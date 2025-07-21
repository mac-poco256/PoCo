//
// PoCoEditWaterDropBase.h
// declare interface of base class of the blur (water drop) edit feature.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoLayer.h"
#import "PoCoPalette.h"
#import "PoCoColorBuffer.h"

// ----------------------------------------------------------------------------
@interface PoCoEditWaterDropBase : NSObject
{
    PoCoBitmap *srcBitmap_;             // 描画元(複製)
    PoCoBitmap *dstBitmap_;             // 描画先
    PoCoColorMode colMode_;             // 色演算モード
    NSMutableArray *cols_;              // 色群
    PoCoPalette *palette_;              // 使用パレット
    PoCoColorBuffer *colorBuffer_;      // 色保持情報

    int rowBytes_;                      // row bytes
}

// initialise.
- (id)initWithBitmap:(PoCoBitmap *)bmp
             colMode:(PoCoColorMode)cmode
             palette:(PoCoPalette *)plt
              buffer:(PoCoColorBuffer *)buf;

// deallocate.
- (void)dealloc;

// calculate colour.
- (void)calcColor:(PoCoPoint *)p
     withDrawRect:(PoCoRect *)dr
         withMask:(PoCoBitmap *)mask;

@end
