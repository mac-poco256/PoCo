//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - ぼかし - 直線(16dot)
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoEditWaterDropDrawLineBase.h"

// ----------------------------------------------------------------------------
@interface PoCoEditWaterDropDrawLine16 : PoCoEditWaterDropDrawLineBase
{
}

// initialize
-(id)init:(PoCoBitmap *)bmp
  colMode:(PoCoColorMode)cmode
  palette:(PoCoPalette *)plt
   buffer:(PoCoColorBuffer *)buf;

// deallocate
-(void)dealloc;

// 描画範囲
-(int)pointSize;

// 点の描画
-(void)drawPoint:(PoCoPoint *)p;

@end
