//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 拡散 - 領域塗りつぶし
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditRandomFill.h"

#import "PoCoUtil.h"

// ============================================================================
@implementation PoCoEditRandomFill

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp : 編集対象
//    plt : 使用パレット
//    rat : 頻度
//    rng : 範囲
//
//  Return
//    function : 実体
//    bitmap_  : 編集対象(instance 変数)
//    palette_ : 使用パレット(instance 変数)
//    ratio_   : 頻度(0.1%単位)(instance 変数)
//    range_   : 範囲(instance 変数)
//
-(id)init:(PoCoBitmap *)bmp
  palette:(PoCoPalette *)plt
    ratio:(int)rat
    range:(int)rng
{
    DPRINT((@"[PoCoEditRandomFill init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->bitmap_ = bmp;
        self->palette_ = plt;
        self->ratio_ = rat;
        self->range_ = rng;

        // それぞれ retain しておく
        [self->bitmap_ retain];
        [self->palette_ retain];
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
//    bitmap_  : 編集対象(instance 変数)
//    palette_ : 使用パレット(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoEditRandomFill dealloc]\n"));

    // 資源の解放
    [self->bitmap_ release];
    [self->palette_ release];
    self->bitmap_ = nil;
    self->palette_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//  重複移動を避けるために、移動後は形状マスクを 0x00 にする
//
//  Call
//    mask     : 形状
//    tile     : タイルパターン
//    trueRect : 描画範囲(画像範囲外含む)
//    drawRect : 描画範囲(画像範囲内のみ)
//    bitmap_  : 編集対象(instance 変数)
//    palette_ : 使用パレット(instance 変数)
//    ratio_   : 頻度(0.1%単位)(instance 変数)
//    range_   : 範囲(instance 変数)
//
//  Return
//    mask    : 形状
//    bitmap_ : 編集対象(instance 変数)
//
-(void)executeDraw:(PoCoBitmap *)mask
          withTile:(PoCoMonochromePattern *)tile
      withTrueRect:(PoCoRect *)trueRect
      withDrawRect:(PoCoRect *)drawRect
{
    PoCoBitmap *tileBitmap;             // タイルパターン(描画範囲に調整済み)
    PoCoRect *tr;
    PoCoRect *dr;
    PoCoRect *rr;
    PoCoPoint *sp;
    PoCoPoint *dp;
    int brow;                           // 描画対象の rowbyets
    int mrow;                           // 形状の rowbytes
    int trow;                           // タイルパターンの rowbytes
    unsigned char *bbmp;
    unsigned char *mbmp;
    const unsigned char *tbmp;
    int bsidx;
    int bdidx;
    int msidx;
    int mdidx;
    int tsidx;
    int tdidx;

    tr = nil;
    dr = nil;
    tileBitmap = nil;

    // 描画領域なし
    if([drawRect empty]){
        goto EXIT;
    }

    // half-open property にするので右下に +1
    tr = [[PoCoRect alloc] initLeft:[trueRect left]
                            initTop:[trueRect top]
                          initRight:([trueRect right] + 1)
                         initBottom:([trueRect bottom] + 1)];
    dr = [[PoCoRect alloc] initLeft:[drawRect left]
                            initTop:[drawRect top]
                          initRight:([drawRect right] + 1)
                         initBottom:([drawRect bottom] + 1)];
    if ([self->bitmap_ width] < [dr right]) {
        [dr setRight:[self->bitmap_ width]];
    }
    if ([self->bitmap_ height] < [dr bottom]) {
        [dr setBottom:[self->bitmap_ height]];
    }
    
    // 描画開始
    tileBitmap = [tile getPixelmap:tr];

    // 各種値の算出
    brow = ([self->bitmap_ width] + ([self->bitmap_ width] & 1));
    mrow = ([mask width]          + ([mask width]          & 1));
    trow = ([tileBitmap width]    + ([tileBitmap width]    & 1));

    // 各種走査用ビットマップを取得
    bbmp = [self->bitmap_ pixelmap];
    mbmp = [mask pixelmap];
    tbmp = [tileBitmap pixelmap];

    // 走査/描画
    sp = [[PoCoPoint alloc] init];
    dp = [[PoCoPoint alloc] init];
    rr = [[PoCoRect alloc] init];
    for ([sp setY:[tr top]]; [sp y] < [tr bottom]; [sp moveY:1]) {
        for ([sp setX:[tr left]]; [sp x] < [tr right]; [sp moveX:1]) {
            [rr   setLeft:MAX(([sp x] - self->range_    ), [tr   left])];
            [rr    setTop:MAX(([sp y] - self->range_    ), [tr    top])];
            [rr  setRight:MIN(([sp x] + self->range_ - 1), [tr  right])];
            [rr setBottom:MIN(([sp y] + self->range_ - 1), [tr bottom])];
            if (!([rr empty])) {
                [dp setX:[PoCoUtil randomStartRange:[rr left]
                                       withEndRange:[rr right]]];
                [dp setY:[PoCoUtil randomStartRange:[rr top]
                                       withEndRange:[rr bottom]]];
                bsidx = (( [sp y]             * brow) +  [sp x]             );
                bdidx = (( [dp y]             * brow) +  [dp x]             );
                msidx = ((([sp y] - [tr top]) * mrow) + ([sp x] - [tr left]));
                mdidx = ((([dp y] - [tr top]) * mrow) + ([dp x] - [tr left]));
                tsidx = ((([sp y] - [tr top]) * trow) + ([sp x] - [tr left]));
                tdidx = ((([dp y] - [tr top]) * trow) + ([dp x] - [tr left]));
                if ((!([sp isEqualPos:dp])) &&
                    ([dr isPointInRect:sp]) &&
                    ([dr isPointInRect:dp]) &&
                    ([PoCoUtil canDrawFromRatio:self->ratio_]) &&
                    (mbmp[msidx] != 0) &&
                    (tbmp[tsidx] != 0) &&
                    (!([[self->palette_ palette:bbmp[bsidx]] isMask])) &&
                    (!([[self->palette_ palette:bbmp[bsidx]] noDropper])) &&
                    (mbmp[mdidx] != 0) &&
                    (tbmp[tdidx] != 0) &&
                    (!([[self->palette_ palette:bbmp[bdidx]] isMask])) &&
                    (!([[self->palette_ palette:bbmp[bdidx]] noDropper]))) {
                    // 入れ替え
#if 0
                    bbmp[bsidx] = (bbmp[bsidx] ^ bbmp[bdidx]);
                    bbmp[bdidx] = (bbmp[bdidx] ^ bbmp[bsidx]);
                    bbmp[bsidx] = (bbmp[bsidx] ^ bbmp[bdidx]);
#else   // 0
                    bbmp[bsidx] ^= bbmp[bdidx];
                    bbmp[bdidx] ^= bbmp[bsidx];
                    bbmp[bsidx] ^= bbmp[bdidx];
#endif  // 0

                    // 重複移動を避けるために形状マスクを 0x00 にする
                    mbmp[msidx] = 0x00;
                    mbmp[mdidx] = 0x00;
                }
            }
        }
    }
    [sp release];
    [dp release];
    [rr release];

EXIT:
    [tileBitmap release];
    [tr release];
    [dr release];
    return;
}

@end
