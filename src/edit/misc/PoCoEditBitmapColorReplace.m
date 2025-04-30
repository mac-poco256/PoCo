//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 色置換
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditBitmapColorReplace.h"

// ============================================================================
@implementation PoCoEditBitmapColorReplace

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    dbmp : 編集対象画像
//    sbmp : 編集元画像
//    msk  : 形状マスク
//    mtx  : 置換表
//
//  Return
//    function   : 実体
//    srcBitmap_ : 編集元画像(instance 変数)
//    dstBitmap_ : 編集対象画像(instance 変数)
//    mask_      : 形状マスク(instance 変数)
//    matrix_    : 置換表(instance 変数)
//
-(id)initTargetBitmap:(PoCoBitmap *)dbmp
     withSourceBitmap:(PoCoBitmap *)sbmp
             withMask:(PoCoBitmap *)msk
           withMatrix:(const unsigned char *)mtx
{
    DPRINT((@"[PoCoEditBitmapColorReplace initBitmap]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->srcBitmap_ = sbmp;
        self->dstBitmap_ = dbmp;
        self->mask_ = msk;
        self->matrix_ = mtx;
        [self->srcBitmap_ retain];
        [self->dstBitmap_ retain];
        [self->mask_ retain];
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
//    srcBitmap_ : 編集元画像(instance 変数)
//    dstBitmap_ : 編集対象画像(instance 変数)
//    mask_      : 形状マスク(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoEditBitmapColorReplace dealloc]\n"));

    // 資源の解放
    [self->srcBitmap_ retain];
    [self->dstBitmap_ retain];
    [self->mask_ retain];
    self->srcBitmap_ = nil;
    self->dstBitmap_ = nil;
    self->mask_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//
//  Call
//    srcBitmap_ : 編集元画像(instance 変数)
//    mask_      : 形状マスク(instance 変数)
//    matrix_    : 置換表(instance 変数)
//
//  Return
//    dstBitmap_ : 編集対象画像(instance 変数)
//
-(void)execute
{
    const int bw = [self->srcBitmap_ width];
    const int mw = [self->mask_ width];
    const int brow = (bw + (bw & 0x01));
    const int mrow = (mw + (mw & 0x01));
    const int bskip = (brow - bw);
    const int mskip = (mrow - mw);
    int x;
    int y;
    unsigned char *dbmp = [self->dstBitmap_ pixelmap];
    const unsigned char *sbmp = [self->srcBitmap_ pixelmap];
    const unsigned char *mbmp = [self->mask_ pixelmap];

    DPRINT((@"[PoCoEditBitmapColorReplace execute]\n"));

    // 垂直走査
    y = [self->srcBitmap_ height];
    do {
        // 水平走査
        x = bw;
        do {
            // 描画
            if (*(mbmp) == 0x00) {
                // 形状の範囲にない
                ;
            } else if (self->matrix_[*(sbmp)] == *(sbmp)) {
                // 変更なし
                *(dbmp) = *(sbmp);
            } else {
                // 指定の色で上書き(特にパレットの属性にも依らない)
                *(dbmp) = self->matrix_[*(sbmp)];
            }

            // 次へ
            (x)--;
            (sbmp)++;
            (dbmp)++;
            (mbmp)++;
        } while (x != 0);

        // 次へ
        (y)--;
        sbmp += bskip;
        dbmp += bskip;
        mbmp += mskip;
    } while (y != 0);

    return;
}

@end
