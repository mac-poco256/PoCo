//
//	Pelistina on Cocoa - PoCo -
//	レイヤー統合
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// 参照 class の宣言
@class PoCoBitmapLayer;

// ----------------------------------------------------------------------------
@interface PoCoControllerPictureLayerUnificater : PoCoControllerBase
{
}

// 統合画像の生成
+(PoCoBitmapLayer *)createUnificatePicture:(PoCoPicture *)pict
                                   isFirst:(BOOL)first;

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
