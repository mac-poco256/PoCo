//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 均一濃度 - 直線基底
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditUniformedDensityDrawLineBase.h"

#import "PoCoColorMixer.h"

// ============================================================================
@implementation PoCoEditUniformedDensityDrawLineBase

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp   : 編集対象
//    cmode : 色演算モード
//    plt   : 使用パレット
//    pat   : 使用カラーパターン
//    buf   : 色保持情報
//
//  Return
//    function     : 実体
//    bitmap_      : 編集対象(instance 変数)
//    colMode_     : 色演算モード(instance 変数)
//    palette_     : 使用パレット(instance 変数)
//    pattern_     : 使用カラーパターン(instance 変数)
//    points_      : 描画する点(instance 変数)
//    density_     : 濃度(0.1%単位)(instance 変数)
//    drawRect_    : 描画範囲(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(id)init:(PoCoBitmap *)bmp
  colMode:(PoCoColorMode)cmode
  palette:(PoCoPalette *)plt
  pattern:(PoCoColorPattern *)pat
   buffer:(PoCoColorBuffer *)buf
{
    DPRINT((@"[PoCoEditUniformedDensityDrawLineBase init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->bitmap_ = bmp;
        self->colMode_ = cmode;
        self->palette_ = plt;
        self->pattern_ = pat;
        self->density_ = 0;
        self->colorBuffer_ = buf;

        // それぞれ retain しておく
        [self->bitmap_ retain];
        [self->palette_ retain];
        [self->pattern_ retain];
        [self->colorBuffer_ retain];

        // 資源の確保
        self->points_ = [[NSMutableArray alloc] init];
        self->drawRect_ = [[PoCoRect alloc] initLeft:[self->bitmap_ width]
                                             initTop:[self->bitmap_ height]
                                           initRight:0
                                          initBottom:0];  
        if ((self->points_ == nil) || (self->drawRect_ == nil)) {
            // 失敗
            DPRINT((@"memory allocation error.\n"));
            [self release];
        }
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
//    bitmap_      : 編集対象(instance 変数)
//    palette_     : 使用パレット(instance 変数)
//    pattern_     : 使用カラーパターン(instance 変数)
//    points_      : 描画する点(instance 変数)
//    drawRect_    : 描画範囲(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoEditUniformedDensityDrawLineBase dealloc]\n"));

    // 資源の解放
    [self->points_ removeAllObjects];
    [self->bitmap_ release];
    [self->palette_ release];
    [self->pattern_ release];
    [self->points_ release];
    [self->drawRect_ release];
    [self->colorBuffer_ release];
    self->bitmap_ = nil;
    self->palette_ = nil;
    self->pattern_ = nil;
    self->points_ = nil;
    self->drawRect_ = nil;
    self->colorBuffer_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 点を登録
//
//  Call
//    p       : 登録する点
//    bitmap_ : 編集対象(instance 変数)
//
//  Return
//    points_   : 描画する点(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//
-(void)addPoint:(PoCoPoint *)p
{
    const int sz = [self pointSize];
    PoCoPoint *tmp;

    tmp = [[PoCoPoint alloc] initX:[p x] initY:[p y]];
    [self->points_ addObject:tmp];
    [tmp release];

    // 描画領域を更新(+1 は half-open property のため)
    if (([p x] - sz) < [self->drawRect_ left]) {
        [self->drawRect_ setLeft:MAX(([p x] - sz), 0)];
    }
    if (([p y] - sz) < [self->drawRect_ top]) {
        [self->drawRect_ setTop:MAX(([p y] - sz), 0)];
    }
    if (([p x] + sz + 1) > [self->drawRect_ right]) {
        [self->drawRect_ setRight:MIN(([p x] + sz + 1), [self->bitmap_ width])];
    }
    if (([p y] + sz + 1) > [self->drawRect_ bottom]) {  
        [self->drawRect_ setBottom:MIN(([p y] + sz + 1), [self->bitmap_ height])];
    }

    return;
}


//
// 点を解放
//
//  Call
//    bitmap_ : 編集対象(instance 変数)
//
//  Return
//    points_   : 描画する点(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//
-(void)clearPoint
{
    [self->points_ removeAllObjects];

    // 描画範囲を初期化する
    [self->drawRect_ setLeft:[self->bitmap_ width]];
    [self->drawRect_ setTop:[self->bitmap_ height]];
    [self->drawRect_ setRight:0];
    [self->drawRect_ setBottom:0];

    return;
}


//
// 濃度を登録
//
//  Call
//    dnum : 濃度(0.1%単位)
//
//  Return
//    density_ : 濃度(0.1%単位)(instance 変数)
//
-(void)setDensity:(int)dnum
{
    self->density_ = dnum;

    return;
}


//
// 実行
//  ここでは座標演算が目的
//  描画そのものは具象 class の drawPoint: で実装する
//
//  Call
//    bitmap_   : 編集対象(instance 変数)
//    pattern_  : 使用カラーパターン(instance 変数)
//    points_   : 描画する点(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//
//  Return
//    None
//
-(void)executeDraw
{
    NSEnumerator *iter;                 // points_ の反復子
    PoCoPoint *p1;                      // 始点
    PoCoPoint *p2;                      // 終点
    PoCoPoint *dp;                      // 描画点(中心)
    int i;                              // 座標遷移(水平ないし垂直)
    int e;                              // 誤差
    int dx;                             // 水平差分
    int dy;                             // 垂直差分
    int sx;                             // 水平変量(常に±1のみ)
    int sy;                             // 垂直変量(常に±1のみ)
    int ax;                             // 水平傾斜
    int ay;                             // 垂直傾斜
    int brow;                           // 描画対象の rowbyets
    unsigned char *bbmp;                // 描画対象の走査用
    PoCoBitmap *patBitmap;              // カラーパターン(描画範囲に調整済み)
    int prow;                           // カラーパターンの rowbytes
    unsigned char *pbmp;                // カラーパターンの走査用

    patBitmap = nil;

    // 描画領域なし
    if([self->drawRect_ empty]){
        goto EXIT;
    }

    // 描画開始
    patBitmap = [self->pattern_ pixelmap:self->drawRect_];

    // 各種値の算出
    brow = [self->bitmap_ width] + ([self->bitmap_ width] & 1);
    prow = [patBitmap width] + ([patBitmap width] & 1);

    // 点の反復処理
    iter = [self->points_ objectEnumerator];
    p1 = [iter nextObject];
    for (p2 = [iter nextObject]; p2 != nil; p2 = [iter nextObject]) {
        dp = p1;

        // 変位算出
        dx = abs([p2 x] - [dp x]);
        dy = abs([p2 y] - [dp y]);
        sx = (([p2 x] < [dp x]) ? -1 : 1);
        sy = (([p2 y] < [dp y]) ? -1 : 1);
        ax = (dx << 1);
        ay = (dy << 1);

        // 描画中心に合わせた pointer 算出
        bbmp = [self->bitmap_ pixelmap] + ([dp y] * brow) + [dp x];
        pbmp = [patBitmap pixelmap] + (([dp y] - [self->drawRect_ top]) * prow)
                                    + ([dp x] - [self->drawRect_ left]);

        // 点の移動
        if ((dx == 0) && (dy == 0)) {
            // 同一点
            [self drawPoint:dp bitmap:bbmp  bitmapRow:brow
                              pattern:pbmp patternRow:prow];
        } else if (dx == 0) {
            // 垂直線
            for ( ; !([dp isEqualPos:p2]); [dp moveY:sy]) {
                [self drawPoint:dp bitmap:bbmp  bitmapRow:brow
                                  pattern:pbmp patternRow:prow];
                bbmp += (sy * brow);
                pbmp += (sy * prow);
            }
        } else if (dy == 0) {
            // 水平線
            for ( ; !([dp isEqualPos:p2]); [dp moveX:sx]) {
                [self drawPoint:dp bitmap:bbmp  bitmapRow:brow
                                  pattern:pbmp patternRow:prow];
                bbmp += sx;
                pbmp += sx;
            }  
        } else if (dx < dy) {  
            // 任意方向(垂直変量の方が大きい)
            e = -(dy);
            for (i = 0; i < dy; (i)++) {
                [self drawPoint:dp bitmap:bbmp  bitmapRow:brow
                                  pattern:pbmp patternRow:prow];

                // 点の移動
                e += ax;
                [dp moveY:sy];
                bbmp += (sy * brow);
                pbmp += (sy * prow);
                if (e >= 0) {
                    [dp moveX:sx];
                    bbmp += sx;
                    pbmp += sx;
                    e -= ay;
                }
            }
        } else {
            // 任意方向(水平変量の方が大きい)
            e = -(dx);
            for (i = 0; i < dx; (i)++) {
                [self drawPoint:dp bitmap:bbmp  bitmapRow:brow
                                  pattern:pbmp patternRow:prow];

                // 点の移動
                e += ay;
                [dp moveX:sx];
                bbmp += sx;
                pbmp += sx;
                if (e >= 0) {
                    [dp moveY:sy];
                    bbmp += (sy * brow);
                    pbmp += (sy * prow);
                    e -= ax;
                }
            }
        }

        // 終点を始点に複写
        p1 = p2;
    }

EXIT:
    [patBitmap release];
    return;
}


//
// 色演算
//
//  Call
//    d2           : 濃度(0.1%単位)(塗装色(i2)用)
//    i1           : 色1(描画先色番号)
//    i2           : 色2(塗装色番号)
//    colMode_     : 色演算モード(instance 変数)
//    palette_     : 使用パレット(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//
//  Return
//    function : 塗装色
//
-(unsigned char)calcColor:(int)d2
                   color1:(unsigned char)i1
                   color2:(unsigned char)i2
{
    return [PoCoColorMixer calcColor:self->palette_
                             colMode:self->colMode_
                            density2:d2
                              color1:i1
                              color2:i2
                              buffer:self->colorBuffer_];
}


//
// 描画範囲
//  具象 class で描画範囲のドット数/2を返す
//
//  Call
//    None
//
//  Return
//    function : 描画範囲
//
-(int)pointSize
{
    return 0;                           // 基底では 0 を返す
}


//
// 点の描画
//  具象 class で指示のある点を中心に描画を実行する。
//  引数の bmp、plt は呼び出し時は描画中心を指している。
//
//  Call
//    p         : 描画中心
//    bbmp      : 描画対象
//    brow      : bbmp の rowbytes
//    pbmp      : パターン
//    prow      : pbmp の rowbytes
//    palette_  : 使用パレット(instance 変数)
//    density_  : 濃度(0.1%単位)(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//
//  Return
//    bbmp : 描画対象(描画結果)
//
-(void)drawPoint:(PoCoPoint *)p
          bitmap:(unsigned char *)bbmp
       bitmapRow:(const int)brow
         pattern:(const unsigned char *)pbmp
      patternRow:(const int)prow
{
    // 基底では何もしない
    ;

    return;
}

@end
