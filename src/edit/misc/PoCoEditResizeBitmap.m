//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 変倍
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditResizeBitmap.h"

// ============================================================================
@implementation PoCoEditResizeBitmap

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    dbmp : 変倍先画像
//    sbmp : 変倍元画像
//
//  Return
//    function   : 実体
//    srcBitmap_ : 変倍元画像(instance 関数)
//    dstBitmap_ : 変倍先画像(instance 関数)
//
-(id)initDst:(PoCoBitmap *)dbmp
     withSrc:(PoCoBitmap *)sbmp
{
    DPRINT((@"[PoCoEditResizeBitmap initDst withSrc]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->srcBitmap_ = sbmp;
        self->dstBitmap_ = dbmp;
        [self->srcBitmap_ retain];
        [self->dstBitmap_ retain];
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
//    srcBitmap_ : 変倍元画像(instance 関数)
//    dstBitmap_ : 変倍先画像(instance 関数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoEditResizeBitmap dealloc]\n"));

    // 資源の解放
    [self->dstBitmap_ release];
    [self->srcBitmap_ release];
    self->srcBitmap_ = nil;
    self->dstBitmap_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//
//  Call
//    srcBitmap_ : 変倍元画像(instance 関数)
//    dstBitmap_ : 変倍先画像(instance 関数)
//
//  Return
//    dstBitmap_ : 変倍先画像(instance 関数)
//
-(void)executeResize
{
    int dx;                    // 水平走査(変倍先画像)
    int dy;                    // 垂直走査(変倍先画像)
    const int dw = [self->dstBitmap_  width];
    const int dh = [self->dstBitmap_ height];
    const int dskip = (dw & 0x01);
    long long sx;                    // 水平走査(変倍元画像)
    long long sy;                    // 垂直走査(変倍元画像)
    const long long sw = ([self->srcBitmap_  width] << 10);
    const long long sh = ([self->srcBitmap_ height] << 10);
    const long long srow = ((sw + (sw & (0x01 << 10))) >> 10);
    const long long hstep = (sw / (long long)(dw));
    const long long vstep = (sh / (long long)(dh));
    unsigned char *sp = [self->srcBitmap_ pixelmap];
    unsigned char *dp = [self->dstBitmap_ pixelmap];

    DPRINT((@"[PoCoEditResizeBitmap executeResize]\n"));

    // 変倍先を垂直走査
    sy = 0;
    dy = dh;
    do {
        // 変倍先を水平走査
        sx = 0;
        dx = dw;
        do {
            // 変倍元画像の参照位置を算出して描画
            *(dp) = sp[(((sy >> 10) * srow) + (sx >> 10))];

            // 次へ
            if (sx < sw) {
                sx += hstep;
                if (sx > sw) {
                    sx = sw;
                }
            }
            (dx)--;
            (dp)++;
        } while (dx != 0);

        // 次へ
        if (sy < sh) {
            sy += vstep;
            if (sy > sh) {
                sy = sh;
            }
        }
        (dy)--;
        dp += dskip;
    } while (dy != 0);

    return;
}

@end




// ============================================================================
@implementation PoCoEditResizeBitmapDouble

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    dbmp1 : 変倍先画像1
//    dbmp2 : 変倍先画像2
//    sbmp1 : 変倍元画像1
//    sbmp2 : 変倍元画像2
//
//  Return
//    function     : 実体
//    srcBitmap_[] : 変倍元画像(instance 関数)
//    dstBitmap_[] : 変倍先画像(instance 関数)
//
-(id)initDst1:(PoCoBitmap *)dbmp1
     withDst2:(PoCoBitmap *)dbmp2
     withSrc1:(PoCoBitmap *)sbmp1
     withSrc2:(PoCoBitmap *)sbmp2
{
    DPRINT((@"[PoCoEditResizeBitmapDouble initDst withSrc]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->srcBitmap_[0] = sbmp1;
        self->srcBitmap_[1] = sbmp2;
        self->dstBitmap_[0] = dbmp1;
        self->dstBitmap_[1] = dbmp2;
        [self->srcBitmap_[0] retain];
        [self->srcBitmap_[1] retain];
        [self->dstBitmap_[0] retain];
        [self->dstBitmap_[1] retain];
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
//    srcBitmap_[] : 変倍元画像(instance 関数)
//    dstBitmap_[] : 変倍先画像(instance 関数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoEditResizeBitmapDouble dealloc]\n"));

    // 資源の解放
    [self->dstBitmap_[0] release];
    [self->dstBitmap_[1] release];
    [self->srcBitmap_[0] release];
    [self->srcBitmap_[1] release];
    self->srcBitmap_[0] = nil;
    self->srcBitmap_[1] = nil;
    self->dstBitmap_[0] = nil;
    self->dstBitmap_[1] = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//
//  Call
//    srcBitmap_[] : 変倍元画像(instance 関数)
//    dstBitmap_[] : 変倍先画像(instance 関数)
//
//  Return
//    dstBitmap_[] : 変倍先画像(instance 関数)
//
-(void)executeResize
{
    long long i;
    int dx;                    // 水平走査(変倍先画像)
    int dy;                    // 垂直走査(変倍先画像)
    const int dw = [self->dstBitmap_[0]  width];
    const int dh = [self->dstBitmap_[0] height];
    const int dskip = (dw & 0x01);
    long long sx;                    // 水平走査(変倍元画像)
    long long sy;                    // 垂直走査(変倍元画像)
    const long long sw = ([self->srcBitmap_[0]  width] << 10);
    const long long sh = ([self->srcBitmap_[0] height] << 10);
    const long long srow = ((sw + (sw & (0x01 << 10))) >> 10);
    const long long hstep = (sw / (long long)(dw));
    const long long vstep = (sh / (long long)(dh));
    unsigned char *sp1 = [self->srcBitmap_[0] pixelmap];
    unsigned char *sp2 = [self->srcBitmap_[1] pixelmap];
    unsigned char *dp1 = [self->dstBitmap_[0] pixelmap];
    unsigned char *dp2 = [self->dstBitmap_[1] pixelmap];

    DPRINT((@"[PoCoEditResizeBitmap executeResize]\n"));

    // 変倍先を垂直走査
    sy = 0;
    dy = dh;
    do {
        // 変倍先を水平走査
        sx = 0;
        dx = dw;
        do {
            // 変倍元画像の参照位置を算出して描画
            i = (((sy >> 10) * srow) + (sx >> 10));
            *(dp1) = sp1[i];
            *(dp2) = sp2[i];

            // 次へ
            if (sx < sw) {
                sx += hstep;
                if (sx > sw) {
                    sx = sw;
                }
            }
            (dx)--;
            (dp1)++;
            (dp2)++;
        } while (dx != 0);

        // 次へ
        if (sy < sh) {
            sy += vstep;
            if (sy > sh) {
                sy = sh;
            }
        }
        (dy)--;
        dp1 += dskip;
        dp2 += dskip;
    } while (dy != 0);

    return;
}

@end
