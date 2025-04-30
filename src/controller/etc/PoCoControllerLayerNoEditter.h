//
//	Pelistina on Cocoa - PoCo -
//	レイヤー構造更新単純通知部(無編集)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerLayerNoEditter : PoCoControllerBase
{
    NSString *name_;                    // 取り消し名称
    BOOL update_;                       // レイヤー構造の変化か

    BOOL deallocPost_;                  // dealloc で通知
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
     name:(NSString *)nm
   update:(BOOL)upd;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

// 通知
-(void)postNote;

@end
