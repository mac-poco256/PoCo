//
//	Pelistina on Cocoa - PoCo -
//	楕円関数
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoCalcEllipse.h"

#import "PoCoCalcRotation.h"

// ============================================================================
@implementation PoCoCalcEllipse

// --------------------------------------------------------- instance - private
//
// 点を追加
//
//  Call
//    num    : 座標群の番号
//    x      : X 座標
//    y      : Y 座標
//    append : 末尾追加か
//             YES : 末尾に追加
//             NO  : 先頭に挿入
//    pos_[] : 座標群(instance 変数)
//
//  Return
//    pos_[] : 座標群(instance 変数)
//
-(void)addPos:(int)num
            x:(int)x
            y:(int)y
       append:(BOOL)append
{
    PoCoPoint *p;

    p = [[PoCoPoint alloc] initX:x
                           initY:y];
    if (append) {
        [self->pos_[num] addObject:p];
    } else {
        [self->pos_[num] insertObject:p
                              atIndex:0];
    }
    [p release];

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
//    function   : 実体
//    arrayIter_ : 反復子(pos_ 配列走査用)(instance 変数)
//    posIter_   : 反復子(pos_ 内走査用)(instance 変数)
//    pos_[]     : 座標群(instance 変数)
//
-(id)init
{
    int l;

    DPRINT((@"[PoCoCalcEllipse init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->arrayIter_ = 0;
        self->posIter_ = nil;
        for (l = 0; l < 8; l++) {
            self->pos_[l] = [[NSMutableArray alloc] init];
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
//    pos_[] : 座標群(instance 変数)
//
-(void)dealloc
{
    int l;

    DPRINT((@"[PoCoCalcEllipse dealloc]\n"));

    // 資源を解放
    for (l = 0; l < 8; l++) {
        [self->pos_[l] removeAllObjects];
        [self->pos_[l] release];
        self->pos_[l] = nil;
    }

    // super class の解放
    [super dealloc];

    return;
}


//
// 演算
//
//  Call
//    cp  : 中心点
//    ep  : 終点
//    ort : 方向
//          == nil : 回転しない
//          != nil : 回転する
//
//  Return
//    None
//
-(void)calc:(PoCoPoint *)cp
     endPos:(PoCoPoint *)ep
orientation:(PoCoPoint *)ort
{
    int h;
    int v;
    int c;                              // 補正
    int x[2];
    int y[2];
    int fx[2] = {0, 0};
    int fy[2] = {0, 0};
    int deg;
    PoCoCalcRotationForEllipse *rot;

    h = (([cp x] < [ep x]) ? ([ep x] - [cp x]) : ([cp x] - [ep x]));
    v = (([cp y] < [ep y]) ? ([ep y] - [cp y]) : ([cp y] - [ep y]));
    rot = [[PoCoCalcRotationForEllipse alloc] initWithCenterPos:cp
                                                     withEndPos:ep
                                                    ifAnyOrient:ort];
    if (h == 0) {
        ;
    } else if (h == v) {
        // 真円
        c = h;
        x[0] = h;
        for (y[0] = 0; x[0] >= y[0]; (y[0])++) {
            [self addPos:0
                       x:([cp x] + x[0])
                       y:([cp y] + y[0])
                  append:YES];
            [self addPos:7
                       x:([cp x] + x[0])
                       y:([cp y] - y[0])
                  append:NO];
            [self addPos:3
                       x:([cp x] - x[0])
                       y:([cp y] + y[0])
                  append:NO];
            [self addPos:4
                       x:([cp x] - x[0])
                       y:([cp y] - y[0])
                  append:YES];
            [self addPos:1
                       x:([cp x] + y[0])
                       y:([cp y] + x[0])
                  append:NO];
            [self addPos:6
                       x:([cp x] + y[0])
                       y:([cp y] - x[0])
                  append:YES];
            [self addPos:2
                       x:([cp x] - y[0])
                       y:([cp y] + x[0])
                  append:YES];
            [self addPos:5
                       x:([cp x] - y[0])
                       y:([cp y] - x[0])
                  append:NO];
            c -= ((y[0] << 1) + 1);
            if (c < 0) {
                c += ((x[0] - 1) << 1);
                (x[0])--;
            }
        }
    } else if ([rot isExec]) {
        // 回転した楕円
        for (deg = 0; deg < 3600; (deg)++) {
            [self addPos:(deg / 450)
                       x:([cp x] + [rot calcXAxis:deg
                                       horiLength:h
                                       vertLength:v])
                       y:([cp y] + [rot calcYAxis:deg
                                       horiLength:h
                                       vertLength:v])
                  append:YES];
        }
    } else if (h > v) {
        // 水平の楕円
        c = h;
        x[0] = h;
        for (y[0] = 0; x[0] >= y[0]; (y[0])++) {
            x[1] = ((x[0] * v) / h);
            y[1] = ((y[0] * v) / h);
            if ((fx[0] != x[0]) || (fy[1] != y[1])) {
                [self addPos:0
                           x:([cp x] + x[0])
                           y:([cp y] + y[1])
                      append:YES];
                [self addPos:7
                           x:([cp x] + x[0])
                           y:([cp y] - y[1])
                      append:NO];
                [self addPos:3
                           x:([cp x] - x[0])
                           y:([cp y] + y[1])
                      append:NO];
                [self addPos:4
                           x:([cp x] - x[0])
                           y:([cp y] - y[1])
                      append:YES];
                fx[0] = x[0];
                fy[1] = y[1];
            }
            if ((fx[1] != x[1]) || (fy[0] != y[0])) {
                [self addPos:1
                           x:([cp x] + y[0])
                           y:([cp y] + x[1])
                      append:NO];
                [self addPos:6
                           x:([cp x] + y[0])
                           y:([cp y] - x[1])
                      append:YES];
                [self addPos:2
                           x:([cp x] - y[0])
                           y:([cp y] + x[1])
                      append:YES];
                [self addPos:5
                           x:([cp x] - y[0])
                           y:([cp y] - x[1])
                      append:NO];
                fx[1] = x[1];
                fy[0] = y[0];
            }
            c -= ((y[0] << 1) - 1);
            if (c < 0) {
                c += ((x[0] - 1) << 1);
                (x[0])--;
            }
        }
    } else {
        // 垂直の楕円
        c = v;
        x[0] = v;
        for (y[0] = 0; x[0] >= y[0]; (y[0])++) {
            x[1] = ((x[0] * h) / v);
            y[1] = ((y[0] * h) / v);
            if ((fx[1] != x[1]) || (fy[0] != y[0])) {
                [self addPos:0
                           x:([cp x] + x[1])
                           y:([cp y] + y[0])
                      append:YES];
                [self addPos:7
                           x:([cp x] + x[1])
                           y:([cp y] - y[0])
                      append:NO];
                [self addPos:3
                           x:([cp x] - x[1])
                           y:([cp y] + y[0])
                      append:NO];
                [self addPos:4
                           x:([cp x] - x[1])
                           y:([cp y] - y[0])
                      append:YES];
                fx[1] = x[1];
                fy[0] = y[0];
            }
            if ((fx[0] != x[0]) || (fy[1] != y[1])) {
                [self addPos:1
                           x:([cp x] + y[1])
                           y:([cp y] + x[0])
                      append:NO];
                [self addPos:6
                           x:([cp x] + y[1])
                           y:([cp y] - x[0])
                      append:YES];
                [self addPos:2
                           x:([cp x] - y[1])
                           y:([cp y] + x[0])
                      append:YES];
                [self addPos:5
                           x:([cp x] - y[1])
                           y:([cp y] - x[0])
                      append:NO];
                fx[0] = x[0];
                fy[1] = y[1];
            }
            c -= ((y[0] << 1) - 1);
            if (c < 0) {
                c += ((x[0] - 1) << 1);
                (x[0])--;
            }
        }
    }

    [rot release];
    return;
}


//
// 取得
//
//  Call
//    arrayIter_ : 反復子(pos_ 配列走査用)(instance 変数)
//    posIter_   : 反復子(pos_ 内走査用)(instance 変数)
//    pos_[]     : 座標群(instance 変数)
//
//  Return
//    arrayIter_ : 反復子(pos_ 配列走査用)(instance 変数)
//    posIter_   : 反復子(pos_ 内走査用)(instance 変数)
//
-(PoCoPoint *)points
{
    PoCoPoint *p;

    p = nil;

    while (self->arrayIter_ < 8) {
        if (self->posIter_ == nil) {
            self->posIter_ = [self->pos_[self->arrayIter_] objectEnumerator];
        }

        p = [self->posIter_ nextObject];
        if (p != nil) {
            break;
        }

        // 次へ
        self->posIter_ = nil;
        (self->arrayIter_)++;
    }

    return p;
}

@end
