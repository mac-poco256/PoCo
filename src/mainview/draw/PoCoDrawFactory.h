//
//	Pelistina on Cocoa - PoCo -
//	描画編集系生成部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class
@class MyDocument;
@class PoCoView;

// ----------------------------------------------------------------------------
@interface PoCoDrawFactory : NSObject
{
}

// 生成
+(id)create:(MyDocument *)doc
   withDraw:(PoCoDrawModeType)draw
    withPen:(PoCoPenStyleType)pen;

@end
