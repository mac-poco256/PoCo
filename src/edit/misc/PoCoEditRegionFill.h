//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 任意領域
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditNormalBase.h"

// ----------------------------------------------------------------------------
@interface PoCoEditRegionFill : PoCoEditNormalBase
{
    BOOL dist_;                         // 描画対象の上塗り確認
}

// initializer
-(id)initWithPattern:(PoCoBitmap *)bmp
             palette:(PoCoPalette *)plt
                tile:(PoCoMonochromePattern *)tile
             pattern:(PoCoColorPattern *)pat
           checkDist:(BOOL)dist;

// deallocate
-(void)dealloc;

// 実行
-(void)executeDraw:(PoCoBitmap *)mask
      withStartPos:(PoCoPoint *)s
        withEndPos:(PoCoPoint *)e;

@end
