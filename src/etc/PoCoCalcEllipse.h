//
//	Pelistina on Cocoa - PoCo -
//	楕円関数
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import <Foundation/Foundation.h>

// ----------------------------------------------------------------------------
@interface PoCoCalcEllipse : NSObject
{
    int arrayIter_;                     // 反復子(pos 配列走査用)
    NSEnumerator *posIter_;             // 反復子(pos 内走査用)
    NSMutableArray *pos_[8];            // 座標群
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// 演算
-(void)calc:(PoCoPoint *)cp
     endPos:(PoCoPoint *)ep
orientation:(PoCoPoint *)ort;

// 取得
-(PoCoPoint *)points;

@end
