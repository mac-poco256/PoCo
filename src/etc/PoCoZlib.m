//
//	Pelistina on Cocoa - PoCo -
//	zlib 運用ライブラリ
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoZlib.h"

// 内部定数
static const unsigned int BUFFER_SIZE = 8192;

// ============================================================================
@implementation PoCoZlibDeflate

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    funcion : 実体
//    zstrm_  : zlib data stream(instance 変数)
//    buf_    : 作業バッファ(instance 変数)
//
-(id)init
{
    int z_er;

    DPRINT((@"[PoCoZlibDeflate init]\n"));

    // super class を初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->buf_ = NULL;
        memset(&(self->zstrm_), 0x00, sizeof(z_stream));

        // 作業バッファを確保
        self->buf_ = (unsigned char *)(malloc(BUFFER_SIZE));
        if (self->buf_ == NULL) {
            DPRINT((@"memory allocation error.\n"));
            [self release];
            self = nil;
            goto EXIT;
        }

        // zlib を初期化
        self->zstrm_.avail_out = BUFFER_SIZE;
        self->zstrm_.next_out = self->buf_;
        z_er = deflateInit(&(self->zstrm_), Z_BEST_COMPRESSION);
        if (z_er != Z_OK) {
            DPRINT((@"deflateInit : %d\n", z_er));
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
//    zstrm_ : zlib data stream(instance 変数)
//    buf_   : 作業バッファ(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoZlibDeflate dealloc]\n"));

    // zlib を終了
    deflateEnd(&(self->zstrm_));

    // 作業バッファを解放
    if (self->buf_ != NULL) {
        free(self->buf_);
    }
    self->buf_ = NULL;

    // duper class を解放
    [super dealloc];

    return;
}


//
// 圧縮(データ追加)
//
//  Call
//    bytes  : 圧縮対象データ列
//    lenth  : データ列長さ
//    zstrm_ : zlib data stream(instance 変数)
//
//  Return
//    function : <  0 : error code
//               == 0 : 圧縮終了
//               == 1 : 圧縮継続
//    zstrm_   : zlib data stream(instance 変数)
//
-(PoCoWErr)appendBytes:(const unsigned char *)bytes
                length:(unsigned int)length
{
    PoCoWErr rv;
    int z_er;

    // z_stream 設定
    if ((bytes != NULL) && (length > 0)) {
        self->zstrm_.avail_in = length;
        self->zstrm_.next_in = (Bytef *)(bytes);
    }

    // 圧縮実行
    z_er = deflate(&(self->zstrm_), Z_SYNC_FLUSH);
    if (z_er == Z_OK) {
        // 正常
        rv = ((self->zstrm_.avail_in == 0) ? 0 : 1);
    } else if (z_er == Z_STREAM_END) {
        // 終了
        rv = 0;
    } else {
        // 他は全てエラー(Z_NEED_DICT は有り得ない)
        rv = ER_ZLIB;
        DPRINT((@"deflate(Z_SYNC_FLUSH) : %d\n", z_er));
    }

    return rv;
}


//
// 圧縮終了
//
//  Call
//    zstrm_ : zlib data stream(instance 変数)
//
//  Return
//    function : <  0 : error code
//               == 0 : Z_STREAM_END(圧縮終了)
//               == 1 : 圧縮継続
//
-(PoCoWErr)finishData
{
    PoCoWErr rv;
    int z_er;

    // Z_FINISH 発行
    z_er = deflate(&(self->zstrm_), Z_FINISH);
    if (z_er == Z_OK) {
        // 継続
        rv = 1;
    } else if (z_er == Z_STREAM_END) {
        // 終了
        rv = 0;
    } else {
        // 他は全てエラー(Z_NEED_DICT は有り得ない)
        rv = ER_ZLIB;
        DPRINT((@"deflate(Z_FINISH) : %d\n", z_er));
    }

    return rv;
}


//
// 取得
//
//  Call
//    buf_ : 作業バッファ(instance 変数)
//
//  Return
//    function : バイト列
//
-(void *)bytes
{
    return (void *)(self->buf_);
}


//
// 取得
//
//  Call
//    zstrm_ : zlib data stream(instance 変数)
//
//  Return
//    function : バッファ使用量
//
-(unsigned int)length
{
    return (BUFFER_SIZE - self->zstrm_.avail_out);
}


//
// バッファ解放
//  実際には、z_stream.avail_out/z_strem.next_out を差し戻すだけ
//
//  Call
//    length : 解放容量
//
//  Return
//    zstrm_ : zlib data stream(instance 変数)
//
-(void)clearBuffer:(unsigned int)length
{
    self->zstrm_.avail_out += length;
    self->zstrm_.next_out -= length;

    return;
}

@end




// ============================================================================
@implementation PoCoZlibInflate

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function : 実体
//    zstrm_   : zlib data stream(instance 変数)
//    buf_     : 作業バッファ(instance 変数)
//
-(id)init
{
    int z_er;

    DPRINT((@"[PoCoZlibInflate init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->buf_ = NULL;
        memset(&(self->zstrm_), 0x00, sizeof(z_stream));

        // 作業バッファを確保
        self->buf_ = (unsigned char *)(malloc(BUFFER_SIZE));
        if (self->buf_ == NULL) {
            DPRINT((@"memory allocation error.\n"));
            [self release];
            self = nil;
            goto EXIT;
        }

        // zlib を初期化
        self->zstrm_.avail_out = BUFFER_SIZE;
        self->zstrm_.next_out = self->buf_;
        z_er = inflateInit(&(self->zstrm_));
        if (z_er != Z_OK) {
            DPRINT((@"inflateInit : %d(0x%08x)\n", z_er, z_er));
            [self release];
            self = nil;
            goto EXIT;
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
//    zstrm_ : zlib data stream(instance 変数)
//    buf_   : 作業バッファ(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoZlibInflate dealloc]\n"));

    // zlib を終了
    inflateEnd(&(self->zstrm_));

    // 作業バッファ解放
    if (self->buf_ != NULL) {
        free(self->buf_);
    }
    self->buf_ = NULL;

    // super class の解放
    [super dealloc];

    return;
}

//
// 伸張(データ追加)
//
//  Call
//    bytes : 伸張対象データ列
//    lenth : データ列長さ
//    zstrm_ : zlib data stream(instance 変数)
//
//  Return
//    function : <  0 : error code
//               == 0 : 伸張終了
//               == 1 : 伸張継続
//    zstrm_   : zlib data stream(instance 変数)
//
-(PoCoWErr)appendBytes:(const unsigned char *)bytes
                length:(unsigned int)length
{
    PoCoWErr rv;
    int z_er;

    // z_stream 設定
    if ((bytes != NULL) && (length > 0)) {
        self->zstrm_.avail_in = length;
        self->zstrm_.next_in = (Bytef *)(bytes);
    }

    // 伸張実行
    z_er = inflate(&(self->zstrm_), Z_SYNC_FLUSH);
    if (z_er == Z_OK) {
        // 正常
        rv = ((self->zstrm_.avail_in == 0) ? 0 : 1);
    } else if (z_er == Z_STREAM_END) {
        // 終了
        rv = 0;
    } else {
        // 他は全てエラー(Z_NEED_DICT は有り得ない)
        rv = ER_ZLIB;
        DPRINT((@"inflate(Z_SYNC_FLUSH) : %d\n", z_er));
    }

    return rv;
}


//
// 伸張終了
//
//  Call
//    zstrm_ : zlib data stream(instance 変数)
//
//  Return
//    function : <  0 : error code
//               == 0 : Z_STREAM_END(伸張終了)
//               == 1 : 伸張継続
//
-(PoCoWErr)finishData
{
    PoCoWErr rv;
    int z_er;

    // Z_FINISH 発行
    z_er = inflate(&(self->zstrm_), Z_FINISH);
    if (z_er == Z_OK) {
        // 継続
        rv = 1;
    } else if (z_er == Z_STREAM_END) {
        // 終了
        rv = 0;
    } else {
        // 他は全てエラー(Z_NEED_DICT は有り得ない)
        rv = ER_ZLIB;
        DPRINT((@"inflate(Z_FINISH) : %d\n", z_er));
    }

    return rv;
}


//
// 取得
//
//  Call
//    buf_ : 作業バッファ(instance 変数)
//
//  Return
//    function : バイト列
//
-(void *)bytes
{
    return (void *)(self->buf_);
}


//
// 取得
//
//  Call
//    zstrm_ : zlib data stream(instance 変数)
//
//  Return
//    function : バッファ使用量
//
-(unsigned int)length
{
    return (BUFFER_SIZE - self->zstrm_.avail_out);
}


//
// バッファ解放
//  実際には、z_stream.avail_out/z_strem.next_out を差し戻すだけ
//
//  Call
//    length : 解放容量
//
//  Return
//    zstrm_ : zlib data stream(instance 変数)
//
-(void)clearBuffer:(unsigned int)length
{
    self->zstrm_.avail_out += length;
    self->zstrm_.next_out -= length;

    return;
}

@end
