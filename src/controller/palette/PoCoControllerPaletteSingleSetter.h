//
//	Pelistina on Cocoa - PoCo -
//	単一パレット要素設定部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// 参照 class の宣言
@class PoCoColorBuffer;

// ----------------------------------------------------------------------------
@interface PoCoControllerPaletteSingleSetter : PoCoControllerBase
{
    int paletteNum_;                    // 対象色番号
    unsigned char red_;                 // 赤
    unsigned char green_;               // 緑
    unsigned char blue_;                // 青
    BOOL isMask_;                       // 上書き禁止
    BOOL noDrop_;                       // 吸い取り禁止
    BOOL isTrans_;                      // 透明指定
    NSString *undoName_;                // 取り消し名称
    PoCoColorBuffer *colorBuffer_;      // 色保持情報
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
      num:(int)num
      red:(unsigned char)r
   green:(unsigned char)g
    blue:(unsigned char)b
  isMask:(BOOL)mask
  noDrop:(BOOL)drop
 isTrans:(BOOL)trans
    name:(NSString *)name;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

// 取り消しの生成
-(void)createUndo;

@end
