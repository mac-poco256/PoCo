//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 霧吹き - 領域塗りつぶし
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoLayer.h"
#import "PoCoPalette.h"
#import "PoCoColorPattern.h"
#import "PoCoMonochromePattern.h"

// ----------------------------------------------------------------------------
@interface PoCoEditAtomizerFill : NSObject
{
    PoCoBitmap *bitmap_;                // 編集対象
    PoCoPalette *palette_;              // 使用パレット
    PoCoColorPattern *pattern_;         // 使用カラーパターン
    int ratio_;                         // 頻度(0.1%単位)
}

// initialize
-(id)init:(PoCoBitmap *)bmp
  palette:(PoCoPalette *)plt
  pattern:(PoCoColorPattern *)pat
    ratio:(int)rat;

// deallocate
-(void)dealloc;

// 実行
-(void)executeDraw:(PoCoBitmap *)mask
          withTile:(PoCoMonochromePattern *)tile
      withTrueRect:(PoCoRect *)trueRect
      withDrawRect:(PoCoRect *)drawRect;

@end
