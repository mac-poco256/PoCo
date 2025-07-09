//
//	Pelistina on Cocoa - PoCo -
//	パレット詳細情報
//
//	Copyright (C) 2005-2019 KAENRYUU Koutoku.
//

#import "PoCoPaletteInfoView.h"

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"
#import "PoCoMyDocument.h"
#import "PoCoPicture.h"
#import "PoCoPalette.h"

#import "PoCoControllerFactory.h"
#import "PoCoControllerPaletteIncrementer.h"
#import "PoCoControllerPaletteDecrementer.h"
#import "PoCoControllerPaletteAttributeSetter.h"


// 内部定数
static  unsigned int H_SIZE = 18;       // 1要素の幅(dot 単位)(枠含む)
static  unsigned int V_SIZE = 64;       // 1要素の高さ(dot 単位)(枠含む)
static  unsigned int H_MAX = 16;        // 水平要素数(個数)
static  unsigned int SMPL_H = 16;       // 色見本の高さ(dot 単位）
static  unsigned int ELMT_H = 10;       // 要素値の高さ(dot 単位)
static  unsigned int ATTR_H = 6;        // 各属性の高さ(dot 単位)
static  unsigned int SMPL_ELMT_H = 16 + (10 * 3);

typedef enum {                          // 位置種別識別番号
    PT_UNKNOWN,                         // 不明
    PT_SAMPLE,                          // 色見本
    PT_R_ELEMENT_H,                     // 赤要素上位
    PT_R_ELEMENT_L,                     // 赤要素下位
    PT_G_ELEMENT_H,                     // 緑要素上位
    PT_G_ELEMENT_L,                     // 緑要素下位
    PT_B_ELEMENT_H,                     // 青要素上位
    PT_B_ELEMENT_L,                     // 青要素下位
    PT_ATTR_MASK,                       // 属性(上塗り禁止)
    PT_ATTR_DROPPER,                    // 属性(吸い取り禁止)
    PT_ATTR_TRANS                       // 属性(透過)
} POS_TYPE;


// 内部マクロ
#define DEF_POSINF  (POS_INF){-1, -1, PT_UNKNOWN}


// 内部型宣言
typedef struct _positionInfo {          // 位置情報
    int num;                            // 領域番号(bias 未反映)
    int cnum;                           // 色番号(bias 反映済み)
    POS_TYPE type;                      // 種別番号
} POS_INF;

// ============================================================================
@implementation PoCoPaletteInfoView

// --------------------------------------------------------- instance - private
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

         // パレット属性変更を受信
        [nc addObserver:self
               selector:@selector(changePaletteAttr:)
                   name:PoCoChangePaletteAttr
                 object:nil];
    }

    return;
}


//
// 色番号から矩形領域へ変換
//  色番号というより、ここでは表示要素番号(0 - 31 の値)
//
//  Call
//    num  : 色番号(0 - 31)
//    bias : view の縦軸のズレ
//
//  Return
//    function : 対象矩形領域
//
-(NSRect)numToRect:(int)num
          withBias:(float)bias
{
    NSRect r;

    r.origin.x = (float)((num % H_MAX) * H_SIZE);
    r.origin.y = ((float)((num / H_MAX) * V_SIZE) + bias);
    r.size.width = (float)(H_SIZE);
    r.size.height = (float)(V_SIZE);

    return r;
}


//
// 座標から色番号へ変換
//
//  Call
//    p    : 座標(view 内に変換済み)
//    bias : view の縦軸のズレ
//
//  Return
//    function : 位置情報
//
-(POS_INF)pointToNum:(NSPoint)p
            withBias:(float)bias
{
    POS_INF inf = DEF_POSINF;
    NSRect r;

    // 要素番号の算出
    p = [PoCoPoint corrNSPoint:p];
    inf.num = (((int)(p.x) / H_SIZE) + (((int)(p.y - bias) / V_SIZE) * H_MAX));
    inf.cnum = (inf.num + ((int)(bias) * H_MAX));

    // 種別の判定
    r = [self numToRect:inf.num withBias:bias];
    if (p.y < (r.origin.y + (float)(SMPL_H))) {
        inf.type = PT_SAMPLE;
    } else if (p.y < (r.origin.y + (float)(SMPL_H + ELMT_H * 1))) {
        inf.type = (p.x < (r.origin.x + (float)(H_SIZE >> 1))) ?
                       PT_R_ELEMENT_H : PT_R_ELEMENT_L;
    } else if (p.y < (r.origin.y + (float)(SMPL_H + ELMT_H * 2))) {
        inf.type = (p.x < (r.origin.x + (float)(H_SIZE >> 1))) ?
                       PT_G_ELEMENT_H : PT_G_ELEMENT_L;
    } else if (p.y < (r.origin.y + (float)(SMPL_H + ELMT_H * 3))) {
        inf.type = (p.x < (r.origin.x + (float)(H_SIZE >> 1))) ?
                       PT_B_ELEMENT_H : PT_B_ELEMENT_L;
    } else if (p.y < (r.origin.y + (float)(SMPL_ELMT_H + ATTR_H * 1))) {
        inf.type = PT_ATTR_MASK;
    } else if (p.y < (r.origin.y + (float)(SMPL_ELMT_H + ATTR_H * 2))) {
        inf.type = PT_ATTR_DROPPER;
    } else if (p.y < (r.origin.y + (float)(SMPL_ELMT_H + ATTR_H * 3))) {
        inf.type = PT_ATTR_TRANS;
    }

    return inf;
}


//
// 部分再描画領域と要素の鎖交を検証
//
//  Call
//    dr   : 領域群(配列)
//    cnt  : 領域数(dr の配列数)
//    num  : 要素の番号
//    bias : 領域の縦軸のズレ
//
//  Return
//    function : YES : 鎖交がある
//
-(BOOL)isSectrect:(const NSRect *)dr
            count:(int)cnt
           number:(int)num
         withBias:(float)bias
{
    BOOL  result;
    int l;
    const NSRect r = [self numToRect:num withBias:bias];

    result = NO;

    for (l = 0; l < cnt; (l)++) {
        if (NSIntersectsRect(dr[l], r)) {
            result = YES;
            break;
        }
    }

    return result;
}


//
// 枠の描画
//
//  Call
//    r    : 矩形領域
//    push : YES : 押し下
//           NO  : 押し上
//
//  Return
//    function : 枠をさっぴいた領域
//
-(NSRect)frameRect:(NSRect)r
            isPush:(BOOL)push
{
    if (push) {
        [[NSColor blackColor] set];
    } else {
        [[NSColor whiteColor] set];
    }
    [NSBezierPath fillRect:r];

    (r.origin.x)++;
    (r.origin.y)++;
    (r.size.width)--;
    (r.size.height)--;

    if (push) {
        [[NSColor whiteColor] set];
    } else {
        [[NSColor blackColor] set];
    }
    [NSBezierPath fillRect:r];

    (r.size.width)--;
    (r.size.height)--;

    return r;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    rect : 矩形領域(api 引数)
//
//  Return
//    function     : 実体
//    attrType_    : 属性系の操作対象番号(instance 変数)
//    beforeTop_   : 以前の表示原点(instance 変数)
//    docCntl_     : document controller(instance 変数)
//    lockImage_   : 編集不可(instance 変数)
//    unlockImage_ : 編集可(instance 変数)
//
-(id)initWithFrame:(NSRect)frameRect
{
    DPRINT((@"[PoCoPaletteInfoView initWithFrame]\n"));

    // super class の初期化
    self = [super initWithFrame:frameRect];

    // 自身の初期化
    if (self != nil) {
        self->attrType_ = -1;
        self->beforeTop_ = (float)(-1.0);
        self->docCntl_ = nil;
        self->lockImage_ = nil;
        self->unlockImage_ = nil;

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
//    docCntl_     : document controller(instance 変数)
//    lockImage_   : 編集不可(instance 変数)
//    unlockImage_ : 編集可(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoPaletteIntoView dealloc]\n"));
    
    // observer の登録を解除
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // 資源の解放
    [self->docCntl_ release];
    [self->lockImage_ release];
    [self->unlockImage_ release];
    self->docCntl_ = nil;
    self->lockImage_ = nil;
    self->unlockImage_ = nil;

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
    return YES;                         // 常時 YES
}


//
// 要描画領域の clipping
//
//  Call
//    None
//
//  Return
//    function : NO
//
-(BOOL)wantsDefaultClipping
{
    return NO;                          // 常時 NO
}


//
// 初期状態の設定
//
//  Call
//    lock_ : 編集可否(outlet)
//
//  Return
//    lockImage_   : 編集不可(instance 変数)
//    unlockImage_ : 編集可(instance 変数)
//
-(void)setFirstState
{
    // 画像を取得
    self->lockImage_ = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"palettelock" ofType:@"tiff"]];
    self->unlockImage_ = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"paletteunlock" ofType:@"tiff"]];

    // パーツの状態設定
    if ([[(PoCoAppController *)([NSApp delegate]) editInfo] lockPalette]) {
        [self->lock_ setIntValue:1];
        [self->lock_ setImage:self->lockImage_];
    } else {
        [self->lock_ setIntValue:0];
        [self->lock_ setImage:self->unlockImage_];
    }
    [[self enclosingScrollView] setLineScroll:(float)(1.0)];

    return;
}


//
// 表示要求
//
//  Call
//    rect       : 表示領域(api 引数)
//    beforeTop_ : 以前の表示原点(instance 変数)
//
//  Return
//    beforeTop_ : 以前の表示原点(instance 変数)
//
-(void)drawRect:(NSRect)rect
{
    int l;                              // 汎用(loop counter)
    NSInteger cnt;                      // 部分再描画領域個数
    int snum;                           // 選択色番号
    int cnum;                           // 描画色番号
    const NSRect *dr;                   // 部分再描画領域
    const NSRect vr = [self visibleRect];
    PoCoSelColor *scol = [[(PoCoAppController *)([NSApp delegate]) editInfo] selColor];

//    DPRINT((@"[PoCoPaletteInfoView drawRect:{%f, %f, %f, %f}\n", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height));

    // 部分再描画領域を取得
    [self getRectsBeingDrawn:&(dr)
                       count:&(cnt)];

    // 選択色を取得
    snum = ((([scol isUnder]) || ([scol isPattern])) ? -1 : [scol num]);

    // 内容の表示
    cnum = (vr.origin.y * H_MAX);
    if (self->beforeTop_ != vr.origin.y) {
        for (l = 0; l < 32; (l)++, (cnum)++) {
            [self drawColor:l
                   withBias:vr.origin.y
                   isSelect:(cnum == snum)];
        }
    } else {
        self->beforeTop_ = vr.origin.y;
        for (l = 0; l < 32; (l)++, (cnum)++) {
            if ([self isSectrect:dr
                           count:(int)(cnt)
                          number:l
                        withBias:vr.origin.y]) {
                [self drawColor:l
                       withBias:vr.origin.y
                       isSelect:(cnum == snum)];
            }
        }
    }

    return;
}


//
// 1要素分の表示
//
//  Call
//    num       : 要素番号(bias * 16 足したのが色番号)
//    bias      : view の縦軸のズレ
//    sel       : 選択している色か
//    docCntl_  : document controller(instance 変数)
//
//  Return
//    None
//
-(void)drawColor:(int)num
        withBias:(float)bias
        isSelect:(BOOL)sel
{
    int i;                              // 任意(値）
    NSRect er = [self numToRect:num     // 1要素全体の領域
                       withBias:bias];
    NSRect r;                           // 1要素内の領域の管理用
    NSRect fr;                          // 任意(矩形領域)
    BOOL isHLS = ([[(PoCoAppController *)([NSApp delegate]) editInfo] colorMode] == PoCoColorMode_HLS);
    int cnum = (num + ((int)(bias) * H_MAX));
    PoCoColor *col = [[[[self->docCntl_ currentDocument] picture] palette] palette:cnum];
    NSEnumerator *iter;
    NSColor *c;
    NSMutableDictionary *charAttr;      // 文字描画用属性

    charAttr = nil;

    // 背景を一旦消去
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_14)
    iter = [[NSColor alternatingContentBackgroundColors] objectEnumerator];
#else   // (MACOSX_DEPLOYMENT_TARGET >= MAC_OS_X_VERSION_10_14)
    iter = [[NSColor controlAlternatingRowBackgroundColors] objectEnumerator];
#endif  // (MACOSX_DEPLOYMENT_TARGET >= MAC_OS_X_VERSION_10_14)
    c = [iter nextObject];
    [c set];
    if (num & 1) {
        c = [iter nextObject];
        [c set];
    }
    [NSBezierPath fillRect:er];

    if (col != nil) {
        // 文字描画属性を設定
        charAttr = [[NSMutableDictionary alloc] init];
        if (charAttr != nil) {
            [charAttr setObject:[NSFont systemFontOfSize:8]
                         forKey:NSFontAttributeName];
            [charAttr setObject:[NSColor controlTextColor]
                         forKey:NSForegroundColorAttributeName];
        }

        // 色見本の描画
        r = er;
        r.size.height = (float)(SMPL_H);
        fr = ((sel) ? [self frameRect:r isPush:NO] : r);
        [[NSColor colorWithCalibratedRed:[col floatRed]
                                   green:[col floatGreen]
                                    blue:[col floatBlue]
                                   alpha:(float)(1.0)] set];
        [NSBezierPath fillRect:fr];
        r.origin.y += r.size.height;

        // red/hue 要素の描画
        r.size.height = (float)(ELMT_H);
        i = ((isHLS) ? [col hue] : [col red]);
        [[NSString stringWithFormat:@"%X", (i / 0x10)]
                        drawAtPoint:NSMakePoint(r.origin.x + 3, r.origin.y)
                     withAttributes:charAttr];
        [[NSString stringWithFormat:@"%X", (i % 0x10)]
                        drawAtPoint:NSMakePoint(r.origin.x + 11, r.origin.y)
                     withAttributes:charAttr];
        r.origin.y += r.size.height;

        // green/lightness 要素の描画
        i = ((isHLS) ? [col lightness] : [col green]);
        [[NSString stringWithFormat:@"%X", (i / 0x10)]
                        drawAtPoint:NSMakePoint(r.origin.x + 3, r.origin.y)
                     withAttributes:charAttr];
        [[NSString stringWithFormat:@"%X", (i % 0x10)]
                        drawAtPoint:NSMakePoint(r.origin.x + 11, r.origin.y)
                     withAttributes:charAttr];
        r.origin.y += r.size.height;

        // blue/saturation 要素の描画
        i = ((isHLS) ? [col saturation] : [col blue]);
        [[NSString stringWithFormat:@"%X", (i / 0x10)]
                        drawAtPoint:NSMakePoint(r.origin.x + 3, r.origin.y)
                     withAttributes:charAttr];
        [[NSString stringWithFormat:@"%X", (i % 0x10)]
                        drawAtPoint:NSMakePoint(r.origin.x + 11, r.origin.y)
                     withAttributes:charAttr];
        r.origin.y += r.size.height;

        // 上書き禁止の表示
        r.size.height = (float)(ATTR_H);
        fr = [self frameRect:r isPush:[col isMask]];
        [[NSColor colorWithCalibratedRed:0.0
                                   green:1.0
                                    blue:0.0
                                   alpha:0.3] set];
        [NSBezierPath fillRect:fr];
        r.origin.y += r.size.height;

        // 吸い取り禁止の表示
        fr = [self frameRect:r isPush:[col noDropper]];
        [[NSColor colorWithCalibratedRed:1.0
                                   green:1.0
                                    blue:0.0
                                   alpha:0.3] set];
        [NSBezierPath fillRect:fr];
        r.origin.y += r.size.height;

        // 透過の表示
        fr = [self frameRect:r isPush:[col isTrans]];
        [[NSColor colorWithCalibratedRed:1.0
                                   green:0.0
                                    blue:0.0
                                   alpha:0.3] set];
        [NSBezierPath fillRect:fr];
        r.origin.y += r.size.height;
    }

    [charAttr release];
    return;
}


// -------------------------------------------- instance - public - observer 系
//
// 表示画像を切り替え(通知)
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
// 選択色の切り替え(通知)
//
//  Call
//    note : 通知内容
//
//  Return
//    None
//
-(void)changeColor:(NSNotification *)note
{
    int num;
    int onum;
    PoCoSelColor *scol;                 // 選択色情報
    PoCoEditInfo *editInfo = [(PoCoAppController *)([NSApp delegate]) editInfo];
    NSRect vr = [self visibleRect];

    // 以前の選択色
    scol = [editInfo oldColor];
    if ([scol isColor]) {
        onum = [scol num];
        num = ([scol num] - (vr.origin.y * H_MAX));
        [self setNeedsDisplayInRect:[self numToRect:num
                                           withBias:vr.origin.y]];
    } else {
        onum = -1;
    }

    // 現在の選択色
    scol = [editInfo selColor];
    if ([scol isColor]) {
        // 再描画
        if (onum != [scol num]) {
            num = ([scol num] - (vr.origin.y * H_MAX));
            [self setNeedsDisplayInRect:[self numToRect:num
                                               withBias:vr.origin.y]];
        }

        // 表示位置を選択色にスクロール
        if ([editInfo syncPalette]) {
            num = ([scol num] / H_MAX);
            if ((num < (int)(vr.origin.y)) || (num > ((int)(vr.origin.y) + 1))){
                vr.origin.y = num;
                if (vr.origin.y < 0.0) {
                    vr.origin.y = 0.0;
                } else if (vr.origin.y > 14.0) {
                    vr.origin.y = 14.0;
                }
                if ([self scrollRectToVisible:vr]) {
                    [self setNeedsDisplay:YES];
                }
            }
        }
    }

    return;
}


//
// パレット変更(通知)
//
//  Call
//    note : 通知内容
//
//  Return
//    None
//
-(void)changePalette:(NSNotification *)note
{
    int i;
    const NSRect vr = [self visibleRect];

    if ([note object] == nil) {
        [self setNeedsDisplay:YES];
    } else {
        i = ([[note object] intValue] - (vr.origin.y * H_MAX));
        if ((i >= 0) && (i <= 31)) {
            [self setNeedsDisplayInRect:[self numToRect:i
                                               withBias:vr.origin.y]];
       }
    }

    return;
}


//
// パレット属性変更(通知)
//
//  Call
//    note : 通知内容
//
//  Return
//    None
//
-(void)changePaletteAttr:(NSNotification *)note
{
    int i;
    const NSRect vr = [self visibleRect];

    if ([note object] == nil) {
        [self setNeedsDisplay:YES];
    } else {
        i = ([[note object] intValue] & 0x0000ffff);
        if (i == 0x0000ffff) {
            [self setNeedsDisplay:YES];
        } else {
            i -= (vr.origin.y * H_MAX);
            if ((i >= 0) && (i <= 31)) {
                [self setNeedsDisplayInRect:[self numToRect:i
                                                   withBias:vr.origin.y]];
            }
        }
    }

    return;
}


// ----------------------------------------- instance - public - イベント処理系
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
//    evt      : 発生イベント(api 変数)
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    attrType_ : 属性系の操作対象番号(instance 変数)
//    attrSet_  : 属性系の設定内容(instance 変数)
//
-(void)mouseDown:(NSEvent *)evt
{
    const NSRect vr = [self visibleRect];
    const POS_INF inf = [self pointToNum:[self convertPoint:[evt locationInWindow]
                                                   fromView:nil]
                                withBias:vr.origin.y];
    PoCoEditInfo *editInfo = [(PoCoAppController *)([NSApp delegate]) editInfo];
    PoCoColor *col;

    if ((inf.num >= 0) && (inf.num < 32)) {
        if ((inf.type == PT_ATTR_MASK) ||
            (inf.type == PT_ATTR_DROPPER) ||
            (inf.type == PT_ATTR_TRANS)) {
            // 属性系はドラッグ操作の実装に飛ばす
            self->attrType_ = inf.type;
            col = [[[[self->docCntl_ currentDocument] picture] palette] palette:inf.cnum];
            self->attrSet_ = ((inf.type == PT_ATTR_MASK)    ? [col isMask] :
                              (inf.type == PT_ATTR_DROPPER) ? [col noDropper] :
                                                              [col isTrans]) ? NO : YES;
            [self mouseDragged:evt];
        } else if ([editInfo lockPalette]) {
            // lock されている場合は色選択とする(処理自体はドラッグ操作引き継ぐ)
            [self mouseDragged:evt];
        } else if ([editInfo colorMode] == PoCoColorMode_RGB) {
            // controller を生成
            switch (inf.type) {
                case PT_SAMPLE:
                    [[(PoCoAppController *)([NSApp delegate]) factory]
                        createPaletteIncrementer:YES
                                             num:inf.cnum
                                             red:YES
                                           green:YES
                                            blue:YES
                                            step:16];
                    break;
                case PT_R_ELEMENT_H:
                case PT_R_ELEMENT_L:
                    [[(PoCoAppController *)([NSApp delegate]) factory]
                        createPaletteIncrementer:YES
                                             num:inf.cnum
                                             red:YES
                                           green:NO
                                            blue:NO
                                            step:((inf.type == PT_R_ELEMENT_H) ? 16 : 1)];
                    break;
                case PT_G_ELEMENT_H:
                case PT_G_ELEMENT_L:
                    [[(PoCoAppController *)([NSApp delegate]) factory]
                        createPaletteIncrementer:YES
                                             num:inf.cnum
                                             red:NO
                                           green:YES
                                            blue:NO
                                            step:((inf.type == PT_G_ELEMENT_H) ? 16 : 1)];
                    break;
                case PT_B_ELEMENT_H:
                case PT_B_ELEMENT_L:
                    [[(PoCoAppController *)([NSApp delegate]) factory]
                        createPaletteIncrementer:YES
                                             num:inf.cnum
                                             red:NO
                                           green:NO
                                            blue:YES
                                            step:((inf.type == PT_B_ELEMENT_H) ? 16 : 1)];
                    break;
                default:
                    ;
                    break;
            }
        }
    }

    return;
}


//
// ドラッグ処理
//
//  Call
//    evt       : 発生イベント(api 変数)
//    attrType_ : 属性系の操作対象番号(instance 変数)
//    attrSet_  : 属性系の設定内容(instance 変数)
//    docCntl_  : document controller (instance 変数)
//
//  Return
//    None
//
-(void)mouseDragged:(NSEvent *)evt
{
    const NSRect vr = [self visibleRect];
    const POS_INF inf = [self pointToNum:[self convertPoint:[evt locationInWindow]
                                                   fromView:nil]
                                withBias:vr.origin.y];
    PoCoEditInfo *editInfo = [(PoCoAppController *)([NSApp delegate]) editInfo];

    if ((inf.num >= 0) && (inf.num < 32)) {
        if (self->attrType_ == inf.type) {
            // 補助属性の編集
            [[(PoCoAppController *)([NSApp delegate]) factory]
                createPaletteAttributeSetter:YES
                                         num:inf.cnum
                                     setType:self->attrSet_
                                        mask:(inf.type == PT_ATTR_MASK)
                                     dropper:(inf.type == PT_ATTR_DROPPER)
                                       trans:(inf.type == PT_ATTR_TRANS)];
        } else if ((self->attrType_ == -1) &&
                   ([editInfo lockPalette]) &&
                   ([editInfo colorMode] == PoCoColorMode_RGB)) {
            // RGB モードで lock されている場合は色選択とする
            if (([[editInfo selColor] isPattern]) ||
                ([[editInfo selColor] num] != inf.cnum)) {
                // 色を切り替え
                [editInfo setSelColor:inf.cnum];

                // 切り替えを通知(自身も受け取る)
                [[NSNotificationCenter defaultCenter]
                    postNotificationName:PoCoChangeColor
                                  object:nil];
            }
        }
    }

    return;
}


//
// ボタンリリース処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    attrType_ : 属性系の操作対象番号(instance 変数)
//
-(void)mouseUp:(NSEvent *)evt
{
    // 操作対象を忘れる
    self->attrType_ = -1;

    return;
}


//
// 右ボタンダウンイベント
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    None
//
-(void)rightMouseDown:(NSEvent *)evt
{
    const NSRect vr = [self visibleRect];
    const POS_INF inf = [self pointToNum:[self convertPoint:[evt locationInWindow]
                                                   fromView:nil]
                                withBias:vr.origin.y];
    PoCoEditInfo *editInfo = [(PoCoAppController *)([NSApp delegate]) editInfo];

    if ((!([editInfo lockPalette])) &&
        ([editInfo colorMode] == PoCoColorMode_RGB) &&
        ((inf.num >= 0) && (inf.num < 32))) {
        // controller を生成
        switch (inf.type) {
            case PT_SAMPLE:
                [[(PoCoAppController *)([NSApp delegate]) factory]
                    createPaletteDecrementer:YES
                                         num:inf.cnum
                                         red:YES
                                       green:YES
                                        blue:YES
                                        step:16];
                break;
            case PT_R_ELEMENT_H:
            case PT_R_ELEMENT_L:
                [[(PoCoAppController *)([NSApp delegate]) factory]
                    createPaletteDecrementer:YES
                                         num:inf.cnum
                                         red:YES
                                       green:NO
                                        blue:NO
                                        step:((inf.type == PT_R_ELEMENT_H) ? 16 : 1)];
                break;
            case PT_G_ELEMENT_H:
            case PT_G_ELEMENT_L:
                [[(PoCoAppController *)([NSApp delegate]) factory]
                    createPaletteDecrementer:YES
                                         num:inf.cnum
                                         red:NO
                                       green:YES
                                        blue:NO
                                        step:((inf.type == PT_G_ELEMENT_H) ? 16 : 1)];
                break;
            case PT_B_ELEMENT_H:
            case PT_B_ELEMENT_L:
                [[(PoCoAppController *)([NSApp delegate]) factory]
                    createPaletteDecrementer:YES
                                         num:inf.cnum
                                         red:NO
                                       green:NO
                                        blue:YES
                                        step:((inf.type == PT_B_ELEMENT_H) ? 16 : 1)];
                break;
            default:
                ;
                break;
        }
    }

    return;
}


//
// Wheel 回転
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    None
//
-(void)scrollWheel:(NSEvent *)evt
{
    // 慣性スクロール禁止
    if ([evt phase] != NSEventPhaseNone) {
        [super scrollWheel:evt];
        [self setNeedsDisplay:YES];
    }

    return;
}


// -------------------------------------------- instance - public - IBAction 系
//
// 編集可否
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    lock_        : 編集可否(outlet)
//    lockImage_   : 編集不可(instance 変数)
//    unlockImage_ : 編集可(instance 変数)
//
-(IBAction)lockPalette:(id)sender
{
    PoCoEditInfo *editInfo = [(PoCoAppController *)([NSApp delegate]) editInfo];

    [editInfo setLockPalette:(([editInfo lockPalette]) ? NO : YES)];
    if ([editInfo lockPalette]) {
        [self->lock_ setIntValue:1];
        [self->lock_ setImage:self->lockImage_];
    } else {
        [self->lock_ setIntValue:0];
        [self->lock_ setImage:self->unlockImage_];
    }

    return;
}


//
// 上へ
//  window での keyDown から実行して再描画するとどうにも変になるので
//  window から setNeedsDisplay することにはする(特に 10.14 以降の場合に)
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    None
//
-(IBAction)scrollUp:(id)sender
{
    NSRect r;

    r = [self visibleRect];
    r.origin.y -= 1.0;
    if (r.origin.y < 0.0) {
        r.origin.y = 0.0;
    }
    if ([self scrollRectToVisible:r]) {
        // keyDown の場合は nil で呼ぶ(keyDown の場合は caller から再描画指示)
        if (sender != nil) {
            [self setNeedsDisplay:YES];
        }
    }

    return;
}


//
// 下へ
//  window での keyDown から実行して再描画するとどうにも変になるので
//  window から setNeedsDisplay することにはする(特に 10.14 以降の場合に)
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    None
//
-(IBAction)scrollDown:(id)sender
{
    NSRect r;

    r = [self visibleRect];
    r.origin.y += 1.0;
    if (r.origin.y > 14.0) {
        r.origin.y = 14.0;
    }
    if ([self scrollRectToVisible:r]) {
        // keyDown の場合は nil で呼ぶ(keyDown の場合は caller から再描画指示)
        if (sender != nil) {
            [self setNeedsDisplay:YES];
        }
    }

    return;
}

@end
