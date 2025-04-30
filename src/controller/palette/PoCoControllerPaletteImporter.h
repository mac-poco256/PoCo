//
//	Pelistina on Cocoa - PoCo -
//	パレット取り込み
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// 参照 class の宣言
@class PoCoPalette;
@class PoCoColorBuffer;

// ----------------------------------------------------------------------------
@interface PoCoControllerPaletteImporter : PoCoControllerBase
{
    PoCoPalette *targetPalette_;        // 設定内容
    BOOL targetFlags_[COLOR_MAX];       // 設定対象
    PoCoColorBuffer *colorBuffer_;      // 色保持情報
}

// initialize
-(id)init:(PoCoPicture *)pict
         info:(PoCoEditInfo *)info
         undo:(NSUndoManager *)undo
       buffer:(PoCoColorBuffer *)buf
targetPalette:(PoCoPalette *)target
    withFlags:(const BOOL *)flags;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

// 取り消しの生成
-(void)createUndo;

@end
