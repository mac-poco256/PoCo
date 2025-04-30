//
//	Pelistina on Cocoa - PoCo -
//	塗りつぶし平行四辺形 - ぼかし
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerFillEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerWaterDropParallelogramFillEditter : PoCoControllerParallelogramFillEditterBase
{
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
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
