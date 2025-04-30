//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 反転 - 任意領域塗りつぶし
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditInvertRegionFill.h"

// ============================================================================
@implementation PoCoEditInvertRegionFill

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp  : 描画対象 bitmap
//    mask : 形状マスク(instance 変数)
//    dr   : 描画領域(instance 変数)
//    z    : 0x00 のみを反転対象とする
//
//  Return
//    function  : 実体
//    mask_     : 形状マスク(instance 変数)
//    drawRect_ : 描画領域(instance 変数)
//
-(id)initWithBitmap:(PoCoBitmap *)bmp
     withMaskBitmap:(PoCoBitmap *)mask
       withDrawRect:(PoCoRect *)dr
         isZeroOnly:(BOOL)z
{
//    DPRINT((@"[PoCoEditInvertRegionFill initWithBitmap]\n"));

    // super class の初期化
    self = [super initWithBitmap:bmp
                      isZeroOnly:z];

    // 自身の初期化
    if (self != nil) {
        self->mask_ = mask;
        self->drawRect_ = dr;
        [self->mask_ retain];
        [self->drawRect_ retain];
    }

    return self;
}


//
// deallocate
//
//  Call
//    None
//
//  Return
//    mask_     : 形状マスク(instance 変数)
//    drawRect_ : 描画領域(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoEditInvertRegionFill dealloc]\n"));

    // 資源の解放
    [self->mask_ release];
    [self->drawRect_ release];
    self->mask_ = nil;
    self->drawRect_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//
//  Call
//    bitmap_   : 描画対象 bitmap(基底 instance 変数)
//    zeroOnly_ : 0x00 のみを反転対象とする(基底 instance 変数)
//    mask_     : 形状マスク(instance 変数)
//    drawRect_ : 描画領域(instance 変数)
//
//  Return
//    bitmap_ : 描画対象 bitmap(基底 instance 変数)
//
-(void)executeDraw
{
    PoCoRect *r;
    PoCoPoint *p;
    int brow;                           // 描画対象の rowbyets
    int mrow;                           // 形状の rowbytes
    int bskip;                          // 描画対象の次の行までのアキ
    int mskip;                          // 形状の次の行までのアキ
    unsigned char *bbmp;                // 描画対象の走査用
    const unsigned char *mbmp;          // 形状の走査用

    r = [[PoCoRect alloc]
              initLeft:MAX(0, [self->drawRect_ left])
               initTop:MAX(0, [self->drawRect_ top])
             initRight:MIN([self->bitmap_ width], [self->drawRect_ right])
            initBottom:MIN([self->bitmap_ height], [self->drawRect_ bottom])];

    // 各種値の算出
    brow = ([self->bitmap_ width] + ([self->bitmap_ width] & 0x01));
    mrow = ([self->mask_   width] + ([self->mask_   width] & 0x01));
    bskip = (brow - [self->drawRect_ width]);
    mskip = (mrow - [self->drawRect_ width]);

    // 各種走査用ビットマップを取得
    bbmp = [self->bitmap_ pixelmap] + (([self->drawRect_ top] * brow) + [self->drawRect_ left]);
    mbmp = [self->mask_ pixelmap];

    // 走査/描画
    p = [[PoCoPoint alloc] init];
    for ([p setY:[self->drawRect_ top]];
         [p y] < [self->drawRect_ bottom];
         [p moveY:1]) {
        for ([p setX:[self->drawRect_ left]];
             [p x] < [self->drawRect_ right];
             [p moveX:1]) {
            if (([r isPointInRect:p]) &&
                (*(mbmp) != 0) &&
                ((!(self->zeroOnly_)) || (*(bbmp) == 0x00))) {
                *(bbmp) ^= 0xff;
            }

            // 次へ
            (bbmp)++;
            (mbmp)++;
        }

        // 次へ
        bbmp += bskip;
        mbmp += mskip;
    }
    [p release];
    [r release];

    return;
}

@end
