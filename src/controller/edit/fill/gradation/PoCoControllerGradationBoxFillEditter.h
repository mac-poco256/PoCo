//
//	Pelistina on Cocoa - PoCo -
//	塗りつぶし矩形枠 - グラデーション
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku. 
//

#import "PoCoControllerFillEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerGradationBoxFillEditter : PoCoControllerBoxFillEditterBase
{
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   eraser:(PoCoColorPattern *)eraser
   buffer:(PoCoColorBuffer *)buf
    start:(PoCoPoint *)s
      end:(PoCoPoint *)e
orientation:(PoCoPoint *)o
    index:(int)idx;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
