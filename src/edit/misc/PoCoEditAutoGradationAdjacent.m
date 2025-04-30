//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 自動グラデーション(隣接)
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import "PoCoEditAutoGradationAdjacent.h"

#import "PoCoColorPattern.h"
#import "PoCoEditAtomizerDrawLine.h"

#if 1
# define  __POCO_USE_THREAD_TO_IMPROVE_EFFICIENCY_OF_AUDOGRAD
#endif  // 1

// =========================================== PoCoAutoGradationAdjacentElement

// ------------------------------------------------------------------ interface
@interface PoCoAutoGradationAdjacentElement : NSObject
{
    PoCoPoint *pt_;                     // 座標
    unsigned char firstColor_;          // 色1
    unsigned char secondColor_;         // 色2
    int firstSize_;                     // サイズ1
    int secondSize_;                    // サイズ2
    BOOL isHori_;                       // 水平走査によるものか
}

// initialize
-(id)initWithPoint:(PoCoPoint *)dp
    withFirstColor:(unsigned char)firstColor
    andSecondColor:(unsigned char)secondColor
     withFirstSize:(int)firstSize
     andSecondSize:(int)secondSize
            isHori:(BOOL)isHori;

// deallocate
-(void)dealloc;

// property(get)
-(NSString *)name;
-(PoCoPoint *)point;
-(unsigned char)firstColor;
-(unsigned char)secondColor;
-(int)firstSize;
-(int)secondSize;
-(BOOL)isHori;

// property(set)
-(void)setFirstSize:(int)size;
-(void)setSecondSize:(int)size;

@end


// ------------------------------------------------------------------ implement
@implementation PoCoAutoGradationAdjacentElement

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//
//  Return
//    function     : 実体
//    pt_          : 座標(instance 変数)
//    firstColor_  : 色1(instance 変数)
//    secondColor_ : 色2(instance 変数)
//    firstSize_   : サイズ1(instance 変数)
//    secondSize_  : サイズ2(instance 変数)
//    isHori_      : 水平走査によるものか(instance 変数)
//
-(id)initWithPoint:(PoCoPoint *)dp
    withFirstColor:(unsigned char)firstColor
    andSecondColor:(unsigned char)secondColor
     withFirstSize:(int)firstSize
     andSecondSize:(int)secondSize
            isHori:(BOOL)isHori
{
    // super class へ回送
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->firstColor_ = firstColor;
        self->secondColor_ = secondColor;
        self->firstSize_ = firstSize;
        self->secondSize_ = secondSize;
        self->isHori_ = isHori;

        // 座標を複製
        self->pt_ = [[PoCoPoint alloc] initX:[dp x]
                                       initY:[dp y]];
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
//    pt_ : 座標(instance 変数)
//
-(void)dealloc
{
    // 資源の解放
    [self->pt_ release];
    self->pt_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


// ------------------------------------------ instance - public - property(get)
//
// 名称
//
//  Call
//    pt_          : 座標(instance 変数)
//    firstColor_  : 色1(instance 変数)
//    secondColor_ : 色2(instance 変数)
//
//  Return
//    function : 文字列
//
-(NSString *)name
{
    return [NSString stringWithFormat:@"%05d:%05d:%03d:%03d", [self->pt_ x], [self->pt_ y], self->firstColor_, self->secondColor_];
}


//
// 座標
//
//  Call
//    pt_ : 座標(instance 変数)
//
//  Return
//    function : 設定内容
//
-(PoCoPoint *)point
{
    return self->pt_;
}


//
// 色1
//
//  Call
//    firstColor_ : 色1(instance 変数)
//
//  Return
//    function : 設定内容
//
-(unsigned char)firstColor
{
    return self->firstColor_;
}


//
// 色2
//
//  Call
//    secondColor_ : 色2(instance 変数)
//
//  Return
//    function : 設定内容
//
-(unsigned char)secondColor
{
    return self->secondColor_;
}


//
// サイズ1
//
//  Call
//    firstSize_ : サイズ1(instance 変数)
//
//  Return
//    function : 設定内容
//
-(int)firstSize
{
    return self->firstSize_;
}


//
// サイズ2
//
//  Call
//    secondSize_ : サイズ2(instance 変数)
//
//  Return
//    function : 設定内容
//
-(int)secondSize
{
    return self->secondSize_;
}


//
// 水平走査によるものか
//
//  Call
//    isHori_ : 水平走査によるものか(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)isHori
{
    return self->isHori_;
}


// ------------------------------------------ instance - public - property(set)
//
// サイズ1
//
//  Call
//    size : 設定内容
//
//  Return
//    firstSize_ : サイズ1(instance 変数)
//
-(void)setFirstSize:(int)size
{
    self->firstSize_ = size;

    return;
}


//
// サイズ2
//
//  Call
//    size : 設定内容
//
//  Return
//    secondSize_ : サイズ2(instance 変数)
//
-(void)setSecondSize:(int)size
{
    self->secondSize_ = size;

    return;
}

@end




// ============================================== PoCoAutoGradationAdjacentPair

// ------------------------------------------------------------------ interface
@interface PoCoAutoGradationAdjacentPair : NSObject
{
    // 描画条件
    unsigned char firstColor_;          // 色1
    unsigned char secondColor_;         // 色2
    PoCoBitmap *workSrcBitmap_;         // 描画元画像
    PoCoBitmap *workMaskBitmap_;        // 形状マスク
    int size_;                          // 大きさ(0: 任意、1-128 の範囲)
    PoCoRect *rect_;                    // 描画範囲

    // 走査状態
    PoCoPoint *drawPoint_;              // 描画点
    int leftLen_;                       // 左・上のドット数
    int rightLen_;                      // 右・下のドット数
    unsigned char leftColor_;           // 左・上の色
    unsigned char rightColor_;          // 右・下の色
    PoCoAutoGradState scanState_;       // 走査状態

    // 結果
    NSMutableDictionary *points_;       // 対象点群
}

// initialize
-(id)initWithFirstColor:(unsigned char)first
         andSecondColor:(unsigned char)second
                withSrc:(PoCoBitmap *)sbmp
               withMask:(PoCoBitmap *)mbmp
                penSize:(int)size
                   rect:(PoCoRect *)r;

// deallocate
-(void)dealloc;

// 実行
-(void)execute;

// property(get)
-(NSDictionary *)points;

@end


// ------------------------------------------------------------------ implement
@implementation PoCoAutoGradationAdjacentPair

// --------------------------------------------------------- instance - private
//
// 点を登録
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
//    points_ : 対象点群(instance 変数)
//
-(void)registerPoint:(BOOL)isHori
{
    int leftSize;
    int rightSize;
    PoCoAutoGradationAdjacentElement *elm;
    PoCoAutoGradationAdjacentElement *tmp;

    // サイズを選別
    if (self->size_ == 0) {
        leftSize = MIN(self->leftLen_, 128);
        rightSize = MIN(self->rightLen_, 128);
    } else {
        leftSize = self->size_;
        rightSize = self->size_;
    }

    // 要素を生成
    elm = [[PoCoAutoGradationAdjacentElement alloc]
              initWithPoint:self->drawPoint_
             withFirstColor:self->leftColor_
             andSecondColor:self->rightColor_
              withFirstSize:leftSize
              andSecondSize:rightSize
                     isHori:isHori];

    // 同じ内容が登録済みか
    tmp = [self->points_ valueForKey:[elm name]];
    if (tmp == nil) {
        // なければ登録
        [self->points_ setValue:elm
                         forKey:[elm name]];
    } else {
        // あれば上書き(サイズが大きい方を残す)
        if ([tmp firstSize] < [elm firstSize]) {
            [tmp setFirstSize:[elm firstSize]];
        }
        if ([tmp secondSize] < [elm secondSize]) {
            [tmp setSecondSize:[elm secondSize]];
        }
    }
    [elm release];

    return;
}


//
// 到達点を検証
//
//  Call
//    srcColor     : 描画元の色
//    mask         : 形状マスク
//    x            : 水平位置
//    y            : 垂直位置
//    isHori       : 水平走査か(YES: 水平走査)
//    firstColor_  : 色1(instance 変数)
//    secondColor_ : 色2(instance 変数)
//    leftLen_     : 左・上のドット数(instance 変数)
//    rightLen_    : 右・下のドット数(instance 変数)
//    leftColor_   : 左・上の色(instance 変数)
//    rightColor_  : 右・下の色(instance 変数)
//    scanState_   : 走査状態(instance 変数)
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
            if ((srcColor == self->firstColor_) ||
                (srcColor == self->secondColor_)) {
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
            } else if ((srcColor == self->firstColor_) ||
                       (srcColor == self->secondColor_)) {
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
                // 終点に達したので点を登録
                [self registerPoint:isHori];

                // 続きに入る
                if ((srcColor == self->firstColor_) ||
                    (srcColor == self->secondColor_)) {
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
            // 始点・中点には達していたので終点に達した扱いとして点を登録
            [self registerPoint:isHori];
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

        // 始点・中点には達していた状態で端に達したので点を登録
        if (self->scanState_ == PoCoAutoGrad_MiddleAttached) {
            [self registerPoint:YES];
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

        // 始点・中点には達していた状態で端に達したので点を登録
        if (self->scanState_ == PoCoAutoGrad_MiddleAttached) {
            [self registerPoint:NO];
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
//    first  : 色1(instance 変数)
//    second : 色2(instance 変数)
//    sbmp   : 描画元画像
//    mbmp   : 形状マスク
//    size   : 大きさ(0: 任意、1-128 の範囲)
//    r      : 描画範囲
//
//  Return
//    function        : 実体
//    firstColor_     : 色1(instance 変数)
//    secondColor_    : 色2(instance 変数)
//    workSrcBitmap_  : 描画元画像(instance 変数)
//    workMaskBitmap_ : 形状マスク(instance 変数)
//    size_           : 大きさ(0: 任意、1-128 の範囲)(instance 変数)
//    rect_           : 描画範囲(instance 変数)
//    drawPoint_      : 描画点(instance 変数)
//    leftLen_        : 左・上のドット数(instance 変数)
//    rightLen_       : 右・下のドット数(instance 変数)
//    leftColor_      : 左・上の色(instance 変数)
//    rightColor_     : 右・下の色(instance 変数)
//    scanState_      : 走査状態(instance 変数)
//    points_         : 対象点群(instance 変数)
//
-(id)initWithFirstColor:(unsigned char)first
         andSecondColor:(unsigned char)second
                withSrc:(PoCoBitmap *)sbmp
               withMask:(PoCoBitmap *)mbmp
                penSize:(int)size
                   rect:(PoCoRect *)r
{
    // super class へ回送
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->firstColor_ = first;
        self->secondColor_ = second;
        self->workSrcBitmap_ = sbmp;
        self->workMaskBitmap_ = mbmp;
        self->size_ = size;
        self->rect_ = r;
        self->drawPoint_ = nil;
        self->points_ = nil;

        // それぞれ retain しておく
        [self->workSrcBitmap_ retain];
        [self->workMaskBitmap_ retain];
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

        // 走査点群の保持先を生成
        self->points_ = [[NSMutableDictionary alloc] init];
        if (self->points_ == nil) {
            [self release];
            self = nil;
            goto EXIT;
        }
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
//    workSrcBitmap_  : 描画元画像(instance 変数)
//    workMaskBitmap_ : 形状マスク(instance 変数)
//    rect_           : 描画範囲(instance 変数)
//    drawPoint_      : 描画点(instance 変数)
//    points_         : 対象点群(instance 変数)
//
-(void)dealloc
{
    // 資源の解放
    [self->workSrcBitmap_ release];
    [self->workMaskBitmap_ release];
    [self->rect_ release];
    [self->drawPoint_ release];
    [self->points_ release];
    self->workSrcBitmap_ = nil;
    self->workMaskBitmap_ = nil;
    self->rect_ = nil;
    self->drawPoint_ = nil;
    self->points_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//
//  Call
//    None
//
//  Return
//    None
//
-(void)execute
{
    // 水平走査
    [self scanHori];

    // 垂直走査
    [self scanVert];

#ifdef  __POCO_USE_THREAD_TO_IMPROVE_EFFICIENCY_OF_AUDOGRAD
    // 終了
    [NSThread exit];
#endif  // __POCO_USE_THREAD_TO_IMPROVE_EFFICIENCY_OF_AUDOGRAD

    return;
}


//------------------------------------------- instance - public - property(get)
//
// 色1
//
//  Call
//    firstColor_ : 色1(instance 変数)
//
//  Return
//    function : 設定内容
//
-(unsigned char)firstColor
{
    return self->firstColor_;
}


//
// 色2
//
//  Call
//    secondColor_ : 色2(instance 変数)
//
//  Return
//    function : 設定内容
//
-(unsigned char)secondColor
{
    return self->secondColor_;
}


//
// 対象点群
//
//  Call
//    points_ : 対象点群(instance 変数)
//
//  Return
//    function : 対象点群
//
-(NSDictionary *)points
{
    return self->points_;
}

@end




// ============================================================================
@implementation PoCoEditAutoGradationAdjacent

// --------------------------------------------------------- instance - private
//
// 半値霧吹きで描画
//
//  Call
//    dp       : 座標
//    col      : 描画色
//    size     : 大きさ(実ドット数なので 1-128 の範囲)
//    flip     : 反転か(YES: 反転を使用)
//    hori     : 水平走査か(YES: 水平走査)
//    high     : 上から下の色遷移か(YES: 上から下、NO: 下から上)
//               (手前の色番号から後ろの色番号への遷移か)
//    palette_ : 使用パレット(instance 変数)
//
//  Return
//    workDstBitmap_ : 描画先画像(instance 変数)
//
-(void)executeHalfAtomizer:(PoCoPoint *)dp
                     color:(unsigned char)col
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
    p = [[PoCoPoint alloc] initX:[dp x]
                           initY:[dp y]];

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
// パレットを退避
//
//  Call
//    palette_ : 使用パレット(instance 変数)
//
//  Return
//    colorBuffer_ : 保持内容(instance 変数)
//
-(void)pushPalette
{
    int l;

    for (l = 0; l < COLOR_MAX; (l)++) {
        self->colorBuffer_[l] = [[self->palette_ palette:l] noDropper];
        self->colorBuffer_[l + COLOR_MAX] = [[self->palette_ palette:l] isMask];
    }

    return;
}


//
// パレットを進出
//
//  Call
//    colorBuffer_ : 保持内容(instance 変数)
//
//  Return
//    palette_ : 使用パレット(instance 変数)
//
-(void)popPalette
{
    int l;

    for (l = 0; l < COLOR_MAX; (l)++) {
        [[self->palette_ palette:l] setDropper:self->colorBuffer_[l]];
        [[self->palette_ palette:l] setMask:self->colorBuffer_[l + COLOR_MAX]];
    }

    return;
}


//
// パレットを切り替え
//
//  Call
//    pair         : 対象の対
//    colorBuffer_ : 保持内容(instance 変数)
//
//  Return
//    palette_ : 使用パレット(instance 変数)
//
-(void)overwritePalette:(PoCoAutoGradationAdjacentPair *)pair
{
    int l;

    // 全てのパレットを上書き(描画・使用を禁止する)
    for (l = 0; l < COLOR_MAX; (l)++) {
        [[self->palette_ palette:l] setDropper:YES];
        [[self->palette_ palette:l] setMask:YES];
    }

    // 対象の色だけ描画・使用を許可する
    if ((self->colorBuffer_[[pair firstColor]            ]) ||
        (self->colorBuffer_[[pair firstColor] + COLOR_MAX])) {
        // もともと使用できないか上塗りが禁止されている
        ;
    } else {
        [[self->palette_ palette:[pair firstColor]] setDropper:NO];
        [[self->palette_ palette:[pair firstColor]] setMask:NO];
    }
    if ((self->colorBuffer_[[pair secondColor]            ]) ||
        (self->colorBuffer_[[pair secondColor] + COLOR_MAX])) {
        // もともと使用できないか上塗りが禁止されている
        ;
    } else {
        [[self->palette_ palette:[pair secondColor]] setDropper:NO];
        [[self->palette_ palette:[pair secondColor]] setMask:NO];
    }

    return;
}


//
// 後ろの色の組み合わせから塗りを実行
//
//  Call
//    pair      : 対象の対
//    sizePair_ : 大きさと色番号の対群(instance 変数)
//
//  Return
//    None
//
-(void)drawBackwordColor:(PoCoAutoGradationAdjacentPair *)pair
{
    NSEnumerator *iter;
    PoCoAutoGradationAdjacentElement *elm;
    unsigned char col;
    int size;
    PoCoGradationPairInfo *tmp;

    // パレットを切り替え
    [self overwritePalette:pair];

    // 対に保持している点を走査
    iter = [[pair points] objectEnumerator];
    for (elm = [iter nextObject]; elm != nil; elm = [iter nextObject]) {
        // 正方向の塗りなので手前の色番号で塗る
        if ([elm firstColor] < [elm secondColor]) {
            col = [elm firstColor];
            size = [elm firstSize];
            if (self->sizePair_ != nil) {
                tmp = [self->sizePair_ valueForKey:[PoCoGradationPairInfo pairString:[elm firstColor]
                                                                          withSecond:[elm secondColor]]];
                size = [tmp size];
            }
        } else {
            col = [elm secondColor];
            size = [elm secondSize];
            if (self->sizePair_ != nil) {
                tmp = [self->sizePair_ valueForKey:[PoCoGradationPairInfo pairString:[elm secondColor]
                                                                          withSecond:[elm firstColor]]];
                size = [tmp size];
            }
        }
        [self executeHalfAtomizer:[elm point]
                            color:col
                             size:size
                           isFlip:NO
                           isHori:[elm isHori]
                           isHigh:YES];
    }

    return;
}


//
// 手前の色の組み合わせの塗りを実行
//
//  Call
//    pair      : 対象の対
//    sizePair_ : 大きさと色番号の対群(instance 変数)
//
//  Return
//    None
//
-(void)drawForwardColor:(PoCoAutoGradationAdjacentPair *)pair
{
    NSEnumerator *iter;
    PoCoAutoGradationAdjacentElement *elm;
    unsigned char col;
    int size;
    BOOL flag;
    PoCoGradationPairInfo *tmp;

    // パレットを切り替え
    [self overwritePalette:pair];

    // 対に保持している点を走査
    iter = [[pair points] objectEnumerator];
    for (elm = [iter nextObject]; elm != nil; elm = [iter nextObject]) {
        // 逆方向の塗りなので後ろの色番号で塗る
        flag = ([elm firstColor] < [elm secondColor]);
        if (flag) {
            col = [elm secondColor];
            size = [elm secondSize];
            if (self->sizePair_ != nil) {
                tmp = [self->sizePair_ valueForKey:[PoCoGradationPairInfo pairString:[elm secondColor]
                                                                          withSecond:[elm firstColor]]];
                size = [tmp size];
            }
        } else {
            col = [elm firstColor];
            size = [elm firstSize];
            if (self->sizePair_ != nil) {
                tmp = [self->sizePair_ valueForKey:[PoCoGradationPairInfo pairString:[elm firstColor]
                                                                          withSecond:[elm secondColor]]];
                size = [tmp size];
            }
        }
        [self executeHalfAtomizer:[elm point]
                            color:col
                             size:size
                           isFlip:YES
                           isHori:[elm isHori]
                           isHigh:flag];
    }

    return;
}


//
// 連続性を検証
//
//  Call
//    matrix_ : 対象色配列(256 固定長、YES: 対象)(instance 変数)
//
//  Return
//    pairNum_ : 対の数(instance 変数)
//
-(void)verifyContinues
{
    int l;
    BOOL noAttach;
    BOOL isStart;

    self->pairNum_ = 0;
    noAttach = YES;
    isStart = NO;

    // 先頭から順番に穴がないかを検証
    for (l = 0; l < COLOR_MAX; (l)++) {
        if (noAttach) {
            // 未到達(先頭を探している)
            if (self->matrix_[l]) {
                // 先頭に達した
                noAttach = NO;
                isStart = YES;
            }
        } else if (isStart) {
            // 先頭には達している(末尾を探している)
            if (self->matrix_[l]) {
                // 連続している数を計上 
                (self->pairNum_)++;
            } else {
                // 末尾に達した(はず)
                noAttach = NO;
                isStart = NO;
            }
        } else {
            // 末尾には達している(はず)(穴を探している)
            if (self->matrix_[l]) {
                // 穴になっていたので連続していない
                self->pairNum_ = 0;     // 連続数を無しにする
                break;
            }
        }
    }

    return;
}


//
// 組み合わせを生成
//
//  Call
//    workSrcBitmap_  : 描画元画像(instance 変数)
//    workMaskBitmap_ : 形状マスク(instance 変数)
//    size_           : 大きさ(0: 任意、1-128 の範囲)(instance 変数)
//    rect_           : 描画範囲(instance 変数)
//    pairNum_        : 対の数(instance 変数)
//
//  Return
//    pair_ : 走査用の対(instance 変数)
//
-(void)createColorPair
{
    int l;
    int i;

    // メモリ確保
    self->pair_ = (PoCoAutoGradationAdjacentPair **)(calloc(self->pairNum_, sizeof(PoCoAutoGradationAdjacentPair *)));
    if (self->pair_ != NULL) {
        // 対の情報を生成
        i = 0;
        for (l = 0; l < (COLOR_MAX - 1); (l)++) {
            if ((self->matrix_[l    ]) &&
                (self->matrix_[l + 1]) &&
                (i < self->pairNum_)) {
                self->pair_[i] = [[PoCoAutoGradationAdjacentPair alloc]
                                     initWithFirstColor:l
                                         andSecondColor:(l + 1)
                                                withSrc:self->workSrcBitmap_
                                               withMask:self->workMaskBitmap_
                                                penSize:self->size_
                                                   rect:self->rect_];
                (i)++;
            }
        }
    }

    return;
}


//
// 対象座標を検出
//
//  Call
//    pairNum_ : 対の数(instance 変数)
//    pair_    : 走査用の対(instance 変数)
//
//  Return
//    pair_ : 走査用の対(instance 変数)
//
-(void)scanTargetPoint
#ifdef  __POCO_USE_THREAD_TO_IMPROVE_EFFICIENCY_OF_AUDOGRAD
{
    int l;
    id *thread;
    BOOL flag;

    // 走査用の対を実行
    thread = (id *)(calloc(self->pairNum_, sizeof(id)));
    if (thread != NULL) {
        for (l = 0; l < self->pairNum_; (l)++) {
            thread[l] = [[NSThread alloc] initWithTarget:self->pair_[l]
                                                selector:@selector(execute)
                                                  object:nil];
            [thread[l] start];
        }

        // すべての thread が終わるのを待つ
        [NSThread sleepForTimeInterval:0.001];
        do {
            flag = NO;
            for (l = 0; l < self->pairNum_; (l)++) {
                if (thread[l] == nil) {
                    // 既に終わっている
                    ;
                } else if ([thread[l] isFinished]) {
                    // 終了したので解放
                    [thread[l] release];
                    thread[l] = nil;
                } else {
                    // 実行中
                    flag = YES;
                }
            }
            [NSThread sleepForTimeInterval:0.001];
        } while (flag);

        // 解放
        free(thread);
    }

    return;
}
#else   // __POCO_USE_THREAD_TO_IMPROVE_EFFICIENCY_OF_AUDOGRAD
{
    int l;

    // 走査用の対を実行
    for (l = 0; l < self->pairNum_; (l)++) {
        [self->pair_[l] execute];
    }

    return;
}
#endif  // __POCO_USE_THREAD_TO_IMPROVE_EFFICIENCY_OF_AUDOGRAD


//
// 対を走査
//
//  Call
//    pairNum_ : 対の数(instance 変数)
//    pair_    : 走査用の対(instance 変数)
//
//  Return
//    None
//
-(void)enumeratePair
{
    int l;

    // パレットを退避
    [self pushPalette];

    // 後ろの色の組み合わせから塗りを実行
    for (l = self->pairNum_; l != 0; (l)--) {
        [self drawBackwordColor:self->pair_[l - 1]];
    }

    // 手前の色の組み合わせの塗りを実行
    for (l = 0; l < self->pairNum_; (l)++) {
        [self drawForwardColor:self->pair_[l]];
    }

    // パレットを進出
    [self popPalette];

    return;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    dbmp     : 描画先画像
//    sbmp     : 描画元画像
//    mbmp     : 形状マスク
//    plt      : 使用パレット
//    size     : 大きさ(0: 任意、1-128 の範囲)
//    mtx      : 対象色配列(256 固定長、YES: 対象)
//    r        : 描画範囲
//    sizePair : 大きさと色番号の対群
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
//    sizePair_       : 大きさと色番号の対群(instance 変数)
//    workSrcBitmap_  : 描画元画像(作業領域)(instance 変数)
//    workDstBitmap_  : 描画先画像(作業領域)(instance 変数)
//    workMaskBitmap_ : 形状マスク(作業領域)(instance 変数)
//    pairNum_        : 対の数(instance 変数)
//    pair_           : 走査用の対(instance 変数)
//
-(id)initDst:(PoCoBitmap *)dbmp
     withSrc:(PoCoBitmap *)sbmp
    withMask:(PoCoBitmap *)mbmp
     palette:(PoCoPalette *)plt
     penSize:(int)size
      matrix:(const BOOL *)mtx
        rect:(PoCoRect *)r
withSizePair:(NSDictionary *)sizePair
{
    DPRINT((@"[PoCoEditAutoGradationAdjacent init]\n"));

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
        self->sizePair_ = sizePair;
        self->workSrcBitmap_ = nil;
        self->workDstBitmap_ = nil;
        self->workMaskBitmap_ = nil;
        self->pairNum_ = 0;
        self->pair_ = NULL;

        // それぞれ retain しておく
        [self->srcBitmap_ retain];
        [self->dstBitmap_ retain];
        [self->maskBitmap_ retain];
        [self->palette_ retain];
        [self->rect_ retain];
        [self->sizePair_ retain];
    }

    return self;
}


//
// deallocate
//
//  Call
//    pairNum_ : 対の数(instance 変数)
//
//  Return
//    srcBitmap_      : 描画元画像(instance 変数)
//    dstBitmap_      : 描画先画像(instance 変数)
//    maskBitmap_     : 形状マスク(instance 変数)
//    palette_        : 使用パレット(instance 変数)
//    rect_           : 描画範囲(instance 変数)
//    sizePair_       : 大きさと色番号の対群(instance 変数)
//    workSrcBitmap_  : 描画元画像(作業領域)(instance 変数)
//    workDstBitmap_  : 描画先画像(作業領域)(instance 変数)
//    workMaskBitmap_ : 形状マスク(作業領域)(instance 変数)
//    pair_           : 走査用の対(instance 変数)
//
-(void)dealloc
{
    int l;

    DPRINT((@"[PoCoEditAutoGradationAdjacent dealloc]\n"));

    // 資源の解放
    if (self->pair_ != NULL) {
        for (l = 0; l < self->pairNum_; (l)++) {
            [self->pair_[l] release];
        }
        free(self->pair_);
    }
    [self->srcBitmap_ release];
    [self->dstBitmap_ release];
    [self->maskBitmap_ release];
    [self->palette_ release];
    [self->rect_ release];
    [self->sizePair_ release];
    [self->workSrcBitmap_ release];
    [self->workDstBitmap_ release];
    [self->workMaskBitmap_ release];
    self->srcBitmap_ = nil;
    self->dstBitmap_ = nil;
    self->maskBitmap_ = nil;
    self->palette_ = nil;
    self->rect_ = nil;
    self->sizePair_ = nil;
    self->workSrcBitmap_ = nil;
    self->workDstBitmap_ = nil;
    self->workMaskBitmap_ = nil;
    self->pair_ = NULL;

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

    // 連続性を検証
    [self verifyContinues];
    if (self->pairNum_ > 0) {
        // 組み合わせを生成
        [self createColorPair];

        // 対象座標を検出
        [self scanTargetPoint];

        // 生成した組み合わせ情報を走査
        [self enumeratePair];
    }

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
