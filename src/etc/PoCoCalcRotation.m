//
//	Pelistina on Cocoa - PoCo -
//	回転関数
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoCalcRotation.h"

// ============================================================================
@implementation PoCoCalcRotation

// ------------------------------------------------------------ class - private
//
// 角度補正
//  15度単位刻みに補正
//
//  Call
//    rad : ラジアン
//
//  Return
//    funcion : ラジアン
//
+(double)corrRotate:(double)rad
{
    int deg;

    // 角度に変換
    deg = (int)(floor((PoCoDivPI * rad) * 10.0));

    // 15度の範囲に丸め込み
    deg += ((deg < 0) ? -75 : 75);
    deg /= 150;
    deg *= 150;

    // 360度の範囲に丸め込み
    deg %= 3600;

    // ラジアンにして返す
    return (((double)(deg) / 10.0) * PoCoMulPI);
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    p : 制御点
//    v : つかむ点の性質は垂直か
//    g : つかむ点の性質は大きい座標か
//
//  Return
//    function : 実体
//    control_ : 制御点(instance 変数)
//    vert_    : つかむ点の性質は垂直か(instance 変数)
//    greater_ : つかむ点の性質は大きい座標か(instance 変数)
//    sin_     : 回転角の sin(instance 変数)
//    cos_     : 回転角の cos(instance 変数)
//    prevSin_ : 以前の sin(instance 変数)
//    prevCos_ : 以前の cos(instance 変数)
//
-(id)initWithControlPoint:(PoCoPoint *)p
        isVerticalControl:(BOOL)v
         isGreaterControl:(BOOL)g
{
    DPRINT((@"[PoCoCalcRotation initWithControlPoint]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->control_ = nil;
        self->vert_ = v;
        self->greater_ = g;
        self->sin_ = ((v) ? 0.0                : ((g) ? 1.0 : -1.0));
        self->cos_ = ((v) ? ((g) ? 1.0 : -1.0) : 0.0               );
        self->prevSin_ = self->sin_;
        self->prevCos_ = self->cos_;

        // 資源を確保
        self->control_ = [[PoCoPoint alloc] initX:[p x]
                                            initY:[p y]];
        if (self->control_ == nil) {
            DPRINT((@"can't allocation\n"));
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
//    control_ : 制御点(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoCalcRotation dealloc]\n"));

    // 資源を解放
    [self->control_ release];
    self->control_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 制御点を移動
//
//  Call
//    p        : 移動先
//    corr     : 角度補正
//               YES : 補正あり
//               NO  : 補正なし
//    control_ : 制御点(instance 変数)
//
//  Return
//    function : 角度が変わったか
//               YES : 変わった
//               NO  : 変わっていない
//    sin_     : 回転角の sin(instance 変数)
//    cos_     : 回転角の cos(instance 変数)
//    prevSin_ : 以前の sin(instance 変数)
//    prevCos_ : 以前の cos(instance 変数)
//
-(BOOL)moveControlPoint:(PoCoPoint *)p
              isCorrect:(BOOL)corr
{
    BOOL result;
    int vx;
    int vy;
    double scr;

    vx = ([p x] - [self->control_ x]);
    vy = ([p y] - [self->control_ y]);
    if ((vy == 0) && (vx != 0)) {
        self->sin_ = 0.0;
        self->cos_ = ((vx < 0) ? -1.0 : 1.0);
    } else {
        scr = sqrt((double)((vx * vx) + (vy * vy)));
        if (scr != 0.0) {
            self->sin_ = ((double)(vy) / scr);
            self->cos_ = ((double)(vx) / scr);
            if (corr) {
                self->sin_ = sin([PoCoCalcRotation corrRotate:asin(self->sin_)]);
                self->cos_ = cos([PoCoCalcRotation corrRotate:acos(self->cos_)]);
            }
        } else {
            self->sin_ = 0.0;
            self->cos_ = 1.0;
        }
    }

    // 以前の結果と比較して値を覚える
    result = ((self->sin_ != self->prevSin_) || (self->cos_ != self->prevCos_));
    self->prevSin_ = self->sin_;
    self->prevCos_ = self->cos_;

    return result;
}


//
// 演算(特定の点に対して)
//  回転元から回転先を求める
//
//  Call
//    p        : 対象点
//    control_ : 制御点(instance 変数)
//    vert_    : つかむ点の性質は垂直か(instance 変数)
//               YES : 垂直の辺上(左辺 or 右辺)
//               NO  : 水平の辺上(上底 or 下底)
//    greater_ : つかむ点の性質は大きい座標か(instance 変数)
//               YES : 大きい方(右辺 or 下底)
//               NO  : 小さい方(左辺 or 上底)
//    sin_     : 回転角の sin(instance 変数)
//    cos_     : 回転角の cos(instance 変数)
//
//  Return
//    p : 対象点
//
-(void)calcPoint:(PoCoPoint *)p
{
    double cx;
    double cy;
    double fx = (double)([self->control_ x]);
    double fy = (double)([self->control_ y]);

    if (self->vert_) {
        if (self->greater_) {
            // 右辺をつかむ場合(制御点は左側)
            cx = ((double)([p x]) - fx);
            cy = ((double)([p y]) - fy);
        } else {
            // 左辺をつかむ場合(制御点は右側)
            cx = (fx - (double)([p x]));
            cy = (fy - (double)([p y]));
        }
        fx += ((cx * self->cos_) - (cy * self->sin_));
        fy += ((cx * self->sin_) + (cy * self->cos_));
    } else {
        if (self->greater_) {
            // 下底をつかむ場合(制御点は上側)
            cx = (fx - (double)([p x]));
            cy = ((double)([p y]) - fy);
        } else {
            // 上底をつかむ場合(制御点は下側)
            cx = ((double)([p x]) - fx);
            cy = (fy - (double)([p y]));
        }
        fx += ((cy * self->cos_) - (cx * self->sin_));
        fy += ((cx * self->cos_) + (cy * self->sin_));
    }

    // 座標を上書き
    [p setX:(int)(floor(fx + 0.5))
       setY:(int)(floor(fy + 0.5))];

    return;
}


#if 0   // 使わなくした
//
// 逆演算(特定の点に対して)
//  回転先から回転元を求める
//
//  Call
//    p        : 対象点
//    control_ : 制御点(instance 変数)
//    vert_    : つかむ点の性質は垂直か(instance 変数)
//               YES : 垂直の辺上(左辺 or 右辺)
//               NO  : 水平の辺上(上底 or 下底)
//    greater_ : つかむ点の性質は大きい座標か(instance 変数)
//               YES : 大きい方(右辺 or 下底)
//               NO  : 小さい方(左辺 or 上底)
//    sin_     : 回転角の sin(instance 変数)
//    cos_     : 回転角の cos(instance 変数)
//
//  Return
//    p : 対象点
//
-(void)recalcPoint:(PoCoPoint *)p
{
    double cx;
    double cy;
    double fx = (double)([self->control_ x]);
    double fy = (double)([self->control_ y]);

    if (self->vert_) {
        if (self->greater_) {
            // 右辺をつかむ場合(制御点は左側)
            cx = ((double)([p x]) - fx);
            cy = ((double)([p y]) - fy);
        } else {
            // 左辺をつかむ場合(制御点は右側)
            cx = (fx - (double)([p x]));
            cy = (fy - (double)([p y]));
        }
        fx += ((cx * self->cos_) + (cy * self->sin_));
        fy += ((cy * self->cos_) - (cx * self->sin_));
    } else {
        if (self->greater_) {
            // 下底をつかむ場合(制御点は上側)
            cx = ((double)([p x]) - fx);
            cy = ((double)([p y]) - fy);
        } else {
            // 上底をつかむ場合(制御点は下側)
            cx = (fx - (double)([p x]));
            cy = (fy - (double)([p y]));
        }
        fx += ((cx * self->sin_) - (cy * self->cos_));
        fy += ((cx * self->cos_) + (cy * self->sin_));
    }

    // 座標を上書き
    [p setX:(int)(floor(fx + 0.5))
       setY:(int)(floor(fy + 0.5))];

    return;
}
#endif  // 0


//
// 逆演算(特定の点に対して)
//  回転先から回転元を求める
//
//  Call
//    x        : 対象点
//    y        : 対象点
//    control_ : 制御点(instance 変数)
//    vert_    : つかむ点の性質は垂直か(instance 変数)
//               YES : 垂直の辺上(左辺 or 右辺)
//               NO  : 水平の辺上(上底 or 下底)
//    greater_ : つかむ点の性質は大きい座標か(instance 変数)
//               YES : 大きい方(右辺 or 下底)
//               NO  : 小さい方(左辺 or 上底)
//    sin_     : 回転角の sin(instance 変数)
//    cos_     : 回転角の cos(instance 変数)
//
//  Return
//    x : 対象点
//    y : 対象点
//
-(void)recalcPointHori:(double *)x
               andVert:(double *)y
{
    double cx;
    double cy;
    double fx = (double)([self->control_ x]);
    double fy = (double)([self->control_ y]);

    if (self->greater_) {
        cx = (*(x) - fx);
        cy = (*(y) - fy);
    } else {
        cx = (fx - *(x));
        cy = (fy - *(y));
    }
    if (self->vert_) {
        *(x) = (fx + ((cx * self->cos_) + (cy * self->sin_)));
        *(y) = (fy + ((cy * self->cos_) - (cx * self->sin_)));
    } else {
        *(x) = (fx + ((cx * self->sin_) - (cy * self->cos_)));
        *(y) = (fy + ((cx * self->cos_) + (cy * self->sin_)));
    }

    return;
}


//
// 変量
//  整数で 1024 倍した値
//
//  Call
//    vert_    : つかむ点の性質は垂直か(instance 変数)
//               YES : 垂直の辺上(左辺 or 右辺)
//               NO  : 水平の辺上(上底 or 下底)
//    greater_ : つかむ点の性質は大きい座標か(instance 変数)
//               YES : 大きい方(右辺 or 下底)
//               NO  : 小さい方(左辺 or 上底)
//    sin_     : 回転角の sin(instance 変数)
//    cos_     : 回転角の cos(instance 変数)
//
//  Return
//    d : 変量
//        d[0] : 回転元水平走査時の回転先水平変量
//        d[1] : 回転元水平走査時の回転先垂直変量
//        d[2] : 回転元垂直走査時の回転先水平変量
//        d[3] : 回転元垂直走査時の回転先垂直変量
//
-(void)diffInt:(long long *)d
{
    if (self->vert_) {
        if (self->greater_) {
            d[0] = (long long)(  self->cos_  * 1024.0);
            d[1] = (long long)(-(self->sin_) * 1024.0);
            d[2] = (long long)(  self->sin_  * 1024.0);
            d[3] = (long long)(  self->cos_  * 1024.0);
        } else {
            d[0] = (long long)(-(self->cos_) * 1024.0);
            d[1] = (long long)(  self->sin_  * 1024.0);
            d[2] = (long long)(-(self->sin_) * 1024.0);
            d[3] = (long long)(-(self->cos_) * 1024.0);
        }
    } else {
        if (self->greater_) {
            d[0] = (long long)(  self->sin_  * 1024.0);
            d[1] = (long long)(  self->cos_  * 1024.0);
            d[2] = (long long)(-(self->cos_) * 1024.0);
            d[3] = (long long)(  self->sin_  * 1024.0);
        } else {
            d[0] = (long long)(-(self->sin_) * 1024.0);
            d[1] = (long long)(-(self->cos_) * 1024.0);
            d[2] = (long long)(  self->cos_  * 1024.0);
            d[3] = (long long)(-(self->sin_) * 1024.0);
        }
    }

    return;
}

@end




// ============================================================================
@implementation PoCoCalcRotationForBox

// --------------------------------------------------------- instance - private
//
// 座標を算出
//
//  Call
//    centerPos_ : 中心点(instance 変数)
//    cos_       : cos(instance 変数)
//    sin_       : sin(instance 変数)
//
//  Return
//    p : 回転後の座標
//
-(void)calcPoint:(PoCoPoint *)p
{
    double cx;
    double cy;
    double fx = (double)([self->centerPos_ x]);
    double fy = (double)([self->centerPos_ y]);

    cx = ((double)([p x]) - fx);
    cy = ((double)([p y]) - fy);
    fx += ((cx * self->cos_) - (cy * self->sin_));
    fy += ((cx * self->sin_) + (cy * self->cos_));

    // 座標を上書き
    [p setX:(int)(floor(fx + 0.5))
       setY:(int)(floor(fy + 0.5))];

    return;
}
#if 0
{
    double cx;
    double cy;
    double fx = (double)([self->control_ x]);
    double fy = (double)([self->control_ y]);

    if (self->vert_) {
        if (self->greater_) {
            // 右辺をつかむ場合(制御点は左側)
            cx = ((double)([p x]) - fx);
            cy = ((double)([p y]) - fy);
        } else {
            // 左辺をつかむ場合(制御点は右側)
            cx = (fx - (double)([p x]));
            cy = (fy - (double)([p y]));
        }
        fx += ((cx * self->cos_) - (cy * self->sin_));
        fy += ((cx * self->sin_) + (cy * self->cos_));
    } else {
        if (self->greater_) {
            // 下底をつかむ場合(制御点は上側)
            cx = (fx - (double)([p x]));
            cy = ((double)([p y]) - fy);
        } else {
            // 上底をつかむ場合(制御点は下側)
            cx = ((double)([p x]) - fx);
            cy = (fy - (double)([p y]));
        }
        fx += ((cy * self->cos_) - (cx * self->sin_));
        fy += ((cx * self->cos_) + (cy * self->sin_));
    }

    // 座標を上書き
    [p setX:(int)(floor(fx + 0.5))
       setY:(int)(floor(fy + 0.5))];

    return;
}
#endif  // 0


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    spos : 始点
//    epos : 終点
//    opos : 方向点
//
//  Return
//    function     : 実体
//    centerPos_   : 中心点(instance 変数)
//    ortPos_      : 方向点(instance 変数)
//    leftTop_     : 左上(名目上)(instance 変数)
//    rightTop_    : 右上(名目上)(instance 変数)
//    leftBottom_  : 左下(名目上)(instance 変数)
//    rightBottom_ : 右下(名目上)(instance 変数)
//    cos_         : cos(instance 変数)
//    sin_         : sin(instance 変数)
//
-(id)initWithStartPos:(PoCoPoint *)spos
           withEndPos:(PoCoPoint *)epos
          ifAnyOrient:(PoCoPoint *)opos
{
    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->centerPos_ = nil;
        self->ortPos_ = nil;
        self->leftTop_ = nil;
        self->rightTop_ = nil;
        self->leftBottom_ = nil;
        self->rightBottom_ = nil;
        self->cos_ = 1.0;
        self->sin_ = 0.0;

        // 中心点を算出
        self->centerPos_ = [[PoCoPoint alloc] initX:((([epos x] - [spos x]) / 2) + [spos x])
                                              initY:((([epos y] - [spos y]) / 2) + [spos y])];

        // 方向点を記憶
        if (opos != nil) {
            self->ortPos_ = [[PoCoPoint alloc] initX:[opos x]
                                               initY:[opos y]];
        }

        // 4点を生成
        self->leftTop_ = [[PoCoPoint alloc] initX:[spos x]
                                            initY:[spos y]];
        self->rightTop_ = [[PoCoPoint alloc] initX:[epos x]
                                             initY:[spos y]];
        self->leftBottom_ = [[PoCoPoint alloc] initX:[spos x]
                                               initY:[epos y]];
        self->rightBottom_ = [[PoCoPoint alloc] initX:[epos x]
                                                initY:[epos y]];
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
//    centerPos_   : 中心点(instance 変数)
//    ortPos_      : 方向点(instance 変数)
//    leftTop_     : 左上(名目上)(instance 変数)
//    rightTop_    : 右上(名目上)(instance 変数)
//    leftBottom_  : 左下(名目上)(instance 変数)
//    rightBottom_ : 右下(名目上)(instance 変数)
//
-(void)dealloc
{
    // 資源を解放
    [self->centerPos_ release];
    [self->ortPos_ release];
    [self->leftTop_ release];
    [self->rightTop_ release];
    [self->leftBottom_ release];
    [self->rightBottom_ release];
    self->centerPos_ = nil;
    self->ortPos_ = nil;
    self->leftTop_ = nil;
    self->rightTop_ = nil;
    self->leftBottom_ = nil;
    self->rightBottom_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 演算実行
//
//  Call
//    diagonal   : 対角を用いるか
//    centerPos_ : 中心点(instance 変数)
//    ortPos_    : 方向点(instance 変数)
//
//  Return
//    leftTop_     : 左上(名目上)(instance 変数)
//    rightTop_    : 右上(名目上)(instance 変数)
//    leftBottom_  : 左下(名目上)(instance 変数)
//    rightBottom_ : 右下(名目上)(instance 変数)
//    cos_         : cos(instance 変数)
//    sin_         : sin(instance 変数)
//
-(void)calc:(BOOL)diagonal
{
    double oc;
    double ec;
    int rot;
    double r;

    // 方向点がなければ何もしない
    if (self->ortPos_ == nil) {
        goto EXIT;
    }

    // 終点(右下)と方向点の cos を算出
    oc = ((double)([self->ortPos_ x] - [self->centerPos_ x]) / sqrt((double)(([self->ortPos_ x] - [self->centerPos_ x]) * ([self->ortPos_ x] - [self->centerPos_ x])) + (double)(([self->ortPos_ y] - [self->centerPos_ y]) * ([self->ortPos_ y] - [self->centerPos_ y]))));
    if (diagonal) {
        ec = ((double)([self->leftBottom_ x] - [self->centerPos_ x]) / sqrt((double)(([self->leftBottom_ x] - [self->centerPos_ x]) * ([self->leftBottom_ x] - [self->centerPos_ x])) + (double)(([self->leftBottom_ y] - [self->centerPos_ y]) * ([self->leftBottom_ y] - [self->centerPos_ y]))));
    } else {
        ec = ((double)([self->rightBottom_ x] - [self->centerPos_ x]) / sqrt((double)(([self->rightBottom_ x] - [self->centerPos_ x]) * ([self->rightBottom_ x] - [self->centerPos_ x])) + (double)(([self->rightBottom_ y] - [self->centerPos_ y]) * ([self->rightBottom_ y] - [self->centerPos_ y]))));
    }
    if (oc == ec) {
        // 回転できないので何もしない
        goto EXIT;
    }

    // 回転角度を算出
    if (((!(diagonal)) && ([self->rightBottom_ y] < [self->centerPos_ y])) ||
        ((  diagonal ) && ([self->leftBottom_  y] < [self->centerPos_ y]))) {
        if ([self->ortPos_ y] < [self->centerPos_ y]) {
            rot = ((int)(floor((acos(ec) * PoCoDivPI) * 100.0)) - (int)(floor((acos(oc) * PoCoDivPI) * 100.0)));
        } else {
            rot = ((int)(floor((acos(oc) * PoCoDivPI) * 100.0)) + (int)(floor((acos(ec) * PoCoDivPI) * 100.0)));
        }
    } else {
        if ([self->ortPos_ y] < [self->centerPos_ y]) {
            rot = -((int)(floor((acos(oc) * PoCoDivPI) * 100.0)) + (int)(floor((acos(ec) * PoCoDivPI) * 100.0)));
        } else {
            rot = ((int)(floor((acos(oc) * PoCoDivPI) * 100.0)) - (int)(floor((acos(ec) * PoCoDivPI) * 100.0)));
        }
    }

    // radian に戻して cos、sin を算出
    r = (((double)(rot) / 100.0) * PoCoMulPI);
    self->cos_ = cos(r);
    self->sin_ = sin(r);

    // 各点の座標を算出
    [self calcPoint:self->leftTop_];
    [self calcPoint:self->rightTop_];
    [self calcPoint:self->leftBottom_];
    [self calcPoint:self->rightBottom_];

EXIT:
    return;
}


// --------------------------------------------- instance - public - 座標を取得
//
// 左上(名目上)
//
//  Call
//    leftTop_ : 左上(名目上)(instance 変数)
//
//  Return
//    function : 点
//
-(PoCoPoint *)leftTop
{
    return self->leftTop_;
}


//
// 右上(名目上)
//
//  Call
//    rightTop_ : 右上(名目上)(instance 変数)
//
//  Return
//    function : 点
//
-(PoCoPoint *)rightTop
{
    return self->rightTop_;
}


//
// 左下(名目上)
//
//  Call
//    leftBottom_ : 左下(名目上)(instance 変数)
//
//  Return
//    function : 点
//
-(PoCoPoint *)leftBottom
{
    return self->leftBottom_;
}


//
// 右下(名目上)
//
//  Call
//    rightBottom_ : 右下(名目上)(instance 変数)
//
//  Return
//    function : 点
//
-(PoCoPoint *)rightBottom
{
    return self->rightBottom_;
}

@end




// ============================================================================
@implementation PoCoCalcRotationForEllipse

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    cpos : 中心点
//    epos : 終点
//    opos : 方向点
//
//  Return
//    function  : 実体
//    rotation_ : 回転角(instance 変数)
//    cos_      : self->rotation_ の cos(instance 変数)
//    sin_      : self->rotation_ の sin(instance 変数)
//    exec_     : 回転可能か(instance 変数)
//
-(id)initWithCenterPos:(PoCoPoint *)cpos
            withEndPos:(PoCoPoint *)epos
           ifAnyOrient:(PoCoPoint *)opos
{
    int rot;
    double oc;
    double ec;

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->rotation_ = 0.0;
        self->cos_ = 0.0;
        self->sin_ = 0.0;
        self->exec_ = NO;

        // 角度を算出
        if (opos != nil) {
            // cos を算出
            oc = ((double)([opos x] - [cpos x]) / sqrt((double)(([opos x] - [cpos x]) * ([opos x] - [cpos x])) + (double)(([opos y] - [cpos y]) * ([opos y] - [cpos y]))));
            ec = ((double)([epos x] - [cpos x]) / sqrt((double)(([epos x] - [cpos x]) * ([epos x] - [cpos x])) + (double)(([epos y] - [cpos y]) * ([epos y] - [cpos y]))));
        } else {
            oc = 0.0;
            ec = oc;
        }

        // 回転角を算出
        if (oc != ec) {
            // degree を算出(0.01度単位の固定小数点)
            if ([epos y] < [cpos y]) {
                if ([opos y] < [cpos y]) {
                    rot = ((int)(floor((acos(ec) * PoCoDivPI) * 100.0)) - (int)(floor((acos(oc) * PoCoDivPI) * 100.0)));
                } else {
                    rot = ((int)(floor((acos(oc) * PoCoDivPI) * 100.0)) + (int)(floor((acos(ec) * PoCoDivPI) * 100.0)));
                }
            } else {
                if ([opos y] < [cpos y]) {
                    rot = -((int)(floor((acos(oc) * PoCoDivPI) * 100.0)) + (int)(floor((acos(ec) * PoCoDivPI) * 100.0)));
                } else {
                    rot = ((int)(floor((acos(oc) * PoCoDivPI) * 100.0)) - (int)(floor((acos(ec) * PoCoDivPI) * 100.0)));
                }
            }

            // radian に戻して cos、sin を算出
            self->rotation_ = (((double)(rot) / 100.0) * PoCoMulPI);
            self->cos_ = cos(self->rotation_);
            self->sin_ = sin(self->rotation_);

            // 回転可能
            self->exec_ = YES;
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
//    None
//
-(void)dealloc
{
    // 資源を解放
    ;

    // super class の解放
    [super dealloc];

    return;
}


//
// 回転可能か
//
//  Call
//    exec_ : 回転可能か
//
//  Return
//    function : 回転可能か
//
-(BOOL)isExec
{
    return self->exec_;
}


//
// 水平座標
//
//  Call
//    rot  : 角度(0.1度単位の固定小数点)
//    h    : 水平幅
//    v    : 垂直幅
//    cos_ : self->rotation_ の cos(instance 変数)
//    sin_ : self->rotation_ の sin(instance 変数)
//
//  Return
//    function : 座標
//
-(int)calcXAxis:(int)rot
     horiLength:(int)h
     vertLength:(int)v
{
    return (int)(floor(((double)(h) * cos(((double)(rot) / 10.0) * PoCoMulPI) * self->cos_) - ((double)(v) * sin(((double)(rot) / 10.0) * PoCoMulPI) * self->sin_)));
}


//
// 垂直座標
//
//  Call
//    rot  : 角度(0.1度単位の固定小数点)
//    h    : 水平幅
//    v    : 垂直幅
//    cos_ : self->rotation_ の cos(instance 変数)
//    sin_ : self->rotation_ の sin(instance 変数)
//
//  Return
//    function : 座標
//
-(int)calcYAxis:(int)rot
     horiLength:(int)h
     vertLength:(int)v
{
    return (int)(floor(((double)(h) * cos(((double)(rot) / 10.0) * PoCoMulPI) * self->sin_) + ((double)(v) * sin(((double)(rot) / 10.0) * PoCoMulPI) * self->cos_)));
}

@end
