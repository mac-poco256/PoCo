//
//	Pelistina on Cocoa - PoCo -
//	パレット補助属性切り替え部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// 参照 class の宣言
@class PoCoColorBuffer;

// ----------------------------------------------------------------------------
@interface PoCoControllerPaletteAttributeSetter : PoCoControllerBase
{
    int startNum_;                      // 設定色番号始点
    int endNum_;                        // < 0 : 単一色  >= 0 : 設定色番号終点
    BOOL setType_;                      // 単一色の場合の設定内容
    const BOOL *maskTable_;             // 上塗り禁止の設定内容
    const BOOL *dropperTable_;          // 吸い取り禁止の設定内容
    const BOOL *transTable_;            // 透過の設定内容
    PoCoColorBuffer *colorBuffer_;      // 色保持情報
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
  withNum:(int)num
  setType:(BOOL)s
     mask:(BOOL)m
  dropper:(BOOL)d
    trans:(BOOL)t;
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
withStart:(int)s
  withEnd:(int)e
     mask:(const BOOL *)m
  dropper:(const BOOL *)d
    trans:(const BOOL *)t;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
