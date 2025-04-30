//
//	Pelistina on Cocoa - PoCo -
//	色交換
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// 参照 class の宣言
@class PoCoColorBuffer;

// ----------------------------------------------------------------------------
@interface PoCoControllerPictureColorExchanger : PoCoControllerBase
{
    BOOL active_;                       // 通知の有無
    unsigned char srcNum_;              // 交換元色番号
    unsigned char dstNum_;              // 交換先色番号
    PoCoColorBuffer *colorBuffer_;      // 色保持情報
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
   active:(BOOL)act
      src:(unsigned char)s
      dst:(unsigned char)d;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

// 取り消しの生成
-(void)createUndo;

@end
