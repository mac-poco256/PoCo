//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 標準 - 画像貼り付け
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditNormalPasteImage.h"

// ============================================================================
@implementation PoCoEditNormalPasteImage

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp  : 描画対象 bitmap
//    plt  : パレット
//    tile : 使用タイルパターン
//    mask : 形状マスク
//    pst  : 貼り付ける画像
//
//  Return
//    function     : 実体
//    maskBitmap_  : 形状マスク(instance 変数)
//    pasteBitmap_ : 貼り付ける画像(instance 変数)
//
-(id)initWithBitmap:(PoCoBitmap *)bmp
            palette:(PoCoPalette *)plt
               tile:(PoCoMonochromePattern *)tile
               mask:(PoCoBitmap *)mask
        pasteBitmap:(PoCoBitmap *)pst
{
//    DPRINT((@"[PoCoEditNormalPasteImage initWithPattern]\n"));

    // super class の初期化
    self = [super initWithPattern:bmp
                          palette:plt
                              pen:nil
                             tile:tile
                          pattern:nil];

    // 自身の初期化
    if (self != nil) {
        self->maskBitmap_ = mask;
        self->pasteBitmap_ = pst;
        [self->maskBitmap_ retain];
        [self->pasteBitmap_ retain];
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
//    maskBitmap_  : 形状マスク(instance 変数)
//    pasteBitmap_ : 貼り付ける画像(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoEditNormalPasteImage dealloc]\n"));

    // 資源の解放
    [self->maskBitmap_ release];
    [self->pasteBitmap_ release];
    self->maskBitmap_ = nil;
    self->pasteBitmap_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//
//  Call
//    pasteRect    : 貼り付ける先の矩形枠
//    bitmap_      : 対象 bitmap(基底 instance 変数)
//    palette_     : パレット(基底 instance 変数)
//    tilePattern_ : タイルパターン(基底 instance 変数)
//    maskBitmap_  : 形状マスク(instance 変数)
//    pasteBitmap_ : 貼り付ける画像(instance 変数)
//
//  Return
//    bitmap_ : 描画対象 bitmap(基底 instance 変数)
//
-(void)executeDraw:(PoCoRect *)pasteRect
{
    PoCoRect *r;                        // 描画範囲
    unsigned int x;                     // X 軸の積算
    unsigned int y;                     // Y 軸の積算
    unsigned int px;                    // 貼り付ける画像の走査元 X 軸
    unsigned int py;                    // 貼り付ける画像の走査元 Y 軸
    PoCoBitmap *tpat;                   // タイルパターン
    unsigned char *dbmp;                // 描画対象画像の pixelmap
    unsigned char *pbmp;                // 貼り付ける画像の pixelmap
    unsigned char *tbmp;                // タイルパターンの pixelmap
    unsigned char *mbmp;                // 形状マスクの pixelmap
    int drow;                           // 対象画像の rowbytes
    int prow;                           // 貼り付ける画像の rowbytes
    int dskip;                          // 描画対象の次行 skip
    int pskip;                          // 貼り付ける画像の次行 skip
    int tskip;                          // タイルパターンの次行 skip
    int mskip;                          // 形状マスクの次行 skip
    int w;
    int i;

    r = nil;
    tpat = nil;

    // 対象領域の算出
    r = [[PoCoRect alloc] initLeft:[pasteRect left]
                           initTop:[pasteRect top]
                         initRight:MIN([pasteRect right], [self->bitmap_ width])
                        initBottom:MIN([pasteRect bottom], [self->bitmap_ height])];
    if (([r left]   >= [self->bitmap_ width])  ||
        ([r top]    >= [self->bitmap_ height]) ||
        ([r right]  < 0) ||
        ([r bottom] < 0)) {
        goto EXIT;
    }
    if ([r left] < 0) {
        px = -([r left]);
        [r setLeft:0];
    } else {
        px = 0;
    }
    if ([r top] < 0) {
        py = -([r top]);
        [r setTop:0];
    } else {
        py = 0;
    }
    if ([r empty]) {
        goto EXIT;
    }

    // rowbytes を算出
    drow = ([self->bitmap_ width] + ([self->bitmap_ width] & 1));
    prow = ([self->pasteBitmap_ width] + ([self->pasteBitmap_ width] & 1));

    // 各種の pixelmap の先頭を取得
    dbmp = ([self->bitmap_ pixelmap] + (([r top] * drow) + [r left]));
    pbmp = [self->pasteBitmap_ pixelmap];
    if (([self->pasteBitmap_ width] == [pasteRect width]) &&
        ([self->pasteBitmap_ height] == [pasteRect height])) {
        pbmp += ((py * prow) + px);
    }

    // skip 値の算出
    w = [r width];
    dskip = (drow - w);
    pskip = (prow - w);

    // タイルパターン生成
    if (self->tilePattern_ != nil) {
        tpat = [self->tilePattern_ getPixelmap:r];
        tbmp = [tpat pixelmap];
        i = ([tpat width] + ([tpat width] & 1));
        tskip = (i - w);
    } else {
        tpat = nil;
        tbmp = NULL;
        tskip = 0;
    }

    // 形状マスク生成
    if (self->maskBitmap_ != nil) {
        i = ([self->maskBitmap_ width] + ([self->maskBitmap_ width] & 1));
        mbmp = ([self->maskBitmap_ pixelmap] + ((py * i) + px));
        mskip = (i - w);
    } else {
        mbmp = NULL;
        mskip = 0;
    }

    // 描画の実行
    y = [r height];
    do {
        x = w;
        do {
            if ((tbmp != NULL) && (*(tbmp) == 0)) {
                // タイルパターンで描画対象外
                ;
            } else if ((mbmp != NULL) && (*(mbmp) == 0)) {
                // 形状マスクで描画対象外
                ;
            } else if ([[self->palette_ palette:*(dbmp)] isMask]) {
                // 描画対象が上塗り禁止
                ;
            } else if ([[self->palette_ palette:*(pbmp)] noDropper]) {
                // 塗装色が使用禁止(吸い取り禁止)
                ;
            } else {
                // 描画実行
                *(dbmp) = *(pbmp);
            }

            // 次へ
            (x)--;
            (dbmp)++;
            (pbmp)++;
            if (tbmp != NULL) {
                (tbmp)++;
            }
            if (mbmp != NULL) {
                (mbmp)++;
            }
        } while (x != 0);

        // 次へ
        (y)--;
        dbmp += dskip;
        pbmp += pskip;
        if (tbmp != NULL) {
            tbmp += tskip;
        }
        if (mbmp != NULL) {
            mbmp += mskip;
        }
    } while (y != 0);

EXIT:
    [r release];
    [tpat release];
    return;
}

@end
