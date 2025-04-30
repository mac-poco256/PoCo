//
//	Pelistina on Cocoa - PoCo -
//	補間曲線
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoCalcCurveWithPoints.h"

// ============================================================================
@implementation PoCoCalcCurveWithPointsBase

// --------------------------------------------------------- instance - private
//
// 点を追加(結果)
//
//  Call
//    x : X
//    y : Y
//
//  Return
//    result_ : 算出した点(instance 変数)
//
-(void)addPointToResult:(int)x
                  withY:(int)y
{
    PoCoPoint *pt;

    pt = [[PoCoPoint alloc] initX:x
                            initY:y];
    [self->result_ addObject:pt];
    [pt release];

    return;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function : 実体
//
-(id)init
{
    // 指定イニシャライザへ転送
    return [self initWithPoints:nil];
}


//
// 初期化(指定イニシャライザ)
//
//  Call
//    points : 指定の点
//
//  Return
//    function : 実体
//    source_  : 指定の点(instance 変数)
//    result_  : 算出した点(instance 変数)
//
-(id)initWithPoints:(NSMutableArray *)points
{
    // super class へ回送
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        if (points == nil) {
            self->source_ = [[NSMutableArray alloc] init];
        } else {
            self->source_ = points;
            [self->source_ retain];
        }
        self->result_ = [[NSMutableArray alloc] init];
        if ((self->source_ == nil) ||
            (self->result_ == nil)) {
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
//    source_ : 指定の点(instance 変数)
//    result_ : 算出した点(instance 変数)
//
-(void)dealloc
{
    // 資源を解放
    [self->source_ release];
    [self->result_ release];
    self->source_ = nil;
    self->result_ = nil;

    // super class へ回送
    [super dealloc];

    return;
}


//
// 点を追加(支点)
//
//  Call
//    pt : 座標
//
//  Return
//    source_ : 指定の点(instance 変数)
//
-(void)addPointToSource:(PoCoPoint *)pt
{
    PoCoPoint *tmp;

    tmp = [[PoCoPoint alloc] initX:[pt x]
                             initY:[pt y]];
    [self->source_ addObject:tmp];
    [tmp release];

    return;
}


//
// 補間した座標を算出
//
//  Call
//    freq : 頻度
//
//  Return
//    function : 算出した点
//
-(NSArray *)exec:(unsigned int)freq
{
    // 基底では何もしない
    ;

    return self->result_;
}

@end




// ============================================================================
@implementation PoCoCalcLagrange

// --------------------------------------------------------- instance - private
//
// 間の点を算出
//
//  Call
//    t : 勾配
//    x : X 軸(配列)(要素数は3固定)
//    y : Y 軸(配列)(要素数は3固定)
//
//  Return
//    None
//
-(void)interpolate:(double)t
             xAxes:(double *)x
             yAxes:(double *)y
{
    double tx;
    double ty;
    double tt;

    // 点を算出
    tt = 1.0f;
    tx = (x[0] * tt);
    ty = (y[0] * tt);

    tt *= t;
    tx += (x[1] * tt);
    ty += (y[1] * tt);

    tt *= t;
    tx += (x[2] * tt);
    ty += (y[2] * tt);

    // 結果を格納
    [self addPointToResult:(int)(tx + 0.5f)
                     withY:(int)(ty + 0.5f)];

    return;
}


// ---------------------------------------------------------- instance - public
//
// 補間した座標を算出
//
//  Call
//    freq    : 頻度
//    source_ : 指定の点(instance 変数)
//
//  Return
//    function : 算出した点
//
-(NSArray *)exec:(unsigned int)freq
{
    int idx1;
    int idx2;
    int interval;
    double vec_x[3];
    double vec_y[3];
    double ans_x[3];
    double ans_y[3];
    PoCoPoint *pt;

    // 以前の結果は忘れる
    [self->result_ removeAllObjects];

    // 指定の点が3点未満なら補間できない
    if ([self->source_ count] < 3) {
        goto EXIT;
    }

    // 座標を算出
    for (idx1 = 0; idx1 < ([self->source_ count] - 1); (idx1)++) {
        if (idx1 == 0) {
            // 3点を取得
            pt = [self->source_ objectAtIndex:0];
            vec_x[0] = (double)([pt x]);
            vec_y[0] = (double)([pt y]);
            pt = [self->source_ objectAtIndex:1];
            vec_x[1] = (double)([pt x]);
            vec_y[1] = (double)([pt y]);
            pt = [self->source_ objectAtIndex:2];
            vec_x[2] = (double)([pt x]);
            vec_y[2] = (double)([pt y]);

            // X 軸の補間量を算出
            ans_x[0] = vec_x[0];
            ans_x[2] = ((vec_x[2] - (vec_x[1] + vec_x[1]) + ans_x[0]) / (double)(2.0f));
            ans_x[1] = (vec_x[1] - ans_x[0] - ans_x[2]);

            // Y 軸の補間量を算出
            ans_y[0] = vec_y[0];
            ans_y[2] = ((vec_y[2] - (vec_y[1] + vec_y[1]) + ans_y[0]) / (double)(2.0f));
            ans_y[1] = (vec_y[1] - ans_y[0] - ans_y[2]);
        } else {
            // 3点を取得
            pt = [self->source_ objectAtIndex:(idx1 + 0)];
            vec_x[0] = (double)([pt x]);
            vec_y[0] = (double)([pt y]);
            pt = [self->source_ objectAtIndex:(idx1 + 1)];
            vec_x[1] = (double)([pt x]);
            vec_y[1] = (double)([pt y]);
            ;
            vec_x[2] = (ans_x[1] + ans_x[2] + ans_x[2]);
            vec_y[2] = (ans_y[1] + ans_y[2] + ans_y[2]);

            // X 軸の補間量を算出
            ans_x[0] = vec_x[0];
            ans_x[1] = vec_x[2];
            ans_x[2] = (vec_x[1] - ans_x[0] - ans_x[1]);
 
            // Y 軸の補間量を算出
            ans_y[0] = vec_y[0];
            ans_y[1] = vec_y[2];
            ans_y[2] = (vec_y[1] - ans_y[0] - ans_y[1]);
        }

        // 算出する点の数を決定
        interval = ((int)(sqrt(  (vec_x[1] - vec_x[0]) * (vec_x[1] - vec_x[0])
                               + (vec_y[1] - vec_y[0]) * (vec_y[1] - vec_y[0])) + (double)(0.5f)) / freq);

        // 座標を算出
        [self addPointToResult:(int)(ans_x[0] + 0.5f)
                         withY:(int)(ans_y[0] + 0.5f)];
        for(idx2 = 1; idx2 <= interval; (idx2)++) {
            [self interpolate:((double)(idx2) / (double)(interval))
                        xAxes:ans_x
                        yAxes:ans_y];
        }
    }

EXIT:
    return (NSArray *)(self->result_);
}

@end




// ============================================================================
@implementation PoCoCalcSpline

// --------------------------------------------------------- instance - private
//
// 間の点を算出
//
//  Call
//    b : 勾配(配列)(要素数は3固定)
//    x : X 軸(配列)(要素数は3固定)
//    y : Y 軸(配列)(要素数は3固定)
//
//  Return
//    None
//
-(void)interpolate:(double *)b
             xAxes:(double *)x
             yAxes:(double *)y
{
    double sx;
    double sy;

    // 点を算出
    sx  = (x[0] * b[0]);
    sy  = (y[0] * b[0]);
    sx += (x[1] * b[1]);
    sy += (y[1] * b[1]);
    sx += (x[2] * b[2]);
    sy += (y[2] * b[2]);

    // 結果を格納
    [self addPointToResult:(int)(sx)
                     withY:(int)(sy)];

    return;
}


//
// Spline による補間値を算出
//
//  Call
//    t : 勾配
//
//  Return
//    bb : 算出した結果(配列)(要素数は3固定)
//
-(void)splineFunction:(double)t
             toResult:(double *)bb
{
    bb[0] = ((double)(0.5f) * ((double)(1.0f) - t) * ((double)(1.0f) - t));
    bb[1] = ((((double)(1.0f) - t) * t) + (double)(0.5f));
    bb[2] = ((double)(0.5f) * t * t);

    return;
}


// ---------------------------------------------------------- instance - public
//
// 補間した座標を算出
//
//  Call
//    freq    : 頻度
//    source_ : 指定の点(instance 変数)
//
//  Return
//    function : 算出した点
//
-(NSArray *)exec:(unsigned int)freq
{
    int idx1;
    int idx2;
    int interval;
    double xx[3];
    double yy[3];
    double bb[3];
    PoCoPoint *pt;
    double a[3];
    double b[3];
    double c[3];
    int deg[3];

    // 以前の結果は忘れる
    [self->result_ removeAllObjects];

    // 指定の点が3点未満なら補間できない
    if ([self->source_ count] < 3) {
        goto EXIT;
    }

    // 先頭の点を登録
    pt = [self->source_ firstObject];
    [self addPointToResult:[pt x]
                     withY:[pt y]];

    // 座標を算出
    for (idx1 = 0; idx1 < ([self->source_ count] - 2); (idx1)++) {
        // 3点を取得
        pt = [self->source_ objectAtIndex:(idx1 + 0)];
        xx[0] = (double)([pt x]);
        yy[0] = (double)([pt y]);
        pt = [self->source_ objectAtIndex:(idx1 + 1)];
        xx[1] = (double)([pt x]);
        yy[1] = (double)([pt y]);
        pt = [self->source_ objectAtIndex:(idx1 + 2)];
        xx[2] = (double)([pt x]);
        yy[2] = (double)([pt y]);

        // 算出する点の数を決定
        a[0] = (xx[1] - xx[0]);
        a[1] = (xx[2] - xx[1]);
        a[2] = (xx[2] - xx[0]);
        b[0] = (yy[1] - yy[0]);
        b[1] = (yy[2] - yy[1]);
        b[2] = (yy[2] - yy[0]);
        c[0] = sqrt((a[0] * a[0]) + (b[0] * b[0]));
        c[1] = sqrt((a[1] * a[1]) + (b[1] * b[1]));
        c[2] = sqrt((a[2] * a[2]) + (b[2] * b[2]));
        deg[0] = (int)(floor((PoCoDivPI * acos(a[0] / c[0])) * 10.0));
        deg[1] = (int)(floor((PoCoDivPI * acos(a[1] / c[1])) * 10.0));
        deg[2] = (int)(floor((PoCoDivPI * acos(a[2] / c[2])) * 10.0));
        if
        (
            (
                (
                    (deg[0] >= 425)
                    &&
                    (deg[0] <= 475)
                )
                &&
                (
                    (deg[1] >= 425)
                    &&
                    (deg[1] <= 475)
                )
                &&
                (
                    (deg[2] >= 425)
                    &&
                    (deg[2] <= 475)
                )
            )
            ||
            (
                (
                    (deg[0] >= 1325)
                    &&
                    (deg[0] <= 1375)
                )
                &&
                (
                    (deg[1] >= 1325)
                    &&
                    (deg[1] <= 1375)
                )
                &&
                (
                    (deg[2] >= 1325)
                    &&
                    (deg[2] <= 1375)
                )
            )
        )
        {
            // 45度、135度の近傍は曲線補間しない
            interval = 0;
        }
        else
        {
            // 他は補間する
            interval = ((int)(c[2] + (double)(0.5f)) / freq);
        }


        // 座標を算出
        [self splineFunction:(double)(0.0f)
                    toResult:bb];
        [self interpolate:bb
                    xAxes:xx
                    yAxes:yy];
        for(idx2 = 1; idx2 <= interval; (idx2)++) {
            [self splineFunction:((double)(idx2) / (double)(interval))
                        toResult:bb];
            [self interpolate:bb
                        xAxes:xx
                        yAxes:yy];
        }
    }

    // 最後の点を登録
    pt = [self->source_ lastObject];
    [self addPointToResult:[pt x]
                     withY:[pt y]];

EXIT:
    return (NSArray *)(self->result_);
}

@end
