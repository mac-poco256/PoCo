//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 反転 - 任意領域境界
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditInvertRegionBorder.h"

// ============================================================================
@implementation PoCoEditInvertRegionBorder

// --------------------------------------------------------- instance - private
//
// 水平走査
//  水平を先に走査する上、進行方向のみにしか進まないので drawn_ については
//  塗ったことを記憶するのみ
//  塗ったあとかは評価しない(進行方向のみなので初めて塗るしかない)
//
//  Call
//    bitmap_   : 描画対象 bitmap(基底 instance 変数)
//    zeroOnly_ : 0x00 のみを反転対象とする(基底 instance 変数)
//    mask_     : 形状マスク(instance 変数)
//    drawRect_ : 描画領域(instance 変数)
//    r_        : 描画対象の矩型枠(clipping したもの)(instance 変数)
//    p_        : 処理中の点(instance 変数)
//    drawn_    : 塗装済みの記憶領域(instance 変数)
//    brow_     : 描画対象の rowbyets(instance 変数)
//    mrow_     : 形状の rowbytes(instance 変数)
//    drow_     : 塗装済みの rowbytes(instance 変数)
//    bskip_    : 描画対象の次の行までのアキ(instance 変数)
//    mskip_    : 形状の次の行までのアキ(instance 変数)
//    dskip_    : 塗装済みの次の行までのアキ(instance 変数)
//
//  Return
//    bitmap_ : 描画対象 bitmap(基底 instance 変数)
//    p_      : 処理中の点(instance 変数)
//    drawn_  : 塗装済みの記憶領域(instance 変数)
//
-(void)horiScan
{
    unsigned char *bbmp;                // 描画対象の走査用
    const unsigned char *mbmp;          // 形状の走査用
    unsigned char *dbmp;                // 塗装済みの走査用
    unsigned char flag;

    // 各種走査用ビットマップを取得
    bbmp = ([self->bitmap_ pixelmap] + (([self->drawRect_ top] * self->brow_) + [self->drawRect_ left]));
    mbmp = [self->mask_ pixelmap];
    dbmp = [self->drawn_ pixelmap];

    // 走査/描画
    for ([self->p_ setY:[self->drawRect_ top]];
         [self->p_ y] < [self->drawRect_ bottom];
         [self->p_ moveY:1]) {
        flag = 0x00;
        for ([self->p_ setX:[self->drawRect_ left]];
             [self->p_ x] < [self->drawRect_ right];
             [self->p_ moveX:1]) {
             if ((*(mbmp) != flag) &&
                 ((!(self->zeroOnly_)) || (*(bbmp) == 0x00))) {
                if ([self->r_ isPointInRect:self->p_]) {
                    if (flag) {
                        // 1->0 の変化だと範囲を抜けるので直前の点を対象にする
                        if ([self->p_ x] >= ([self->r_ left] + 1)) {
                            *(bbmp - 1) ^= 0xff;
                            *(dbmp - 1) = 1;
                        }
                    } else {
                        // 0->1 の変化だと範囲に入るのでその点を対象にする
                        *(bbmp) ^= 0xff;
                        *(dbmp) = 1;
                    }
                }
                flag = *(mbmp);
            }

            // 次へ
            (bbmp)++;
            (mbmp)++;
            (dbmp)++;
        }

        // 範囲内のままなので直前の点は対象に含む
        if ((flag) &&
            ([self->r_ isPointInRect:self->p_]) &&
            ([self->p_ x] >= ([self->r_ left] + 1))) {
            *(bbmp - 1) ^= 0xff;
            *(dbmp - 1) = 1;
        }

        // 次へ
        bbmp += self->bskip_;
        mbmp += self->mskip_;
        dbmp += self->dskip_;
    }

    return;
}


//
// 垂直走査
//  垂直が後なので水平ですでに塗ったかを評価する
//  逆に塗ったあとかどうかは記憶しない(垂直も進行方向にしか進めるのであって
//  次がない(上塗りがない)ので記憶する必要がない)
//
//  Call
//    bitmap_   : 描画対象 bitmap(基底 instance 変数)
//    zeroOnly_ : 0x00 のみを反転対象とする(基底 instance 変数)
//    mask_     : 形状マスク(instance 変数)
//    drawRect_ : 描画領域(instance 変数)
//    r_        : 描画対象の矩型枠(clipping したもの)(instance 変数)
//    p_        : 処理中の点(instance 変数)
//    drawn_    : 塗装済みの記憶領域(instance 変数)
//    brow_     : 描画対象の rowbyets(instance 変数)
//    mrow_     : 形状の rowbytes(instance 変数)
//    drow_     : 塗装済みの rowbytes(instance 変数)
//    bskip_    : 描画対象の次の行までのアキ(instance 変数)
//    mskip_    : 形状の次の行までのアキ(instance 変数)
//    dskip_    : 塗装済みの次の行までのアキ(instance 変数)
//
//  Return
//    bitmap_ : 描画対象 bitmap(基底 instance 変数)
//    p_      : 処理中の点(instance 変数)
//    drawn_  : 塗装済みの記憶領域(instance 変数)
//
-(void)vertScan
{
    int x;
    unsigned char *bbmp;                // 描画対象の走査用
    const unsigned char *mbmp;          // 形状の走査用
    unsigned char *dbmp;                // 塗装済みの走査用
    unsigned char flag;

    // 各種走査用ビットマップを取得
    bbmp = ([self->bitmap_ pixelmap] + (([self->drawRect_ top] * self->brow_) + [self->drawRect_ left]));
    mbmp = [self->mask_ pixelmap];
    dbmp = [self->drawn_ pixelmap];

    // 走査/描画
    for ([self->p_ setX:[self->drawRect_ left]], x = 0;
         [self->p_ x] < [self->drawRect_ right];
         [self->p_ moveX:1], (x)++) {
        flag = 0x00;
        for ([self->p_ setY:[self->drawRect_ top]];
             [self->p_ y] < [self->drawRect_ bottom];
             [self->p_ moveY:1]) {
             if ((*(mbmp) != flag) &&
                 ((!(self->zeroOnly_)) || (*(bbmp) == 0x00))) {
                if ([self->r_ isPointInRect:self->p_]) {
                    if (flag) {
                        // 1->0 の変化だと範囲を抜けるので直上の点を対象にする
                        if ([self->p_ y] >= 1) {
                            if (*(dbmp - self->drow_) == 0) {
                                *(bbmp - self->brow_) ^= 0xff;
                            }
                        }
                    } else {
                        // 0->1 の変化だと範囲に入るのでその点を対象にする
                        if (*(dbmp) == 0) {
                            *(bbmp) ^= 0xff;
                        }
                    }
                }
                flag = *(mbmp);
            }

            // 次へ
            bbmp += self->brow_;
            mbmp += self->mrow_;
            dbmp += self->drow_;
        }

        // 範囲内のままなので直前の点は対象に含む
        if ((flag) && ([self->p_ y] >= 1)) {
            if (*(dbmp - self->drow_) == 0) {
                *(bbmp - self->brow_) ^= 0xff;
            }
        }

        // 次へ
        bbmp = (([self->bitmap_ pixelmap] + (([self->drawRect_ top] * self->brow_) + [self->drawRect_ left])) + x);
        mbmp = ([self->mask_ pixelmap] + x);
        dbmp = ([self->drawn_ pixelmap] + x);
    }

    return;
}


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
//    r_        : 描画対象の矩型枠(clipping したもの)(instance 変数)
//    p_        : 処理中の点(instance 変数)
//    drawn_    : 塗装済みの記憶領域(instance 変数)
//    brow_     : 描画対象の rowbyets(instance 変数)
//    mrow_     : 形状の rowbytes(instance 変数)
//    bskip_    : 描画対象の次の行までのアキ(instance 変数)
//    mskip_    : 形状の次の行までのアキ(instance 変数)
//
-(id)initWithBitmap:(PoCoBitmap *)bmp
     withMaskBitmap:(PoCoBitmap *)mask
       withDrawRect:(PoCoRect *)dr
         isZeroOnly:(BOOL)z
{
//    DPRINT((@"[PoCoEditInvertRegionBorder initWithBitmap]\n"));

    // super class の初期化
    self = [super initWithBitmap:bmp
                      isZeroOnly:z];

    // 自身の初期化
    if (self != nil) {
        self->mask_ = mask;
        self->drawRect_ = dr;
        [self->mask_ retain];
        [self->drawRect_ retain];

        // 作業領域は何もない(使用していない)状態
        self->r_ = nil;
        self->p_ = nil;
        self->drawn_ = nil;
        self->brow_ = 0;
        self->mrow_ = 0;
        self->bskip_ = 0;
        self->mskip_ = 0;
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
//    r_        : 描画対象の矩型枠(clipping したもの)(instance 変数)
//    p_        : 処理中の点(instance 変数)
//    drawn_    : 塗装済みの記憶領域(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoEditInvertRegionBorder dealloc]\n"));

    // 資源の解放
    [self->mask_ release];
    [self->drawRect_ release];
    [self->drawn_ release];
    [self->p_ release];
    [self->r_ release];
    self->mask_ = nil;
    self->drawRect_ = nil;
    self->r_ = nil;
    self->p_ = nil;
    self->drawn_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//
//  Call
//    bitmap_   : 描画対象 bitmap(基底 instance 変数)
//    mask_     : 形状マスク(instance 変数)
//    drawRect_ : 描画領域(instance 変数)
//
//  Return
//    r_     : 描画対象の矩型枠(clipping したもの)(instance 変数)
//    p_     : 処理中の点(instance 変数)
//    drawn_ : 塗装済みの記憶領域(instance 変数)
//    brow_  : 描画対象の rowbyets(instance 変数)
//    mrow_  : 形状の rowbytes(instance 変数)
//    drow_  : 塗装済みの rowbytes(instance 変数)
//    bskip_ : 描画対象の次の行までのアキ(instance 変数)
//    mskip_ : 形状の次の行までのアキ(instance 変数)
//    dskip_ : 塗装済みの次の行までのアキ(instance 変数)
//
-(void)executeDraw
{
    // clipping した領域を生成
    self->r_ = [[PoCoRect alloc]
              initLeft:MAX(0, [self->drawRect_ left])
               initTop:MAX(0, [self->drawRect_ top])
             initRight:MIN([self->bitmap_ width], [self->drawRect_ right])
            initBottom:MIN([self->bitmap_ height], [self->drawRect_ bottom])];

    // 点を生成
    self->p_ = [[PoCoPoint alloc] init];

    // 塗装済みの記憶領域を生成
    self->drawn_ = [[PoCoBitmap alloc] initWidth:[self->drawRect_ width]
                                      initHeight:[self->drawRect_ height]
                                    defaultColor:0];

    // 各種値の算出
    self->brow_ = ([self->bitmap_ width] + ([self->bitmap_ width] & 0x01));
    self->mrow_ = ([self->mask_   width] + ([self->mask_   width] & 0x01));
    self->drow_ = ([self->drawn_  width] + ([self->drawn_  width] & 0x01));
    self->bskip_ = (self->brow_ - [self->drawRect_ width]);
    self->mskip_ = (self->mrow_ - [self->drawRect_ width]);
    self->dskip_ = (self->drow_ - [self->drawRect_ width]);

    // 水平走査
    [self horiScan];

    // 垂直走査
    [self vertScan];

    // 解放
    [self->drawn_ release];
    [self->p_ release];
    [self->r_ release];
    self->drawn_ = nil;
    self->p_ = nil;
    self->r_ = nil;

    return;
}

@end
