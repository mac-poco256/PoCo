//
//	Pelistina on Cocoa - PoCo -
//	レイヤー削除部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerLayerDeleter : PoCoControllerBase
{
    BOOL active_;                       // 通知の有無
    int index_;                         // 削除対象レイヤー番号
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   active:(BOOL)act
  atIndex:(int)idx;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

// 取り消しの生成
-(void)createUndo;

@end
