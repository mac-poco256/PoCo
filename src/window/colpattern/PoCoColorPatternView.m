//
// PoCoColorPatternView.m
// implementation of PoCoColorPatternView class.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoColorPatternView.h"

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"
#import "PoCoMyDocument.h"
#import "PoCoView.h"
#import "PoCoSelLayer.h"
#import "PoCoPicture.h"
#import "PoCoPalette.h"
#import "PoCoColorPattern.h"
#import "PoCoControllerFactory.h"
#import "PoCoControllerColorPatternSetter.h"

// 内部定数
static  unsigned int SEL_SIZE = 64;     // 1要素の大きさ(dot 単位)(枠含む)
static  unsigned int H_MAX = 8;         // 水平要素数(個数)

// ============================================================================
@implementation PoCoColorPatternView

// ----------------------------------------------------------------------------
// instance - private.

//
// observer を登録
//
//  Call
//    None
//
//  Return
//    None
//
-(void)registerObserver
{
    NSNotificationCenter *nc;

    nc = [NSNotificationCenter defaultCenter];
    if (nc != nil) {
        // 編集対象変更を受信
        [nc addObserver:self
               selector:@selector(changePicture:)
                   name:PoCoChangePicture
                 object:nil];   
    
        // パレット変更を受信
        [nc addObserver:self
               selector:@selector(changePalette:)
                   name:PoCoChangePalette
                 object:nil];

        // 選択色変更を受信
        [nc addObserver:self
               selector:@selector(changeColor:)
                   name:PoCoChangeColor
                 object:nil];

        // カラーパターン更新を受信
        [nc addObserver:self
               selector:@selector(changePattern:)
                   name:PoCoColorPatternSet
                 object:nil];
    }

    return;
}


//
// 正規化された座標へ変換
//
//  Call
//    p  : 実座標(画面上)
//    rb : YES : 右下
//         NO  : 左上
//
//  Return
//    function : 平面位置
//
-(PoCoPoint *)toNormalPos:(PoCoPoint *)p
               isRightBot:(BOOL)rb
{
    PoCoPoint *np = [[PoCoPoint alloc] initX:([p x] / SEL_SIZE)
                                       initY:([p y] / SEL_SIZE)];
    if (rb) {
        [np moveX:-1 moveY:-1];
    }

    return np;
}


//
// 色番号から矩形領域変換
//
//  Call
//    num : 色番号
//
//  Return
//    function : 対象矩形領域
//
-(NSRect)numToRect:(int)num
{
    NSRect r;

    r.origin.x = (float)((num % H_MAX) * SEL_SIZE);
    r.origin.y = (float)((num / H_MAX) * SEL_SIZE);
    r.size.width = (float)(SEL_SIZE);
    r.size.height = (float)(SEL_SIZE);

    return r;
}


//
// 1マス分の描画
//
//  Call
//    num      : 要素番号
//    isSelect : YES : 選択中表示
//               NO  : 非選択中表示
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)drawCell:(int)num
       isSelect:(BOOL)sel
{
    NSRect r;
    NSImageRep *img;
    PoCoRect *pr;
    PoCoPicture *picture;
    PoCoColorPattern *pat;

    picture = [[self->docCntl_ currentDocument] picture];
    pat = [picture colpat:num];
    if (pat != nil) {
        // 座標を算出
        r = [self numToRect:num];

        // 選択中なら枠をつける
        pr = nil;
        if (sel) {
            [[NSColor whiteColor] set];
            [NSBezierPath fillRect:r];
            (r.origin.x)++;
            (r.origin.y)++;
            (r.size.width)--;
            (r.size.height)--;
            [[NSColor blackColor] set];
            [NSBezierPath fillRect:r];
            pr = [[PoCoRect alloc] initLeft:1
                                    initTop:1
                                  initRight:r.size.width
                                 initBottom:r.size.height];
        } else {
            pr = [[PoCoRect alloc] initLeft:0
                                    initTop:0
                                  initRight:SEL_SIZE
                                 initBottom:SEL_SIZE];
        }
        img = [pat preview:pr
                   palette:[picture palette]];
        [pr release];

        // パターンを描画
        if (img != nil) {
            [img drawAtPoint:r.origin];
            [img release];
        }
    }

    return;
}


// ----------------------------------------------------------------------------
// instance - public.

//
// initialize
//
//  Call
//    frameRect : 矩形領域(api 変数)
//
//  Return
//    function  : 実体
//    info_     : 編集情報(instance 変数)
//    docCntl_  : document controller(instance 変数)
//
-(id)initWithFrame:(NSRect)frameRect
{
    DPRINT((@"[PoCoColorPatternView initWithFrame]\n"));

    // super class の初期化
    self = [super initWithFrame:frameRect];

    // 自身の初期化
    if (self != nil) {
        self->info_ = nil;
        self->docCntl_ = nil;

        // observer を登録
        [self registerObserver];

        // document controller を取得
        self->docCntl_ = [NSDocumentController sharedDocumentController];
        [self->docCntl_ retain];

        // 編集情報を取得
        self->info_ = [(PoCoAppController *)([NSApp delegate]) editInfo];
        [self->info_ retain];
    }

    return self;
}


//
// deallocate
//
//  Call
//    None
//
//  Return
//    info_    : 編集情報(instance 変数)
//    docCntl_ : document controller(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoColorPatternView dealloc]\n"));

    // observer の登録を解除
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // 資源を解放
    [self->info_ release];
    [self->docCntl_ release];
    self->info_ = nil;
    self->docCntl_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 座標系を反転
//
//  Call
//    None
//
//  Return
//    function : YES
//
-(BOOL)isFlipped
{
    return YES;
}


//
// set the clips to bound property (always return YES).
//
//  Call:
//    none.
//
//  Return:
//    function : YES (always).
//
- (BOOL)clipsToBounds
{
    return YES;
}


//
// 表示要求
//
//  Call
//    rect  : 領域(api 変数)
//    info_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(void)drawRect:(NSRect)rect
{
    int i;
    int x;
    int y;
    int snum;
    PoCoRect *r;
    PoCoPoint *lt;
    PoCoPoint *rb;
    PoCoSelColor *scol;

//    DPRINT((@"[PoCoPaletteView drawRect]\n"));

    // 選択色情報を取得
    scol = [self->info_ selColor];
    snum = (([scol isUnder]) || ([scol isColor])) ? -1 : [scol num];

    // 範囲の算出
    r = [[PoCoRect alloc] initNSRect:rect];
    lt = [self toNormalPos:[r  lefttop] isRightBot:NO];
    rb = [self toNormalPos:[r rightbot] isRightBot:YES];
    if ((r == nil) || (lt == nil) || (rb == nil)) {
        ;
    } else {
        // 表示
        if (([lt x] == [rb x]) && ([lt y] == [rb y])) {
            i = (([lt y] * H_MAX) + [lt x]);
            [self drawCell:i
                  isSelect:(i == snum)];
        } else if ([lt x] == [rb x]) {
            i = (([lt y] * H_MAX) + [lt x]);
            for (y = [lt y]; y <= [rb y]; (y)++, i += H_MAX) {
                [self drawCell:i
                      isSelect:(i == snum)];
            }
        } else if ([lt y] == [rb y]) {
            i = (([lt y] * H_MAX) + [lt x]);
            for (x = [lt x]; x <= [rb x]; (x)++, (i)++) {
                [self drawCell:i
                      isSelect:(i == snum)];
            }
        } else {
            for (y = [lt y]; y <= [rb y]; (y)++) {
                i = ((y * H_MAX) + [lt x]);
                for (x = [lt x]; x <= [rb x]; (x)++, (i)++) {
                    [self drawCell:i
                          isSelect:(i == snum)];
                }
            }
        }
    }
    [r release];
    [lt release];
    [rb release];

    return;
}


// ----------------------------------------------------------------------------
// instance - public - observers.

//
// 表示画像を切り替え
//
//  Call
//    note : 通知内容
//
//  Return
//    None
//
-(void)changePicture:(NSNotification *)note
{
    // 単純に全再描画
    [self setNeedsDisplay:YES];

    return;
}


//
// パレットを編集
//
//  Call
//    note : 通知内容
//
//  Return
//    None
//
-(void)changePalette:(NSNotification *)note
{
    // 単純に全再描画
    [self setNeedsDisplay:YES];

    return;
}


//
// 選択色の切り替え
//
//  Call
//    note  : 通知内容
//    info_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(void)changeColor:(NSNotification *)note
{
    int onum;
    PoCoSelColor *scol;

    // 以前の選択色
    scol = [self->info_ oldColor];
    if ([scol isPattern]) {
        onum = [scol num];
        [self setNeedsDisplayInRect:[self numToRect:onum]];
    } else {
        onum = -1;
    }
    
    // 現在の選択色
    scol = [self->info_ selColor];
    if (([scol isPattern]) && (onum != [scol num])) {
        [self setNeedsDisplayInRect:[self numToRect:[scol num]]];
    }

    return;
}


//
// カラーパターン更新
//
//  Call
//    note : 通知内容
//
//  Return
//    None
//
-(void)changePattern:(NSNotification *)note
{
    // 単純に全再描画
    [self setNeedsDisplay:YES];

    return;
}


// ----------------------------------------------------------------------------
// instance - public - for IBActions.

//
// パターンを設定
//
//  Call
//    sender   : 操作対象(api 変数)
//    info_    : 編集情報(instance 変数)
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(IBAction)setPattern:(id)sender
{
    MyDocument *doc;

    if ([[self->info_ selRect] empty]) {
        // 選択範囲がなければ無視
        ;
    } else if ([[self->info_ selColor] isPattern]) {
        doc = [self->docCntl_ currentDocument];

        // 選択枠消去
        [[doc view] drawGuideLine];

        // 選択中のカラーパターンを更新
        [[(PoCoAppController *)([NSApp delegate]) factory]
            createColorPatternSetter:YES
                                 num:[[self->info_ selColor] num]
                               layer:[[[self->docCntl_ currentDocument] selLayer] sel]
                                rect:[self->info_ selRect]];

        // 選択枠表示
        [[doc view] drawGuideLine];
    }

    return;
}


// ----------------------------------------------------------------------------
// instance - public - event handlers (especially pointing device).

// 
// ボタンダウンイベントの受け入れ可否
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    function : 可否
//
-(BOOL)acceptsFirstMouse:(NSEvent *)evt
{
    // 種別判定は無視
    ;

    return YES;
}


//
// ボタンダウン処理
//
//  Call
//    evt   : 発生イベント(api 変数)
//    info_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(void)mouseDown:(NSEvent *)evt
{
    int num;
    NSPoint p;
    PoCoSelColor *oldColor;
    
    // 位置を取得
    p = [PoCoPoint corrNSPoint:[self convertPoint:[evt locationInWindow] fromView:nil]];
    if ([self mouse:p inRect:[self bounds]]) {
        oldColor = [self->info_ selColor];

        // 選択番号を取得
        num = (((int)(p.x) / SEL_SIZE) + (((int)(p.y) / SEL_SIZE) * H_MAX));
        if (([oldColor isColor]) || ([oldColor num] != num)) {
            // 色を切り替え
            [self->info_ setSelPattern:num];

            // 切り替えを通知(自身も受け取る)
            [[NSNotificationCenter defaultCenter]
                postNotificationName:PoCoChangeColor
                              object:nil];
        }
    }

    return;
}

            
//
// ドラッグ処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    None
//  
-(void)mouseDragged:(NSEvent *)evt
{
    // ボタンダウン処理と同じにする
    [self mouseDown:evt];
  
    return;
} 

@end
