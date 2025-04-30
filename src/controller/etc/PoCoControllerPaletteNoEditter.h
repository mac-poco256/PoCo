//
//	Pelistina on Cocoa - PoCo -
//	パレット更新単純通知部(無編集)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerPaletteNoEditter : PoCoControllerBase
{
    NSString *name_;                    // 取り消し名称
    int index_;                         // 対象パレット番号(<0 : 全更新扱い)

    BOOL deallocPost_;                  // dealloc で通知
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
     name:(NSString *)nm
    index:(int)idx;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

// 通知
-(void)postNote;

@end
