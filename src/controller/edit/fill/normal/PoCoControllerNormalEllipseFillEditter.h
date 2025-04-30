//
//	Pelistina on Cocoa - PoCo -
//	塗りつぶし円/楕円 - 通常
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoControllerEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerNormalEllipseFillEditter : PoCoControllerEllipseEditterBase
{
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   eraser:(PoCoColorPattern *)eraser
     tile:(PoCoTilePattern *)tile
    start:(PoCoPoint *)s
      end:(PoCoPoint *)e
orientation:(PoCoPoint *)o
    index:(int)idx;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
