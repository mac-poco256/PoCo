//
//	Pelistina on Cocoa - PoCo -
//	画像サイズ変更単純通知部(無編集)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerResizeNoEditter : PoCoControllerBase
{
    NSString *name_;                    // 取り消し名称

    BOOL deallocPost_;                  // dealloc で通知
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
     name:(NSString *)nm;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

// 通知
-(void)postNote;

@end
