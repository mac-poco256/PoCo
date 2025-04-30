//
//	Pelistina on Cocoa - PoCo -
//	パレット要素減算部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// 参照 class の宣言
@class PoCoColorBuffer;

// ----------------------------------------------------------------------------
@interface PoCoControllerPaletteDecrementer : PoCoControllerBase
{
    int num_;                           // 対象色番号
    BOOL isRed_;                        // YES : 赤要素を操作対象に加える
    BOOL isGreen_;                      // YES : 緑要素を操作対象に加える
    BOOL isBlue_;                       // YES : 青要素を操作対象に加える
    unsigned int step_;                 // 増減値
    int prevElm_[3];                    // 編集前の色要素
    PoCoColorBuffer *colorBuffer_;      // 色保持情報
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
      num:(int)n
      red:(BOOL)r
    green:(BOOL)g
     blue:(BOOL)b
     step:(unsigned int)s;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

// 取り消しの生成
-(void)createUndo;

@end
