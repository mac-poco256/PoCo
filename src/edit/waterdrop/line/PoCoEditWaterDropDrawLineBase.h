//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - ぼかし - 直線基底
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//
// 具象 class で [pointSize] と [drawPoint] を実装すること
//

#import <Cocoa/Cocoa.h>

#import "PoCoEditWaterDropBase.h"

// ----------------------------------------------------------------------------
@interface PoCoEditWaterDropDrawLineBase : PoCoEditWaterDropBase
{
    NSMutableArray *points_;            // 描画する点
    PoCoRect *drawRect_;                // 描画範囲
}

// initialize
-(id)init:(PoCoBitmap *)bmp
  colMode:(PoCoColorMode)cmode
  palette:(PoCoPalette *)plt
   buffer:(PoCoColorBuffer *)buf;

// deallocate
-(void)dealloc;

// 点を登録
-(void)addPoint:(PoCoPoint *)p;

// 点を解放
-(void)clearPoint;

// 実行
-(void)executeDraw;

// 描画範囲(基底では 0 固定)
-(int)pointSize;

// 点の描画(基底では何もしない)
-(void)drawPoint:(PoCoPoint *)p;

@end
