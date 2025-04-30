//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 拡散 - 直線
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditRandomDrawLine.h"

#import "PoCoEditRandomFill.h"
#import "PoCoCreateStyleMask.h"

// ============================================================================
@implementation PoCoEditRandomDrawLine

// --------------------------------------------------------- instance - private
//
// 点の描画
//
//  Call
//    p            : 描画中心
//    tile         : タイルパターン
//    bitmap_      : 編集対象(instance 変数)
//    palette_     : 使用パレット(instance 変数)
//    tilePattern_ : タイルパターン(instance 変数)
//    ratio_       : 頻度(0.1%単位)(instance 変数)
//    range_       : 範囲(instance 変数)
//
//  Return
//    None
//
-(void)drawPoint:(PoCoPoint *)p
{
    PoCoPoint *p2;
    PoCoRect *drawRect;                 // 予定描画領域(全体)
    PoCoRect *trueRect;                 // 描画領域(画像範囲外も含む)
    PoCoCreateStyleMask *styleMask;     // 形状マスク
    PoCoEditRandomFill *filler;

    // 終点を生成(常に原点から右下)
    p2 = [[PoCoPoint alloc] initX:([p x] + self->range_)
                            initY:([p y] + self->range_)];

    // 描画領域を生成
    trueRect = [[PoCoRect alloc] initLeft:([p x] - self->range_)
                                  initTop:([p y] - self->range_)
                                initRight:[p2 x]
                               initBottom:[p2 y]];
    drawRect = [[PoCoRect alloc] initLeft:MAX(([p x] - self->range_), 0)
                                  initTop:MAX(([p y] - self->range_), 0)
                                initRight:MIN([p2 x], [self->bitmap_ width])
                               initBottom:MIN([p2 y], [self->bitmap_ height])];

    // 形状生成(真円を起こすので方向点は nil でよい)
    styleMask = [[PoCoCreateStyleMask alloc] init];
    if ([styleMask ellipse:p
                       end:p2
               orientation:nil]) {
        // 描画
        filler = [[PoCoEditRandomFill alloc]
                       init:self->bitmap_
                    palette:self->palette_
                      ratio:self->ratio_
                      range:self->range_];
        [filler executeDraw:[styleMask mask]
                   withTile:self->tilePattern_
               withTrueRect:trueRect
               withDrawRect:drawRect];
        [filler release];
    }
    [styleMask release];
    [p2 release];
    [trueRect release];
    [drawRect release];

    return;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp  : 編集対象
//    plt  : 使用パレット
//    tile : タイルパターン
//    size : 大きさ
//
//  Return
//    function     : 実体
//    bitmap_      : 編集対象(instance 変数)
//    palette_     : 使用パレット(instance 変数)
//    tilePattern_ : タイルパターン(instance 変数)
//    points_      : 描画する点(instance 変数)
//    ratio_       : 頻度(0.1%単位)(instance 変数)
//    range_       : 範囲(instance 変数)
//    drawRect_    : 描画範囲(instance 変数)
//
-(id)init:(PoCoBitmap *)bmp
  palette:(PoCoPalette *)plt
     tile:(PoCoMonochromePattern *)tile
    ratio:(int)rat
    range:(int)rng
{
    DPRINT((@"[PoCoEditRandomDrawLine init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->bitmap_ = bmp;
        self->palette_ = plt;
        self->tilePattern_ = tile;
        self->ratio_ = rat;
        self->range_ = rng;

        // それぞれ retain しておく
        [self->bitmap_ retain];
        [self->palette_ retain];
        [self->tilePattern_ retain];

        // 資源の確保
        self->points_ = [[NSMutableArray alloc] init];
        self->drawRect_ = [[PoCoRect alloc] initLeft:[self->bitmap_ width]
                                             initTop:[self->bitmap_ height]
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
//    bitmap_      : 編集対象(instance 変数)
//    palette_     : 使用パレット(instance 変数)
//    tilePattern_ : タイルパターン(instance 変数)
//    points_      : 描画する点(instance 変数)
//    drawRect_    : 描画範囲(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoEditRandomDrawLine dealloc]\n"));

    // 資源の解放
    [self->points_ removeAllObjects];
    [self->bitmap_ release];
    [self->palette_ release];
    [self->tilePattern_ release];
    [self->points_ release];
    [self->drawRect_ release];
    self->bitmap_ = nil;
    self->palette_ = nil;
    self->tilePattern_ = nil;
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
//    p       : 登録する点
//    bitmap_ : 編集対象(instance 変数)
//
//  Return
//    points_   : 描画する点(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//
-(void)addPoint:(PoCoPoint *)p
{
    const int sz = (ATOMIZER_TBL_ROW / 2);
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
        [self->drawRect_ setRight:MIN(([p x] + sz + 1), [self->bitmap_ width])];
    }
    if (([p y] + sz + 1) > [self->drawRect_ bottom]) {  
        [self->drawRect_ setBottom:MIN(([p y] + sz + 1), [self->bitmap_ height])];
    }

    return;
}


//
// 点を解放
//
//  Call
//    bitmap_ : 編集対象(instance 変数)
//
//  Return
//    points_   : 描画する点(instance 変数)
//    drawRect_ : 描画範囲(instance 変数)
//
-(void)clearPoint
{
    [self->points_ removeAllObjects];

    // 描画範囲を初期化する
    [self->drawRect_ setLeft:[self->bitmap_ width]];
    [self->drawRect_ setTop:[self->bitmap_ height]];
    [self->drawRect_ setRight:0];
    [self->drawRect_ setBottom:0];

    return;
}


//
// 実行
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
    if ([self->drawRect_ empty]) {
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

@end
