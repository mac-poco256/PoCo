//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 拡散 - 直線
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoLayer.h"
#import "PoCoPalette.h"
#import "PoCoMonochromePattern.h"

// ----------------------------------------------------------------------------
@interface PoCoEditRandomDrawLine : NSObject
{
    PoCoBitmap *bitmap_;                // 編集対象
    PoCoPalette *palette_;              // 使用パレット
    PoCoMonochromePattern *tilePattern_;// タイルパターン
    NSMutableArray *points_;            // 描画する点
    int ratio_;                         // 頻度(0.1%単位)
    int range_;                         // 範囲
    PoCoRect *drawRect_;                // 描画範囲
}

// initialize
-(id)init:(PoCoBitmap *)bmp
  palette:(PoCoPalette *)plt
     tile:(PoCoMonochromePattern *)tile
    ratio:(int)rat
    range:(int)rng;

// deallocate
-(void)dealloc;

// 点を登録
-(void)addPoint:(PoCoPoint *)p;

// 点を解放
-(void)clearPoint;

// 実行
-(void)executeDraw;

@end
