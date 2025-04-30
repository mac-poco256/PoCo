//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 反転 - 基底
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoLayer.h"
#import "PoCoPalette.h"
#import "PoCoColorPattern.h"
#import "PoCoMonochromePattern.h"

// ----------------------------------------------------------------------------
@interface PoCoEditInvertBase : NSObject
{
    PoCoBitmap *bitmap_;                // 描画対象 bitmap
    BOOL zeroOnly_;                     // 0x00 のみを反転対象とする
}

// initialize
-(id)initWithBitmap:(PoCoBitmap *)bmp
         isZeroOnly:(BOOL)z;

// deallocate
-(void)dealloc;

// 点の描画
-(void)drawPoint:(PoCoPoint *)pnt;

@end
