//
//	Pelistina on Cocoa - PoCo -
//	PNG ライブラリ
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoPNG.h"

#import <zlib.h>

// 内部定数
static const unsigned int BUFFER_SIZE = 4096;

// ============================================================================
@implementation PoCoPNGEncoder

// ------------------------------------------------------------- class - public
//
// CRC32 を計算
//
//  Call
//    crc   : CRC
//    bytes : CRC を計算するバイト列
//    len   : バイト列長さ
//
//  Return
//    crc : CRC
//
+(unsigned int)calcCRC:(unsigned int)crc
                 bytes:(const void *)bytes
                length:(unsigned int)len
{
    return (unsigned int)(crc32(crc, bytes, len));
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function     : 実体
//    chunkName_[] : CHUNK タイプ名(instance 変数)
//    chunkBody_   : CHUNK の内容(instance 変数)
//    bufferLen_   : chunkBody_ 使用量(instance 変数)
//    bufferSize_  : chunkBody_ 確保量(instance 変数)
//
-(id)init
{
    DPRINT((@"[PoCoPNGEncoder init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->chunkBody_ = NULL;
        self->bufferLen_ = 0;
        self->bufferSize_ = 0;
        memset(self->chunkName_, 0x00, 4);
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
//    chunkBody_ : CHUNK の内容(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoPNGEncoder dealloc]\n"));

    if (self->chunkBody_ != NULL) {
        free(self->chunkBody_);
    }
    self->chunkBody_ = NULL;

    // super class の解放
    [super dealloc];

    return;
}


//
// CHUNK 生成
//
//  Call
//    name : CHUNK タイプ名
//
//  Return
//    function     : error code
//    chunkName_[] : CHUNK タイプ名(instance 変数)
//    bufferLen_   : chunkBody_ 使用量(instance 変数)
//
-(PoCoErr)createChunk:(const unsigned char *)name
{
    // タイプ名を保持
    memcpy(self->chunkName_, name, 4);

    // body の使用量を初期化
    self->bufferLen_ = 0;

    return ER_OK;
}


//
// CHUNK 書き込み(1バイト)
//
//  Call
//    val : 値
//
//  Return
//    function : error code
//
-(PoCoErr)writeByteChunk:(unsigned char)val
{
    return [self writeChunk:(const void *)(&(val))
                     length:sizeof(unsigned char)];
}


//
// CHUNK 書き込み(int)(4バイト)
//
//  Call
//    val : 値
//
//  Return
//    function : error code
//
-(PoCoErr)writeIntChunk:(unsigned int)val
{
#ifdef  __LITTLE_ENDIAN__
    val = PoCoSwapUW(val);
#endif  // __LITTLE_ENDIAN__
    return [self writeChunk:(const void *)(&(val))
                     length:sizeof(unsigned int)];
}


//
// CHUNK 書き込み(任意長さ)
//
//  Call
//    bytes       : バイト列
//    len         : バイト列長さ
//    chunkBody_  : CHUNK の内容(instance 変数)
//    bufferLen_  : chunkBody_ 使用量(instance 変数)
//    bufferSize_ : chunkBody_ 確保量(instance 変数)
//
//  Return
//    chunkBody_  : CHUNK の内容(instance 変数)
//    bufferLen_  : chunkBody_ 使用量(instance 変数)
//    bufferSize_ : chunkBody_ 確保量(instance 変数)
//
-(PoCoErr)writeChunk:(const void *)bytes
              length:(unsigned int)len
{
    PoCoErr er;
    unsigned char *ptr;

    er = ER_OK;

    // バッファ拡張
    while (self->bufferSize_ < (self->bufferLen_ + len)) {
        // 再確保
        ptr = (unsigned char *)(realloc(self->chunkBody_, self->bufferSize_ + BUFFER_SIZE));
        if (ptr == NULL) {
            DPRINT((@"memory allocation error.\n"));
            er = ER_NOMEM;
            goto EXIT;
        }

        // 更新
        self->chunkBody_ = ptr;
        self->bufferSize_ += BUFFER_SIZE;
    }

    // 複写
    memcpy(&(self->chunkBody_[self->bufferLen_]), bytes, len);
    self->bufferLen_ += len;

EXIT:
    return er;
}


//
// CHUNK 閉じる
//
//  Call
//    None
//
//  Return
//    function : error code
//
-(PoCoErr)closeChunk
{
    // 何もしない
    ;

    return ER_OK;
}


//
// NSData を取得
//
//  Call
//    chunkName_[] : CHUNK タイプ名(instance 変数)
//    chunkBody_   : CHUNK の内容(instance 変数)
//    bufferLen_   : chunkBody_ 使用量(instance 変数)
//
//  Return
//    function : data
//
-(NSData *)createNSData
{
    NSMutableData *data;
    unsigned int crc;
#ifdef  __LITTLE_ENDIAN__
    unsigned int i;
#endif  // __LITTLE_ENDIAN__

    data = [NSMutableData data];

    // crc を計算
    crc = [PoCoPNGEncoder calcCRC:0
                            bytes:NULL
                           length:0];
    crc = [PoCoPNGEncoder calcCRC:crc
                            bytes:self->chunkName_
                           length:4];
    if (self->bufferLen_ > 0) {
        crc = [PoCoPNGEncoder calcCRC:crc
                                bytes:self->chunkBody_
                               length:self->bufferLen_];
    }

    // 長さ
#ifdef  __LITTLE_ENDIAN__
    i = PoCoSwapUW(self->bufferLen_);
    [data appendBytes:&(i)
               length:sizeof(unsigned int)];
#else   // __LITTLE_ENDIAN__
    [data appendBytes:&(self->bufferLen_)
               length:sizeof(unsigned int)];
#endif  // __LITTLE_ENDIAN__

    // CHUNK タイプ名
    [data appendBytes:self->chunkName_
               length:4];

    // body
    if (self->bufferLen_ > 0) {
        [data appendBytes:self->chunkBody_
                   length:self->bufferLen_];
    }

    // CRC
#ifdef  __LITTLE_ENDIAN__
    i = PoCoSwapUW(crc);
    [data appendBytes:&(i)
               length:sizeof(unsigned int)];
#else   // __LITTLE_ENDIAN__
    [data appendBytes:&(crc)
               length:sizeof(unsigned int)];
#endif  // __LITTLE_ENDIAN__

    return data;
}

@end




// ============================================================================
@implementation PoCoPNGDecoder

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function      : 実体
//    chunkName_[]  : CHUNK タイプ名(instance 変数)
//    chunkBody_    : CHUNK の内容(instance 変数)
//    bufferLen_    : chunkBody_ 使用量(instance 変数)
//    bufferSize_   : chunkBody_ 確保量(instance 変数)
//    bufferRefer_  : chunkBody_ 参照位置(instance 変数)
//    filterBuffer_ : フイルタ用のバッファ(instance 変数)
//    filterSize_   : フィルタサイズ(instance 変数)
//
-(id)init
{
    DPRINT((@"[PoCoPNGDecoder init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->chunkBody_ = NULL;
        self->bufferLen_ = 0;
        self->bufferSize_ = 0;
        self->bufferRefer_ = 0;
        memset(self->chunkName_, 0x00, 4);
        self->filterBuffer_ = NULL;
        self->filterSize_ = 0;
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
//    chunkBody_    : CHUNK の内容(instance 変数)
//    filterBuffer_ : フイルタ用のバッファ(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoPNGDecoder dealloc]\n"));

    // バッファを解放
    if (self->chunkBody_ != NULL) {
        free(self->chunkBody_);
    }
    if (self->filterBuffer_ != NULL) {
        free(self->filterBuffer_);
    }
    self->chunkBody_ = NULL;
    self->filterBuffer_ = NULL;

    // super class の解放
    [super dealloc];

    return;
}


//
// CHUNK を開ける
//  CHUNK タイプ名の照合をとる
//
//  Call
//    name         : 照合する CHUNK タイプ名
//    chunkName_[] : CHUNK タイプ名(instance 変数)
//
//  Return
//    function     : YES : タイプ名一致
//                   NO  : タイプ名不一致
//    bufferRefer_ : chunkBody_ 参照位置(instance 変数)
//
-(BOOL)openChunk:(const unsigned char *)name
{
    self->bufferRefer_ = 0;

    return (memcmp(name, self->chunkName_, 4) == 0);
}


//
// 読み込み(1バイト)
//
//  Call
//    val : 読み込んだ値を返す先
//
//  Return
//    function : YES : 成功
//               NO  : 失敗
//    val      : 読み込んだ値
//
-(BOOL)readByteChunk:(unsigned char *)val
{
    return [self readChunk:(void *)(val)
                    length:sizeof(unsigned char)
                    readed:NULL];
}


//
// 読み込み(int)(4バイト)
//
//  Call
//    val : 読み込んだ値を返す先
//
//  Return
//    function : YES : 成功
//               NO  : 失敗
//    val      : 読み込んだ値
//
-(BOOL)readIntChunk:(unsigned int *)val
#ifdef  __LITTLE_ENDIAN__
{
    BOOL result = [self readChunk:(void *)(val)
                           length:sizeof(unsigned int)
                           readed:NULL];

    *val = PoCoSwapUW(*val);

    return result;
}
#else   // __LITTLE_ENDIAN__
{
    return [self readChunk:(void *)(val)
                    length:sizeof(unsigned int)
                    readed:NULL];
}
#endif  // __LITTLE_ENDIAN__


//
// 読み込み(任意長さ)
//
//  Call
//    bytes        : 読み込んだ内容を返す先
//    len          : 読み込む長さ
//    read         : 読み込んだ容量
//    chunkBody_   : CHUNK の内容      (instance 変数)
//    bufferLen_   : chunkBody_ 使用量  (instance 変数)
//    bufferRefer_ : chunkBody_ 参照位置(instance 変数)
//
//  Return
//    function     : YES : 成功
//                   NO  : 失敗
//    read         : 読み込んだ容量(NULL 許容)
//    bufferRefer_ : chunkBody_ 参照位置(instance 変数)
//
-(BOOL)readChunk:(void *)bytes
          length:(unsigned int)len
          readed:(unsigned int *)read
{
    BOOL result;

    result = NO;

    // 読み込み容量を算出
    if ((self->bufferLen_ - self->bufferRefer_) < len) {
        len = (self->bufferLen_ - self->bufferRefer_);
    }

    // 1バイト以上なら成功
    if (len > 0) {
        // バッファへ複写
        if (bytes != NULL) {
            memcpy(bytes, &(self->chunkBody_[self->bufferRefer_]), len);
        }

        // 更新
        self->bufferRefer_ += len;

        // 成功
        result = YES;
        if (read != NULL) {
            *(read) = len;
        }
    }

    return result;
}


//
// CHUNK タイプ名を取得
//
//  Call
//    chunkName_[] : CHUNK タイプ名(instance 変数)
//
//  Return
//    function : CHUNK タイプ名
//
-(const unsigned char *)chunkName
{
    return self->chunkName_;
}


//
// CHUNK の内容を取得
//
//  Call
//    chunkBody_   : CHUNK の内容(instance 変数)
//    bufferRefer_ : chunkBody_ 参照位置(instance 変数)
//
//  Return
//    function : CHUNK の内容
//
-(const void *)bytes
{
    return (const void *)(&(self->chunkBody_[self->bufferRefer_]));
}


//
// CHUNK 長さを取得
//
//  Call
//    bufferLen_   : chunkBody_ 使用量(instance 変数)
//    bufferRefer_ : chunkBody_ 参照位置(instance 変数)
//
//  Return
//    function : CHUNK 長さ
//
-(unsigned int)length
{
    return (self->bufferLen_ - self->bufferRefer_);
}


//
// CHUNK を閉じる
//
//  Call
//    None
//
//  Return
//    None
//
-(void)closeChunk
{
    // 何もしない
    ;

    return;
}


// NSData から読み込み
//
//  Call
//    data  : 読み込み内容
//    range : 読み込み範囲
//
//  Return
//    function     : YES : 成功
//                   NO  : 失敗
//    range        : 読み込み範囲
//    chunkName_[] : CHUNK タイプ名(instance 変数)
//    chunkBody_   : CHUNK の内容(instance 変数)
//    bufferLen_   : chunkBody_ 使用量(instance 変数)
//    bufferSize_  : chunkBody_ 確保量(instance 変数)
//    bufferRefer_ : chunkBody_ 参照位置(instance 変数)
//
-(BOOL)loadNSData:(NSData *)data
        withRange:(NSRange *)range
{
    BOOL result;
    unsigned char *ptr;
    unsigned int crc;

    result = NO;
    self->bufferLen_ = 0;
    self->bufferRefer_ = 0;

    // CHUNK 長さを取得
    range->length = 4;
    if ([data length] < (range->location + range->length)) {
        goto EXIT;
    }
    [data getBytes:&(self->bufferLen_) range:*(range)];
#ifdef  __LITTLE_ENDIAN__
    self->bufferLen_ = PoCoSwapUW(self->bufferLen_);
#endif  // __LITTLE_ENDIAN__
    range->location += range->length;

    // CHUNK タイプ名を取得
    if ([data length] < (range->location + range->length)) {
        goto EXIT;
    }
    [data getBytes:self->chunkName_ range:*(range)];
    range->location += range->length;

    // body の領域を確保
    if (self->bufferSize_ < self->bufferLen_) {
        // 再確保
        ptr = (unsigned char *)(realloc(self->chunkBody_, self->bufferLen_));
        if (ptr == NULL) {
            DPRINT((@"memory allocation error.\n"));
            goto EXIT;
        }

        // 更新
        self->chunkBody_ = ptr;
        self->bufferSize_ = self->bufferLen_;
    }

    // CHUNK を読み込み
    range->length = self->bufferLen_;
    if ([data length] < (range->location + range->length)) {
        goto EXIT;
    }
    [data getBytes:self->chunkBody_ range:*(range)];
    range->location += range->length;

    // CRC を読み込み(読み捨て)
    range->length = 4;
    if ([data length] < (range->location + range->length)) {
        goto EXIT;
    }
    [data getBytes:&(crc) range:*(range)];
    range->location += range->length;

    // 成功
    result = YES;

EXIT:
    return result;
}


//
// フィルタ初期化
//
//  Call
//    w             : 幅(フィルタの分は含まない)
//    filterBuffer_ : フイルタ用のバッファ(instance 変数)
//
//  Return
//    filterBuffer_ : フイルタ用のバッファ(instance 変数)
//    filterSize_   : フィルタサイズ(instance 変数)
//
-(void)initFilter:(unsigned int)w
{
    // 以前のバッファを解放
    if (self->filterBuffer_ != NULL) {
        free(self->filterBuffer_);
    }
    self->filterBuffer_ = NULL;

    // 確保(+1 は最左端の左上用)
    self->filterSize_ = w;
    self->filterBuffer_ = (unsigned char *)(calloc(w + 1, sizeof(unsigned char)));

    return;
}


//
// フィルタをかける
//
//  Call
//    type          : フィルタ種別
//    data          : フィルタをかけるデータ列
//    filterBuffer_ : フイルタ用のバッファ(instance 変数)
//    filterSize_   : フィルタサイズ(instance 変数)
//
//  Return
//    data          : フィルタ結果
//    filterBuffer_ : フイルタ用のバッファ(instance 変数)
//
-(void)filtering:(unsigned int)type
            data:(unsigned char *)data
{
    unsigned int p;                     // paeth filter 用
    unsigned int pa;                    // paeth filter 用
    unsigned int pb;                    // paeth filter 用
    unsigned int pc;                    // paeth filter 用
    unsigned int x = self->filterSize_;
    unsigned char left = 0x00;
    unsigned char *flt = &(self->filterBuffer_[1]);
    unsigned char *ptr = data;

    // フィルタをかける
    switch (type) {
        default:
        case 0:
            // none filter
            ;
            break;
        case 1:
            // sub filter
            do {
                // フィルタをかける
                *(ptr) += left;

                // 次へ
                left = *(ptr);
                (x)--;
                (ptr)++;
            } while (x != 0);
            break;
        case 2:
            // up filter
            do {
                // フィルタをかける
                *(ptr) += *(flt);

                // 次へ
                (x)--;
                (ptr)++;
                (flt)++;
            } while (x != 0);
            break;
        case 3:
            // average filter
            do {
                // フィルタをかける
                *(ptr) += (unsigned char)(((unsigned int)(left) + (unsigned int)(*(flt))) >> 1);

                // 次へ
                left = *(ptr);
                (x)--;
                (ptr)++;
                (flt)++;
            } while (x != 0);
            break;
        case 4:
            // paeth filter
            do {
                // フィルタをかける
                p = left + *(flt) - *(flt - 1);
                pa = (unsigned int)(abs((int)(p - left)));
                pb = (unsigned int)(abs((int)(p - *(flt))));
                pc = (unsigned int)(abs((int)(p - *(flt - 1))));
                if ((pa <= pb) && (pa <= pc)) {
                    *(ptr) += left;
                } else if (pb <= pc) {
                    *(ptr) += *(flt);
                } else {
                    *(ptr) += *(flt - 1);
                }

                // 次へ
                left = *(ptr);
                (x)--;
                (ptr)++;
                (flt)++;
            } while (x != 0);
            break;
    }

    // フィルタをかけた結果をバッファに戻す
    memcpy(&(self->filterBuffer_[1]), data, self->filterSize_);

    return;
}

@end
