//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 濃度 - 直線(11dot)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditDensityDrawLineBase.h"

// ----------------------------------------------------------------------------
@interface PoCoEditDensityDrawLine11 : PoCoEditDensityDrawLineBase
{
}

// initialize
-(id)init:(PoCoBitmap *)bmp
  colMode:(PoCoColorMode)cmode
  palette:(PoCoPalette *)plt
  pattern:(PoCoColorPattern *)pat
   buffer:(PoCoColorBuffer *)buf;

// deallocate
-(void)dealloc;

// 描画範囲
-(int)pointSize;

// 点の描画
-(void)drawPoint:(PoCoPoint *)p
          bitmap:(unsigned char *)bbmp
       bitmapRow:(const int)brow
         pattern:(const unsigned char *)pbmp
      patternRow:(const int)prow;

@end
