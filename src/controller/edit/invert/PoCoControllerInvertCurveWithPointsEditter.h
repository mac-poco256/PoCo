//
//	Pelistina on Cocoa - PoCo -
//	直線群(曲線) - 反転
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//
// 直線を描くときのガイドライン用であり、undo は効かない
//

#import "PoCoControllerEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerInvertCurveWithPointsEditter : PoCoControllerEditterBase
{
    NSMutableArray *points_;            // 支点群
    PoCoCurveWithPointsType type_;      // 補間方法
    unsigned int freq_;                 // 補間頻度
}

// initialize
-(id)init:(PoCoPicture *)pict
   points:(NSMutableArray *)p
     type:(PoCoCurveWithPointsType)type
     freq:(unsigned int)freq
    index:(int)idx;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
