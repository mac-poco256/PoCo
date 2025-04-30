//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 反転(垂直)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoLayer.h"

// ----------------------------------------------------------------------------
@interface PoCoEditFlipVertBitmap : NSObject
{
    PoCoBitmap *srcBitmap_;             // 反転元画像
    PoCoBitmap *dstBitmap_;             // 反転先画像
}

// initialize
-(id)initDst:(PoCoBitmap *)d
     withSrc:(PoCoBitmap *)s;

// deallocate
-(void)dealloc;

// 実行
-(void)executeFlip;

@end
