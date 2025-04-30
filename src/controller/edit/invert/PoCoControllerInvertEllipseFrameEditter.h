//
//	Pelistina on Cocoa - PoCo -
//	円/楕円 - 反転
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//
// 円/楕円を描くときのガイドライン用であり、undo は効かない
//

#import "PoCoControllerEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerInvertEllipseFrameEditter : PoCoControllerEllipseEditterBase
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
