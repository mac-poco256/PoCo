//
//	Pelistina on Cocoa - PoCo -
//	線/枠線系描画部基底
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoControllerFrameEditterBase.h"

#import "PoCoCalcRotation.h"
#import "PoCoCalcEllipse.h"
#import "PoCoCalcCurveWithPoints.h"

#import "PoCoEditNormalDrawPoint.h" 
#import "PoCoEditNormalDrawLine.h"
#import "PoCoEditUniformedDensityDrawLineBase.h"
#import "PoCoEditDensityDrawLineBase.h"
#import "PoCoEditAtomizerDrawLine.h"
#import "PoCoEditGradationDrawLine.h"
#import "PoCoEditRandomDrawLine.h"

// ============================================================================
@implementation PoCoControllerLineEditterBase

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict   : 編集対象画像
//    info   : 編集情報
//    undo   : 取り消し情報
//    eraser : 消しゴム用画像
//    buf    : 色保持情報
//    pen    : ペン先
//    tile   : タイルパターン
//    s      : 描画始点(中心点)
//    e      : 描画終点(中心点)
//    prop   : 筆圧比例
//    idx    : 対象レイヤー番号
//
//  Return
//    function  : 実体
//    startPos_ : 描画始点(中心点)(instance 変数)
//    endPos_   : 描画終点(中心点)(instance 変数)
//    prop_     : 筆圧比例(instance 変数)
//    cont_     : 常に連続線分(instance 変数)
//
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
      withPen:(PoCoPenStyle *)pen
     withTile:(PoCoTilePattern *)tile
    withStart:(PoCoPoint *)s
      withEnd:(PoCoPoint *)e
       isProp:(BOOL)prop
      atIndex:(int)idx
{
//    DPRINT((@"[PoCoControllerLineEditterBase init]\n"));

    // super class を初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:buf
                   withPen:pen
                  withTile:tile
                   atIndex:idx];

    // 自身を初期化
    if (self != nil) {
        self->prop_ = prop;
        self->cont_ = NO;

        // 点を複製
        self->startPos_ = [[PoCoPoint alloc] initX:[s x] initY:[s y]];
        self->endPos_   = [[PoCoPoint alloc] initX:[e x] initY:[e y]];
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
//    startPos_ : 描画始点(中心点)(instance 変数)
//    endPos_   : 描画終点(中心点)(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerLineEditterBase dealloc]\n"));

    // 資源を解放
    [self->startPos_ release];
    [self->endPos_ release];
    self->startPos_ = nil;
    self->endPos_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// ペン太さを選別
//
//  Call
//    editInfo_ : 編集情報(基底 instance 変数)
//    prop_     : 筆圧比例(instance 変数)
//
//  Return
//    function : 太さ(1-16)
//
-(int)selectPenSize
{
    int press;

    // 筆圧を取得
    if ((self->prop_) &&
        ([self->editInfo_ sizePropType] == PoCoProportionalType_Relation)) {
        press = [self->editInfo_ pressure];
    } else {
        press = 1000;
    }

    // 設定を上限に値算出
    return MIN(
        [self->editInfo_ penSize],
        (([self->editInfo_ penSize] * press) / 1000)
    );
}


//
// 濃度を選別
//
//  Call
//    editInfo_ : 編集情報(基底 instance 変数)
//    prop_     : 筆圧比例(instance 変数)
//
//  Return
//    function : 濃度(0.1%単位)
//
-(int)selectDensity
{
    int press;

    if ((self->prop_) &&
        ([self->editInfo_ densityPropType] == PoCoProportionalType_Relation)) {
        press = [self->editInfo_ pressure];
    } else {
        press = 1000;
    }

    // 設定を上限に値算出
    return MIN(
        [self->editInfo_ density],
        (([self->editInfo_ density] * press) / 1000)
    );
}


//
// 描画予定領域の算出
//
//  Call
//    corr      : 補正量
//    picture_  : 編集対象画像(基底 instance 変数)
//    startPos_ : 描画始点(中心点)(instance 変数)
//    endPos_   : 描画終点(中心点)(instance 変数)
//
//  Return
//    function : 領域
//
-(PoCoRect *)calcArea:(int)corr
{
    PoCoRect *r;

    r = [[PoCoRect alloc] init];

    // 水平軸の算出
    if ([self->startPos_ x] < [self->endPos_ x]) {
        [r setLeft:([self->startPos_ x] - corr)];
        [r setRight:(([self->endPos_ x] + corr) + 1)];
    } else {
        [r setLeft:([self->endPos_ x] - corr)];
        [r setRight:(([self->startPos_ x] + corr) + 1)];
    }

    // 垂直軸の算出
    if ([self->startPos_ y] < [self->endPos_ y]) {
        [r setTop:([self->startPos_ y] - corr)];
        [r setBottom:(([self->endPos_ y] + corr) + 1)];
    } else {
        [r setTop:([self->endPos_ y] - corr)];
        [r setBottom:(([self->startPos_ y] + corr) + 1)];
    }

    return r;
}


//
// 編集開始
//
//  Call
//    dc : 再描画領域の補正量
//    uc : 取り消し領域の補正量
//
//  Return
//    function : 可否
//
-(BOOL)startEdit:(int)dc
    withUndoCorr:(int)uc
{
    BOOL result;
    PoCoRect *dr;
    PoCoRect *ur;

    // 範囲を生成
    dr = [self calcArea:dc];
    ur = [self calcArea:uc];
    [super correctRect:dr];
    [super correctRect:ur];

    // super class へ回送
    result = [super startEdit:dr
                 withUndoRect:ur];

    // 範囲を解放
    [dr release];
    [ur release];

    return result;
}


//
// 連続線分
//
//  Call
//    None
//
//  Return
//    cont_ : 常に連続線分(instance 変数)
//
-(void)setCont
{
    self->cont_ = YES;

    return;
}


//
// 直線の描画
//
//  Call
//    edit      : 編集系
//    editInfo_ : 編集情報(基底 instance 変数)
//    startPos_ : 描画始点(中心点)(instance 変数)
//    endPos_   : 描画終点(中心点)(instance 変数)
//    cont_     : 常に連続線分(instance 変数)
//
//  Return
//    None
//
-(void)drawFrame:(id)edit
{
    if ((self->cont_) ||
        (([self->editInfo_ continuationType]) &&
         (![self->startPos_ isEqualPos:self->endPos_]))) {
        // 連続線分
        [edit addPoint:self->startPos_];
        [edit addPoint:self->endPos_];
        [edit executeDraw];
    } else {
        // 非連続線分
        [edit addPoint:self->startPos_];
        [edit addPoint:self->startPos_];
        [edit executeDraw];
        if (!([self->startPos_ isEqualPos:self->endPos_])) {
            [edit clearPoint];
            [edit addPoint:self->endPos_];
            [edit addPoint:self->endPos_];
            [edit executeDraw];
        }
    }

    return;
}


//
// 編集終了
//
//  Call
//    name : 取り消し名称文字列
//
//  Return
//    None
//
-(void)endEdit:(NSString *)name
{
    // super class へ回送
    [super endEdit:name];

    return;
}

@end




// ============================================================================
@implementation PoCoControllerBoxFrameEditterBase

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict   : 編集対象画像
//    info   : 編集情報
//    undo   : 取り消し情報
//    eraser : 消しゴム用画像
//    buf    : 色保持情報
//    pen    : ペン先
//    tile   : タイルパターン
//    s      : 描画始点(中心点)
//    e      : 描画終点(中心点)
//    o      : 方向点
//    idx    : 対象レイヤー番号
//
//  Return
//    function : 実体
//    cont_    : 常に連続線分(instance 変数)
//
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
      withPen:(PoCoPenStyle *)pen
     withTile:(PoCoTilePattern *)tile
    withStart:(PoCoPoint *)s
      withEnd:(PoCoPoint *)e
  ifAnyOrient:(PoCoPoint *)o
      atIndex:(int)idx
{
//    DPRINT((@"[PoCoControllerBoxFrameEditterBase init]\n"));

    // super class を初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:buf
                   withPen:pen
                  withTile:tile
                 withStart:s
                   withEnd:e
               ifAnyOrient:o
                   atIndex:idx];

    // 自身を初期化
    if (self != nil) {
        self->cont_ = NO;
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
//    None
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerBoxFrameEditterBase dealloc]\n"));

    // 資源を解放
    ;

    // super class を解放
    [super dealloc];

    return;
}


//
// 連続線分
//
//  Call
//    None
//
//  Return
//    cont_ : 常に連続線分(instance 変数)
//
-(void)setCont
{
    self->cont_ = YES;

    return;
}


//
// 矩形枠の描画
//
//  Call
//    edit      : 編集系
//    editInfo_ : 編集情報(基底 instance 変数)
//    startPos_ : 描画始点(中心点)(基底 instance 変数)
//    endPos_   : 描画終点(中心点)(基底 instance 変数)
//    ortPos_   : 方向点(基底 instance 変数)
//    diagonal_ : 回転で対角を使用(基底 instance 変数)
//    cont_     : 常に連続線分(instance 変数)
//
//  Return
//    None
//
-(void)drawFrame:(id)edit
{
    PoCoCalcRotationForBox *rot;

    rot = nil;

    // 回転座標を算出
    rot = [[PoCoCalcRotationForBox alloc] initWithStartPos:self->startPos_
                                                withEndPos:self->endPos_
                                               ifAnyOrient:self->ortPos_];
    [rot calc:self->diagonal_];
    if ((self->cont_) ||
        (([self->editInfo_ continuationType]) &&
         (![self->startPos_ isEqualPos:self->endPos_]))) {
        // 連続線分
        [edit addPoint:[rot leftTop]];
        [edit addPoint:[rot leftBottom]];
        [edit addPoint:[rot rightBottom]];
        [edit addPoint:[rot rightTop]];
        [edit addPoint:[rot leftTop]];
        [edit executeDraw];
    } else {
        // 非連続線分
        [edit addPoint:[rot leftTop]];
        [edit addPoint:[rot leftTop]];
        [edit executeDraw];
        if (!([self->startPos_ isEqualPos:self->endPos_])) {
            [edit clearPoint];
            [edit addPoint:[rot leftBottom]];
            [edit addPoint:[rot leftBottom]];
            [edit executeDraw];

            [edit clearPoint];
            [edit addPoint:[rot rightBottom]];
            [edit addPoint:[rot rightBottom]];
            [edit executeDraw];

            [edit clearPoint];
            [edit addPoint:[rot rightTop]];
            [edit addPoint:[rot rightTop]];
            [edit executeDraw];
        }
    }
    [rot release];

    return;
}

@end




// ============================================================================
@implementation PoCoControllerEllipseFrameEditterBase

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict   : 編集対象画像
//    info   : 編集情報
//    undo   : 取り消し情報
//    eraser : 消しゴム用画像
//    buf    : 色保持情報
//    pen    : ペン先
//    tile   : タイルパターン
//    s      : 描画始点(中心点)
//    e      : 描画終点(中心点)
//    o      : 方向点
//    idx    : 対象レイヤー番号
//
//  Return
//    function : 実体
//
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
      withPen:(PoCoPenStyle *)pen
     withTile:(PoCoTilePattern *)tile
    withStart:(PoCoPoint *)s
      withEnd:(PoCoPoint *)e
  ifAnyOrient:(PoCoPoint *)o
      atIndex:(int)idx
{
//    DPRINT((@"[PoCoControllerEllipseFrameEditterBase init]\n"));

    // super class を初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:buf
                   withPen:pen
                  withTile:tile
                 withStart:s
                   withEnd:e
               ifAnyOrient:o
                   atIndex:idx];

    // 自身を初期化
    if (self != nil) {
        ;
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
//    None
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerEllipseFrameEditterBase dealloc]\n"));

    // 資源を解放
    ;

    // super class を解放
    [super dealloc];

    return;
}


//
// 連続線分
//
//  Call
//    None
//
//  Return
//    None
//
-(void)setCont
{
    // ellipse では区別しない
    ;

    return;
}


//
// 円/楕円枠の描画
//
//  Call
//    edit      : 編集系
//    startPos_ : 描画始点(中心点)(基底 instance 変数)
//    endPos_   : 描画終点(中心点)(基底 instance 変数)
//    ortPos_   : 方向点(基底 instance 変数)
//
//  Return
//    None
//
-(void)drawFrame:(id)edit
{
    PoCoCalcEllipse *calc;              // 楕円関数
    PoCoPoint *p;

    // 点の算出
    calc = [[PoCoCalcEllipse alloc] init];
    [calc calc:self->startPos_
        endPos:self->endPos_
   orientation:self->ortPos_];

    // 点を取得
    for (p = [calc points]; p != nil; p = [calc points]) {
        [edit addPoint:p];
    }
 
    // 描画
    [edit executeDraw];
    [calc release];

    return;
}

@end




// ============================================================================
@implementation PoCoControllerParallelogramFrameEditterBase

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict   : 編集対象画像
//    info   : 編集情報
//    undo   : 取り消し情報
//    eraser : 消しゴム用画像
//    buf    : 色保持情報
//    pen    : ペン先
//    tile   : タイルパターン
//    f      : 1点(中心点)
//    s      : 2点(中心点)
//    t      : 3点(中心点)
//    idx    : 対象レイヤー番号
//
//  Return
//    function : 実体
//    cont_    : 常に連続線分(instance 変数)
//
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
      withPen:(PoCoPenStyle *)pen
     withTile:(PoCoTilePattern *)tile
    withFirst:(PoCoPoint *)f
   withSecond:(PoCoPoint *)s
    withThird:(PoCoPoint *)t
      atIndex:(int)idx
{
//    DPRINT((@"[PoCoControllerParallelogramFrameEditterBase init]\n"));

    // super class を初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:buf
                   withPen:pen
                  withTile:tile
                 withFirst:f
                withSecond:s
                 withThird:t
                   atIndex:idx];

    // 自身を初期化
    if (self != nil) {
        self->cont_ = NO;
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
//    None
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerParallelogramFrameEditterBase dealloc]\n"));

    // 資源を解放
    ;

    // super class を解放
    [super dealloc];

    return;
}


//
// 連続線分
//
//  Call
//    None
//
//  Return
//    cont_ : 常に連続線分(instance 変数)
//
-(void)setCont
{
    self->cont_ = YES;

    return;
}


//
// 平行四辺形枠の描画
//
//  Call
//    edit       : 編集系
//    editInfo_  : 編集情報(基底 instance 変数)
//    firstPos_  : 1点(中心点)(基底 instance 変数)
//    secondPos_ : 2点(中心点)(基底 instance 変数)
//    thirdPos_  : 3点(中心点)(基底 instance 変数)
//    fourthPos_ : 4点(中心点)(基底 instance 変数)
//    cont_      : 常に連続線分(instance 変数)
//
//  Return
//    None
//
-(void)drawFrame:(id)edit
{
    if ((self->cont_) ||
        ([self->editInfo_ continuationType])) {
        // 連続線分
        [edit addPoint:self->firstPos_];
        [edit addPoint:self->secondPos_];
        [edit addPoint:self->thirdPos_];
        [edit addPoint:self->fourthPos_];
        [edit addPoint:self->firstPos_];
        [edit executeDraw];
    } else {
        // 非連続線分
        [edit addPoint:self->firstPos_];
        [edit addPoint:self->firstPos_];
        [edit executeDraw];
        [edit clearPoint];
        [edit addPoint:self->secondPos_];
        [edit addPoint:self->secondPos_];
        [edit executeDraw];
        [edit clearPoint];
        [edit addPoint:self->thirdPos_];
        [edit addPoint:self->thirdPos_];
        [edit executeDraw];
        [edit clearPoint];
        [edit addPoint:self->fourthPos_];
        [edit addPoint:self->fourthPos_];
        [edit executeDraw];
    }

    return;
}

@end




// ============================================================================
@implementation PoCoControllerCurveWithPointsEditterBase

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict   : 編集対象画像
//    info   : 編集情報
//    undo   : 取り消し情報
//    eraser : 消しゴム用画像
//    buf    : 色保持情報
//    pen    : ペン先
//    tile   : タイルパターン
//    points : 支点群
//    type   : 補間方法
//    freq   : 補間頻度
//    idx    : 対象レイヤー番号
//
//  Return
//    function : 実体
//    cont_    : 常に連続線分(instance 変数)
//
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
      withPen:(PoCoPenStyle *)pen
     withTile:(PoCoTilePattern *)tile
   withPoints:(NSMutableArray *)points
     withType:(PoCoCurveWithPointsType)type
     withFreq:(unsigned int)freq
      atIndex:(int)idx
{
//    DPRINT((@"[PoCoControllerCurveWithPointsEditterBase init]\n"));

    // super class を初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:buf
                   withPen:pen
                  withTile:tile
                withPoints:points
                  withType:type
                  withFreq:freq
                   atIndex:idx];

    // 自身を初期化
    if (self != nil) {
        self->cont_ = NO;
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
//    None
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerCurveWithPointsEditterBase dealloc]\n"));

    // 資源を解放
    ;

    // super class を解放
    [super dealloc];

    return;
}


//
// 連続線分
//
//  Call
//    None
//
//  Return
//    cont_ : 常に連続線分(instance 変数)
//
-(void)setCont
{
    self->cont_ = YES;

    return;
}


//
// 直線群(曲線)の描画 
//
//  Call
//    edit       : 編集系
//    editInfo_  : 編集情報(基底 instance 変数)
//    points_    : 支点群(基底 instance 変数)
//    type_      : 補間方法(基底 instance 変数)
//    freq_      : 補間頻度(基底 instance 変数)
//    cont_      : 常に連続線分(instance 変数)
//
//  Return
//    None
//
-(void)drawFrame:(id)edit
{
    PoCoCalcCurveWithPointsBase *calc;
    NSEnumerator *iter;
    PoCoPoint *p;
    BOOL doing;

    // 補間演算を実施
    switch (self->type_) {
        default:
        case PoCoCurveWithPoints_Lagrange:
            calc = [[PoCoCalcLagrange alloc] initWithPoints:self->points_];
            break;
        case PoCoCurveWithPoints_Spline:
            calc = [[PoCoCalcSpline alloc] initWithPoints:self->points_];
            break;
    }
    iter = [[calc exec:self->freq_] objectEnumerator];

    // 点を取得
    if ((self->cont_) ||
        ([self->editInfo_ continuationType])) {
        // 連続線分
        for (p = [iter nextObject]; p != nil; p = [iter nextObject]) {
           [edit addPoint:p];
        }

        // 描画
        [edit executeDraw];
    } else {
        // 非連続線分
        doing = NO;
        for (p = [iter nextObject]; p != nil; p = [iter nextObject]) {
           [edit addPoint:p];
           if (doing) {
               [edit executeDraw];
               [edit clearPoint];
               doing = NO;
           } else {
               doing = YES;
           }
        }
    }
    [calc release];

    return;
}

@end
