//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 霧吹き - 直線
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoLayer.h"
#import "PoCoPalette.h"
#import "PoCoColorPattern.h"

// ----------------------------------------------------------------------------
@interface PoCoEditAtomizerDrawLine : NSObject
{
    PoCoBitmap *bitmap_;                // 編集対象
    PoCoPalette *palette_;              // 使用パレット
    PoCoColorPattern *pattern_;         // 使用カラーパターン
    NSMutableArray *points_;            // 描画する点
    int ratio_;                         // 頻度(0.1%単位)
    int size_;                          // 大きさ
    BOOL flip_;                         // YES: 反転
    PoCoAtomizerSkipType posSkip_;      // 移動方法
    BOOL patType_;                      // 種類(YES: 半値, NO: 通常)
    PoCoRect *drawRect_;                // 描画範囲
}

// initialize
-(id)init:(PoCoBitmap *)bmp
  palette:(PoCoPalette *)plt
  pattern:(PoCoColorPattern *)pat
  penSize:(int)size;

// deallocate
-(void)dealloc;

// 点を登録
-(void)addPoint:(PoCoPoint *)p;

// 点を解放
-(void)clearPoint;

// 頻度を設定
-(void)setRatio:(int)dnum
      pointSkip:(PoCoAtomizerSkipType)skip
    patternType:(BOOL)type
      isFlipped:(BOOL)flag;

// 実行
-(void)executeDraw;

// 点の描画
-(void)drawPoint:(PoCoPoint *)p
          bitmap:(unsigned char *)bbmp
       bitmapRow:(const int)brow
         pattern:(const unsigned char *)pbmp
      patternRow:(const int)prow;

@end
