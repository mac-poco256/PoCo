//
//	Pelistina on Cocoa - PoCo -
//	layer 宣言
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import "PoCoLayer.h"

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"

#import "PoCoPalette.h"
#import "PoCoPNG.h"
#import "PoCoZlib.h"

// 内部定数
#if !(MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)
static const unsigned int SAMPLE_SIZE = 48;
static const unsigned int SAMPLE_SIZE_4X = (48 * 4);
#endif  // !(MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)

// ============================================================================
@implementation PoCoBitmap

// --------------------------------------------------------- instance - private
//
// 伸張
//
//  Call
//    buffer : 伸張先
//    png    : PNG Decoder
//    size_  : 確保容量 (instance 変数)
//
//  Return
//    function : YES : 成功
//               NO  : 失敗
//    buffer   : 伸張結果
//
-(BOOL)inflateChunkData:(unsigned char *)buffer
         withPNGDecoder:(PoCoPNGDecoder *)png
{
    BOOL result;
    unsigned int idx;                   // DI-reg.
    PoCoWErr rv;
    PoCoZlibInflate *zlib;

    DPRINT((@"[PoCoBitmap inflateChunkData]\n"));

    result = NO;
    idx = 0;
    zlib = nil;

    // 伸張
    zlib = [[PoCoZlibInflate alloc] init];
    if (zlib == nil) {
        goto EXIT;
    }
    rv = [zlib appendBytes:[png bytes]
                    length:[png length]];
    if (rv < ER_OK) {
        DPRINT((@"[zlib appendBytes: length:] : %d(0x%08x)\n", rv, rv));
        goto EXIT;
    } else if (self->size_ < [zlib length]) {
        DPRINT((@"data overflow\n"));
        goto EXIT;
    }
    [png readChunk:NULL
            length:[png length]
            readed:NULL];
    memcpy(&(buffer[idx]), [zlib bytes], [zlib length]);
    idx += [zlib length];
    [zlib clearBuffer:[zlib length]];
    while (rv == 1) {
        rv = [zlib appendBytes:NULL
                        length:0];
        if (rv < ER_OK) {
            DPRINT((@"[zlib appendBytes: length:] : %d(0x%08x)\n", rv, rv));
            goto EXIT;
        } else if (self->size_ < (idx + [zlib length])) {
            DPRINT((@"data overflow\n"));
            goto EXIT;
        }
        memcpy(&(buffer[idx]), [zlib bytes], [zlib length]);
        idx += [zlib length];
        [zlib clearBuffer:[zlib length]];
    }
    do {
        rv = [zlib finishData];
        if (rv < ER_OK) {
            DPRINT((@"[zlib finishData] : %d(0x%08x)\n", rv, rv));
            goto EXIT;
        } else if (self->size_ < (idx + [zlib length])) {
            DPRINT((@"data overflow\n"));
            goto EXIT;
        }
        memcpy(&(buffer[idx]), [zlib bytes], [zlib length]);
        idx += [zlib length];
        [zlib clearBuffer:[zlib length]];
    } while (rv == 1);

    // 正常終了
    result = YES;

EXIT:
    [zlib release];
    return result;
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
    return [self initWidth:0
                initHeight:0
              defaultColor:0];
}


//
// initialize(指定イニシャライザ)
//  色、領域指定つき
//
//  Call
//    w : 幅
//    h : 高さ
//    c : 色
//
//  Return
//    function : 実体
//    width_   : 幅(instance 変数)
//    height_  : 高さ(instance 変数)
//    size_    : 確保容量(instance 変数)
//    bitmap_  : pixel map(instance 変数)
//
-(id)initWidth:(int)w
    initHeight:(int)h
  defaultColor:(unsigned char)c
{
//    DPRINT((@"[PoCoBitmap initWidth:%d initHeight:%d defaultColor:%d]\n", w, h, c));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->width_ = w;
        self->height_ = h;
        self->size_ = ((w + (w & 1)) * h);  // 常に偶数
        self->bitmap_ = NULL;
        if (self->size_ > 0) {
            self->bitmap_ = (unsigned char *)(malloc(self->size_));
            if (self->bitmap_ == NULL) {
                DPRINT((@"memory allocation error.\n"));
                [self release];
                self = nil;
                goto EXIT;
            }

            // 選択中の色で塗りつぶしておく
            memset(self->bitmap_, c, self->size_);
        }
    }

EXIT:
    return self;
}


//
// initialize(複製)
//
//  Call
//    zone    : zone(api 変数)
//    width_  : 幅(instance 変数)
//    height_ : 高さ(instance 変数)
//    bitmap_ : pixel map(instance 変数)
//
//  Return
//    function : 実体(複製した実体)
//
-(id)copyWithZone:(NSZone *)zone
{
    PoCoBitmap *copy;

//    DPRINT((@"[PoCoBitmap copyWithZone:0x%x]\n", (unsigned int)(zone)));

    // 複製を生成
    copy = [[[self class] allocWithZone:zone] initWidth:self->width_
                                             initHeight:self->height_
                                           defaultColor:0];

    // 複製先の内容を設定
    if (copy != nil) {
        memcpy(copy->bitmap_, self->bitmap_, copy->size_);
    }

    return copy;
}


//
// deallocate
//
//  Call
//    None
//
//  Return
//    width_  : 幅(instance 変数)
//    height_ : 高さ(instance 変数)
//    size_   : 確保容量(instance 変数)
//    bitmap_ : pixel map(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoBitmap dealloc]\n"));

    if (self->bitmap_ != NULL) {
        free(self->bitmap_);
    }
    self->width_ = 0;
    self->height_ = 0;
    self->size_ = 0;
    self->bitmap_ = NULL;

    // super class を解放
    [super dealloc];

    return;
}


//
// 幅の取得
//
//  Call
//    width_ : 幅(instance 変数)
//
//  Return
//    function : 幅
//
-(int)width
{
    return self->width_;
}


//
// 高さの取得
//
//  Call
//    height_ : 高さ(instance 変数)
//
//  Return
//    function : 高さ
//
-(int)height
{
    return self->height_;
}


//
// bitmap の参照取得
//  得られた pointer を free() しないこと
//
//  Call
//    None
//
//  Return
//    function : pixel map
//
-(unsigned char *)pixelmap
{
    return self->bitmap_;
}


//
// bitmap の取得
//  完全取得
//
//  Call
//    size_   : 確保容量(instance 変数)
//    bitmap_ : pixel map(instance 変数)
//
//  Return
//    function : pixel map
//
-(unsigned char *)getBitmap
{
    unsigned char *ptr;

    ptr = NULL;

    // 領域確保
    ptr = (unsigned char *)(malloc(self->size_));
    if (ptr == NULL) {
        DPRINT((@"memory allocation error.\n"));
        ;
    } else {
        // 単純複写
        memcpy(ptr, self->bitmap_, self->size_);
    }

    return ptr;
}


//
// 取得
//  部分取得
//
//  Call
//    r       : 取得範囲
//    width_  : 幅(instance 変数)
//    height_ : 高さ(instance 変数)
//    bitmap_ : pixel map(instance 変数)
//
//  Return
//    function : != nil : 取得画像
//               == nil : 取得画像なし
//
-(PoCoBitmap *)getBitmap:(const PoCoRect *)r
{
    PoCoBitmap *bmp;
    int x;
    int y;
    int xe;
    int ye;
    unsigned char *sp;                  // SI-reg.(bitmap_ の走査用)
    unsigned char *dp;                  // DI-reg.(bmp の走査用)
    const size_t sstep = (self->width_ + (self->width_ & 1)); // SI-reg. の更新量
    size_t dstep;                       // DI-reg. の更新量(byte 単位)
    const int rl = [r left];
    const int rt = [r top];
    const int rr = [r right];
    const int rb = [r bottom];

    bmp = nil;

    // 取得範囲の算出
    if ((rl >= self->width_) || (rt >= self->height_)) {
        // lefttop が範囲外
        ;
    } else if ((rr < 0) || (rb < 0)) {
        // rightbot が範囲外
        ;
    } else {
        // 原点の算出
        x = 0;
        y = 0;
        sp = self->bitmap_;
        if (rl > 0) {
            x = rl;
            sp += rl;
        }
        if (rt > 0) {
            y = rt;
            sp += (sstep * y);
        }

        // 転送終端の算出
        xe = ((rr > self->width_)  ? self->width_  : rr);
        ye = ((rb > self->height_) ? self->height_ : rb);

        // PoCoBitmap を生成
        bmp = [[PoCoBitmap alloc] initWidth:(xe - x)
                                 initHeight:(ye - y)
                               defaultColor:0];
        if (bmp != nil) {
            // bmp->bitmap_ の内容を設定
            ye -= y;
            dp = bmp->bitmap_;
            dstep = (bmp->width_ + (bmp->width_ & 1));
            do {
                memcpy(dp, sp, bmp->width_);

                // 各 index-reg の更新
                sp += sstep;
                dp += dstep;
                (ye)--;
            } while (ye != 0);
        }
    }

    return bmp;
}


//
// 設定
//  領域がはみ出していても拡張とかはしないで clip する
//
//  Call
//    bmp     : 設定内容
//    r       : bmp の領域(lefttopは複写先原点)
//    width_  : 幅(instance 変数)
//    height_ : 高さ(instance 変数)
//
//  Return
//    bitmap_ : pixel map(instance 変数)
//
-(void)setBitmap:(const unsigned char *)bmp
        withRect:(const PoCoRect *)r
{
    int y;                              // 転送行
    const unsigned char *sp;            // SI-reg.(bmp 側走査)
    unsigned char *dp;                  // DI-reg.(bitmap_ 側走査用)
    size_t csize;                       // 1行あたりの複写量(byte 単位)
    size_t sstep;                       // SI-reg. の更新量(byte 単位)
    const size_t dstep = (self->width_ + (self->width_ & 1)); // DI-reg. の更新量
    const int rx = [r left];
    const int ry = [r top];
    const int rxe = [r right];
    const int rye = [r bottom];
    const int rw = [r width];

    if ((rx >= self->width_) || (ry >= self->height_)) {
        // lefttop がすでに範囲外
        ;
    } else if ((rxe < 0) || (rye < 0)) {
        // rightbot が範囲外
        ;
    } else {
        // 更新量の算出
        sstep = (rw + (rw & 1));

        // 複写原点の算出
        sp = bmp;
        dp = self->bitmap_;
        if (rx < 0) {
            sp -= rx;
        } else if (rx > 0) {
            dp += rx;
        }
        if (ry < 0) {
            sp += (sstep * -(ry));
        } else if (ry > 0) {
            dp += (dstep * ry);
        }

        // 転送幅の算出
        csize = rw;
        if (rx < 0) {
            csize += rx;
        } else if (csize > (self->width_ - rx)) {
            csize = (self->width_ - rx);
        }

        // 転送行範囲の算出
        y = ((rye > self->height_) ? self->height_ : rye);
        if (ry > 0) {
            y -= ry;
        }

        // 行単位で複写
        do {
            memcpy(dp, sp, csize);

            // 各 index-reg の更新
            sp += sstep;
            dp += dstep;
            (y)--;
        } while (y != 0);
    }

    return;
}


//
// 変形
//  resize にともなう bitmap の clip とかはしない
//
//  Call
//    w     : 幅(dot 単位)
//    h     : 高さ(dot 単位)
//    size_ : 確保容量(instance 変数)
//
//  Return
//    function : == YES : 変形成功(bitmap は再確保済み)
//               == NO  : 変形失敗(bitmap は以前のまま)
//    width_   : 幅(instance 変数)
//    height_  : 高さ(instance 変数)
//    size_    : 確保容量(instance 変数)
//    bitmap_  : pixel map(instance 変数)
//
-(BOOL)resizeWidth:(int)w
      resizeHeight:(int)h
{
    BOOL flg;
    int s;
    unsigned char *buf;

    flg = YES;                          // 初期値は成功
    buf = NULL;

    // 必要容量の算出
    if (w <= 0) {
        w = self->width_;
    }
    if (h <= 0) {
        h = self->height_;
    }
    s = ((w + (w & 1)) * h);

    // bitmap の変形
    if (self->size_ < s) {
        buf = (unsigned char *)(realloc(self->bitmap_, s));
        if (buf == NULL) {
           DPRINT((@"memory allocation error.\n"));
           flg = NO;
        } else {
            // bitmap の更新
            self->bitmap_ = buf;
            self->size_ = s;
        }
    }

    // 大きさの更新
    if (flg) {
        self->width_ = w;
        self->height_ = h;
    }

    return flg;
}


// ----------------------------------------- instance - public - ファイル操作系
//
// 保存
//
//  Call
//    width_  : 幅(instance 変数)
//    height_ : 高さ(instance 変数)
//    size_   : 確保容量(instance 変数)
//    bitmap_ : pixel map(instance 変数)
//
//  Return
//    function : data
//
-(NSData *)createFileData
{
    NSMutableData *data;
    PoCoWErr rv;
    PoCoZlibDeflate *zlib;
#ifdef  __LITTLE_ENDIAN__
    int i;
#endif  // __LITTLE_ENDIAN__

    DPRINT((@"[PoCoBitmap createFileData]\n"));

    data = [NSMutableData data];

    // 幅を書き込む
#ifdef  __LITTLE_ENDIAN__
    i = PoCoSwapUW(self->width_);
    [data appendBytes:&(i)
               length:sizeof(int)];
#else   // __LITTLE_ENDIAN__
    [data appendBytes:&(self->width_)
               length:sizeof(int)];
#endif  // __LITTLE_ENDIAN__

    // 高さを書き込む
#ifdef  __LITTLE_ENDIAN__
    i = PoCoSwapUW(self->height_);
    [data appendBytes:&(i)
               length:sizeof(int)];
#else   // __LITTLE_ENDIAN__
    [data appendBytes:&(self->height_)
               length:sizeof(int)];
#endif  // __LITTLE_ENDIAN__

    // 圧縮
    zlib = [[PoCoZlibDeflate alloc] init];
    rv = [zlib appendBytes:self->bitmap_ length:self->size_];
    if (rv < ER_OK) {
        DPRINT((@"[zlib appendBytes: length:] : %d(0x%08x)\n", rv, rv));
        data = nil;
    } else {
        [data appendBytes:[zlib bytes]
                   length:[zlib length]];
        [zlib clearBuffer:[zlib length]];
        do {
            rv = [zlib finishData];
            if (rv < ER_OK) {
                DPRINT((@"[zlib finishData] : %d(0x%08x)\n", rv, rv));
                data = nil;
                break;
            }
            [data appendBytes:[zlib bytes]
                       length:[zlib length]];
            [zlib clearBuffer:[zlib length]];
        } while (rv == 1);
    }
    [zlib release];

    return data;
}


//
// 読み込み(通常)
//
//  Call
//    png : PNG Decoder
//
//  Return
//    function : 実体
//    width_   : 幅(instance 変数)
//    height_  : 高さ(instance 変数)
//    bitmap_  : pixel map(instance 変数)
//
-(id)initWithPNGDecoder:(PoCoPNGDecoder *)png
{
    int w;
    int h;

    DPRINT((@"[PoCoBitmap initWithPNGDecoder]\n"));

    [png readIntChunk:(unsigned int *)(&(w))];
    [png readIntChunk:(unsigned int *)(&(h))];

    // 指定イニシャライザを呼び出す
    self = [self initWidth:w
                initHeight:h
              defaultColor:0];

    // 解凍
    if (self != nil) {
        if ([self inflateChunkData:self->bitmap_
                    withPNGDecoder:png]) {
            // 成功
            ;
        } else {
            // 失敗
            [self release];
            self = nil;
        }
    }

    return self;
}


//
// 読み込み(IDAT CHUNK)
//  複数 IDAT CHUNK には未対応
//  PNG への完璧な対応は謳わないので、IDAT CHUNK 対応はあんまり本気で実装しない
//
//  Call
//    png : PNG Decoder
//    w   : 幅
//    h   : 高さ
//
//  Return
//    function : 実体
//    width_   : 幅(instance 変数)
//    height_  : 高さ(instance 変数)
//    size_    : 確保容量(instance 変数)
//    bitmap_  : pixel map(instance 変数)
//
-(id)initWithPNGDecoderIDAT:(PoCoPNGDecoder *)png
                  sizeWidth:(unsigned int)w
                 sizeHeight:(unsigned int)h
{
    unsigned int l;
    unsigned char *ptr;
    unsigned char *ptr2;

    DPRINT((@"[PoCoBitmap initWithPNGDecoderIDAT sizeWidth sizeHeigth]\n"));

    // 初期化(+1 は filter 用)
    self = [self initWidth:(w + 1)
                initHeight:h
              defaultColor:0];
    if (self == nil) {
        goto EXIT;
    }

    // 解凍
    if ([self inflateChunkData:self->bitmap_
                withPNGDecoder:png]) {
        // フィルタ実施
        ptr = self->bitmap_;
        [png initFilter:w];
        l = h;
        do {
            // 1行のフィルタ実施
            [png filtering:ptr[0]
                      data:&(ptr[1])];

            // 次へ
            (l)--;
            ptr += self->width_;
        } while (l != 0);

        // フィルタの分を消す
        ptr = self->bitmap_;
        l = h;
        if (w & 1) {
            do {
                memmove(&(ptr[0]), &(ptr[1]), w);
                ptr[w] = 0x00;

                // 次へ
                (l)--;
                ptr += self->width_;
            } while (l != 0);
            self->width_ = w;
        } else {
            ptr2 = (self->bitmap_ + 1);
            do {
                memmove(ptr, ptr2, w);

                // 次へ
                (l)--;
                ptr += w;
                ptr2 += self->width_;
            } while (l != 0);

            // 再確保(減少方向しかないので、不足はないだろうけど...)
            self->width_ = w;
            self->size_ = (self->width_ * self->height_);
            ptr = (unsigned char *)(realloc(self->bitmap_, self->size_));
            if (ptr != NULL) {
                self->bitmap_ = ptr;
            } else {
                [self release];
                self = nil;
            }
        }
    } else {
        // 失敗
        [self release];
        self = nil;
    }

EXIT:
    return self;
}

@end




// ============================================================================
@implementation PoCoLayerBase

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
    return [self initWidth:0
                initHeight:0
              defaultColor:0];
}


//
// initialize(指定イニシャライザ)
//  空レイヤーの生成になる
//
//  Call
//    w : 幅(dot 単位)
//    h : 高さ(dot 単位)
//    c : 色
//
//  Return
//    function    : 実体
//    bitmap_     : 内容の実体(instance 変数)
//    preview_    : 見本の表示用(instance 変数)
//    sampleRect_ : 見本の大きさ(instance 変数)
//    drawLock_   : 描画禁止の有無(instance 変数)
//    isDisplay_  : 表示禁止の有無(instance 変数)
//    name_       : レイヤー名称(instance 変数)
//
-(id)initWidth:(int)w
    initHeight:(int)h
  defaultColor:(unsigned char)c
{
    DPRINT((@"[PoCoLayerBase initWidth:%d initHeight:%d defaultColor:%d]\n", w, h, c));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        // 各値の初期化
        self->bitmap_ = nil;
        self->preview_ = nil;
        self->sampleRect_ = NSMakeRect(0.0, 0.0, 0.0, 0.0);
        self->drawLock_ = NO;
        self->isDisplay_ = YES;
        self->name_ = [[NSString alloc] initWithString:@""];

        // 編集対象画像のみ生成
        self->bitmap_ = [[PoCoBitmap alloc] initWidth:w
                                           initHeight:h
                                         defaultColor:c];
        if (self->bitmap_ == nil) {
            DPRINT((@"can't alloc bitmap.\n"));
            [self release];
            self = nil;
        }
    }

    return self;
}


//
// initialize(複製)
//
//  Call
//    zone        : zone(api 変数)
//    bitmap_     : 内容の実体(instance 変数)
//    preview_    : 見本の表示用(instance 変数)
//    sampleRect_ : 見本の大きさ(instance 変数)
//    drawLock_   : 描画禁止の有無(instance 変数)
//    isDisplay_  : 表示禁止の有無(instance 変数)
//    name_       : レイヤー名称(instance 変数)
//
//  Return
//    function : 実体(複製した実体)
//
-(id)copyWithZone:(NSZone *)zone
{
    PoCoLayerBase *copy;

    DPRINT((@"[PoCoLayerBase copyWithZone:0x%p]\n", zone));

    // 複製を生成
    copy = [[[self class] allocWithZone:zone] init];

    // 複製先の内容を設定
    if (copy != nil) {
        // 初期化で用意されたものを解放
        [copy->bitmap_ release];
        [copy->preview_ release];
        [copy->name_ release];
        copy->bitmap_ = nil;
        copy->preview_ = nil;
        copy->name_ = nil;

        // copy を生成
        copy->bitmap_ = [self->bitmap_ copy];
        copy->preview_ = [self->preview_ copy];
        copy->sampleRect_ = self->sampleRect_;
        if ([self drawLock]) {
            [copy setDrawLock];
        }
        if (!([self isDisplay])) {
            [copy clearIsDisplay];
        }
        copy->name_ = [self->name_ copy];
    }

    return copy;
}


//
// deallocate
//
//  Call
//    None
//
//  Return
//    bitmap_  : 内容の実体(instance 変数)
//    preview_ : 見本の表示用(instance 変数)
//    name_    : レイヤー名称(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoLayer dealloc]\n"));

    // 各資源を解放
    [self->preview_ release];
    [self->bitmap_ release];
    [self->name_ release];
    self->bitmap_ = nil;
    self->preview_ = nil;
    self->name_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// 種別
//
//  Call
//    None
//
//  Return
//    function : 種別番号
//
-(PoCoLayerType)layerType
{
    return PoCoLayerType_Base;
}


//
// 種別名称
//
//  Call
//    None
//
//  Return
//    function : 名称文字列
//
-(NSString *)typeName
{
    return @"";
}


//
// bitmap の参照
//
//  Call
//    bitmap_ : 内容の実体(instance 変数)
//
//  Return
//    function : 編集対象の bitmap
//
-(PoCoBitmap *)bitmap
{
    return self->bitmap_;
}


//
// preview 画像の参照
//
//  Call
//    preview_    : 見本の表示用(instance 変数)
//    sampleRect_ : 見本の大きさ(instance 変数)
//
//  Return
//    function : 見本表示用の bitmap
//
-(NSImage *)preview
{
    NSImage *image;

#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)
    image = [[NSImage alloc] initWithCGImage:[self->preview_ CGImage]
                                        size:self->sampleRect_.size];
#else   // (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)
    image = [[NSImage alloc] init];
    [image addRepresentation:self->preview_];
#endif  // (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)

    // レイヤー一覧の場合は identifier で呼ばれたままになるので autorelease
    [image autorelease];

    return image;
}


//
// 描画禁止かの確認
//
//  Call
//    drawLock_ : 描画禁止の有無(instance 変数)
//
//  Return
//    function : YES : 描画禁止状態
//               NO  : 描画許可状態
//
-(BOOL)drawLock
{
    return self->drawLock_;
}


//
// 表示禁止かの確認
//
//  Call
//    isDisplay_ : 表示禁止の有無(instance 変数)
//
//  Return
//    function : YES : 表示許可状態
//               NO  : 表示禁止状態
//
-(BOOL)isDisplay
{
    return self->isDisplay_;
}


//
// 名称の取得
//
//  Call
//    name_ : レイヤー名称(instance 変数)
//
//  Return
//    function : 名称
//
-(NSString *)name
{
    return self->name_;
}


//
// 描画禁止にする
//
//  Call
//    None
//
//  Return
//    drawLock_ : 描画禁止の有無(instance 変数)
//
-(void)setDrawLock
{
    self->drawLock_ = YES;

    return;
}


//
// 描画可能にする
//
//  Call
//    None
//
//  Return
//    drawLock_ : 描画禁止の有無(instance 変数)
//
-(void)clearDrawLock
{
    self->drawLock_ = NO;

    return;
}


//
// 表示許可にする
//
//  Call
//    None
//
//  Return
//    isDisplay_ : 表示禁止の有無(instance 変数)
//
-(void)setIsDisplay
{
    self->isDisplay_ = YES;

    return;
}


//
// 表示禁止にする
//
//  Call
//    None
//
//  Return
//    isDisplay_ : 表示禁止の有無(instance 変数)
//
-(void)clearIsDisplay
{
    self->isDisplay_ = NO;

    return;
}


//
// レイヤー名の設定
//
//  Call
//    str : 名称文字列
//
//  Return
//    name_ : レイヤー名称(instance 変数)
//
-(void)setName:(NSString *)str
{
    [self->name_ release];
    self->name_ = [str copy];

    return;
}


//
// preview の更新
//
//  Call
//    palette : パレット
//    bitmap_ : 編集対象の画像(instance 変数)
//
//  Return
//    preview_    : 見本の表示用(instance 変数)
//    sampleRect_ : 見本の大きさ(instance 変数)
//
-(void)updatePreview:(PoCoPalette *)palette
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)
{
    unsigned int sx;
    unsigned int sy;
    unsigned int dy;
    unsigned int si;
    unsigned int di;
    unsigned int sourceXStep;
    unsigned int sourceYStep;
    unsigned int sourceRow;
    unsigned int sampleWidth;
    unsigned int sampleHeight;
    unsigned int sampleRow;
    unsigned char *source;
    unsigned char *sample;
    PoCoColor *color;
    NSBitmapImageRep *buffer;
    const unsigned int sourceWidth = [self->bitmap_ width];
    const unsigned int sourceHeight = [self->bitmap_ height];
    PoCoEditInfo *info;
    unsigned int size;

//    DPRINT((@"[PoCoLayerBase updatePreview]\n"));

    info = [(PoCoAppController *)([NSApp delegate]) editInfo];
    size = [info previewSize];

    // 大きさの算出(見本表示部分)
    if ((size == 0) ||
        ((sourceWidth <= size) && (sourceHeight <= size))) {
        self->sampleRect_.size.width = (CGFloat)(sourceWidth);
        self->sampleRect_.size.height = (CGFloat)(sourceHeight);
    } else {
        if (sourceWidth < sourceHeight) {
            self->sampleRect_.size.width = (CGFloat)(MAX(1, ((size * sourceWidth) / sourceHeight)));
            self->sampleRect_.size.height = (CGFloat)(size);
        } else {
            self->sampleRect_.size.width = (CGFloat)(size);
            self->sampleRect_.size.height = (CGFloat)(MAX(1, ((size * sourceHeight) / sourceWidth)));
        }
    }

    // 大きさの算出(生成画像)
    size *= [info previewQuality];
    if ((size == 0) ||
        ((sourceWidth <= size) && (sourceHeight <= size))) {
        sampleWidth = sourceWidth;
        sampleHeight = sourceHeight;
        sourceXStep = 1;
        sourceYStep = 1;
    } else {
        if (sourceWidth < sourceHeight) {
            sampleWidth = MAX(1, ((size * sourceWidth) / sourceHeight));
            sampleHeight = size;
        } else {
            sampleWidth = size;
            sampleHeight = MAX(1, ((size * sourceHeight) / sourceWidth));
        }
        sourceXStep = (sourceWidth / sampleWidth);
        sourceYStep = (sourceHeight / sampleHeight);
    }

    // NSBitmapImageRep の生成
    buffer = [[NSBitmapImageRep alloc]
                 initWithBitmapDataPlanes:NULL
                               pixelsWide:sampleWidth
                               pixelsHigh:sampleHeight
                            bitsPerSample:8
                          samplesPerPixel:3
                                 hasAlpha:NO
                                 isPlanar:NO
                           colorSpaceName:NSCalibratedRGBColorSpace
                              bytesPerRow:0
                             bitsPerPixel:0];
    if (buffer == nil) {
        DPRINT((@"can't alloc NSBitmapImageRep\n"));
    } else {
        // 差し替え
        [self->preview_ release];
        self->preview_ = buffer;

        // 見本画像の生成
        source = [self->bitmap_ pixelmap];
        sample = [self->preview_ bitmapData];
        sourceRow = (sourceWidth + (sourceWidth & 1));
        sampleRow = (unsigned int)([self->preview_ bytesPerRow]);
        for (sy = 0, dy = 0;
             (sy < sourceHeight) && (dy < sampleHeight);
             sy += sourceYStep, (dy)++) {
            si = (sy * sourceRow);
            di = (dy * sampleRow);
            for (sx = 0; sx < sourceWidth; sx += sourceXStep) {
                color = [palette palette:source[si]];
                sample[di + 0] = [color red];
                sample[di + 1] = [color green];
                sample[di + 2] = [color blue];
                si += sourceXStep;
                di += 3;
            }
        }
    }

    return;
}
#else   // (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)
{
    unsigned int sx;
    unsigned int sy;
    unsigned int dy;
    unsigned int si;
    unsigned int di;
    unsigned int sourceXStep;
    unsigned int sourceYStep;
    unsigned int sourceRow;
    unsigned int sampleWidth;
    unsigned int sampleHeight;
    unsigned int sampleRow;
    unsigned char *source;
    unsigned char *sample;
    PoCoColor *color;
    NSBitmapImageRep *buffer;
    const unsigned int sourceWidth = [self->bitmap_ width];
    const unsigned int sourceHeight = [self->bitmap_ height];

//    DPRINT((@"[PoCoLayerBase updatePreview]\n"));

    // 大きさの算出
    if ((sourceWidth <= SAMPLE_SIZE) && (sourceHeight <= SAMPLE_SIZE)) {
        sampleWidth = sourceWidth;
        sampleHeight = sourceHeight;
        sourceXStep = 1;
        sourceYStep = 1;
    } else {
        if (sourceWidth < sourceHeight) {
            sampleWidth = MAX(1, ((SAMPLE_SIZE * sourceWidth) / sourceHeight));
            sampleHeight = SAMPLE_SIZE;
        } else {
            sampleWidth = SAMPLE_SIZE;
            sampleHeight = MAX(1, ((SAMPLE_SIZE * sourceHeight) / sourceWidth));
        }
        sourceXStep = (sourceWidth / sampleWidth);
        sourceYStep = (sourceHeight / sampleHeight);
    }

    // NSBitmapImageRep の生成
    buffer = [[NSBitmapImageRep alloc]
                 initWithBitmapDataPlanes:NULL
                               pixelsWide:sampleWidth
                               pixelsHigh:sampleHeight
                            bitsPerSample:8
                          samplesPerPixel:3
                                 hasAlpha:NO
                                 isPlanar:NO
                           colorSpaceName:NSCalibratedRGBColorSpace
                              bytesPerRow:0
                             bitsPerPixel:0];
    if (buffer == nil) {
        DPRINT((@"can't alloc NSBitmapImageRep\n"));
    } else {
        // 差し替え
        [self->preview_ release];
        self->preview_ = buffer;

        // 見本画像の生成
        source = [self->bitmap_ pixelmap];
        sample = [self->preview_ bitmapData];
        sourceRow = (sourceWidth + (sourceWidth & 1));
        sampleRow = (unsigned int)([self->preview_ bytesPerRow]);
        for (sy = 0, dy = 0;
             (sy < sourceHeight) && (dy < sampleHeight);
             sy += sourceYStep, (dy)++) {
            si = (sy * sourceRow);
            di = (dy * sampleRow);
            for (sx = 0; sx < sourceWidth; sx += sourceXStep) {
                color = [palette palette:source[si]];
                sample[di + 0] = [color red];
                sample[di + 1] = [color green];
                sample[di + 2] = [color blue];
                si += sourceXStep;
                di += 3;
            }
        }
    }

    return;
}
#endif  // (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)
#if 0   // 完全(重すぎるので使わない)
{
    unsigned int x;
    unsigned int y;
    unsigned int sskip;
    unsigned int dskip;
    unsigned char *sbmp;
    unsigned char *dbmp;
    PoCoColor *c;
    NSBitmapImageRep *buffer;
    const unsigned int w = [self->bitmap_ width];
    const unsigned int h = [self->bitmap_ height];

//    DPRINT((@"[PoCoLayerBase updatePreview]\n"));

    // 大きさの算出
    if ((w <= SAMPLE_SIZE) && (h <= SAMPLE_SIZE)) {
        self->sampleRect_.size.width = (CGFloat)(w);
        self->sampleRect_.size.height = (CGFloat)(h);
    } else {
        if (w < h) {
            self->sampleRect_.size.width = (CGFloat)(MAX(1, ((SAMPLE_SIZE * w) / h)));
            self->sampleRect_.size.height = (CGFloat)(SAMPLE_SIZE);
        } else {
            self->sampleRect_.size.width = (CGFloat)(SAMPLE_SIZE);
            self->sampleRect_.size.height = (CGFloat)(MAX(1, ((SAMPLE_SIZE * h) / w)));
        }
    }

    // NSBitmapImageRep の生成
    buffer = [[NSBitmapImageRep alloc]
                 initWithBitmapDataPlanes:NULL
                               pixelsWide:w
                               pixelsHigh:h
                            bitsPerSample:8
                          samplesPerPixel:3
                                 hasAlpha:NO
                                 isPlanar:NO
                           colorSpaceName:NSCalibratedRGBColorSpace
                              bytesPerRow:0
                             bitsPerPixel:0];
    if (buffer == nil) {
        DPRINT((@"can't alloc NSBitmapImageRep\n"));
    } else {
        // 差し替え
        [self->preview_ release];
        self->preview_ = buffer;

        // 見本画像の生成
        sbmp = [self->bitmap_ pixelmap];
        dbmp = [self->preview_ bitmapData];
        sskip = (w & 1);
        dskip = ((unsigned int)([self->preview_ bytesPerRow]) - (w * 3));
        y = h;
        do {
            x = w;
            do {
                c = [palette palette:*(sbmp)];
                (sbmp)++;
                *(dbmp) = [c red];
                (dbmp)++;
                *(dbmp) = [c green];
                (dbmp)++;
                *(dbmp) = [c blue];
                (dbmp)++;
                (x)--;
            } while (x != 0);
            sbmp += sskip;
            dbmp += dskip;
            (y)--;
        } while (y != 0);
    }

    return;
}
#endif   // 0


// ----------------------------------------- instance - public - ファイル操作系
//
// 保存
//
//  Call
//    None
//
//  Return
//    function : data
//
-(NSData *)createFileData
{
    // 基底 class では何もしない
    ;

    return nil;
}


//
// 読み込み
//
//  Call
//    png : PNG Decoder
//
//  Return
//    function : 実体
//
-(id)initWithPNGDecoder:(PoCoPNGDecoder *)png
{
    // 基底 class では何もしない
    ;

    return nil;
}

@end




// ============================================================================
@implementation PoCoBitmapLayer

// ---------------------------------------------------------- instance - public
//
// initialize(複製)
//
//  Call
//    zone : zone(api 変数)
//
//  Return
//    function : 実体(複製した実体)
//
-(id)copyWithZone:(NSZone *)zone
{
    DPRINT((@"[PoCoBitmapLayer copyWithZone:0x%p]\n", zone));

    // 複製を生成
    return [super copyWithZone:zone];
}


//
// 種別
//
//  Call
//    None
//
//  Return
//    function : 種別番号
//
-(PoCoLayerType)layerType
{
    return PoCoLayerType_Bitmap;
}


//
// 種別名称
//
//  Call
//    None
//
//  Return
//    function : 名称文字列
//
-(NSString *)typeName
{
    return [[NSBundle mainBundle]
               localizedStringForKey:@"BitmapLayerName"
                               value:@"image"
                               table:nil];
}


// ----------------------------------------- instance - public - ファイル操作系
//
// 保存
//
//  Call
//    isDisplay_ : 表示禁止の有無(instance 変数)
//    drawLock_  : 描画禁止の有無(instance 変数)
//    name_      : レイヤー名称(instance 変数)
//    bitmap_    : 編集対象の画像(instance 変数)
//
//  Return
//    function : data
//
-(NSData *)createFileData
{
    NSData *data;
    PoCoPNGEncoder *png;
    NSData *pixdata;

    DPRINT((@"[PoCoBitmapLayer createFileData]"));

    png = [[PoCoPNGEncoder alloc] init];

    // CHUNK を生成
    [png createChunk:(unsigned char *)("ilAY")];

    // ilAY の内容を書き込み
    [png writeByteChunk:self->isDisplay_];
    [png writeByteChunk:self->drawLock_];
    if ([self->name_ length] > 0) {
        [png writeChunk:[self->name_ UTF8String]
                 length:((unsigned int)(strlen([self->name_ UTF8String])) + 1)];
    } else {
        [png writeByteChunk:0x00];
    }
    pixdata = [self->bitmap_ createFileData];
    [png writeChunk:[pixdata bytes]
             length:(unsigned int)([pixdata length])];

    // CHUNK を閉じる
    [png closeChunk];

    // NSData を生成
    data = [png createNSData];
    [png release];

    return data;
}


//
// 読み込み(標準)
//
//  Call
//    png : PNG Decoder
//
//  Return
//    function : 実体
//
-(id)initWithPNGDecoder:(PoCoPNGDecoder *)png
{
    PoCoBitmap *bmp;
    unsigned char i;

    DPRINT((@"[PoCoBitmapLayer initWithPNGDecoder]"));

    // 指定イニシャライザを呼び出す
    self = [super init];
    if (self == nil) {
        goto EXIT;
    }

    // 表示可否の読み込み
    if (!([png readByteChunk:&(i)])) {
        DPRINT((@"can't read display.\n"));
        [self release];
        self = nil;
        goto EXIT;
    }
    if (i == 0) {
        [self clearIsDisplay];
    }

    // 編集可否の読み込み
    if (!([png readByteChunk:&(i)])) {
        DPRINT((@"can't read display.\n"));
        [self release];
        self = nil;
        goto EXIT;
    }
    if (i != 0) {
        [self setDrawLock];
    }

    // レイヤー名称の読み込み
    [self->name_ release];
    [self setName:[NSString stringWithUTF8String:[png bytes]]];
    [png readChunk:NULL
            length:((unsigned int)(strlen([png bytes])) + 1)
            readed:NULL];

    // pixelmap を読み込み
    bmp = [[PoCoBitmap alloc] initWithPNGDecoder:png];
    if (bmp == nil) {
        DPRINT((@"can't load pixelmap.\n"));
        [self release];
        self = nil;
        goto EXIT;
    }
    [self->bitmap_ release];
    self->bitmap_ = bmp;
#if 0
{
    const unsigned char *p = [bmp pixelmap];
    const int w = [bmp width];
    const int h = [bmp height];
    const int r = (w + (w & 0x01));
    int x;
    int y;

    for (y = 0; y < h; (y)++) {
        for (x = 0; x < w; (x)++) {
            printf(" %02x,", p[(y * r) + x]);
        }
        printf("\n");
    }
}
#endif  // 0

EXIT:
    return self;
}


//
// 読み込み(IDAT CHUNK)
//
//  Call
//    png : PNG Decoder
//    w   : 幅
//    h   : 高さ
//
//  Return
//    function : 実体
//
-(id)initWithPNGDecoderIDAT:(PoCoPNGDecoder *)png
                  sizeWidth:(unsigned int)w
                 sizeHeight:(unsigned int)h
{
    PoCoBitmap *bmp;

    DPRINT((@"[PoCoBitmapLayer initWithPNGDecoderIDAT sizeWidth sizeHeight]"));

    // 指定イニシャライザを呼び出す
    self = [super init];

    // pixelmap を読み込み
    if (self != nil) {
        bmp = [[PoCoBitmap alloc] initWithPNGDecoderIDAT:png
                                               sizeWidth:w
                                              sizeHeight:h];
        if (bmp == nil) {
            DPRINT((@"can't load pixelmap.\n"));
            [self release];
            self = nil;
        } else {
            [self->bitmap_ release];
            self->bitmap_ = bmp;
        }
    }

    return self;
}

@end




// ============================================================================
@implementation PoCoStringLayer

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function : 実体
//    str_r_   : 文字列のレイアウト領域(instance 変数)
//    str_     : 対象文字列(instance 変数)
//
-(id)init
{
    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->str_r_ = nil;
        self->str_ = @"";
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
//    str_r_ : 文字列のレイアウト領域(instance 変数)
//    str_   : 対象文字列(instance 変数)
//
-(void)dealloc
{
    [self->str_r_ release];
    [self->str_ release];

    // super class の解放
    [super dealloc];

    return;
}


//
// 種別
//
//  Call
//    None
//
//  Return
//    function : 種別番号
//
-(PoCoLayerType)layerType
{
    return PoCoLayerType_String;
}


//
// 種別名称
//
//  Call
//    None
//
//  Return
//    function : 名称文字列
//
-(NSString *)typeName
{
    return [[NSBundle mainBundle]
               localizedStringForKey:@"StringLayerName"
                               value:@"string"
                               table:nil];
}

// ... 文字列 layer 特有の内容は未定義 ...


// ----------------------------------------- instance - public - ファイル操作系
//
// 保存
//
//  Call
//    None
//
//  Return
//    function : data
//
-(NSData *)createFileData
{
    DPRINT((@"[PoCoStringLayer createFileData]"));

// ... まだ ...

    return nil;
}


//
// 読み込み
//
//  Call
//    png : PNG Decoder
//
//  Return
//    function : 実体
//
-(id)initWithPNGDecoder:(PoCoPNGDecoder *)png
{
    DPRINT((@"[PoCoStringLayer initWithPNGDecoder]"));

// ... まだ ...

    return nil;
}

@end
