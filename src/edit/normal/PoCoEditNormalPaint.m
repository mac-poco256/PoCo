//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 標準 - 塗りつぶし
//
//	Copyright (C) 2005-2019 KAENRYUU Koutoku.
//

#import "PoCoEditNormalPaint.h"

// ======================================================= PoCoPaintPointBuffer

// ------------------------------------------------------------------ interface
@interface PoCoPaintPointBuffer : NSObject
{
    int left_;                          // 左端
    int right_;                         // 右端
    int vert_;                          // 垂直位置
    int prev_;                          // 以前の垂直位置
}

// initialize
-(id)initWithVert:(int)v
         withPrev:(int)pv;

// deallocate
-(void)dealloc;

// 設定
-(void)setLeft:(int)l;                  // 左端
-(void)setRight:(int)r;                 // 右端

// 取得
-(int)left;                             // 左端
-(int)right;                            // 右端
-(int)vert;                             // 垂直位置
-(int)prev;                             // 以前の垂直位置

@end


// ------------------------------------------------------------------ implement
@implementation PoCoPaintPointBuffer

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    v  : 垂直位置
//    pv : 以前の垂直位置
//
//  Return
//    function : 実体
//    left_    : 左端(instance 変数)
//    right_   : 右端(instance 変数)
//    vert_    : 垂直位置(instance 変数)
//    prev_    : 以前の垂直位置(instance 変数)
//
-(id)initWithVert:(int)v
         withPrev:(int)pv
{
    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->left_ = 0;
        self->right_ = 0;
        self->vert_ = v;
        self->prev_ = pv;
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
    // 資源の解放
    ;

    // super class の解放
    [super dealloc];

    return;
}


//
// 左端を設定
//
//  Call
//    l : 左端
//
//  Return
//    left_ : 左端(instance 変数)
//
-(void)setLeft:(int)l
{
    self->left_ = l;

    return;
}


//
// 右端を設定
//
//  Call
//    r : 右端
//
//  Return
//    right_ : 右端(instance 変数)
//
-(void)setRight:(int)r
{
    self->right_ = r;

    return;
}


//
// 左端を取得
//
//  Call
//    left : 左端(instance 変数)
//
//  Return
//    function : 左端
//
-(int)left
{
    return self->left_;
}


//
// 右端を取得
//
//  Call
//    right_ : 右端(instance 変数)
//
//  Return
//    function : 右端
//
-(int)right
{
    return self->right_;
}


//
// 垂直位置を取得
//
//  Call
//    vert_ : 垂直位置(instance 変数)
//
//  Return
//    function : 垂直位置
//
-(int)vert
{
    return self->vert_;
}


//
// 以前の垂直位置を取得
//
//  Call
//    prev_ : 以前の垂直位置(instance 変数)
//
//  Return
//    function : 以前の垂直位置
//
-(int)prev
{
    return self->prev_;
}

@end




// ============================================================================
@implementation PoCoEditNormalPaint

// --------------------------------------------------------- instance - private
//
// 許容色リストを構築
//
//  Call
//    palette_ : パレット(基底instance変数)
//    range_   : 範囲(instance 変数)
//    baseCol_ : 基準色(instance 変数)
//
//  Return
//    acceptable_[] : 許容色(instance 変数)
//
-(void)createAcceptableTable
{
    int idx;
    int border;

    // 全て NO にする
    memset(self->acceptable_, 0x00, (COLOR_MAX * sizeof(BOOL)));

    // 少なくとも自身は許容
    self->acceptable_[self->baseCol_] = YES;

    // 自身より手前側の許容範囲を作成
    border = MAX(0, (self->baseCol_ - self->range_));
    for (idx = (self->baseCol_ - 1); idx >= border; (idx)--) {
        // 上塗り禁止色を超えては許容範囲にしない
        if ([[self->palette_ palette:idx] isMask]) {
            break;
        }

        // 許容色にする
        self->acceptable_[idx] = YES;
    }

    // 自身より後ろ側の許容範囲を作成
    border = MIN(COLOR_MAX, (self->baseCol_ + self->range_));
    for (idx = (self->baseCol_ + 1); idx <= border; (idx)++) {
        // 上塗り禁止色を超えては許容範囲にしない
        if ([[self->palette_ palette:idx] isMask]) {
            break;
        }

        // 許容色にする
        self->acceptable_[idx] = YES;
    }

    return;
}


//
// 1ライン走査
//
//  Call
//    c             : 探索色(self->acceptable_[] を用いるのでこの引数は不使用)
//    l             : 左端
//    r             : 右端
//    v             : 垂直位置
//    pv            : 以前の垂直位置
//    bitmap_       : 描画対象 bitmap(基底 instance 変数)
//    acceptable_[] : 許容色(instance 変数)
//
//  Return
//    points_ : 点(instance 変数)
//
-(void)scanLine:(unsigned char)c
           left:(int)l
          right:(int)r
              v:(int)v
             pv:(int)pv
{
    unsigned int row;
    unsigned char *pixelmap;
    PoCoPaintPointBuffer *pos;

    // pixelmap の起点を取得
    row = [self->bitmap_ width];
    row += (row & 1);
    pixelmap = [self->bitmap_ pixelmap] + (row * v);

    // 走査
    while (l <= r) {
        // バッファを確保
        pos = [[PoCoPaintPointBuffer alloc] initWithVert:v
                                                withPrev:pv];

        // 左端を探す
#if 0
        for ( ; (l < r) && (!(self->acceptable_[pixelmap[l]])); (l)++) { }
#else   // 0
        for ( ; l < r; (l)++) {
            if (self->acceptable_[pixelmap[l]]) {
                break;
            }
        }
#endif  // 0
        if (!(self->acceptable_[pixelmap[l]])) {
            [pos release];
            break;
        }
        [pos setLeft:l];

        // 右端を探す
#if 0
        for ( ; (l <= r) && (self->acceptable_[pixelmap[l]]); (l)++) { }
#else   // 0
        for ( ; l <= r; (l)++) {
            if (!(self->acceptable_[pixelmap[l]])) {
                break;
            }
        }
#endif  // 0
        [pos setRight:(l - 1)];

        // 座標を登録
        [self->points_ addObject:pos];
        [pos release];
    }

    return;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp  : 描画対象 bitmap
//    plt  : 使用パレット
//    tile : 使用タイルパターン
//    pat  : 使用カラーパターン
//    rng  : 範囲
//
//  Return
//    function      : 実体
//    drect_        : 実描画範囲(instance 変数)
//    points_       : 点(instance 変数)
//    mask_         : 描画済みマスク(instance 変数)
//    range_        : 範囲(instance 変数)
//    baseCol_      : 基準色(instance 変数)
//    acceptable_[] : 許容色(instance 変数)
//
-(id)initWithPattern:(PoCoBitmap *)bmp
             palette:(PoCoPalette *)plt
                tile:(PoCoMonochromePattern *)tile
             pattern:(PoCoColorPattern *)pat
               range:(int)rng
{
//    DPRINT((@"[PoCoEditNormalPaint initWithPattern]\n"));

    // super class の初期化
    self = [super initWithPattern:bmp
                          palette:plt
                              pen:nil
                             tile:tile
                          pattern:pat];

    // 自身の初期化
    if (self != nil) {
        self->mask_ = nil;
        self->points_ = nil;
        self->drect_ = nil;
        self->range_ = rng;
        self->baseCol_ = 0;
        memset(self->acceptable_, 0x00, (COLOR_MAX * sizeof(BOOL)));

        // 資源確保
        self->points_ = [[NSMutableArray alloc] init];
        self->drect_ = [[PoCoRect alloc] initLeft:[bmp width]
                                          initTop:[bmp height]
                                        initRight:0
                                       initBottom:0];
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
//    drect_  : 実描画範囲(instance 変数)
//    points_ : 点(instance 変数)
//    mask_   : 描画済みマスク(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoEditNormalPaint dealloc]\n"));

    // 資源の解放
    [self->points_ removeAllObjects];
    [self->points_ release];
    [self->drect_ release];
    [self->mask_ release];
    self->points_ = nil;
    self->drect_ = nil;
    self->mask_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実描画範囲を取得
//
//  Call
//    drect_ : 実描画範囲(instance 変数)
//
//  Return
//    function : 実描画範囲
//
-(PoCoRect *)drect
{
    return self->drect_;
}


//
// 描画済みマスクを取得
//
//  Call
//    mask_ : 描画済みマスク(instance 変数)
//
//  Return
//    function : 描画済みマスク
//
-(PoCoBitmap *)mask
{
    return self->mask_;
}


//
// 実行
//
//  Call
//    p             : 始点
//    bitmap_       : 対象 bitmap(基底instance変数)
//    palette_      : パレット(基底instance変数)
//    tilePattern_  : タイルパターン(基底instance変数)
//    colorPattern_ : カラーパターン(基底instance変数)
//    points_       : 点(instance 変数)
//    range_        : 範囲(instance 変数)
//
//  Return
//    bitmap_  : 描画対象 bitmap(基底 instance 変数)
//    drect_   : 実描画範囲(instance 変数)
//    points_  : 点(instance 変数)
//    mask_    : 描画済みマスク(instance 変数)
//    baseCol_ : 基準色(instance 変数)
//
-(void)executeDraw:(PoCoPoint *)p
{
    unsigned char c;                    // 始点の色
    int l;                              // 左端
    int r;                              // 右端
    int h;                              // 描画範囲の走査用(水平のみ)
    int v;                              // 垂直位置
    unsigned int row;                   // row bytes
    unsigned int vJump;                 // 垂直位置までの変量
    unsigned char *pixelmap;            // 描画対象の pixelmap
    unsigned char *maskmap;             // 描画済みマスクの pixelmap
    PoCoBitmap *tile;                   // 描画範囲に合わせたタイルパターン
    unsigned char *tilePat;             // タイルパターンの pixelmap
    PoCoBitmap *col;                    // 描画範囲に合わせたカラーパターン
    unsigned char *colPat;              // カラーパターンの pixelmap
    PoCoRect *dr;                       // 描画範囲(画像全体)
    PoCoPaintPointBuffer *pos;          // 座標バッファ
    const int width = ([self->bitmap_ width] - 1);

    // 点を登録
    pos = [[PoCoPaintPointBuffer alloc] initWithVert:[p y]
                                            withPrev:[p y]];
    [pos setLeft:[p x]];
    [pos setRight:[p x]];
    [self->points_ addObject:pos];
    [pos release];

    // 塗装済みのマスクを生成
    self->mask_ = [[PoCoBitmap alloc] initWidth:[self->bitmap_ width]
                                     initHeight:[self->bitmap_ height]
                                   defaultColor:0];

    // パターン類の取得
    dr = [[PoCoRect alloc] initLeft:0
                            initTop:0
                          initRight:[self->bitmap_ width]
                         initBottom:[self->bitmap_ height]];
    tile = [self->tilePattern_ getPixelmap:dr];
    col = [self->colorPattern_ pixelmap:dr];
    [dr release];

    // row bytes 算出
    row = [self->bitmap_ width];
    row += (row & 1);

    // 始点の色を取得
    c = *([self->bitmap_ pixelmap] + (([p y] * row) + [p x]));
    self->baseCol_ = (int)(c);

    // 許容色リストを構築
    [self createAcceptableTable];

    // 描画
    do {
        // 座標を取得
        pos = [self->points_ objectAtIndex:0];
        v = [pos vert];
        vJump = (v * row);

        maskmap = ([self->mask_ pixelmap] + vJump);
        if (maskmap[[pos left]] == 0x00) {
            pixelmap = ([self->bitmap_ pixelmap] + vJump);

            // 左端を探す
            l = [pos left];
            for ( ; (l > 0) && (self->acceptable_[pixelmap[l - 1]]); (l)--) { }

            // 右端を探す
            r = [pos right];
            for ( ; (r < width) && (self->acceptable_[pixelmap[r + 1]]); (r)++) { }

            // 実描画範囲を更新
            if (l < [self->drect_ left]) {
                [self->drect_ setLeft:l];
            }
            if ([self->drect_ right] <= r) {
                [self->drect_ setRight:(r + 1)];
            }
            if (v < [self->drect_ top]) {
                [self->drect_ setTop:v];
            }
            if ([self->drect_ bottom] <= v) {
                [self->drect_ setBottom:(v + 1)];
            }

            // 間を描画
            tilePat = [tile pixelmap] + vJump;
            colPat = [col pixelmap] + vJump;
            for (h = l; h <= r; h++) {
                if (tilePat[h] == 0) {
                    // タイルパターンで描画対象外
                    ;
                } else if ([[self->palette_ palette:colPat[h]] noDropper]) {
                    // 塗装色が使用禁止(吸い取り禁止)
                    ;
                } else if ([[self->palette_ palette:pixelmap[h]] isMask]) {
                    // 描画対象が上塗り禁止
                    ;
                } else {
                    // 描画実行
                    pixelmap[h] = colPat[h];
                }

                // 描画済みにする
                maskmap[h] = 0xff;
            }

            // 上の行を走査
            v = ([pos vert] - 1);
            if (v >= 0) {
                if ([pos prev] == v) {
                    [self scanLine:c
                              left:l
                             right:([pos left] - 1)
                                 v:v
                                pv:(v + 1)];
                    [self scanLine:c
                              left:([pos right] + 1)
                             right:r
                                 v:v
                                pv:(v + 1)];
                } else {
                    [self scanLine:c
                              left:l
                             right:r
                                 v:v
                                pv:(v + 1)];
                }
            }

            // 下の行を走査
            v = ([pos vert] + 1);
            if (v < [self->bitmap_ height]) {
                if ([pos prev] == v) {
                    [self scanLine:c
                              left:l
                             right:([pos left] - 1)
                                 v:v
                                pv:(v - 1)];
                    [self scanLine:c
                              left:([pos right] + 1)
                             right:r
                                 v:v
                                pv:(v - 1)];
                } else {
                    [self scanLine:c
                              left:l
                             right:r
                                 v:v
                                pv:(v - 1)];
                }
            }
        }
        [self->points_ removeObjectAtIndex:0];
    } while ([self->points_ count] > 0);
    [tile release];
    [col release];

    return;
}

@end




// ============================================================================
@implementation PoCoEditNormalBorderPaint

// --------------------------------------------------------- instance - private
//
// 許容色リストを構築
//
//  Call
//    border_ : 境界色(instance 変数)
//
//  Return
//    acceptable_[] : 許容色(instance 変数)
//
-(void)createAcceptableTable
{
    // 全て YES にする
    memset(self->acceptable_, 0xff, (COLOR_MAX * sizeof(BOOL)));

    // 境界色だけ許容しない
    self->acceptable_[[self->border_ num]] = NO;

    return;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp  : 描画対象 bitmap
//    plt  : 使用パレット
//    tile : 使用タイルパターン
//    pat  : 使用カラーパターン
//    bcol : 境界色
//
//  Return
//    function : 実体
//    border_  : 境界色(instance 変数)
//
-(id)initWithPattern:(PoCoBitmap *)bmp
             palette:(PoCoPalette *)plt
                tile:(PoCoMonochromePattern *)tile
             pattern:(PoCoColorPattern *)pat
              border:(PoCoSelColor *)bcol
{
//    DPRINT((@"[PoCoEditNormalBorderPaint initWithPattern]\n"));

    // super class の初期化
    self = [super initWithPattern:bmp
                          palette:plt
                             tile:tile
                          pattern:pat
                            range:0];

    // 自身の初期化
    if (self != nil) {
        self->border_ = bcol;
        [self->border_ retain];
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
//    border_ : 境界色(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoEditNormalBorderPaint dealloc]\n"));

    // 資源の解放
    [self->border_ release];
    self->border_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


#if 0   // most simple flood fill algorithm as principal, so that no longer use.
//
// 実行
//
//  Call
//    p             : 始点
//    bitmap_       : 対象 bitmap(基底instance変数)
//    palette_      : パレット(基底instance変数)
//    tilePattern_  : タイルパターン(基底instance変数)
//    colorPattern_ : カラーパターン(基底instance変数)
//    points_       : 点(基底 instance 変数)
//    border_       : 境界色(instance 変数)
//
//  Return
//    bitmap_ : 描画対象 bitmap(基底 instance 変数)
//    drect_  : 実描画範囲(基底 instance 変数)
//    points_ : 点(基底 instance 変数)
//    mask_   : 描画済みマスク(基底 instance 変数)
//
-(void)executeDraw:(PoCoPoint *)p
{
    unsigned int row;                   // row bytes
    unsigned int idx;                   // 位置までの変量
    unsigned char *pixelmap;            // 描画対象の pixelmap
    unsigned char *maskmap;             // 描画済みマスクの pixelmap
    PoCoBitmap *tile;                   // 描画範囲に合わせたタイルパターン
    unsigned char *tilePat;             // タイルパターンの pixelmap
    PoCoBitmap *col;                    // 描画範囲に合わせたカラーパターン
    unsigned char *colPat;              // カラーパターンの pixelmap
    PoCoRect *dr;                       // 描画範囲(画像全体)
    PoCoPoint *pos;                     // 座標

    // 境界色にパターン・背面は使えない
    if (([self->border_ isPattern]) ||
        ([self->border_ isUnder])) {
        goto EXIT;
    }

    // 点を登録
    pos = [[PoCoPoint alloc] initX:[p x]
                             initY:[p y]];
    [self->points_ addObject:pos];
    [pos release];

    // 塗装済みのマスクを生成
    self->mask_ = [[PoCoBitmap alloc] initWidth:[self->bitmap_ width]
                                     initHeight:[self->bitmap_ height]
                                   defaultColor:0];

    // パターン類の取得
    dr = [[PoCoRect alloc] initLeft:0
                            initTop:0
                          initRight:[self->bitmap_ width]
                         initBottom:[self->bitmap_ height]];
    tile = [self->tilePattern_ getPixelmap:dr];
    col = [self->colorPattern_ pixelmap:dr];
    [dr release];
    maskmap = [self->mask_ pixelmap];
    pixelmap = [self->bitmap_ pixelmap];
    tilePat = [tile pixelmap];
    colPat = [col pixelmap];

    // row bytes 算出
    row = [self->bitmap_ width];
    row += (row & 1);

    // 描画
    do {
        // 座標を取得
        p = [self->points_ objectAtIndex:0];
        if (([p x] >= 0) &&
            ([p y] >= 0) &&
            ([p x] < [self->bitmap_ width]) &&
            ([p y] < [self->bitmap_ height])) {
            idx = (([p y] * row) + [p x]);
            if ((maskmap[idx] == 0x00) &&
                (pixelmap[idx] != [self->border_ num])) {
                // 実描画範囲を更新
                if ([p x] < [self->drect_ left]) {
                    [self->drect_ setLeft:[p x]];
                }
                if ([self->drect_ right] <= [p x]) {
                    [self->drect_ setRight:([p x] + 1)];
                }
                if ([p y] < [self->drect_ top]) {
                    [self->drect_ setTop:[p y]];
                }
                if ([self->drect_ bottom] <= [p y]) {
                    [self->drect_ setBottom:([p y] + 1)];
                }

                // 描画
                if (tilePat[idx] == 0) {
                    // タイルパターンで描画対象外
                    ;
                } else if ([[self->palette_ palette:colPat[idx]] noDropper]) {
                    // 塗装色が使用禁止(吸い取り禁止)
                    ;
                } else if ([[self->palette_ palette:pixelmap[idx]] isMask]) {
                    // 描画対象が上塗り禁止
                    ;
                } else {
                    // 描画実行
                    pixelmap[idx] = colPat[idx];
                }

                // 描画済みにする
                maskmap[idx] = 0xff;

                // 周辺4点を追加
                pos = [[PoCoPoint alloc] initX:([p x] - 1)
                                         initY:([p y]    )];
                [self->points_ addObject:pos];
                [pos release];
                pos = [[PoCoPoint alloc] initX:([p x] + 1)
                                         initY:([p y]    )];
                [self->points_ addObject:pos];
                [pos release];
                pos = [[PoCoPoint alloc] initX:([p x]    )
                                         initY:([p y] - 1)];
                [self->points_ addObject:pos];
                [pos release];
                pos = [[PoCoPoint alloc] initX:([p x]    )
                                         initY:([p y] + 1)];
                [self->points_ addObject:pos];
                [pos release];
            }
        }
        [self->points_ removeObjectAtIndex:0];
    } while ([self->points_ count] > 0);
    [tile release];
    [col release];

EXIT:
    return;
}
#endif  // 0

@end
