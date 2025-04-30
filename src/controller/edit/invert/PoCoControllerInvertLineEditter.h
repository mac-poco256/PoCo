//
//	Pelistina on Cocoa - PoCo -
//	直線 - 反転
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//
// 直線を描くときのガイドライン用であり、undo は効かない
//

#import "PoCoControllerEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerInvertLineEditter : PoCoControllerEditterBase
{
    PoCoPoint *startPos_;               // 描画始点(中心点)
    PoCoPoint *endPos_;                 // 描画終点(中心点)
}

// initialize
-(id)init:(PoCoPicture *)pict
    start:(PoCoPoint *)s
      end:(PoCoPoint *)e
    index:(int)idx;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
