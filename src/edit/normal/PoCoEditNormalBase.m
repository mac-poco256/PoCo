//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 標準 - 基底
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditNormalBase.h"

// ============================================================================
@implementation PoCoEditNormalBase

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp  : 描画対象 bitmap
//    plt  : 使用パレット
//    pen  : 使用ペン先
//    tile : 使用タイルパターン
//    pat  : 使用カラーパターン
//
//  Return
//    function      : 実体
//    bitmap_       : 描画対象 bitmap(instance 変数)
//    palette_      : 使用パレット(instance 変数)
//    penPattern_   : 使用ペン先(instance 変数)
//    tilePattern_  : 使用タイルパターン(instance 変数)
//    colorPattern_ : 使用カラーパターン(instance 変数)
//    tileBitmap_   : タイルパターン(instance 変数)
//    colorBitmap_  : カラーパターン(instance 変数)
//    tileRow_      : タイルパターンの rowbytes(instance 変数)
//    colorRow_     : カラーパターンの rowbytes(instance 変数)
//    bitmapRow_    : 描画対象の rowbytes(instance 変数)
//    drawLeftTop_  : 描画範囲の左上(instance 変数)
//
-(id)initWithPattern:(PoCoBitmap *)bmp
             palette:(PoCoPalette *)plt
                 pen:(PoCoMonochromePattern *)pen
                tile:(PoCoMonochromePattern *)tile
             pattern:(PoCoColorPattern *)pat
{
//    DPRINT((@"[PoCoEditNormalBase initWithPattern]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->bitmap_ = bmp;
        self->palette_ = plt;
        self->penPattern_ = pen;
        self->tilePattern_ = tile;
        self->colorPattern_ = pat;
        self->tileBitmap_ = nil;
        self->colorBitmap_ = nil;
        self->tileRow_ = 0;
        self->colorRow_ = 0;
        self->bitmapRow_ = 0;
        self->drawLeftTop_ = nil;

        // それぞれを retain
        [self->bitmap_ retain];
        [self->palette_ retain];
        [self->penPattern_ retain];
        [self->tilePattern_ retain];
        [self->colorPattern_ retain];
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
//    bitmap_       : 描画対象 bitmap(instance 変数)
//    palette_      : 使用パレット(instance 変数)
//    penPattern_   : 使用ペン先(instance 変数)
//    tilePattern_  : 使用タイルパターン(instance 変数)
//    colorPattern_ : 使用カラーパターン(instance 変数)
//    tileBitmap_   : タイルパターン(instance 変数)
//    colorBitmap_  : カラーパターン(instance 変数)
//    drawLeftTop_  : 描画範囲の左上(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoEditNormalBase dealloc]\n"));

    // 資源の解放
    [self->bitmap_ release];
    [self->palette_ release];
    [self->penPattern_ release];
    [self->tilePattern_ release];
    [self->colorPattern_ release];
    [self->tileBitmap_ release];
    [self->colorBitmap_ release];
    [self->drawLeftTop_ release];
    self->bitmap_ = nil;
    self->palette_ = nil;
    self->penPattern_ = nil;
    self->tilePattern_ = nil;
    self->colorPattern_ = nil;
    self->tileBitmap_ = nil;
    self->colorBitmap_ = nil;
    self->drawLeftTop_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 点の描画
//  1点だけの描画用
//
//  Call
//    pnt           : 描画中心
//    bitmap_       : 描画対象 bitmap(instance 変数)
//    palette_      : 使用パレット(instance 変数)
//    penPattern_   : 使用ペン先(instance 変数)
//    tilePattern_  : 使用タイルパターン(instance 変数)
//    colorPattern_ : 使用カラーパターン(instance 変数)
//
//  Return
//    bitmap_ : 描画対象 bitmap(instance 変数)
//
-(void)drawPoint:(PoCoPoint *)pnt
{
    unsigned int x;                     // X 軸の積算
    unsigned int y;                     // Y 軸の積算
    unsigned int ty;                    // タイルパターンの Y 軸の積算
    unsigned int cy;                    // カラーパターンの Y 軸の積算
    unsigned int px;                    // ペン先の X 軸の積算
    unsigned int py;                    // ペン先の Y 軸の積算
    unsigned int ti;                    // タイルパターンの走査用
    unsigned int pi;                    // ペン先の走査用
    unsigned int ci;                    // カラーパターンの走査用
    unsigned int di;                    // 描画対象の走査用
    unsigned int trow;                  // タイルパターンの rowbytes
    unsigned int crow;                  // カラーパターンの rowbytes
    unsigned int row;                   // 描画対象の rowbytes
    unsigned char *pixmap;              // 描画対象画像の pixelmap
    PoCoRect *r;                        // 描画範囲(中点からペン先大きさ分まで)
    PoCoBitmap *tile;                   // 描画範囲に合わせたタイルパターン
    PoCoBitmap *col;                    // 描画範囲に合わせたカラーパターン
    unsigned char *tilePat;             // タイルパターンの pixelmap
    unsigned char *colPat;              // カラーパターンの pixelmap
    unsigned char *penPat;              // ペン先の pixelmap

//    DPRINT((@"[PoCoEditNormalBase drawPoint]\n"));

    r = nil;
    tile = nil;
    col = nil;

    // 対象領域の算出
    r = [[PoCoRect alloc] init];
    [r setLeft:([pnt x] - (PEN_STYLE_SIZE >> 1))];
    [r setTop:([pnt y] - (PEN_STYLE_SIZE >> 1))];
    [r setRight:MIN([pnt x] + (PEN_STYLE_SIZE >> 1), [self->bitmap_ width])];
    [r setBottom:MIN([pnt y] + (PEN_STYLE_SIZE >> 1), [self->bitmap_ height])];
    if (([r left] >= [self->bitmap_ width]) || ([r right] < 0) ||
        ([r top] >= [self->bitmap_ height]) || ([r bottom] < 0)) {
        goto EXIT;
    }
    if ([r left] < 0) {
        px = -[r left];
        [r setLeft:0];
    } else {
        px = 0;
    }
    if ([r top] < 0) {
        py = -[r top];
        [r setTop:0];
    } else {
        py = 0;
    }
    if ([r empty]) {
        goto EXIT;
    }

    // 各パターンの pixelmap の取得
    tile = [self->tilePattern_ getPixelmap:r];
    col = [self->colorPattern_ pixelmap:r];
    penPat = (unsigned char *)([self->penPattern_ pattern]);
    tilePat = [tile pixelmap];
    colPat = [col pixelmap];
    trow = ([tile width] + ([tile width] & 1));
    crow = ([col width] + ([col width] & 1));

    // 描画の実行
    ty = 0;
    cy = 0;
    row = ([self->bitmap_ width] + ([self->bitmap_ width] & 1));
    pixmap = [self->bitmap_ pixelmap];
    for (y = [r top]; y < [r bottom]; (y)++, (ty)++, (py)++, (cy)++) {
        ti = (ty * trow);
        pi = ((py * PEN_STYLE_SIZE) + px);
        ci = (cy * crow);
        di = ((y * row) + [r left]);
        for (x = [r left]; x < [r right]; (x)++, (ti)++, (pi)++, (ci)++, (di)++) {
            if (tilePat[ti] == 0) {
                // タイルパターンで描画対象外
                ;
            } else if (penPat[pi] == 0) {
                // ペン先で描画対象外
                ;
            } else if ([[self->palette_ palette:pixmap[di]] isMask]) {
                // 描画対象が上塗り禁止
                ;
            } else if ([[self->palette_ palette:colPat[ci]] noDropper]) {
                // 塗装色が使用禁止(吸い取り禁止)
                ;
            } else {
                // 描画実行
                pixmap[di] = colPat[ci];
            }
        }
    }

EXIT:
    [r release];
    [tile release];
    [col release];
    return;
}


//
// 描画開始
//
//  Call
//    r             : 描画領域
//    bitmap_       : 描画対象 bitmap(instance 変数)
//    tilePattern_  : 使用タイルパターン(instance 変数)
//    colorPattern_ : 使用カラーパターン(instance 変数)
//
//  Return
//    tileBitmap_  : タイルパターンの bitmap(instance 変数)
//    colorBitmap_ : カラーパターンの bitmap(instance 変数)
//    tileRow_     : タイルパターンの rowbytes(instance 変数)
//    colorRow_    : カラーパターンの rowbytes(instance 変数)
//    bitmapRow_   : 描画対象の rowbytes(instance 変数)
//    drawLeftTop_ : 描画範囲の左上(instance 変数)
//
-(void)beginDraw:(PoCoRect *)r
{
    // パターン類を生成
    self->tileBitmap_ = [self->tilePattern_ getPixelmap:r];
    self->colorBitmap_ = [self->colorPattern_ pixelmap:r];

    // row bytes を算出
    self->tileRow_ = ([self->tileBitmap_ width] + ([self->tileBitmap_ width] & 1));
    self->colorRow_ = ([self->colorBitmap_ width] + ([self->colorBitmap_ width] & 1));
    self->bitmapRow_ = ([self->bitmap_ width] + ([self->bitmap_ width] & 1));

    // lefttop を記憶
    self->drawLeftTop_ = [[PoCoPoint alloc] initX:[r left] initY:[r top]];

    return;
}


//
// 描画終了
//
//  Call
//    None
//
//  Return
//    tileBitmap_  : タイルパターンの bitmap(instance 変数)
//    colorBitmap_ : カラーパターンの bitmap(instance 変数)
//    drawLeftTop_ : 描画範囲の左上(instance 変数)
//
-(void)endDraw
{
    // パターン類を破棄
    [self->tileBitmap_ release];
    [self->colorBitmap_ release];
    [self->drawLeftTop_ release];
    self->tileBitmap_ = nil;
    self->colorBitmap_ = nil;
    self->drawLeftTop_ = nil;

    return;
}


//
// 点の描画
//  連続して描画する場合、事前に描画開始を呼ぶこと
//
//  Call
//    pnt          : 描画中心
//    bitmap_      : 描画対象 bitmap(instance 変数)
//    palette_     : 使用パレット(instance 変数)
//    penPattern_  : 使用ペン先(instance 変数)
//    tileBitmap_  : タイルパターン(instance 変数)
//    colorBitmap_ : カラーパターン(instance 変数)
//    tileRow_     : tilepat rowbytes(instance 変数)
//    colorRow_    : colpat rowbytes (instance 変数)
//    bitmapRow_   : bitmap rowbytes (instance 変数)
//    drawLeftTop_ : 描画範囲の左上(instance 変数)
//
//  Return
//    bitmap_ : 描画対象 bitmap(instance 変数)
//
-(void)drawPoint2:(PoCoPoint *)pnt
{
    unsigned int x;                     // X 軸の積算
    unsigned int y;                     // Y 軸の積算
    unsigned int px;                    // ペン先の X 軸の積算
    unsigned int py;                    // ペン先の Y 軸の積算
    unsigned char *pixmap;              // 描画対象画像の pixelmap
    PoCoRect *r;                        // 描画範囲(中点からペン先大きさ分まで)
    unsigned char *tilePat;             // タイルパターンの pixelmap
    unsigned char *colPat;              // カラーパターンの pixelmap
    unsigned char *penPat;              // ペン先の pixelmap
    unsigned int tileSkip;              // タイルパターンの次行 skip
    unsigned int penSkip;               // ペン先の次行 skip
    unsigned int colSkip;               // カラーパターンの次行 skip
    unsigned int pixSkip;               // 描画対象の次行 skip
    unsigned int areaWidth;

//    DPRINT((@"[PoCoEditNormalBase drawPoint2]\n"));

    r = nil;

    // 対象領域の算出
    r = [[PoCoRect alloc] init];
    [r setLeft:([pnt x] - (PEN_STYLE_SIZE >> 1))];
    [r setTop:([pnt y] - (PEN_STYLE_SIZE >> 1))];
    [r setRight:MIN([pnt x] + (PEN_STYLE_SIZE >> 1), [self->bitmap_ width])];
    [r setBottom:MIN([pnt y] + (PEN_STYLE_SIZE >> 1), [self->bitmap_ height])];
    if (([r left] >= [self->bitmap_ width]) || ([r right] < 0) ||
        ([r top] >= [self->bitmap_ height]) || ([r bottom] < 0)) {
        goto EXIT;
    }
    if ([r left] < 0) {
        px = -[r left];
        [r setLeft:0];
    } else {
        px = 0;
    }
    if ([r top] < 0) {
        py = -[r top];
        [r setTop:0];
    } else {
        py = 0;
    }
    if ([r empty]) {
        goto EXIT;
    }

    // 各種の pixelmap の先頭を取得
    tilePat = [self->tileBitmap_ pixelmap] + ((([r top] - [self->drawLeftTop_ y]) * self->tileRow_) + ([r left] - [self->drawLeftTop_ x]));
    penPat = (unsigned char *)([self->penPattern_ pattern]) + ((py * PEN_STYLE_SIZE) + px);
    colPat = [self->colorBitmap_ pixelmap] + ((([r top] - [self->drawLeftTop_ y]) * self->colorRow_) + ([r left] - [self->drawLeftTop_ x]));
    pixmap = [self->bitmap_ pixelmap] + (([r top] * self->bitmapRow_) + [r left]);

    // skip 値の算出
    areaWidth = [r width];
    tileSkip = (self->tileRow_ - areaWidth);
    penSkip = (PEN_STYLE_SIZE - areaWidth);
    colSkip = (self->colorRow_ - areaWidth);
    pixSkip = (self->bitmapRow_ - areaWidth);

    // 描画の実行
    y = [r height];
    do {
        x = areaWidth;
        do {
            if (*(tilePat) == 0) {
                // タイルパターンで描画対象外
                ;
            } else if (*(penPat) == 0) {
                // ペン先で描画対象外
                ;
            } else if ([[self->palette_ palette:*(pixmap)] isMask]) {
                // 描画対象が上塗り禁止
                ;
            } else if ([[self->palette_ palette:*(colPat)] noDropper]) {
                // 塗装色が使用禁止(吸い取り禁止)
                ;
            } else {
                // 描画実行
                *(pixmap) = *(colPat);
            }

            // 次へ
            (x)--;
            (tilePat)++;
            (penPat)++;
            (colPat)++;
            (pixmap)++;
        } while (x != 0);

        // 次へ
        (y)--;
        tilePat += tileSkip;
        penPat += penSkip;
        colPat += colSkip;
        pixmap += pixSkip;
    } while (y != 0);

EXIT:
    [r release];
    return;
}

@end
