//
//	Pelistina on Cocoa - PoCo -
//	塗りつぶし平行四辺形 - 濃度
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import "PoCoControllerFillEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerDensityParallelogramFillEditter : PoCoControllerParallelogramFillEditterBase
{
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   eraser:(PoCoColorPattern *)eraser
   buffer:(PoCoColorBuffer *)buf
    first:(PoCoPoint *)f
   second:(PoCoPoint *)s
    third:(PoCoPoint *)t
    index:(int)idx;

// deallcate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
