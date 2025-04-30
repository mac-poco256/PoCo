//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 任意領域
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditRegionFill.h"

// ============================================================================
@implementation PoCoEditRegionFill

// --------------------------------------------------------- instance - private
//
// 対象領域を算出
//  half-open property のため、右下に +1 する
//
//  Call
//    s       : 左上
//    e       : 右下
//    bitmap_ : 描画対象(基底 instance 変数)
//
//  Return
//    function : 領域
//
-(PoCoRect *)calcRect:(PoCoPoint *)s
                  end:(PoCoPoint *)e
{
    PoCoRect *r;

    r = [[PoCoRect alloc] init];
    if ([s x] < [e x]) {
        [r setLeft:MAX(0, [s x])];
        [r setRight:MIN([e x] + 1, [self->bitmap_ width])];
    } else {
        [r setLeft:MAX(0, [e x])];
        [r setRight:MIN([s x] + 1, [self->bitmap_ width])];
    }
    if ([s y] < [e y]) {
        [r setTop:MAX(0, [s y])];
        [r setBottom:MIN([e y] + 1, [self->bitmap_ height])];
    } else {
        [r setTop:MAX(0, [e y])];
        [r setBottom:MIN([s y] + 1, [self->bitmap_ height])];
    }

    return r;
}


//
// 形状マスクを切り取り
//
//  Call
//    mask : 形状マスク
//    s    : 左上
//    e    : 右下
//    r    : 対象領域
//
//  Return
//    function : 形状マスク
//
-(PoCoBitmap *)truncMask:(PoCoBitmap *)mask
            withStartPos:(PoCoPoint *)s
              withEndPos:(PoCoPoint *)e
                withRect:(PoCoRect *)r
{
    PoCoBitmap *pat;
    PoCoRect *mr;

    if (([mask width] == [r width]) && ([mask height] == [r height])) {
        // 全体(getBitmap で作らずに pointer 複写だけになるので retain)
        pat = mask;
        [pat retain];
    } else {
        // 部分
        mr = [[PoCoRect alloc] init];
        if ([r left] == 0) {
            [mr setLeft:-(MIN([s x], [e x]))];
        }
        if ([r top] == 0) {
            [mr setTop:-(MIN([s y], [e y]))];
        }
        [mr setRight:[mr left] + [r width]];
        [mr setBottom:[mr top] + [r height]];
        pat = [mask getBitmap:mr];
        [mr release];
    }

    return pat;
}


//
// タイルパターンと形状マスクを論理積
//
//  Call
//    style : 形状マスク
//    tile  : タイルパターン
//
//  Return
//    style : 形状マスク
//
-(void)andStyleMask:(PoCoBitmap *)style
    withTilePattern:(PoCoBitmap *)tile
{
    unsigned int size;
    unsigned char *stylePixel;
    unsigned char *tilePixel;

    size = [style width];
    size += (size & 1);
    size *= [style height];
    stylePixel = [style pixelmap];
    tilePixel = [tile pixelmap];

    do {
        // 積をとる
        *(stylePixel) = (*(stylePixel) & *(tilePixel));

        // 次へ
        (size)--;
        (stylePixel)++;
        (tilePixel)++;
    } while (size != 0);

    return;
}


//
// 描画実行
//
//  Call
//    r            : 描画領域
//    maskBitmap   : 形状マスク
//    bitmap_      : 描画対象(基底 instance 変数)
//    palette_     : 使用パレット(基底 instance 変数)
//    colorBitmap_ : 使用カラーパターン(基底 instance 変数)
//    colorRow_    : colpat rowbytes(基底 instance 変数)
//    bitmapRow_   : bitmap rowbytes(基底 instance 変数)
//    dist_        : 描画対象の上塗り確認(instance 変数)
//
//  Return
//    bitmap_ : 描画対象(基底 instance 変数)
//
-(void)draw:(PoCoRect *)r
   withMask:(PoCoBitmap *)maskBitmap
{
    unsigned int x;                     // X 軸の積算
    unsigned int y;                     // Y 軸の積算
    unsigned int maskRow;               // 形状マスクの row bytes
    unsigned char *bitmapPixel;         // 描画対象画像の pixelmap
    unsigned char *colorPixel;          // カラーパターンの pixelmap
    unsigned char *maskPixel;           // タイルパターンの pixelmap
    unsigned int bitmapSkip;            // 描画対象の次行 skip
    unsigned int colorSkip;             // カラーパターンの次行 skip
    unsigned int maskSkip;              // タイルパターンの次行 skip
    const unsigned int areaWidth = [r width];

    // 形状マスクの rowbytes 算出
    maskRow = [maskBitmap width];
    maskRow += (maskRow & 1);

    // 各種 pixelmap の取得
    bitmapPixel = [self->bitmap_ pixelmap] + (([r top] * self->bitmapRow_) + [r left]);
    colorPixel = [self->colorBitmap_ pixelmap];
    maskPixel  = [maskBitmap pixelmap];

    // skip 値の算出
    bitmapSkip = (self->bitmapRow_ - areaWidth);
    colorSkip = (self->colorRow_ - areaWidth);
    maskSkip = (maskRow - areaWidth);

    // 描画
    y = [r height];
    do {
        x = areaWidth;
        do {
            if (*(maskPixel) == 0) {
                // 形状範囲外
                ;
            } else if ((self->dist_) &&
                       ([[self->palette_ palette:*(bitmapPixel)] isMask])) {
                // 上塗り禁止
                ;
            } else if ([[self->palette_ palette:*(colorPixel)] noDropper]) {
                // 使用禁止
                ;
            } else {
                // 描画
                *(bitmapPixel) = *(colorPixel);
            }

            // 次へ
            (x)--;
            (maskPixel)++;
            (colorPixel)++;
            (bitmapPixel)++;
        } while (x != 0);

        // 次へ
        (y)--;
        maskPixel += maskSkip;
        colorPixel += colorSkip;
        bitmapPixel += bitmapSkip;
    } while (y != 0);

    return;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp  : 描画対象 bitmap
//    plt  : 使用パレット
//    tile : 使用タイルパターン
//    pat  : 使用カラーパターン
//    dist : 描画対象の上塗り確認
//
//  Return
//    function : 実体
//    dist_    : 描画対象の上塗り確認(instance 変数)
//
-(id)initWithPattern:(PoCoBitmap *)bmp
             palette:(PoCoPalette *)plt
                tile:(PoCoMonochromePattern *)tile
             pattern:(PoCoColorPattern *)pat
           checkDist:(BOOL)dist
{
//    DPRINT((@"[PoCoEditRegionFill initWithPattern]\n"));

    // super class の初期化
    self = [super initWithPattern:bmp
                          palette:plt
                              pen:nil
                             tile:tile
                          pattern:pat];

    // 自身の初期化
    if (self != nil) {
        self->dist_ = dist;
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
//    None
//
-(void)dealloc
{
//    DPRINT((@"[PoCoEditRegionFill dealloc]\n"));

    // 資源の解放
    ;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//
//  Call
//    mask        : 形状マスク
//    s           : 左上
//    e           : 右下
//    bitmap_     : 描画対象(基底 instance 変数)
//    tileBitmap_ : タイルパターンの bitmap(基底 instance 変数)
//
//  Return
//    None
//
-(void)executeDraw:(PoCoBitmap *)mask
      withStartPos:(PoCoPoint *)s
        withEndPos:(PoCoPoint *)e
{
    PoCoRect *r;
    PoCoBitmap *maskBitmap;

    // 対象領域の算出
    r = [self calcRect:s end:e];
    if (([r left] >= [self->bitmap_ width]) || ([r right] < 0) ||
        ([r top] >= [self->bitmap_ height]) || ([r bottom] < 0)) {
        ;
    } else {
        // パターンを取得(基底で取得)
        [super beginDraw:r];

        // 形状マスクを切り抜き
        maskBitmap = [self truncMask:mask
                        withStartPos:s
                          withEndPos:e
                            withRect:r];

        // タイルパターンと形状マスクを論理積
        [self andStyleMask:maskBitmap
           withTilePattern:self->tileBitmap_];

        // 描画
        [self draw:r
          withMask:maskBitmap];

        // 形状マスクを解放
        [maskBitmap release];

        // パターンを解放(基底で取得した分)
        [super endDraw];
    }
    [r release];

    return;
}

@end
