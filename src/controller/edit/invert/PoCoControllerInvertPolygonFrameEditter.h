//
//	Pelistina on Cocoa - PoCo -
//	直線群(閉路) - 反転
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//
// 任意領域を描くときのガイドライン用であり、undo は効かない
//

#import "PoCoControllerEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerInvertPolygonFrameEditter : PoCoControllerEditterBase
{
    NSMutableArray *points_;            // 支点群
}

// initialize
-(id)init:(PoCoPicture *)pict
     poly:(NSMutableArray *)p
    index:(int)idx;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
