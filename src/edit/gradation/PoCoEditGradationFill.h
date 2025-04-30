//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - グラデーション - 領域塗りつぶし
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoLayer.h"
#import "PoCoPalette.h"
#import "PoCoColorPattern.h"
#import "PoCoColorBuffer.h"
#import "PoCoMonochromePattern.h"

// ----------------------------------------------------------------------------
@interface PoCoEditGradationFill : NSObject
{
    PoCoBitmap *bitmap_;                // 編集対象
    PoCoColorMode colMode_;             // 色演算モード
    PoCoPalette *palette_;              // 使用パレット
    PoCoColorPattern *pattern_;         // 使用カラーパターン
    PoCoColorBuffer *colorBuffer_;      // 色保持情報
    int density_;                       // 濃度(0.1%単位)
    int ratio_;                         // 頻度(0.1%単位)
}

// initialize
-(id)init:(PoCoBitmap *)bmp
  colMode:(PoCoColorMode)cmode
  palette:(PoCoPalette *)plt
  pattern:(PoCoColorPattern *)pat
   buffer:(PoCoColorBuffer *)buf
    ratio:(int)ratio;

// deallocate
-(void)dealloc;

// 更新
-(void)replaceDensity:(int)d
           withBitmap:(PoCoBitmap *)bmp;

// 実行
-(void)executeDraw:(PoCoBitmap *)mask
          withTile:(PoCoMonochromePattern *)tile
      withTrueRect:(PoCoRect *)trueRect
      withDrawRect:(PoCoRect *)drawRect;

@end
