//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 霧吹き - 直線
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditAtomizerDrawLine.h"

#import "PoCoUtil.h"
#import "PoCoEditAtomizerPattern.h"

// ============================================================================
@implementation PoCoEditAtomizerDrawLine

// --------------------------------------------------------- instance - private
//
// 霧吹きのパターン
//  移動方法に合わせて補正をかける
//
//  Call
//    p        : 原点
//    size_    : 大きさ(instance 変数)
//    flip_    : 反転(instance 変数)
//    posSkip_ : 移動方法(instance 変数)
//    patType_ : 種類(instance 変数)
//
//  Return
//    function : パターン
//
-(const unsigned char *)correctPattern:(PoCoPoint *)p
{
    const unsigned char *tbl = ((self->patType_) ?
                                   [PoCoEditAtomizerPattern half:self->size_
                                                            type:0] :
                                   [PoCoEditAtomizerPattern normal:self->size_]);
    const int x = [p x];
    const int y = [p y];

    // 移動方法で補正
    if (self->posSkip_ == PoCoAtomizerSkipType_Always) {
        // 常に移動
        tbl += ((4 * ATOMIZER_TBL_ROW1) + 4);
    } else if (self->posSkip_ == PoCoAtomizerSkipType_Binary) {
        // 偶数座標、奇数座標に固定
        tbl += (((4 - (y & 0x01)) * ATOMIZER_TBL_ROW1) + (4 - (x & 0x01)));
    } else if (self->patType_) {
        // 半値パターンでパターンを維持
#if 1
        tbl = [PoCoEditAtomizerPattern half:self->size_
                                       type:(((x % 4) / 2) != ((y % 4) / 2))]
              +  ((x & 0x01) + 4)
              + (((y & 0x01) + 4) * ATOMIZER_TBL_ROW1);
#else   // 1 // 演算式の意味を忠実に書き表せばこういうこと
{
        BOOL xe;
        BOOL ye;
        BOOL xh;
        BOOL yh;
        int type;

        xe = ((x & 0x01) != 0x00);
        ye = ((y & 0x01) != 0x00);
        xh = ((x % 4) >= 2);
        yh = ((y % 4) >= 2);
        type = (((yh) ? 0x08 : 0x00) | ((xh) ? 0x04 : 0x00) | ((ye) ? 0x02 : 0x00) | ((xe) ? 0x01 : 0x00));
        switch (type) {
            case 0x0b:
                // yh -- ye xe
                ;   // 通過
            case 0x07:
                // -- xh ye xe
                tbl = [PoCoEditAtomizerPattern half:self->size_ type:1];
                tbl += 5;
                tbl += (5 * ATOMIZER_TBL_ROW1);
                break;
            case 0x0a:
                // yh -- ye --
                ;   // 通過
            case 0x06:
                // -- xh ye --
                tbl = [PoCoEditAtomizerPattern half:self->size_ type:1];
                tbl += 4;
                tbl += (5 * ATOMIZER_TBL_ROW1);
                break;
            case 0x09:
                // yh -- -- xe
                ;   // 通過
            case 0x05:
                // -- xh -- xe
                tbl = [PoCoEditAtomizerPattern half:self->size_ type:1];
                tbl += 5;
                tbl += (4 * ATOMIZER_TBL_ROW1);
                break;
            case 0x08:
                // yh -- -- --
                ;   // 通過
            case 0x04:
                // -- xh -- --
                tbl = [PoCoEditAtomizerPattern half:self->size_ type:1];
                tbl += 4;
                tbl += (4 * ATOMIZER_TBL_ROW1);
                break;

            case 0x0f:
                // yh xh ye xe
                ;   // 通過
            case 0x03:
                // -- -- ye xe
                tbl = [PoCoEditAtomizerPattern half:self->size_ type:0];
                tbl += 5;
                tbl += (5 * ATOMIZER_TBL_ROW1);
                break;
            case 0x0e:
                // yh xh ye --
                ;   // 通過
            case 0x02:
                // -- -- ye --
                tbl = [PoCoEditAtomizerPattern half:self->size_ type:0];
                tbl += 4;
                tbl += (5 * ATOMIZER_TBL_ROW1);
                break;
            case 0x0d:
                // yh xh -- xe
                ;   // 通過
            case 0x01:
                // -- -- -- xe
                tbl = [PoCoEditAtomizerPattern half:self->size_ type:0];
                tbl += 5;
                tbl += (4 * ATOMIZER_TBL_ROW1);
                break;
            default:
            case 0x0c:
                // yh xh -- --
                ;   // 通過
            case 0x00:
                // -- -- -- --
                tbl = [PoCoEditAtomizerPattern half:self->size_ type:0];
                tbl += 4;
                tbl += (4 * ATOMIZER_TBL_ROW1);
                break;
        }
}
#endif  // 1
    } else {
        // 通常パターンでパターンを維持
        tbl += (((y % ATOMIZER_TBL_CORR) * ATOMIZER_TBL_ROW1) + (x % ATOMIZER_TBL_CORR));
    }

    // 反転時は横に 1dot 移動
    if (self->flip_) {
        (tbl)--;
    }

    return tbl;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp  : 編集対象
//    plt  : 使用パレット
//    pat  : 使用カラーパターン
//    size : 大きさ
//
//  Return
//    function  : 実体
//    bitmap_   : 編集対象(instance 変数)
//    palette_  : 使用パレット(instance 変数)
//    pattern_  : 使用カラーパターン(instance 変数)
//    points_   : 描画する点(instance 変数)
//    ratio_    : 頻度(0.1%単位)(instance 変数)
//    size_     : 大きさ(instance 変数)
//    flip_     : 反転(instance 変数)
//    posSkip_  : 移動方法(instance 変数)
//    patType_  : 種類(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//
-(id)init:(PoCoBitmap *)bmp
  palette:(PoCoPalette *)plt
  pattern:(PoCoColorPattern *)pat
  penSize:(int)size
{
    DPRINT((@"[PoCoEditAtomizerDrawLine init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->bitmap_ = bmp;
        self->palette_ = plt;
        self->pattern_ = pat;
        self->ratio_ = 0;
        self->size_ = size;
        self->posSkip_ = PoCoAtomizerSkipType_Always;
        self->flip_ = NO;

        // それぞれ retain しておく
        [self->bitmap_ retain];
        [self->palette_ retain];
        [self->pattern_ retain];

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
//    bitmap_   : 編集対象(instance 変数)
//    palette_  : 使用パレット(instance 変数)
//    pattern_  : 使用カラーパターン(instance 変数)
//    points_   : 描画する点(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoEditAtomizerDrawLine dealloc]\n"));

    // 資源の解放
    [self->points_ removeAllObjects];
    [self->bitmap_ release];
    [self->palette_ release];
    [self->pattern_ release];
    [self->points_ release];
    [self->drawRect_ release];
    self->bitmap_ = nil;
    self->palette_ = nil;
    self->pattern_ = nil;
    self->points_ = nil;
    self->drawRect_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 点を登録
//
//  Call
//    p : 登録する点
//
//  Return
//    points_   : 描画する点(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//
-(void)addPoint:(PoCoPoint *)p
{
    const int sz = (ATOMIZER_TBL_ROW / 2);
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
// 頻度を登録
//
//  Call
//    dnum : 頻度(0.1%単位)
//    skip : 移動方法
//    type : 種類
//    flag : 反転
//
//  Return
//    ratio_   : 頻度(0.1%単位)(instance 変数)
//    flip_    : 反転(instance 変数)
//    posSkip_ : 移動方法(instance 変数)
//    patType_ : 種類(instance 変数)
//
-(void)setRatio:(int)dnum
      pointSkip:(PoCoAtomizerSkipType)skip
    patternType:(BOOL)type
      isFlipped:(BOOL)flag
{
    self->ratio_ = dnum;
    self->flip_ = flag;
    self->posSkip_ = skip;
    self->patType_ = type;

    return;
}


//
// 実行
//  ここでは座標演算が目的で描画は drawPoint: で実装する
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
    if ([self->drawRect_ empty]) {
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
        sx = ([p2 x] < [dp x]) ? -1 : 1;
        sy = ([p2 y] < [dp y]) ? -1 : 1;
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
            for (i = 0; i < dy; i++) {
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
            for (i = 0; i < dx; i++) {
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
// 点の描画
//  指示のある点を中心に描画を実行
//  引数の bmp、plt は呼び出し時は描画中心を指す
//
//  Call
//    p         : 描画中心
//    bbmp      : 描画対象
//    brow      : bbmp の rowbytes
//    pbmp      : パターン
//    prow      : pbmp の rowbytes
//    palette_  : 使用パレット(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//    ratio_    : 頻度(0.1%単位)(instance 変数)
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
    unsigned int cnt;
    unsigned int num;
    PoCoPoint *dp = [[PoCoPoint alloc] initX:[p x] initY:[p y]];
    const unsigned char *abmp = [self correctPattern:dp];
    const int a1 = (ATOMIZER_TBL_ROW - 1);
    const int l2 = (ATOMIZER_TBL_LINE / 2);
    const int r2 = (ATOMIZER_TBL_ROW / 2);
    const int brow1 = (brow - a1);
    const int prow1 = (prow - a1);
    const int acorr = (ATOMIZER_TBL_CORR + 1);

    DPRINT((@"[PoCoEditAtomizerDrawLine drawPoint:]\n"));

    // 原点を左上に合わせる
    bbmp -= ((brow * l2) + r2);
    pbmp -= ((prow * l2) + r2);
    [dp moveX:-(r2) moveY:-(l2)];

    // 走査しつつ描画
    cnt = (ATOMIZER_TBL_ROW - 1);
    num = (ATOMIZER_TBL_ROW * ATOMIZER_TBL_LINE);
    do {
#if 1
        if (([PoCoUtil canDrawFromRatio:self->ratio_]) &&
            (*(abmp) != 0) &&
            ([self->drawRect_ isPointInRect:dp]) &&
            (!([[self->palette_ palette:*(bbmp)] isMask])) &&
            (!([[self->palette_ palette:*(pbmp)] noDropper]))) {
            *(bbmp) = *(pbmp);
        }
#else   // 1
        if ([PoCoUtil canDrawFromRatio:self->ratio_]) {
            if (*(abmp) != 0) {
                if ([self->drawRect_ isPointInRect:dp]) {
                    if ([[self->palette_ palette:*(bbmp)] isMask]) {
                        ;
                    } else if ([[self->palette_ palette:*(pbmp)] noDropper]) {
                        ;
                    } else {
                        *(bbmp) = *(pbmp);
                    }
                }
            }
        }
#endif  // 1
        if (cnt != 0) {
            // 水平に移動
            (bbmp)++;
            (pbmp)++;
            (abmp)++;
            [dp moveX:1];
        } else {
            // 水平は原点に戻って垂直移動
            cnt = ATOMIZER_TBL_ROW;
            bbmp += brow1;
            pbmp += prow1;
            abmp += acorr;
            [dp moveX:-(a1) moveY:1];
        }
        (cnt)--;
        (num)--;
    } while (num != 0);
    [dp release];

    return;
}

@end
