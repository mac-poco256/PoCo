//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 任意角回転
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditRotateBitmap.h"

// =========================================================== PoCoRotateThread

// ------------------------------------------------------------------ interface
@interface PoCoRotateThread : NSObject
{
    unsigned char *sp_;                 // 回転元
    unsigned char *dp_;                 // 回転先
    PoCoRect *srcRect_;                 // 回転元範囲
    PoCoRect *dstRect_;                 // 回転先範囲
    long long sp_x_;                    // 回転元座標(X)
    long long sp_y_;                    // 回転元座標(Y)
    long long diff_x_;                  // 回転元移動量(X)
    long long diff_y_;                  // 回転元移動量(Y)
    int srcRowBytes_;                   // 回転元の row bytes
}

// initialize
-(id)initDst:(unsigned char *)dp
     withSrc:(unsigned char *)sp
     dstRect:(PoCoRect *)dr
     srcRect:(PoCoRect *)sr
   srcPointX:(long long)sp_x
   srcPointY:(long long)sp_y
    srcDiffX:(long long)diff_x
    srcDiffY:(long long)diff_y
 srcRowBytes:(int)srow;

// deallocate
-(void)dealloc;

// 実行
-(void)execute;

@end


// ------------------------------------------------------------------ implement
@implementation PoCoRotateThread

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    sp     : 回転元
//    dp     : 回転先
//    sr     : 回転元範囲
//    dr     : 回転先範囲
//    sp_x   : 回転元座標(X)
//    sp_y   : 回転元座標(Y)
//    diff_x : 回転元移動量(X)
//    diff_y : 回転元移動量(Y)
//    srow   : 回転元の row bytes
//
//  Return
//    sp_          : 回転元(instance 変数)
//    dp_          : 回転先(instance 変数)
//    srcRect_     : 回転元範囲(instance 変数)
//    dstRect_     : 回転先範囲(instance 変数)
//    sp_x_        : 回転元座標(X)(instance 変数)
//    sp_y_        : 回転元座標(Y)(instance 変数)
//    diff_x_      : 回転元移動量(X)(instance 変数)
//    diff_y_      : 回転元移動量(Y)(instance 変数)
//    srcRowBytes_ : 回転元の row bytes(instance 変数)
//
-(id)initDst:(unsigned char *)dp
     withSrc:(unsigned char *)sp
     dstRect:(PoCoRect *)dr
     srcRect:(PoCoRect *)sr
   srcPointX:(long long)sp_x
   srcPointY:(long long)sp_y
    srcDiffX:(long long)diff_x
    srcDiffY:(long long)diff_y
 srcRowBytes:(int)srow
{
    DPRINT((@"[PoCoRotateThread init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->sp_ = sp;
        self->dp_ = dp;
        self->srcRect_ = sr;
        self->dstRect_ = dr;
        self->sp_x_ = sp_x;
        self->sp_y_ = sp_y;
        self->diff_x_ = diff_x;
        self->diff_y_ = diff_y;
        self->srcRowBytes_ = srow;

        [self->srcRect_ retain];
        [self->dstRect_ retain];
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
//    srcRect_ : 回転元範囲(instance 変数)
//    dstRect_ : 回転先範囲(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoRotateThreadDouble dealloc]\n"));

    // 資源を解放
    [self->srcRect_ release];
    [self->dstRect_ release];
    self->srcRect_ = nil;
    self->dstRect_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//
//  Call
//    sp_          : 回転元(instance 変数)
//    dp_          : 回転先(instance 変数)
//    srcRect_     : 回転元範囲(instance 変数)
//    dstRect_     : 回転先範囲(instance 変数)
//    sp_x_        : 回転元座標(X)(instance 変数)
//    sp_y_        : 回転元座標(Y)(instance 変数)
//    diff_x_      : 回転元移動量(X)(instance 変数)
//    diff_y_      : 回転元移動量(Y)(instance 変数)
//    srcRowBytes_ : 回転元の row bytes(instance 変数)
//
//  Return
//    dp_    : 回転先(instance 変数)
//    sp_x_  : 回転元座標(X)(instance 変数)
//    sp_y_  : 回転元座標(Y)(instance 変数)
//
-(void)execute
{
    int i;
    int dx;
    int x;
    int y;
    BOOL draw;

    DPRINT((@"[PoCoRotateThread execute]\n"));

    draw = NO;
    for (dx = [self->dstRect_ left]; dx <= [self->dstRect_ right]; (dx)++) {
        // 回転元画像の参照位置を算出
#if 0
        x = (int)((self->sp_x_ + 512) >> 10);
        y = (int)((self->sp_y_ + 512) >> 10);
#else   // 0
        x = (int)((self->sp_x_ + 512) / 1024);
        y = (int)((self->sp_y_ + 512) / 1024);
#endif  // 0
        if (([self->srcRect_ left] <= x) && (x <= [self->srcRect_  right]) &&
            ([self->srcRect_  top] <= y) && (y <= [self->srcRect_ bottom])) {
            x -= ([self->srcRect_ left]);
            y -= ([self->srcRect_ top]);
            i = ((y * self->srcRowBytes_) + x);
            *(self->dp_) = self->sp_[i];
            draw = YES;
        } else if (draw) {
            // 一度でも描画した後なら範囲外に抜けたことになる
            break;
        }

        // 次へ
        (self->dp_)++;
        self->sp_x_ += self->diff_x_;
        self->sp_y_ += self->diff_y_;
    }

    // 抜ける
    [NSThread exit];

    return;
}

@end




// ===================================================== PoCoRotateThreadDouble

// ------------------------------------------------------------------ interface
@interface PoCoRotateThreadDouble : NSObject
{
    unsigned char *sp1_;                // 回転元1
    unsigned char *sp2_;                // 回転元2
    unsigned char *dp1_;                // 回転先1
    unsigned char *dp2_;                // 回転先2
    PoCoRect *srcRect_;                 // 回転元範囲
    PoCoRect *dstRect_;                 // 回転先範囲
    long long sp_x_;                    // 回転元座標(X)
    long long sp_y_;                    // 回転元座標(Y)
    long long diff_x_;                  // 回転元移動量(X)
    long long diff_y_;                  // 回転元移動量(Y)
    int srcRowBytes_;                   // 回転元の row bytes
}

// initialize
-(id)initDst1:(unsigned char *)dp1
     withDst2:(unsigned char *)dp2
     withSrc1:(unsigned char *)sp1
     withSrc2:(unsigned char *)sp2
      dstRect:(PoCoRect *)dr
      srcRect:(PoCoRect *)sr
    srcPointX:(long long)sp_x
    srcPointY:(long long)sp_y
     srcDiffX:(long long)diff_x
     srcDiffY:(long long)diff_y
  srcRowBytes:(int)srow;

// deallocate
-(void)dealloc;

// 実行
-(void)execute;

@end


// ------------------------------------------------------------------ implement
@implementation PoCoRotateThreadDouble

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    sp1    : 回転元1
//    sp2    : 回転元2
//    dp1    : 回転先1
//    dp2    : 回転先2
//    sr     : 回転元範囲
//    dr     : 回転先範囲
//    sp_x   : 回転元座標(X)
//    sp_y   : 回転元座標(Y)
//    diff_x : 回転元移動量(X)
//    diff_y : 回転元移動量(Y)
//    srow   : 回転元の row bytes
//
//  Return
//    sp1_         : 回転元1(instance 変数)
//    sp2_         : 回転元2(instance 変数)
//    dp1_         : 回転先1(instance 変数)
//    dp2_         : 回転先2(instance 変数)
//    srcRect_     : 回転元範囲(instance 変数)
//    dstRect_     : 回転先範囲(instance 変数)
//    sp_x_        : 回転元座標(X)(instance 変数)
//    sp_y_        : 回転元座標(Y)(instance 変数)
//    diff_x_      : 回転元移動量(X)(instance 変数)
//    diff_y_      : 回転元移動量(Y)(instance 変数)
//    srcRowBytes_ : 回転元の row bytes(instance 変数)
//
-(id)initDst1:(unsigned char *)dp1
     withDst2:(unsigned char *)dp2
     withSrc1:(unsigned char *)sp1
     withSrc2:(unsigned char *)sp2
      dstRect:(PoCoRect *)dr
      srcRect:(PoCoRect *)sr
    srcPointX:(long long)sp_x
    srcPointY:(long long)sp_y
     srcDiffX:(long long)diff_x
     srcDiffY:(long long)diff_y
  srcRowBytes:(int)srow
{
    DPRINT((@"[PoCoRotateThreadDouble init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->sp1_ = sp1;
        self->sp2_ = sp2;
        self->dp1_ = dp1;
        self->dp2_ = dp2;
        self->srcRect_ = sr;
        self->dstRect_ = dr;
        self->sp_x_ = sp_x;
        self->sp_y_ = sp_y;
        self->diff_x_ = diff_x;
        self->diff_y_ = diff_y;
        self->srcRowBytes_ = srow;

        [self->srcRect_ retain];
        [self->dstRect_ retain];
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
//    srcRect_ : 回転元範囲(instance 変数)
//    dstRect_ : 回転先範囲(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoRotateThreadDouble dealloc]\n"));

    // 資源を解放
    [self->srcRect_ release];
    [self->dstRect_ release];
    self->srcRect_ = nil;
    self->dstRect_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//
//  Call
//    sp1_         : 回転元1(instance 変数)
//    sp2_         : 回転元2(instance 変数)
//    dp1_         : 回転先1(instance 変数)
//    dp2_         : 回転先2(instance 変数)
//    srcRect_     : 回転元範囲(instance 変数)
//    dstRect_     : 回転先範囲(instance 変数)
//    sp_x_        : 回転元座標(X)(instance 変数)
//    sp_y_        : 回転元座標(Y)(instance 変数)
//    diff_x_      : 回転元移動量(X)(instance 変数)
//    diff_y_      : 回転元移動量(Y)(instance 変数)
//    srcRowBytes_ : 回転元の row bytes(instance 変数)
//
//  Return
//    dp1_   : 回転先1(instance 変数)
//    dp2_   : 回転先2(instance 変数)
//    sp_x_  : 回転元座標(X)(instance 変数)
//    sp_y_  : 回転元座標(Y)(instance 変数)
//
-(void)execute
{
    int i;
    int dx;
    int x;
    int y;
    BOOL draw;

    DPRINT((@"[PoCoRotateThreadDouble execute]\n"));

    draw = NO;
    for (dx = [self->dstRect_ left]; dx <= [self->dstRect_ right]; (dx)++) {
        // 回転元画像の参照位置を算出
#if 0
        x = (int)((self->sp_x_ + 512) >> 10);
        y = (int)((self->sp_y_ + 512) >> 10);
#else   // 0
        x = (int)((self->sp_x_ + 512) / 1024);
        y = (int)((self->sp_y_ + 512) / 1024);
#endif  // 0
        if (([self->srcRect_ left] <= x) && (x <= [self->srcRect_  right]) &&
            ([self->srcRect_  top] <= y) && (y <= [self->srcRect_ bottom])) {
            x -= ([self->srcRect_ left]);
            y -= ([self->srcRect_ top]);
            i = ((y * self->srcRowBytes_) + x);
            *(self->dp1_) = self->sp1_[i];
            *(self->dp2_) = self->sp2_[i];
            draw = YES;
        } else if (draw) {
            // 一度でも描画した後なら範囲外に抜けたことになる
            break;
        }

        // 次へ
        (self->dp1_)++;
        (self->dp2_)++;
        self->sp_x_ += self->diff_x_;
        self->sp_y_ += self->diff_y_;
    }

    // 抜ける
    [NSThread exit];

    return;
}

@end




// ============================================================================
@implementation PoCoEditRotateBitmap

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    dbmp : 回転先画像
//    sbmp : 回転元画像
//    dr   : 回転先範囲
//    sr   : 回転元範囲
//    rot  : 回転関数
//
//  Return
//    function   : 実体
//    srcBitmap_ : 回転元画像(instance 関数)
//    dstBitmap_ : 回転先画像(instance 関数)
//    srcRect_   : 回転元範囲(instance 関数)
//    dstRect_   : 回転先範囲(instance 関数)
//    rotate_    : 回転関数(instance 変数)
//
-(id)initDst:(PoCoBitmap *)dbmp
     withSrc:(PoCoBitmap *)sbmp
     dstRect:(PoCoRect *)dr
     srcRect:(PoCoRect *)sr
 withRotater:(PoCoCalcRotation *)rot
{
    DPRINT((@"[PoCoEditRotateBitmap initDst withSrc]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->srcBitmap_ = sbmp;
        self->dstBitmap_ = dbmp;
        self->srcRect_ = sr;
        self->dstRect_ = dr;
        self->rotate_ = rot;
        [self->srcBitmap_ retain];
        [self->dstBitmap_ retain];
        [self->srcRect_ retain];
        [self->dstRect_ retain];
        [self->rotate_ retain];
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
//    srcBitmap_ : 回転元画像(instance 関数)
//    dstBitmap_ : 回転先画像(instance 関数)
//    srcRect_   : 回転元範囲(instance 関数)
//    dstRect_   : 回転先範囲(instance 関数)
//    rotate_    : 回転関数(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoEditRotateBitmap dealloc]\n"));

    // 資源の解放
    [self->srcBitmap_ release];
    [self->dstBitmap_ release];
    [self->srcRect_ release];
    [self->dstRect_ release];
    [self->rotate_ release];
    self->srcBitmap_ = nil;
    self->dstBitmap_ = nil;
    self->srcRect_ = nil;
    self->dstRect_ = nil;
    self->rotate_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//
//  Call
//    srcBitmap_ : 回転元画像(instance 関数)
//    dstBitmap_ : 回転先画像(instance 関数)
//    srcRect_   : 回転元範囲(instance 関数)
//    dstRect_   : 回転先範囲(instance 関数)
//    rotate_    : 回転関数(instance 変数)
//
//  Return
//    dstBitmap_ : 回転先画像(instance 関数)
//
-(void)executeRotate
#if 1   // thread 化
{
    int l;
    int cnt;
    BOOL flag;
    unsigned char *sp;
    unsigned char *dp;
    int srow = ([self->srcBitmap_ width] + ([self->srcBitmap_ width] & 0x01));
    int drow = ([self->dstBitmap_ width] + ([self->dstBitmap_ width] & 0x01));
    double x;
    double y;
    long long op_x;
    long long op_y;
    long long diff[4];
    id *scan;
    id *thread;

    scan = NULL;
    thread = NULL;
    sp = [self->srcBitmap_ pixelmap];
    dp = [self->dstBitmap_ pixelmap];

    // 回転先から回転元の左上原点を取得
    x = (double)([self->dstRect_ left]);
    y = (double)([self->dstRect_ top]);
    [self->rotate_ recalcPointHori:&(x)
                           andVert:&(y)];
    op_x = (long long)(x * 1024.0);
    op_y = (long long)(y * 1024.0);

    // 変量を取得
    [self->rotate_ diffInt:&(diff[0])];

    // 資源を確保
    cnt = (([self->dstRect_ bottom] - [self->dstRect_ top]) + 1);
    scan = (id *)(calloc(cnt, sizeof(id)));
    thread = (id *)(calloc(cnt, sizeof(id)));
    if ((scan == NULL) || (thread == NULL)) {
        goto EXIT;
    }

    // 回転先を垂直走査(垂直走査をすべて thread にする)
    for (l = 0; l < cnt; (l)++) {
        // 回転先を水平走査
        scan[l] = [[PoCoRotateThread alloc] initDst:dp
                                            withSrc:sp
                                            dstRect:self->dstRect_
                                            srcRect:self->srcRect_
                                          srcPointX:op_x
                                          srcPointY:op_y
                                           srcDiffX:diff[0]
                                           srcDiffY:diff[1]
                                        srcRowBytes:srow];
        thread[l] = [[NSThread alloc] initWithTarget:scan[l]
                                            selector:@selector(execute)
                                              object:nil];
        [thread[l] start];

        // 次へ
        dp += drow;
        op_x += diff[2];
        op_y += diff[3];
    }

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
    return;
}
#endif  // 1
#if 0   // 整数演算、水平走査は足し算のみ
{
    PoCoPoint *p;
    int dx;                             // 水平走査(回転先画像)
    int dy;                             // 垂直走査(回転先画像)
    unsigned char *sp;
    unsigned char *dp;
    int srow = ([self->srcBitmap_ width] + ([self->srcBitmap_ width] & 0x01));
    int dskip = ([self->dstBitmap_ width] & 0x01);
    double x;
    double y;
    long long op_x;
    long long op_y;
    long long sp_x;
    long long sp_y;
    long long diff[4];

    sp = [self->srcBitmap_ pixelmap];
    dp = [self->dstBitmap_ pixelmap];

    // 回転先から回転元の左上原点を取得
    x = (double)([self->dstRect_ left]);
    y = (double)([self->dstRect_ top]);
    [self->rotate_ recalcPointHori:&(x)
                           andVert:&(y)];
    op_x = (long long)(x * 1024.0);
    op_y = (long long)(y * 1024.0);

    // 変量を取得
    [self->rotate_ diffInt:&(diff[0])];

    // 回転先を垂直走査
    p = [[PoCoPoint alloc] init];
    for (dy = [self->dstRect_ top]; dy <= [self->dstRect_ bottom]; (dy)++) {
        // 回転先を水平走査
        sp_x = op_x;
        sp_y = op_y;
        for (dx = [self->dstRect_ left]; dx <= [self->dstRect_ right]; (dx)++) {
            // 回転元画像の参照位置を算出
#if 0
            [p setX:(int)((sp_x + 512) >> 10)
               setY:(int)((sp_y + 512) >> 10)];
#else   // 0
            [p setX:(int)((sp_x + 512) / 1024)
               setY:(int)((sp_y + 512) / 1024)];
#endif  // 0
            if (([self->srcRect_ left] <= [p x]) &&
                ([self->srcRect_ top] <= [p y]) &&
                ([p x] <= [self->srcRect_ right]) &&
                ([p y] <= [self->srcRect_ bottom])) {
                [p moveX:-([self->srcRect_ left])
                   moveY:-([self->srcRect_ top])];
                *(dp) = sp[(([p y] * srow) + [p x])];
            }

            // 次へ
            (dp)++;
            sp_x += diff[0];
            sp_y += diff[1];
        }

        // 次へ
        dp += dskip;
        op_x += diff[2];
        op_y += diff[3];
    }
    [p release];

    return;
}
#endif  // 0
#if 0   // 基本
{
    PoCoPoint *p;
    int dx;                             // 水平走査(回転先画像)
    int dy;                             // 垂直走査(回転先画像)
    unsigned char *sp;
    unsigned char *dp;
    int srow = ([self->srcBitmap_ width] + ([self->srcBitmap_ width] & 0x01));
    int dskip = ([self->dstBitmap_ width] & 0x01);

    sp = [self->srcBitmap_ pixelmap];
    dp = [self->dstBitmap_ pixelmap];

    // 回転先を垂直走査
    p = [[PoCoPoint alloc] init];
    for (dy = [self->dstRect_ top]; dy <= [self->dstRect_ bottom]; (dy)++) {
        // 回転先を水平走査
        for (dx = [self->dstRect_ left]; dx <= [self->dstRect_ right]; (dx)++) {
            // 回転元画像の参照位置を算出
            [p setX:dx
               setY:dy];
            [self->rotate_ recalcPoint:p];
            if (([self->srcRect_ left] <= [p x]) &&
                ([self->srcRect_ top] <= [p y]) &&
                ([p x] <= [self->srcRect_ right]) &&
                ([p y] <= [self->srcRect_ bottom])) {
                [p moveX:-([self->srcRect_ left])
                   moveY:-([self->srcRect_ top])];
                *(dp) = sp[(([p y] * srow) + [p x])];
            }

            // 次へ
            (dp)++;
        }

        // 次へ
        dp += dskip;
    }
    [p release];
#if 0
{
    int x;
    int y;
    unsigned char *p;

    printf("================================\n");
    printf("----------------\n");
    printf("width : %d, height: %d\n", [self->srcBitmap_ width], [self->srcBitmap_ height]);
    for (y = 0; y < [self->srcBitmap_ height]; (y)++) {
        p  = [self->srcBitmap_ pixelmap];
        p += (y * ([self->srcBitmap_ width] + ([self->srcBitmap_ width] & 0x01)));
        for (x = 0; x < [self->srcBitmap_ width]; (x)++) {
            printf("%c", ((*(p) != 0x00) ? '1' : '0'));
            (p)++;
        }
        printf("\n");
    }

    printf("----------------\n");
    printf("width : %d, height: %d\n", [self->dstBitmap_ width], [self->dstBitmap_ height]);
    for (y = 0; y < [self->dstBitmap_ height]; (y)++) {
        p  = [self->dstBitmap_ pixelmap];
        p += (y * ([self->dstBitmap_ width] + ([self->dstBitmap_ width] & 0x01)));
        for (x = 0; x < [self->dstBitmap_ width]; (x)++) {
            printf("%c", ((*(p) != 0x00) ? '1' : '0'));
            (p)++;
        }
        printf("\n");
    }
}
#endif  // 0

    return;
}
#endif  // 0

@end




// ============================================================================
@implementation PoCoEditRotateBitmapDouble

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    dbmp1 : 回転先画像1
//    dbmp2 : 回転先画像2
//    sbmp1 : 回転元画像1
//    sbmp2 : 回転元画像2
//    dr    : 回転先範囲
//    sr    : 回転元範囲
//    rot   : 回転関数
//
//  Return
//    function     : 実体
//    srcBitmap_[] : 回転元画像(instance 関数)
//    dstBitmap_[] : 回転先画像(instance 関数)
//    srcRect_     : 回転元範囲(instance 関数)
//    dstRect_     : 回転先範囲(instance 関数)
//    rotate_      : 回転関数(instance 変数)
//
-(id)initDst1:(PoCoBitmap *)dbmp1
     withDst2:(PoCoBitmap *)dbmp2
     withSrc1:(PoCoBitmap *)sbmp1
     withSrc2:(PoCoBitmap *)sbmp2
     dstRect:(PoCoRect *)dr
     srcRect:(PoCoRect *)sr
 withRotater:(PoCoCalcRotation *)rot
{
    DPRINT((@"[PoCoEditRotateBitmapDouble initDst withSrc]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->srcBitmap_[0] = sbmp1;
        self->srcBitmap_[1] = sbmp2;
        self->dstBitmap_[0] = dbmp1;
        self->dstBitmap_[1] = dbmp2;
        self->srcRect_ = sr;
        self->dstRect_ = dr;
        self->rotate_ = rot;
        [self->srcBitmap_[0] retain];
        [self->srcBitmap_[1] retain];
        [self->dstBitmap_[0] retain];
        [self->dstBitmap_[1] retain];
        [self->srcRect_ retain];
        [self->dstRect_ retain];
        [self->rotate_ retain];
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
//    srcBitmap_[] : 回転元画像(instance 関数)
//    dstBitmap_[] : 回転先画像(instance 関数)
//    srcRect_     : 回転元範囲(instance 関数)
//    dstRect_     : 回転先範囲(instance 関数)
//    rotate_      : 回転関数(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoEditRotateBitmapDouble dealloc]\n"));

    // 資源の解放
    [self->srcBitmap_[0] release];
    [self->srcBitmap_[1] release];
    [self->dstBitmap_[0] release];
    [self->dstBitmap_[1] release];
    [self->srcRect_ release];
    [self->dstRect_ release];
    [self->rotate_ release];
    self->srcBitmap_[0] = nil;
    self->srcBitmap_[1] = nil;
    self->dstBitmap_[0] = nil;
    self->dstBitmap_[1] = nil;
    self->srcRect_ = nil;
    self->dstRect_ = nil;
    self->rotate_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//
//  Call
//    srcBitmap_[] : 回転元画像(instance 関数)
//    dstBitmap_[] : 回転先画像(instance 関数)
//    srcRect_     : 回転元範囲(instance 関数)
//    dstRect_     : 回転先範囲(instance 関数)
//    rotate_      : 回転関数(instance 変数)
//
//  Return
//    dstBitmap_ : 回転先画像(instance 関数)
//
-(void)executeRotate
{
    int l;
    int cnt;
    BOOL flag;
    unsigned char *sp1;
    unsigned char *sp2;
    unsigned char *dp1;
    unsigned char *dp2;
    int srow = ([self->srcBitmap_[0] width] + ([self->srcBitmap_[0] width] & 0x01));
    int drow = ([self->dstBitmap_[0] width] + ([self->dstBitmap_[0] width] & 0x01));
    double x;
    double y;
    long long op_x;
    long long op_y;
    long long diff[4];
    id *scan;
    id *thread;

    scan = NULL;
    thread = NULL;
    sp1 = [self->srcBitmap_[0] pixelmap];
    sp2 = [self->srcBitmap_[1] pixelmap];
    dp1 = [self->dstBitmap_[0] pixelmap];
    dp2 = [self->dstBitmap_[1] pixelmap];

    // 回転先から回転元の左上原点を取得
    x = (double)([self->dstRect_ left]);
    y = (double)([self->dstRect_ top]);
    [self->rotate_ recalcPointHori:&(x)
                           andVert:&(y)];
    op_x = (long long)(x * 1024.0);
    op_y = (long long)(y * 1024.0);

    // 変量を取得
    [self->rotate_ diffInt:&(diff[0])];

    // 資源を確保
    cnt = (([self->dstRect_ bottom] - [self->dstRect_ top]) + 1);
    scan = (id *)(calloc(cnt, sizeof(id)));
    thread = (id *)(calloc(cnt, sizeof(id)));
    if ((scan == NULL) || (thread == NULL)) {
        goto EXIT;
    }

    // 回転先を垂直走査(垂直走査をすべて thread にする)
    for (l = 0; l < cnt; (l)++) {
        // 回転先を水平走査
        scan[l] = [[PoCoRotateThreadDouble alloc] initDst1:dp1
                                                  withDst2:dp2
                                                  withSrc1:sp1
                                                  withSrc2:sp2
                                                   dstRect:self->dstRect_
                                                   srcRect:self->srcRect_
                                                 srcPointX:op_x
                                                 srcPointY:op_y
                                                  srcDiffX:diff[0]
                                                  srcDiffY:diff[1]
                                               srcRowBytes:srow];
        thread[l] = [[NSThread alloc] initWithTarget:scan[l]
                                            selector:@selector(execute)
                                              object:nil];
        [thread[l] start];

        // 次へ
        dp1 += drow;
        dp2 += drow;
        op_x += diff[2];
        op_y += diff[3];
    }

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
    return;
}

@end
