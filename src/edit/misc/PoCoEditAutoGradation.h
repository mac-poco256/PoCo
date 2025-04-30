//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 自動グラデーション(任意)
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoLayer.h"
#import "PoCoPalette.h"

// ----------------------------------------------------------------------------
@interface PoCoEditAutoGradation : NSObject
{
    // 描画対象・条件
    PoCoBitmap *srcBitmap_;             // 描画元画像
    PoCoBitmap *dstBitmap_;             // 描画先画像
    PoCoBitmap *maskBitmap_;            // 形状マスク
    PoCoPalette *palette_;              // 使用パレット
    int size_;                          // 大きさ(0: 任意、1-128 の範囲)
    const BOOL *matrix_;                // 対象色配列(256 固定長、YES: 対象)
    PoCoRect *rect_;                    // 描画範囲

    // 作業領域
    PoCoBitmap *workSrcBitmap_;         // 描画元画像
    PoCoBitmap *workDstBitmap_;         // 描画先画像
    PoCoBitmap *workMaskBitmap_;        // 形状マスク

    // 走査状態関連
    PoCoPoint *drawPoint_;              // 描画点
    int leftLen_;                       // 左・上のドット数
    int rightLen_;                      // 右・下のドット数
    unsigned char leftColor_;           // 左・上の色
    unsigned char rightColor_;          // 右・下の色
    PoCoAutoGradState scanState_;       // 走査状態
}

// initialize
-(id)initDst:(PoCoBitmap *)dbmp
     withSrc:(PoCoBitmap *)sbmp
    withMask:(PoCoBitmap *)mbmp
     palette:(PoCoPalette *)plt
     penSize:(int)size
      matrix:(const BOOL *)mtx
        rect:(PoCoRect *)r;

// deallocate
-(void)dealloc;

// 実行
-(void)executeDraw;

@end
