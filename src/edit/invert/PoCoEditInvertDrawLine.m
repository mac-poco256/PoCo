//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 反転 - 直線の描画
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditInvertDrawLine.h"

// ============================================================================
@implementation PoCoEditInvertDrawLine

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp : 描画対象 bitmap
//    z   : 0x00 のみを反転対象とする
//
//  Return
//    function : 実体
//    points_  : 点(instance 変数)
//
-(id)initWithBitmap:(PoCoBitmap *)bmp
         isZeroOnly:(BOOL)z
{
//    DPRINT((@"[PoCoEditInvertDrawLine initWithBitmap]\n"));

    // super class の初期化
    self = [super initWithBitmap:bmp
                      isZeroOnly:z];

    // 自身の初期化
    if (self != nil) {
        // 点の保持部の生成
        self->points_ = [[NSMutableArray alloc] init];
        if (self->points_ == nil) {
            DPRINT((@"can't alloc NSMutableArray\n"));
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
//    points_ : 点(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoEditInvertDrawLine dealloc]\n"));

    // 資源の解放
    [self->points_ removeAllObjects];
    [self->points_ release];
    self->points_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 点の登録
//
//  Call
//    p : 登録する点
//
//  Return
//    points_ : 点(instance 変数)
//
-(void)addPoint:(PoCoPoint *)p
{
    PoCoPoint *tmp;

    tmp = [[PoCoPoint alloc] initX:[p x]
                             initY:[p y]];
    [self->points_ addObject:tmp];
    [tmp release];

    return;
}


//
// 実行
//  閉路を描いても始点・終点は重ならないようにしている
//
//  Call
//    points_ : 点(instance 変数)
//
//  Return
//    None
//
-(void)executeDraw
{
    NSEnumerator *iter;
    int i;
    int e;                              // 誤差
    int ax;                             // 水平傾斜
    int ay;                             // 垂直傾斜
    int dx;                             // 水平差分
    int dy;                             // 垂直差分
    int sx;                             // 水平変量
    int sy;                             // 垂直変量
    int fx;                             // 直前の水平軸
    int fy;                             // 直前の垂直軸
    PoCoPoint *dp;                      // 描画点
    PoCoPoint *p1;                      // 線分始点
    PoCoPoint *p2;                      // 線分終点
    PoCoPoint *sp;                      // 最初の点

    if ([self->points_ count] > 1) {
        fx = -1;
        fy = -1;
        iter = [self->points_ objectEnumerator];
        p1 = [iter nextObject];
        sp = [[PoCoPoint alloc] initX:[p1 x]
                                initY:[p1 y]];
        for (p2 = [iter nextObject]; p2 != nil; p2 = [iter nextObject]) {
            // 水平値の算出
            dx = [p2 x] - [p1 x];
            if (dx < 0) {
                sx = -1;
                dx = -dx;
            } else {
                sx = 1;
            }
            ax = (dx << 1);

            // 垂直値の算出
            dy = [p2 y] - [p1 y];
            if (dy < 0) {
                sy = -1;
                dy = -(dy);
            } else {
                sy = 1;
            }
            ay = (dy << 1);

            // 点の描画
            if ((dx == 0) && (dy == 0)) {
                // 同一点
                ;
            } else if (dx == 0) {
                // 垂直線
                for (dp = p1 ; !([dp isEqualPos:p2]); [dp moveY:sy]) {
                    if ((fx != [dp x]) || (fy != [dp y])) {
                        [super drawPoint:dp];
                    }
                    fx = [dp x];
                    fy = [dp y];
                }
            } else if (dy == 0) {
                // 水平線
                for (dp = p1; !([dp isEqualPos:p2]); [dp moveX:sx]) {
                    if ((fx != [dp x]) || (fy != [dp y])) {
                        [super drawPoint:dp];
                    }
                    fx = [dp x];
                    fy = [dp y];
                }
            } else if (dx < dy) {
                // 任意方向(垂直変量の方が大きい)
                dp = p1;
                e = -(dy);
                for (i = 0; i < dy; (i)++) {
                    if ((fx != [dp x]) || (fy != [dp y])) {
                        [super drawPoint:dp];
                    }
                    fx = [dp x];
                    fy = [dp y];

                    // 点の移動
                    e += ax;
                    [dp moveY:sy];
                    if (e >= 0) {
                        [dp moveX:sx];
                        e -= ay;
                    }
                }
            } else {
                // 任意方向(水平変量の方が大きい)
                dp = p1;
                e = -dx;
                for (i = 0; i < dx; (i)++) {
                    if ((fx != [dp x]) || (fy != [dp y])) {
                        [super drawPoint:dp];
                    }
                    fx = [dp x];
                    fy = [dp y];

                    // 点の移動
                    e += ay;
                    [dp moveX:sx];
                    if (e >= 0) {
                        [dp moveY:sy];
                        e -= ax;
                    }
                }
            }

            // 大本の始点と違えば描画
            if (!([p2 isEqualPos:sp])) {
                [super drawPoint:p2];
                fx = [p2 x];
                fy = [p2 y];
            }

            // 終点を始点に複写
            p1 = p2;
        }
        [sp release];
    }

    return;
}

@end
