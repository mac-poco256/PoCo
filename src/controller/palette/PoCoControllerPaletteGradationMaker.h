//
//	Pelistina on Cocoa - PoCo -
//	パレットグラデーション生成部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// 参照 class の宣言
@class PoCoColorBuffer;

// ----------------------------------------------------------------------------
@interface PoCoControllerPaletteGradationMaker : PoCoControllerBase
{
    int startNum_;                      // 始点色番号
    int endNum_;                        // 終点色番号
    PoCoColorBuffer *colorBuffer_;      // 色保持情報
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
 startNum:(int)s
   endNum:(int)e;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

// 取り消しを生成
-(void)createUndo;

@end
