//
//	Pelistina on Cocoa - PoCo -
//	平行四辺形 - 拡散
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerFrameEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerRandomParallelogramFrameEditter : PoCoControllerParallelogramFrameEditterBase
{
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
     tile:(PoCoTilePattern *)tile
    first:(PoCoPoint *)f
   second:(PoCoPoint *)s
    third:(PoCoPoint *)t
    index:(int)idx;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
