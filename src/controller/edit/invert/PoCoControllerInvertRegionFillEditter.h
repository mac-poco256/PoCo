//
//	Pelistina on Cocoa - PoCo -
//	任意領域塗りつぶし - 反転
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//
// 任意領域を描くときのガイドライン用であり、undo は効かない
//

#import "PoCoControllerEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerInvertRegionFillEditter : PoCoControllerEditterBase
{
    PoCoBitmap *mask_;                  // 形状マスク
    PoCoRect* rect_;                    // 描画範囲
}

// initialize
-(id)init:(PoCoPicture *)pict
     mask:(PoCoBitmap *)mask
     rect:(PoCoRect *)r
    index:(int)idx;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
