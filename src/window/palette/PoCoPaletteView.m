//
// PoCoPaletteView.m
// implementation of PoCoPaletteView class.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoPaletteView.h"

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"
#import "PoCoMyDocument.h"
#import "PoCoPicture.h"
#import "PoCoPalette.h"
#import "PoCoControllerFactory.h"
#import "PoCoControllerPaletteSingleSetter.h"

// 内部定数
static  unsigned int SEL_SIZE = 8;      // 1要素の大きさ(dot 単位)(枠含む)
static  unsigned int H_MAX = 16;        // 水平要素数(個数)

// ============================================================================
@implementation PoCoPaletteView

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

        // 選択色変更を受信
        [nc addObserver:self
               selector:@selector(changeColor:)
                   name:PoCoChangeColor
                 object:nil];

        // パレット変更を受信
        [nc addObserver:self
               selector:@selector(changePalette:)
                   name:PoCoChangePalette
                 object:nil];
        [nc addObserver:self
               selector:@selector(changePalette:)
                   name:PoCoChangePaletteAttr
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
//    function : パレット平面位置
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
// 詳細テキストを表示
//
//  Call
//    number_               : 色番号(outlet)
//    elementR_             : 色要素(R)(outlet)
//    elementG_             : 色要素(G)(outlet)
//    elementB_             : 色要素(B)(outlet)
//    elementH_             : 色要素(H)(outlet)
//    elementL_             : 色要素(L)(outlet)
//    elementS_             : 色要素(S)(outlet)
//    attributeMask_        : マスク(outlet)
//    attributeDropper_     : 吸い取り禁止(outlet)
//    attributeTransparent_ : 透明(outlet)
//    docCntl_              : document controller(instance 変数)
//
//  Return
//    None
//
-(void)showInfoText
{
    PoCoSelColor *scol = [[(PoCoAppController *)([NSApp delegate]) editInfo] selColor];
    PoCoColor *col;

    if ([scol isColor]) {
        col = [[[[self->docCntl_ currentDocument] picture] palette] palette:[scol num]];

        // 表示
        [self->number_ setStringValue:[NSString stringWithFormat:@"%03d", [scol num]]];
        [self->elementR_ setStringValue:[NSString stringWithFormat:@"0x%02X", [col red]]];
        [self->elementG_ setStringValue:[NSString stringWithFormat:@"0x%02X", [col green]]];
        [self->elementB_ setStringValue:[NSString stringWithFormat:@"0x%02X", [col blue]]];
        [self->elementH_ setStringValue:[NSString stringWithFormat:@"%03d", [col hue]]];
        [self->elementL_ setStringValue:[NSString stringWithFormat:@"%03d", [col lightness]]];
        [self->elementS_ setStringValue:[NSString stringWithFormat:@"%03d", [col saturation]]];
        [self->attributeMask_ setState:(([col isMask]) ? 1 : 0)];
        [self->attributeDropper_ setState:(([col noDropper]) ? 1 : 0)];
        [self->attributeTransparent_ setState:(([col isTrans]) ? 1 : 0)];

        // 補助属性は enable にする
        [self->attributeMask_ setEnabled:YES];
        [self->attributeDropper_ setEnabled:YES];
        [self->attributeTransparent_ setEnabled:YES];
    } else {
        // 表示
        [self->number_ setStringValue:@"---"];
        [self->elementR_ setStringValue:@"----"];
        [self->elementG_ setStringValue:@"----"];
        [self->elementB_ setStringValue:@"----"];
        [self->elementH_ setStringValue:@"---"];
        [self->elementL_ setStringValue:@"---"];
        [self->elementS_ setStringValue:@"---"];
        [self->attributeMask_ setState:0];
        [self->attributeDropper_ setState:0];
        [self->attributeTransparent_ setState:0];

        // 補助属性は disable にする
        [self->attributeMask_ setEnabled:NO];
        [self->attributeDropper_ setEnabled:NO];
        [self->attributeTransparent_ setEnabled:NO];
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
//    function : 実体
//    docCntl_ : document controller(instance 変数)
//
-(id)initWithFrame:(NSRect)frameRect
{
    DPRINT((@"[PoCoPaletteView initWithFrame]\n"));

    // super class の初期化
    self = [super initWithFrame:frameRect];

    // 自身の初期化
    if (self != nil) {
        // observer を登録
        [self registerObserver];

        // document controller を取得
        self->docCntl_ = [NSDocumentController sharedDocumentController];
        [self->docCntl_ retain];
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
//    docCntl_ : document controller(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoPaletteView dealloc]\n"));

    // observer の登録を解除
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // 資源を解放
    [self->docCntl_ release];
    self->docCntl_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// awake from nib.
//
//  Call:
//    attributeMask_        : マスク(outlet)
//    attributeDropper_     : 吸い取り禁止(outlet)
//    attributeTransparent_ : 透明(outlet)
//
//  Return:
//    attributesRect_[] : 補助属性の初期位置(instance 変数)
//
- (void)awakeFromNib
{
    // forwaed to super class.
    [super awakeFromNib];

    // store initial positions.
    self->attributesRect_[0] = [self->attributeMask_ frame];
    self->attributesRect_[1] = [self->attributeDropper_ frame];
    self->attributesRect_[2] = [self->attributeTransparent_ frame];

    // set property.
    [self setClipsToBounds:YES];

    return;
}


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

    // 詳細テキストを表示
    [self showInfoText];

    return;
}


//
// 選択色の切り替え
//  主ウィンドウから送信される
//  自身の press による切り替えも受け取る
//
//  Call
//    note : 通知内容
//
//  Return
//    None
//
-(void)changeColor:(NSNotification *)note
{
    int onum;
    PoCoSelColor *scol;

    // 以前の選択色
    scol = [[(PoCoAppController *)([NSApp delegate]) editInfo] oldColor];
    if ([scol isColor]) {
        onum = [scol num];
        [self setNeedsDisplayInRect:[self numToRect:onum]];
    } else {
        onum = -1;
    }

    // 現在の選択色
    scol = [[(PoCoAppController *)([NSApp delegate]) editInfo] selColor];
    if (([scol isColor]) && (onum != [scol num])) {
        [self setNeedsDisplayInRect:[self numToRect:[scol num]]];
    }

    // 詳細テキストを表示
    [self showInfoText];

    return;
}


//
// パレットを変更(編集)
//
//  Call
//    note : 通知内容
//
//  Return
//    None
//
-(void)changePalette:(NSNotification *)note
{
    if ([note object] == nil) {
        [self setNeedsDisplay:YES];
    } else {
        [self setNeedsDisplayInRect:[self numToRect:[[note object] intValue]]];
    }

    // 詳細テキストを表示
    [self showInfoText];

    return;
}


//
// 表示要求
//
//  Call
//    rect : 表示領域(api 変数)
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
    scol = [[(PoCoAppController *)([NSApp delegate]) editInfo] selColor];
    snum = ((([scol isUnder]) || ([scol isPattern])) ? -1 : [scol num]);

    // 範囲の算出
    r = [[PoCoRect alloc] initNSRect:rect];
    lt = [self toNormalPos:[r lefttop]
                isRightBot:NO];
    rb = [self toNormalPos:[r rightbot]
                isRightBot:YES];
    if ((r == nil) || (lt == nil) || (rb == nil)) {
        ;
    } else {
        // 表示
        if (([lt x] == [rb x]) && ([lt y] == [rb y])) {
            i = (([lt y] * H_MAX) + [lt x]);
            [self drawColor:i
                   isSelect:(i == snum)];
        } else if ([lt x] == [rb x]) {
            i = (([lt y] * H_MAX) + [lt x]);
            for (y = [lt y]; y <= [rb y]; (y)++, i += H_MAX) {
                [self drawColor:i
                       isSelect:(i == snum)];
            }
        } else if ([lt y] == [rb y]) {
            i = (([lt y] * H_MAX) + [lt x]);
            for (x = [lt x]; x <= [rb x]; (x)++, (i)++) {
                [self drawColor:i
                       isSelect:(i == snum)];
            }
        } else {
            for (y = [lt y]; y <= [rb y]; (y)++) {
                i = ((y * H_MAX) + [lt x]);
                for (x = [lt x]; x <= [rb x]; (x)++, (i)++) {
                    [self drawColor:i
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
// 1色分の描画
//
//  Call
//    num      : 番号
//    sel      : YES : 選択中表示
//               NO  : 非選択中表示
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)drawColor:(int)num
        isSelect:(BOOL)sel
{
    NSRect  r;
    PoCoColor *col = [[[[self->docCntl_ currentDocument] picture] palette] palette:num];

    if (col != nil) {
        // 座標を算出
        r = [self numToRect:num];

        // 選択中なら枠をつける
        if (sel) {
            [[NSColor whiteColor] set];
            [NSBezierPath fillRect:r];
            (r.origin.x)++;
            (r.origin.y)++;
            (r.size.width)--;
            (r.size.height)--;
            [[NSColor blackColor] set];
            [NSBezierPath fillRect:r];
            (r.size.width)--;
            (r.size.height)--;
        }

        // 色を描画
        [[NSColor colorWithCalibratedRed:[col floatRed]
                                   green:[col floatGreen]
                                    blue:[col floatBlue]
                                   alpha:(float)(1.0)] set];
        [NSBezierPath fillRect:r];
    }

    return;
}


//
// ウィンドウ拡縮
//
//  Call
//    state             : 拡縮状態
//                        YES : 縮小表示
//                        NO  : 拡大表示
//    attributesRect_[] : 補助属性の初期位置(instance 変数)
//
//  Return
//    titleR_               : 項目名(R)(outlet)
//    titleG_               : 項目名(G)(outlet)
//    titleB_               : 項目名(B)(outlet)
//    titleH_               : 項目名(H)(outlet)
//    titleL_               : 項目名(L)(outlet)
//    titleS_               : 項目名(S)(outlet)
//    number_               : 色番号(outlet)
//    elementR_             : 色要素(R)(outlet)
//    elementG_             : 色要素(G)(outlet)
//    elementB_             : 色要素(B)(outlet)
//    elementH_             : 色要素(H)(outlet)
//    elementL_             : 色要素(L)(outlet)
//    elementS_             : 色要素(S)(outlet)
//    attributeMask_        : マスク(outlet)
//    attributeDropper_     : 吸い取り禁止(outlet)
//    attributeTransparent_ : 透明(outlet)
//
-(void)setDisclosed:(BOOL)state
{
    NSRect r;

    if (state) {
        // 縮小表示では隠す
        [self->number_ setHidden:YES];
        [self->titleR_ setHidden:YES];
        [self->elementR_ setHidden:YES];
        [self->titleG_ setHidden:YES];
        [self->elementG_ setHidden:YES];
        [self->titleB_ setHidden:YES];
        [self->elementB_ setHidden:YES];
        [self->titleH_ setHidden:YES];
        [self->elementH_ setHidden:YES];
        [self->titleL_ setHidden:YES];
        [self->elementL_ setHidden:YES];
        [self->titleS_ setHidden:YES];
        [self->elementS_ setHidden:YES];

        // 補助属性の位置をずらす
        r = self->attributesRect_[0];
        r.origin.x = -3.0;
        [self->attributeMask_ setFrame:r];
        r.origin.x += (self->attributesRect_[0].size.width - 2.0);
        [self->attributeDropper_ setFrame:r];
        r.origin.x += (self->attributesRect_[1].size.width - 2.0);
        [self->attributeTransparent_ setFrame:r];
    } else {
        // 補助属性の位置を戻す
        [self->attributeMask_ setFrame:self->attributesRect_[0]];
        [self->attributeDropper_ setFrame:self->attributesRect_[1]];
        [self->attributeTransparent_ setFrame:self->attributesRect_[2]];

        // 拡大表示では見せる
        [self->number_ setHidden:NO];
        [self->titleR_ setHidden:NO];
        [self->elementR_ setHidden:NO];
        [self->titleG_ setHidden:NO];
        [self->elementG_ setHidden:NO];
        [self->titleB_ setHidden:NO];
        [self->elementB_ setHidden:NO];
        [self->titleH_ setHidden:NO];
        [self->elementH_ setHidden:NO];
        [self->titleL_ setHidden:NO];
        [self->elementL_ setHidden:NO];
        [self->titleS_ setHidden:NO];
        [self->elementS_ setHidden:NO];
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
//    evt : 発生イベント(api 変数)
//
//  Return
//    selNumber_ : 編集中の色番号(instance 変数)
//
-(void)mouseDown:(NSEvent *)evt
{
    int num;
    const NSPoint p = [PoCoPoint corrNSPoint:[self convertPoint:[evt locationInWindow] fromView:nil]];
    PoCoSelColor *oldColor = [[(PoCoAppController *)([NSApp delegate]) editInfo] selColor];

    num = -1;

    if ([self mouse:p inRect:[self bounds]]) {
        // 選択番号を取得
        num = (int)(p.x) / SEL_SIZE + ((int)(p.y) / SEL_SIZE) * H_MAX;
        if (([oldColor isPattern]) || ([oldColor num] != num)) {
            // 色を切り替え
            [[(PoCoAppController *)([NSApp delegate]) editInfo] setSelColor:num];

            // 切り替えを通知(自身も受け取る)
            [[NSNotificationCenter defaultCenter]
                postNotificationName:PoCoChangeColor
                              object:nil];
        }
    }

    // double click 以上の場合は詳細設定へ
    if (((num >= 0) && (num < COLOR_MAX)) && ([evt clickCount] >= 2)) {
          self->selNumber_ = num;
          [self raiseColorInfoSheet];
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


// ----------------------------------------------------------------------------
// instance - public - for the detailed colour attribute setting sheets.

//
// 色詳細設定シートを開ける
//
//  Call
//    accessoryView_ : 補助属性(outlet)
//    selNumber_     : 編集中の色番号(instance 変数)
//
//  Return
//    infoSheet_            : 色詳細設定シート(instance 変数)
//    accessoryMask_        : 上塗り禁止(outlet)
//    accessoryDropper_     : 吸い取り禁止(outlet)
//    accessoryTransparent_ : 透明(outlet)
//
-(void)raiseColorInfoSheet
{
    PoCoColor *col;

    // 色を取得
    col = [[[[self->docCntl_ currentDocument] picture] palette] palette:self->selNumber_];

    // パネルを生成
    [NSColorPanel setPickerMask:(NSColorPanelRGBModeMask           |
                                 NSColorPanelHSBModeMask           |
                                 NSColorPanelCMYKModeMask          |
                                 NSColorPanelCustomPaletteModeMask |
                                 NSColorPanelColorListModeMask     |
                                 NSColorPanelWheelModeMask         |
                                 NSColorPanelCrayonModeMask)];
    self->infoSheet_ = [NSColorPanel sharedColorPanel];
    [self->infoSheet_ setShowsAlpha:NO];

    // 色を与える
    [self->infoSheet_ setColor:[NSColor colorWithCalibratedRed:[col floatRed]
                                                         green:[col floatGreen]
                                                          blue:[col floatBlue]
                                                         alpha:(float)(1.0)]];

    // 追加情報を設定
    [self->infoSheet_ setAccessoryView:self->accessoryView_];
    [self->accessoryMask_ setState:([col isMask]) ? 1 : 0];
    [self->accessoryDropper_ setState:([col noDropper]) ? 1 : 0];
    [self->accessoryTransparent_ setState:([col isTrans]) ? 1 : 0];

    // シートを開ける
    [NSApp beginSheet:self->infoSheet_
       modalForWindow:[self window]
        modalDelegate:self
       didEndSelector:@selector(colorInfoSheetDidEnd:returnCode:contextInfo:)
          contextInfo:nil];

    return;
}


//
// 色詳細設定シートを閉じる
//  補助属性群の [cancel] [set] button の action
//
//  Call
//    sender     : 実行対象(api 変数)
//    infoSheet_ : 色詳細設定シート(instance 変数)
//
//  Return
//    None
//
-(IBAction)endColorInfoSheet:(id)sender
{
    // 補助属性設定シートを閉じる
    [self->infoSheet_ orderOut:sender];
    [NSApp endSheet:self->infoSheet_
         returnCode:[sender tag]];

    return;
}


//
// 色詳細設定シートが閉じられた
//
//  Call
//    sheet                 : 閉じたsheet (api 変数)
//    returnCode            : 終了時返り値(api 変数)
//    contextInfo           : 補助情報(api 変数)
//    accessoryMask_        : 上塗り禁止(outlet)
//    accessoryDropper_     : 吸い取り禁止(outlet)
//    accessoryTransparent_ : 透明(outlet)
//    infoSheet_            : 色詳細設定シート(instance 変数)
//    selNumber_            : 編集中の色番号(instance 変数)
//
//  Return
//    None
//
-(void)colorInfoSheetDidEnd:(NSWindow *)sheet
                 returnCode:(int)returnCode
                contextInfo:(void *)contextInfo
{
    CGFloat red;
    CGFloat green;
    CGFloat blue;

    // [set] で抜けていたら、設定を反映
    if (returnCode == 0) {
        // 色を取得
        [[self->infoSheet_ color] getRed:&(red)
                                   green:&(green)
                                    blue:&(blue)
                                   alpha:NULL];

        // 値を取得
        [[(PoCoAppController *)([NSApp delegate]) factory]
            createPaletteSingleSetter:YES
                                  num:self->selNumber_
                                  red:(unsigned char)(red * 255.0)
                                green:(unsigned char)(green * 255.0)
                                 blue:(unsigned char)(blue * 255.0)
                               isMask:([self->accessoryMask_ state] != 0)
                               noDrop:([self->accessoryDropper_ state] != 0)
                              isTrans:([self->accessoryTransparent_ state] != 0)
                                 name:[[NSBundle mainBundle]
                                          localizedStringForKey:@"SinglePaletteElementSet"
                                                          value:@"edit single palette"
                                                          table:nil]];
    }

    return;
}


// ----------------------------------------------------------------------------
// instance - public - for IBActions.

//
// マスク
//
//  Call
//    sender            : 操作対象(api 変数)
//    attributeMask_    : マスク(outlet)
//    attributesRect_[] : 補助属性の初期位置(instance 変数)
//
//  Return
//    None
//
-(IBAction)attributeMask:(id)sender
{
    PoCoSelColor *scol = [[(PoCoAppController *)([NSApp delegate]) editInfo] selColor];
    PoCoColor *col;

    if ([scol isColor]) {
        col = [[[[self->docCntl_ currentDocument] picture] palette] palette:[scol num]];

        // 設定を反転
        [[(PoCoAppController *)([NSApp delegate]) factory]
            createPaletteAttributeSetter:YES
                                     num:[scol num]
                                 setType:(([col isMask]) ? NO : YES)
                                    mask:YES
                                 dropper:NO
                                   trans:NO];

        // 表示に反映
        [self->attributeMask_ setState:(([col isMask]) ? 1 : 0)];
    }

    // 再描画要求を発しておく(位置かぶりのため)
    if ([self->attributeMask_ frame].origin.x != self->attributesRect_[0].origin.x) {
        [self setNeedsDisplay:YES];
    }

    return;
}


//
// 吸い取り禁止
//
//  Call
//    sender            : 操作対象(api 変数)
//    attributeDropper_ : 吸い取り禁止(outlet)
//    attributesRect_[] : 補助属性の初期位置(instance 変数)
//
//  Return
//    None
//
-(IBAction)attributeDropper:(id)sender
{
    PoCoSelColor *scol = [[(PoCoAppController *)([NSApp delegate]) editInfo] selColor];
    PoCoColor *col;

    if ([scol isColor]) {
        col = [[[[self->docCntl_ currentDocument] picture] palette] palette:[scol num]];

        // 設定を反転
        [[(PoCoAppController *)([NSApp delegate]) factory]
            createPaletteAttributeSetter:YES
                                     num:[scol num]
                                 setType:(([col noDropper]) ? NO : YES)
                                    mask:NO
                                 dropper:YES
                                   trans:NO];

        // 表示に反映
        [self->attributeDropper_ setState:(([col noDropper]) ? 1 : 0)];
    }

    // 再描画要求を発しておく(位置かぶりのため)
    if ([self->attributeDropper_ frame].origin.x != self->attributesRect_[1].origin.x) {
        [self setNeedsDisplay:YES];
    }

    return;
}


//
// 透明
//
//  Call
//    sender                : 操作対象(api 変数)
//    attributeTransparent_ : 透明(outlet)
//    attributesRect_[]     : 補助属性の初期位置(instance 変数)
//
//  Return
//    None
//
-(IBAction)attributeTransparent:(id)sender
{
    PoCoSelColor *scol = [[(PoCoAppController *)([NSApp delegate]) editInfo] selColor];
    PoCoColor *col;

    if ([scol isColor]) {
        col = [[[[self->docCntl_ currentDocument] picture] palette] palette:[scol num]];

        // 設定を反転
        [[(PoCoAppController *)([NSApp delegate]) factory]
            createPaletteAttributeSetter:YES
                                     num:[scol num]
                                 setType:(([col isTrans]) ? NO : YES)
                                    mask:NO
                                 dropper:NO
                                   trans:YES];

        // 表示に反映
        [self->attributeTransparent_ setState:(([col isTrans]) ? 1 : 0)];
    }

    // 再描画要求を発しておく(位置かぶりのため)
    if ([self->attributeTransparent_ frame].origin.x != self->attributesRect_[2].origin.x) {
        [self setNeedsDisplay:YES];
    }

    return;
}

@end
