//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 反転(水平)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoLayer.h"

// ----------------------------------------------------------------------------
@interface PoCoEditFlipHoriBitmap : NSObject
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
