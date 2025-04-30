//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 変倍
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoLayer.h"

// ----------------------------------------------------------------------------
@interface PoCoEditResizeBitmap : NSObject
{
    PoCoBitmap *srcBitmap_;             // 変倍元画像
    PoCoBitmap *dstBitmap_;             // 変倍先画像
}

// initialize
-(id)initDst:(PoCoBitmap *)dbmp
     withSrc:(PoCoBitmap *)sbmp;

// deallocate
-(void)dealloc;

// 実行
-(void)executeResize;

@end


// ----------------------------------------------------------------------------
@interface PoCoEditResizeBitmapDouble : NSObject
{
    PoCoBitmap *srcBitmap_[2];          // 変倍元画像
    PoCoBitmap *dstBitmap_[2];          // 変倍先画像
}

// initialize
-(id)initDst1:(PoCoBitmap *)dbmp1
     withDst2:(PoCoBitmap *)dbmp2
     withSrc1:(PoCoBitmap *)sbmp1
     withSrc2:(PoCoBitmap *)sbmp2;

// deallocate
-(void)dealloc;

// 実行
-(void)executeResize;

@end
