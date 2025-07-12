//
// PoCoMonochromePattern.h
// implementation of base classes for monochrome pattern.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoMonochromePattern.h"

#import "PoCoLayer.h"

// 内部定数
#define CLASS_VERSION 1                 // class 版番号

// ============================================================================
@implementation PoCoMonochromePattern

// ----------------------------------------------------------------------------
// class - public.

//
// 初期設定
//
//  Call
//    None
//
//  Return
//    None
//
+(void)initialize
{
    if (self == [PoCoMonochromePattern class]) {
        [self setVersion:CLASS_VERSION];
    }

    return;
}


// ----------------------------------------------------------------------------
// instance - public.

//
// initialize
//
//  Call
//    None
//
//  Return
//    function : 実体
//    width_   : 幅(dot 単位)(instance 変数)
//    height_  : 高さ(dot 単位)(instance 変数)
//    pattern_ : パターン(instance 変数)
//
-(id)init
{
    DPRINT((@"[PoCoMonochromePattern init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->width_ = 0;
        self->height_ = 0;
        self->pattern_ = NULL;
    }

    return self;
}


//
// deallocate
//
//  Call
//    pattern_ : パターン(instance 変数)
//
//  Return
//    width_   : 幅(dot 単位)(instance 変数)
//    height_  : 高さ(dot 単位)(instance 変数)
//    pattern_ : パターン(instance 変数)
//
//
-(void)dealloc
{
    DPRINT((@"[PoCoMonochromePattern dealloc]\n"));

    // 資源の解放
    if (self->pattern_ != NULL) {
        free(self->pattern_);
    }
    self->pattern_ = NULL;
    self->width_ = 0;
    self->height_ = 0;

    // super class の解放
    [super dealloc];

    return;
}


//
// 幅の取得
//
//  Call
//    width_ : 幅(dot 単位)(instance 変数)
//
//  Return
//    function : 幅
//
-(unsigned int)width
{
    return self->width_;
}


//
// 高さの取得
//
//  Call
//    height_ : 高さ(dot 単位)(instance 変数)
//
//  Return
//    function : 高さ
//
-(unsigned int)height
{
    return self->height_;
}


//
// パターンの取得
//
//  Call
//    pattern_ : パターン(instance 変数)
//
//  Return
//    function : パターン
//
-(const unsigned char *)pattern
{
    return self->pattern_;
}


//
// 一括取得
//
//  Call
//    pat      : パターンの取得先(NULL なら取得しない)
//    w        : 幅の取得先(NULL なら取得しない)
//    h        : 高さの取得先(NULL なら取得しない)
//    width_   : 幅(dot 単位)(instance 変数)
//    height_  : 高さ(dot 単位)(instance 変数)
//    pattern_ : パターン(instance 変数)
//
//  Return
//    function : パターン
//    w        : 幅
//    h        : 高さ
//
-(void)getPattern:(const unsigned char **)pat
         getWidth:(unsigned int *)w
        getHeight:(unsigned int *)h
{
    if (pat != NULL) {
        *(pat) = self->pattern_;
    }
    if (w != NULL) {
        *(w) = self->width_;
    }
    if (h != NULL) {
        *(h) = self->height_;
    }

    return;
}


//
// 設定(一括)
//  内容を複製する(呼び出しに使用した pat は解放してよい)
//
//  Call
//    pat : 設定する内容
//    w   : 設定する内容の幅(dot 単位)
//    h   : 設定する内容の高さ(dot 単位)
//
//  Return
//    width_   : 幅(dot 単位)(instance 変数)
//    height_  : 高さ(dot 単位)(instance 変数)
//    pattern_ : パターン(instance 変数)
//
-(void)setPattern:(const unsigned char *)pat
            width:(unsigned int)w
           height:(unsigned int)h
{
    unsigned char *buf;
    const size_t size = ((w + (w & 1)) * h);

    if (size > 0) {
        buf = (unsigned char *)(malloc(size));
        if (buf == NULL) {
            DPRINT((@"memory allocation error.\n"));
        } else {
            // buffer に一旦複写
            memcpy(buf, pat, size);

            // 以前の内容を解放
            if (self->pattern_ != NULL) {
                free(self->pattern_);
            }
            self->pattern_ = NULL;

            // buffer に溜めた内容で更新
            self->pattern_ = buf;
            self->width_ = w;
            self->height_ = h;
        }
    }

    return;
}


//
// 表示用画像の取得
//  常に実寸のみ
//
//  Call
//    width_   : 幅(dot 単位)(instance 変数)
//    height_  : 高さ(dot 単位)(instance 変数)
//    pattern_ : パターン(instance 変数)
//
//  Return
//    function : 画像
//
-(NSBitmapImageRep *)getImage
{
    NSBitmapImageRep *img;
    unsigned int x;
    unsigned int y;
    unsigned int si;
    unsigned int di;
    unsigned int imgRow;
    unsigned int patRow;
    unsigned char *plane;

    img = nil;

    // 転送先画像の生成
    img = [[NSBitmapImageRep alloc]
              initWithBitmapDataPlanes:NULL
                            pixelsWide:self->width_
                            pixelsHigh:self->height_
                         bitsPerSample:8
                       samplesPerPixel:3
                              hasAlpha:NO
                              isPlanar:NO
                        colorSpaceName:NSCalibratedRGBColorSpace
                           bytesPerRow:0
                          bitsPerPixel:0];
    if (img == nil) {
        DPRINT((@"can't alloc NSBitmapImageRep\n"));
        goto EXIT;
    }

    // row bytes を取得
    imgRow = (int)([img bytesPerRow]);
    patRow = (self->width_ + (self->width_ & 1));

    // 画像を生成
    plane = [img bitmapData];
    for (y = 0; y < self->height_; (y)++) {
        si = ((self->height_ - y - 1) * patRow);
        di = (y * imgRow);
        for (x = 0; x < self->width_; (x)++, (si)++, di += 3) {
            memset(&(plane[di]), (self->pattern_[si] == 0) ? 0x00 : 0xff, 3);
        }
    }

EXIT:
    return img;
}


//
// パターンの羅列の取得
//
//  Call
//    r        : 取得領域
//    width_   : 幅(dot 単位)(instance 変数)
//    height_  : 高さ(dot 単位)(instance 変数)
//    pattern_ : パターン(instance 変数)
//
//  Return
//    function : pixelmap
//
-(PoCoBitmap *)getPixelmap:(PoCoRect *)r
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
    unsigned int row;
    unsigned int bitmapRow;
    unsigned char *bitmap;
    const unsigned int bitmapWidth = [r width];
    const unsigned int bitmapHeight = [r height];

    bmp = nil;

    // 起点の算出
    startX = (([r left] < 0) ? 0 : ([r left] % self->width_));
    startY = (([r  top] < 0) ? 0 : ([r  top] % self->height_));

    // PoCoBitmap の生成
    bmp = [[PoCoBitmap alloc] initWidth:bitmapWidth
                             initHeight:bitmapHeight
                           defaultColor:0];
    if (bmp == nil) {
        DPRINT((@"can't alloc PoCoBitmap\n"));
        goto EXIT;
    }

    // 画像の生成
    bitmap = [bmp pixelmap];
    row = (self->width_ + (self->width_ & 1));
    bitmapRow = (bitmapWidth + (bitmapWidth & 1));
    for (dy = 0, sy = startY; dy < bitmapHeight; (dy)++) {
        si = ((sy * row) + startX);
        di = (dy * bitmapRow);
        for (dx = 0, sx = startX; dx < bitmapWidth; (dx)++) {
            bitmap[di] = self->pattern_[si];
            (di)++;
            (sx)++;
            (si)++;
            if (sx >= self->width_) {
                sx = 0;
                si = (sy * row);
            }
        }
        (sy)++;
        if (sy >= self->height_) {
            sy = 0;
        }
    }

EXIT:
    return bmp;
}


// ----------------------------------------------------------------------------
// instance - public - file I/O.

//
// 読み込み
//
//  Call
//    coder : coder(api 変数)
//
//  Return
//    function : 実体
//    width_   : 幅(dot 単位)(instance 変数)
//    height_  : 高さ(dot 単位)(instance 変数)
//    pattern_ : パターン(instance 変数)
//
-(id)initWithCoder:(NSCoder *)coder
{
#if 0   // バージョン番号は特に意識しない
    int ver;
#endif  // 0
    NSUInteger len;
    size_t  size;

//    DPRINT((@"[PoCoMonochromePattern initWithCoder]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化(読み込み）
    if (self != nil) {
        self->width_ = 0;
        self->height_ = 0;
        self->pattern_ = NULL;

#if 0   // バージョン番号は特に意識しない
        // 版番号の取得
        ver = [coder versionForClassName:@"PoCoMonochromePattern"];
//        DPRINT((@"PoCoMonochromePattern version : %d\n", ver));
#endif  // 0
        
        // 大きさの取得
        [coder decodeValueOfObjCType:@encode(unsigned int) at:&(self->width_)];
        [coder decodeValueOfObjCType:@encode(unsigned int) at:&(self->height_)];

        size = ((self->width_ + (self->width_ & 1)) * self->height_);
        self->pattern_ = (unsigned char *)(malloc(size));
        if (self->pattern_ == NULL) {
            DPRINT((@"memory allocation error.\n"));
            [self release];
            self = nil;
        } else {
            memcpy(self->pattern_, [coder decodeBytesWithReturnedLength:&(len)], size);
        }
    }

    return self;
}


//
// 保存
//
//  Call
//    coder    : coder(api 変数)
//    width_   : 幅(dot 単位)(instance 変数)
//    height_  : 高さ(dot 単位)(instance 変数)
//    pattern_ : パターン(instance 変数)
//
//  Return
//    None
//
-(void)encodeWithCoder:(NSCoder *)coder
{
    const size_t  size = ((self->width_ + (self->width_ & 1)) * self->height_);

//    DPRINT((@"[PoCoMonochromePattern encodeWithCoder]\n"));

    // 大きさを保存
    [coder encodeValueOfObjCType:@encode(unsigned int) at:&(self->width_)];
    [coder encodeValueOfObjCType:@encode(unsigned int) at:&(self->height_)];

    // パターンを保存
    [coder encodeBytes:self->pattern_ length:size];

    return;
}

@end




// ============================================================================
@implementation PoCoMonochromePatternContainerBase

// ----------------------------------------------------------------------------
// class - public.

//
// 初期設定
//
//  Call
//    None
//
//  Return
//    None
//
+(void)initialize
{
    // 何もしない
    ;

    return;
}


// ----------------------------------------------------------------------------
// instance - public.

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
    return [super init];
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
    [super dealloc];

    return;
}


//
// 参照
//  基底では常に nil が返されるだけ
//
//  Call
//    index : 参照番号
//
//  Return
//    function : パターン
//
-(PoCoMonochromePattern *)pattern:(int)index
{
    return nil;
}


//
// 設定
//
//  Call
//    pat   : 設定内容
//    index : 参照番号
//
//  Return
//    None
//
-(void)setPattern:(PoCoMonochromePattern *)pat
          atIndex:(int)index
{
    // 何もしない
    ;

    return;
}

@end
