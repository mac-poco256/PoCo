//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - ぼかし - 直線基底
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoEditWaterDropDrawLineBase.h"

#import "PoCoColorMixer.h"

// ============================================================================
@implementation PoCoEditWaterDropDrawLineBase

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp   : 編集対象
//    cmode : 色演算モード
//    plt   : 使用パレット
//    buf   : 色保持情報
//
//  Return
//    function  : 実体
//    points_   : 描画する点(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//
-(id)init:(PoCoBitmap *)bmp
  colMode:(PoCoColorMode)cmode
  palette:(PoCoPalette *)plt
   buffer:(PoCoColorBuffer *)buf
{
    DPRINT((@"[PoCoEditWaterDropDrawLineBase init]\n"));

    // super class の初期化
    self = [super initWithBitmap:bmp
                         colMode:cmode
                         palette:plt
                          buffer:buf];

    // 自身の初期化
    if (self != nil) {
        // 資源の確保
        self->points_ = [[NSMutableArray alloc] init];
        self->drawRect_ = [[PoCoRect alloc] initLeft:[bmp width]
                                             initTop:[bmp height]
                                           initRight:0
                                          initBottom:0];  
        if ((self->points_ == nil) || (self->drawRect_ == nil)) {
            // 失敗
            DPRINT((@"memory allocation error.\n"));
            [self release];
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
//    points_   : 描画する点(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoEditWaterDropDrawLineBase dealloc]\n"));

    // 資源の解放
    [self->points_ removeAllObjects];
    [self->points_ release];
    [self->drawRect_ release];
    self->points_ = nil;
    self->drawRect_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 点を登録
//
//  Call
//    p          : 登録する点
//    srcBitmap_ : 描画元(複製)(instance 変数)
//
//  Return
//    points_   : 描画する点(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//
-(void)addPoint:(PoCoPoint *)p
{
    const int sz = [self pointSize];
    PoCoPoint *tmp;

    tmp = [[PoCoPoint alloc] initX:[p x] initY:[p y]];
    [self->points_ addObject:tmp];
    [tmp release];

    // 描画領域を更新(+1 は half-open property のため)
    if (([p x] - sz) < [self->drawRect_ left]) {
        [self->drawRect_ setLeft:MAX(([p x] - sz), 0)];
    }
    if (([p y] - sz) < [self->drawRect_ top]) {
        [self->drawRect_ setTop:MAX(([p y] - sz), 0)];
    }
    if (([p x] + sz + 1) > [self->drawRect_ right]) {
        [self->drawRect_ setRight:MIN(([p x] + sz + 1), [self->srcBitmap_ width])];
    }
    if (([p y] + sz + 1) > [self->drawRect_ bottom]) {  
        [self->drawRect_ setBottom:MIN(([p y] + sz + 1), [self->srcBitmap_ height])];
    }

    return;
}


//
// 点を解放
//
//  Call
//    srcBitmap_ : 描画元(複製)(instance 変数)
//
//  Return
//    points_   : 描画する点(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//
-(void)clearPoint
{
    [self->points_ removeAllObjects];

    // 描画範囲を初期化する
    [self->drawRect_ setLeft:[self->srcBitmap_ width]];
    [self->drawRect_ setTop:[self->srcBitmap_ height]];
    [self->drawRect_ setRight:0];
    [self->drawRect_ setBottom:0];

    return;
}


//
// 実行
//  ここでは座標演算が目的
//  描画そのものは具象 class の drawPoint: で実装する
//
//  Call
//    points_   : 描画する点(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//
//  Return
//    None
//
-(void)executeDraw
{
    NSEnumerator *iter;                 // points_ の反復子
    PoCoPoint *p1;                      // 始点
    PoCoPoint *p2;                      // 終点
    PoCoPoint *dp;                      // 描画点(中心)
    int i;                              // 座標遷移(水平ないし垂直)
    int e;                              // 誤差
    int dx;                             // 水平差分
    int dy;                             // 垂直差分
    int sx;                             // 水平変量(常に±1のみ)
    int sy;                             // 垂直変量(常に±1のみ)
    int ax;                             // 水平傾斜
    int ay;                             // 垂直傾斜

    // 描画領域なし
    if([self->drawRect_ empty]){
        goto EXIT;
    }

    // 点の反復処理
    iter = [self->points_ objectEnumerator];
    p1 = [iter nextObject];
    for (p2 = [iter nextObject]; p2 != nil; p2 = [iter nextObject]) {
        dp = p1;

        // 変位算出
        dx = abs([p2 x] - [dp x]);
        dy = abs([p2 y] - [dp y]);
        sx = (([p2 x] < [dp x]) ? -1 : 1);
        sy = (([p2 y] < [dp y]) ? -1 : 1);
        ax = (dx << 1);
        ay = (dy << 1);

        // 点の移動
        if ((dx == 0) && (dy == 0)) {
            // 同一点
            [self drawPoint:dp];
        } else if (dx == 0) {
            // 垂直線
            for ( ; !([dp isEqualPos:p2]); [dp moveY:sy]) {
                [self drawPoint:dp];
            }
        } else if (dy == 0) {
            // 水平線
            for ( ; !([dp isEqualPos:p2]); [dp moveX:sx]) {
                [self drawPoint:dp];
            }  
        } else if (dx < dy) {  
            // 任意方向(垂直変量の方が大きい)
            e = -(dy);
            for (i = 0; i < dy; (i)++) {
                [self drawPoint:dp];

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
            e = -(dx);
            for (i = 0; i < dx; (i)++) {
                [self drawPoint:dp];

                // 点の移動
                e += ay;
                [dp moveX:sx];
                if (e >= 0) {
                    [dp moveY:sy];
                    e -= ax;
                }
            }
        }

        // 終点を始点に複写
        p1 = p2;
    }

EXIT:
    return;
}


//
// 描画範囲
//  具象 class で描画範囲のドット数/2を返す
//
//  Call
//    None
//
//  Return
//    function : 描画範囲
//
-(int)pointSize
{
    return 0;                           // 基底では 0 を返す
}


//
// 点の描画
//
//  Call
//    p : 描画中心
//
//  Return
//    None
//
-(void)drawPoint:(PoCoPoint *)p
{
    // 基底では何もしない
    ;

    return;
}

@end
