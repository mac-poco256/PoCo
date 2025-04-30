//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 標準 - 直線の描画
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditNormalBase.h"

// ----------------------------------------------------------------------------
@interface PoCoEditNormalDrawLine : PoCoEditNormalBase
{
    NSMutableArray *points_;            // 支点
    PoCoRect *drawRect_;                // 描画範囲
}

// initialize
-(id)initWithPattern:(PoCoBitmap *)bmp
             palette:(PoCoPalette *)plt
                 pen:(PoCoMonochromePattern *)pen
                tile:(PoCoMonochromePattern *)tile
             pattern:(PoCoColorPattern *)pat;

// deallocate
-(void)dealloc;

// 点の登録
-(void)addPoint:(PoCoPoint *)p;

// 実行
-(void)executeDraw;

@end
