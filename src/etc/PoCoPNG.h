//
//	Pelistina on Cocoa - PoCo -
//	PNG ライブラリ
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Foundation/Foundation.h>

// ----------------------------------------------------------------------------
@interface PoCoPNGEncoder : NSObject
{
    unsigned char chunkName_[4];        // CHUNK タイプ名
    unsigned char *chunkBody_;          // CHUNK の内容
    unsigned int bufferLen_;            // chunkBody 使用量
    unsigned int bufferSize_;           // chunkBody 確保量
}

// CRC32 を計算
+(unsigned int)calcCRC:(unsigned int)crc
                 bytes:(const void *)bytes
                length:(unsigned int)len;

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// CHUNK 生成
-(PoCoErr)createChunk:(const unsigned char *)name;

// CHUNK 書き込み
-(PoCoErr)writeByteChunk:(unsigned char)val;
-(PoCoErr)writeIntChunk:(unsigned int)val;
-(PoCoErr)writeChunk:(const void *)bytes
              length:(unsigned int)len;

// CHUNK 閉じる
-(PoCoErr)closeChunk;

// NSData を取得
-(NSData *)createNSData;

@end


// ----------------------------------------------------------------------------
@interface PoCoPNGDecoder : NSObject
{
    unsigned char chunkName_[4];        // CHUNK タイプ名
    unsigned char *chunkBody_;          // CHUNK の内容
    unsigned int bufferLen_;            // chunkBody 使用量
    unsigned int bufferSize_;           // chunkBody 確保量
    unsigned int bufferRefer_;          // chunkBody 参照位置

    unsigned char *filterBuffer_;       // フイルタ用のバッファ
    unsigned int filterSize_;           // フィルタサイズ
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// CHUNK を開ける
-(BOOL)openChunk:(const unsigned char *)name;

// CHUNK 読み込み
-(BOOL)readByteChunk:(unsigned char *)val;
-(BOOL)readIntChunk:(unsigned int *)val;
-(BOOL)readChunk:(void *)bytes
          length:(unsigned int)len
          readed:(unsigned int *)read;

// 取得
-(const unsigned char *)chunkName;
-(const void *)bytes;
-(unsigned int)length;

// CHUNK を閉じる
-(void)closeChunk;

// NSData から読み込み
-(BOOL)loadNSData:(NSData *)data
        withRange:(NSRange *)range;

// フイルタ関係
-(void)initFilter:(unsigned int)w;
-(void)filtering:(unsigned int)type
            data:(unsigned char *)data;

@end
