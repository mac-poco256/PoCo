//
//	Pelistina on Cocoa - PoCo -
//	切り抜き
//
//	Copyright (C) 2005-2019 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerPictureImageClipper : PoCoControllerBase
{
    PoCoRect *rect_;                    // 矩形枠
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
     rect:(PoCoRect *)r;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
