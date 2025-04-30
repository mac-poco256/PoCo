//
//	Pelistina on Cocoa - PoCo -
//	画像定義
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//
// wchar_t が 32bit の処理系であることに依存しているので注意
//

#import "PoCoPicture.h"

#import <wchar.h>

#import "PoCoPalette.h"
#import "PoCoLayer.h"
#import "PoCoColorPattern.h"
#import "PoCoControllerPictureLayerUnificater.h"
#import "PoCoBuffer.h"

#import "PoCoPNG.h"
#import "PoCoZlib.h"

#if 0
# define GAMACHUNK_WINDOWS
#endif  // 0

// 内部定数
#define GRID_HORI_SOLID   0x01
#define GRID_HORI_DOTTED  0x02
#define GRID_VERT_SOLID   0x04
#define GRID_VERT_DOTTED  0x08
#define GRID_NONE 0x00
#define GRID_HORI (GRID_HORI_SOLID | GRID_HORI_DOTTED)
#define GRID_VERT (GRID_VERT_SOLID | GRID_VERT_DOTTED)

static const int TRANS_GRID = 16;
static const int TRANS_GRID_HALF = (TRANS_GRID >> 1);


// ============================================================================
@implementation PoCoPicture

// ------------------------------------------------------------ class - private
//
// IHDR Chunk(ヘッダ)の読み込み
//
//  Call
//    data   : 読み込み内容
//    range  : 読み込み範囲
//    width  : 画像の幅を返す先
//    height : 画像の高さを返す先
//
//  Return
//    function : YES : 成功
//               NO  : 失敗
//    range    : 読み込み範囲
//    width    : 画像の幅
//    height   : 画像の高さ
//
+(BOOL)loadIHDRChunk:(NSData *)data
           withRange:(NSRange *)range
               width:(unsigned int *)width
              height:(unsigned int *)height
{
    BOOL result;
    PoCoPNGDecoder *png;
    unsigned char i;

    DPRINT((@"[PoCoPicture loadIHDRChunk: widthRange: width: height:]\n"));

    png = nil;

    // CHUNK を読み込み
    png = [[PoCoPNGDecoder alloc] init];
    [png loadNSData:data withRange:range];

    // CHUNK を開ける
    result = [png openChunk:(unsigned char *)("IHDR")];
    if (result != YES) {
        DPRINT((@"not IHDR Chunk.\n"));
        goto EXIT;
    }

    // 幅を取得
    result = [png readIntChunk:width];
    if (result != YES) {
        DPRINT((@"can't read width.\n"));
        goto EXIT;
    }

    // 高さを取得
    result = [png readIntChunk:height];
    if (result != YES) {
        DPRINT((@"can't read height.\n"));
        goto EXIT;
    }

    // ビット数を取得
    result = [png readByteChunk:&(i)];
    if (result != YES) {
        DPRINT((@"can't read bitdepth.\n"));
        goto EXIT;
    } else if (i != 8) {
        DPRINT((@"not support bitdepth : %d\n", i));
        result = NO;
        goto EXIT;
    }

    // カラータイプを取得
    result = [png readByteChunk:&(i)];
    if (result != YES) {
        DPRINT((@"can't read color type.\n"));
        goto EXIT;
    } else if (i != 3) {
        DPRINT((@"not support color type : %d\n", i));
        result = NO;
        goto EXIT;
    }

    // 圧縮方法を取得
    result = [png readByteChunk:&(i)];
    if (result != YES) {
        DPRINT((@"can't read compression method.\n"));
        goto EXIT;
    } else if (i != 0) {
        DPRINT((@"not support compression method : %d\n", i));
        result = NO;
        goto EXIT;
    }

    // フィルタ種別を取得
    result = [png readByteChunk:&(i)];
    if (result != YES) {
        DPRINT((@"can't read filter method.\n"));
        goto EXIT;
    } else if (i != 0) {
        DPRINT((@"not support filter method : %d\n", i));
        result = NO;
        goto EXIT;
    }

    // インターレース方法を取得
    result = [png readByteChunk:&(i)];
    if (result != YES) {
        DPRINT((@"can't read interlace method.\n"));
        goto EXIT;
    } else if (i != 0) {
        DPRINT((@"not support interlace method : %d\n", i));
        result = NO;
        goto EXIT;
    }

    // CHUNK を閉じる
    [png closeChunk];

    // 成功
    result = YES;

EXIT:
    [png release];
    return result;
}


//
// 任意の CHUNK 読み込み(ペーストボード用)
//
//  Call
//    data   : 読み込み内容
//    range  : 読み込み範囲
//    width  : 幅
//    height : 高さ
//    lyr    : 取り込んだ内容に対するレイヤー
//    plt    : 取り込んだ内容に対するパレット
//
//  Return
//    function : YES : 成功
//               NO  : 失敗
//    range    : 読み込み範囲
//    lyr      : 取り込んだ内容に対するレイヤー
//    plt      : 取り込んだ内容に対するパレット
//
+(BOOL)loadChunks:(NSData *)data
        withRange:(NSRange *)range
        sizeWidth:(unsigned int)width
       sizeHeight:(unsigned int)height
      resultLayer:(PoCoLayerBase **)lyr
    resultPalette:(PoCoPalette *)plt
{
    BOOL result;
    BOOL isContinue;
    PoCoPNGDecoder *png;

    isContinue = YES;
    png = nil;

    // PNG を走査
    png = [[PoCoPNGDecoder alloc] init];
    do {
        // CHUNK を読み込み
        result = [png loadNSData:data withRange:range];
        if (result != YES) {
            break;
        }

        // CHUNK を開ける
        [png openChunk:[png chunkName]];

        // CHUNK タイプごとに分岐
        if (memcmp([png chunkName], "iCCP", 4) == 0) {
            // iCCP CHUNK(ICC Profile)
            ;     // ペーストボードでは無視
        } else if (memcmp([png chunkName], "sRGB", 4) == 0) {
            // sRGB CHUNK(sRGB)
            ;     // ペーストボードでは無視
        } else if (memcmp([png chunkName], "gAMA", 4) == 0) {
            // gAMA CHUNK(γ補正値)
            ;     // ペーストボードでは無視
        } else if (memcmp([png chunkName], "cHRM", 4) == 0) {
            // cHRM CHUNK(色温度)
            ;     // ペーストボードでは無視
        } else if (memcmp([png chunkName], "pHYs", 4) == 0) {
            // pHYs Chunk(物理スケール)
            ;     // ペーストボードでは無視
        } else if (memcmp([png chunkName], "PLTE", 4) == 0) {
            // PLTE Chunk(パレット)
            result = [plt loadPLTEChunk:png];
        } else if (memcmp([png chunkName], "tRNS", 4) == 0) {
            // tRNS Chunk(透明)
            result = [plt loadTRNSChunk:png];
        } else if (memcmp([png chunkName], "drOP", 4) == 0) {
            // drOP Chunk(吸い取り禁止)
            result = [plt loadDROPChunk:png];
        } else if (memcmp([png chunkName], "maSK", 4) == 0) {
            // maSK Chunk(上書き禁止)
            result = [plt loadMASKChunk:png];
        } else if (memcmp([png chunkName], "cpAT", 4) == 0) {
            // cpAT Chunk(カラーパターン)
            ;     // ペーストボードでは無視
        } else if (memcmp([png chunkName], "ilAY", 4) == 0) {
            // ilAY Chunk(画像レイヤー)
            ;     // ペーストボードでは無視
        } else if (memcmp([png chunkName], "slAY", 4) == 0) {
            // slAY Chunk(文字列レイヤー)
            ;     // ペーストボードでは無視
        } else if (memcmp([png chunkName], "IDAT", 4) == 0) {
            // IDAT Chunk(画像)
            *(lyr) = [[PoCoBitmapLayer alloc]
                         initWithPNGDecoderIDAT:png
                                      sizeWidth:width
                                     sizeHeight:height];
        } else if (memcmp([png chunkName], "IEND", 4) == 0) {
            // IEND Chunk(終了)
            result = YES;               // 正常終了
            isContinue = NO;
        } else {
            // 他は全部無視
            ;
        }

        // CHUNK を閉じる
        [png closeChunk];
    } while ((isContinue) && (result));
    [png release];

    return result;
}


// ------------------------------------------------------------- class - public
//
// ペーストボードから取り込み
//
//  Call
//    data  : 読み込み内容
//    range : 読み込み範囲
//    lyr   : 取り込んだ内容に対するレイヤー
//    plt   : 取り込んだ内容に対するパレット
//
//  Return
//    function : YES : 成功
//               NO  : 失敗
//    range    : 読み込み範囲
//    lyr      : 取り込んだ内容に対するレイヤー
//    plt      : 取り込んだ内容に対するパレット
//
+(BOOL)pastePBoardData:(NSData *)data
             withRange:(NSRange *)range
           resultLayer:(PoCoLayerBase **)lyr
         resultPalette:(PoCoPalette *)plt
{
    BOOL result;
    unsigned int width;
    unsigned int height;

    DPRINT((@"[PoCoPicture pastePBoardData: withRange: resultLayer: resultPalette:]\n"));

    // IHDR CHUNK を読み込み
    result = [PoCoPicture loadIHDRChunk:data
                              withRange:range
                                  width:&(width)
                                 height:&(height)];
    if (result != YES) {
        DPRINT((@"can't load IHDR Chunk.\n"));
    } else {
        // 続きの CHUNK の読み込み
        result = [PoCoPicture loadChunks:data
                               withRange:range
                               sizeWidth:width
                              sizeHeight:height
                             resultLayer:lyr
                           resultPalette:plt];
        if (result != YES) {
            DPRINT((@"can't paste image.\n"));
        } else {
            // 正常終了
            result = YES;
        }
    }

    return result;
}


// --------------------------------------------------------- instance - private
#if 1
//
// 1マス分を描画
//
//  Call
//    imageBitmap : 対象 pixlemap
//    square      : マスの大きさ(dot 数)
//    row         : pixlemap の rowbytes
//    color       : 色
//    grid        : グリッド線の種類
//
//  Return
//    None
//
-(void)drawArea:(unsigned int *)imageBitmap
         square:(int)square
       rowBytes:(int)row
          color:(unsigned int)color
       withGrid:(unsigned char)grid
{
    int l;
    unsigned int *bmp;

    l = square;
    bmp = imageBitmap;
    do {
        // 横一列を塗りつぶす
        wmemset((wchar_t *)(bmp), color, square);

        // グリッド線(左辺)
        if ((grid & GRID_HORI) == GRID_NONE) {
            // 無し
            ;
        } else if ((grid & GRID_HORI_SOLID) == GRID_HORI_SOLID) {
            // 実線
            *(bmp) ^= 0x00ffffff;
        } else if ((l & 0x01) != 0x00) {
            // 破線
            *(bmp) ^= 0x00ffffff;
        }

        // 次へ
        (l)--;
        bmp += row;
    } while (l != 0);

    // グリッド線(下底)
    if ((grid & GRID_VERT) == GRID_NONE) {
        // 無し
        ;
    } else {
        l = square;
        bmp = imageBitmap;
        do {
            if ((grid & GRID_VERT_SOLID) == GRID_VERT_SOLID) {
                // 実線
                *(bmp) ^= 0x00ffffff;
            } else if ((l & 0x01) != 0x00) {
                // 破線
                *(bmp) ^= 0x00ffffff;
            }

            // 次へ
            (l)--;
            (bmp)++;
        } while (l != 0);
    }

    return;
}
#else   // 1
//
// 1マス分を描画
//
//  Call
//    imageBitmap : 対象 pixlemap
//    width       : マスの幅(dot 数)
//    height      : マスの高さ(dot 数)
//    row         : pixlemap の rowbytes
//    color       : 色
//    grid        : グリッド線の種類
//
//  Return
//    None
//
-(void)drawArea:(unsigned int *)imageBitmap
          width:(int)width
         height:(int)height
       rowBytes:(int)row
          color:(unsigned int)color
       withGrid:(unsigned char)grid
{
    int l;
    unsigned int *bmp;

    l = height;
    bmp = imageBitmap;
    do {
        // 横一列を塗りつぶす
        wmemset((wchar_t *)(bmp), color, width);

        // グリッド線(左辺)
        if ((grid & GRID_HORI) == GRID_NONE) {
            // 無し
            ;
        } else if ((grid & GRID_HORI_SOLID) == GRID_HORI_SOLID) {
            // 実線
            *(bmp) ^= 0x00ffffff;
        } else if ((l & 0x01) != 0x00) {
            // 破線
            *(bmp) ^= 0x00ffffff;
        }

        // 次へ
        (l)--;
        bmp += row;
    } while (l != 0);

    // グリッド線(下底)
    if ((grid & GRID_VERT) == GRID_NONE) {
        // 無し
        ;
    } else {
        l = width;
        bmp = imageBitmap;
        do {
            if ((grid & GRID_VERT_SOLID) == GRID_VERT_SOLID) {
                // 実線
                *(bmp) ^= 0x00ffffff;
            } else if ((l & 0x01) != 0x00) {
                // 破線
                *(bmp) ^= 0x00ffffff;
            }

            // 次へ
            (l)--;
            (bmp)++;
        } while (l != 0);
    }

    return;
}
#endif  // 1


//
// 取得範囲を算出
//
//  Call
//    rect   : == nil : 全取得
//             != nil : 取得したい領域
//    layer_ : 各レイヤー(instance 変数)
//
//  Return
//    function : 領域
//
-(PoCoRect *)calcViewRect:(PoCoRect *)rect
{
    PoCoRect *area;
    int i;
    const PoCoBitmap *bot = [[self->layer_ objectAtIndex:0] bitmap]; // 最背面画像

    // 取得領域の算出
    area = [[PoCoRect alloc] initLeft:0
                              initTop:0
                            initRight:[bot width]
                           initBottom:[bot height]];
    if (rect == nil) {
        // 調節なし
        ;
    } else if (area != nil) {
        // 左辺を調節
        i = [rect left];
        if (i <= 0) {
            ;
        } else if (i < [area right]) {
            [area setLeft:i];
        } else {
            [area setLeft:[area right]];
            goto EXIT;
        }

        // 上端を調節
        i = [rect top];
        if (i <= 0) {
            ;
        } else if (i < [area bottom]) {
            [area setTop:i];
        } else {
            [area setTop:[area bottom]];
            goto EXIT;
        }

        // 右辺を調節
        i = [rect right];
        if (i < 0) {
            [area setLeft:[area right]];
            goto EXIT;
        } else if (i < [area right]) {
            [area setRight:i];
        }

        // 下端を調節
        i = [rect bottom];
        if (i < 0) {
            [area setTop:[area bottom]];
        } else if (i < [area bottom]) {
            [area setBottom:i];
        }
    }

EXIT:
    return area;
}


//
// 背景描画
//
//  Call
//    image      : 表示用画像
//    rect       : 描画先の矩形枠
//    scale      : 表示倍率(0.1% 単位)
//    supplement : 表示修飾
//                 == nil : 修飾無し(表示ウィンドウ向け)
//                 != nil : 修飾あり(主ウィンドウ向け)
//
//  Return
//    image : 表示用画像
//
-(void)drawBackground:(NSBitmapImageRep *)image
             withArea:(PoCoRect *)area
            withScale:(int)scale
       withSupplement:(PoCoMainViewSupplement *)supplement
{
    unsigned int *bmp;
    long x;
    long y;
    int gx;
    int gy;

    if ((supplement == nil) ||
        (([supplement backgroundColor] & 0x00ffffff) == 0x00ffffff)) {
        // 修飾情報がなければ白背景
        memset([image bitmapData], 0xff, [image bytesPerRow] * [image pixelsHigh]);
    } else {
        // 単色
        wmemset((wchar_t *)([image bitmapData]), [supplement backgroundColor], (([image bytesPerRow] * [image pixelsHigh]) / sizeof(wchar_t)));

        // パターン
        if ([supplement isPattern]) {
            bmp = (unsigned int *)([image bitmapData]);
            y = [image pixelsHigh];
            gy = ((([area bottom] * scale) / 1000) - 1);
            do {
                x = [image pixelsWide];
                gx = (([area left] * scale) / 1000);
                do {
                    // 描画
                    if ((gx % TRANS_GRID) < TRANS_GRID_HALF) {
                        if ((gy % TRANS_GRID) < TRANS_GRID_HALF) {
                            *(bmp) = 0xffffffff;
                        }
                    } else {
                        if ((gy % TRANS_GRID) >= TRANS_GRID_HALF) {
                            *(bmp) = 0xffffffff;
                        }
                    }

                    // 次へ
                    (x)--;
                    (gx)++;
                    (bmp)++;
                } while (x != 0);

                // 次へ
                (y)--;
                (gy)--;
            } while (y != 0);
        }
    }

    return;
}


//
// 描画先 NSImageRep を生成(拡大用)
//
//  Call
//    rect        : 描画先の矩形枠
//    scale       : 表示倍率(0.1% 単位)
//    viewBuffer_ : 表示用の作業バッファ(instance 変数)
//
//  Return
//    function : 描画先の NSImageRep
//
-(NSBitmapImageRep *)createViewImageRepScaleUp:(PoCoRect *)rect
                                     withScale:(int)scale
{
    const int width = ([rect width] * scale / 1000);
    const int height = ([rect height] * scale / 1000);
    const int row = (width << 2);

    return [[NSBitmapImageRep alloc]
               initWithBitmapDataPlanes:[self->viewBuffer_ resizeBitmap:height
                                                               rowBytes:row]
                             pixelsWide:width
                             pixelsHigh:height
                          bitsPerSample:8
                        samplesPerPixel:3
                               hasAlpha:NO
                               isPlanar:NO
                         colorSpaceName:NSCalibratedRGBColorSpace
                           bitmapFormat:(NSBitmapFormat)(0)
                            bytesPerRow:row
                           bitsPerPixel:32];
}


//
// 描画先 NSImageRep を生成(縮小用)
//
//  Call
//    rect        : 描画先の矩形枠
//    scale       : 表示倍率(0.1% 単位)
//    viewBuffer_ : 表示用の作業バッファ(instance 変数)
//
//  Return
//    function : 描画先の NSImageRep
//
-(NSBitmapImageRep *)createViewImageRepScaleDown:(PoCoRect *)rect
                                       withScale:(int)scale
{
    const int adjust = (((1000 / scale) == 0) ? 0 : ((1000 / scale) - 1));
    const int width = ((([rect width] + adjust) * scale) / 1000);
    const int height = ((([rect height] + adjust) * scale) / 1000);
    const int row = (width << 2);

    return [[NSBitmapImageRep alloc]
               initWithBitmapDataPlanes:[self->viewBuffer_ resizeBitmap:height
                                                               rowBytes:row]
                             pixelsWide:width
                             pixelsHigh:height
                          bitsPerSample:8
                        samplesPerPixel:3
                               hasAlpha:NO
                               isPlanar:NO
                         colorSpaceName:NSCalibratedRGBColorSpace
                           bitmapFormat:(NSBitmapFormat)(0)
                            bytesPerRow:row
                           bitsPerPixel:32];
}


//
// 等倍画像を生成
//
//  Call
//    area            : 描画先の矩形枠
//    supplement      : 表示修飾
//                      == nil : 修飾無し(表示ウィンドウ向け)
//                      != nil : 修飾あり(主ウィンドウ向け)
//    viewBuffer_     : 表示用の作業バッファ(instance 変数)
//    layer_          : 各レイヤー(instance 変数)
//    paletteTable_[] : パレット値参照テーブル(instance 変数)
//    transTable_[]   : 透過指定参照テーブル(instance 変数)
//
//  Return
//    function : 表示用画像
//
-(NSBitmapImageRep *)createViewEvenSize:(PoCoRect *)area
                         withSupplement:(PoCoMainViewSupplement *)supplement
#if 1
{
    NSBitmapImageRep *image;            // 生成する表示用画像
    unsigned int *imageBitmap;          // image の plane 走査用
    PoCoBitmap *mask;                   // 描画済みマスク
    int maskRow;                        // mask の rowbytes
    unsigned char *maskBitmap;          // mask の plane 走査用
    int maskCount;                      // mask の残り点数
    unsigned int maskSkip;              // mask の rowbytes - 幅(次行へ)
    int srcRow;                         // 描画元画像の rowbytes
    unsigned char *srcBitmap;           // 描画元画像の plane 走査用
    unsigned int srcJump;               // 描画元画像の plane 内走査開始位置
    unsigned int srcSkip;               // 描画元画像の rowbytes - 幅(前行へ)
    int sx;                             // X 軸走査用(src)
    int sy;                             // Y 軸走査用(src)
    PoCoLayerBase *lyr;                 // 処理対象のレイヤー
    NSEnumerator *iter;                 // レイヤー走査用
    const int areaWidth = [area width];
    const int areaHeight = [area height];

    image = nil;
    mask = nil;

    // mask 管理領域を生成
    mask = [[PoCoBitmap alloc] initWidth:areaWidth
                              initHeight:areaHeight
                            defaultColor:1];
    if (mask == nil) {
        DPRINT((@"can't alloc PoCoBitmap(mask)\n"));
        goto EXIT;
    }
    maskRow = areaWidth + (areaWidth & 1);
    maskCount = areaWidth * areaHeight;
    maskSkip = maskRow - areaWidth;

    // NSBitmapImageRep を生成
    image = [[NSBitmapImageRep alloc]
                initWithBitmapDataPlanes:[self->viewBuffer_
                                             resizeBitmap:areaHeight
                                                 rowBytes:(areaWidth << 2)]
                              pixelsWide:areaWidth
                              pixelsHigh:areaHeight
                           bitsPerSample:8
                         samplesPerPixel:3
                                hasAlpha:NO
                                isPlanar:NO
                          colorSpaceName:NSCalibratedRGBColorSpace
                            bitmapFormat:(NSBitmapFormat)(0)
                             bytesPerRow:(areaWidth << 2)
                            bitsPerPixel:32];
    if (image == nil) {
        DPRINT((@"can't alloc NSBitmapImageRep\n"));
        goto EXIT;
    }

    // 下地を描画
    [self drawBackground:image
                withArea:area
               withScale:1000
          withSupplement:supplement];

    // layer_ を最後尾から順次走査
    iter = [self->layer_ reverseObjectEnumerator];
    lyr = [iter nextObject];
    srcRow = [[lyr bitmap] width];
    srcRow += (srcRow & 1);
    srcJump = ([area bottom] - 1) * srcRow + [area left];
    srcSkip = srcRow + areaWidth;
    for ( ; lyr != nil; lyr = [iter nextObject]) {
        // 非表示レイヤーなら飛ばす
        if (!([lyr isDisplay])) {
            continue;
        }

        // 内容を反映
        srcBitmap = [[lyr bitmap] pixelmap] + srcJump;
        maskBitmap = [mask pixelmap];
        imageBitmap = (unsigned int *)([image bitmapData]);
        sy = areaHeight;
        do {
            sx = areaWidth;
            do {
                if ((self->transTable_[*(srcBitmap)]) && (*(maskBitmap))) {
                    // 描画
                    *(imageBitmap) = self->paletteTable_[*(srcBitmap)];

                    // 描画済み
                    *(maskBitmap) = 0;

                    // 描画点数を更新(減点していく)
                    (maskCount)--;
                }

                // 次の点へ
                (sx)--;
                (imageBitmap)++;
                (srcBitmap)++;
                (maskBitmap)++;
            } while (sx != 0);

            // 次の行へ
            (sy)--;
            srcBitmap  -= srcSkip;
            maskBitmap += maskSkip;
        } while (sy != 0);

        // 全て描いた
        if (maskCount == 0) {
            break;
        }
    }

EXIT:
    [mask release];
    return image;
}
#else   // 1
{
    NSBitmapImageRep *image;            // 生成する表示用画像
    unsigned int *imageBitmap;          // image の plane 走査用
    unsigned int imageJump;
    unsigned int imageSkip;
    PoCoBitmap *mask;                   // 描画済みマスク
    int maskRow;                        // mask の rowbytes
    unsigned char *maskBitmap;          // mask の plane 走査用
    int maskCount;                      // mask の残り点数
    unsigned int maskSkip;              // mask の rowbytes - 幅(次行へ)
    int srcRow;                         // 描画元画像の rowbytes
    unsigned char *srcBitmap;           // 描画元画像の plane 走査用
    unsigned int srcJump;               // 描画元画像の plane 内走査開始位置
    unsigned int srcSkip;               // 描画元画像の rowbytes - 幅(前行へ)
    int sx;                             // X 軸走査用(src)
    int sy;                             // Y 軸走査用(src)
    PoCoLayerBase *lyr;                 // 処理対象のレイヤー
    NSEnumerator *iter;                 // レイヤー走査用
    const int areaWidth = [area width];
    const int areaHeight = [area height];

    image = nil;
    mask = nil;

    // mask 管理領域を生成
    mask = [[PoCoBitmap alloc] initWidth:areaWidth
                              initHeight:areaHeight
                            defaultColor:1];
    if (mask == nil) {
        DPRINT((@"can't alloc PoCoBitmap(mask)\n"));
        goto EXIT;
    }
    maskRow = areaWidth + (areaWidth & 1);
    maskCount = areaWidth * areaHeight;
    maskSkip = maskRow - areaWidth;

    // NSBitmapImageRep を生成
    image = [[NSBitmapImageRep alloc]
                initWithBitmapDataPlanes:NULL
                              pixelsWide:areaWidth
                              pixelsHigh:areaHeight
                           bitsPerSample:8
                         samplesPerPixel:3
                                hasAlpha:NO
                                isPlanar:NO
                          colorSpaceName:NSCalibratedRGBColorSpace
                            bitmapFormat:(NSBitmapFormat)(0)
                             bytesPerRow:(areaWidth << 2)
                            bitsPerPixel:32];
    if (image == nil) {
        DPRINT((@"can't alloc NSBitmapImageRep\n"));
        goto EXIT;
    }
    imageJump = [image bytesPerRow] * [image pixelsHigh];
    imageJump -= [image bytesPerRow];
#if 0
    imageSkip = (([image bytesPerRow] << 1) >> 2);
#else   // 0
    imageSkip = ([image bytesPerRow] >> 1);
#endif  // 0

    // 下地を描画
    [self drawBackground:image
                withArea:area
               withScale:1000
          withSupplement:supplement];

    // layer_ を最後尾から順次走査
    iter = [self->layer_ reverseObjectEnumerator];
    lyr = [iter nextObject];
    srcRow = [[lyr bitmap] width];
    srcRow += (srcRow & 1);
    srcJump = [area top] * srcRow + [area left];
    srcSkip = srcRow - [area right] + [area left];
    for ( ; lyr != nil; lyr = [iter nextObject]) {
        // 非表示レイヤーなら飛ばす
        if (!([lyr isDisplay])) {
            continue;
        }

        // 内容を反映
        srcBitmap = [[lyr bitmap] pixelmap] + srcJump;
        maskBitmap = [mask pixelmap];
        imageBitmap = (unsigned int *)([image bitmapData] + imageJump);
        sy = areaHeight;
        do {
            sx = areaWidth;
            do {
                if ((self->transTable_[*(srcBitmap)]) && (*(maskBitmap))) {
                    // 描画
                    *(imageBitmap) = self->paletteTable_[*(srcBitmap)];

                    // 描画済み
                    *(maskBitmap) = 0;

                    // 描画点数を更新(減点していく)
                    (maskCount)--;
                }

                // 次の点へ
                (sx)--;
                (imageBitmap)++;
                (srcBitmap)++;
                (maskBitmap)++;
            } while (sx != 0);

            // 次の行へ
            (sy)--;
            imageBitmap -= imageSkip;
            srcBitmap   += srcSkip;
            maskBitmap  += maskSkip;
        } while (sy != 0);

        // 全て描いた
        if (maskCount == 0) {
            break;
        }
    }

EXIT:
    [mask release];
    return image;
}
#endif  // 1


//
// 拡大画像を生成
//
//  Call
//    area            : 描画先の矩形枠
//    scale           : 表示倍率(0.1% 単位)
//    supplement      : 表示修飾
//                      == nil : 修飾無し(表示ウィンドウ向け)
//                      != nil : 修飾あり(主ウィンドウ向け)
//    layer_          : 各レイヤー(instance 変数)
//    paletteTable_[] : パレット値参照テーブル(instance 変数)
//    transTable_[]   : 透過指定参照テーブル(instance 変数)
//
//  Return
//    function : 表示用画像
//
-(NSBitmapImageRep *)createViewScaleUp:(PoCoRect *)area
                             withScale:(int)scale
                        withSupplement:(PoCoMainViewSupplement *)supplement
#if 1
{
    NSBitmapImageRep *image;            // 生成する表示用画像
    unsigned int *imageBitmap;          // image の plane 走査用
    int imageRow;                       // image の rowbytes
    unsigned int imageStep;             // image の step 数
    unsigned int imageSkip;             // image の次の行への移動量
    PoCoBitmap *mask;                   // 描画済みマスク
    int maskRow;                        // mask の rowbytes
    unsigned char *maskBitmap;          // mask の plane 走査用
    int maskCount;                      // mask の残り点数
    unsigned int maskSkip;              // mask の rowbytes - 幅(次行へ)
    int srcRow;                         // 描画元画像の rowbytes
    unsigned char *srcBitmap;           // 描画元画像の plane 走査用
    unsigned int srcJump;               // 描画元画像の plane 内走査開始位置
    unsigned int srcSkip;               // 描画元画像の rowbytes - 幅(前行へ)
    int sx;                             // X 軸走査用(src)
    int sy;                             // Y 軸走査用(src)
    PoCoLayerBase *lyr;                 // 処理対象のレイヤー
    NSEnumerator *iter;                 // レイヤー走査用
    const int areaWidth = [area width];
    const int areaHeight = [area height];
    int gx;
    int gy;
    unsigned char gridType;

    image = nil;
    mask = nil;

    // mask 管理領域を生成
    mask = [[PoCoBitmap alloc] initWidth:[area width]
                              initHeight:[area height]
                            defaultColor:1];
    if (mask == nil) {
        DPRINT((@"can't alloc PoCoBitmap(mask)\n"));
        goto EXIT;
    }
    maskRow = [mask width] + ([mask width] & 1);
    maskCount = [area width] * [area height];
    maskSkip = maskRow - areaWidth;

    // NSBitmapImageRep を生成
    image = [self createViewImageRepScaleUp:area
                                  withScale:scale];
    if (image == nil) {
        DPRINT((@"can't alloc NSBitmapImageRep\n"));
        goto EXIT;
    }
    imageRow = (int)([image bytesPerRow]);
    imageRow >>= 2;
    imageStep = scale / 1000;
    imageSkip = imageRow * (imageStep - 1);

    // 下地を描画
    [self drawBackground:image
                withArea:area
               withScale:scale
          withSupplement:supplement];

    // layer_ を最後尾から順次走査
    iter = [self->layer_ reverseObjectEnumerator];
    lyr = [iter nextObject];
    srcRow = [[lyr bitmap] width];
    srcRow += (srcRow & 1);
    srcJump = ([area bottom] - 1) * srcRow + [area left];
    srcSkip = srcRow + areaWidth;
    for ( ; lyr != nil; lyr = [iter nextObject]) {
        // 非表示レイヤーなら飛ばす
        if (!([lyr isDisplay])) {
            continue;
        }

        // 内容を反映
        srcBitmap = [[lyr bitmap] pixelmap] + srcJump;
        maskBitmap = [mask pixelmap];
        imageBitmap = (unsigned int *)([image bitmapData]);
        sy = areaHeight;
        gy = [area bottom];
        do {
            sx = areaWidth;
            gx = [area left];
            do {
                // グリッド線の種類を選別
                gridType = GRID_NONE;
                if ((supplement != nil) &&
                    ([supplement gridStep] > 0) &&  // 枠線無しではない
                    (scale >= 4000)) {              // ４倍以上の表示
                    // 左辺用の種別
                    if (gx > 0) {
                        gridType |= GRID_HORI_DOTTED;
                        if ((gx % [supplement gridStep]) == 0) {
                            gridType |= GRID_HORI_SOLID;
                        }
                    }

                    // 下底用の種別
                    if ((gy > 0) && (gy < [[lyr bitmap] height])) {
                        gridType |= GRID_VERT_DOTTED;
                        if ((gy % [supplement gridStep]) == 0) {
                            gridType |= GRID_VERT_SOLID;
                        }
                    }
                }

                // 不透明なら描画(上層からなので描画済みなら飛ばす)
                if ((self->transTable_[*(srcBitmap)]) && (*(maskBitmap))) {
                    // 描画
                    [self drawArea:imageBitmap
                            square:imageStep
                          rowBytes:imageRow
                             color:self->paletteTable_[*(srcBitmap)]
                          withGrid:gridType];

                    // 描画済み
                    *(maskBitmap) = 0;

                    // 描画点数を更新(減点していく)
                    (maskCount)--;
                }

                // 次の点へ
                (sx)--;
                (gx)++;
                imageBitmap += imageStep;
                (srcBitmap)++;
                (maskBitmap)++;
            } while (sx != 0);

            // 次の行へ
            (sy)--;
            (gy)--;
            imageBitmap += imageSkip;
            srcBitmap   -= srcSkip;
            maskBitmap  += maskSkip;
        } while (sy != 0);

        // 全て描いた
        if (maskCount == 0) {
            break;
        }
    }

EXIT:
    [mask release];
    return image;
}
#else   // 1
{
    NSBitmapImageRep *image;            // 生成する表示用画像
    unsigned int *imageBitmap;          // image の plane 走査用
    int imageRow;                       // image の rowbytes
    unsigned int imageStep;             // image の step 数
    unsigned int imageSkip;             // image の次の行への移動量
    int imageCnt;
    int imageErrX;
    int imageErrY;
    unsigned int imageCorrX;
    unsigned int imageCorrY;
    PoCoBitmap *mask;                   // 描画済みマスク
    int maskRow;                        // mask の rowbytes
    unsigned char *maskBitmap;          // mask の plane 走査用
    int maskCount;                      // mask の残り点数
    unsigned int maskSkip;              // mask の rowbytes - 幅(次行へ)
    int srcRow;                         // 描画元画像の rowbytes
    unsigned char *srcBitmap;           // 描画元画像の plane 走査用
    unsigned int srcJump;               // 描画元画像の plane 内走査開始位置
    unsigned int srcSkip;               // 描画元画像の rowbytes - 幅(前行へ)
    int sx;                             // X 軸走査用(src)
    int sy;                             // Y 軸走査用(src)
    PoCoLayerBase *lyr;                 // 処理対象のレイヤー
    NSEnumerator *iter;                 // レイヤー走査用
    const int areaWidth = [area width];
    const int areaHeight = [area height];
    int gx;
    int gy;
    unsigned char gridType;
    int scaleMod;

    image = nil;
    mask = nil;

    // mask 管理領域を生成
    mask = [[PoCoBitmap alloc] initWidth:[area width]
                              initHeight:[area height]
                            defaultColor:1];
    if (mask == nil) {
        DPRINT((@"can't alloc PoCoBitmap(mask)\n"));
        goto EXIT;
    }
    maskRow = ([mask width] + ([mask width] & 1));
    maskCount = ([area width] * [area height]);
    maskSkip = (maskRow - areaWidth);

    // NSBitmapImageRep を生成
    image = [self createViewImageRepScaleUp:area
                                  withScale:scale];
    if (image == nil) {
        DPRINT((@"can't alloc NSBitmapImageRep\n"));
        goto EXIT;
    }
    imageRow = (int)([image bytesPerRow]);
    imageRow >>= 2;
    imageStep = (scale / 1000);
    scaleMod = (scale % 1000);
    imageSkip = (imageRow * (imageStep - 1));

    // 下地を描画
    [self drawBackground:image
                withArea:area
               withScale:scale
          withSupplement:supplement];

    // layer_ を最後尾から順次走査
    iter = [self->layer_ reverseObjectEnumerator];
    lyr = [iter nextObject];
    srcRow = [[lyr bitmap] width];
    srcRow += (srcRow & 1);
    srcJump = ((([area bottom] - 1) * srcRow) + [area left]);
    srcSkip = (srcRow + areaWidth);
    for ( ; lyr != nil; lyr = [iter nextObject]) {
        // 非表示レイヤーなら飛ばす
        if (!([lyr isDisplay])) {
            continue;
        }

        // 内容を反映
        srcBitmap = ([[lyr bitmap] pixelmap] + srcJump);
        maskBitmap = [mask pixelmap];
        imageBitmap = (unsigned int *)([image bitmapData]);
        sy = areaHeight;
        gy = [area bottom];
        imageErrY = 0;
        imageCorrY = 0;
        do {
            imageCnt = imageRow;
            imageErrX = 0;
            imageCorrX = 0;
            sx = areaWidth;
            gx = [area left];
            do {
                // グリッド線の種類を選別
                gridType = GRID_NONE;
                if ((supplement != nil) &&
                    ([supplement gridStep] > 0) &&  // 枠線無しではない
                    (scale >= 4000)) {              // ４倍以上の表示
                    // 左辺用の種別
                    if (gx > 0) {
                        gridType |= GRID_HORI_DOTTED;
                        if ((gx % [supplement gridStep]) == 0) {
                            gridType |= GRID_HORI_SOLID;
                        }
                    }

                    // 下底用の種別
                    if ((gy > 0) && (gy < [[lyr bitmap] height])) {
                        gridType |= GRID_VERT_DOTTED;
                        if ((gy % [supplement gridStep]) == 0) {
                            gridType |= GRID_VERT_SOLID;
                        }
                    }
                }

                // 不透明なら描画(上層からなので描画済みなら飛ばす)
                if ((self->transTable_[*(srcBitmap)]) && (*(maskBitmap))) {
                    // 描画
                    [self drawArea:imageBitmap
                             width:(imageStep + imageCorrX)
                            height:(imageStep + imageCorrY)
                          rowBytes:imageRow
                             color:self->paletteTable_[*(srcBitmap)]
                          withGrid:gridType];

                    // 描画済み
                    *(maskBitmap) = 0;

                    // 描画点数を更新(減点していく)
                    (maskCount)--;
                }

                // 次の点へ
                (sx)--;
                (gx)++;
                imageBitmap += (imageStep + imageCorrX);
                (srcBitmap)++;
                (maskBitmap)++;
                imageCnt -= (imageStep + imageCorrX);
                imageErrX += scaleMod;
                if (imageErrX >= 1000) {
                    imageErrX -= 1000;
                    imageCorrX = 1;
                } else {
                    imageCorrX = 0;
                }
            } while (sx != 0);

            // 次の行へ
            (sy)--;
            (gy)--;
            imageBitmap += (imageSkip + imageCnt + (imageRow * imageCorrY));
            srcBitmap -= srcSkip;
            maskBitmap += maskSkip;
            imageErrY += scaleMod;
            if (imageErrY >= 1000) {
                imageErrY -= 1000;
                imageCorrY = 1;
            } else {
                imageCorrY = 0;
            }
        } while (sy != 0);

        // 全て描いた
        if (maskCount == 0) {
            break;
        }
    }

EXIT:
    [mask release];
    return image;
}
#endif  // 1


//
// 縮小画像を生成
//
//  Call
//    area            : 描画先の矩形枠
//    scale           : 表示倍率(0.1% 単位)
//    supplement      : 表示修飾
//                      == nil : 修飾無し(表示ウィンドウ向け)
//                      != nil : 修飾あり(主ウィンドウ向け)
//    layer_          : 各レイヤー(instance 変数)
//    paletteTable_[] : パレット値参照テーブル(instance 変数)
//    transTable_[]   : 透過指定参照テーブル(instance 変数)
//
//  Return
//    function : 表示用画像
//
-(NSBitmapImageRep *)createViewScaleDown:(PoCoRect *)area
                               withScale:(int)scale
                          withSupplement:(PoCoMainViewSupplement *)supplement
{
    #define FRAC_BIAS 1024              // 固定小数点の bias

    NSBitmapImageRep *image;            // 生成する表示用画像
    unsigned int *dp;                   // 描画先画像の走査用
    long dw;                            // 描画先画像の幅走査数
    long dh;                            // 描画先画像の高さ走査数

    PoCoBitmap *mask;                   // 描画済みマスク
    unsigned char *mp;                  // mask の走査用
    int mrow;                           // mask の rowbytes
    int mskip;                          // mask の rowbytes - 幅(次行へ)
    long long mcount;                   // mask の残り点数

    unsigned char *sp;                  // 描画元画像の走査用
    long long srow;                     // 描画元画像の rowbytes
    long long sskip;                    // 描画元画像の rowbytes - 幅(次行へ)
    long long sstep;                    // 描画元画像の step 数
    long long sfrac;                    // 描画元画像の端数(step 数の端数)
    long long sjump;                    // 描画元画像の走査開始位置
    long long sw;                       // 描画元画像の幅走査用(端数を積算)
    long long sh;                       // 描画元画像の高さ走査用(端数を積算)
    long scnt;

    PoCoLayerBase *lyr;                 // 処理対象のレイヤー
    NSEnumerator *iter;                 // レイヤー走査用
    const long width = [area width];

    image = nil;
    mask = nil;

    // NSBitmapImageRep を生成
    image = [self createViewImageRepScaleDown:area
                                    withScale:scale];
    if (image == nil) {
        DPRINT((@"can't alloc NSBitmapImageRep\n"));
        goto EXIT;
    }

    // mask 管理領域を生成
    mask = [[PoCoBitmap alloc] initWidth:(int)([image pixelsWide])
                              initHeight:(int)([image pixelsHigh])
                            defaultColor:1];
    if (mask == nil) {
        DPRINT((@"can't alloc PoCoBitmap(mask)\n"));
        goto EXIT;
    }
    mrow = ([mask width] + ([mask width] & 1));
    mcount = ([mask width] * [mask height]);
    mskip = (mrow - [mask width]);

    // 下地を描画
    [self drawBackground:image
                withArea:area
               withScale:scale
          withSupplement:supplement];

    // layer_ を最後尾から順次走査
    iter = [self->layer_ reverseObjectEnumerator];
    lyr = [iter nextObject];
    srow = [[lyr bitmap] width];
    srow += (srow & 1);
    sjump = ((([area bottom] - 1) * srow) + [area left]);
    sfrac = ((1000 * FRAC_BIAS) / (long long)(scale));
    sstep = (unsigned int)(sfrac / FRAC_BIAS);
    if (sstep == 0) {
        sstep = 1;
    }
    sfrac -= (sstep * FRAC_BIAS);
    sskip = ((srow * sstep) + width);
#if 0
printf("\n");
printf("scale     : %d\n", scale);
printf("area      : %d, %d, %d, %d(%d, %d)\n", [area left], [area top], [area right], [area bottom], [area width], [area height]);
printf("image     : %d, %d\n", [image pixelsWide], [image pixelsHigh]);
printf("mrow      : %d\n", mrow);
printf("mskip     : %d\n", mskip);
printf("mcount    : %d\n", mcount);
printf("srow      : %d\n", srow);
printf("sskip     : %d\n", sskip);
printf("sstep     : %d\n", sstep);
printf("sfrac     : %d\n", sfrac);
printf("sjump     : %d\n", sjump);
#endif  // 0
    for ( ; lyr != nil; lyr = [iter nextObject]) {
        // 非表示レイヤーなら飛ばす
        if (!([lyr isDisplay])) {
            continue;
        }

        // 内容を反映
        dp = (unsigned int *)([image bitmapData]);
        mp = [mask pixelmap];
        sp = ([[lyr bitmap] pixelmap] + sjump);
        sh = 0;
        dh = [image pixelsHigh];
        do {
            scnt = 0;
            sw = 0;
            dw = [image pixelsWide];
            do {
                if ((self->transTable_[*(sp)]) && (*(mp))) {
                    // 描画
                    *(dp) = self->paletteTable_[*(sp)];

                    // 描画済み
                    *(mp) = 0;

                    // 描画点数を更新(減点していく)
                    (mcount)--;
                }

                // 次へ
                (dw)--;
                (dp)++;
                (mp)++;
                sp += sstep;
                scnt += sstep;
                sw += sfrac;
                if (sw > FRAC_BIAS) {
                    (sp)++;
                    (scnt)++;
                    sw -= FRAC_BIAS;
                }
            } while (dw != 0);

            // 次へ
            (dh)--;
            mp += mskip;
            sp -= (sskip - (width - scnt));
            sh += sfrac;
            if (sh > FRAC_BIAS) {
                sp -= srow;
                sh -= FRAC_BIAS;
            }
        } while (dh != 0);

        // 全て描いた
        if (mcount <= 0) {
            break;
        }
    }

EXIT:
    [mask release];
    return image;
}


// -------------------------------------- instance - private - ファイル入出力系
//
// IHDR Chunk(ヘッダ)を生成
//
//  Call
//    width  : 幅
//    height : 高さ
//
//  Return
//    function : data
//
-(NSData *)createIHDRChunk:(int)width
                    height:(int)height
{
    NSData *data;
    PoCoPNGEncoder *png;

    DPRINT((@"[PoCoPicture:createIHDRChunk]\n"));

    png = [[PoCoPNGEncoder alloc] init];

    // CHUNK を生成
    [png createChunk:(unsigned char *)("IHDR")];

    // IHDR Chunk の内容を書き込み
    [png writeIntChunk:width];          // 幅
    [png writeIntChunk:height];         // 高さ
    [png writeByteChunk:8];             // 1画素のビット数
    [png writeByteChunk:3];             // カラータイプ(index color)
    [png writeByteChunk:0];             // 圧縮方法
    [png writeByteChunk:0];             // フィルタ種別
    [png writeByteChunk:0];             // インターレース種別(none interlace)

    // CHUNK を閉じる
    [png closeChunk];

    // NSData を生成
    data = [png createNSData];
    [png release];

    return data;
}


//
// iCCP Chunk(ICC Profile)を生成
//
//  Call
//    None
//
//  Return
//    function : data
//
-(NSData *)createICCPChunk
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5)
{
    static  unsigned char nm[] = {'I', 'C', 'C', ' ', 'P', 'r', 'o', 'f', 'i', 'l', 'e', 0x00};
    NSData *data;
    PoCoPNGEncoder *png;
    PoCoWErr rv;
    PoCoZlibDeflate *zlib;
    NSData *scr;

    DPRINT((@"[PoCoPicture:createICCPChunk]\n"));

    png = [[PoCoPNGEncoder alloc] init];

    // CHUNK を生成
    [png createChunk:(unsigned char *)("iCCP")];

    // 名前を設定
    [png writeChunk:nm
             length:sizeof(nm)];

    // 圧縮方法を設定
    [png writeByteChunk:0x00];

    // MainScreen の ICC Profile を取得
    scr = [[[NSScreen mainScreen] colorSpace] ICCProfileData];

    // ICC Profile を圧縮
    zlib = [[PoCoZlibDeflate alloc] init];
    rv = [zlib appendBytes:[scr bytes]
                    length:(int)([scr length])];
    if (rv < ER_OK) {
        DPRINT((@"[zlib appendBytes: length:] : %d(0x%08x)\n", rv, rv));
    } else {
        [png writeChunk:[zlib bytes]
                 length:[zlib length]];
        [zlib clearBuffer:[zlib length]];
        do {
            rv = [zlib finishData];
            if (rv < ER_OK) {
                DPRINT((@"[zlib finishData] : %d(0x%08x)\n", rv, rv));
                break;
            }
            [png writeChunk:[zlib bytes]
                     length:[zlib length]];
            [zlib clearBuffer:[zlib length]];
        } while (rv == 1);
    }
    [zlib release];

    // CHUNK を閉じる
    [png closeChunk];

    // NSData を生成
    data = [png createNSData];
    [png release];

    return data;
}
#else // MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5
{
    static  unsigned char profile[] = {
        0x49, 0x43, 0x43, 0x20, 0x50, 0x72, 0x6f, 0x66,
        0x69, 0x6c, 0x65, 0x00, 0x00, 0x78, 0x01, 0x63,
        0x60, 0x60, 0x32, 0x70, 0x74, 0x71, 0x72, 0x65,
        0x12, 0x60, 0x60, 0xc8, 0xcd, 0x2b, 0x29, 0x0a,
        0x72, 0x77, 0x52, 0x88, 0x88, 0x8c, 0x52, 0x60,
        0xbf, 0xc0, 0xc0, 0xc1, 0xc0, 0xcd, 0x20, 0xcc,
        0x60, 0xcc, 0x60, 0x9d, 0x98, 0x5c, 0x5c, 0xe0,
        0x18, 0x10, 0xe0, 0xc3, 0x00, 0x04, 0x79, 0xf9,
        0x79, 0xa9, 0x20, 0x1a, 0x15, 0x7c, 0xbb, 0xc6,
        0xc0, 0x08, 0x12, 0xb9, 0xac, 0x0b, 0x32, 0xeb,
        0xde, 0x8a, 0xe6, 0xa6, 0x1b, 0x33, 0xaf, 0x7e,
        0x7b, 0x5a, 0xbc, 0xc5, 0xc8, 0xdd, 0xea, 0xa1,
        0x05, 0xaa, 0x5a, 0x0c, 0x1e, 0x57, 0x72, 0x41,
        0x51, 0x09, 0x50, 0xf4, 0x0f, 0x10, 0x1b, 0xa5,
        0xa4, 0x16, 0x27, 0x33, 0x30, 0x30, 0x1a, 0x00,
        0xd9, 0xd9, 0xe5, 0x25, 0x05, 0x40, 0x71, 0xc6,
        0x39, 0x40, 0xb6, 0x48, 0x52, 0x36, 0x98, 0xbd,
        0x01, 0xc4, 0x2e, 0x0a, 0x09, 0x72, 0x06, 0x8a,
        0x1f, 0x01, 0xb2, 0xf9, 0xd2, 0x21, 0xec, 0x2b,
        0x20, 0x76, 0x12, 0x84, 0xfd, 0x04, 0xc4, 0x2e,
        0x02, 0x7a, 0x02, 0xa8, 0xe6, 0x0b, 0x48, 0x7d,
        0x3a, 0x98, 0xcd, 0xc4, 0x01, 0x62, 0x27, 0x41,
        0xd8, 0x32, 0x20, 0x76, 0x49, 0x6a, 0x05, 0xc8,
        0x5e, 0x06, 0xe7, 0xfc, 0x82, 0xca, 0xa2, 0xcc,
        0xf4, 0x8c, 0x12, 0x05, 0x23, 0x03, 0x03, 0x03,
        0x05, 0xc7, 0x94, 0xfc, 0xa4, 0x54, 0x85, 0xe0,
        0xca, 0xe2, 0x92, 0xd4, 0xdc, 0x62, 0x05, 0xcf,
        0xbc, 0xe4, 0xfc, 0xa2, 0x82, 0xfc, 0xa2, 0xc4,
        0x92, 0xd4, 0x14, 0xa0, 0x5a, 0x88, 0xfb, 0x40,
        0xba, 0x18, 0x04, 0x21, 0x0a, 0x41, 0x21, 0xa6,
        0x61, 0x68, 0x69, 0x69, 0xa1, 0x09, 0x16, 0xa5,
        0x22, 0x01, 0x8a, 0x07, 0x88, 0x71, 0x9f, 0x03,
        0xc1, 0xe1, 0xcb, 0x28, 0x76, 0x06, 0x21, 0x86,
        0xb0, 0x28, 0xb9, 0xb4, 0xa8, 0x0c, 0xca, 0x63,
        0x64, 0x32, 0x66, 0x60, 0x20, 0xc4, 0x47, 0x98,
        0x31, 0x47, 0x82, 0x81, 0xc1, 0x7f, 0x29, 0x03,
        0x03, 0xcb, 0x1f, 0x84, 0x98, 0x49, 0x2f, 0x03,
        0xc3, 0x02, 0x1d, 0x06, 0x06, 0xfe, 0xa9, 0x08,
        0x31, 0x35, 0x43, 0x06, 0x06, 0x01, 0x7d, 0x06,
        0x86, 0x7d, 0x73, 0x00, 0x68, 0xdb, 0x5a, 0x0e
    };

    NSData *data;
    PoCoPNGEncoder *png;

    DPRINT((@"[PoCoPicture:createICCPChunk]\n"));

    png = [[PoCoPNGEncoder alloc] init];

    // CHUNK を生成
    [png createChunk:(unsigned char *)("iCCP")];

    // iCCP Chunk の内容を書き込み
    [png writeChunk:profile length:sizeof(profile)];

    // CHUNK を閉じる
    [png closeChunk];

    // NSData を生成
    data = [png createNSData];
    [png release];

    return data;
}
#endif  // MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5


//
// sRGB Chunk(sRGB)を生成
//
//  Call
//    srgb_ : sRGB CHUNK(instance 変数)
//
//  Return
//    function : data
//
-(NSData *)createSRGBChunk
{
    NSData *data;
    PoCoPNGEncoder *png;
    unsigned char i;

    DPRINT((@"[PoCoPicture:createSRGBChunk]\n"));

    png = [[PoCoPNGEncoder alloc] init];

    // CHUNK を生成
    [png createChunk:(unsigned char *)("sRGB")];

    // sRGB Chunk の内容を書き込み
    i = self->srgb_;
    [png writeByteChunk:i];

    // CHUNK を閉じる
    [png closeChunk];

    // NSData を生成
    data = [png createNSData];
    [png release];

    return data;
}


//
// gAMA Chunk(γ補正値)を生成
//
//  Call
//    gamma_ : gAMA CHUNK(instance 変数)
//
//  Return
//    function : data
//
-(NSData *)createGAMAChunk
{
    NSData *data;
    PoCoPNGEncoder *png;

    DPRINT((@"[PoCoPicture:createGAMAChunk]\n"));

    png = [[PoCoPNGEncoder alloc] init];

    // CHUNK を生成
    [png createChunk:(unsigned char *)("gAMA")];

    // gAMA Chunk の内容を書き込み
    [png writeIntChunk:self->gamma_];

    // CHUNK を閉じる
    [png closeChunk];

    // NSData を生成
    data = [png createNSData];
    [png release];

    return data;
}


//
// cHRM Chunk(色温度)を生成
//
//  Call
//    chromakey_[] : cHRM CHUNK(instance 変数)
//
//  Return
//    function : data
//
-(NSData *)createCHRMChunk
{
    NSData *data;
    PoCoPNGEncoder *png;

    DPRINT((@"[PoCoPicture:createCHRMChunk]\n"));

    png = [[PoCoPNGEncoder alloc] init];

    // CHUNK を生成
    [png createChunk:(unsigned char *)("cHRM")];

    // cHRM Chunk の内容を書き込み
    [png writeIntChunk:self->chromakey_[0]];
    [png writeIntChunk:self->chromakey_[1]];
    [png writeIntChunk:self->chromakey_[2]];
    [png writeIntChunk:self->chromakey_[3]];
    [png writeIntChunk:self->chromakey_[4]];
    [png writeIntChunk:self->chromakey_[5]];
    [png writeIntChunk:self->chromakey_[6]];
    [png writeIntChunk:self->chromakey_[7]];

    // CHUNK を閉じる
    [png closeChunk];

    // NSData を生成
    data = [png createNSData];
    [png release];

    return data;
}


//
// bKGD Chunk(背景色)を生成
//
//  Call
//    bkgdColor_ : 背景色要素(instance 変数)
//
//  Return
//    function : data
//
-(NSData *)createBKGDChunk
{
    NSData *data;
    PoCoPNGEncoder *png;
    unsigned char i;

    DPRINT((@"[PoCoPicture:createGKGDChunk]\n"));

    png = [[PoCoPNGEncoder alloc] init];

    // CHUNK を生成
    [png createChunk:(unsigned char *)("bKGD")];

    // bKGD Chunk の内容を書き込み
    i = self->bkgdColor_;
    [png writeByteChunk:i];

    // CHUNK を閉じる
    [png closeChunk];

    // NSData を生成
    data = [png createNSData];
    [png release];

    return data;
}


//
// pHYs Chunk(物理サイズ)を生成
//
//  Call
//    h_unit_ : 水平用紙解像度(instance 変数)
//    v_unit_ : 垂直用紙解像度(instance 変数)
//
//  Return
//    function : data
//
-(NSData *)createPHYSChunk
{
    NSData *data;
    PoCoPNGEncoder *png;

    DPRINT((@"[PoCoPicture:createPHYSChunk]\n"));

    png = [[PoCoPNGEncoder alloc] init];

    // CHUNK を生成
    [png createChunk:(unsigned char *)("pHYs")];

    // pHYs Chunk の内容を書き込み
    [png writeIntChunk:(int)(floor((1000 * self->h_unit_) / 25.4))];
    [png writeIntChunk:(int)(floor((1000 * self->v_unit_) / 25.4))];
    [png writeByteChunk:1];

    // CHUNK を閉じる
    [png closeChunk];

    // NSData を生成
    data = [png createNSData];
    [png release];

    return data;
}


//
// IDAT Chunk(画像)生成のメイン
//
//  Call
//    bmp : 対象画像
//
//  Return
//    function : data
//
-(NSData *)createIDATChunkMain:(PoCoBitmap *)bmp
{
    NSData *data;
    PoCoPNGEncoder *png;
    PoCoWErr rv;
    int y;
    PoCoZlibDeflate *zlib;
    unsigned char *src;                 // 圧縮元画像の走査用
    unsigned char *line;                // 1行分のバッファ
    unsigned int row;                   // row bytes
    const unsigned int width = [bmp width];
    const unsigned int height = [bmp height];

    DPRINT((@"[PoCoPicture:createIDATChunkMain]\n"));

    data = nil;
    png = nil;
    zlib = nil;
    line = NULL;
    row = width + (width & 1);

    // 1ラインのバッファを確保
    line = (unsigned char *)(calloc(width + 1, sizeof(unsigned char)));
    if (line == NULL) {
        DPRINT((@"memory allocation error.\n"));
        goto EXIT;
    }

    // CHUNK を生成
    png = [[PoCoPNGEncoder alloc] init];
    [png createChunk:(unsigned char *)("IDAT")];

    // 画像をエンコード
    zlib = [[PoCoZlibDeflate alloc] init];
    src = [bmp pixelmap];
    for (y = 0; y < height; y++) {
        // 1ライン圧縮(filter type は常に None filter)
        memcpy(line + 1, src, width);
        rv = [zlib appendBytes:line length:(width + 1)];
        if (rv < ER_OK) {
            DPRINT((@"[zlib appendBytes length] : %d(0x%08x)\n", rv, rv));
            [png release];
            png = nil;
            goto EXIT;
        }
        [png writeChunk:[zlib bytes] length:[zlib length]];
        [zlib clearBuffer:[zlib length]];
        while (rv == 1) {
            rv = [zlib appendBytes:NULL length:0];
            if (rv < ER_OK) {
                DPRINT((@"[zlib appendBytes length] : %d(0x%08x)\n", rv, rv));
                [png release];
                png = nil;
                goto EXIT;
            }
            [png writeChunk:[zlib bytes] length:[zlib length]];
            [zlib clearBuffer:[zlib length]];
        }

        // 次の行へ
        src += row;
    }

    // 圧縮終了
    do {
        rv = [zlib finishData];
        if (rv < ER_OK) {
            DPRINT((@"[zlib finishData] : %d(0x%08x)\n", rv, rv));
            [png release];
            png = nil;
            goto EXIT;
        }
        [png writeChunk:[zlib bytes] length:[zlib length]];
        [zlib clearBuffer:[zlib length]];
    } while (rv == 1);

    // CHUNK を閉じる
    [png closeChunk];

    // NSData を生成
    data = [png createNSData];

EXIT:
    if (line != NULL) {
        free(line);
    }
    [png release];
    [zlib release];
    return data;
}


//
// IDAT Chunk(画像)を生成
//  表示画像を結合して IDAT CHUNK に格納
//
//  Call
//    None
//
//  Return
//    function : data
//
-(NSData *)createIDATChunk
{
    NSData *data;
    PoCoBitmapLayer *bmp;               // 圧縮元画像(表示統合済み画像)

    DPRINT((@"[PoCoPicture:createIDATChunk]\n"));

    // 表示レイヤーを統合した画像を生成
    bmp = [PoCoControllerPictureLayerUnificater
              createUnificatePicture:self
                             isFirst:YES];

    // IDAT Chunk を作成
    data = [self createIDATChunkMain:[bmp bitmap]];
    [bmp release];

    return data;
}


//
// IDAT Chunk(画像)を生成
//  特定のレイヤーのみを IDAT CHUNK に格納
//
//  Call
//    r      : 切り取り範囲
//    index  : 対象レイヤー
//    layer_ : 各レイヤー(instance 変数)
//
//  Return
//    function : data
//
-(NSData *)createIDATChunk:(PoCoRect *)r
                   atIndex:(int)index
{
    NSData *data;
    PoCoBitmap *bmp;                    // 圧縮元画像(表示画像)

    DPRINT((@"[PoCoPicture:createIDATChunk atIndex]\n"));

    // 対象レイヤーの表示内容取得
    bmp = [[[self->layer_ objectAtIndex:index] bitmap] getBitmap:r];

    // IDAT Chunk を作成
    data = [self createIDATChunkMain:bmp];
    [bmp release];

    return data;
}


//
// iCCP Chunk(ICC Profile)を読み込み
//  CHUNK の内容は覚えない(無視する)
//  sRGB があっても、iCCP が後なら iCCP を優先する
//  (iCCP と sRGB の両方あるのは PNG 仕様違反だけど)
//
//  Call
//    png : PNG decoder
//
//  Return
//    function   : YES : 成功
//                 NO  : 失敗
//    isUseICCP_ : iCCP 使用(instance 変数)
//
-(BOOL)loadICCPChunk:(PoCoPNGDecoder *)png
{
    // 内容は関知しない
    self->isUseICCP_ = YES;

    return YES;                         // 常時 YES
}


//
// sRGB Chunk(sRGB)を読み込み
//  iCCP があっても、sRGB が後なら sRGB を優先する
//  (iCCP と sRGB の両方あるのは PNG 仕様違反だけど)
//
//  Call
//    png : PNG decoder
//
//  Return
//    function   : YES : 成功
//                 NO  : 失敗
//    srgb_      : sRGB CHUNK(instance 変数)
//    isUseICCP_ : iCCP 使用(instance 変数)
//
-(BOOL)loadSRGBChunk:(PoCoPNGDecoder *)png
{
    BOOL result;
    unsigned char i;

    // 読み込み
    result = [png readByteChunk:&(i)];
    if (result != YES) {
        DPRINT((@"can't read sRGB CHUNK.\n"));
        goto EXIT;
    }
    self->srgb_ = i;
    self->isUseICCP_ = NO;

EXIT:
    return result;
}


//
// gAMA Chunk(γ補正値)を読み込み
//
//  Call
//    png : PNG decoder
//
//  Return
//    function : YES : 成功
//               NO  : 失敗
//    gamma_   : gAMA CHUNK(instance 変数)
//
-(BOOL)loadGAMAChunk:(PoCoPNGDecoder *)png
{
    BOOL result;
    unsigned int i;

    // 読み込み
    result = [png readIntChunk:&(i)];
    if (result != YES) {
        DPRINT((@"can't read gAMA CHUNK.\n"));
        goto EXIT;
    }
    self->gamma_ = i;

EXIT:
    return result;
}


//
// cHRM Chunk(色温度)を読み込み
//
//  Call
//    png : PNG decoder
//
//  Return
//    function     : YES : 成功
//                   NO  : 失敗
//    chromakey_[] : cHRM CHUNK(instance 変数)
//
-(BOOL)loadCHRMChunk:(PoCoPNGDecoder *)png
{
    BOOL result;
    int l;
    unsigned int i;

    result = NO;

    // 8個固定
    for (l = 0; l < 8; l++) {
        result = [png readIntChunk:&(i)];
        if (result != YES) {
            DPRINT((@"can't read cHRM[%d] CHUNK.\n", l));
            break;
        } else {
            self->chromakey_[l] = i;
        }
    }

    return result;
}


//
// bKGD Chunk(背景色)を読み込み
//
//  Call
//    png : PNG decoder
//
//  Return
//    function   : YES : 成功
//                 NO  : 失敗
//    isUseBKGD_ : 背景色使用(instance 変数)
//    bkgdColor_ : 背景色要素(instance 変数)
//
-(BOOL)loadBKGDChunk:(PoCoPNGDecoder *)png
{
    BOOL result;
    unsigned char i;

    // bKGD 使用にする
    self->isUseBKGD_ = YES;

    // 色要素を取得
    result = [png readByteChunk:&(i)];
    if (result) {
        self->bkgdColor_ = i;
    }

    return result;
}


//
// pHYs Chunk(物理サイズ)を読み込み
//
//  Call
//    png : PNG decoder
//
//  Return
//    function : YES : 成功
//               NO  : 失敗
//    h_unit_  : 水平用紙解像度(instance 変数)
//    v_unit_  : 垂直用紙解像度(instance 変数)
//
-(BOOL)loadPHYSChunk:(PoCoPNGDecoder *)png
{
    BOOL result;
    unsigned int i;

    // 水平解像度を取得
    result = [png readIntChunk:&(i)];
    if (result != YES) {
        goto EXIT;
    }
    self->h_unit_ = (int)(floor(((float)(i) * 25.4) / (float)(1000.0) + (float)(0.5)));

    // 垂直解像度を取得
    result = [png readIntChunk:&(i)];
    if (result != YES) {
        goto EXIT;
    }
    self->v_unit_ = (int)(floor(((float)(i) * 25.4) / (float)(1000.0) + (float)(0.5)));

EXIT:
    return result;
}


//
// 任意の CHUNK 読み込み
//  基本的に IDAT Chunk は無視
//  ただし、ilAY/slAY が 1つもなかったから画像レイヤーに読み替える
//
//  Call
//    data      : 読み込み内容
//    range     : 読み込み範囲
//    width     : 幅
//    height    : 高さ
//    colpat_[] : カラーパターン(instance 変数)
//
//  Return
//    function  : YES : 成功
//                NO  : 失敗
//    range     : 読み込み範囲
//    colpat_[] : カラーパターン(instance 変数)
//
-(BOOL)loadChunks:(NSData *)data
        withRange:(NSRange *)range
        sizeWidth:(unsigned int)width
       sizeHeight:(unsigned int)height
{
    BOOL result;
    int cpat;                           // カラーパターンの個数
    BOOL isContinue;
    BOOL isNoExistLayer;
    PoCoPNGDecoder *png;
    PoCoLayerBase *lyr;

    png = nil;
    isContinue = YES;
    isNoExistLayer = YES;
    cpat = 0;

    png = [[PoCoPNGDecoder alloc] init];
    do {
        // CHUNK を読み込み
        result = [png loadNSData:data withRange:range];
        if (result != YES) {
            break;
        }

        // CHUNK を開ける
        [png openChunk:[png chunkName]];

        // CHUNK タイプごとに分岐
        if (memcmp([png chunkName], "iCCP", 4) == 0) {
            // iCCP CHUNK(ICC Profile)
            result = [self loadICCPChunk:png];
        } else if (memcmp([png chunkName], "sRGB", 4) == 0) {
            // sRGB CHUNK(sRGB)
            result = [self loadSRGBChunk:png];
        } else if (memcmp([png chunkName], "gAMA", 4) == 0) {
            // gAMA CHUNK(γ補正値)
            result = [self loadGAMAChunk:png];
        } else if (memcmp([png chunkName], "cHRM", 4) == 0) {
            // cHRM CHUNK(色温度)
            result = [self loadCHRMChunk:png];
        } else if (memcmp([png chunkName], "pHYs", 4) == 0) {
            // pHYs Chunk(物理スケール)
            result = [self loadPHYSChunk:png];
        } else if (memcmp([png chunkName], "PLTE", 4) == 0) {
            // PLTE Chunk(パレット)
            result = [self->palette_ loadPLTEChunk:png];
        } else if (memcmp([png chunkName], "tRNS", 4) == 0) {
            // tRNS Chunk(透明)
            result = [self->palette_ loadTRNSChunk:png];
        } else if (memcmp([png chunkName], "drOP", 4) == 0) {
            // drOP Chunk(吸い取り禁止)
            result = [self->palette_ loadDROPChunk:png];
        } else if (memcmp([png chunkName], "maSK", 4) == 0) {
            // maSK Chunk(上書き禁止)
            result = [self->palette_ loadMASKChunk:png];
        } else if (memcmp([png chunkName], "bKGD", 4) == 0) {
            // bKGD CHUNK(背景色)
            result = [self loadBKGDChunk:png];
        } else if (memcmp([png chunkName], "cpAT", 4) == 0) {
            // cpAT Chunk(カラーパターン)
            if (cpat < COLOR_PATTERN_NUM) {
                result = [self->colpat_[cpat] loadCPATChunk:png];
                cpat++;
            }
        } else if (memcmp([png chunkName], "ilAY", 4) == 0) {
            // ilAY Chunk(画像レイヤー)
            lyr = [[PoCoBitmapLayer alloc] initWithPNGDecoder:png];
            if (lyr == nil) {
                result = NO;
            } else {
                [self insertLayer:-1 layer:lyr];
                isNoExistLayer = NO;
            }
            [lyr release];
        } else if (memcmp([png chunkName], "slAY", 4) == 0) {
            // slAY Chunk(文字列レイヤー)
            lyr = [[PoCoStringLayer alloc] initWithPNGDecoder:png];
            if (lyr == nil) {
                result = NO;
            } else {
                [self insertLayer:-1 layer:lyr];
                isNoExistLayer = NO;
            }
            [lyr release];
        } else if (memcmp([png chunkName], "IDAT", 4) == 0) {
            // IDAT Chunk(画像)
            if (isNoExistLayer) {
                lyr = [[PoCoBitmapLayer alloc]
                          initWithPNGDecoderIDAT:png
                                       sizeWidth:width
                                      sizeHeight:height];
                if (lyr == nil) {
                    result = NO;
                } else {
                    [self insertLayer:-1 layer:lyr];
                    isNoExistLayer = NO;
                }
                [lyr release];
            }
        } else if (memcmp([png chunkName], "IEND", 4) == 0) {
            // IEND Chunk(終了)
            result = YES;               // 正常終了
            isContinue = NO;
        } else {
            // 他は全部無視
            ;
        }

        // CHUNK を閉じる
        [png closeChunk];
    } while ((isContinue) && (result));
    [png release];

    return result;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    dpi             : 解像度
//    paletteTable_[] : パレット値テーブル(instance 変数)
//    transTable_[]   : 透過指定テーブル(instance 変数)
//
//  Return
//    palette_     : パレット(instance 変数)
//    layer_       : 各レイヤー(instance 変数)
//    colpat_[]    : カラーパターン(instance 変数)
//    viewBuffer_  : 表示用の作業バッファ(instance 変数)
//    h_unit_      : 水平用紙解像度(instance 変数)
//    v_unit_      : 垂直用紙解像度(instance 変数)
//    isUseBKGD_   : 背景色使用(instance 変数)
//    bkgdColor_   : 背景色番号(instance 変数)
//    isUseICCP_   : iCCP 使用(instance 変数)
//    gamma_       : gAMA CHUNK(instance 変数)
//    chromakey_[] : cHRM CHUNK(instance 変数)
//    srgb_        : sRGB CHUNK(instance 変数)
//
-(id)init:(int)dpi
{
    int l;

    DPRINT((@"[PoCoPicture init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->palette_ = nil;
        self->layer_ = nil;
        for (l = 0; l < COLOR_PATTERN_NUM; l++) {
            self->colpat_[l] = nil;
        }
        self->h_unit_ = dpi;
        self->v_unit_ = dpi;
        self->isUseBKGD_ = NO;
        self->bkgdColor_ = 255;
        self->isUseICCP_ = NO;
#ifdef  GAMACHUNK_WINDOWS
        self->gamma_ = 45455;           // 1 / 2.2(Windows)
#else   // GAMACHUNK_WINDOWS
        self->gamma_ = 55556;           // 1 / 1.8(Mac)
#endif  // GAMACHUNK_WINDOWS
        self->chromakey_[0] = 31270;
        self->chromakey_[1] = 32900;
        self->chromakey_[2] = 64000;
        self->chromakey_[3] = 33000;
        self->chromakey_[4] = 30000;
        self->chromakey_[5] = 60000;
        self->chromakey_[6] = 15000;
        self->chromakey_[7] = 6000;
        self->srgb_ = 0;

        // 各 class の実体を生成
        self->palette_ = [[PoCoPalette alloc] initWithTable:self->paletteTable_
                                                  withTrans:self->transTable_];
        if (self->palette_ == nil) {
            DPRINT((@"PoCoPalette init error.\n"));
            [self release];
            self = nil;
            goto EXIT;
        }
        self->layer_ = [[NSMutableArray alloc] init];
        if (self->layer_ == nil) {
            DPRINT((@"NSMutableArray init error.\n"));
            [self release];
            self = nil;
            goto EXIT;
        }

        // カラーパターンの生成
        for (l = 0; l < COLOR_PATTERN_NUM; l++) {
            self->colpat_[l] = [[PoCoColorPattern alloc] initWidth:16
                                                        initHeight:16
                                                      defaultColor:l];
            if (self->colpat_[l] == nil) {
                DPRINT((@"PoCoColorPattern(%d) init error.\n", l));
                [self release];
                self = nil;
                goto EXIT;
            }
        }

        // 表示用の作業バッファを生成
        self->viewBuffer_ = [[PoCoBuffer alloc] init];
        if (self->viewBuffer_ == nil) {
            DPRINT((@"PoCoBuffer init error.\n"));
            [self release];
            self = nil;
            goto EXIT;
        }
    }

EXIT:
    return self;
}


//
// deallocate
//
//  Call
//    None
//
//  Return
//    palette_    : パレット(instance 変数)
//    layer_      : 各レイヤー(instance 変数)
//    colpat_[]   : カラーパターン(instance 変数)
//    viewBuffer_ : 表示用の作業バッファ(instance 変数)
//
-(void)dealloc
{
    int l;

    DPRINT((@"[PoCoPicture dealloc]\n"));

    // 管理下のレイヤーを削除
    [self deleteLayer:-1];

    // カラーパターンの解放
    for (l = 0; l < COLOR_PATTERN_NUM; l++) {
        [self->colpat_[l] release];
        self->colpat_[l] = nil;
    }

    // member の解放
    [self->viewBuffer_ release];
    [self->palette_ release];
    [self->layer_ release];

    self->layer_ = nil;
    self->palette_ = nil;
    self->viewBuffer_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// レイヤーを追加
//  この method は常に画像レイヤーのみ追加する
//  レイヤーがない場合は、常に追加になる(index は無視/w と h は必須)
//  レイヤーがある場合は、w と h は無視(最下層レイヤーのものを使用)
//
//  Call
//    index  : >= 0 : 挿入場所(終端以上なら追加になる)
//             <  0 : 終端に追加
//    w      : 画像幅(dot)(レイヤーがない場合のみ必要)
//    h      : 画像高さ(dot)(レイヤーがない場合のみ必要)
//    c      : 色
//    layer_ : 各レイヤー(instance 変数)
//
//  Return
//    function : error code
//    layer_    : 各レイヤー(instance 変数)
//
-(PoCoErr)addLayer:(int)index
             width:(int)w
            height:(int)h
             color:(unsigned char)c
{
    PoCoErr er;
    PoCoLayerBase *lyr;                 // 追加するレイヤー

    er = ER_OK;

    // 幅/高さの算出・追加/挿入の判定
    if ([self->layer_ count] > 0) {
        w = [[[self->layer_ objectAtIndex:0] bitmap] width];
        h = [[[self->layer_ objectAtIndex:0] bitmap] height];
    }

    // 空レイヤーを新規生成
    lyr = [[PoCoBitmapLayer alloc] initWidth:w
                                  initHeight:h
                                defaultColor:c];
    if (lyr == nil) {
        DPRINT((@"can't create new layer.\n"));
        er = ER_ADDLAYER;
    } else {
        // レイヤーを追加
        [self insertLayer:index layer:lyr];
    }
    [lyr release];

    return er;
}


//
// 文字列レイヤーを追加
//
//  Call
//    index  : >= 0 : 挿入場所(終端以上なら追加になる)
//             <  0 : 終端に追加
//    c      : 色
//    layer_ : 各レイヤー(instance 変数)
//
//  Return
//    function : error code
//    layer_    : 各レイヤー(instance 変数)
//
-(PoCoErr)addStringLayer:(int)index
                   color:(unsigned char)c
{
    PoCoErr er;
    int w;
    int h;
    PoCoLayerBase *lyr;                 // 追加するレイヤー

    er = ER_OK;

    // 幅/高さの算出・追加/挿入の判定
    w = [[[self->layer_ objectAtIndex:0] bitmap] width];
    h = [[[self->layer_ objectAtIndex:0] bitmap] height];

    // 空レイヤーを新規生成
    lyr = [[PoCoStringLayer alloc] initWidth:w
                                  initHeight:h
                                defaultColor:c];
    if (lyr == nil) {
        DPRINT((@"can't create new string layer.\n"));
        er = ER_ADDLAYER;
    } else {
        // レイヤーを追加
        [self insertLayer:index layer:lyr];
    }
    [lyr release];

    return er;
}


//
// レイヤーを削除
//
//  Call
//    index  : >= 0 : 削除対象番号
//             <  0 : 全削除
//    layer_ : 各レイヤー(instance 変数)
//
//  Return
//    layer_ : 各レイヤー(instance 変数)
//
-(void)deleteLayer:(int)index
{
    if (index < 0) {
        // 全削除
        [self->layer_ removeAllObjects];
    } else if ((unsigned int)(index) < [self->layer_ count]) {
        [self->layer_ removeObjectAtIndex:(unsigned int)(index)];
    }

    return;
}


//
// 参照(全取得)
//
//  Call
//    layer_ : 各レイヤー(instance 変数)
//
//  Return
//    function : レイヤー
//
-(NSMutableArray *)layer
{
    return self->layer_;
}


//
// 参照(単一取得)
//
//  Call
//    index : 層番号
//    layer_ : 各レイヤー(instance 変数)
//
//  Return
//    function : 対象レイヤー
//
-(id)layer:(int)index
{
    return [self->layer_ objectAtIndex:index];
}


//
// レイヤー挿入
//
//  Call
//    index    : <  0 : 末尾
//               >= 0 : 任意位置
//    lyr      : 挿入レイヤー
//    palette_ : パレット(instance 変数)
//
//  Return
//    layer_ : 各レイヤー(instance 変数)
//
-(void)insertLayer:(int)index
             layer:(PoCoLayerBase *)lyr
{
    const unsigned int cnt = (int)([self->layer_ count]);

    if ((cnt <= 0) || (index < 0) || (index >= cnt)) {
        [self->layer_ addObject:lyr];
    } else {
        [self->layer_ insertObject:lyr atIndex:(unsigned int)(index)];
    }

    // 見本を生成
    [lyr updatePreview:self->palette_];

    return;
}


//
// レイヤー見本更新
//
//  Call
//    index    : <  0 : 全更新
//               >= 0 : 特定レイヤーのみ更新
//    layer_   : 各レイヤー(instance 変数)
//    palette_ : パレット(instance 変数)
//
//  Return
//    None
//
-(void)updateLayerPreview:(int)index
{
    PoCoLayerBase *lyr;

    // 対象レイヤーの取得
    lyr = ((index >= 0) ? [self->layer_ objectAtIndex:index] : nil);
    if (lyr != nil) {
        // 特定レイヤーのみの更新
        [lyr updatePreview:self->palette_];
    } else {
        // 全更新(パレットの更新とやることは同じ)
        [self didUpdatePalette];
    }

    return;
}


//
// 画像サイズの取得
//  先頭レイヤーの大きさを NSRect に読み替えるだけ
//
//  Call
//    layer_ : 各レイヤー(instance 変数)
//
//  Return
//    function : 大きさ
//
-(NSRect)bitmapRect
{
    NSRect r;

    r.origin.x = 0;
    r.origin.y = 0;
    r.size.width = [[[self->layer_ objectAtIndex:0] bitmap] width];
    r.size.height = [[[self->layer_ objectAtIndex:0] bitmap] height];

    return r;
}


//
// 画像サイズの取得
//  新規の PoCoRect で返す
//
//  Call
//    layer_ : 各レイヤー(instance 変数)
//
//  Return
//    function : 大きさ
//
-(PoCoRect *)bitmapPoCoRect
{
    PoCoRect *r;

    r = [[PoCoRect alloc] initLeft:0
                           initTop:0
                         initRight:[[[self->layer_ objectAtIndex:0] bitmap] width]
                        initBottom:[[[self->layer_ objectAtIndex:0] bitmap] height]];

    return r;
}


//
// 主ウィンドウの表示用画像の取得
//  部分取得
//
//  Call
//    rect       : == nil : 全取得
//                 != nil : 取得したい領域
//    scale      : 表示倍率(0.1% 単位)
//    supplement : 表示修飾
//                 == nil : 修飾無し(表示ウィンドウ向け)
//                 != nil : 修飾あり(主ウィンドウ向け)
//
//  Return
//    function : 画像
//
-(NSBitmapImageRep *)getMainImage:(PoCoRect *)rect
                        withScale:(int)scale
                   withSupplement:(PoCoMainViewSupplement *)supplement
{
    NSBitmapImageRep *image;
    PoCoRect *area;

    image = nil;

    // 取得領域の算出
    area = [self calcViewRect:rect];
    if (!([area empty])) {
        // 画像を生成
        if (scale == 1000) {
            image = [self createViewEvenSize:area
                              withSupplement:supplement];
        } else if (scale > 1000) {
            image = [self createViewScaleUp:area
                                  withScale:scale
                             withSupplement:supplement];
        } else {
            image = [self createViewScaleDown:area
                                    withScale:scale
                               withSupplement:supplement];
        }
    }
    [area release];

    return image;
}


//
// 特定点の色を取得
//
//  Call
//    p      : 点(画像内座標)
//    index  : 対象レイヤー番号
//    layer_ : 各レイヤー(instance 変数)
//
//  Return
//    function : 色番号
//
-(int)pointColor:(PoCoPoint *)p
         atIndex:(int)index
{
    int num;
    PoCoBitmap *bmp;
    PoCoLayerBase *lyr;
    unsigned char *pixmap;

    num = 0;
    lyr = [self->layer_ objectAtIndex:index];
    if (lyr != nil) {
        bmp = [lyr bitmap];
        pixmap = [bmp pixelmap];
        if (pixmap != NULL) {
            num = pixmap[([p y] * ([bmp width] + ([bmp width] & 1))) + [p x]];
        }
    }

    return num;
}


//
// パレットの取得
//
//  Call
//    palette_ : パレット(instance 変数)
//
//  Return
//    function : パレット
//
-(PoCoPalette *)palette
{
    return self->palette_;
}


//
// パレット更新通知
//
//  Call
//    layer_   : 各レイヤー(instance 変数)
//    palette_ : パレット  (instance 変数)
//
//  Return
//    None
//
-(void)didUpdatePalette
{
    NSEnumerator *iter;
    PoCoLayerBase *lyr;

    iter = [self->layer_ objectEnumerator];
    lyr = [iter nextObject];
    for ( ;lyr != nil; lyr = [iter nextObject]) {
        [lyr updatePreview:self->palette_];
    }

    return;
}


//
// 表示参照用テーブルを退避
//
//  Call
//    paletteTable_[] : パレット値テーブル(instance 変数)
//    transTable_[]   : 透過指定テーブル(instance 変数)
//
//  Return
//    shadowPaletteTable_[] : パレット値テーブル(instance 変数)
//    shadowTransTable_[]   : 透過指定テーブル(instance 変数)
//
-(void)pushPaletteTable
{
    memcpy(self->shadowPaletteTable_, self->paletteTable_, sizeof(wchar_t) * COLOR_MAX);
    memcpy(self->shadowTransTable_, self->transTable_, sizeof(BOOL) * COLOR_MAX);

    return;
}


//
// 表示参照用テーブルを進出
//
//  Call
//    shadowPaletteTable_[] : パレット値テーブル(instance 変数)
//    shadowTransTable_[]   : 透過指定テーブル(instance 変数)
//
//  Return
//    paletteTable_[] : パレット値テーブル(instance 変数)
//    transTable_[]   : 透過指定テーブル(instance 変数)
//
-(void)popPaletteTable
{
    memcpy(self->paletteTable_, self->shadowPaletteTable_, sizeof(wchar_t) * COLOR_MAX);
    memcpy(self->transTable_, self->shadowTransTable_, sizeof(BOOL) * COLOR_MAX);

    return;
}


//
// カラーパターンの取得
//
//  Call
//    index     : パターン番号
//    colpat_[] : カラーパターン(instance 変数)
//
//  Return
//    function カラーパターン
//
-(PoCoColorPattern *)colpat:(int)index
{
    return (((index >= 0) && (index < COLOR_PATTERN_NUM)) ? self->colpat_[index] : nil);
}


//
// カラーパターンの更新
//
//  Call
//    index : パターン番号
//    pat   : パターン
//
//  Return
//    colpat_[] : カラーパターン(instance 変数)
//
-(void)setColpat:(int)index
         pattern:(PoCoColorPattern *)pat
{
    if ((index >= 0) && (index < COLOR_PATTERN_NUM)) {
        [self->colpat_[index] release];
        self->colpat_[index] = pat;
        [self->colpat_[index] retain];
    }

    return;
}


// --------------------------------------- instance - public - 補助情報入出力系
//
// pHYs 取得(水平解像度)
//
//  Call
//    h_unit_ : 水平用紙解像度(instance 変数)
//
//  Return
//    function : 設定値(TAD 準拠値)
//
-(int)h_unit
{
    return self->h_unit_;
}


//
// pHYs 取得(垂直解像度)   
//
//  Call
//    v_unit_ : 垂直用紙解像度(instance 変数)
//
//  Return
//    function : 設定値(TAD 準拠値)
//
-(int)v_unit
{
    return self->v_unit_;
}


//
// iCCP 使用取得
//
//  Call
//    isUseICCP_ : iCCP 使用(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)isUseICCP
{
    return self->isUseICCP_;
}


//
// bKGD CHUNK 取得
//
//  Call
//    idx        : 色要素の格納先
//                 != NULL : 取得先
//                 == NULL : 取得しない
//    isUseBKGD_ : 背景色使用(instance 変数)
//    bkgdColor_ : 背景色要素(instance 変数)
//
//  Return
//    function : 背景色使用
//    idx      : 色要素
//
-(BOOL)bkgdColor:(unsigned int *)idx
{
    if (idx != NULL) {
        *(idx) = self->bkgdColor_;
    }

    return self->isUseBKGD_;
}


//
// gAMA CHUNK 取得
//
//  Call
//    gamma_ : gAMA CHUNK(instance 変数)
//
//  Return
//    function : 設定内容
//
-(unsigned int)gamma
{
    return self->gamma_;
}


//
// cHRM CHUNK 取得
//
//  Call
//    chromakey_[] : cHRM CHUNK(instance 変数)
//
//  Return
//    function : 設定内容(配列数は 8 固定)
//
-(const unsigned int *)chromakey
{
    return self->chromakey_;
}


//
// sRGB CHUNK 取得
//
//  Call
//    srgb_ : sRGB CHUNK(instance 変数)
//
//  Return
//    function : 設定内容
//
-(unsigned int)srgb
{
    return self->srgb_;
}


//
// pHYs CHUNK 設定
//
//  Call
//    h : 水平解像度
//    v : 垂直解像度
//
//  Return
//    h_unit_ : 水平用紙解像度(instance 変数)
//    v_unit_ : 垂直用紙解像度(instance 変数)
//
-(void)setHUnit:(int)h
      withVUnit:(int)v
{
    self->h_unit_ = h;
    self->v_unit_ = v;

    return;
}

//
// bKGD CHUNK 設定
//
//  Call
//    flg : 背景色指定
//    idx : 色番号
//          (flg の YES/NO によらず設定可能)
//
//  Return
//    isUseBKGD_ : 背景色使用(instance 変数)
//    bkgdColor_ : 背景色要素(instance 変数)
//
-(void)setBKGD:(BOOL)flg
     withIndex:(unsigned int)idx
{
    self->isUseBKGD_ = flg;
    self->bkgdColor_ = idx;

    return;
}


//
// iCCP 使用設定
//
//  Call
//    flag : 設定内容
//           YES : 色補正情報は iCCP CHUNK のみ
//           NO  : 色補正情報に iCCP CHUNK 以外を使用
//
//  Return
//    isUseICCP_ : iCCP 使用(instance 変数)
//
-(void)setUseICCP:(BOOL)flag
{
    self->isUseICCP_ = flag;

    return;
}


//
// gAMA CHUNK 設定
//
//  Call
//    val : 設定内容
//
//  Return
//    gamma_ : gAMA CHUNK(instance 変数)
//
-(void)setGamma:(unsigned int)val
{
    self->gamma_ = val;

    return;
}


//
// cHRM CHUNK 設定
//
//  Call
//    val: 設定内容(配列数は 8 固定)
//
//  Return
//    chromakey_[] : cHRM CHUNK(instance 変数)
//
-(void)setChromakey:(const unsigned int *)val
{
    unsigned int l;

    for (l = 0; l < 8; l++) {
        self->chromakey_[l] = val[l];
    }

    return;
}


//
// sRGB CHUNK 設定
//
//  Call
//    val : 設定内容
//
//  Return
//    srgb_ : sRGB CHUNK(instance 変数)
//
-(void)setSrgb:(unsigned int)val
{
    self->srgb_ = val;

    return;
}


// ----------------------------------------- instance - public - ファイル操作系
//
// 保存
//
//  Call
//    toAlpha    : grayscale を不透明度とするか
//    palette_   : パレット(instance 変数)
//    colpat_[]  : カラーパターン(instance 変数)
//    layer_     : 各レイヤー(instance 変数)
//    isUseBKGD_ : 背景色使用(instance 変数)
//    isUseICCP_ : iCCP 使用(instance 変数)
//
//  Return
//    function : data
//
-(NSData *)createFileData:(BOOL)toAlpha
{
    NSMutableData *data;
    int l;
    NSEnumerator *iter;
    PoCoLayerBase *lyr;

    DPRINT((@"[PoCoPicture createFileData]\n"));

    data = [NSMutableData data];

    // IHDR Chunk を作成
    lyr = [self->layer_ objectAtIndex:0];
    [data appendData:[self createIHDRChunk:[[lyr bitmap] width]
                                    height:[[lyr bitmap] height]]];

    // 色補正 CHUNK 群を生成
    if (self->isUseICCP_) {
        // iCCP CHUNK を生成
        [data appendData:[self createICCPChunk]];
    } else {
        // sRGB CHUNK を生成
        [data appendData:[self createSRGBChunk]];

        // gAMA CHUNK を作成
        [data appendData:[self createGAMAChunk]];

        // cHRM CHUNK を生成
        [data appendData:[self createCHRMChunk]];
    }

    // pHYs CHUNK を生成
    [data appendData:[self createPHYSChunk]];

    // パレット関連の CHUNK を作成
    [data appendData:[self->palette_ createFileData:toAlpha]];

    // bKGD CHUNK を生成
    if (self->isUseBKGD_) {
        [data appendData:[self createBKGDChunk]];
    }

    // カラーパターンの CHUNK を作成
    for (l = 0; l < COLOR_PATTERN_NUM; l++) {
        [data appendData:[self->colpat_[l] createFileData]];
    }

    // 各レイヤーごとの CHUNK を作成
    iter = [self->layer_ objectEnumerator];
    lyr = [iter nextObject];
    for ( ;lyr != nil; lyr = [iter nextObject]) {
        [data appendData:[lyr createFileData]];
    }

    // IDAT Chunk を作成
    [data appendData:[self createIDATChunk]];

    return data;
}


//
// 読み込み
//
//  Call
//    data  : 読み込み内容
//    range : 読み込み範囲
//
//  Return
//    function : YES : 成功
//               NO  : 失敗
//    range    : 読み込み範囲
//
-(BOOL)loadFileData:(NSData *)data
          withRange:(NSRange *)range
{
    BOOL result;
    unsigned int width;
    unsigned int height;

    DPRINT((@"[PoCoPicture loadFIleData: withRange:]\n"));

    // [MyDocument init] で作ったレイヤーを破棄
    [self deleteLayer:0];

    // IHDR CHUNK を読み込み
    result = [PoCoPicture loadIHDRChunk:data
                              withRange:range
                                  width:&(width)
                                 height:&(height)];
    if (result != YES) {
        DPRINT((@"can't load IHDR Chunk.\n"));
        goto EXIT;
    }

    // 続きの CHUNK の読み込み
    result = [self loadChunks:data
                    withRange:range
                    sizeWidth:width
                   sizeHeight:height];
    if (result != YES) {
        DPRINT((@"can't load file.\n"));
        goto EXIT;
    }

    // 成功
    result = YES;

EXIT:
    return result;
}


// ---------------------------------------- instance - public - Pasteboard 関連
//
// ペーストボードへ貼り付け
//
//  Call
//    r          : 切り取り範囲
//    index      : 対象レイヤー
//    toAlpha    : grayscale を不透明度とするか
//    palette_   : パレット(instance 変数)
//    isUseICCP_ : iCCP 使用(instance 変数)
//
//  Return
//    function : data
//
-(NSData *)createPBoardData:(PoCoRect *)r
                    atIndex:(int)index
                    toAlpha:(BOOL)toAlpha
{
    NSMutableData *data;
#if 0   // カラーパターンは除外(090922)
    int l;
#endif  // 0

    DPRINT((@"[PoCoPicture createPBoardData]\n"));

    data = [NSMutableData data];

    // IHDR Chunk を作成
    [data appendData:[self createIHDRChunk:[r width] height:[r height]]];

    // 色補正 CHUNK 群を生成
    if (self->isUseICCP_) {
        // iCCP CHUNK を生成
        [data appendData:[self createICCPChunk]];
    } else {
        // sRGB CHUNK を生成
        [data appendData:[self createSRGBChunk]];

        // gAMA CHUNK を作成
        [data appendData:[self createGAMAChunk]];

        // cHRM CHUNK を生成
        [data appendData:[self createCHRMChunk]];
    }

    // pHYs CHUNK を生成
    [data appendData:[self createPHYSChunk]];

    // パレット関連の CHUNK を作成
    [data appendData:[self->palette_ createFileData:toAlpha]];

#if 0   // カラーパターンは除外(090922)
    // カラーパターンの CHUNK を作成
    for (l = 0; l < COLOR_PATTERN_NUM; l++) {
        [data appendData:[self->colpat_[l] createFileData]];
    }
#endif  // 0

    // IDAT Chunk を作成
    [data appendData:[self createIDATChunk:r
                                   atIndex:index]];

    return data;
}

@end
