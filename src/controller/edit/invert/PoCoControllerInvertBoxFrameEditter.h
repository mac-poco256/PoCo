//
//	Pelistina on Cocoa - PoCo -
//	矩形枠 - 反転
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//
// 矩形枠を描くときのガイドライン用であり、undo は効かない
//

#import "PoCoControllerEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerInvertBoxFrameEditter : PoCoControllerBoxEditterBase
{
}

// initialize
-(id)init:(PoCoPicture *)pict
    start:(PoCoPoint *)s
      end:(PoCoPoint *)e
orientation:(PoCoPoint *)o
    index:(int)idx;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
