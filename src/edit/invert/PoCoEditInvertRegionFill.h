//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 反転 - 任意領域塗りつぶし
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditInvertBase.h"

// ----------------------------------------------------------------------------
@interface PoCoEditInvertRegionFill : PoCoEditInvertBase
{
    PoCoBitmap *mask_;           // 形状マスク
    PoCoRect *drawRect_;         // 描画領域
}

// initialize
-(id)initWithBitmap:(PoCoBitmap *)bmp
     withMaskBitmap:(PoCoBitmap *)mask
       withDrawRect:(PoCoRect *)dr
         isZeroOnly:(BOOL)z;

// deallocate
-(void)dealloc;

// 実行
-(void)executeDraw;

@end
