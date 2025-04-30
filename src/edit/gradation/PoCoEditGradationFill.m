//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - グラデーション - 領域塗りつぶし
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditGradationFill.h"

#import "PoCoUtil.h"
#import "PoCoColorMixer.h"

// ============================================================================
@implementation PoCoEditGradationFill

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
//    ratio : 頻度
//
//  Return
//    function     : 実体
//    bitmap_      : 編集対象(instance 変数)
//    colMode_     : 色演算モード(instance 変数)
//    palette_     : 使用パレット(instance 変数)
//    pattern_     : 使用カラーパターン(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//    density_     : 濃度(0.1%単位)(instance 変数)
//    ratio_       : 頻度(0.1%単位)(instance 変数)
//
-(id)init:(PoCoBitmap *)bmp
  colMode:(PoCoColorMode)cmode
  palette:(PoCoPalette *)plt
  pattern:(PoCoColorPattern *)pat
   buffer:(PoCoColorBuffer *)buf
    ratio:(int)ratio
{
    DPRINT((@"[PoCoEditGradationFill init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->bitmap_ = bmp;
        self->colMode_ = cmode;
        self->palette_ = plt;
        self->pattern_ = pat;
        self->density_ = 0;
        self->ratio_ = ratio;
        self->colorBuffer_ = buf;

        // それぞれ retain しておく
        [self->bitmap_ retain];
        [self->palette_ retain];
        [self->pattern_ retain];
        [self->colorBuffer_ retain];

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
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoEditGradationFill dealloc]\n"));

    // 資源の解放
    [self->bitmap_ release];
    [self->palette_ release];
    [self->pattern_ release];
    [self->colorBuffer_ release];
    self->bitmap_ = nil;
    self->palette_ = nil;
    self->pattern_ = nil;
    self->colorBuffer_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 更新
//
//  Call
//    d   : 頻度(0.1%単位)
//    bmp : 編集対象
//
//  Return
//    density_ : 濃度(0.1%単位)(instance 変数)
//    bitmap_  : 編集対象(instance 変数)
//
-(void)replaceDensity:(int)d
           withBitmap:(PoCoBitmap *)bmp
{
    // 以前の分を忘れる
    [self->bitmap_ release];

    // 差し替え
    self->density_ = d;
    self->bitmap_ = bmp;
    [self->bitmap_ retain];

    return;
}


//
// 実行
//
//  Call
//    mask         : 形状
//    tile         : タイルパターン
//    trueRect     : 描画範囲(画像範囲外含む)
//    drawRect     : 描画範囲(画像範囲内のみ)
//    bitmap_      : 編集対象(instance 変数)
//    colMode_     : 色演算モード(instance 変数)
//    palette_     : 使用パレット(instance 変数)
//    pattern_     : 使用カラーパターン(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//    density_     : 濃度(0.1%単位)(instance 変数)
//    ratio_       : 頻度(0.1%単位)(instance 変数)
//
//  Return
//    bitmap_ : 編集対象(instance 変数)
//
-(void)executeDraw:(PoCoBitmap *)mask
          withTile:(PoCoMonochromePattern *)tile
      withTrueRect:(PoCoRect *)trueRect
      withDrawRect:(PoCoRect *)drawRect
{
    PoCoBitmap *patBitmap;              // カラーパターン(描画範囲に調整済み)
    PoCoBitmap *tileBitmap;             // タイルパターン(描画範囲に調整済み)
    PoCoRect *tr;
    PoCoRect *dr;
    PoCoRect *nr;
    PoCoPoint *p;
    int brow;                           // 描画対象の rowbyets
    int prow;                           // カラーパターンの rowbytes
    int mrow;                           // 形状の rowbytes
    int trow;                           // タイルパターンの rowbytes
    int bskip;                          // 描画対象の次の行までのアキ
    int pskip;                          // カラーパターンの次の行までのアキ
    int mskip;                          // 形状の次の行までのアキ
    int tskip;                          // タイルパターンの次の行までのアキ
    unsigned char *bbmp;                // 描画対象の走査用
    const unsigned char *pbmp;          // カラーパターンの走査用
    const unsigned char *mbmp;          // 形状の走査用
    const unsigned char *tbmp;          // タイルパターンの走査用

    tr = nil;
    dr = nil;
    nr = nil;
    patBitmap = nil;
    tileBitmap = nil;

    // 描画領域なし
    if ([drawRect empty]) {
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
    nr = [[PoCoRect alloc] initLeft:([trueRect left] & 1)
                            initTop:([trueRect top] & 1)
                          initRight:([trueRect width] + 1 + ([trueRect left] & 1))
                         initBottom:([trueRect height] + 1 + ([trueRect top] & 1))];
    
    if ([self->bitmap_ width] < [dr right]) {
        [dr setRight:[self->bitmap_ width]];
    }
    if ([self->bitmap_ height] < [dr bottom]) {
        [dr setBottom:[self->bitmap_ height]];
    }

    // 描画開始
    patBitmap = [self->pattern_ pixelmap:tr];
    tileBitmap = [tile getPixelmap:nr];

    // 各種値の算出
    brow = ([self->bitmap_ width] + ([self->bitmap_ width] & 1));
    prow = ([patBitmap width]     + ([patBitmap width]     & 1));
    mrow = ([mask width]          + ([mask width]          & 1));
    trow = ([tileBitmap width]    + ([tileBitmap width]    & 1));
    bskip = (brow - [tr width]);
    pskip = (prow - [tr width]);
    mskip = (mrow - [tr width]);
    tskip = (trow - [tr width]);

    // 各種走査用ビットマップを取得
    bbmp = [self->bitmap_ pixelmap] + (([tr top] * brow) + [tr left]);
    pbmp = [patBitmap pixelmap];
    mbmp = [mask pixelmap];
    tbmp = [tileBitmap pixelmap];

    // 走査/描画
    p = [[PoCoPoint alloc] init];
    for ([p setY:[tr top]]; [p y] < [tr bottom]; [p moveY:1]) {
        for ([p setX:[tr left]]; [p x] < [tr right]; [p moveX:1]) {
            if (([PoCoUtil canDrawFromRatio:self->ratio_]) &&
                ([dr isPointInRect:p]) &&
                (*(mbmp) != 0) &&
                (*(tbmp) != 0) &&
                (!([[self->palette_ palette:*(bbmp)] isMask]))) {
                *(bbmp) = [PoCoColorMixer calcColor:self->palette_
                                            colMode:self->colMode_
                                           density2:self->density_
                                             color1:*(bbmp)
                                             color2:*(pbmp)
                                             buffer:self->colorBuffer_];
            }

            // 次へ
            (bbmp)++;
            (pbmp)++;
            (mbmp)++;
            (tbmp)++;
        }

        // 次へ
        bbmp += bskip;
        pbmp += pskip;
        mbmp += mskip;
        tbmp += tskip;
    }
    [p release];

EXIT:
    // 描画終了
    [tr release];
    [dr release];
    [nr release];
    [patBitmap release];
    [tileBitmap release];
    return;
}

@end
