//
//	Pelistina on Cocoa - PoCo -
//	筆圧比例自由曲線 - 霧吹き
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerFrameEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerAtomizerProportionalFreeLineEditter : PoCoControllerLineEditterBase
{
    NSString *undoName_;                // 取り消し名称
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   eraser:(PoCoColorPattern *)eraser
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
