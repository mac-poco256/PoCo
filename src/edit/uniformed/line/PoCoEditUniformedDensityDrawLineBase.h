//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 均一濃度 - 直線基底
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//
// 具象 class で [pointSize] と [drawPoint: bitmap: pattern:] を実装すること
//

#import <Cocoa/Cocoa.h>

#import "PoCoLayer.h"
#import "PoCoPalette.h"
#import "PoCoColorPattern.h"
#import "PoCoColorBuffer.h"

// ----------------------------------------------------------------------------
@interface PoCoEditUniformedDensityDrawLineBase : NSObject
{
    PoCoBitmap *bitmap_;                // 編集対象
    PoCoColorMode colMode_;             // 色演算モード
    PoCoPalette *palette_;              // 使用パレット
    PoCoColorPattern *pattern_;         // 使用カラーパターン
    NSMutableArray *points_;            // 描画する点
    int density_;                       // 濃度(0.1%単位)
    PoCoRect *drawRect_;                // 描画範囲
    PoCoColorBuffer *colorBuffer_;      // 色保持情報
}

// initialize
-(id)init:(PoCoBitmap *)bmp
  colMode:(PoCoColorMode)cmode
  palette:(PoCoPalette *)plt
  pattern:(PoCoColorPattern *)pat
   buffer:(PoCoColorBuffer *)buf;

// deallocate
-(void)dealloc;

// 点を登録
-(void)addPoint:(PoCoPoint *)p;

// 点を解放
-(void)clearPoint;

// 濃度を設定
-(void)setDensity:(int)dnum;

// 実行
-(void)executeDraw;

// 色演算
-(unsigned char)calcColor:(int)d2
                   color1:(unsigned char)i1
                   color2:(unsigned char)i2;

// 描画範囲(基底では 0 固定)
-(int)pointSize;

// 点の描画(基底では何もしない)
-(void)drawPoint:(PoCoPoint *)p
          bitmap:(unsigned char *)bbmp
       bitmapRow:(const int)brow
         pattern:(const unsigned char *)pbmp
      patternRow:(const int)prow;

@end
