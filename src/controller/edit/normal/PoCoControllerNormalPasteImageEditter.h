//
//	Pelistina on Cocoa - PoCo -
//	画像貼り付け - 通常
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerNormalPasteImageEditter : PoCoControllerEditterBase
{
    PoCoRect *dstRect_;                 // 貼り付け先矩形枠
    PoCoBitmap *pasteBmp_;              // 貼り付ける画像
    PoCoRect *prevRect_;                // 貼り付け元矩形枠
    PoCoBitmap *mask_;                  // 任意領域の形状
    PoCoBitmap *prevBmp_;               // 貼り付け前画像
    NSString *undoName_;                // 取り消し名称
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
     tile:(PoCoTilePattern *)tile
     rect:(PoCoRect *)r
   bitmap:(PoCoBitmap *)bmp
   region:(PoCoBitmap *)mask
 prevRect:(PoCoRect *)pr
prevBitmap:(PoCoBitmap *)pbmp
    index:(int)idx
 undoName:(NSString *)name;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
