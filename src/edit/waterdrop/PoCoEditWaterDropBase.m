//
// PoCoEditWaterDropBase.h
// implementation of PoCoEditWaterDropBase class.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoEditWaterDropBase.h"

#import "PoCoColorMixer.h"

// ============================================================================
@implementation PoCoEditWaterDropBase

// ----------------------------------------------------------------------------
// instance - public.

//
// initialise.
//
//  Call:
//    bmp   : 描画対象 bitmap
//    cmode : 色演算モード
//    plt   : 使用パレット
//    buf   : 色保持情報
//
//  Return:
//    function     : 実体
//    srcBitmap_   : 描画元(複製)(instance 変数)
//    dstBitmap_   : 描画先(instance 変数)
//    colMode_     : 色演算モード(instance 変数)
//    cols_        : 色群(instance 変数)
//    palette_     : 使用パレット(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//    rowBytes_    : row bytes(instance 変数)
//
- (id)initWithBitmap:(PoCoBitmap *)bmp
             colMode:(PoCoColorMode)cmode
             palette:(PoCoPalette *)plt
              buffer:(PoCoColorBuffer *)buf
{
//    DPRINT((@"[PoCoEditWaterDropBase initWithPattern]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->srcBitmap_ = nil;
        self->cols_ = nil;

        // 保持
        self->dstBitmap_ = bmp;
        self->colMode_ = cmode;
        self->palette_ = plt;
        self->colorBuffer_ = buf;
        [self->dstBitmap_ retain];
        [self->palette_ retain];
        [self->colorBuffer_ retain];

        // row bytes を算出
        self->rowBytes_ = ([bmp width] + ([bmp width] & 0x01));

        // 資源を生成
        self->srcBitmap_ = [bmp copy];
        if (self->srcBitmap_ == nil) {
            DPRINT((@"can't alloc source bitmap.\n"));
            [self release];
            self = nil;
            goto EXIT;
        }
        self->cols_ = [[NSMutableArray alloc] init];
        if (self->cols_ == nil) {
            DPRINT((@"can't alloc array.\n"));
            [self release];
            self = nil;
            goto EXIT;
        }
    }

EXIT:
    return self;
}


//
// deallocate.
//
//  Call:
//    none.
//
//  Return:
//    srcBitmap_   : 描画元(複製)(instance 変数)
//    dstBitmap_   : 描画先(instance 変数)
//    cols_        : 色群(instance 変数)
//    palette_     : 使用パレット(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//
- (void)dealloc
{
//    DPRINT((@"[PoCoEditWaterDropBase dealloc]\n"));

    // 資源の解放
    [self->srcBitmap_ release];
    [self->dstBitmap_ release];
    [self->cols_ removeAllObjects];
    [self->cols_ release];
    [self->palette_ release];
    [self->colorBuffer_ release];
    self->srcBitmap_ = nil;
    self->dstBitmap_ = nil;
    self->cols_ = nil;
    self->palette_ = nil;
    self->colorBuffer_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// calculate colour.
//
//  Call:
//    p            : 描画中心
//    dr           : 描画領域
//    mask         : 形状(nil 許容)
//    srcBitmap_   : 描画元(複製)(instance 変数)
//    dstBitmap_   : 描画先(instance 変数)
//    colMode_     : 色演算モード(instance 変数)
//    cols_        : 色群(instance 変数)
//    palette_     : 使用パレット(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//    rowBytes_    : row bytes(instance 変数)
//
//  Return:
//    dstBitmap_ : 描画先(instance 変数)
//
- (void)calcColor:(PoCoPoint *)p
     withDrawRect:(PoCoRect *)dr
         withMask:(PoCoBitmap *)mask
{
    PoCoRect *r;
    unsigned char *sbmp;
    const unsigned char *mbmp;
    int idx;
    int x;
    int y;
    int sskip;
    int mrow;
    int mskip_x;
    int mskip_y;
    PoCoColor *c;
    unsigned char ch;
    PoCoColorMixerUnit *elm;
    PoCoPoint *dp;

    r = nil;

    // そもそも描画範囲外なら何もしない
    if (!([dr isPointInRect:p])) {
        goto EXIT;
    }

    // 以前の内容を忘れる
    [self->cols_ removeAllObjects];

    // 中心を取得
    idx = (([p y] * self->rowBytes_) + [p x]);

    // 描画先が塗装できないなら何もしない
    ch = *([self->srcBitmap_ pixelmap] + idx);
    c = [self->palette_ palette:ch];
    if (([c isMask]) || ([c noDropper])) {
        goto EXIT;
    }

    // 走査範囲を取得
    r = [[PoCoRect alloc] initLeft:MAX(([p x] - 1), 0)
                           initTop:MAX(([p y] - 1), 0)
                         initRight:MIN(([p x] + 2), [self->srcBitmap_ width])
                        initBottom:MIN(([p y] + 2), [self->srcBitmap_ height])];
    sbmp  = [self->srcBitmap_ pixelmap];
    sbmp += (([r top] * self->rowBytes_) + [r left]);
    sskip = (self->rowBytes_ - [r width]);
    if (mask != nil) {
        mrow = ([mask width] + ([mask width] & 1));
        mskip_x = 1;
        mskip_y = (mrow - [r width]);      
        mbmp = ([mask pixelmap] + ((([r top] - [dr top]) * mrow) + ([r left] - [dr left])));
    } else {
        mrow = 0;
        mskip_x = 0;
        mskip_y = 0;
        mbmp = NULL;
    }

    // 走査
    dp = [[PoCoPoint alloc] initX:[r left] 
                            initY:[r top]];
    y = [r height];
    do {
        [dp setX:[r left]];
        x = [r width];
        do {
            // whether the drawing point is located within the drawing rectangle.
            if ([dr isPointInRect:dp]) {
                // 色を取得
                c = [self->palette_ palette:*(sbmp)];
                if ([c noDropper]) {
                    // 使用禁止は除外
                    ;
                } else if ((mask != nil) &&
                           (mbmp != NULL) &&
                           (*(mbmp) == 0)) {
                    // 形状の範囲外も除外
                    ;
                } else {
                    if (self->colMode_ == PoCoColorMode_RGB) {
                        // RGB
                        elm = [[PoCoColorMixerUnit alloc]
                                  initWithElement1:[c red]
                                      withElement2:[c green]
                                      withElement3:[c blue]];
                    } else {
                        // HLS
                        elm = [[PoCoColorMixerUnit alloc]
                                  initWithElement1:[c hue]
                                      withElement2:[c lightness]
                                      withElement3:[c saturation]];
                    }
                    [self->cols_ addObject:elm];
                    [elm release];
                }
            }

            // 次へ
            [dp moveX:1];
            (x)--;
            (sbmp)++;
            mbmp += mskip_x;
        } while (x != 0);

        // 次へ
        [dp moveY:1];
        (y)--;
        sbmp += sskip;
        mbmp += mskip_y;
    } while (y != 0);
    [dp release];

    // 色を算出、描画
    if (self->colMode_ == PoCoColorMode_RGB) {
        // RGB
        ch = [PoCoColorMixer calcColorRGB:self->palette_
                               withColors:self->cols_
                                   buffer:self->colorBuffer_
                                 orgColor:ch];
    } else {
        // HLS
        ch = [PoCoColorMixer calcColorHLS:self->palette_
                               withColors:self->cols_
                                   buffer:self->colorBuffer_
                                 orgColor:ch];
    }
    *([self->dstBitmap_ pixelmap] + idx) = ch;

EXIT:
    [r release];
    return;
}

@end
