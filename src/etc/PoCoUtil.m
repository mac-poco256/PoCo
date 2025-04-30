//
//	Pelistina on Cocoa - PoCo -
//	補助関数群
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoUtil.h"

#import <stdlib.h>
#import <time.h>

// ============================================================================
@implementation PoCoUtil

// ------------------------------------------------------------- class - public
//
// 初期化
//
//  Call
//    None
//
//  Return
//    None
//
+(void)startUp
{
    srand((unsigned int)(time(NULL)));

    return;
}


//
// 描画可否(頻度)
//  乱数で判定
//    
//  Call  
//    ratio : 頻度(0.1%単位)
//    
//  Return
//    function : 判定結果
//
+(BOOL)canDrawFromRatio:(int)ratio
{
    return ((int)(((double)(rand()) / (double)(RAND_MAX)) * 1000.0) < ratio);
}


//
// 範囲内座標
//
//  Call
//    s : 始点
//    e : 終点
//
//  Return
//    function : 算出結果
//
+(int)randomStartRange:(int)s
          withEndRange:(int)e
{
    return (int)(floor((((double)(rand()) / (double)(RAND_MAX)) * ((double)(e) - (double)(s))) + (double)(s)));
}

@end
