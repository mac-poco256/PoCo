//
//	Pelistina on Cocoa - PoCo -
//	画像レイヤー追加部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerLayerBitmapAdder : PoCoControllerBase
{
    unsigned char color_;
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
    color:(unsigned char)c;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

// 取り消しを生成
-(void)createUndo;

@end
