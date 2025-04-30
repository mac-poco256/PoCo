//
//	Pelistina on Cocoa - PoCo -
//	平行四辺形 - 反転
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//
// 平行四辺形を描くときのガイドライン用であり、undo は効かない
//

#import "PoCoControllerEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerInvertParallelogramFrameEditter : PoCoControllerParallelogramEditterBase
{
}

// initialize
-(id)init:(PoCoPicture *)pict
    first:(PoCoPoint *)f
   second:(PoCoPoint *)s
    third:(PoCoPoint *)t
    index:(int)idx;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
