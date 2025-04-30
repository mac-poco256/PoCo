//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 標準 - 塗りつぶし
//
//	Copyright (C) 2005-2019 KAENRYUU Koutoku.
//

#import "PoCoEditNormalBase.h"

// ----------------------------------------------------------------------------
@interface PoCoEditNormalPaint : PoCoEditNormalBase
{
    PoCoRect *drect_;                   // 実描画範囲
    NSMutableArray *points_;            // 点
    PoCoBitmap *mask_;                  // 描画済みマスク
    int range_;                         // 範囲
    int baseCol_;                       // 基本色(始点色)
    BOOL acceptable_[COLOR_MAX];        // 許容色
}

// initialize
-(id)initWithPattern:(PoCoBitmap *)bmp
             palette:(PoCoPalette *)plt
                tile:(PoCoMonochromePattern *)tile
             pattern:(PoCoColorPattern *)pat
               range:(int)rng;

// deallocate
-(void)dealloc;

// 実描画範囲を取得
-(PoCoRect *)drect;

// 描画済みマスクを取得
-(PoCoBitmap *)mask;

// 実行
-(void)executeDraw:(PoCoPoint *)p;

@end


// ----------------------------------------------------------------------------
@interface PoCoEditNormalBorderPaint : PoCoEditNormalPaint
{
    PoCoSelColor *border_;              // 境界色
}

// initialize
-(id)initWithPattern:(PoCoBitmap *)bmp
             palette:(PoCoPalette *)plt
                tile:(PoCoMonochromePattern *)tile
             pattern:(PoCoColorPattern *)pat
              border:(PoCoSelColor *)bcol;

// deallocate
-(void)dealloc;

// 実行
// -(void)executeDraw:(PoCoPoint *)p;

@end
