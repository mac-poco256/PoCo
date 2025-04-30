//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 標準 - 基底
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoLayer.h"
#import "PoCoPalette.h"
#import "PoCoColorPattern.h"
#import "PoCoMonochromePattern.h"

// ----------------------------------------------------------------------------
@interface PoCoEditNormalBase : NSObject
{
    PoCoBitmap *bitmap_;                // 描画対象 bitmap
    PoCoPalette *palette_;              // 使用パレット
    PoCoMonochromePattern *penPattern_; // 使用ペン先
    PoCoMonochromePattern *tilePattern_;// 使用タイルパターン
    PoCoColorPattern *colorPattern_;    // 使用カラーパターン

    PoCoBitmap *tileBitmap_;            // タイルパターンの bitmap
    PoCoBitmap *colorBitmap_;           // カラーパターンの bitmap
    unsigned int tileRow_;              // タイルパターンの rowbytes
    unsigned int colorRow_;             // カラーパターンの rowbytes
    unsigned int bitmapRow_;            // 描画対象の rowbytes
    PoCoPoint *drawLeftTop_;            // 描画範囲の左上
}

// initialize
-(id)initWithPattern:(PoCoBitmap *)bmp
             palette:(PoCoPalette *)plt
                 pen:(PoCoMonochromePattern *)pen
                tile:(PoCoMonochromePattern *)tile
             pattern:(PoCoColorPattern *)pat;

// deallocate
-(void)dealloc;

// 描画関係
-(void)drawPoint:(PoCoPoint *)pnt;      // 点の描画(単独)
-(void)beginDraw:(PoCoRect *)r;         // 描画開始
-(void)endDraw;                         // 描画終了
-(void)drawPoint2:(PoCoPoint *)pnt;     // 点の描画(複数)

@end
