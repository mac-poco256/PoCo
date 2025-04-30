//
//	Pelistina on Cocoa - PoCo -
//	サイズ変更
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// 参照 class の宣言
@class PoCoBitmap;

// ----------------------------------------------------------------------------
@interface PoCoControllerPictureCanvasResizer : PoCoControllerBase
{
    BOOL isFit_;                        // 変倍
    int width_;                         // 幅
    int height_;                        // 高さ
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
    isFit:(BOOL)f
    width:(int)w
   height:(int)h;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
