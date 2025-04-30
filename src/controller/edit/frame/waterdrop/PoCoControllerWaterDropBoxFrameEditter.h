//
//	Pelistina on Cocoa - PoCo -
//	矩形 - ぼかし
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoControllerFrameEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerWaterDropBoxFrameEditter : PoCoControllerBoxFrameEditterBase
{
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
    start:(PoCoPoint *)s
      end:(PoCoPoint *)e
orientation:(PoCoPoint *)o
    index:(int)idx;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
