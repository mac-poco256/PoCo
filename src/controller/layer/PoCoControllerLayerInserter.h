//
//	Pelistina on Cocoa - PoCo -
//	レイヤー挿入部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// 参照 class の宣言
@class PoCoLayerBase;

// ----------------------------------------------------------------------------
@interface PoCoControllerLayerInserter : PoCoControllerBase
{
    BOOL active_;                       // 通知の有無
    int index_;                         // 挿入位置
    PoCoLayerBase *layer_;              // 挿入レイヤー
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   active:(BOOL)act
    layer:(PoCoLayerBase *)lyr
  atIndex:(int)idx;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

// 取り消しの生成
-(void)createUndo;

@end
