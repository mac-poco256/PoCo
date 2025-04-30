//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 均一濃度 - 生成部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class の宣言
@class PoCoBitmap;
@class PoCoPalette;
@class PoCoColorPattern;
@class PoCoColorBuffer;

// ----------------------------------------------------------------------------
@interface PoCoEditUniformedDensityDrawLineFactory : NSObject
{
}

// 生成
+(id)create:(PoCoBitmap *)bmp
    colMode:(PoCoColorMode)cmode
    palette:(PoCoPalette *)plt
    pattern:(PoCoColorPattern *)pat
     buffer:(PoCoColorBuffer *)buf
    penSize:(int)size;

@end
