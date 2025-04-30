//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 反転 - 直線の描画
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditInvertBase.h"

// ----------------------------------------------------------------------------
@interface PoCoEditInvertDrawLine : PoCoEditInvertBase
{
    NSMutableArray *points_;            // 支点
}

// initialize
-(id)initWithBitmap:(PoCoBitmap *)bmp
         isZeroOnly:(BOOL)z;

// deallocate
-(void)dealloc;

// 点の登録
-(void)addPoint:(PoCoPoint *)p;

// 実行
-(void)executeDraw;

@end
