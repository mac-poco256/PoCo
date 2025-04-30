//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 反転(垂直)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditFlipVertBitmap.h"

// ============================================================================
@implementation PoCoEditFlipVertBitmap

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
    DPRINT((@"[PoCoEditFlipVertBitmap initDst withSrc]\n"));

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
    DPRINT((@"[PoCoEditFlipVertBitmap dealloc]\n"));

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
    int y = [self->srcBitmap_ height];
    int row = ([self->srcBitmap_ width] + ([self->srcBitmap_ width] & 0x01));
    unsigned char *sp = [self->srcBitmap_ pixelmap];
    unsigned char *dp = [self->dstBitmap_ pixelmap];

    DPRINT((@"[PoCoEditFlipVertBitmap executeFlip]\n"));

    // 反転先は画像の下底から走査
    dp += ((y - 1) * row);

    // 垂直走査
    do {
        // 反転先へ単純複写
        memcpy(dp, sp, row);

        // 次へ
        (y)--;
        sp += row;
        dp -= row;
    } while (y != 0);

    return;
}

@end
