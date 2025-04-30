//
//	Pelistina on Cocoa - PoCo -
//	補間曲線
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import <Foundation/Foundation.h>

// ----------------------------------------------------------------------------
@interface PoCoCalcCurveWithPointsBase : NSObject
{
    NSMutableArray *source_;            // source: NSMutableArray<PoCoPoint *>
    NSMutableArray *result_;            // result: NSMutableArray<PoCoPoint *>
}

// initialize
-(id)init;
-(id)initWithPoints:(NSMutableArray *)points; // 指定イニシャライザ

// deallocate
-(void)dealloc;

// 点を追加(支点)
-(void)addPointToSource:(PoCoPoint *)pt;

// 補間した座標を算出
-(NSArray *)exec:(unsigned int)freq;

@end


// ----------------------------------------------------------------------------
@interface PoCoCalcLagrange : PoCoCalcCurveWithPointsBase 
{
}

// 補間した座標を算出
-(NSArray *)exec:(unsigned int)freq;

@end


// ----------------------------------------------------------------------------
@interface PoCoCalcSpline : PoCoCalcCurveWithPointsBase 
{
}

// 補間した座標を算出
-(NSArray *)exec:(unsigned int)freq;

@end
