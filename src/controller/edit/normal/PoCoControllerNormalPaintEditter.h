//
//	Pelistina on Cocoa - PoCo -
//	塗りつぶし(seed paint) - 通常
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerNormalPaintEditter : PoCoControllerEditterBase
{
    PoCoPoint *pos_;                    // 始点
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   eraser:(PoCoColorPattern *)eraser
     tile:(PoCoTilePattern *)tile
      pos:(PoCoPoint *)p
    index:(int)idx;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
