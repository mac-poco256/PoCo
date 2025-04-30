//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 反転 - 閉じた直線群(塗りつぶし)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditInvertBase.h"

// ----------------------------------------------------------------------------
@interface PoCoEditInvertPolygon : PoCoEditInvertBase
{
    NSArray *points_;            // 支点群
    PoCoRect *drawRect_;         // 描画領域
}

// initialize
-(id)initWithBitmap:(PoCoBitmap *)bmp
         withPoints:(NSArray *)pts
       withDrawRect:(PoCoRect *)dr
         isZeroOnly:(BOOL)z;

// deallocate
-(void)dealloc;

// 実行
-(void)executeDraw;

@end
