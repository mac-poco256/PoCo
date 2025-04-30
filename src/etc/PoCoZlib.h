//
//	Pelistina on Cocoa - PoCo -
//	zlib 運用ライブラリ
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Foundation/Foundation.h>
#import <zlib.h>

// ----------------------------------------------------------------------------
@interface PoCoZlibDeflate : NSObject
{
    z_stream zstrm_;                    // zlib data stream
    unsigned char *buf_;                // 作業バッファ
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// 圧縮(データ追加)
-(PoCoWErr)appendBytes:(const unsigned char *)bytes
                length:(unsigned int)length;

// 圧縮終了
-(PoCoWErr)finishData;

// 取得
-(void *)bytes;
-(unsigned int)length;

// バッファ解放
-(void)clearBuffer:(unsigned int)length;

@end


// ----------------------------------------------------------------------------
@interface PoCoZlibInflate : NSObject
{
    z_stream zstrm_;                    // zlib data stream
    unsigned char *buf_;                // 作業バッファ
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// 伸張(データ追加)
-(PoCoWErr)appendBytes:(const unsigned char *)bytes
                length:(unsigned int)length;

// 伸張終了
-(PoCoWErr)finishData;

// 取得
-(void *)bytes;
-(unsigned int)length;

// バッファ解放
-(void)clearBuffer:(unsigned int)length;

@end
