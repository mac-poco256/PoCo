//
//	Pelistina on Cocoa - PoCo -
//	編集部基底
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoPicture.h"
#import "PoCoEditInfo.h"

// 参照 class の宣言
@class PoCoControllerFactory;

// ----------------------------------------------------------------------------
@interface PoCoControllerBase : NSObject
{
    PoCoPicture *picture_;              // 編集対象画像
    PoCoEditInfo *editInfo_;            // 編集情報
    NSUndoManager *undoManager_;        // 取り消し情報
    PoCoControllerFactory *factory_;    // 編集部の生成部
}

// initialize
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo;

// deallocate
-(void)dealloc;

// 取り消し名称の設定
-(void)setUndoName:(NSString *)name;

// 編集実行
-(BOOL)execute;

// 取り消し情報の生成
-(void)createUndo;

@end
