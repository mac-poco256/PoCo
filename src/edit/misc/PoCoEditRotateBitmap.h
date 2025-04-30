//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 任意角回転
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoLayer.h"
#import "PoCoCalcRotation.h"

// ----------------------------------------------------------------------------
@interface PoCoEditRotateBitmap : NSObject
{
    PoCoBitmap *srcBitmap_;             // 回転元画像
    PoCoBitmap *dstBitmap_;             // 回転先画像
    PoCoRect *srcRect_;                 // 回転元範囲
    PoCoRect *dstRect_;                 // 回転先範囲
    PoCoCalcRotation *rotate_;          // 回転関数
}

// initialize
-(id)initDst:(PoCoBitmap *)dbmp
     withSrc:(PoCoBitmap *)sbmp
     dstRect:(PoCoRect *)dr
     srcRect:(PoCoRect *)sr
 withRotater:(PoCoCalcRotation *)r;

// deallocate
-(void)dealloc;

// 実行
-(void)executeRotate;

@end


// ----------------------------------------------------------------------------
@interface PoCoEditRotateBitmapDouble : NSObject
{
    PoCoBitmap *srcBitmap_[2];          // 回転元画像
    PoCoBitmap *dstBitmap_[2];          // 回転先画像
    PoCoRect *srcRect_;                 // 回転元範囲
    PoCoRect *dstRect_;                 // 回転先範囲
    PoCoCalcRotation *rotate_;          // 回転関数
}

// initialize
-(id)initDst1:(PoCoBitmap *)dbmp1
     withDst2:(PoCoBitmap *)dbmp2
     withSrc1:(PoCoBitmap *)sbmp1
     withSrc2:(PoCoBitmap *)sbmp2
      dstRect:(PoCoRect *)dr
      srcRect:(PoCoRect *)sr
  withRotater:(PoCoCalcRotation *)r;

// deallocate
-(void)dealloc;

// 実行
-(void)executeRotate;

@end
