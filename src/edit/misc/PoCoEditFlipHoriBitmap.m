//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 反転(水平)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditFlipHoriBitmap.h"

// ============================================================================
@implementation PoCoEditFlipHoriBitmap

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    d : 反転先画像
//    s : 反転元画像
//
//  Return
//    function   : 実体
//    srcBitmap_ : 反転元画像(instance 関数)
//    dstBitmap_ : 反転先画像(instance 関数)
//
-(id)initDst:(PoCoBitmap *)d
     withSrc:(PoCoBitmap *)s
{
    DPRINT((@"[PoCoEditFlipHoriBitmap initDst withSrc]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->srcBitmap_ = s;
        self->dstBitmap_ = d;
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
//    srcBitmap_ : 反転元画像(instance 関数)
//    dstBitmap_ : 反転先画像(instance 関数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoEditFlipHoriBitmap dealloc]\n"));

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
//    srcBitmap_ : 反転元画像(instance 関数)
//    dstBitmap_ : 反転先画像(instance 関数)
//
//  Return
//    dstBitmap_ : 反転先画像(instance 関数)
//
-(void)executeFlip
{
    const int w = [self->srcBitmap_ width];
    const int row = (w + (w & 0x01));
    const int sskip = (row - w);
    const int dskip = (row + w);
    int x;
    int y;
    unsigned char *sp = [self->srcBitmap_ pixelmap];
    unsigned char *dp = [self->dstBitmap_ pixelmap];

    DPRINT((@"[PoCoEditFlipHoriBitmap executeFlip]\n"));

    // 反転先は画像の右辺から走査
    dp += (w - 1);

    // 垂直走査
    y = [self->srcBitmap_ height];
    do {
        // 水平走査
        x = w;
        do {
            // 単純複写
            *(dp) = *(sp);

            // 次へ
            (x)--;
            (sp)++;
            (dp)--;
        } while (x != 0);

        // 次へ
        (y)--;
        sp += sskip;
        dp += dskip;
    } while (y != 0);

    return;
}

@end
