//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 自動グラデーション(隣接)
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoLayer.h"
#import "PoCoPalette.h"

// 参照クラス
@class PoCoAutoGradationAdjacentPair;

// ----------------------------------------------------------------------------
@interface PoCoEditAutoGradationAdjacent : NSObject
{
    // 描画対象・条件
    PoCoBitmap *srcBitmap_;             // 描画元画像
    PoCoBitmap *dstBitmap_;             // 描画先画像
    PoCoBitmap *maskBitmap_;            // 形状マスク
    PoCoPalette *palette_;              // 使用パレット
    int size_;                          // 大きさ(0: 任意、1-128 の範囲)
    const BOOL *matrix_;                // 対象色配列(256 固定長、YES: 対象)
    PoCoRect *rect_;                    // 描画範囲
    NSDictionary *sizePair_;            // 大きさと色番号の対群

    // 作業領域
    PoCoBitmap *workSrcBitmap_;         // 描画元画像
    PoCoBitmap *workDstBitmap_;         // 描画先画像
    PoCoBitmap *workMaskBitmap_;        // 形状マスク

    // 走査状態関連
    int pairNum_;                       // 対の数
    PoCoAutoGradationAdjacentPair **pair_;  // 走査用の対
    BOOL colorBuffer_[COLOR_MAX * 2];   // 色情報の退避先
}

// initialize
-(id)initDst:(PoCoBitmap *)dbmp
     withSrc:(PoCoBitmap *)sbmp
    withMask:(PoCoBitmap *)mbmp
     palette:(PoCoPalette *)plt
     penSize:(int)size
      matrix:(const BOOL *)mtx
        rect:(PoCoRect *)r
withSizePair:(NSDictionary *)sizePair;

// deallocate
-(void)dealloc;

// 実行
-(void)executeDraw;

@end
