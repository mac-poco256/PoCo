//
//	Pelistina on Cocoa - PoCo -
//	パレット要素設定部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// 参照 class の宣言
@class PoCoPalette;
@class PoCoColorBuffer;

// ----------------------------------------------------------------------------
@interface PoCoControllerPaletteElementSetter : PoCoControllerBase
{
    PoCoPalette *palette_;              // 設定内容
    PoCoColorBuffer *colorBuffer_;      // 色保持情報
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
  palette:(PoCoPalette *)pal;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

// 取り消しの生成
-(void)createUndo;

@end
