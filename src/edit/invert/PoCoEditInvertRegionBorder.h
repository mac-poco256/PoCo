//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 反転 - 任意領域境界
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditInvertBase.h"

// ----------------------------------------------------------------------------
@interface PoCoEditInvertRegionBorder : PoCoEditInvertBase
{
    PoCoBitmap *mask_;                  // 形状マスク
    PoCoRect *drawRect_;                // 描画領域

    // 作業領域
    PoCoRect *r_;                       // 描画対象の矩型枠(clipping したもの)
    PoCoPoint *p_;                      // 処理中の点
    PoCoBitmap *drawn_;                 // 塗装済みの記憶領域
    int brow_;                          // 描画対象の rowbyets
    int mrow_;                          // 形状の rowbytes
    int drow_;                          // 塗装済みの rowbytes
    int bskip_;                         // 描画対象の次の行までのアキ
    int mskip_;                         // 形状の次の行までのアキ
    int dskip_;                         // 塗装済みの次の行までのアキ
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
