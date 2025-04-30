//
//	Pelistina on Cocoa - PoCo -
//	補助関数群
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// ----------------------------------------------------------------------------
@interface PoCoUtil : NSObject
{
}

// 初期化
+(void)startUp;

// 描画可否(頻度)
+(BOOL)canDrawFromRatio:(int)ratio;

// 範囲内座標
+(int)randomStartRange:(int)s
          withEndRange:(int)e;

@end
