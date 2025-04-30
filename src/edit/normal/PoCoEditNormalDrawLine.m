//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 標準 - 直線の描画
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditNormalDrawLine.h"

// ============================================================================
@implementation PoCoEditNormalDrawLine

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp  : 描画対象 bitmap
//    plt  : 使用パレット
//    pen  : 使用ペン先
//    tile : 使用タイルパターン
//    pat  : 使用カラーパターン
//
//  Return
//    function  : 実体
//    points_   : 点(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//
-(id)initWithPattern:(PoCoBitmap *)bmp
             palette:(PoCoPalette *)plt
                 pen:(PoCoMonochromePattern *)pen
                tile:(PoCoMonochromePattern *)tile
             pattern:(PoCoColorPattern *)pat
{
//    DPRINT((@"[PoCoEditNormalDrawLine initWithPattern]\n"));

    // super class の初期化
    self = [super initWithPattern:bmp
                          palette:plt
                              pen:pen
                             tile:tile
                          pattern:pat];

    // 自身の初期化
    if (self != nil) {
        // 点の保持部の生成
        self->points_ = [[NSMutableArray alloc] init];
        if (self->points_ == nil) {
            DPRINT((@"can't alloc NSMutableArray\n"));
            [self release];
            self = nil;
            goto EXIT;
        }

        // 描画領域の生成
        self->drawRect_ = [[PoCoRect alloc] initLeft:[bmp width]
                                             initTop:[bmp height]
                                           initRight:0
                                          initBottom:0];
        if (self->drawRect_ == nil) {
            DPRINT((@"can't alloc PoCoRect \n"));
            [self release];
            self = nil;
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
//    points_   : 点(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoEditNormalDrawLine dealloc]\n"));

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
// 点の登録
//
//  Call
//    p       : 登録する点
//    bitmap_ : 描画対象 bitmap(基底 instance 変数)
//
//  Return
//    points_   : 点(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//
-(void)addPoint:(PoCoPoint *)p
{
    PoCoPoint *tmp;

    // 点を登録(複製をとる)
    tmp = [[PoCoPoint alloc] initX:[p x] initY:[p y]];
    [self->points_ addObject:tmp];
    [tmp release];

    // 描画領域を更新
    if (([p x] - (PEN_STYLE_SIZE >> 1)) < [self->drawRect_ left]) {
        [self->drawRect_ setLeft:MAX(([p x] - (PEN_STYLE_SIZE >> 1)), 0)];
    }
    if (([p x] + (PEN_STYLE_SIZE >> 1)) > [self->drawRect_ right]) {
        [self->drawRect_ setRight:MIN([p x] + (PEN_STYLE_SIZE >> 1), [self->bitmap_ width])];
    }
    if (([p y] - (PEN_STYLE_SIZE >> 1)) < [self->drawRect_ top]) {
        [self->drawRect_ setTop:MAX(([p y] - (PEN_STYLE_SIZE >> 1)), 0)];
    }
    if (([p y] + (PEN_STYLE_SIZE >> 1)) > [self->drawRect_ bottom]) {
        [self->drawRect_ setBottom:MIN([p y] + (PEN_STYLE_SIZE >> 1),[self->bitmap_ height])];
    }

    return;
}


//
// 実行
//
//  Call
//    points_   : 点(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
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
    PoCoPoint *dp;
    PoCoPoint *p1;
    PoCoPoint *p2;

    // 描画開始
    [super beginDraw:self->drawRect_];

    // 描画
    iter = [self->points_ objectEnumerator];
    p1 = [iter nextObject];
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
            for (dp = p1; !([dp isEqualPos:p2]); [dp moveY:sy]) {
                [super drawPoint2:dp];
            }
        } else if (dy == 0) {
            // 水平線
            for (dp = p1; !([dp isEqualPos:p2]); [dp moveX:sx]) {
                [super drawPoint2:dp];
            }
        } else if (dx < dy) {
            // 任意方向(垂直変量の方が大きい)
            dp = p1;
            e = -dy;
            for (i = 0; i < dy; (i)++) {
                [super drawPoint2:dp];

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
            e = -(dx);
            for (i = 0; i < dx; (i)++) {
                [super drawPoint2:dp];

                // 点の移動
                e += ay;
                [dp moveX:sx];
                if (e >= 0) {
                    [dp moveY:sy];
                    e -= ax;
                }
            }
        }
        [super drawPoint2:p2];

        // 終点を始点に複写
        p1 = p2;
    }

    // 描画終了
    [super endDraw];

    return;
}

@end
