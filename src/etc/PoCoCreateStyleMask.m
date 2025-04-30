//
//	Pelistina on Cocoa - PoCo -
//	形状マスク生成
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoCreateStyleMask.h"

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"
#import "PoCoPicture.h"
#import "PoCoMyDocument.h"
#import "PoCoTilePattern.h"

#import "PoCoCalcRotation.h"
#import "PoCoCalcEllipse.h"
#import "PoCoEditInvertPolygon.h"
#import "PoCoEditNormalPaint.h"

// ============================================================================
@implementation PoCoCreateStyleMask

// ------------------------------------------------------------ class - private
//
// bitmap の論理和
//  マスクとしての論理和なので、色番号が 0 か否かのみ
//
//  Call
//    dstRect    : 結果の枠(実座標)(joinRect を内包すること)
//    joinBitmap : 演算対象
//    joinRect   : 演算対象の枠(実座標)
//
//  Return
//    dstBitmap : 結果
//
+(void)orBitmap:(PoCoBitmap *)dstBitmap
        dstRect:(PoCoRect *)dstRect
     joinBitmap:(PoCoBitmap *)joinBitmap
       joinRect:(PoCoRect *)joinRect
{
    const int jw = [joinBitmap width];
    const int jskip = (jw & 0x01);
    const int dw = [dstBitmap width];
    const int drow = (dw + (dw & 0x01));
    const int dskip = (drow - jw);
    int x;
    int y;
    unsigned char *dbmp;
    unsigned char *jbmp;

    dbmp = ([dstBitmap pixelmap] + ((([joinRect top] - [dstRect top]) * drow) + ([joinRect left] - [dstRect left])));
    jbmp = [joinBitmap pixelmap];

    // 垂直
    y = [joinBitmap height];
    do {
        // 水平
        x = jw;
        do {
            // 論理和
            *(dbmp) |= *(jbmp);

            // 次へ
            (x)--;
            (dbmp)++;
            (jbmp)++;
        } while (x != 0);

        // 次へ
        (y)--;
        dbmp += dskip;
        jbmp += jskip;
    } while (y != 0);

    return;
}


//
// bitmap の排他
//  排他する部分の色番号が 0 でなければ結果から排除する
//
//  Call
//    dstRect    : 結果の枠(実座標)(sprtRect を内包すること)
//    sprtBitmap : 演算対象
//    sprtRect   : 演算対象の枠(実座標)
//
//  Return
//    dstBitmap : 結果
//
+(void)excludeBitmap:(PoCoBitmap *)dstBitmap
             dstRect:(PoCoRect *)dstRect
      separateBitmap:(PoCoBitmap *)sprtBitmap
        separateRect:(PoCoRect *)sprtRect
{
    const int sw = [sprtBitmap width];
    const int sskip = (sw & 0x01);
    const int dw = [dstBitmap width];
    const int drow = (dw + (dw & 0x01));
    const int dskip = (drow - sw);
    int x;
    int y;
    unsigned char *dbmp;
    const unsigned char *sbmp;

    dbmp = ([dstBitmap pixelmap] + ((([sprtRect top] - [dstRect top]) * drow) + ([sprtRect left] - [dstRect left])));
    sbmp = [sprtBitmap pixelmap];

    // 垂直
    y = [sprtBitmap height];
    do {
        // 水平
        x = sw;
        do {
            // 排他
            if (*(sbmp) != 0x00) {
                *(dbmp) = 0x00;
            }

            // 次へ
            (x)--;
            (dbmp)++;
            (sbmp)++;
        } while (x != 0);

        // 次へ
        (y)--;
        dbmp += dskip;
        sbmp += sskip;
    } while (y != 0);

    return;
}


//
// 矩形枠を更新
//  排他によって小さくなる(か大きさは変わらない)場合のみを想定
//
//  Call
//    rect   : 矩形枠(実座標)
//    bitmap : 対象マスク画像
//
//  Return
//    rect : 矩形枠(実座標)
//
+(void)resizeRect:(PoCoRect *)rect
       withBitmap:(PoCoBitmap *)bitmap
{
    const int skip = ([bitmap width] & 0x01);
    int l = INT_MAX;
    int t = INT_MAX;
    int r = INT_MIN;
    int b = INT_MIN;
    int x;
    int y;
    int h;
    int w;
    const unsigned char *bmp;

    bmp = [bitmap pixelmap];
    y = [rect top];
    h = [bitmap height];
    do {
        // 水平
        x = [rect left];
        w = [bitmap width];
        do {
            if (*(bmp) != 0x00) {
                l = MIN(x, l);
                t = MIN(y, t);
                r = MAX(x, r);
                b = MAX(y, b);
            }

            // 次へ
            (x)++;
            (w)--;
            (bmp)++;
        } while (w != 0);

        // 次へ
        (y)++;
        (h)--;
        bmp += skip;
    } while (h != 0);

    // 矩形枠を更新する
    [rect   setLeft:l];
    [rect    setTop:t];
    [rect  setRight:(r + 1)];
    [rect setBottom:(b + 1)];

    return;
}


// --------------------------------------------------------- instance - private
//
// 矩形領域の算出(矩形枠用)
//
//  Call
//    startPos : 描画始点
//    endPos   : 描画終点
//    ort      : 方向点
//    diagonal : 対角を使用するか
//
//  Return
//    function : 領域
//
-(PoCoRect *)calcBoxRect:(PoCoPoint *)startPos
                     end:(PoCoPoint *)endPos
             orientation:(PoCoPoint *)ort
              isDiagonal:(BOOL)diagonal
{
    PoCoRect *r;
    PoCoCalcRotationForBox *rot;

    r = [[PoCoRect alloc] initLeft:INT_MAX
                           initTop:INT_MAX
                         initRight:INT_MIN
                        initBottom:INT_MIN];

    // 回転座標を算出
    rot = [[PoCoCalcRotationForBox alloc] initWithStartPos:startPos
                                                withEndPos:endPos
                                               ifAnyOrient:ort];
    [rot calc:diagonal];

    // 左辺
    [r setLeft:MIN([r left], [[rot leftTop] x])];
    [r setLeft:MIN([r left], [[rot rightTop] x])];
    [r setLeft:MIN([r left], [[rot leftBottom] x])];
    [r setLeft:MIN([r left], [[rot rightBottom] x])];

    // 上底
    [r setTop:MIN([r top], [[rot leftTop] y])];
    [r setTop:MIN([r top], [[rot rightTop] y])];
    [r setTop:MIN([r top], [[rot leftBottom] y])];
    [r setTop:MIN([r top], [[rot rightBottom] y])];

    // 右辺
    [r setRight:MAX([r right], [[rot leftTop] x])];
    [r setRight:MAX([r right], [[rot rightTop] x])];
    [r setRight:MAX([r right], [[rot leftBottom] x])];
    [r setRight:MAX([r right], [[rot rightBottom] x])];

    // 下底
    [r setBottom:MAX([r bottom], [[rot leftTop] y])];
    [r setBottom:MAX([r bottom], [[rot rightTop] y])];
    [r setBottom:MAX([r bottom], [[rot leftBottom] y])];
    [r setBottom:MAX([r bottom], [[rot rightBottom] y])];

    [rot release];
    return r;
}


//
// 矩形領域の算出(円/楕円用)
//
//  Call
//    startPos : 描画始点(中点)
//    endPos   : 描画終点(中点)
//    ort      : 方向点
//
//  Return
//    function : 領域
//
-(PoCoRect *)calcEllipseRect:(PoCoPoint *)startPos
                         end:(PoCoPoint *)endPos
                 orientation:(PoCoPoint *)ort
{
    PoCoRect *r;
    int i;
    PoCoCalcRotationForEllipse *rot;
    int x;
    int y;
    int h;
    int v;
    int d;

    r = [[PoCoRect alloc] init];

    // 水平軸の算出
    i = ([startPos x] < [endPos x]) ? ([endPos x] - [startPos x]) :
                                      ([startPos x] - [endPos x]);
    [r setLeft:([startPos x] - i)];
    [r setRight:([startPos x] + i + 1)];
     
    // 垂直軸の算出  
    i = ([startPos y] < [endPos y]) ? ([endPos y] - [startPos y]) :
                                      ([startPos y] - [endPos y]);
    [r setTop:([startPos y] - i)];
    [r setBottom:([startPos y] + i + 1)];

    // 方向点による回転を反映
    rot = [[PoCoCalcRotationForEllipse alloc] initWithCenterPos:startPos
                                                     withEndPos:endPos
                                                    ifAnyOrient:ort];
    if ([rot isExec]) {  
        h = ([r width] / 2);
        v = ([r height] / 2);
        [r setLeft:INT_MAX];
        [r setTop:INT_MAX];
        [r setRight:INT_MIN];
        [r setBottom:INT_MIN];
        for (d = 0; d < 3600; (d)++) {
            x = ([startPos x] + [rot calcXAxis:d
                                    horiLength:h
                                    vertLength:v]);
            y = ([startPos y] + [rot calcYAxis:d
                                    horiLength:h
                                    vertLength:v]);
            if (x < [r left]) {
                [r setLeft:x];
            } else if (x > [r right]) {
                [r setRight:x];
            }
            if (y < [r top]) {
                [r setTop:y];         
            } else if (y > [r bottom]) {
                [r setBottom:y];
            }
        }
    }
    [rot release];

    return r;
}


//
// 矩形領域の算出(平行四辺形用)
//
//  Call
//    firstPos  : 1点
//    secondPos : 2点
//    thirdPos  : 3点
//    fourthPos : 4点
//
//  Return
//    function : 領域
//
-(PoCoRect *)calcParallelogramRect:(PoCoPoint* )firstPos
                            second:(PoCoPoint *)secondPos
                             third:(PoCoPoint *)thirdPos
                            fourth:(PoCoPoint *)fourthPos
{
    PoCoRect *r;

    r = [[PoCoRect alloc] initLeft:[firstPos x]
                           initTop:[firstPos y]
                         initRight:[firstPos x]
                        initBottom:[firstPos y]];

    // 左辺
    if ([secondPos x] < [r left]) { [r setLeft:[secondPos x]]; }
    if ([thirdPos  x] < [r left]) { [r setLeft:[thirdPos  x]]; }
    if ([fourthPos x] < [r left]) { [r setLeft:[fourthPos x]]; }

    // 上底
    if ([secondPos y] < [r top]) { [r setTop:[secondPos y]]; }
    if ([thirdPos  y] < [r top]) { [r setTop:[thirdPos  y]]; }
    if ([fourthPos y] < [r top]) { [r setTop:[fourthPos y]]; }

    // 右辺
    if ([r right] < [secondPos x]) { [r setRight:[secondPos x]]; }
    if ([r right] < [thirdPos  x]) { [r setRight:[thirdPos  x]]; }
    if ([r right] < [fourthPos x]) { [r setRight:[fourthPos x]]; }

    // 下底
    if ([r bottom] < [secondPos y]) { [r setBottom:[secondPos y]]; }
    if ([r bottom] < [thirdPos  y]) { [r setBottom:[thirdPos  y]]; }
    if ([r bottom] < [fourthPos y]) { [r setBottom:[fourthPos y]]; }

    return r;
}


//
// 矩形領域の算出(直線群用)
//
//  Call
//    points : 支点群
//
//  Return
//    function : 領域
//
-(PoCoRect *)calcPolygonRect:(NSMutableArray *)points
{
    PoCoRect *r;
    NSEnumerator *iter;
    PoCoPoint *p;

    r = [[PoCoRect alloc] initLeft:INT_MAX
                           initTop:INT_MAX
                         initRight:INT_MIN
                        initBottom:INT_MIN];
    iter = [points objectEnumerator];
    for (p = [iter nextObject]; p != nil; p = [iter nextObject]) {
        [r   setLeft:MIN([p x], [r   left])];
        [r    setTop:MIN([p y], [r    top])];
        [r  setRight:MAX([p x], [r  right])];
        [r setBottom:MAX([p y], [r bottom])];
    }

    return r;
}


//
// 塗り(seed paint)を実行
//
//  Call
//    p       : 対象点(seed)
//    bmp     : 対象画像
//    bmpRect : 対象画像の枠(実座標)
//    border  : 境界線指定か
//              YES : 境界線による塗り選択
//              NO  : 指定座標の色による塗り選択
//    range   : 色範囲
//
//  Return
//    edit : 編集系の実体
//
-(void)executePaint:(PoCoEditNormalPaint **)edit
         targetPont:(PoCoPoint *)p
         withBitmap:(PoCoBitmap *)bmp
         bitmapRect:(PoCoRect *)bmpRect
           isBorder:(BOOL)border
         colorRange:(int)range
{
    PoCoPoint *tp;
    PoCoBitmap *tbmp;
    PoCoColorPattern *pat;

    tp = nil;
    tbmp = nil;
    pat = nil;

    // 対象画像を複製
    tbmp = [bmp copy];
    if (tbmp == nil) {
        DPRINT((@"can't copy bitmap.\n"));
        goto EXIT;
    }

    // 正規化した座標を生成
    tp = [[PoCoPoint alloc] initX:([p x] - [bmpRect left])
                            initY:([p y] - [bmpRect top])];
    if (tp == nil) {
        DPRINT((@"can't create normalized point.\n"));
        goto EXIT;
    }

    // 色を取得してカラーパターンを生成
    pat = [[PoCoColorPattern alloc] initWidth:1
                                   initHeight:1
                                 defaultColor:[tbmp pixelmap][([tp y] * ([tbmp width] + ([tbmp width] & 0x01))) + [tp x]]];

    // 塗りを実行
    if (border) {
        // 境界色を指定
        *(edit) = [[PoCoEditNormalBorderPaint alloc] 
                      initWithPattern:tbmp
                              palette:[[[[NSDocumentController sharedDocumentController] currentDocument] picture] palette]
                                 tile:[[(PoCoAppController *)([NSApp delegate]) tileSteadyPattern] pattern:7]
                              pattern:pat
                               border:[[(PoCoAppController *)([NSApp delegate]) editInfo] selColor]];
    } else {
        // 指定座標と同一色
        *(edit) = [[PoCoEditNormalPaint alloc] 
                      initWithPattern:tbmp
                              palette:[[[[NSDocumentController sharedDocumentController] currentDocument] picture] palette]
                                 tile:[[(PoCoAppController *)([NSApp delegate]) tileSteadyPattern] pattern:7]
                              pattern:pat
                                range:range];
    }
    [*(edit) executeDraw:tp];

EXIT:
    [pat release];
    [tbmp release];
    [tp release];
    return;
}


//
// 描画済みのマスクを形状マスクに結合
//
//  Call
//    drawnBitmap : 描画済みマスク
//    drawnRect   : 描画済みの枠(実座標)
//    styleRect   : 形状マスクの枠(実座標)
//    styleBitmap : 形状マスク(instance 変数)
//
//  Return
//    resultRect : 結合後の枠(実座標)
//    styleMask_ : 形状マスク(instance 変数)
//
-(void)joinMaskBitmap:(PoCoBitmap *)drawnBitmap
             maskRect:(PoCoRect *)drawnRect
          styleBitmap:(PoCoBitmap *)styleBitmap
            styleRect:(PoCoRect *)styleRect
           resultRect:(PoCoRect *)resultRect
{
    PoCoBitmap *dstBitmap;

    // 塗ったあとの矩形枠取得
    if ((styleRect != nil) && (styleBitmap != nil)) {
        [resultRect   setLeft:MIN([styleRect   left], [drawnRect   left])];
        [resultRect    setTop:MIN([styleRect    top], [drawnRect    top])];
        [resultRect  setRight:MAX([styleRect  right], [drawnRect  right])];
        [resultRect setBottom:MAX([styleRect bottom], [drawnRect bottom])];
    } else {
        [resultRect   setLeft:[drawnRect   left]];
        [resultRect    setTop:[drawnRect    top]];
        [resultRect  setRight:[drawnRect  right]];
        [resultRect setBottom:[drawnRect bottom]];
    }

    // 結果の bitmap を生成
    dstBitmap = [[PoCoBitmap alloc] initWidth:[resultRect width] + 1
                                   initHeight:[resultRect height] + 1
                                 defaultColor:0];
    if (dstBitmap == nil) {
        DPRINT((@"can't create joinMaskBitmap.\n"));
        goto EXIT;
    }

    // 形状マスクを結果に反映
    if ((styleRect != nil) && (styleBitmap != nil)) {
        [PoCoCreateStyleMask orBitmap:dstBitmap
                              dstRect:resultRect
                           joinBitmap:styleBitmap
                             joinRect:styleRect];
    }

    // 塗りで得られたマスクを結果に反映
    [PoCoCreateStyleMask orBitmap:dstBitmap
                          dstRect:resultRect
                       joinBitmap:drawnBitmap
                         joinRect:drawnRect];

    // 入れ替え
    [self->styleMask_ release];
    self->styleMask_ = dstBitmap;

EXIT:
    return;
}


//
// 描画済みのマスクを形状マスクから排除
//
//  Call
//    drawnBitmap : 描画済みマスク
//    drawnRect   : 描画済みの枠(実座標)
//    styleRect   : 形状マスクの枠(実座標)
//    styleBitmap : 形状マスク(instance 変数)
//
//  Return
//    resultRect : 結合後の枠(実座標)
//    styleMask_ : 形状マスク(instance 変数)
//
-(void)separateMaskBitmap:(PoCoBitmap *)drawnBitmap
                 maskRect:(PoCoRect *)drawnRect
              styleBitmap:(PoCoBitmap *)styleBitmap
                styleRect:(PoCoRect *)styleRect
               resultRect:(PoCoRect *)resultRect
{
    PoCoBitmap *dstBitmap;
    PoCoRect *r;

    // 現状の形状マスクを複写
    dstBitmap = [styleBitmap copy];
    if (dstBitmap == nil) {
        DPRINT((@"can't create excludeMaskBitmap.\n"));
        goto EXIT;
    }
    [resultRect   setLeft:[styleRect   left]];
    [resultRect    setTop:[styleRect    top]];
    [resultRect  setRight:[styleRect  right]];
    [resultRect setBottom:[styleRect bottom]];

    // 塗りで得られたマスクを結果に反映
    [PoCoCreateStyleMask excludeBitmap:dstBitmap
                               dstRect:resultRect
                        separateBitmap:drawnBitmap
                          separateRect:drawnRect];

    // 矩形枠を更新
    [PoCoCreateStyleMask resizeRect:resultRect
                         withBitmap:dstBitmap];

    // 矩形枠に沿った形状マスクに入れ替え
    [self->styleMask_ release];
    r = [[PoCoRect alloc] initLeft: ([resultRect   left] - [styleRect left])
                           initTop: ([resultRect    top] - [styleRect  top])
                         initRight:(([resultRect  right] - [styleRect left]) + 1)
                        initBottom:(([resultRect bottom] - [styleRect  top]) + 1)];
    self->styleMask_ = [dstBitmap getBitmap:r];
    [r release];
    [dstBitmap release];

EXIT:
    return;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function   : 実体
//    styleMask_ : 形状マスク(instance 変数)
//
-(id)init
{
//    DPRINT((@"[PoCoCreateStyleMask init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->styleMask_ = nil;
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
//    styleMask_ : 形状マスク(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoCreateStyleMask dealloc]\n"));

    // 資源の解放
    [self->styleMask_ release];
    self->styleMask_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 取得
//
//  Call
//    styleMask_ : 形状マスク(instance 変数)
//
//  Return
//    function : 形状マスク
//
-(PoCoBitmap *)mask
{
    return self->styleMask_;
}


// --------------------------------------------------- instance - public - 生成
//
// 矩形枠
//
//  Call
//    startPos : 描画始点(左上)
//    endPos   : 描画終点(右下)
//    ort      : 方向点
//    diagonal : 対角を使用するか
//
//  Return
//    function   : YES : 成功
//                 NO  : 失敗
//    styleMask_ : 形状マスク(instance 変数)
//
-(BOOL)box:(PoCoPoint *)startPos
       end:(PoCoPoint *)endPos
orientation:(PoCoPoint *)ort
isDiagonal:(BOOL)diagonal
{
    BOOL  result;
    PoCoEditInvertPolygon *fill;
    PoCoRect *r;
    NSMutableArray *poly;
    PoCoPoint *t;  
    PoCoCalcRotationForBox *rot;

    result = NO;
    fill = nil;
    r = nil;
    poly = nil;
    rot = nil;

    // 片方だけでは描画しない
    if ((startPos == nil) || (endPos == nil)) {
        goto EXIT;
    }

    // 以前の分は残さない
    [self->styleMask_ release];
    self->styleMask_ = nil;

    // 外接長方形を生成
    r = [self calcBoxRect:startPos
                      end:endPos
              orientation:ort
               isDiagonal:diagonal];

    // 回転座標を算出
    rot = [[PoCoCalcRotationForBox alloc] initWithStartPos:startPos
                                                withEndPos:endPos
                                               ifAnyOrient:ort];
    [rot calc:diagonal];

    // 座標を正規化して登録
    poly = [[NSMutableArray alloc] init];
    t = [[PoCoPoint alloc] initX:([[rot leftTop] x] - [r left])
                           initY:([[rot leftTop] y] - [r top])];
    [poly addObject:t];
    [t release];
    t = [[PoCoPoint alloc] initX:([[rot leftBottom] x] - [r left])
                           initY:([[rot leftBottom] y] - [r top])];
    [poly addObject:t];
    [t release];
    t = [[PoCoPoint alloc] initX:([[rot rightBottom] x] - [r left])
                           initY:([[rot rightBottom] y] - [r top])];
    [poly addObject:t];
    [t release];
    t = [[PoCoPoint alloc] initX:([[rot rightTop] x] - [r left])
                           initY:([[rot rightTop] y] - [r top])];
    [poly addObject:t];
    [t release];
    [rot release];

    // マスクを生成(half-open property のため、+1)
    self->styleMask_ = [[PoCoBitmap alloc] initWidth:([r width] + 1)
                                          initHeight:([r height] + 1)
                                        defaultColor:0];
    if (self->styleMask_ == nil) {
        DPRINT((@"can't create StyleMask.\n"));
        goto EXIT;
    }

    // 塗りつぶし
    fill = [[PoCoEditInvertPolygon alloc] initWithBitmap:self->styleMask_
                                              withPoints:poly
                                            withDrawRect:r
                                              isZeroOnly:YES];
    if (fill == nil) {
        DPRINT((@"can't create FillEditter.\n"));
        goto EXIT;
    }
    [fill executeDraw];

    // 正常終了
    result = YES;

EXIT:
    [fill release];
    [r release];
    [poly removeAllObjects];
    [poly release];
    return result;
}


//
// 円/楕円
//
//  Call
//    startPos : 描画始点(中点)
//    endPos   : 描画終点(中点)
//    ort      : 方向点
//
//  Return
//    function   : YES : 成功
//                 NO  : 失敗
//    styleMask_ : 形状マスク(instance 変数)
//
-(BOOL)ellipse:(PoCoPoint *)startPos
           end:(PoCoPoint *)endPos
   orientation:(PoCoPoint *)ort
{
    BOOL result;
    PoCoEditInvertPolygon *fill;
    PoCoRect *r;
    NSMutableArray *poly;
    PoCoPoint *t;
    PoCoCalcEllipse *calc;
    PoCoPoint *p;

    result = NO;
    fill = nil;
    r = nil;
    poly = nil;

    // 片方だけでは描画しない
    if ((startPos == nil) || (endPos == nil)) {
        goto EXIT;
    }

    // 以前の分は残さない
    [self->styleMask_ release];
    self->styleMask_ = nil;

    // 外接長方形を生成
    r = [self calcEllipseRect:startPos
                          end:endPos
                  orientation:ort];

    // 楕円枠を生成、座標を正規化して登録
    poly = [[NSMutableArray alloc] init];
    calc = [[PoCoCalcEllipse alloc] init];
    [calc calc:startPos
        endPos:endPos
   orientation:ort];
    for (p = [calc points]; p != nil; p = [calc points]) {
        t = [[PoCoPoint alloc] initX:([p x] - [r left])
                               initY:([p y] - [r top])];
        [poly addObject:t];
        [t release];
    }
    [calc release];

    // マスクを生成(half-open property のため、+1)
    self->styleMask_ = [[PoCoBitmap alloc] initWidth:([r width] + 1)
                                          initHeight:([r height] + 1)
                                        defaultColor:0];
    if (self->styleMask_ == nil) {
        DPRINT((@"can't create StyleMask.\n"));
        goto EXIT;
    }

    // 塗りつぶし               
    fill = [[PoCoEditInvertPolygon alloc] initWithBitmap:self->styleMask_
                                              withPoints:poly
                                            withDrawRect:r
                                              isZeroOnly:YES];
    if (fill == nil) {
        DPRINT((@"can't create FillEditter.\n"));
        goto EXIT;
    }
    [fill executeDraw];

    // 正常終了
    result = YES;

EXIT:
    [fill release];
    [r release];
    [poly removeAllObjects];
    [poly release];
    return result;
}


//
// 平行四辺形
//
//  Call
//    firstPos  : 1点
//    secondPos : 2点
//    thirdPos  : 3点
//    fourthPos : 4点
//
//  Return
//    function   : YES : 成功
//                 NO  : 失敗
//    styleMask_ : 形状マスク(instance 変数)
//
-(BOOL)parallelogram:(PoCoPoint* )firstPos
              second:(PoCoPoint *)secondPos
               third:(PoCoPoint *)thirdPos
              fourth:(PoCoPoint *)fourthPos
{
    BOOL result;
    PoCoEditInvertPolygon *fill;
    PoCoRect *r;
    NSMutableArray *poly;
    PoCoPoint *t;

    result = NO;
    fill = nil;
    r = nil;
    poly = nil;

    // 足りていなければ描画しない
    if ((firstPos == nil) ||
        (secondPos == nil) ||
        (thirdPos == nil) ||
        (fourthPos == nil)) {
        goto EXIT;
    }

    // 以前の分は残さない
    [self->styleMask_ release];
    self->styleMask_ = nil;

    // 外接長方形を生成
    r = [self calcParallelogramRect:firstPos
                             second:secondPos
                              third:thirdPos
                             fourth:fourthPos];

    // 座標を正規化して登録
    poly = [[NSMutableArray alloc] init];
    t = [[PoCoPoint alloc] initX:([firstPos x] - [r left])
                           initY:([firstPos y] - [r top])];
    [poly addObject:t];
    [t release];
    t = [[PoCoPoint alloc] initX:([secondPos x] - [r left])
                           initY:([secondPos y] - [r top])];
    [poly addObject:t];
    [t release];
    t = [[PoCoPoint alloc] initX:([thirdPos x] - [r left])
                           initY:([thirdPos y] - [r top])];
    [poly addObject:t];
    [t release];
    t = [[PoCoPoint alloc] initX:([fourthPos x] - [r left])
                           initY:([fourthPos y] - [r top])];
    [poly addObject:t];
    [t release];

    // マスクを生成(half-open property のため、+1)
    self->styleMask_ = [[PoCoBitmap alloc] initWidth:([r width] + 1)
                                          initHeight:([r height] + 1)
                                        defaultColor:0];
    if (self->styleMask_ == nil) {
        DPRINT((@"can't create StyleMask.\n"));
        goto EXIT;
    }
 
    // 塗りつぶし
    fill = [[PoCoEditInvertPolygon alloc] initWithBitmap:self->styleMask_
                                              withPoints:poly
                                            withDrawRect:r
                                              isZeroOnly:YES];
    if (fill == nil) {
        DPRINT((@"can't create FillEditter.\n"));
        goto EXIT;
    }
    [fill executeDraw];

    // 正常終了
    result = YES;

EXIT:
    [fill release];
    [r release];
    [poly removeAllObjects];
    [poly release];
    return result;
}


//
// 直線群(閉路)
//
//  Call
//    points : 支点群
//
//  Return
//    function   : YES : 成功
//                 NO  : 失敗
//    styleMask_ : 形状マスク(instance 変数)
//
-(BOOL)polygon:(NSMutableArray *)points
{
    BOOL  result;
    PoCoEditInvertPolygon *fill;
    PoCoRect *r;
    NSMutableArray *poly;
    NSEnumerator *iter;
    PoCoPoint *p;
    PoCoPoint *t;

    result = NO;
    fill = nil;
    r = nil;
    poly = nil;

    // 以前の分は残さない
    [self->styleMask_ release];
    self->styleMask_ = nil;

    // 外接長方形を生成
    r = [self calcPolygonRect:points];

    // 座標を正規化して登録
    poly = [[NSMutableArray alloc] init];
    iter = [points objectEnumerator];
    for (p = [iter nextObject]; p != nil; p = [iter nextObject]) {
        t = [[PoCoPoint alloc] initX:([p x] - [r left])
                               initY:([p y] - [r top])];
        [poly addObject:t];
        [t release];
    }
    p = [[points objectEnumerator] nextObject];
    t = [[PoCoPoint alloc] initX:([p x] - [r left])
                           initY:([p y] - [r top])];
    [poly addObject:t];
    [t release];

    // マスクを生成(half-open property のため、+1)
    self->styleMask_ = [[PoCoBitmap alloc] initWidth:([r width] + 1)
                                          initHeight:([r height] + 1)
                                        defaultColor:0];
    if (self->styleMask_ == nil) {
        DPRINT((@"can't create StyleMask.\n"));
        goto EXIT;
    }
 
    // 塗りつぶし
    fill = [[PoCoEditInvertPolygon alloc] initWithBitmap:self->styleMask_
                                              withPoints:poly
                                            withDrawRect:r
                                              isZeroOnly:YES];
    if (fill == nil) {
        DPRINT((@"can't create FillEditter.\n"));
        goto EXIT;
    }
    [fill executeDraw];

    // 正常終了
    result = YES;

EXIT:
    [fill release];
    [r release];
    [poly removeAllObjects];
    [poly release];
    return result;
}


//
// 塗り(seed paint)
//
//  Call
//    p           : 対象点(seed)
//    imageBitmap : 対象画像
//    imageRect   : 対象画像の枠(実座標)
//    border      : 境界線指定か
//                  YES : 境界線による塗り選択
//                  NO  : 指定座標の色による塗り選択
//    range       : 色範囲
//
//  Return
//    function   : YES : 成功
//                 NO  : 失敗
//    resultRect : 選択範囲
//    styleMask_ : 形状マスク(instance 変数)
//
-(BOOL)paint:(PoCoPoint *)p
 imageBitmap:(PoCoBitmap *)imageBitmap
   imageRect:(PoCoRect *)imageRect
    isBorder:(BOOL)border
  colorRange:(int)range
  resultRect:(PoCoRect *)resultRect
{
    return [self paintJoin:p
               imageBitmap:imageBitmap
                 imageRect:imageRect
               styleBitmap:nil
                 styleRect:nil
                  isBorder:border
                colorRange:range
                resultRect:resultRect];
}


//
// 塗り(seed paint)の結合
//
//  Call
//    p           : 対象点(seed)
//    imageBitmap : 対象画像
//    imageRect   : 対象画像の枠(実座標)
//    styleBitmap : 形状マスクの枠(実座標)
//    styleRect   : 形状マスクの枠(実座標)
//    border      : 境界線指定か
//                  YES : 境界線による塗り選択
//                  NO  : 指定座標の色による塗り選択
//    range       : 色範囲
//
//  Return
//    function   : YES : 成功
//                 NO  : 失敗
//    resultRect : 選択範囲
//    styleMask_ : 形状マスク(instance 変数)
//
-(BOOL)paintJoin:(PoCoPoint *)p
     imageBitmap:(PoCoBitmap *)imageBitmap
       imageRect:(PoCoRect *)imageRect
     styleBitmap:(PoCoBitmap *)styleBitmap
       styleRect:(PoCoRect *)styleRect
        isBorder:(BOOL)border
      colorRange:(int)range
      resultRect:(PoCoRect *)resultRect
{
    BOOL  result;
    PoCoEditNormalPaint *edit;
    PoCoBitmap *mbmp;
    PoCoRect *mr;

    result = NO;
    edit = nil;
    mbmp = nil;
    mr = nil;

    // 塗りを実行
    [self executePaint:&(edit)
            targetPont:p
            withBitmap:imageBitmap
            bitmapRect:imageRect
              isBorder:border
            colorRange:range];
    if (edit == nil) {
        DPRINT((@"can't create seedPaint mask.\n"));
        goto EXIT;
    }

    // 塗ったあと(描画済みのマスク)を形状マスクに結合
    mr = [[PoCoRect alloc] initLeft:[[edit drect]   left]
                            initTop:[[edit drect]    top]
                          initRight:[[edit drect]  right]
                         initBottom:[[edit drect] bottom]];
    mbmp = [[edit mask] getBitmap:mr];
    if (mbmp == nil) {
        DPRINT((@"can't join styleMask with seedPaint.\n"));
        goto EXIT;
    }
    [self joinMaskBitmap:mbmp
                maskRect:mr
             styleBitmap:styleBitmap
               styleRect:styleRect
              resultRect:resultRect];

    // 正常終了
    result = YES;

EXIT:
    [mr release];
    [mbmp release];
    [edit release];
    return result;
}


//
// 塗り(seed paint)の分離
//
//  Call
//    p           : 対象点(seed)
//    imageBitmap : 対象画像
//    imageRect   : 対象画像の枠(実座標)
//    styleBitmap : 形状マスクの枠(実座標)
//    styleRect   : 形状マスクの枠(実座標)
//    border      : 境界線指定か
//                  YES : 境界線による塗り選択
//                  NO  : 指定座標の色による塗り選択
//    range       : 色範囲
//
//  Return
//    function   : YES : 成功
//                 NO  : 失敗
//    resultRect : 選択範囲
//    styleMask_ : 形状マスク(instance 変数)
//
-(BOOL)paintSeparate:(PoCoPoint *)p
         imageBitmap:(PoCoBitmap *)imageBitmap
           imageRect:(PoCoRect *)imageRect
         styleBitmap:(PoCoBitmap *)styleBitmap
           styleRect:(PoCoRect *)styleRect
            isBorder:(BOOL)border
          colorRange:(int)range
          resultRect:(PoCoRect *)resultRect
{
    BOOL  result;
    PoCoEditNormalPaint *edit;
    PoCoBitmap *mbmp;
    PoCoRect *mr;

    result = NO;
    edit = nil;
    mbmp = nil;
    mr = nil;

    // 塗りを実行
    [self executePaint:&(edit)
            targetPont:p
            withBitmap:imageBitmap
            bitmapRect:imageRect
              isBorder:border
            colorRange:range];
    if (edit == nil) {
        DPRINT((@"can't create seedPaint mask.\n"));
        goto EXIT;
    }

    // 塗ったあと(描画済みのマスク)を形状マスクから排除
    mr = [[PoCoRect alloc] initLeft:[[edit drect]   left]
                            initTop:[[edit drect]    top]
                          initRight:[[edit drect]  right]
                         initBottom:[[edit drect] bottom]];
    mbmp = [[edit mask] getBitmap:mr];
    if (mbmp == nil) {
        DPRINT((@"can't separate styleMask with seedPaint.\n"));
        goto EXIT;
    }
    [self separateMaskBitmap:mbmp
                    maskRect:mr
                 styleBitmap:styleBitmap
                   styleRect:styleRect
                  resultRect:resultRect];

    // 正常終了
    result = YES;

EXIT:
    [mr release];
    [mbmp release];
    [edit release];
    return result;
}

@end
