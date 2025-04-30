//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 均一濃度 - 領域塗りつぶし
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditUniformedDensityFill.h"

#import "PoCoColorMixer.h"

// ========================================================== PoCoThreadCounter

// ------------------------------------------------------------------ interface
@interface PoCoThreadCounter : NSObject
{
    int count_;                         // 数
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// count
-(void)up;                              // 足す
-(void)down;                            // 引く
-(int)count;                            // 数

@end


// ------------------------------------------------------------------ implement
@implementation PoCoThreadCounter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function : 実体
//    count_   : 数(instance 変数)
//
-(id)init
{
    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->count_ = 0;
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
    // super class の解放
    [super dealloc];

    return;
}


//
// 足す
//
//  Call
//    None
//
//  Return
//    count_ : 数(instance 変数)
//
-(void)up
{
    (self->count_)++;

    return;
}


//
// 引く
//
//  Call
//    None
//
//  Return
//    count_ : 数(instance 変数)
//
-(void)down
{
    (self->count_)--;

    return;
}


//
// 数
//
//  Call
//    count_ : 数(instance 変数)
//
//  Return
//    function : 数
//
-(int)count
{
    return self->count_;
}

@end




// ================================================= PoCoUniformedDensityThread

// ------------------------------------------------------------------ interface
@interface PoCoUniformedDensityThread : NSObject
{
    PoCoPoint *pos_;                    // 描画位置
    PoCoRect *trueRect_;                // 描画範囲(画像範囲外含む)
    PoCoRect *drawRect_;                // 描画範囲(画像範囲外含む)
    unsigned char *dstBitmap_;          // 描画対象
    const unsigned char *patBitmap_;    // カラーパターン
    const unsigned char *maskBitmap_;   // 形状
    PoCoColorMode colMode_;             // 色演算モード
    PoCoPalette *palette_;              // 使用パレット
    int density_;                       // 頻度(0.1%単位)
    PoCoColorBuffer *colorBuffer_;      // 色保持情報
    PoCoThreadCounter *counter_;        // counter
}

// initialize
-(id)initStartPos:(PoCoPoint *)p
     withTrueRect:(PoCoRect *)tr
     withDrawRect:(PoCoRect *)dr
        dstBitmap:(unsigned char *)bbmp
        patBitmap:(const unsigned char *)pbmp
       maskBitmap:(const unsigned char *)mbmp
          colMode:(PoCoColorMode)cmode
          palette:(PoCoPalette *)plt
          density:(int)den
           buffer:(PoCoColorBuffer *)buf
          counter:(PoCoThreadCounter *)cnt;

// deallocate
-(void)dealloc;

// 実行
-(void)execute;

@end


// ------------------------------------------------------------------ implement
@implementation PoCoUniformedDensityThread

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    p     : 描画位置
//    trect : 描画範囲(画像範囲外含む)
//    drect : 描画範囲(画像範囲内のみ)
//    bbmp  : 描画対象
//    pbmp  : カラーパターン
//    mbmp  : 形状
//    cmode : 色演算モード
//    plt   : 使用パレット
//    den   : 頻度(0.1%単位)
//    buf   : 色保持情報
//    cnt   : counter
//
//  Return
//    function     : 実体
//    pos_         : 描画位置(instance 変数)
//    trueRect_    : 描画範囲(画像範囲外含む)(instance 変数)
//    drawRect_    : 描画範囲(画像範囲内のみ)(instance 変数)
//    dstBitmap_   : 描画対象(instance 変数)
//    patBitmap_   : カラーパターン(instance 変数)
//    maskBitmap_  : 形状(instance 変数)
//    colMode_     : 色演算モード(instance 変数)
//    palette_     : 使用パレット(instance 変数)
//    density_     : 頻度(0.1%単位)(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//    counter_     : counter(instance 変数)
//
-(id)initStartPos:(PoCoPoint *)p
     withTrueRect:(PoCoRect *)tr
     withDrawRect:(PoCoRect *)dr
        dstBitmap:(unsigned char *)bbmp
        patBitmap:(const unsigned char *)pbmp
       maskBitmap:(const unsigned char *)mbmp
          colMode:(PoCoColorMode)cmode
          palette:(PoCoPalette *)plt
          density:(int)den
           buffer:(PoCoColorBuffer *)buf
          counter:(PoCoThreadCounter *)cnt
{
    DPRINT((@"[PoCoUniformedDensityThread init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->trueRect_ = tr;
        self->drawRect_ = dr;
        self->dstBitmap_ = bbmp;
        self->patBitmap_ = pbmp;
        self->maskBitmap_ = mbmp;
        self->colMode_ = cmode;
        self->palette_ = plt;
        self->density_ = den;
        self->colorBuffer_ = buf;
        self->counter_ = cnt;

        // 描画位置は複製
        self->pos_ = [[PoCoPoint alloc] initX:[p x]
                                        initY:[p y]];

        // それぞれ retain しておく
        [self->trueRect_ retain];
        [self->drawRect_ retain];
        [self->palette_ retain];
        [self->colorBuffer_ retain];
        [self->counter_ retain];

        // 計数
        [self->counter_ up];
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
//    pos_         : 描画位置(instance 変数)
//    trueRect_    : 描画範囲(画像範囲外含む)(instance 変数)
//    drawRect_    : 描画範囲(画像範囲内のみ)(instance 変数)
//    palette_     : 使用パレット(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//    counter_     : counter(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoUniformedDensityThread dealloc]\n"));

    // 資源を解放
    [self->pos_ release];
    [self->trueRect_ release];
    [self->drawRect_ release];
    [self->palette_ release];
    [self->colorBuffer_ release];
    [self->counter_ release];
    self->pos_ = nil;
    self->trueRect_ = nil;
    self->drawRect_ = nil;
    self->palette_ = nil;
    self->colorBuffer_ = nil;
    self->counter_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//
//  Call
//    pos_         : 描画位置(instance 変数)
//    trueRect_    : 描画範囲(画像範囲外含む)(instance 変数)
//    drawRect_    : 描画範囲(画像範囲内のみ)(instance 変数)
//    dstBitmap_   : 描画対象(instance 変数)
//    patBitmap_   : カラーパターン(instance 変数)
//    maskBitmap_  : 形状(instance 変数)
//    colMode_     : 色演算モード(instance 変数)
//    palette_     : 使用パレット(instance 変数)
//    density_     : 頻度(0.1%単位)(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//
//  Return
//    dstBitmap_ : 描画対象(instance 変数)
//    counter_   : counter(instance 変数)
//
-(void)execute
{
    for ([self->pos_ setX:[self->trueRect_ left]];
         [self->pos_ x] < [self->trueRect_ right];
         [self->pos_ moveX:1]) {
        if (([self->drawRect_ isPointInRect:self->pos_]) &&
            (*(self->maskBitmap_) != 0) &&
            (!([[self->palette_ palette:*(self->dstBitmap_)] isMask]))) {
            *(self->dstBitmap_) = [PoCoColorMixer calcColor:self->palette_
                                                    colMode:self->colMode_
                                                   density2:self->density_
                                                     color1:*(self->dstBitmap_)
                                                     color2:*(self->patBitmap_)
                                                     buffer:self->colorBuffer_];
        }

        // 次へ
        (self->dstBitmap_)++;
        (self->patBitmap_)++;
        (self->maskBitmap_)++;
    }

    // 抜ける
    [self->counter_ down];
    [NSThread exit];

    return;
}

@end




// ============================================================================
@implementation PoCoEditUniformedDensityFill

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp   : 編集対象
//    cmode : 色演算モード
//    plt   : 使用パレット
//    pat   : 使用カラーパターン
//    buf   : 色保持情報
//    den   : 濃度
//
//  Return
//    function     : 実体
//    bitmap_      : 編集対象(instance 変数)
//    colMode_     : 色演算モード(instance 変数)
//    palette_     : 使用パレット(instance 変数)
//    pattern_     : 使用カラーパターン(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//    density_     : 頻度(0.1%単位)(instance 変数)
//
-(id)init:(PoCoBitmap *)bmp
  colMode:(PoCoColorMode)cmode
  palette:(PoCoPalette *)plt
  pattern:(PoCoColorPattern *)pat
   buffer:(PoCoColorBuffer *)buf
  density:(int)den
{
    DPRINT((@"[PoCoEditUniformedDensityFill init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->bitmap_ = bmp;
        self->colMode_ = cmode;
        self->palette_ = plt;
        self->pattern_ = pat;
        self->density_ = den;
        self->colorBuffer_ = buf;

        // それぞれ retain しておく
        [self->bitmap_ retain];
        [self->palette_ retain];
        [self->pattern_ retain];
        [self->colorBuffer_ retain];
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
//    pattern_     : 使用カラーパターン(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoEditUniformedDensityFill dealloc]\n"));

    // 資源の解放
    [self->bitmap_ release];
    [self->palette_ release];
    [self->pattern_ release];
    [self->colorBuffer_ release];
    self->bitmap_ = nil;
    self->palette_ = nil;
    self->pattern_ = nil;
    self->colorBuffer_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 更新
//
//  Call
//    d   : 頻度(0.1%単位)
//    bmp : 編集対象
//
//  Return
//    density_ : 頻度(0.1%単位)(instance 変数)
//    bitmap_  : 編集対象(instance 変数)
//
-(void)replaceDensity:(int)d
           withBitmap:(PoCoBitmap *)bmp
{
    // 以前の分を忘れる
    [self->bitmap_ release];

    // 差し替え
    self->density_ = d;
    self->bitmap_ = bmp;
    [self->bitmap_ retain];

    return;
}


//
// 実行
//
//  Call
//    mask     : 形状
//    tile     : タイルパターン
//    trueRect : 描画範囲(画像範囲外含む)
//    drawRect : 描画範囲(画像範囲内のみ)
//    bitmap_  : 編集対象(instance 変数)
//    palette_ : 使用パレット(instance 変数)
//    pattern_ : 使用カラーパターン(instance 変数)
//    density_ : 頻度(0.1%単位)(instance 変数)
//
//  Return
//    bitmap_ : 編集対象(instance 変数)
//
-(void)executeDraw:(PoCoBitmap *)mask
          withTile:(PoCoMonochromePattern *)tile
      withTrueRect:(PoCoRect *)trueRect
      withDrawRect:(PoCoRect *)drawRect
#if 0
{
    PoCoBitmap *patBitmap;              // カラーパターン(描画範囲に調整済み)
    PoCoRect *tr;
    PoCoRect *dr;
    PoCoPoint *p;
    int brow;                           // 描画対象の rowbyets
    int prow;                           // カラーパターンの rowbytes
    int mrow;                           // 形状の rowbytes
    unsigned char *bbmp;                // 描画対象の走査用
    const unsigned char *pbmp;          // カラーパターンの走査用
    const unsigned char *mbmp;          // 形状の走査用
    BOOL flag;
    int l;
    int cnt;
    id *scan;
    id *thread;
    PoCoThreadCounter *counter;

    tr = nil;
    dr = nil;
    patBitmap = nil;
    scan = NULL;
    thread = NULL;
    counter = nil;

    // 描画領域なし
    if ([drawRect empty]) {
        goto EXIT;
    }

    // half-open property にするので右下に +1
    tr = [[PoCoRect alloc] initLeft:[trueRect left]
                            initTop:[trueRect top]
                          initRight:([trueRect right] + 1)
                         initBottom:([trueRect bottom] + 1)];
    dr = [[PoCoRect alloc] initLeft:[drawRect left]
                            initTop:[drawRect top]
                          initRight:([drawRect right] + 1)
                         initBottom:([drawRect bottom] + 1)];
    if ([self->bitmap_ width] < [dr right]) {
        [dr setRight:[self->bitmap_ width]];
    }
    if ([self->bitmap_ height] < [dr bottom]) {
        [dr setBottom:[self->bitmap_ height]];
    }

    // 描画開始
    patBitmap = [self->pattern_ pixelmap:tr];

    // 各種値の算出
    brow = ([self->bitmap_ width] + ([self->bitmap_ width] & 1));
    prow = ([patBitmap width]     + ([patBitmap width]     & 1));
    mrow = ([mask width]          + ([mask width]          & 1));

    // 各種走査用ビットマップを取得
    bbmp = [self->bitmap_ pixelmap] + (([tr top] * brow) + [tr left]);
    pbmp = [patBitmap pixelmap];
    mbmp = [mask pixelmap];

    // 資源を確保
    cnt = [tr height];
    if (cnt <= 0) {
        goto EXIT;
    }
    scan = (id *)(calloc(cnt, sizeof(id)));
    thread = (id *)(calloc(cnt, sizeof(id)));
    if ((scan == NULL) || (thread == NULL)) {
        goto EXIT;
    }
    counter = [[PoCoThreadCounter alloc] init];

    // 走査/描画(垂直走査をすべて thread にする)
    l = 0;
    p = [[PoCoPoint alloc] init];
    for ([p setY:[tr top]]; [p y] < [tr bottom]; [p moveY:1]) {
        // 水平走査
        scan[l] = [[PoCoUniformedDensityThread alloc]
                      initStartPos:p
                      withTrueRect:tr
                      withDrawRect:dr
                         dstBitmap:bbmp
                         patBitmap:pbmp
                        maskBitmap:mbmp
                           colMode:self->colMode_
                           palette:self->palette_
                           density:self->density_
                            buffer:self->colorBuffer_
                           counter:counter];
        thread[l] = [[NSThread alloc] initWithTarget:scan[l]
                                            selector:@selector(execute)
                                              object:nil];
        [thread[l] start];

        // 次へ
        bbmp += brow;
        pbmp += prow;
        mbmp += mrow;
        (l)++;

        // thread 本数を抑制
        while ([counter count] >= 2) {
            [NSThread sleepForTimeInterval:0.001];
        }
    }
    [p release];

    // すべての thread が終わるのを待つ
    [NSThread sleepForTimeInterval:0.001];
    do {
        flag = NO;
        for (l = 0; l < cnt; (l)++) {
            if (thread[l] == nil) {
                // 既に終わっている
                ;
            } else if ([thread[l] isFinished]) {
                // 終了したので解放
                [thread[l] release];
                [scan[l] release];
                thread[l] = nil;
                scan[l] = nil;
            } else {
                // 実行中
                flag = YES;
            }
        }
        [NSThread sleepForTimeInterval:0.001];
    } while (flag);

EXIT:
    if (scan != NULL) {
        free(scan);
    }
    if (thread != NULL) {
        free(thread);
    }
    [counter release];
    [patBitmap release];
    [tr release];
    [dr release];
    return;
}
#else   // 1
{
    PoCoBitmap *patBitmap;              // カラーパターン(描画範囲に調整済み)
    PoCoRect *tr;
    PoCoRect *dr;
    PoCoPoint *p;
    int brow;                           // 描画対象の rowbyets
    int prow;                           // カラーパターンの rowbytes
    int mrow;                           // 形状の rowbytes
    int bskip;                          // 描画対象の次の行までのアキ
    int pskip;                          // カラーパターンの次の行までのアキ
    int mskip;                          // 形状の次の行までのアキ
    unsigned char *bbmp;                // 描画対象の走査用
    const unsigned char *pbmp;          // カラーパターンの走査用
    const unsigned char *mbmp;          // 形状の走査用

    tr = nil;
    dr = nil;
    patBitmap = nil;

    // 描画領域なし
    if ([drawRect empty]) {
        goto EXIT;
    }

    // half-open property にするので右下に +1
    tr = [[PoCoRect alloc] initLeft:[trueRect left]
                            initTop:[trueRect top]
                          initRight:([trueRect right] + 1)
                         initBottom:([trueRect bottom] + 1)];
    dr = [[PoCoRect alloc] initLeft:[drawRect left]
                            initTop:[drawRect top]
                          initRight:([drawRect right] + 1)
                         initBottom:([drawRect bottom] + 1)];
    if ([self->bitmap_ width] < [dr right]) {
        [dr setRight:[self->bitmap_ width]];
    }
    if ([self->bitmap_ height] < [dr bottom]) {
        [dr setBottom:[self->bitmap_ height]];
    }

    // 描画開始
    patBitmap = [self->pattern_ pixelmap:tr];

    // 各種値の算出
    brow = ([self->bitmap_ width] + ([self->bitmap_ width] & 1));
    prow = ([patBitmap width]     + ([patBitmap width]     & 1));
    mrow = ([mask width]          + ([mask width]          & 1));
    bskip = (brow - [tr width]);
    pskip = (prow - [tr width]);
    mskip = (mrow - [tr width]);

    // 各種走査用ビットマップを取得
    bbmp = [self->bitmap_ pixelmap] + (([tr top] * brow) + [tr left]);
    pbmp = [patBitmap pixelmap];
    mbmp = [mask pixelmap];

    // 走査/描画
    p = [[PoCoPoint alloc] init];
    for ([p setY:[tr top]]; [p y] < [tr bottom]; [p moveY:1]) {
        for ([p setX:[tr left]]; [p x] < [tr right]; [p moveX:1]) {
            if (([dr isPointInRect:p]) &&
                (*(mbmp) != 0) &&
                (!([[self->palette_ palette:*(bbmp)] isMask]))) {
                *(bbmp) = [PoCoColorMixer calcColor:self->palette_
                                            colMode:self->colMode_
                                           density2:self->density_
                                             color1:*(bbmp)
                                             color2:*(pbmp)
                                             buffer:self->colorBuffer_];
            }

            // 次へ
            (bbmp)++;
            (pbmp)++;
            (mbmp)++;
        }

        // 次へ
        bbmp += bskip;
        pbmp += pskip;
        mbmp += mskip;
    }
    [p release];

EXIT:
    [patBitmap release];
    [tr release];
    [dr release];
    return;
}
#endif  // 1

@end
