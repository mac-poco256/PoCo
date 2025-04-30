//
//	Pelistina on Cocoa - PoCo -
//	任意バッファ
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Foundation/Foundation.h>

// ----------------------------------------------------------------------------
@interface PoCoBuffer : NSObject
{
    unsigned char *ptr_;                // バッファ
    unsigned long size_;                // バッファの確保容量
    unsigned char *pptr_[1];            // 2次元配列に読み替え
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// 取得
-(unsigned char **)resizeBitmap:(unsigned int)height
                       rowBytes:(unsigned int)row;

@end
