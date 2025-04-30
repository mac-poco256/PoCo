//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 自動グラデーション(任意)
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import "PoCoEditAutoGradation.h"

#import "PoCoColorPattern.h"
#import "PoCoEditAtomizerDrawLine.h"

// ============================================================================
@implementation PoCoEditAutoGradation

// --------------------------------------------------------- instance - private
//
// 半値霧吹きで描画
//
//  Call
//    col        : 描画色
//    size       : 大きさ(実ドット数なので 1-128 の範囲)
//    flip       : 反転か(YES: 反転を使用)
//    hori       : 水平走査か(YES: 水平走査)
//    high       : 上から下の色遷移か(YES: 上から下、NO: 下から上)
//                 (手前の色番号から後ろの色番号への遷移か)
//    palette_   : 使用パレット(instance 変数)
//    drawPoint_ : 描画点(instance 変数)
//
//  Return
//    workDstBitmap_ : 描画先画像(instance 変数)
//
-(void)executeHalfAtomizer:(unsigned char)col
                      size:(int)size
                    isFlip:(BOOL)flip
                    isHori:(BOOL)hori
                    isHigh:(BOOL)high
{
    PoCoEditAtomizerDrawLine *edit;
    PoCoColorPattern *pat;
    int s;
    PoCoPoint *p;

    pat = nil;
    edit = nil;
    s = (size / 8);                     // 霧吹きパターン用は実サイズ / 8
    p = [[PoCoPoint alloc] initX:[self->drawPoint_ x]
                           initY:[self->drawPoint_ y]];

#if 0   // そもそもこの調整は必要なのかしら?
    // 逆方向の場合に位置調整
    if (flip) {
        if (hori) {
            if (high) {
                // 上から下の切り替えなので位置を右に移動
                [p moveX:(s / 2)];
            } else {
                // 下から上の切り替えなので位置を左に移動
                [p moveX:-(s + (s / 2))];
            }
        } else {
            if (high) {
                // 上から下の切り替えなので位置を下に移動
                [p moveY:(s / 2)];
            } else {
                // 下から上の切り替えなので位置を上に移動
                [p moveY:-(s + (s / 2))];
            }
        }
    }
#endif  // 0

    // カラーパターンを生成
    pat = [[PoCoColorPattern alloc] initWidth:1
                                   initHeight:1
                                 defaultColor:col];

    // 描画系を生成
    edit = [[PoCoEditAtomizerDrawLine alloc]
                  init:self->workDstBitmap_
               palette:self->palette_
               pattern:pat
               penSize:s];
    [edit setRatio:1000
         pointSkip:PoCoAtomizerSkipType_Pattern
       patternType:YES
         isFlipped:flip];

    // 線分には同じ点を指定
    [edit addPoint:p];
    [edit addPoint:p];

    // 描画実行
    [edit executeDraw];

    // 解放
    [edit release];
    [pat release];

    [p release];
    return;
}


//
// 描画実行
//
//  Call
//    isHori      : 水平走査か(YES: 水平走査)
//    size_       : 大きさ(0: 任意、1-128 の範囲)(instance 変数)
//    leftLen_    : 左・上のドット数(instance 変数)
//    rightLen_   : 右・下のドット数(instance 変数)
//    leftColor_  : 左・上の色(instance 変数)
//    rightColor_ : 右・下の色(instance 変数)
//
//  Return
//    None
//
-(void)draw:(BOOL)isHori
{
    int size;
    BOOL isFlip;
    BOOL isHigh;

    // 色の前後関係で塗りを変える
    if (self->leftColor_ < self->rightColor_) {
        // 手前の色番号から後ろの色番号への遷移
        isFlip = NO;
        isHigh = YES;
    } else {
        // 手前の色番号から後ろの色番号への遷移
        isFlip = YES;
        isHigh = NO;
    }

    // 左・上の色
    if (self->size_ == 0) {
        size = MIN(self->leftLen_, 128);
    } else {
        size = self->size_;
    }
    [self executeHalfAtomizer:self->leftColor_
                         size:size
                       isFlip:isFlip
                       isHori:isHori
                       isHigh:isHigh];

    // 右・上の色
    if (self->size_ == 0) {
        size = MIN(self->rightLen_, 128);
    } else {
        size = self->size_;
    }
    [self executeHalfAtomizer:self->rightColor_
                         size:size
                       isFlip:!(isFlip)
                       isHori:isHori
                       isHigh:isHigh];

    return;
}


//
// 到達点を検証
//
//  Call
//    srcColor    : 描画元の色
//    mask        : 形状マスク
//    x           : 水平位置
//    y           : 垂直位置
//    isHori      : 水平走査か(YES: 水平走査)
//    matrix_     : 対象色配列(256 固定長、YES: 対象)(instance 変数)
//    leftLen_    : 左・上のドット数(instance 変数)
//    rightLen_   : 右・下のドット数(instance 変数)
//    leftColor_  : 左・上の色(instance 変数)
//    rightColor_ : 右・下の色(instance 変数)
//    scanState_  : 走査状態(instance 変数)
//
//  Return
//    drawPoint_  : 描画点(instance 変数)
//    leftLen_    : 左・上のドット数(instance 変数)
//    rightLen_   : 右・下のドット数(instance 変数)
//    leftColor_  : 左・上の色(instance 変数)
//    rightColor_ : 右・下の色(instance 変数)
//    scanState_  : 走査状態(instance 変数)
//
-(void)inspectAttachedPoint:(unsigned char)srcColor
                   withMask:(unsigned char)mask
                    horiPos:(int)x
                    vertPos:(int)y
                 isHoriScan:(BOOL)isHori
{
    if (mask) {
        if (self->scanState_ == PoCoAutoGrad_NoneAttach) {
            // 始点を探している
            if (self->matrix_[srcColor]) {
                // 対象色なので始点に達した
                self->leftLen_ = 1;
                self->leftColor_ = srcColor;

                // 状態遷移
                self->scanState_ = PoCoAutoGrad_StartAttached;
            }
        } else if (self->scanState_ == PoCoAutoGrad_StartAttached) {
            // 始点には達した(中点を探している)
            if (self->leftColor_ == srcColor) {
                // 始点と同じ色のままなので継続
                (self->leftLen_)++;
            } else if (self->matrix_[srcColor]) {
                // 始点とは違う色だけど対象色なので中点に達した
                self->rightLen_ = 1;
                self->rightColor_ = srcColor;

                // 中点が描画位置
                [self->drawPoint_ setX:x
                                  setY:y];

                // 状態遷移
                self->scanState_ = PoCoAutoGrad_MiddleAttached;
            } else {
                // 対象色ではないものは中点にならないので何もしない
                self->leftLen_ = 0;
                self->rightLen_ = 0;
                self->leftColor_ = 0;
                self->rightColor_ = 0;

                // 状態遷移
                self->scanState_ = PoCoAutoGrad_NoneAttach;
            }
        } else if (self->scanState_ == PoCoAutoGrad_MiddleAttached) {
            // 始点・中点に達した(終点を探している)
            if (self->rightColor_ == srcColor) {
                // 中点と同じ色のままなので継続
                (self->rightLen_)++;
            } else {
                // 終点に達したので塗りを実行
                [self draw:isHori];

                // 続きに入る
                if (self->matrix_[srcColor]) {
                    // 対象色なので中点に達した扱いにする
                    self->leftLen_ = self->rightLen_;
                    self->rightLen_ = 1;
                    self->leftColor_ = self->rightColor_;
                    self->rightColor_ = srcColor;

                    // 終点が次の中点となる(描画位置になる)
                    [self->drawPoint_ setX:x
                                      setY:y];

                    // 状態遷移はしないで終点を探す
                    ;
                } else {
                    // 対象色ではない部分なので最初に戻る
                    self->leftLen_ = 0;
                    self->rightLen_ = 0;
                    self->leftColor_ = 0;
                    self->rightColor_ = 0;

                    // 状態遷移
                    self->scanState_ = PoCoAutoGrad_NoneAttach;
                }
            }
        }
    } else {
        // 形状に含まない範囲
        if (self->scanState_ == PoCoAutoGrad_NoneAttach) {
            // そもそもどこにも達していない
            ;
        } else if (self->scanState_ == PoCoAutoGrad_StartAttached) {
            // 始点には達しているけど中点には達していない
            ;
        } else if (self->scanState_ == PoCoAutoGrad_MiddleAttached) {
            // 始点・中点には達していたので終点に達した扱いとして塗り
            [self draw:isHori];
        }

        // 範囲を抜ける
        self->leftLen_ = 0;
        self->rightLen_ = 0;
        self->leftColor_ = 0;
        self->rightColor_ = 0;

        // 状態遷移
        self->scanState_ = PoCoAutoGrad_NoneAttach;
    }

    return;
}


//
// 水平走査
//
//  Call
//    workSrcBitmap_  : 描画元画像(instance 変数)
//    workMaskBitmap_ : 形状マスク(instance 変数)
//
//  Return
//    leftLen_    : 左・上のドット数(instance 変数)
//    rightLen_   : 右・下のドット数(instance 変数)
//    leftColor_  : 左・上の色(instance 変数)
//    rightColor_ : 右・下の色(instance 変数)
//    scanState_  : 走査状態(instance 変数)
//
-(void)scanHori
{
    const int w = [self->workSrcBitmap_ width];
    const int h = [self->workSrcBitmap_ height];
    const int row = (w + (w & 0x01));
    const int skip = (row - w);
    int x;
    int y;
    unsigned char *sp = [self->workSrcBitmap_ pixelmap];
    unsigned char *mp = [self->workMaskBitmap_ pixelmap];

    DPRINT((@"[PoCoEditAutoGradation scanHori]\n"));

    // 垂直走査
    y = 0;
    do {
        // １ラインごとに常に初期状態に戻す
        self->leftLen_ = 0;
        self->rightLen_ = 0;
        self->leftColor_ = 0;
        self->rightColor_ = 0;
        self->scanState_ = PoCoAutoGrad_NoneAttach;

        // 水平走査
        x = 0;
        do {
            // 到達点を検証
            [self inspectAttachedPoint:*(sp)
                              withMask:*(mp)
                               horiPos:x
                               vertPos:y
                            isHoriScan:YES];

            // 次へ
            (x)++;
            (sp)++;
            (mp)++;
        } while (x < w);

        // 始点・中点には達していた状態で端に達したので塗り
        if (self->scanState_ == PoCoAutoGrad_MiddleAttached) {
            [self draw:YES];
        }

        // 次へ
        (y)++;
        sp += skip;
        mp += skip;
    } while (y < h);

    return;
}


//
// 垂直走査
//
//  Call
//    workSrcBitmap_  : 描画元画像(instance 変数)
//    workMaskBitmap_ : 形状マスク(instance 変数)
//
//  Return
//    leftLen_    : 左・上のドット数(instance 変数)
//    rightLen_   : 右・下のドット数(instance 変数)
//    leftColor_  : 左・上の色(instance 変数)
//    rightColor_ : 右・下の色(instance 変数)
//    scanState_  : 走査状態(instance 変数)
//
-(void)scanVert
{
    const int w = [self->workSrcBitmap_ width];
    const int h = [self->workSrcBitmap_ height];
    const int row = (w + (w & 0x01));
    int x;
    int y;
    unsigned char *sp = [self->workSrcBitmap_ pixelmap];
    unsigned char *mp = [self->workMaskBitmap_ pixelmap];

    DPRINT((@"[PoCoEditAutoGradation scanVert]\n"));

    // 水平走査
    x = 0;
    do {
        // １ラインごとに常に初期状態に戻す
        self->leftLen_ = 0;
        self->rightLen_ = 0;
        self->leftColor_ = 0;
        self->rightColor_ = 0;
        self->scanState_ = PoCoAutoGrad_NoneAttach;

        // 垂直走査
        y = 0;
        do {
            // 到達点を検証
            [self inspectAttachedPoint:*(sp)
                              withMask:*(mp)
                               horiPos:x
                               vertPos:y
                            isHoriScan:NO];

            // 次へ
            (y)++;
            sp += row;
            mp += row;
        } while (y < h);

        // 始点・中点には達していた状態で端に達したので塗り
        if (self->scanState_ == PoCoAutoGrad_MiddleAttached) {
            [self draw:NO];
        }

        // 次へ
        (x)++;
        sp = ([self->workSrcBitmap_ pixelmap] + x);
        mp = ([self->workMaskBitmap_ pixelmap] + x);
    } while (x < w);

    return;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    dbmp : 描画先画像
//    sbmp : 描画元画像
//    mbmp : 形状マスク
//    plt  : 使用パレット
//    size : 大きさ(0: 任意、1-128 の範囲)
//    mtx  : 対象色配列(256 固定長、YES: 対象)
//    r    : 描画範囲
//
//  Return
//    function        : 実体
//    srcBitmap_      : 描画元画像(instance 変数)
//    dstBitmap_      : 描画先画像(instance 変数)
//    maskBitmap_     : 形状マスク(instance 変数)
//    palette_        : 使用パレット(instance 変数)
//    size_           : 大きさ(0: 任意、1-128 の範囲)(instance 変数)
//    matrix_         : 対象色配列(256 固定長、YES: 対象)(instance 変数)
//    rect_           : 描画範囲(instance 変数)
//    workSrcBitmap_  : 描画元画像(作業領域)(instance 変数)
//    workDstBitmap_  : 描画先画像(作業領域)(instance 変数)
//    workMaskBitmap_ : 形状マスク(作業領域)(instance 変数)
//    drawPoint_      : 描画点(instance 変数)
//    leftLen_        : 左・上のドット数(instance 変数)
//    rightLen_       : 右・下のドット数(instance 変数)
//    leftColor_      : 左・上の色(instance 変数)
//    rightColor_     : 右・下の色(instance 変数)
//    scanState_      : 走査状態(instance 変数)
//
-(id)initDst:(PoCoBitmap *)dbmp
     withSrc:(PoCoBitmap *)sbmp
    withMask:(PoCoBitmap *)mbmp
     palette:(PoCoPalette *)plt
     penSize:(int)size
      matrix:(const BOOL *)mtx
        rect:(PoCoRect *)r
{
    DPRINT((@"[PoCoEditAutoGradation init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->srcBitmap_ = sbmp;
        self->dstBitmap_ = dbmp;
        self->maskBitmap_ = mbmp;
        self->palette_ = plt;
        self->size_ = size;
        self->matrix_ = mtx;
        self->rect_ = r;
        self->workSrcBitmap_ = nil;
        self->workDstBitmap_ = nil;
        self->workMaskBitmap_ = nil;

        // それぞれ retain しておく
        [self->srcBitmap_ retain];
        [self->dstBitmap_ retain];
        [self->maskBitmap_ retain];
        [self->palette_ retain];
        [self->rect_ retain];

        // 描画点を生成
        self->drawPoint_ = [[PoCoPoint alloc] init];
        if (self->drawPoint_ == nil) {
            [self release];
            self = nil;
            goto EXIT;
        }

        // 走査状態は特に何もなし
        self->leftLen_ = 0;
        self->rightLen_ = 0;
        self->leftColor_ = 0;
        self->rightColor_ = 0;
        self->scanState_ = PoCoAutoGrad_NoneAttach;
    }

EXIT:
    return self;
}


//
// deallocate
//
//  Call
//    None
//
//  Return
//    srcBitmap_      : 描画元画像(instance 変数)
//    dstBitmap_      : 描画先画像(instance 変数)
//    maskBitmap_     : 形状マスク(instance 変数)
//    palette_        : 使用パレット(instance 変数)
//    rect_           : 描画範囲(instance 変数)
//    workSrcBitmap_  : 描画元画像(作業領域)(instance 変数)
//    workDstBitmap_  : 描画先画像(作業領域)(instance 変数)
//    workMaskBitmap_ : 形状マスク(作業領域)(instance 変数)
//    drawPoint_      : 描画点(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoEditAutoGradation dealloc]\n"));

    // 資源の解放
    [self->srcBitmap_ release];
    [self->dstBitmap_ release];
    [self->maskBitmap_ release];
    [self->palette_ release];
    [self->rect_ release];
    [self->workSrcBitmap_ release];
    [self->workDstBitmap_ release];
    [self->workMaskBitmap_ release];
    [self->drawPoint_ release];
    self->srcBitmap_ = nil;
    self->dstBitmap_ = nil;
    self->maskBitmap_ = nil;
    self->palette_ = nil;
    self->rect_ = nil;
    self->workSrcBitmap_ = nil;
    self->workDstBitmap_ = nil;
    self->workMaskBitmap_ = nil;
    self->drawPoint_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//
//  Call
//    srcBitmap_  : 描画元画像(instance 変数)
//    dstBitmap_  : 描画先画像(instance 変数)
//    maskBitmap_ : 形状マスク(instance 変数)
//    rect_       : 描画範囲(instance 変数)
//
//  Return
//    dstBitmap_      : 描画先画像(instance 変数)
//    workSrcBitmap_  : 描画元画像(作業領域)(instance 変数)
//    workDstBitmap_  : 描画先画像(作業領域)(instance 変数)
//    workMaskBitmap_ : 形状マスク(作業領域)(instance 変数)
//
-(void)executeDraw
{
    PoCoRect *r;
    int x;
    int y;
    PoCoBitmap *tmp;

    // 描画先に描画元をそのまま複写
    r = [[PoCoRect alloc] initLeft:0
                           initTop:0
                         initRight:[self->srcBitmap_ width]
                        initBottom:[self->srcBitmap_ height]];
    [self->dstBitmap_ setBitmap:[self->srcBitmap_ pixelmap]
                       withRect:r];
    [r release];

    // 作業領域へ複写
    x = 0;
    y = 0;
    if (([self->rect_ left] % 4) != 0) {
        x = ([self->rect_ left] % 4);
    }
    if (([self->rect_ top] % 4) != 0) {
        y = ([self->rect_ top] % 4);
    }
    r = [[PoCoRect alloc] initLeft:0
                           initTop:0
                         initRight:([self->srcBitmap_ width] + x)
                        initBottom:([self->srcBitmap_ height] + y)];
    self->workSrcBitmap_ = [[PoCoBitmap alloc] initWidth:[r width]
                                              initHeight:[r height]
                                            defaultColor:0];
    self->workDstBitmap_ = [[PoCoBitmap alloc] initWidth:[r width]
                                              initHeight:[r height]
                                            defaultColor:0];
    self->workMaskBitmap_ = [[PoCoBitmap alloc] initWidth:[r width]
                                              initHeight:[r height]
                                            defaultColor:0];
    [r setLeft:x];
    [r setTop:y];
    [self->workSrcBitmap_ setBitmap:[self->srcBitmap_ pixelmap]
                           withRect:r];
    [self->workDstBitmap_ setBitmap:[self->dstBitmap_ pixelmap]
                           withRect:r];
    [self->workMaskBitmap_ setBitmap:[self->maskBitmap_ pixelmap]
                           withRect:r];
    [r release];

    // 水平走査
    [self scanHori];

    // 垂直走査
    [self scanVert];

    // 作業領域から複写(描画後の内容のみ)
    r = [[PoCoRect alloc] initLeft:x
                           initTop:y
                         initRight:([self->dstBitmap_ width] + x)
                        initBottom:([self->dstBitmap_ height] + y)];
    tmp = [self->workDstBitmap_ getBitmap:r];
    [r release];
    r = [[PoCoRect alloc] initLeft:0
                           initTop:0
                         initRight:[tmp width]
                        initBottom:[tmp height]];
    [self->dstBitmap_ setBitmap:[tmp pixelmap]
                       withRect:r];
    [tmp release];
    [r release];

    return;
}

@end
