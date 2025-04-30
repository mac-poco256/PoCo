//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - グラデーション - 直線
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoLayer.h"
#import "PoCoPalette.h"
#import "PoCoColorPattern.h"
#import "PoCoColorBuffer.h"

// ----------------------------------------------------------------------------
@interface PoCoEditGradationDrawLine : NSObject
{
    PoCoBitmap *bitmap_;                // 編集対象
    PoCoColorMode colMode_;             // 色演算モード
    PoCoPalette *palette_;              // 使用パレット
    PoCoColorPattern *pattern_;         // 使用カラーパターン
    NSMutableArray *points_;            // 描画する点
    int ratio_;                         // 頻度(0.1%単位)
    int density_;                       // 濃度(0.1%単位)
    int size_;                          // 大きさ
    BOOL flip_;                         // YES: 反転
    PoCoAtomizerSkipType posSkip_;      // 移動方法
    PoCoRect *drawRect_;                // 描画範囲
    PoCoColorBuffer *colorBuffer_;      // 色保持情報
}

// initialize
-(id)init:(PoCoBitmap *)bmp
  colMode:(PoCoColorMode)cmode
  palette:(PoCoPalette *)plt
  pattern:(PoCoColorPattern *)pat
   buffer:(PoCoColorBuffer *)buf
  penSize:(int)size;

// deallocate
-(void)dealloc;

// 点を登録
-(void)addPoint:(PoCoPoint *)p;

// 点を解放
-(void)clearPoint;

// 頻度を設定
-(void)setRatio:(int)ratio
     setDensity:(int)density
      pointSkip:(PoCoAtomizerSkipType)skip
      isFlipped:(BOOL)flag;

// 描画可否(乱数で判定)
-(BOOL)canDraw;

// 実行
-(void)executeDraw;

// 点の描画
-(void)drawPoint:(PoCoPoint *)p
          bitmap:(unsigned char *)bbmp
       bitmapRow:(const int)brow
         pattern:(const unsigned char *)pbmp
      patternRow:(const int)prow;

@end
