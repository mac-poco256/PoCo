//
//	Pelistina on Cocoa - PoCo -
//	カラーパターン
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoColorPattern.h"

#import "PoCoLayer.h"
#import "PoCoPalette.h"
#import "PoCoPNG.h"

// ============================================================================
@implementation PoCoColorPattern

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function : 実体
//
-(id)init
{
//    DPRINT((@"[PoCoColorPattern init]\n"));

    return [self initWidth:0 initHeight:0 defaultColor:0];
}


//
// initialize
//
//  Call
//    w : 幅
//    h : 高さ
//    c : 初期色
//
//  Return
//    function : 実体
//
-(id)initWidth:(int)w
    initHeight:(int)h
  defaultColor:(unsigned char)c
{
    PoCoBitmap *bmp;

//    DPRINT((@"[PoCoColorPattern initWidth:%d initHeight:%d defaultColor:%d]\n", w, h, c));

    bmp = [[PoCoBitmap alloc] initWidth:w
                             initHeight:h
                           defaultColor:c];
    self = [self initWithBitmap:bmp];
    [bmp release];

    return self;
}


//
// initialize(指定イニシャライザ)
//
//  Call
//    bitmap : パターン
//
//  Return
//    pattern_ : パターン(instance 変数)
//
-(id)initWithBitmap:(PoCoBitmap *)bitmap
{
    PoCoRect *r;

//    DPRINT((@"[PoCoColorPattern initWithBitmap]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->pattern_ = nil;

        // 確保
        self->pattern_ = [[PoCoBitmap alloc] initWidth:[bitmap width]
                                            initHeight:[bitmap height]
                                          defaultColor:0];
        if (self->pattern_ == nil) {
            DPRINT((@"can't alloc PoCoBitmap.\n"));
            [self release];
            self = nil;
            goto EXIT;
        }

        // 設定
        r = [[PoCoRect alloc] initLeft:0
                               initTop:0
                             initRight:[bitmap width]
                            initBottom:[bitmap height]];
        [self->pattern_ setBitmap:[bitmap pixelmap]
                         withRect:r];
        [r release];
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
//    pattern_ : パターン(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoColorPattern dealloc]\n"));

    // 資源の解放
    [self->pattern_ release];
    self->pattern_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// パターンの更新
//
//  Call
//    pat : パターン
//
//  Return
//    pattern_ : パターン(instance 変数)
//
-(void)setPattern:(PoCoBitmap *)pat
{
    [self->pattern_ release];
    self->pattern_ = pat;
    [self->pattern_ retain];

    return;
}


//
// 見本の取得
//
//  Call
//    r        : 矩形領域
//    palette  : 使用パレット
//    pattern_ : パターン(instance 変数)
//
//  Return
//    function : 画像
//
-(NSImageRep *)preview:(PoCoRect *)r
               palette:(PoCoPalette *)palette
{
    NSBitmapImageRep *img;
    unsigned int sx;
    unsigned int sy;
    unsigned int dx;
    int dy;
    unsigned int si;
    unsigned int di;
    unsigned int startX;
    unsigned int startY;
    unsigned int sourceRow;
    unsigned int bitmapRow;
    unsigned char *source;
    unsigned char *bitmap;
    PoCoColor *color;
    const unsigned int sourceWidth = [self->pattern_ width];
    const unsigned int sourceHeight = [self->pattern_ height];
    const unsigned int bitmapWidth = [r width];
    const unsigned int bitmapHeight = [r height];

    img = nil;

    // 起点の算出
    startX = (([r left] < 0) ? 0 : ([r left] % sourceWidth));
    startY = (([r  top] < 0) ? 0 : ([r  top] % sourceHeight));

    // NSBitmapImageRep の生成
    img = [[NSBitmapImageRep alloc]
              initWithBitmapDataPlanes:NULL
                            pixelsWide:bitmapWidth
                            pixelsHigh:bitmapHeight
                         bitsPerSample:8
                       samplesPerPixel:3
                              hasAlpha:NO
                              isPlanar:NO
                        colorSpaceName:NSCalibratedRGBColorSpace
                           bytesPerRow:0
                          bitsPerPixel:0];
    if (img == nil) {
        DPRINT((@"can't alloc NSBItmapImageRep\n"));
        goto EXIT;
    }

    // 画像の生成
    source = [self->pattern_ pixelmap];
    bitmap = [img bitmapData];
    sourceRow = (sourceWidth + (sourceWidth & 1));
    bitmapRow = (unsigned int)([img bytesPerRow]);
    for (dy = (bitmapHeight - 1), sy = startY; dy >= 0; (dy)--) {
        si = ((sy * sourceRow) + startX);
        di = (dy * bitmapRow);
        for (dx = 0, sx = startX; dx < bitmapWidth; (dx)++) {
            color = [palette palette:source[si]];
            bitmap[di + 0] = [color red];
            bitmap[di + 1] = [color green];
            bitmap[di + 2] = [color blue];
            di += 3;
            (sx)++;
            (si)++;
            if (sx >= sourceWidth) {
                sx = 0;
                si = (sy * sourceRow);
            }
        }
        (sy)++;
        if (sy >= sourceHeight) {
            sy = 0;
        }
    }

EXIT:
    return img;
}


//
// パターン画像の取得
//
//  Call
//    r        : 矩形領域
//    pattern_ : パターン(instance 変数)
//
//  Return
//    function : 画像
//
-(PoCoBitmap *)pixelmap:(PoCoRect *)r
{
    PoCoBitmap *bmp;
    unsigned int sx;
    unsigned int sy;
    unsigned int dx;
    unsigned int dy;
    unsigned int si;
    unsigned int di;
    unsigned int startX;
    unsigned int startY;
    unsigned int sourceRow;
    unsigned int bitmapRow;
    unsigned char *source;
    unsigned char *bitmap;
    const unsigned int sourceWidth = [self->pattern_ width];
    const unsigned int sourceHeight = [self->pattern_ height];
    const unsigned int bitmapWidth = [r width];
    const unsigned int bitmapHeight = [r height];

    bmp = nil;

    // 起点の算出
    startX = ([r left] < 0) ? 0 : ([r left] % sourceWidth);
    startY = ([r top] < 0) ? 0 : ([r top] % sourceHeight);

    // PoCoBitmap の生成
    bmp = [[PoCoBitmap alloc] initWidth:bitmapWidth
                             initHeight:bitmapHeight
                           defaultColor:0];
    if (bmp == nil) {
        DPRINT((@"can't alloc PoCoBitmap\n"));
        goto EXIT;
    }

    // 画像の生成
    source = [self->pattern_ pixelmap];
    bitmap = [bmp pixelmap];
    sourceRow = (sourceWidth + (sourceWidth & 1));
    bitmapRow = (bitmapWidth + (bitmapWidth & 1));
    for (dy = 0, sy = startY; dy < bitmapHeight; (dy)++) {
        si = sy * sourceRow + startX;
        di = dy * bitmapRow;
        for (dx = 0, sx = startX; dx < bitmapWidth; (dx)++) {
            bitmap[di] = source[si];
            (di)++;
            (sx)++;
            (si)++;
            if (sx >= sourceWidth) {
                sx = 0;
                si = (sy * sourceRow);
            }
        }
        (sy)++;
        if (sy >= sourceHeight) {
            sy = 0;
        }
    }

EXIT:
    return bmp;
}


// ----------------------------------------- instance - public - ファイル操作系
//
// 保存
//
//  Call
//    pattern_ : パターン(instance 変数)
//
//  Return
//    function : data
//
-(NSData *)createFileData
{
    NSData *data;
    PoCoPNGEncoder *png;
    NSData *pixdata;

    DPRINT((@"[PoCoColorPattern createFileData]\n"));

    png = [[PoCoPNGEncoder alloc] init];

    // CHUNK を生成
    [png createChunk:(unsigned char *)("cpAT")];

    // cpAT の内容を書き込み
    pixdata = [self->pattern_ createFileData];
    [png writeChunk:[pixdata bytes]
             length:(unsigned int)([pixdata length])];

    // CHUNK を閉じる
    [png closeChunk];

    // NSData を生成
    data = [png createNSData];
    [png release];

    return data;
}


//
// 読み込み(cpAT Chunk)
//
//  Call
//    png : PNG Decoder
//
//  Return
//    function : YES : 成功
//               NO  : 失敗
//
-(BOOL)loadCPATChunk:(PoCoPNGDecoder *)png
{
    BOOL result;
    PoCoBitmap *bmp;

    DPRINT((@"[PoCoColorPattern loadCPATChunk]\n"));

    result = NO;

    // pixelmap を読み込み
    bmp = [[PoCoBitmap alloc] initWithPNGDecoder:png];
    if (bmp == nil) {
        DPRINT((@"can't load pixelmap.\n"));
        goto EXIT;
    }

    // カラーパターンを更新
    [self setPattern:bmp];
    [bmp release];

    // 成功
    result = YES;

EXIT:
    return result;
}

@end
