//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 反転 - 基底
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditInvertBase.h"

// ============================================================================
@implementation PoCoEditInvertBase

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp : 描画対象 bitmap
//    z   : 0x00 のみを反転対象とする
//
//  Return
//    function  : 実体
//    bitmap_   : 描画対象 bitmap(instance 変数)
//    zeroOnly_ : 0x00 のみを反転対象とする(instance 変数)
//
-(id)initWithBitmap:(PoCoBitmap *)bmp
         isZeroOnly:(BOOL)z
{
//    DPRINT((@"[PoCoEditInvertBase initWithBitmap]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->bitmap_ = bmp;
        self->zeroOnly_ = z;
        [self->bitmap_ retain];
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
//    bitmap_ : 描画対象 bitmap(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoEditInvertBase dealloc]\n"));

    // 資源の解放
    [self->bitmap_ release];
    self->bitmap_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 点の描画
//
//  Call
//    pnt       : 描画中心
//    bitmap_   : 描画対象 bitmap(instance 変数)
//    zeroOnly_ : 0x00 のみを反転対象とする(instance 変数)
//
//  Return
//    bitmap_ : 描画対象 bitmap(instance 変数)
//
-(void)drawPoint:(PoCoPoint *)pnt
{
    unsigned int row;                   // 描画対象の rowbytes
    unsigned char *pixmap;              // 描画対象画像の pixelmap

//    DPRINT((@"[PoCoEditInvertBase drawPoint]\n"));

    // 描画の実行
    if (([pnt x] >= 0) && ([pnt x] < [self->bitmap_ width]) &&
        ([pnt y] >= 0) && ([pnt y] < [self->bitmap_ height])) {
        row = [self->bitmap_ width];
        row += (row & 1);
        pixmap = [self->bitmap_ pixelmap];
        if ((!(self->zeroOnly_)) ||
            (pixmap[(([pnt y] * row) + [pnt x])] == 0x00)) {
            pixmap[(([pnt y] * row) + [pnt x])] ^= 0xff;
        }
    }

    return;
}

@end
