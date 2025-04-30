//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - ぼかし - 領域塗りつぶし
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoEditWaterDropBase.h"
#import "PoCoMonochromePattern.h"

// ----------------------------------------------------------------------------
@interface PoCoEditWaterDropFill : PoCoEditWaterDropBase
{
}

// initialize
-(id)init:(PoCoBitmap *)bmp
  colMode:(PoCoColorMode)cmode
  palette:(PoCoPalette *)plt
   buffer:(PoCoColorBuffer *)buf;

// deallocate
-(void)dealloc;

// 実行
-(void)executeDraw:(PoCoBitmap *)mask
          withTile:(PoCoMonochromePattern *)tile
      withTrueRect:(PoCoRect *)trueRect
      withDrawRect:(PoCoRect *)drawRect;

@end
