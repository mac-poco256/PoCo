//
//	Pelistina on Cocoa - PoCo -
//	選択範囲管理
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoSelectionShape.h"

#import "PoCoMyDocument.h"
#import "PoCoAppController.h"
#import "PoCoPicture.h"
#import "PoCoSelLayer.h"
#import "PoCoEditInfo.h"

#import "PoCoCreateStyleMask.h"
#import "PoCoCalcRotation.h"
#import "PoCoEditResizeBitmap.h"
#import "PoCoEditRotateBitmap.h"
#import "PoCoEditRegionFill.h"
#import "PoCoEditUniformedDensityFill.h"
#import "PoCoEditAtomizerFill.h"
#import "PoCoEditGradationFill.h"
#import "PoCoEditRandomFill.h"
#import "PoCoEditWaterDropFill.h"
#import "PoCoEditFlipHoriBitmap.h"
#import "PoCoEditFlipVertBitmap.h"
#import "PoCoEditAutoGradation.h"
#import "PoCoEditAutoGradationAdjacent.h"
#import "PoCoEditBitmapColorReplace.h"

// ============================================================================
@implementation PoCoSelectionShape

// ------------------------------------------------------------ class - private
//
// 位置判定(ハンドルのみ)
//
//  Call
//    p      : 検証する点
//    gap    : ハンドルの拡張幅
//    hndl[] : ハンドル(変形後)(instance 変数)
//
//  Return
//    function : 種類
//
+(PoCoHandleType)hitTest:(PoCoPoint *)p
               handleGap:(int)gap
             withHanldes:(PoCoRect **)hndl
{
    PoCoHandleType type;
    int l;

    type = PoCoHandleType_unknown;

    // ハンドル上かを判定
    for (l = 1; l < (int)(PoCoHandleType_effective); (l)++) {
        if (([p x] >= ([hndl[l]   left] - gap)) &&
            ([p y] >= ([hndl[l]    top] - gap)) &&
            ([p x] <  ([hndl[l]  right] + gap)) &&
            ([p y] <  ([hndl[l] bottom] + gap))) {
            // 見つけた
            type = (PoCoHandleType)(l);
            break;
        }
    }

    return type;
}


//
// 位置判定(形状ないし外接長方形のみ)
//
//  Call
//    p     : 検証する点
//    r     : 外接長方形(変形後)(instance 変数)
//    shape : 形状(変形後)(instance 変数)
//            != nil : 形状と外接長方形から判定する
//            == nil : 外接長方形のみで判定する
//
//  Return
//    function : 種類
//
+(PoCoHandleType)hitTest:(PoCoPoint *)p
                withRect:(PoCoRect *)r
               withShape:(PoCoBitmap *)shape
{
    PoCoHandleType type;

    // 範囲内かを判定
    if ([r isPointInRect:p]) {
        if (shape != nil) {
            // 形状も判定
            if ([shape pixelmap][((([p y] - [r top]) * ([r width] + ([r width] & 0x01))) + ([p x] - [r left]))] != 0x00) {
                type = PoCoHandleType_in_shape;
            } else {
                type = PoCoHandleType_out_shape;
            }
        } else {
            type = PoCoHandleType_in_rect;
        }
    } else {
        type = ((shape != nil) ? PoCoHandleType_out_shape :
                                 PoCoHandleType_out_rect);
    }

    return type;
}


//
// 位置判定
//
//  Call
//    p      : 検証する点
//    gap    : ハンドルの拡張幅
//    r      : 外接長方形(変形後)(instance 変数)
//    hndl[] : ハンドル(変形後)(instance 変数)
//    shape  : 形状(変形後)(instance 変数)
//             != nil : 形状と外接長方形から判定する
//             == nil : 外接長方形のみで判定する
//
//  Return
//    function : 種類
//
+(PoCoHandleType)hitTest:(PoCoPoint *)p
               handleGap:(int)gap
                withRect:(PoCoRect *)r
             withHanldes:(PoCoRect **)hndl
               withShape:(PoCoBitmap *)shape
{
    PoCoHandleType type;

    // ハンドル上かを判定
    type = [PoCoSelectionShape hitTest:p
                             handleGap:gap
                           withHanldes:hndl];
    if (type == PoCoHandleType_unknown) {
        // 範囲内かを判定
        type = [PoCoSelectionShape hitTest:p
                                  withRect:r
                                 withShape:shape];
    }

    return type;
}


//
// 同一形状か
//
//  Call
//    r      : 外接長方形
//    points : 支点群
//
//  Return
//    function : 判定結果
//
+(BOOL)isSameStyle:(PoCoRect *)r
         testShape:(NSMutableArray *)points
{
    BOOL result;
    PoCoCreateStyleMask *mask;
    PoCoBitmap *rect;
    PoCoBitmap *region;

    result = NO;
    rect = nil;
    region = nil;

    // 形状マスクを生成
    mask = [[PoCoCreateStyleMask alloc] init];
    if ([mask box:[r lefttop]
              end:[r rightbot]
      orientation:nil
       isDiagonal:NO]) {
        rect = [[mask mask] copy];
    }
    if ([mask polygon:points]) {
        region = [[mask mask] copy];
    }
    [mask release];

    // 判定
    if ((rect != nil) && (region != nil)) {
        if (([rect width] == [region width]) &&
            ([rect height] == [region height])) {
            result = (memcmp([rect pixelmap], [region pixelmap], ([rect width] *
 [rect height])) == 0);
        }
    }
    [rect release];
    [region release];

    return result;
}


//
// 点を追加
//
//  Call
//    p : 登録する点
//
//  Return
//    points : 登録先
//    r      : 外接長方形
//
+(void)addControlPoint:(PoCoPoint *)p
           targetArray:(NSMutableArray *)points
            targetRect:(PoCoRect *)r
{
    PoCoPoint *tmp;

    // 点を追加
    tmp = [[PoCoPoint alloc] initX:[p x]
                             initY:[p y]];
    [points addObject:tmp];
    [tmp release];

    // 外接長方形を拡張
    [r   setLeft:MIN([r   left], [p x])];
    [r    setTop:MIN([r    top], [p y])];
    [r  setRight:MAX([r  right], [p x])];
    [r setBottom:MAX([r bottom], [p y])];

    return;
}


//
// ハンドル位置(枠)生成
//
//  Call
//    r : 外接長方形
//
//  Return
//    hndl[] : ハンドル
//
+(void)createHandleRect:(PoCoRect *)r
          targetHandles:(PoCoRect **)hndl
{
    const int w = [r width];
    const int w2 = (w >> 1);
    const int h = [r height];
    const int h2 = (h >> 1);

    // 中心(中心は点とするので lefttop == rightbot)
    hndl[PoCoHandleType_center] = [[PoCoRect alloc]
          initLeft:([r left] + w2)
           initTop:([r  top] + h2)
         initRight:([r left] + w2)
        initBottom:([r  top] + h2)];

    // 左上
    hndl[PoCoHandleType_corner_lt] = [[PoCoRect alloc]
          initLeft:([r left]      - HANDLE_GAP)
           initTop:([r  top]      - HANDLE_GAP)
         initRight:([r left]      + HANDLE_GAP + 1)
        initBottom:([r  top]      + HANDLE_GAP + 1)];

    // 上底
    hndl[PoCoHandleType_edge_t] = [[PoCoRect alloc]
          initLeft:([r left] + w2 - HANDLE_GAP)
           initTop:([r  top]      - HANDLE_GAP)
         initRight:([r left] + w2 + HANDLE_GAP + 1)
        initBottom:([r  top]      + HANDLE_GAP + 1)];

    // 右上
    hndl[PoCoHandleType_corner_rt] = [[PoCoRect alloc]
          initLeft:([r left] + w  - HANDLE_GAP)
           initTop:([r  top]      - HANDLE_GAP)
         initRight:([r left] + w  + HANDLE_GAP + 1)
        initBottom:([r  top]      + HANDLE_GAP + 1)];

    // 右辺
    hndl[PoCoHandleType_edge_r] = [[PoCoRect alloc]
          initLeft:([r left] + w  - HANDLE_GAP)
           initTop:([r  top] + h2 - HANDLE_GAP)
         initRight:([r left] + w  + HANDLE_GAP + 1)
        initBottom:([r  top] + h2 + HANDLE_GAP + 1)];

    // 右下
    hndl[PoCoHandleType_corner_rb] = [[PoCoRect alloc]
          initLeft:([r left] + w  - HANDLE_GAP)
           initTop:([r  top] + h  - HANDLE_GAP)
         initRight:([r left] + w  + HANDLE_GAP + 1)
        initBottom:([r  top] + h  + HANDLE_GAP + 1)];

    // 下底
    hndl[PoCoHandleType_edge_b] = [[PoCoRect alloc]
          initLeft:([r left] + w2 - HANDLE_GAP)
           initTop:([r  top] + h  - HANDLE_GAP)
         initRight:([r left] + w2 + HANDLE_GAP + 1)
        initBottom:([r  top] + h  + HANDLE_GAP + 1)];

    // 左下
    hndl[PoCoHandleType_corner_lb] = [[PoCoRect alloc]
          initLeft:([r left]      - HANDLE_GAP)
           initTop:([r  top] + h  - HANDLE_GAP)
         initRight:([r left]      + HANDLE_GAP + 1)
        initBottom:([r  top] + h  + HANDLE_GAP + 1)];

    // 左辺
    hndl[PoCoHandleType_edge_l] = [[PoCoRect alloc]
          initLeft:([r left]      - HANDLE_GAP)
           initTop:([r  top] + h2 - HANDLE_GAP)
         initRight:([r left]      + HANDLE_GAP + 1)
        initBottom:([r  top] + h2 + HANDLE_GAP + 1)];

    return;
}


//
// 形状確定
//
//  Call
//    points : 支点座標群
//    r      : 外接長方形
//
//  Return
//    hndl[] : ハンドル
//    shape  : 形状
//
+(void)createShape:(NSMutableArray *)points
          withRect:(PoCoRect *)r
     targetHandles:(PoCoRect **)hndl
       targetShape:(PoCoBitmap **)shape
{
    PoCoCreateStyleMask *mask;

    // 形状マスクを生成
    mask = [[PoCoCreateStyleMask alloc] init];
    if ([mask polygon:points]) {
        [(*(shape)) release];
        *(shape) = [[mask mask] copy];
    }
    [mask release];

    // ハンドル位置を設定
    [PoCoSelectionShape createHandleRect:r
                           targetHandles:hndl];

    return;
}


// --------------------------------------------------------- instance - private
//
// 変形後の形状を忘れる
//
//  Call
//    None
//
//  Return
//    resultPoints_   : 支点座標群(変形後)(instance 変数)
//    resultRect_     : 外接長方形(変形後)(instance 変数)
//    resultHandle_[] : ハンドル(変形後)(instance 変数)
//    resultShape_    : 形状(変形後)(instance 変数)
//
-(void)clearResult
{
    int l;

    [self->resultPoints_ removeAllObjects];
    [self->resultRect_   setLeft:INT_MAX];
    [self->resultRect_    setTop:INT_MAX];
    [self->resultRect_  setRight:INT_MIN];
    [self->resultRect_ setBottom:INT_MIN];
    [self->resultShape_ release];
    for (l = 0; l < (int)(PoCoHandleType_effective); (l)++) {
        [self->resultHandle_[l] release];
        self->resultHandle_[l] = nil;
    }
    self->resultShape_ = nil;

    return;
}


//
// 変形前の形状を変形後の形状に複写
//
//  Call
//    originalPoints_   : 支点座標群(変形前)(instance 変数)
//    originalRect_     : 外接長方形(変形前)(instance 変数)
//    originalHandle_[] : ハンドル(変形前)(instance 変数)
//    originalShape_    : 形状(変形前)(instance 変数)
//
//  Return
//    resultPoints_   : 支点座標群(変形後)(instance 変数)
//    resultRect_     : 外接長方形(変形後)(instance 変数)
//    resultHandle_[] : ハンドル(変形後)(instance 変数)
//    resultShape_    : 形状(変形後)(instance 変数)
//
-(void)copyOriginalToResult
{
    NSEnumerator* iter;
    PoCoPoint *p;
    PoCoPoint *tmp;
    int l;

    // 以前の内容を忘れる
    [self clearResult];

    // 支点座標群
    [self->resultPoints_ release];
    self->resultPoints_ = [[NSMutableArray alloc] init];
    iter = [self->originalPoints_ objectEnumerator];
    for (p = [iter nextObject]; p != nil; p = [iter nextObject]) {
        tmp = [[PoCoPoint alloc] initX:[p x]
                                 initY:[p y]];
        [self->resultPoints_ addObject:tmp];
        [tmp release];
    }

    // 外接長方形
    [self->resultRect_ release];
    self->resultRect_ = [[PoCoRect alloc]
                              initLeft:[self->originalRect_ left]
                               initTop:[self->originalRect_ top]
                             initRight:[self->originalRect_ right]
                            initBottom:[self->originalRect_ bottom]];

    // 形状マスク
    self->resultShape_ = [self->originalShape_ copy];

    // ハンドル
    for (l = 0; l < (int)(PoCoHandleType_effective); (l)++) {
        self->resultHandle_[l] = [[PoCoRect alloc]
              initLeft:[self->originalHandle_[l] left]
               initTop:[self->originalHandle_[l] top]
             initRight:[self->originalHandle_[l] right]
            initBottom:[self->originalHandle_[l] bottom]];
    }

    return;
}


//
// 相似変形の座標算出
//
//  Call
//    p                 : 制御点の移動先
//    originalHandle_[] : ハンドル(変形前)(instance 変数)
//    point_            : 制御点(開始点)(instance 変数)
//    modify_           : 変形の修飾(instance 変数)
//
//  Return
//    p       : 制御点の移動先
//    modify_ : 変形の修飾(instance 変数)
//
-(void)similerPoint:(PoCoPoint *)p
{
    float ccw;                          // 中心点と制御点の幅
    float cch;                          // 中心点と制御点の高さ
    float tcw;                          // 移動先と制御点の幅
    float tch;                          // 移動先と制御点の高さ

    ccw = (float)([self->point_ x] - [[self->originalHandle_[PoCoHandleType_center] lefttop] x]);
    cch = (float)([self->point_ y] - [[self->originalHandle_[PoCoHandleType_center] lefttop] y]);
    tcw = (float)([p x] - [self->point_ x]);
    tch = (float)([p y] - [self->point_ y]);

    if ((tcw == 0.0) && (tch == 0.0)) {
        /* 移動していない */
        ;
    } else if (self->modify_ == PoCoModifierType_resize_similer_hori) {
        /* 水平変量依存を維持 */
        [p setY:([self->point_ y] + (int)(floor((cch * (tcw / ccw)) + 0.5)))];
    } else if (self->modify_ == PoCoModifierType_resize_similer_vert) {
        /* 垂直変量依存を維持 */
        [p setX:([self->point_ x] + (int)(floor((ccw * (tch / cch)) + 0.5)))];
    } else if (fabs(tcw) < fabs(tch)) {
        /* 水平変量依存を開始 */
        [p setY:([self->point_ y] + (int)(floor((cch * (tcw / ccw)) + 0.5)))];
        self->modify_ = PoCoModifierType_resize_similer_hori;
    } else {
        /* 垂直変量依存を開始 */
        [p setX:([self->point_ x] + (int)(floor((ccw * (tch / cch)) + 0.5)))];
        self->modify_ = PoCoModifierType_resize_similer_vert;
    }

    return;
}


//
// 変形前の形状から回転後の外接長方形を算出
//  形状内に含むすべての点を走査
//
//  Call
//    originalRect_  : 外接長方形(変形前)(instance 変数)
//    originalShape_ : 形状(変形前)(instance 変数)
//    rotate_        : 回転関数(instance 変数)
//
//  Return
//    resultRect_ : 外接長方形(変形後)(instance 変数)
//
-(void)calcRotateRectFromOriginalShape
{
    PoCoPoint *p;
    const int skip = ([self->originalShape_ width] & 0x01);
    int x;
    int y;
    unsigned char *bmp;

    // 走査
    bmp = [self->originalShape_ pixelmap];
    for (y = [self->originalRect_ top];
         y < [self->originalRect_ bottom];
         (y)++, bmp += skip) {
        for (x = [self->originalRect_ left];
             x < [self->originalRect_ right];
             (x)++, (bmp)++) {
            // 形状内の点を対象にする
            if (*(bmp) != 0x00) {
                // 点を生成
                p = [[PoCoPoint alloc] initX:x
                                       initY:y];

                // 回転後の位置を算出
                [self->rotate_ calcPoint:p];

                // 外接長方形に反映
                [self->resultRect_   setLeft:MIN([self->resultRect_   left], [p x])];
                [self->resultRect_    setTop:MIN([self->resultRect_    top], [p y])];
                [self->resultRect_  setRight:MAX([self->resultRect_  right], [p x])];
                [self->resultRect_ setBottom:MAX([self->resultRect_ bottom], [p y])];

                // 点を解放
                [p release];
            }
        }
    }

#if 0
    // 支点がない場合でしか作らず half-open property ではないので -1
    [self->resultRect_  setRight:([self->resultRect_  right] - 1)];
    [self->resultRect_ setBottom:([self->resultRect_ bottom] - 1)];
#endif  // 0

    return;
}


// ---------------------------------------------- instance - private - 画像生成
//
// 移動
//
//  Call
//    org : 変形前
//
//  Return
//    bmp : 変形後
//
-(void)createMoveBitmap:(PoCoBitmap *)org
           targetBitmap:(PoCoBitmap **)bmp
{
    [(*(bmp)) release];
    *(bmp) = nil;
    *(bmp) = [org copy];

    return;
}


//
// 移動(形状、画像の両方)
//
//  Call
//    originalShape_ : 形状(変形前)(instance 変数)
//    originalImage_ : 画像(変形前)(instance 変数)
//
//  Return
//    resultShape_ : 形状(変形後)(instance 変数)
//    resultImage_ : 画像(変形後)(instance 変数)
//
-(void)createMoveBitmapTwin
{
    // 以前の結果を忘れる
    [self->resultShape_ release];
    [self->resultImage_ release];
    self->resultShape_ = nil;
    self->resultImage_ = nil;

    // 複製
    self->resultShape_ = [self->originalShape_ copy];
    self->resultImage_ = [self->originalImage_ copy];

    return;
}


//
// 変倍
//
//  Call
//    org             : 変形前
//    originalPoints_ : 支点座標群(変形前)(instance 変数)
//    resultRect_     : 外接長方形(変形後)(instance 変数)
//
//  Return
//    bmp : 変形後
//
-(void)createResizeBitmap:(PoCoBitmap *)org
             targetBitmap:(PoCoBitmap **)bmp
{
    PoCoEditResizeBitmap *edit;
    int w;
    int h;

    [(*(bmp)) release];
    *(bmp) = nil;
    if (!([self->resultRect_ empty])) {
        w = ([self->resultRect_ width] + 1);
        h = ([self->resultRect_ height] + 1);
        *(bmp) = [[PoCoBitmap alloc] initWidth:w
                                    initHeight:h
                                  defaultColor:0];
        edit = [[PoCoEditResizeBitmap alloc] initDst:*(bmp)
                                             withSrc:org];
        [edit executeResize];
        [edit release];
    }

    return;
}


//
// 変倍(形状、画像の両方)
//
//  Call
//    originalPoints_ : 支点座標群(変形前)(instance 変数)
//    originalShape_  : 形状(変形前)(instance 変数)
//    originalImage_  : 画像(変形前)(instance 変数)
//    resultRect_     : 外接長方形(変形後)(instance 変数)
//
//  Return
//    resultShape_ : 形状(変形後)(instance 変数)
//    resultImage_ : 画像(変形後)(instance 変数)
//
-(void)createResizeBitmapTwin
{
    PoCoEditResizeBitmapDouble *edit;
    int w;
    int h;

    // 以前の結果を忘れる
    [self->resultShape_ release];
    [self->resultImage_ release];
    self->resultShape_ = nil;
    self->resultImage_ = nil;
    if (!([self->resultRect_ empty])) {
        // 結果の格納先を生成
        w = ([self->resultRect_ width] + 1);
        h = ([self->resultRect_ height] + 1);
        self->resultShape_ = [[PoCoBitmap alloc] initWidth:w
                                                initHeight:h
                                              defaultColor:0];
        self->resultImage_ = [[PoCoBitmap alloc] initWidth:w
                                                initHeight:h
                                              defaultColor:0];

        // 変倍
        edit = [[PoCoEditResizeBitmapDouble alloc] initDst1:self->resultShape_
                                                   withDst2:self->resultImage_
                                                   withSrc1:self->originalShape_
                                                   withSrc2:self->originalImage_];
        [edit executeResize];
        [edit release];
    }

    return;
}


//
// 回転
//
//  Call
//    org             : 変形前
//    originalPoints_ : 支点座標群(変形前)(instance 変数)
//    originalRect_   : 外接長方形(変形前)(instance 変数)
//    resultRect_     : 外接長方形(変形後)(instance 変数)
//    rotate_         : 回転関数(instance 変数)
//
//  Return
//    bmp : 変形後
//
-(void)createRotateBitmap:(PoCoBitmap *)org
             targetBitmap:(PoCoBitmap **)bmp
{
    PoCoEditRotateBitmap *edit;
    int w;
    int h;

    [*(bmp) release];
    *(bmp) = nil;
    if (!([self->resultRect_ empty])) {
        w = ([self->resultRect_ width] + 1);
        h = ([self->resultRect_ height] + 1);
        *(bmp) = [[PoCoBitmap alloc] initWidth:w
                                    initHeight:h
                                  defaultColor:0];
        edit = [[PoCoEditRotateBitmap alloc] initDst:*(bmp)
                                             withSrc:org
                                             dstRect:self->resultRect_
                                             srcRect:self->originalRect_
                                         withRotater:self->rotate_];
        [edit executeRotate];
        [edit release];
    }

    return;
}


//
// 回転(形状、画像の両方)
//
//  Call
//    originalPoints_ : 支点座標群(変形前)(instance 変数)
//    originalRect_   : 外接長方形(変形前)(instance 変数)
//    originalShape_  : 形状(変形前)(instance 変数)
//    originalImage_  : 画像(変形前)(instance 変数)
//    resultRect_     : 外接長方形(変形後)(instance 変数)
//    rotate_         : 回転関数(instance 変数)
//
//  Return
//    resultShape_  : 形状(変形後)(instance 変数)
//    resultImage_  : 画像(変形後)(instance 変数)
//
-(void)createRotateBitmapTwin
{
    PoCoEditRotateBitmapDouble *edit;
    int w;
    int h;

    // 以前の結果を忘れる
    [self->resultShape_ release];
    [self->resultImage_ release];
    self->resultShape_ = nil;
    self->resultImage_ = nil;
    if (!([self->resultRect_ empty])) {
        // 結果の格納先を生成
        w = ([self->resultRect_ width] + 1);
        h = ([self->resultRect_ height] + 1);
        self->resultShape_ = [[PoCoBitmap alloc] initWidth:w
                                                initHeight:h
                                              defaultColor:0];
        self->resultImage_ = [[PoCoBitmap alloc] initWidth:w
                                                initHeight:h
                                              defaultColor:0];

        // 回転
        edit = [[PoCoEditRotateBitmapDouble alloc] initDst1:self->resultShape_
                                                   withDst2:self->resultImage_
                                                   withSrc1:self->originalShape_
                                                   withSrc2:self->originalImage_
                                                    dstRect:self->resultRect_
                                                    srcRect:self->originalRect_
                                                withRotater:self->rotate_];
        [edit executeRotate];
        [edit release];
    }

    return;
}


//
// 反転(水平)
//
//  Call
//    org             : 変形前
//    originalPoints_ : 支点座標群(変形前)(instance 変数)
//    resultRect_     : 外接長方形(変形後)(instance 変数)
//
//  Return
//    bmp : 変形後
//
-(void)createFlipHoriBitmap:(PoCoBitmap *)org
               targetBitmap:(PoCoBitmap **)bmp
{
    PoCoEditFlipHoriBitmap *edit;
    int w;
    int h;

    [*(bmp) release];
    *(bmp) = nil;
    if (!([self->resultRect_ empty])) {
        w = ([self->resultRect_ width] + 1);
        h = ([self->resultRect_ height] + 1);
        *(bmp) = [[PoCoBitmap alloc] initWidth:w
                                    initHeight:h
                                  defaultColor:0];
        edit = [[PoCoEditFlipHoriBitmap alloc] initDst:*(bmp)
                                               withSrc:org];
        [edit executeFlip];
        [edit release];
    }

    return;
}


//
// 反転(垂直)
//
//  Call
//    org             : 変形前
//    originalPoints_ : 支点座標群(変形前)(instance 変数)
//    resultRect_     : 外接長方形(変形後)(instance 変数)
//
//  Return
//    bmp : 変形後
//
-(void)createFlipVertBitmap:(PoCoBitmap *)org
               targetBitmap:(PoCoBitmap **)bmp
{
    PoCoEditFlipVertBitmap *edit;
    int w;
    int h;

    [*(bmp) release];
    *(bmp) = nil;
    if (!([self->resultRect_ empty])) {
        w = ([self->resultRect_ width] + 1);
        h = ([self->resultRect_ height] + 1);
        *(bmp) = [[PoCoBitmap alloc] initWidth:w
                                    initHeight:h
                                  defaultColor:0];
        edit = [[PoCoEditFlipVertBitmap alloc] initDst:*(bmp)
                                               withSrc:org];
        [edit executeFlip];
        [edit release];
    }

    return;
}


// ------------------------------------------------ instance - private - 変形中
//
// 移動
//
//  Call
//    p               : 制御点の移動先
//    evt             : 取得イベント
//    liveShape       : 形状の逐次更新
//    liveResult      : 結果の逐次更新
//    originalPoints_ : 支点座標群(変形前)(instance 変数)
//    originalShape_  : 形状(変形前)(instance 変数)
//    originalImage_  : 画像(変形前)(instance 変数)
//    point_          : 制御点(開始点)(instance 変数)
//    modify_         : 変形の修飾(instance 変数)
//
//  Return
//    resultPoints_ : 支点座標群(変形後)(instance 変数)
//    resultRect_   : 外接長方形(変形後)(instance 変数)
//    resultShape_  : 形状(変形後)(instance 変数)
//    resultImage_  : 画像(変形後)(instance 変数)
//    modify_       : 変形の修飾(instance 変数)
//
-(void)moveTrans:(PoCoPoint *)p
       withEvent:(NSEvent *)evt
     updateShape:(BOOL)liveShape
    updateResult:(BOOL)liveResult
{
    int dx;
    int dy;
    NSEnumerator* iter;
    PoCoPoint *tp1;
    PoCoPoint *tp2;

    if ([self isInnerHandle]) {
        // 以前の結果を忘れる
        [self clearResult];

        // 方向束縛
        if (([evt modifierFlags] & NSShiftKeyMask) != 0x00) {
            // 移動方向
            if (self->modify_ == PoCoModifierType_move_hori) {
                // 水平移動を維持
                [p setY:[self->point_ y]];
            } else if (self->modify_ == PoCoModifierType_move_vert) {
                // 垂直移動を維持
                [p setX:[self->point_ x]];
            } else if (abs([self->point_ y] - [p y]) < abs([self->point_ x] - [p x])) {
                // 水平移動を開始
                self->modify_ = PoCoModifierType_move_hori;
                [p setY:[self->point_ y]];
            } else {
                // 垂直移動を開始
                self->modify_ = PoCoModifierType_move_vert;
                [p setX:[self->point_ x]];
            }
        } else {
            // 修飾無し
            self->modify_ = PoCoModifierType_none;
        }

        // 移動量を算出
        dx = ([p x] - [self->point_ x]);
        dy = ([p y] - [self->point_ y]);

        // 座標移動
        if ((self->originalPoints_ == nil) ||
            ([self->originalPoints_ count] == 0)) {
            // 制御点がない(塗り選択の)場合は外接長方形を変形
            [self->resultRect_   setLeft:([self->originalRect_   left] + dx)];
            [self->resultRect_    setTop:([self->originalRect_    top] + dy)];
            [self->resultRect_  setRight:([self->originalRect_  right] + dx)];
            [self->resultRect_ setBottom:([self->originalRect_ bottom] + dy)];
        } else {
            // 制御点を変形
            iter = [self->originalPoints_ objectEnumerator];
            for (tp1 = [iter nextObject]; tp1 != nil; tp1 = [iter nextObject]) {
                tp2 = [[PoCoPoint alloc] initX:([tp1 x] + dx)
                                         initY:([tp1 y] + dy)];
                [PoCoSelectionShape addControlPoint:tp2
                                        targetArray:self->resultPoints_
                                         targetRect:self->resultRect_];
                [tp2 release];
            }
        }

        // 変形後の形状を生成
        if (liveResult) {
            [self createMoveBitmapTwin];
        } else if (liveShape) {
            [self createMoveBitmap:self->originalShape_
                      targetBitmap:&(self->resultShape_)];
        }
    }

    return;
}


//
// 変倍
//
//  Call
//    p               : 制御点の移動先
//    evt             : 取得イベント
//    liveShape       : 形状の逐次更新
//    liveResult      : 結果の逐次更新
//    originalPoints_ : 支点座標群(変形前)(instance 変数)
//    originalRect_   : 外接長方形(変形前)(instance 変数)
//    originalShape_  : 形状(変形前)(instance 変数)
//    originalImage_  : 画像(変形前)(instance 変数)
//    handle_         : 変形時のハンドル種別(instance 変数)
//    point_          : 制御点(開始点)(instance 変数)
//    modify_         : 変形の修飾(instance 変数)
//
//  Return
//    resultPoints_ : 支点座標群(変形後)(instance 変数)
//    resultRect_   : 外接長方形(変形後)(instance 変数)
//    resultShape_  : 形状(変形後)(instance 変数)
//    resultImage_  : 画像(変形後)(instance 変数)
//    modify_       : 変形の修飾(instance 変数)
//
-(void)resizeTrans:(PoCoPoint *)p
         withEvent:(NSEvent *)evt
       updateShape:(BOOL)liveShape
      updateResult:(BOOL)liveResult
{
    float h;
    float v;
    float x;
    float y;
    PoCoRect *r;
    NSEnumerator* iter;
    PoCoPoint *tp1;
    PoCoPoint *tp2;

    if ([self isCornerHandle]) {
        // 方向束縛
        if (([evt modifierFlags] & NSShiftKeyMask) != 0x00) {
            if ((self->modify_ == PoCoModifierType_resize_similer_hori) ||
                (self->modify_ == PoCoModifierType_resize_similer_vert)) {
                // 相似変形を維持
                [self similerPoint:p];
            } else if (self->modify_ == PoCoModifierType_resize_hori) {
                // 水平変形を維持
                [p setY:[self->point_ y]];
            } else if (self->modify_ == PoCoModifierType_resize_vert) {
                // 垂直変形を維持
                [p setX:[self->point_ x]];
            } else if (self->handle_ == PoCoHandleType_corner_lt) {
                // 左上
                if ((([self->point_ x] <= [p x])  &&
                     ([self->point_ y] <= [p y])) ||
                    (([self->point_ x] >  [p x])  &&
                     ([self->point_ y] >  [p y]))) {
                    // 相似変形を開始
                    [self similerPoint:p];
                } else if (([self->point_ x] <= [p x]) &&
                           ([self->point_ y] >  [p y])) {
                    // 垂直変形を開始
                    self->modify_ = PoCoModifierType_resize_vert;
                    [p setX:[self->point_ x]];
                } else /* if (([self->point_ x] >  [p x]) &&
                              ([self->point_ y] <= [p y])) */ {
                    // 水平変形を開始
                    self->modify_ = PoCoModifierType_resize_hori;
                    [p setY:[self->point_ y]];
                }
            } else if (self->handle_ == PoCoHandleType_corner_rt) {
                // 右上
                if ((([self->point_ x] <= [p x])  &&
                     ([self->point_ y] >  [p y])) ||
                    (([self->point_ x] >  [p x])  &&
                     ([self->point_ y] <= [p y]))) {
                    // 相似変形を開始
                    [self similerPoint:p];
                } else if (([self->point_ x] <= [p x]) &&
                           ([self->point_ y] <= [p y])) {
                    // 水平変形を開始
                    self->modify_ = PoCoModifierType_resize_hori;
                    [p setY:[self->point_ y]];
                } else /* if (([self->point_ x] >  [p x]) &&
                              ([self->point_ y] >  [p y])) */ {
                    // 垂直変形を開始
                    self->modify_ = PoCoModifierType_resize_vert;
                    [p setX:[self->point_ x]];
                }
            } else if (self->handle_ == PoCoHandleType_corner_rb) {
                // 右下
                if ((([self->point_ x] <= [p x])  &&
                     ([self->point_ y] <= [p y])) ||
                    (([self->point_ x] >  [p x])  &&
                     ([self->point_ y] >  [p y]))) {
                    // 相似変形を開始
                    [self similerPoint:p];
                } else if (([self->point_ x] <= [p x]) &&
                           ([self->point_ y] >  [p y])) {
                    // 水平変形を開始
                    self->modify_ = PoCoModifierType_resize_hori;
                    [p setY:[self->point_ y]];
                } else /* if (([self->point_ x] >  [p x]) &&
                              ([self->point_ y] <= [p y])) */ {
                    // 垂直変形を開始
                    self->modify_ = PoCoModifierType_resize_vert;
                    [p setX:[self->point_ x]];
                }
            } else /* if (self->handle_ == PoCoHandleType_corner_lb) */ {
                // 左下
                if ((([self->point_ x] <= [p x])  &&
                     ([self->point_ y] >  [p y])) ||
                    (([self->point_ x] >  [p x])  &&
                     ([self->point_ y] <= [p y]))) {
                    // 相似変形を開始
                    [self similerPoint:p];
                } else if (([self->point_ x] <= [p x]) &&
                           ([self->point_ y] <= [p y])) {
                    // 垂直変形を開始
                    self->modify_ = PoCoModifierType_resize_vert;
                    [p setX:[self->point_ x]];
                } else /* if (([self->point_ x] >  [p x]) &&
                              ([self->point_ y] >  [p y])) */ {
                    // 水平変形を開始
                    self->modify_ = PoCoModifierType_resize_hori;
                    [p setY:[self->point_ y]];
                }
            }
        } else {
            // 修飾無し
            self->modify_ = PoCoModifierType_none;
        }

        // 変倍結果を算出
        r = [[PoCoRect alloc] initPoCoRect:self->originalRect_];
        if (self->handle_ == PoCoHandleType_corner_lt) {
            [r setLeft:[p x]];
            [r setTop:[p y]];
        } else if (self->handle_ == PoCoHandleType_corner_rt) {
            [r setRight:[p x]];
            [r setTop:[p y]];
        } else if (self->handle_ == PoCoHandleType_corner_rb) {
            [r setRight:[p x]];
            [r setBottom:[p y]];
        } else /* if (self->handle_ == PoCoHandleType_corner_lb) */ {
            [r setLeft:[p x]];
            [r setBottom:[p y]];
        }
        if (!([r empty])) {
            // 以前の結果を忘れる
            [self clearResult];

            // 変倍結果を更新
            [self->resultRect_ release];
            self->resultRect_ = [[PoCoRect alloc] initPoCoRect:r];

            // 変倍率を算出
            h = ((float)([self->resultRect_ width]) / (float)([self->originalRect_ width]));
            v = ((float)([self->resultRect_ height]) / (float)([self->originalRect_ height]));

            // 座標変倍
            if ((self->originalPoints_ == nil) ||
                ([self->originalPoints_ count] == 0)) {
                // 制御点がない(塗り選択の)場合は外接長方形を変形
                [self->resultRect_   setLeft:[self->originalRect_   left]];
                [self->resultRect_    setTop:[self->originalRect_    top]];
                [self->resultRect_  setRight:[self->originalRect_  right]];
                [self->resultRect_ setBottom:[self->originalRect_ bottom]];
                if (self->handle_ == PoCoHandleType_corner_lt) {
                    [self->resultRect_ setLeft:(int)(floor(((float)([self->originalRect_ right]) - ((float)([self->originalRect_ right] - [self->originalRect_ left]) * h)) + 0.5))];
                    [self->resultRect_ setTop:(int)(floor(((float)([self->originalRect_ bottom]) - ((float)([self->originalRect_ bottom] - [self->originalRect_ top]) * v)) + 0.5))];
                } else if (self->handle_ == PoCoHandleType_corner_rt) {
                    [self->resultRect_ setRight:(int)(floor(((float)([self->originalRect_ left]) + ((float)([self->originalRect_ right] - [self->originalRect_ left]) * h)) + 0.5))];
                    [self->resultRect_ setTop:(int)(floor(((float)([self->originalRect_ bottom]) - ((float)([self->originalRect_ bottom] - [self->originalRect_ top]) * v)) + 0.5))];
                } else if (self->handle_ == PoCoHandleType_corner_rb) {
                    [self->resultRect_ setRight:(int)(floor(((float)([self->originalRect_ left]) + ((float)([self->originalRect_ right] - [self->originalRect_ left]) * h)) + 0.5))];
                    [self->resultRect_ setBottom:(int)(floor(((float)([self->originalRect_ top]) + ((float)([self->originalRect_ bottom] - [self->originalRect_ top]) * v)) + 0.5))];
                } else /* if (self->handle_ == PoCoHandleType_corner_lb) */ {
                    [self->resultRect_ setLeft:(int)(floor(((float)([self->originalRect_ right]) - ((float)([self->originalRect_ right] - [self->originalRect_ left]) * h)) + 0.5))];
                    [self->resultRect_ setBottom:(int)(floor(((float)([self->originalRect_ top]) + ((float)([self->originalRect_ bottom] - [self->originalRect_ top]) * v)) + 0.5))];
                }
            } else {
                // 制御点を変形
                iter = [self->originalPoints_ objectEnumerator];
                for (tp1 = [iter nextObject]; tp1 != nil; tp1 = [iter nextObject]) {
                    if (self->handle_ == PoCoHandleType_corner_lt) {
                        x = ((float)([self->originalRect_ right]) - ((float)([self->originalRect_ right] - [tp1 x]) * h));
                        y = ((float)([self->originalRect_ bottom]) - ((float)([self->originalRect_ bottom] - [tp1 y]) * v));
                    } else if (self->handle_ == PoCoHandleType_corner_rt) {
                        x = ((float)([self->originalRect_ left]) + ((float)([tp1 x] - [self->originalRect_ left]) * h));
                        y = ((float)([self->originalRect_ bottom]) - ((float)([self->originalRect_ bottom] - [tp1 y]) * v));
                    } else if (self->handle_ == PoCoHandleType_corner_rb) {
                        x = ((float)([self->originalRect_ left]) + ((float)([tp1 x] - [self->originalRect_ left]) * h));
                        y = ((float)([self->originalRect_ top]) + ((float)([tp1 y] - [self->originalRect_ top]) * v));
                    } else /* if (self->handle_ == PoCoHandleType_corner_lb) */ {
                        x = ((float)([self->originalRect_ right]) - ((float)([self->originalRect_ right] - [tp1 x]) * h));
                        y = ((float)([self->originalRect_ top]) + ((float)([tp1 y] - [self->originalRect_ top]) * v));
                    }
                    tp2 = [[PoCoPoint alloc] initX:(int)(floor(x + 0.5))
                                             initY:(int)(floor(y + 0.5))];
                    [PoCoSelectionShape addControlPoint:tp2
                                            targetArray:self->resultPoints_
                                             targetRect:self->resultRect_];
                    [tp2 release];
                }
            }

            // 変形後の形状を生成
            if (liveResult) {
                [self createResizeBitmapTwin];
            } else if (liveShape) {
                [self createResizeBitmap:self->originalShape_
                            targetBitmap:&(self->resultShape_)];
            }
        }
        [r release];
    }

    return;
}


//
// 回転
//
//  Call
//    p               : 制御点の移動先
//    evt             : 取得イベント
//    liveShape       : 形状の逐次更新
//    liveResult      : 結果の逐次更新
//    originalPoints_ : 支点座標群(変形前)(instance 変数)
//    originalShape_  : 形状(変形前)(instance 変数)
//    originalImage_  : 画像(変形前)(instance 変数)
//    modify_         : 変形の修飾(instance 変数)
//
//  Return
//    resultPoints_ : 支点座標群(変形後)(instance 変数)
//    resultRect_   : 外接長方形(変形後)(instance 変数)
//    rotate_       : 回転関数(instance 変数)
//    resultShape_  : 形状(変形後)(instance 変数)
//    resultImage_  : 画像(変形後)(instance 変数)
//    modify_       : 変形の修飾(instance 変数)
//
-(void)rotateTrans:(PoCoPoint *)p
         withEvent:(NSEvent *)evt
       updateShape:(BOOL)liveShape
      updateResult:(BOOL)liveResult
{
    NSEnumerator* iter;
    PoCoPoint *tp1;
    PoCoPoint *tp2;

    if ([self isEdgeHandle]) {
        // 方向束縛
        if (([evt modifierFlags] & NSShiftKeyMask) != 0x00) {
            // 角度
            self->modify_ = PoCoModifierType_rotate;
        } else {
            // 修飾無し
            self->modify_ = PoCoModifierType_none;
        }

        // 角度を算出
        if ([self->rotate_ moveControlPoint:p
                                  isCorrect:(self->modify_ == PoCoModifierType_rotate)]) {
            // 以前の結果を忘れる
            [self clearResult];

            // 座標回転
            if ((self->originalPoints_ == nil) ||
                ([self->originalPoints_ count] == 0)) {
                // 制御点がない(塗り選択の)場合は変形前の形状のすべての点を走査
                [self calcRotateRectFromOriginalShape];
            } else {
                // 制御点を変形
                iter = [self->originalPoints_ objectEnumerator];
                for (tp1 = [iter nextObject]; tp1 != nil; tp1 = [iter nextObject]) {
                    tp2 = [[PoCoPoint alloc] initX:[tp1 x]
                                             initY:[tp1 y]];
                    [self->rotate_ calcPoint:tp2];
                    [PoCoSelectionShape addControlPoint:tp2
                                            targetArray:self->resultPoints_
                                             targetRect:self->resultRect_];
                    [tp2 release];
                }
            }

            // 変形後の形状を生成
            if (liveResult) {
                [self createRotateBitmapTwin];
            } else if (liveShape) {
                [self createRotateBitmap:self->originalShape_
                            targetBitmap:&(self->resultShape_)];
            }
        }
    }

    return;
}


//
// 反転(水平)
//
//  Call
//    originalPoints_ : 支点座標群(変形前)(instance 変数)
//    originalRect_   : 外接長方形(変形前)(instance 変数)
//
//  Return
//    resultPoints_ : 支点座標群(変形後)(instance 変数)
//    resultRect_   : 外接長方形(変形後)(instance 変数)
//
-(void)flipHori
{
    int left;
    int right;
    NSEnumerator* iter;
    PoCoPoint *tp1;
    PoCoPoint *tp2;

    left = [self->originalRect_ left];
    right = [self->originalRect_ right];

    // 以前の結果を忘れる
    [self->resultPoints_ removeAllObjects];

    // 座標移動
    iter = [self->originalPoints_ objectEnumerator];
    for (tp1 = [iter nextObject]; tp1 != nil; tp1 = [iter nextObject]) {
        tp2 = [[PoCoPoint alloc] initX:(right - ([tp1 x] - left))
                                 initY:[tp1 y]];
        [self->resultPoints_ addObject:tp2];
        [tp2 release];
    }

    return;
}


//
// 反転(垂直)
//
//  Call
//    originalPoints_ : 支点座標群(変形前)(instance 変数)
//    originalRect_   : 外接長方形(変形前)(instance 変数)
//
//  Return
//    resultPoints_ : 支点座標群(変形後)(instance 変数)
//    resultRect_   : 外接長方形(変形後)(instance 変数)
//
-(void)flipVert
{
    int top;
    int bottom;
    NSEnumerator* iter;
    PoCoPoint *tp1;
    PoCoPoint *tp2;

    top = [self->originalRect_ top];
    bottom = [self->originalRect_ bottom];

    // 以前の内容を忘れる
    [self->resultPoints_ removeAllObjects];

    // 座標移動
    iter = [self->originalPoints_ objectEnumerator];
    for (tp1 = [iter nextObject]; tp1 != nil; tp1 = [iter nextObject]) {
        tp2 = [[PoCoPoint alloc] initX:[tp1 x]
                                 initY:(bottom - ([tp1 y] - top))];
        [self->resultPoints_ addObject:tp2];
        [tp2 release];
    }

    return;
}


// ------------------------------------------------------------- class - public
//
// 四隅か
//
//  Call
//    type : 種類
//
//  Return
//    function : 判定結果
//
+(BOOL)isCorner:(PoCoHandleType)type
{
    return ((type == PoCoHandleType_corner_lt) ||
            (type == PoCoHandleType_corner_rt) ||
            (type == PoCoHandleType_corner_rb) ||
            (type == PoCoHandleType_corner_lb));
}


//
// 四辺か
//
//  Call
//    type : 種類
//
//  Return
//    function : 判定結果
//
+(BOOL)isEdge:(PoCoHandleType)type
{
    return ((type == PoCoHandleType_edge_t) ||
            (type == PoCoHandleType_edge_r) ||
            (type == PoCoHandleType_edge_b) ||
            (type == PoCoHandleType_edge_l));
}


//
// 領域内か
//
//  Call
//    type : 種類
//
//  Return
//    function : 判定結果
//
+(BOOL)isInner:(PoCoHandleType)type
{
    return ((type == PoCoHandleType_center) ||
            (type == PoCoHandleType_in_rect) ||
            (type == PoCoHandleType_in_shape));
}


//
// 領域外か
//
//  Call
//    type : 種類
//
//  Return
//    function : 判定結果
//
+(BOOL)isOuter:(PoCoHandleType)type
{
    return ((type == PoCoHandleType_effective) ||
            (type == PoCoHandleType_out_rect) ||
            (type == PoCoHandleType_out_shape) ||
            (type == PoCoHandleType_unknown));
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    originalPoints_   : 支点座標群(変形前)(instance 変数)
//    originalRect_     : 外接長方形(変形前)(instance 変数)
//    originalHandle_[] : ハンドル(変形前)(instance 変数)
//    originalShape_    : 形状(変形前)(instance 変数)
//    originalImage_    : 画像(変形前)(instance 変数)
//    resultPoints_     : 支点座標群(変形後)(instance 変数)
//    resultRect_       : 外接長方形(変形後)(instance 変数)
//    resultHandle_[]   : ハンドル(変形後)(instance 変数)
//    resultShape_      : 形状(変形後)(instance 変数)
//    resultImage_      : 画像(変形後)(instance 変数)
//    handle_           : 変形時のハンドル種別(instance 変数)
//    point_            : 制御点(開始点)(instance 変数)
//    rotate_           : 回転関数(instance 変数)
//    modify_           : 変形の修飾(instance 変数)
//
-(id)init
{
    int l;

    DPRINT((@"[PoCoSelectionShape init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        for (l = 0; l < (int)(PoCoHandleType_effective); (l)++) {
            self->originalHandle_[l] = nil;
            self->resultHandle_[l] = nil;
        }
        self->originalPoints_ = nil;
        self->originalRect_ = nil;
        self->originalShape_ = nil;
        self->originalImage_ = nil;
        self->resultPoints_ = nil;
        self->resultRect_ = nil;
        self->resultShape_ = nil;
        self->resultImage_ = nil;
        self->handle_ = PoCoHandleType_unknown;
        self->point_ = nil;
        self->rotate_ = nil;
        self->modify_ = PoCoModifierType_none;

        // 資源を確保
        self->originalPoints_ = [[NSMutableArray alloc] init];
        self->resultPoints_ = [[NSMutableArray alloc] init];
        self->originalRect_ = [[PoCoRect alloc] initLeft:INT_MAX
                                                 initTop:INT_MAX
                                               initRight:INT_MIN
                                              initBottom:INT_MIN];
        self->resultRect_ = [[PoCoRect alloc] initLeft:INT_MAX
                                               initTop:INT_MAX
                                             initRight:INT_MIN
                                            initBottom:INT_MIN];
        if ((self->originalPoints_ == nil) ||
            (self->originalRect_ == nil) ||
            (self->resultPoints_ == nil) ||
            (self->resultRect_ == nil)) {
            DPRINT((@"can't allocation.\n"));
            [self release];
            self = nil;
        }
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
//    originalPoints_   : 支点座標群(変形前)(instance 変数)
//    originalRect_     : 外接長方形(変形前)(instance 変数)
//    originalHandle_[] : ハンドル(変形前)(instance 変数)
//    originalShape_    : 形状(変形前)(instance 変数)
//    originalImage_    : 画像(変形前)(instance 変数)
//    resultPoints_     : 支点座標群(変形後)(instance 変数)
//    resultRect_       : 外接長方形(変形後)(instance 変数)
//    resultHandle_[]   : ハンドル(変形後)(instance 変数)
//    resultShape_      : 形状(変形後)(instance 変数)
//    resultImage_      : 画像(変形後)(instance 変数)
//    point_            : 制御点(開始点)(instance 変数)
//    rotate_           : 回転関数(instance 変数)
//
-(void)dealloc
{
    int l;

    DPRINT((@"[PoCoSelectionShape dealloc]\n"));

    // 資源を解放
    for (l = 0; l < (int)(PoCoHandleType_effective); (l)++) {
        [self->originalHandle_[l] release];
        [self->resultHandle_[l] release];
        self->originalHandle_[l] = nil;
        self->resultHandle_[l] = nil;
    }
    [self->originalPoints_ release];
    [self->originalRect_ release];
    [self->originalShape_ release];
    [self->originalImage_ release];
    [self->resultPoints_ release];
    [self->resultRect_ release];
    [self->resultShape_ release];
    [self->resultImage_ release];
    [self->point_ release];
    [self->rotate_ release];
    self->originalPoints_ = nil;
    self->originalRect_ = nil;
    self->originalShape_ = nil;
    self->originalImage_ = nil;
    self->resultPoints_ = nil;
    self->resultRect_ = nil;
    self->resultShape_ = nil;
    self->resultImage_ = nil;
    self->point_ = nil;
    self->rotate_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 変形前の形状を忘れる
//
//  Call
//    None
//
//  Return
//    originalPoints_   : 支点座標群(変形前)(instance 変数)
//    originalRect_     : 外接長方形(変形前)(instance 変数)
//    originalHandle_[] : ハンドル(変形前)(instance 変数)
//    originalShape_    : 形状(変形前)(instance 変数)
//
-(void)clearOriginal
{
    int l;

    [self->originalPoints_ removeAllObjects];
    [self->originalRect_   setLeft:INT_MAX];
    [self->originalRect_    setTop:INT_MAX];
    [self->originalRect_  setRight:INT_MIN];
    [self->originalRect_ setBottom:INT_MIN];
    [self->originalShape_ release];
    for (l = 0; l < (int)(PoCoHandleType_effective); (l)++) {
        [self->originalHandle_[l] release];
        self->originalHandle_[l] = nil;
    }
    self->originalShape_ = nil;

    return;
}


//
// 変形前の支点を登録
//
//  Call
//    p : 登録する点
//        == nil : 形状確定
//        != nil : 点を追加
//
//  Return
//    originalPoints_   : 支点座標群(変形前)(instance 変数)
//    originalRect_     : 外接長方形(変形前)(instance 変数)
//    originalHandle_[] : ハンドル(変形前)(instance 変数)
//    originalShape_    : 形状(変形前)(instance 変数)
//
-(void)addPoint:(PoCoPoint *)p
{
    if (p != nil) {
        // 点を追加
        [PoCoSelectionShape addControlPoint:p
                                targetArray:self->originalPoints_
                                 targetRect:self->originalRect_];
    } else {
        // 形状確定
        [PoCoSelectionShape createShape:self->originalPoints_
                               withRect:self->originalRect_
                          targetHandles:(PoCoRect **)(&(self->originalHandle_))
                            targetShape:&(self->originalShape_)];
        [self copyOriginalToResult];
    }

    return;
}


//
// 変形前の画像を登録
//  変形前として覚える内容は単純に実体へのポインタ複写なので、
//  呼び出し元で bmp の release は不要(呼び出し元で bmp の alloc が必要)
//
//  Call
//    bmp : 画像
//
//  Return
//    originalImage_ : 画像(変形前)(instance 変数)
//    resultImage_   : 画像(変形後)(instance 変数)
//
-(void)setImage:(PoCoBitmap *)bmp
{
    // 以前の分を忘れる
    [self->originalImage_ release];
    [self->resultImage_ release];

    // 変形前は単純に実体へのポインタ複写
    self->originalImage_ = bmp;

    // 変形後は複製
    self->resultImage_ = [bmp copy];

    return;
}


//
// 変形後の形状を変形前の形状に複写
//
//  Call
//    resultPoints_   : 支点座標群(変形後)(instance 変数)
//    resultRect_     : 外接長方形(変形後)(instance 変数)
//    resultHandle_[] : ハンドル(変形後)(instance 変数)
//    resultShape_    : 形状(変形後)(instance 変数)
//
//  Return
//    originalPoints_   : 支点座標群(変形前)(instance 変数)
//    originalRect_     : 外接長方形(変形前)(instance 変数)
//    originalHandle_[] : ハンドル(変形前)(instance 変数)
//    originalShape_    : 形状(変形前)(instance 変数)
//
-(void)copyResultToOriginal
{
    NSEnumerator* iter;
    PoCoPoint *p;
    PoCoPoint *tmp;
    int l;

    // 以前の内容を忘れる
    [self clearOriginal];

    // 支点座標群
    [self->originalPoints_ release];
    self->originalPoints_ = [[NSMutableArray alloc] init];
    iter = [self->resultPoints_ objectEnumerator];
    for (p = [iter nextObject]; p != nil; p = [iter nextObject]) {
        tmp = [[PoCoPoint alloc] initX:[p x]
                                 initY:[p y]];
        [self->originalPoints_ addObject:tmp];
        [tmp release];
    }

    // 外接長方形
    [self->originalRect_ release];
    self->originalRect_ = [[PoCoRect alloc]
                              initLeft:[self->resultRect_ left]
                               initTop:[self->resultRect_ top]
                             initRight:[self->resultRect_ right]
                            initBottom:[self->resultRect_ bottom]];

    // 形状マスク
    self->originalShape_ = [self->resultShape_ copy];

    // ハンドル
    for (l = 0; l < (int)(PoCoHandleType_effective); (l)++) {
        self->originalHandle_[l] = [[PoCoRect alloc]
              initLeft:[self->resultHandle_[l] left]
               initTop:[self->resultHandle_[l] top]
             initRight:[self->resultHandle_[l] right]
            initBottom:[self->resultHandle_[l] bottom]];
    }

    return;
}


// ----------------------------------------------- instance - public - 補助情報
//
// 変形時のハンドル種別
//
//  Call
//    handle_ : 変形時のハンドル種別(instance 変数)
//
//  Return
//    function : 変形時のハンドル種別
//
-(PoCoHandleType)controlHandle
{
    return self->handle_;
}


//
// 制御点
//
//  Call
//    point_ : 制御点(開始点)(instance 変数)
//
//  Return
//    function : 制御点(開始点)
//
-(PoCoPoint *)controlPoint
{
    return self->point_;
}


//
// 回転関数
//
//  Call
//    rotate_ : 回転関数(instance 変数)
//
//  Return
//    rotate_ : 回転関数
//
-(PoCoCalcRotation *)calcRotater
{
    return self->rotate_;
}


//
// 四隅か
//
//  Call
//    handle_ : 変形時のハンドル種別(instance 変数)
//
//  Return
//    function : 判定結果
//
-(BOOL)isCornerHandle
{
    return [PoCoSelectionShape isCorner:self->handle_];
}


//
// 四辺か
//
//  Call
//    handle_ : 変形時のハンドル種別(instance 変数)
//
//  Return
//    function : 判定結果
//
-(BOOL)isEdgeHandle
{
    return [PoCoSelectionShape isEdge:self->handle_];
}


//
// 領域内か
//
//  Call
//    handle_ : 変形時のハンドル種別(instance 変数)
//
//  Return
//    function : 判定結果
//
-(BOOL)isInnerHandle
{
    return [PoCoSelectionShape isInner:self->handle_];
}


//
// 領域外か
//
//  Call
//    handle_ : 変形時のハンドル種別(instance 変数)
//
//  Return
//    function : 判定結果
//
-(BOOL)isOuterHandle
{
    return [PoCoSelectionShape isOuter:self->handle_];
}


// ----------------------------------------- instance - public - 変形前形状取得
//
// 支点座標群
//
//  Call
//    originalPoints_ : 支点座標群(変形前)(instance 変数)
//
//  Return
//    function : 支点座標群(変形前)
//
-(NSMutableArray *)originalPoints
{
    return self->originalPoints_;
}


//
// 外接長方形
//
//  Call
//    originalRect_ : 外接長方形(変形前)(instance 変数)
//
//  Return
//    function : 外接長方形(変形前)
//
-(PoCoRect *)originalRect
{
    return self->originalRect_;
}


//
// ハンドル
//
//  Call
//    type              : 種類
//    originalHandle_[] : ハンドル(変形前)(instance 変数)
//
//  Return
//    function : ハンドル(変形前)
//
-(PoCoRect *)originalHandle:(PoCoHandleType)type
{
    int i = (int)(type);

    return ((i < (int)(PoCoHandleType_effective)) ? self->originalHandle_[i] : nil);
}


//
// 形状
//
//  Call
//    originalShape_ : 形状(変形前)(instance 変数)
//
//  Return
//    function : 形状(変形前)
//
-(PoCoBitmap *)originalShape
{
    return self->originalShape_;
}


//
// 画像
//
//  Call
//    originalImage_ : 画像(変形前)(instance 変数)
//
//  Return
//    function : 画像(変形前)
//
-(PoCoBitmap *)originalImage
{
    return self->originalImage_;
}


//
// 位置判定
//
//  Call
//    p                 : 検証する点
//    gap               : ハンドルの拡張幅
//    shape             : 形状を対象とするか
//                        YES : 形状から外接長方形から判定する
//                        NO  : 外接長方形のみで判定する
//    originalRect_     : 外接長方形(変形前)(instance 変数)
//    originalHandle_[] : ハンドル(変形前)(instance 変数)
//    originalShape_    : 形状(変形前)(instance 変数)
//
//  Return
//    function : 種類
//
-(PoCoHandleType)originalHitTest:(PoCoPoint *)p
                       handleGap:(int)gap
                       withShape:(BOOL)shape
{
    return [PoCoSelectionShape hitTest:p
                             handleGap:gap
                              withRect:self->originalRect_
                           withHanldes:(PoCoRect **)(&(self->originalHandle_))
                             withShape:((shape) ? self->originalShape_ : nil)];
}


//
// 外接長方形と支点群が同一領域か
//
//  Call
//    originalPoints_ : 支点座標群(変形前)(instance 変数)
//    originalRect_   : 外接長方形(変形前)(instance 変数)
//
//  Return
//    function : 判定結果
//
-(BOOL)isSameStyleOriginalRectShape
{
    return [PoCoSelectionShape isSameStyle:self->originalRect_
                                 testShape:self->originalPoints_];
}


// ----------------------------------------- instance - public - 変形後形状取得
//
// 支点座標群
//
//  Call
//    resultPoints_ : 支点座標群(変形後)(instance 変数)
//
//  Return
//    function : 支点座標群(変形後)
//
-(NSMutableArray *)resultPoints
{
    return self->resultPoints_;
}


//
// 外接長方形
//
//  Call
//    resultRect_ : 外接長方形(変形後)(instance 変数)
//
//  Return
//    function : 外接長方形(変形後)
//
-(PoCoRect *)resultRect
{
    return self->resultRect_;
}


//
// ハンドル
//
//  Call
//    type            : 種類
//    resultHandle_[] : ハンドル(変形後)(instance 変数)
//
//  Return
//    function : ハンドル(変形後)
//
-(PoCoRect *)resultHandle:(PoCoHandleType)type
{
    int i = (int)(type);

    return ((i < (int)(PoCoHandleType_effective)) ? self->resultHandle_[i] : nil);
}


//
// 形状
//
//  Call
//    resultShape_ : 形状(変形後)(instance 変数)
//
//  Return
//    function : 形状(変形後)
//
-(PoCoBitmap *)resultShape
{
    return self->resultShape_;
}


//
// 画像
//
//  Call
//    resultImage_ : 画像(変形後)(instance 変数)
//
//  Return
//    function : 画像(変形後)
//
-(PoCoBitmap *)resultImage
{
    return self->resultImage_;
}


//
// 位置判定
//
//  Call
//    p               : 検証する点
//    gap             : ハンドルの拡張幅
//    shape           : 形状を対象とするか
//                      YES : 形状から外接長方形から判定する
//                      NO  : 外接長方形のみで判定する
//    resultRect_     : 外接長方形(変形後)(instance 変数)
//    resultHandle_[] : ハンドル(変形後)(instance 変数)
//    resultShape_    : 形状(変形後)(instance 変数)
//
//  Return
//    function : 種類
//
-(PoCoHandleType)resultHitTest:(PoCoPoint *)p
                     handleGap:(int)gap
                     withShape:(BOOL)shape
{
    return [PoCoSelectionShape hitTest:p
                             handleGap:gap
                              withRect:self->resultRect_
                           withHanldes:(PoCoRect **)(&(self->resultHandle_))
                             withShape:((shape) ? self->resultShape_ : nil)];
}


//
// 外接長方形と支点群が同一領域か
//
//  Call
//    resultPoints_ : 支点座標群(変形後)(instance 変数)
//    resultRect_   : 外接長方形(変形後)(instance 変数)
//
//  Return
//    function : 判定結果
//
-(BOOL)isSameStyleResultRectShape
{
    return [PoCoSelectionShape isSameStyle:self->resultRect_
                                 testShape:self->resultPoints_];
}


// --------------------------------------------------- instance - public - 変形
//
// 開始
//
//  Call
//    p     : 制御点(開始点)
//    gap   : ハンドルの拡張幅
//    shape : 形状を対象とするか
//             YES : 形状から外接長方形から判定する
//             NO  : 外接長方形のみで判定する
//
//  Return
//    function : 開始したか
//               YES : 形状変更開始
//               NO  : 開始していない(制御点が選択範囲外)
//    handle_  : 変形時のハンドル種別(instance 変数)
//    point_   : 制御点(開始点)(instance 変数)
//    rotate_  : 回転関数(instance 変数)
//    modify_  : 変形の修飾(instance 変数)
//
-(BOOL)startTrans:(PoCoPoint *)p
        handleGap:(int)gap
        withShape:(BOOL)shape
{
    BOOL result;
    BOOL v;
    BOOL g;

    result = YES;

    // 以前の変形情報忘れる
    [self->point_ release];
    [self->rotate_ release];
    self->point_ = nil;
    self->rotate_ = nil;
    self->handle_ = PoCoHandleType_unknown;
    self->modify_ = PoCoModifierType_none;

    // 制御点を覚える
    self->point_ = [[PoCoPoint alloc] initX:[p x]
                                      initY:[p y]];

    // 変形結果に対して hit test
    self->handle_ = [self resultHitTest:p
                              handleGap:gap
                              withShape:shape];
    if ([self isInnerHandle]) {
        // 移動系
        ;
    } else if ([self isCornerHandle]) {
        // 変倍系
        ;
    } else if ([self isEdgeHandle]) {
        // 回転系
        switch (self->handle_) {
            default:
            case PoCoHandleType_edge_t:
                // 上底
                v = NO;
                g = NO;
                break;
            case PoCoHandleType_edge_b:
                // 下底
                v = NO;
                g = YES;
                break;
            case PoCoHandleType_edge_r:
                // 右辺
                v = YES;
                g = YES;
                break;
            case PoCoHandleType_edge_l:
                // 左辺
                v = YES;
                g = NO;
                break;
        }
        self->rotate_ = [[PoCoCalcRotation alloc]
                            initWithControlPoint:[self->resultHandle_[PoCoHandleType_center] lefttop]
                               isVerticalControl:v
                                isGreaterControl:g];
    } else /* if ([self isOterHandle]) */ {
        // 不明
        [self->point_ release];
        self->point_ = nil;
        self->handle_ = PoCoHandleType_unknown;
        self->modify_ = PoCoModifierType_none;
        result = NO;
    }

    return result;
}


//
// 変形中
//
//  Call
//    p          : 制御点の移動先
//    evt        : 取得イベント
//    liveShape  : 形状の逐次更新
//    liveResult : 結果の逐次更新
//    handle_    : 変形時のハンドル種別(instance 変数)
//    point_     : 制御点(開始点)(instance 変数)
//
//  Return
//    None
//
-(void)runningTrans:(PoCoPoint *)p
          withEvent:(NSEvent *)evt
  isLiveUpdateShape:(BOOL)liveShape
 isLiveUpdateResult:(BOOL)liveResult
{
    PoCoPoint *tmp;

    // 変形の修飾で制御点を上書きするので複製する
    tmp = [[PoCoPoint alloc] initX:[p x]
                             initY:[p y]];
    if ([self isInnerHandle]) {
        // 移動系
        [self moveTrans:tmp
              withEvent:evt
            updateShape:liveShape
           updateResult:liveResult];
    } else if ([self isCornerHandle]) {
        // 変倍系
        [self resizeTrans:tmp
                withEvent:evt
              updateShape:liveShape
             updateResult:liveResult];
    } else if ([self isEdgeHandle]) {
        // 回転系
        [self rotateTrans:tmp
                withEvent:evt
              updateShape:liveShape
             updateResult:liveResult];
    } else /* if ([self isOterHandle]) */ {
        // 不明
        ;
    }
    [tmp release];

    return;
}


//
// 終了
//
//  Call
//    originalShape_ : 形状(変形前)(instance 変数)
//    originalImage_ : 画像(変形前)(instance 変数)
//    resultPoints_  : 支点座標群(変形後)(instance 変数)
//    resultRect_    : 外接長方形(変形後)(instance 変数)
//    handle_        : 変形時のハンドル種別(instance 変数)
//
//  Return
//    resultHandle_[] : ハンドル(変形後)(instance 変数)
//    resultShape_    : 形状(変形後)(instance 変数)
//    resultImage_    : 画像(変形後)(instance 変数)
//
-(void)endTrans
{
    if ([self isOuterHandle]) {
        // 不明
        ;
    } else {
        // 形状確定
        [PoCoSelectionShape createShape:self->resultPoints_
                               withRect:self->resultRect_
                          targetHandles:(PoCoRect **)(&(self->resultHandle_))
                            targetShape:&(self->resultShape_)];

        if ([self isInnerHandle]) {
            // 移動系
            [self createMoveBitmapTwin];
            [self copyResultToOriginal];
        } else if ([self isCornerHandle]) {
            // 変倍系
            [self createResizeBitmapTwin];
        } else if ([self isEdgeHandle]) {
            // 回転系
            [self createRotateBitmapTwin];
        }
    }

    return;
}


// ------------------------------------------- instance - public - その他の加工
//
// 削除
//
//  Call
//    doc           : document
//    info          : 編集情報
//    resultPoints_ : 支点座標群(変形後)(instance 変数)
//    resultRect_   : 外接長方形(変形後)(instance 変数)
//    resultShape_  : 形状(変形後)(instance 変数)
//
//  Return
//    resultImage_   : 画像(変形後)(instance 変数)
//    originalImage_ : 画像(変形前)(instance 変数)
//
-(void)delete:(MyDocument *)doc
 withEditInfo:(PoCoEditInfo *)info
#if 0   // 旧実装(常に選択色での塗りつぶしのみ)
{
    PoCoEditRegionFill *edit;
    PoCoMonochromePattern *tile;
    PoCoColorPattern *pat;
    PoCoPoint *sp;
    PoCoPoint *ep;

    edit = nil;
    tile = nil;
    pat = nil;

    // 以前の結果を忘れる
    [self->resultImage_ release];
    self->resultImage_ = nil;

    // 範囲選択状態なら描画
    if (!([self->resultRect_ empty])) {
        // 使用タイルパターンを選別
        tile = [[(PoCoAppController *)([NSApp delegate]) tilePattern] pattern:[info tileNumber]];  

        // 描画パターンを選別
        if (([info eraserType]) && ([doc eraser] != nil)) {
            // 以前の画像を使用(alloc はしないので retain しておく)
            pat = [doc eraser];
            [pat retain];
        } else if (([[info selColor] isUnder]) && ([[doc selLayer] sel] > 0)) {
            // 背面レイヤーを使用
            pat = [[PoCoColorPattern alloc] initWithBitmap:[[[doc picture] layer:([[doc selLayer] sel] - 1)] bitmap]]; 
        } else if ([[info selColor] isPattern]) {
            // カラーパターンを使用(alloc はしないので retain しておく)
            pat = [[doc picture] colpat:[[info selColor] num]];
            [pat retain];
        } else {
            // 通常の色を使用
            pat = [[PoCoColorPattern alloc] initWidth:1
                                           initHeight:1
                                         defaultColor:[[info selColor] num]];
        }

        // 編集実行
        self->resultImage_ = [[PoCoBitmap alloc]
                                     initWidth:([self->resultRect_ width] + 1)
                                    initHeight:([self->resultRect_ height] + 1)
                                  defaultColor:0];
        ep = [[PoCoPoint alloc] init];
        sp = [[PoCoPoint alloc] initX:[self->resultImage_ width]
                                initY:[self->resultImage_ height]];
        edit = [[PoCoEditRegionFill alloc]
                   initWithPattern:self->resultImage_
                           palette:[[doc picture] palette]
                              tile:tile
                           pattern:pat
                         checkDist:NO];
        [edit executeDraw:self->resultShape_
             withStartPos:sp
               withEndPos:ep];
        [edit release];
        [ep release];
        [sp release];

        // 描画パターンを解放
        [pat release];

        // 結果を複写
        [self copyResultToOriginal];
        [self->originalImage_ release];
        self->originalImage_ = [self->resultImage_ copy];
    }

    return;
}
#else   // 0  // ペン先に依存した描画とする
{
    id edit;
    PoCoMonochromePattern *tile;
    PoCoColorPattern *pat;
    PoCoBitmap *behind;
    PoCoPoint *sp;
    PoCoPoint *ep;
    PoCoRect *r;
    int ratio;
    PoCoBitmap *shape;

    edit = nil;
    tile = nil;
    pat = nil;
    sp = nil;
    ep = nil;
    r = nil;
    shape = nil;
    behind = nil;

    // 以前の結果を忘れる
    [self->resultImage_ release];
    self->resultImage_ = nil;

    // 選択範囲無しでは何もできない
    if ([self->resultRect_ empty]) {
        goto EXIT;
    }

    // 使用タイルパターンを選別
    tile = [[(PoCoAppController *)([NSApp delegate]) tilePattern] pattern:[info tileNumber]];  

    // 描画パターンを選別
    if (([info eraserType]) && ([doc eraser] != nil)) {
        // 以前の画像を使用(alloc はしないので retain しておく)
        pat = [doc eraser];
        [pat retain];
    } else if (([[info selColor] isUnder]) && ([[doc selLayer] sel] > 0)) {
        // 背面レイヤーを使用
        behind = [[[[doc picture] layer:([[doc selLayer] sel] - 1)] bitmap] getBitmap:self->resultRect_];
        pat = [[PoCoColorPattern alloc] initWithBitmap:behind]; 
        [behind release];
        behind = nil;
    } else if ([[info selColor] isPattern]) {
        // カラーパターンを使用(alloc はしないので retain しておく)
        pat = [[doc picture] colpat:[[info selColor] num]];
        [pat retain];
    } else {
        // 通常の色を使用
        pat = [[PoCoColorPattern alloc] initWidth:1
                                       initHeight:1
                                     defaultColor:[[info selColor] num]];
    }

    // 編集実行
    if ([info penStyleType] == PoCoPenStyleType_Normal) {
        // 通常
        self->resultImage_ = [[PoCoBitmap alloc]
                                     initWidth:([self->resultRect_ width] + 1)
                                    initHeight:([self->resultRect_ height] + 1)
                                  defaultColor:0];
        ep = [[PoCoPoint alloc] init];
        sp = [[PoCoPoint alloc] initX:[self->resultImage_ width]
                                initY:[self->resultImage_ height]];
        edit = [[PoCoEditRegionFill alloc]
                   initWithPattern:self->resultImage_
                           palette:[[doc picture] palette]
                              tile:tile
                           pattern:pat
                         checkDist:NO];
        [edit executeDraw:self->resultShape_
             withStartPos:sp
               withEndPos:ep];
        [edit release];
        [ep release];
        [sp release];
    } else {
        self->resultImage_ = [self->originalImage_ copy];
        shape = [self->resultShape_ copy];
        r = [[PoCoRect alloc] initLeft:0
                               initTop:0
                             initRight:[self->resultImage_ width]
                            initBottom:[self->resultImage_ height]];
        switch ([info penStyleType]) {
            case PoCoPenStyleType_Normal:
            default:
                // 通常
                ;
                break;
            case PoCoPenStyleType_UniformedDensity:
            case PoCoPenStyleType_Density:
                // 単一濃度
                // 濃度
                edit = [[PoCoEditUniformedDensityFill alloc]
                              init:self->resultImage_
                           colMode:[info colorMode]
                           palette:[[doc picture] palette]
                           pattern:pat
                            buffer:[doc colorBuffer]
                           density:[info density]];
                break;
            case PoCoPenStyleType_Atomizer:
                // 霧吹き
                ratio = [info density];
                if (ratio < 250) {
                    ratio /= 75;
                } else if (ratio < 750) {
                    ratio /= 2;
                    ratio /= 50;
                } else if (ratio < 1000) {
                    ratio /= 5;
                    ratio /= 25;
                }
                if (ratio > 0) {
                    edit = [[PoCoEditAtomizerFill alloc]
                                  init:self->resultImage_
                               palette:[[doc picture] palette]
                               pattern:pat
                                 ratio:ratio];
                }
                break;
            case PoCoPenStyleType_Gradation:
                // グラデーション
                ratio = [info density];
                if (ratio < 250) {
                    ratio /= 75;
                } else if (ratio < 750) {
                    ratio /= 50;
                } else if (ratio < 1000) {
                    ratio /= 25;
                }
                if (ratio > 0) {
                    edit = [[PoCoEditGradationFill alloc]
                                  init:self->resultImage_
                               colMode:[info colorMode]
                               palette:[[doc picture] palette]
                               pattern:pat
                                buffer:[doc colorBuffer]
                                 ratio:ratio];
                    [edit replaceDensity:(1000 / ([info penSize] + 7))
                              withBitmap:self->resultImage_];
                }
                break;
            case PoCoPenStyleType_Random:
                // 拡散
                edit = [[PoCoEditRandomFill alloc]
                              init:self->resultImage_
                           palette:[[doc picture] palette]
                             ratio:[info density]
                             range:([info penSize] * 8)];
                break;
            case PoCoPenStyleType_WaterDrop:
                // ぼかし
                edit = [[PoCoEditWaterDropFill alloc]
                              init:self->resultImage_
                           colMode:[info colorMode]
                           palette:[[doc picture] palette]
                            buffer:[doc colorBuffer]];
                break;
        }
        [edit executeDraw:shape
                 withTile:tile
             withTrueRect:r
             withDrawRect:r];
        [edit release];
        [shape release];
        [r release];
    }

    // 描画パターンを解放
    [pat release];

    // 結果を複写
    [self copyResultToOriginal];
    [self->originalImage_ release];
    self->originalImage_ = [self->resultImage_ copy];

EXIT:
    return;
}
#endif  // 0


//
// 反転
//
//  Call
//    hori           : 水平か
//                     YES : 水平に画像反転
//                     NO  : 垂直に画像反転
//    originalShape_ : 形状(変形前)(instance 変数)
//    originalImage_ : 画像(変形前)(instance 変数)
//
//  Return
//    resultShape_ : 形状(変形後)(instance 変数)
//    resultImage_ : 画像(変形後)(instance 変数)
//
-(void)flip:(BOOL)hori
{
    if (hori) {
        // 水平反転
        [self flipHori];
        [self createFlipHoriBitmap:self->originalShape_
                      targetBitmap:&(self->resultShape_)];
        [self createFlipHoriBitmap:self->originalImage_
                      targetBitmap:&(self->resultImage_)];
    } else {
        // 垂直反転
        [self flipVert];
        [self createFlipVertBitmap:self->originalShape_
                      targetBitmap:&(self->resultShape_)];
        [self createFlipVertBitmap:self->originalImage_
                      targetBitmap:&(self->resultImage_)];
    }

    // 結果を複写
    [self copyResultToOriginal];
    [self->originalImage_ release];
    self->originalImage_ = [self->resultImage_ copy];

    return;
}


//
// 自動グラデーション
//
//  Call
//    doc            : document
//    size           : 大きさ(0: 任意、1-128 の範囲)
//    adj            : 隣接(YES: 隣り合う色番号のみ)
//    mtx            : 対象色配列(256 固定長、YES: 対象)
//    originalImage_ : 画像(変形前)(instance 変数)
//    originalShape_ : 形状(変形前)(instance 変数)
//    resultRect_    : 外接長方形(変形後)(instance 変数)
//
//  Return
//    originalImage_ : 画像(変形前)(instance 変数)
//    resultImage_   : 画像(変形後)(instance 変数)
//
-(void)autoGrad:(MyDocument *)doc
        penSize:(int)size
     isAdjacent:(BOOL)adj
         matrix:(const BOOL *)mtx
   withSizePair:(NSDictionary *)sizePair
{
    id edit;

    edit = nil;

    // 以前の結果を忘れる
    [self->resultImage_ release];
    self->resultImage_ = nil;

    // 範囲選択状態なら描画
    if (!([self->resultRect_ empty])) {
        // 編集実行
        self->resultImage_ = [[PoCoBitmap alloc]
                                     initWidth:([self->resultRect_ width] + 1)
                                    initHeight:([self->resultRect_ height] + 1)
                                  defaultColor:0];
        if (adj) {
            // 隣接
            edit = [[PoCoEditAutoGradationAdjacent alloc]
                       initDst:self->resultImage_
                       withSrc:self->originalImage_
                      withMask:self->originalShape_
                       palette:[[doc picture] palette]
                       penSize:size
                        matrix:mtx
                          rect:self->resultRect_
                  withSizePair:sizePair];
        } else {
            // 任意
            edit = [[PoCoEditAutoGradation alloc]
                       initDst:self->resultImage_
                       withSrc:self->originalImage_
                      withMask:self->originalShape_
                       palette:[[doc picture] palette]
                       penSize:size
                        matrix:mtx
                          rect:self->resultRect_];
        }
        [edit executeDraw];
        [edit release];

        // 結果を複写
        [self copyResultToOriginal];
        [self->originalImage_ release];
        self->originalImage_ = [self->resultImage_ copy];
    }

    return;
}


//
// 色置換
//
//  Call
//    doc            : document
//    mtx            : 置換表(256 固定長)
//    originalImage_ : 画像(変形前)(instance 変数)
//    originalShape_ : 形状(変形前)(instance 変数)
//    resultRect_    : 外接長方形(変形後)(instance 変数)
//
//  Return
//    originalImage_ : 画像(変形前)(instance 変数)
//    resultImage_   : 画像(変形後)(instance 変数)
//
-(void)colorReplace:(MyDocument *)doc
             matrix:(const unsigned char *)mtx
{
    PoCoEditBitmapColorReplace *edit;

    edit = nil;

    // 以前の結果を忘れる
    [self->resultImage_ release];
    self->resultImage_ = nil;

    // 範囲選択状態なら描画
    if (!([self->resultRect_ empty])) {
        // 編集実行
        self->resultImage_ = [[PoCoBitmap alloc]
                                     initWidth:([self->resultRect_ width] + 1)
                                    initHeight:([self->resultRect_ height] + 1)
                                  defaultColor:0];
        edit = [[PoCoEditBitmapColorReplace alloc]
                   initTargetBitmap:self->resultImage_
                   withSourceBitmap:self->originalImage_
                           withMask:self->originalShape_
                         withMatrix:mtx];
        [edit execute];
        [edit release];

        // 結果を複写
        [self copyResultToOriginal];
        [self->originalImage_ release];
        self->originalImage_ = [self->resultImage_ copy];
    }

    return;
}


//
// テクスチャ
//
//  Call
//    doc           : document
//    info          : 編集情報
//    base          : 基本色(NSArray<unsigned int>)
//    grad          : 濃淡対(NSArray<unsinged int, NSArray<unsigned int> >)
//    resultPoints_ : 支点座標群(変形後)(instance 変数)
//    resultRect_   : 外接長方形(変形後)(instance 変数)
//    resultShape_  : 形状(変形後)(instance 変数)
//
//  Return
//    originalImage_ : 画像(変形前)(instance 変数)
//    resultImage_   : 画像(変形後)(instance 変数)
//
-(void)texture:(MyDocument *)doc
  withEditInfo:(PoCoEditInfo *)info
    baseColors:(NSArray *)base
gradientColors:(NSArray *)grad
{
    PoCoPalette *pal;
    PoCoEditRegionFill *fill;
    PoCoEditBitmapColorReplace *rep;
    PoCoMonochromePattern *tile;
    PoCoBitmap *behind;
    PoCoColorPattern *pat;
    PoCoPoint *sp;
    PoCoPoint *ep;
    NSEnumerator *iter;
    PoCoBaseGradientPair *pair;
    NSNumber *bnum;
    NSNumber *gnum;
    PoCoBaseGradientPair *bpair;
    int idx;
    unsigned char mtx[COLOR_MAX];
    BOOL mask[COLOR_MAX];
    BOOL drop[COLOR_MAX];

    fill = nil;
    rep = nil;
    tile = nil;
    pat = nil;
    behind = nil;
    sp = nil;
    ep = nil;
    pal = [[doc picture] palette];
    bpair = nil;

    // 選択範囲無しでは何もできない
    if ([self->resultRect_ empty]) {
        goto EXIT;
    }

    // パレット属性を退避
    for (idx = 0; idx < COLOR_MAX; (idx)++) {
        mask[idx] = [[pal palette:idx] isMask];
        drop[idx] = [[pal palette:idx] noDropper];
    }

    // 使用タイルパターンを選別
    tile = [[(PoCoAppController *)([NSApp delegate]) tilePattern] pattern:[info tileNumber]];  

    // 背面レイヤーを使用
    behind = [[[[doc picture] layer:([[doc selLayer] sel] - 1)] bitmap] getBitmap:self->resultRect_];
    pat = [[PoCoColorPattern alloc] initWithBitmap:behind]; 
    [behind release];
    behind = nil;

    // 編集範囲
    ep = [[PoCoPoint alloc] init];
    sp = [[PoCoPoint alloc] initX:[self->resultImage_ width]
                            initY:[self->resultImage_ height]];

    // 濃淡の反復動作
    iter = [grad objectEnumerator];
    for (pair = [iter nextObject]; pair != nil; pair = [iter nextObject]) {
        // 反復動作の途中では基本色に対しては何もしない
        for (idx = 0; idx < [base count]; (idx)++) {
            bnum = (NSNumber *)([base objectAtIndex:idx]);
            gnum = (NSNumber *)([[pair colors] objectAtIndex:0]);
            if ([bnum intValue] == [gnum intValue]) {
                bpair = pair;
                goto NEXT;
            }
        }

        // 濃淡側で上塗り禁止なので何もしない
        if (mask[[pair base]]) {
            goto NEXT;
        }

        // パレット属性切り替え
        for (idx = 0; idx < COLOR_MAX; (idx)++) {
            [[pal palette:idx] setMask:YES];
            [[pal palette:idx] setDropper:YES];
        }
        for (idx = 0; idx < [base count]; (idx)++) {
            bnum = (NSNumber *)([base objectAtIndex:idx]);
            gnum = (NSNumber *)([[pair colors] objectAtIndex:idx]);
            if (drop[[bnum intValue]]) {
                // テクスチャ側で吸い取り禁止
                ;
            } else if (drop[[gnum intValue]]) {
                // 置換先で吸い取り禁止
                ;
            } else {
                // 対象の色を描画可能とする
                [[pal palette:[bnum intValue]] setMask:NO];
                [[pal palette:[bnum intValue]] setDropper:NO];
                [[pal palette:[gnum intValue]] setMask:NO];
                [[pal palette:[gnum intValue]] setDropper:NO];
            }
        }
        [[pal palette:[pair base]] setMask:NO];
        [[pal palette:[pair base]] setDropper:NO];

        // 背面レイヤーを取り出す
        [self->resultImage_ release];   // 結果を忘れる
        self->resultImage_ = [self->originalImage_ copy];
        fill = [[PoCoEditRegionFill alloc]
                   initWithPattern:self->resultImage_
                           palette:pal
                              tile:tile
                           pattern:pat
                         checkDist:YES];
        [fill executeDraw:self->resultShape_
             withStartPos:sp
               withEndPos:ep];
        [fill release];
        [self copyResultToOriginal];    // 取り出した結果を複写
        [self->originalImage_ release];
        self->originalImage_ = [self->resultImage_ copy];

        // 濃淡を反映
        for (idx = 0; idx < COLOR_MAX; (idx)++) {
            mtx[idx] = idx;
        }
        for (idx = 0; idx < [base count]; (idx)++) {
            bnum = (NSNumber *)([base objectAtIndex:idx]);
            gnum = (NSNumber *)([[pair colors] objectAtIndex:idx]);
            mtx[[bnum intValue]] = [gnum intValue];
        }
        [self->resultImage_ release];   // 結果を忘れる
        self->resultImage_ = [self->originalImage_ copy];
        rep = [[PoCoEditBitmapColorReplace alloc]
                   initTargetBitmap:self->resultImage_
                   withSourceBitmap:self->originalImage_
                           withMask:self->originalShape_
                         withMatrix:mtx];
        [rep execute];
        [rep release];
        [self copyResultToOriginal];    // 濃淡の結果を複写
        [self->originalImage_ release];
        self->originalImage_ = [self->resultImage_ copy];

        // 次へ
NEXT:
        ;
    }

    // 最後に基本色を反映
    if ((bpair == nil) ||
        (mask[[bpair base]])) {
        // 基本色が不明、あるいは上塗り禁止
        ;
    } else {
        for (idx = 0; idx < COLOR_MAX; (idx)++) {
            [[pal palette:idx] setMask:YES];
            [[pal palette:idx] setDropper:YES];
        }
        iter = [[bpair colors] objectEnumerator];
        for (gnum = [iter nextObject]; gnum != nil; gnum = [iter nextObject]) {
            if (drop[[gnum intValue]]) {
                // 吸い取り禁止
                ;
            } else {
                // 対象の色を描画可能とする
                [[pal palette:[gnum intValue]] setMask:NO];
                [[pal palette:[gnum intValue]] setDropper:NO];
            }
        }
        [[pal palette:[bpair base]] setMask:NO];
        [[pal palette:[bpair base]] setDropper:NO];

        // 背面レイヤーを取り出す
        [self->resultImage_ release];   // 結果を忘れる
        self->resultImage_ = [self->originalImage_ copy];
        fill = [[PoCoEditRegionFill alloc]
                   initWithPattern:self->resultImage_
                           palette:pal
                              tile:tile
                           pattern:pat
                         checkDist:YES];
        [fill executeDraw:self->resultShape_
             withStartPos:sp
               withEndPos:ep];
        [fill release];
        [self copyResultToOriginal];    // 取り出した結果を複写
        [self->originalImage_ release];
        self->originalImage_ = [self->resultImage_ copy];
    }

    // パレット属性を進出
    for (idx = 0; idx < COLOR_MAX; (idx)++) {
        [[pal palette:idx] setMask:mask[idx]];
        [[pal palette:idx] setDropper:drop[idx]];
    }

EXIT:
    [pat release];
    [ep release];
    [sp release];
    return;
}


// ----------------------------------------------- instance - public - 塗り選択
//
// 新規
//
//  Call
//    p      : 対象点(seed)
//    bmp    : 対象画像
//    border : 境界線指定か
//             YES : 境界線による塗り選択
//             NO  : 指定座標の色による塗り選択
//    range  : 色範囲
//
//  Return
//    originalRect_     : 外接長方形(変形前)(instance 変数)
//    originalHandle_[] : ハンドル(変形前)(instance 変数)
//    originalShape_    : 形状(変形前)(instance 変数)
//
-(void)seedNew:(PoCoPoint *)p
        bitmap:(PoCoBitmap *)bmp
      isBorder:(BOOL)border
    colorRange:(int)range
{
    PoCoCreateStyleMask *mask;
    PoCoRect *tr;

    // 画像全体の枠を生成
    tr = [[PoCoRect alloc] initLeft:0
                            initTop:0
                          initRight:[bmp width]
                         initBottom:[bmp height]];

    // 形状マスクを生成
    mask = [[PoCoCreateStyleMask alloc] init];
    if ([mask paint:p
        imageBitmap:bmp
          imageRect:tr
           isBorder:border
         colorRange:range
         resultRect:self->originalRect_]) {
        [self->originalShape_ release];
        self->originalShape_ = [[mask mask] copy];
    }
    [mask release];

    // ハンドルを設定
    [PoCoSelectionShape createHandleRect:self->originalRect_
                           targetHandles:(PoCoRect **)(&(self->originalHandle_))];

    // 画像全体の枠を解放
    [tr release];

    // 変形前の形状を変形後の形状に複写
    [self copyOriginalToResult];

    return;
}


//
// 結合
//
//  Call
//    p              : 対象点(seed)
//    bmp            : 対象画像
//    border         : 境界線指定か
//                     YES : 境界線による塗り選択
//                     NO  : 指定座標の色による塗り選択
//    range          : 色範囲
//    originalRect_  : 外接長方形(変形前)(instance 変数)
//    originalShape_ : 形状(変形前)(instance 変数)
//    resultRect_    : 外接長方形(変形後)(instance 変数)
//
//  Return
//    originalRect_     : 外接長方形(変形前)(instance 変数)
//    originalHandle_[] : ハンドル(変形前)(instance 変数)
//    originalShape_    : 形状(変形前)(instance 変数)
//
-(void)seedJoin:(PoCoPoint *)p
         bitmap:(PoCoBitmap *)bmp
       isBorder:(BOOL)border
     colorRange:(int)range
{
    PoCoCreateStyleMask *mask;
    PoCoRect *tr;

    // 画像全体の枠を生成
    tr = [[PoCoRect alloc] initLeft:0
                            initTop:0
                          initRight:[bmp width]
                         initBottom:[bmp height]];

    // 形状マスクを生成
    mask = [[PoCoCreateStyleMask alloc] init];
    if ([mask paintJoin:p
            imageBitmap:bmp
              imageRect:tr
            styleBitmap:self->originalShape_
              styleRect:self->resultRect_
               isBorder:border
             colorRange:range
             resultRect:self->originalRect_]) {
        [self->originalShape_ release];
        self->originalShape_ = [[mask mask] copy];
    }
    [mask release];

    // ハンドルを設定
    [PoCoSelectionShape createHandleRect:self->originalRect_
                           targetHandles:(PoCoRect **)(&(self->originalHandle_))];

    // 画像全体の枠を解放
    [tr release];

    // 変形前の形状を変形後の形状に複写
    [self copyOriginalToResult];

    return;
}


//
// 分離
//
//  Call
//    p              : 対象点(seed)
//    bmp            : 対象画像
//    border         : 境界線指定か
//                     YES : 境界線による塗り選択
//                     NO  : 指定座標の色による塗り選択
//    range          : 色範囲
//    originalRect_  : 外接長方形(変形前)(instance 変数)
//    originalShape_ : 形状(変形前)(instance 変数)
//    resultRect_    : 外接長方形(変形後)(instance 変数)
//
//  Return
//    originalRect_     : 外接長方形(変形前)(instance 変数)
//    originalHandle_[] : ハンドル(変形前)(instance 変数)
//    originalShape_    : 形状(変形前)(instance 変数)
//
-(void)seedSeparate:(PoCoPoint *)p
             bitmap:(PoCoBitmap *)bmp
           isBorder:(BOOL)border
         colorRange:(int)range
{
    PoCoCreateStyleMask *mask;
    PoCoRect *tr;

    // 選択範囲内なら実行
    if ([PoCoSelectionShape hitTest:p
                           withRect:self->originalRect_
                          withShape:self->originalShape_] == PoCoHandleType_in_shape) {
        // 画像全体の枠を生成
        tr = [[PoCoRect alloc] initLeft:0
                                initTop:0
                              initRight:[bmp width]
                             initBottom:[bmp height]];

        // 形状マスクを生成
        mask = [[PoCoCreateStyleMask alloc] init];
        if ([mask paintSeparate:p
                    imageBitmap:bmp
                      imageRect:tr
                    styleBitmap:self->originalShape_
                      styleRect:self->resultRect_
                       isBorder:border
                     colorRange:range
                     resultRect:self->originalRect_]) {
            [self->originalShape_ release];
            self->originalShape_ = [[mask mask] copy];
        }
        [mask release];

        // ハンドルを設定
        [PoCoSelectionShape createHandleRect:self->originalRect_
                               targetHandles:(PoCoRect **)(&(self->originalHandle_))];

        // 画像全体の枠を解放
        [tr release];

        // 変形前の形状を変形後の形状に複写
        [self copyOriginalToResult];
    }

    return;
}

@end
