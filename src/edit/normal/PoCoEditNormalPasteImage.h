//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 標準 - 画像貼り付け
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditNormalBase.h"

// ----------------------------------------------------------------------------
@interface PoCoEditNormalPasteImage : PoCoEditNormalBase
{
    PoCoBitmap *maskBitmap_;            // 形状マスク
    PoCoBitmap *pasteBitmap_;           // 貼り付ける画像
}

// initialize
-(id)initWithBitmap:(PoCoBitmap *)bmp
            palette:(PoCoPalette *)plt
               tile:(PoCoMonochromePattern *)tile
               mask:(PoCoBitmap *)mask
        pasteBitmap:(PoCoBitmap *)pst;

// deallocate
-(void)dealloc;

// 実行
-(void)executeDraw:(PoCoRect *)pasteRect;

@end
