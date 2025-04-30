//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 拡散 - 領域塗りつぶし
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoLayer.h"
#import "PoCoPalette.h"
#import "PoCoColorPattern.h"
#import "PoCoMonochromePattern.h"

// ----------------------------------------------------------------------------
@interface PoCoEditRandomFill : NSObject
{
    PoCoBitmap *bitmap_;                // 編集対象
    PoCoPalette *palette_;              // 使用パレット
    int ratio_;                         // 頻度(0.1%単位)
    int range_;                         // 範囲
}

// initialize
-(id)init:(PoCoBitmap *)bmp
  palette:(PoCoPalette *)plt
    ratio:(int)rat
    range:(int)rng;

// deallocate
-(void)dealloc;

// 実行
-(void)executeDraw:(PoCoBitmap *)mask
          withTile:(PoCoMonochromePattern *)tile
      withTrueRect:(PoCoRect *)trueRect
      withDrawRect:(PoCoRect *)drawRect;

@end
