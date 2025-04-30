//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 霧吹き - 領域塗りつぶし
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditAtomizerFill.h"

#import "PoCoUtil.h"

// ============================================================================
@implementation PoCoEditAtomizerFill

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp : 編集対象
//    plt : 使用パレット
//    pat : 使用カラーパターン
//    rat : 頻度
//
//  Return
//    function : 実体
//    bitmap_  : 編集対象(instance 変数)
//    palette_ : 使用パレット(instance 変数)
//    pattern_ : 使用カラーパターン(instance 変数)
//    ratio_   : 頻度(0.1%単位)(instance 変数)
//
-(id)init:(PoCoBitmap *)bmp
  palette:(PoCoPalette *)plt
  pattern:(PoCoColorPattern *)pat
    ratio:(int)rat
{
    DPRINT((@"[PoCoEditAtomizerFill init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->bitmap_ = bmp;
        self->palette_ = plt;
        self->pattern_ = pat;
        self->ratio_ = rat;

        // それぞれ retain しておく
        [self->bitmap_ retain];
        [self->palette_ retain];
        [self->pattern_ retain];
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
//    pattern_ : 使用カラーパターン(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoEditAtomizerFill dealloc]\n"));

    // 資源の解放
    [self->bitmap_ release];
    [self->palette_ release];
    [self->pattern_ release];
    self->bitmap_ = nil;
    self->palette_ = nil;
    self->pattern_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//
//  Call
//    mask     : 形状
//    tile     : タイルパターン
//    trueRect : 描画範囲(画像範囲外含む)
//    drawRect : 描画範囲(画像範囲内のみ)
//    bitmap_  : 編集対象(instance 変数)
//    palette_ : 使用パレット(instance 変数)
//    pattern_ : 使用カラーパターン(instance 変数)
//    ratio_   : 頻度(0.1%単位)(instance 変数)
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

    p = nil;
    tr = nil;
    nr = nil;
    patBitmap = nil;
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
    nr = [[PoCoRect alloc] initLeft:([trueRect left] & 1)
                            initTop:([trueRect top] & 1)
                          initRight:([trueRect width] + 1 + ([trueRect left] & 1))
                         initBottom:([trueRect height] + 1 + ([trueRect top] & 1))];
    
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
                ([drawRect isPointInRect:p]) &&
                (*(mbmp) != 0) &&
                (*(tbmp) != 0) &&
                (!([[self->palette_ palette:*(bbmp)] isMask])) &&
                (!([[self->palette_ palette:*(pbmp)] noDropper]))) {
                *(bbmp) = *(pbmp);
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

EXIT:
    // 描画終了
    [patBitmap release];
    [tileBitmap release];
    [tr release];
    [nr release];
    [p release];
    return;
}

@end
