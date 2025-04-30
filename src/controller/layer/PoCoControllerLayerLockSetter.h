//
//	Pelistina on Cocoa - PoCo -
//	レイヤー描画抑止設定部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerLayerLockSetter : PoCoControllerBase
{
    int index_;                         // 対象レイヤー番号
    BOOL drawLock_;                     // 設定内容
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
 drawLock:(BOOL)lock
  atIndex:(int)idx;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
