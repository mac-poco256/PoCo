//
//	Pelistina on Cocoa - PoCo -
//	レイヤー移動/複製部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerLayerMover : PoCoControllerBase
{
    int src_;                           // 移動元
    int dst_;                           // 移動先
    BOOL isCopy_;                       // 移動/複製の指定
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
fromIndex:(int)s
  toIndex:(int)d
   isCopy:(BOOL)copy;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
