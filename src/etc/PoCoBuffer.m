//
//	Pelistina on Cocoa - PoCo -
//	任意バッファ
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoBuffer.h"

// ============================================================================
@implementation PoCoBuffer

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function : 実体
//    ptr_     : バッファ(instance 変数)
//    size_    : バッファの確保容量(instance 変数)
//
-(id)init
{
    DPRINT((@"[PoCoBuffer init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->ptr_ = NULL;
        self->size_ = 0;
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
//    ptr_  : バッファ(instance 変数)
//    size_ : バッファの確保容量(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoBuffer dealloc]\n"));

    // バッファを解放
    if (self->ptr_ != NULL) {
        free(self->ptr_);
    }
    self->ptr_ = NULL;
    self->size_ = 0;

    // super class の解放
    [super dealloc];

    return;
}


//
// 取得
//
//  Call
//    height : 高さ
//    row    : rowBytes
//
//  Return
//    function : バッファ
//    ptr_     : バッファ(instance 変数)
//    size_    : バッファの確保容量(instance 変数)
//    pptr_    : 2次元配列に読み替え(instance 変数)
//
-(unsigned char **)resizeBitmap:(unsigned int)height
                       rowBytes:(unsigned int)row
{
    const unsigned long i = (row * height);
    unsigned char *p;

    if (i > self->size_) {
        DPRINT((@"height : %d, row : %d, size : %ld\n", height, row, i));

        p = (unsigned char *)(realloc(self->ptr_, i));
        if (p != NULL) {
            self->ptr_ = p;
            self->size_ = i;
        }
    }
    self->pptr_[0] = self->ptr_;

    return self->pptr_;
}

@end
