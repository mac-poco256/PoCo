//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 色置換
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoLayer.h"

// ----------------------------------------------------------------------------
@interface PoCoEditBitmapColorReplace : NSObject
{
    PoCoBitmap *srcBitmap_;             // 編集元画像
    PoCoBitmap *dstBitmap_;             // 編集対象画像
    PoCoBitmap *mask_;                  // 形状マスク
    const unsigned char *matrix_;       // 置換表(添字と色番号が同じなら対象外)
}

// initialize
-(id)initTargetBitmap:(PoCoBitmap *)dbmp
     withSourceBitmap:(PoCoBitmap *)sbmp
             withMask:(PoCoBitmap *)msk
           withMatrix:(const unsigned char *)mtx;

// deallocate
-(void)dealloc;

// 実行
-(void)execute;

@end
