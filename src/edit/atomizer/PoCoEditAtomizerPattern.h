//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 霧吹き - 形状
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoConstValue.h"

// ----------------------------------------------------------------------------
@interface PoCoEditAtomizerPattern : NSObject
{
}

// class method
+(const unsigned char *)normal:(int)size;
+(const unsigned char *)half:(int)size type:(int)num;

@end
