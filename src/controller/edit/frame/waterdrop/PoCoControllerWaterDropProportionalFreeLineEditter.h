//
//	Pelistina on Cocoa - PoCo -
//	筆圧比例自由曲線 - ぼかし
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerFrameEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerWaterDropProportionalFreeLineEditter : PoCoControllerLineEditterBase
{
    NSString *undoName_;                // 取り消し名称
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
    start:(PoCoPoint *)s
      end:(PoCoPoint *)e
    index:(int)idx
     prop:(BOOL)p
 undoName:(NSString *)name;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
