//
//	Pelistina on Cocoa - PoCo -
//	画像置換
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// 参照 class の宣言
@class PoCoBitmap;

// ----------------------------------------------------------------------------
@interface PoCoControllerPictureBitmapReplacer : PoCoControllerBase
{
    int index_;                         // 対象レイヤー番号
    PoCoRect *rect_;                    // 置換領域
    PoCoBitmap *bitmap_;                // 置換内容
    NSString *undoName_;                // 取り消し名称
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
    layer:(int)idx rect:(PoCoRect *)r
   bitmap:(PoCoBitmap *)bmp
     name:(NSString *)name;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
