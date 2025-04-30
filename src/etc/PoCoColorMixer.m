//
//	Pelistina on Cocoa - PoCo -
//	色混合
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoColorMixer.h"

#import "PoCoPalette.h"
#import "PoCoColorBuffer.h"

// ============================================================================
@implementation PoCoColorMixerUnit

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    e1 : 要素1
//    e2 : 要素2
//    e3 : 要素3
//
//  Return
//    e1_ : 要素1(instance 変数)
//    e2_ : 要素2(instance 変数)
//    e3_ : 要素3(instance 変数)
//
-(id)initWithElement1:(int)e1
         withElement2:(int)e2
         withElement3:(int)e3
{
    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->e1_ = e1;
        self->e2_ = e2;
        self->e3_ = e3;
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
    // 資源の解放
    ;

    // super class の解放
    [super dealloc];

    return;
}


//
// 取得(要素1)
//
//  Call
//    e1_ : 要素1(instance 変数)
//
//  Return
//    function : 値
//
-(int)element1
{
    return self->e1_;
}


//
// 取得(要素2)
//
//  Call
//    e2_ : 要素2(instance 変数)
//
//  Return
//    function : 値
//
-(int)element2;
{
    return self->e2_;
}


//
// 取得(要素3)
//
//  Call
//    e3_ : 要素3(instance 変数)
//
//  Return
//    function : 値
//
-(int)element3;
{
    return self->e3_;
}

@end




// ============================================================================
@implementation PoCoColorMixer

// ------------------------------------------------------------- class - public
//
// 色演算(2色混合の平均)
//
//  Call
//    palette : 使用パレット
//    colMode : 色演算モード
//    d2      : 濃度(0.1%単位)(塗装色(i2)用)
//    i1      : 色1(描画先色番号)
//    i2      : 色2(塗装色番号)
//    buffer  : 色保持
//              == nil : 使用しないで逐次検索
//              != nil : バッファを探索
//
//  Return
//    function : 塗装色
//
+(unsigned char)calcColor:(PoCoPalette *)palette
                  colMode:(PoCoColorMode)colMode
                 density2:(int)d2
                   color1:(unsigned char)i1
                   color2:(unsigned char)i2
                   buffer:(PoCoColorBuffer *)buffer
{
    unsigned char ch = i1;              // 初期値は描画先のまま
    int i;
    unsigned char e[3];                 // 色要素(RGB ないし HLS)
    unsigned char h[2];                 // 色相(0 : i1用、1 : i2用)
    PoCoColor *cd;                      // 候補(candidate)
    const unsigned int d1 = (1000 - d2);
    const PoCoColor *c1 = [palette palette:i1];
    const PoCoColor *c2 = [palette palette:i2];

    // 濃度100%の扱い
    if (d2 <= 0) {
        // 描画先の色のまま
        ;
        goto EXIT;
    } else if ((d2 >= 1000) && (!([[palette palette:i2] noDropper]))) {
        // 塗装色のみになる
        ch = i2;
        goto EXIT;
    }

    // 以前の演算と同じか
    if (buffer != nil) {
        i = [buffer findOnceCalc:colMode
                    withDensity1:d1
                    withDensity2:d2
                      withColor1:i1
                      withColor2:i2];
        if (i >= 0) {
            ch = (unsigned char)(i);
            goto EXIT;
        }
    }

    // 要素取得
    if (colMode == PoCoColorMode_RGB) {
        // RGB
        e[0] = ((([c1 red]   * d1) + ([c2 red]   * d2)) / 1000);
        e[1] = ((([c1 green] * d1) + ([c2 green] * d2)) / 1000);
        e[2] = ((([c1 blue]  * d1) + ([c2 blue]  * d2)) / 1000);
    } else {
        // HLS
        if ([c2 saturation] == 0) {
            // 塗装色が無彩色なので色は描画先にする
            e[0] = [c1 hue];
            e[2] = [c1 saturation];
        } else if ([c1 saturation] == 0) {
            // 描画先が無彩色なので色は塗装色にする
            e[0] = [c2 hue];
            e[2] = [c2 saturation];
        } else {
            // 中間色をとる
            h[0] = [c1 hue];
            h[1] = [c2 hue];
            if (h[1] < h[0]) {
                if ((h[0] - h[1]) <= (256 - h[0] + h[1])) {
                    i = (h[0] - (((h[0] - h[1]) * d2) / 1000));
                } else {
                    i = (h[0] + (((256 - h[0] + h[1]) * d2) / 1000));
                }
            } else {
                if ((h[1] - h[0]) <= (256 - h[1] + h[0])) {
                    i = (h[0] + (((h[1] - h[0]) * d2) / 1000));
                } else {
                    i = (h[0] - (((255 - h[1] + h[0]) * d2) / 1000));
                }
            }
            if (i < 0) {
                i += 255;
            } else if (i > 255) {
                i -= 255;
            }

            e[0] = (unsigned char)(i);
            e[2] = ((([c1 saturation] * d1) + ([c2 saturation] * d2)) / 1000);
        }
        e[1] = ((([c1 lightness] * d1) + ([c2 lightness] * d2)) / 1000);

        // RGB に戻す
        cd = [[PoCoColor alloc] init];
        [cd setHue:e[0] setLightness:e[1] setSaturation:e[2]];
        e[0] = [cd red];
        e[1] = [cd green];
        e[2] = [cd blue];
        [cd release];
    }
 
    // 色検索
    if (buffer != nil) {
        // 保持している色から探す
        ch = [buffer findWithBuffer:palette
                            withRed:e[0]
                          withGreen:e[1]
                           withBlue:e[2]];

        // 以前の演算結果として記憶
        [buffer addOnceCalc:colMode
               withDensity1:d1
               withDensity2:d2
                 withColor1:i1
                 withColor2:i2
                 withResult:ch];
    } else {
        // 逐次探索
        ch = [PoCoColorBuffer find:palette
                           withRed:e[0]
                         withGreen:e[1]
                          withBlue:e[2]];
    }
    
EXIT:
    return ch;
}


//
// 色演算(任意個数の平均)
//  RGB 演算
//
//  Call
//    palette : 使用パレット
//    cols    : 対象の色群
//    buffer  : 色保持
//              == nil : 使用しないで逐次検索
//              != nil : バッファを探索
//    org     : 演算中心の色番号
//
//  Return
//    function : 塗装色
//
+(unsigned char)calcColorRGB:(PoCoPalette *)palette
                  withColors:(NSArray *)cols
                      buffer:(PoCoColorBuffer *)buffer
                    orgColor:(unsigned char)org
{
    unsigned char ch = org;
    NSEnumerator *iter;
    PoCoColorMixerUnit *c;
    float r;
    float g;
    float b;

    iter = [cols objectEnumerator];

    // 順番に足す
    c = [iter nextObject];
    r = ((float)([c element1]) / 255.0);
    g = ((float)([c element2]) / 255.0);
    b = ((float)([c element3]) / 255.0);
    for (c = [iter nextObject]; c != nil; c = [iter nextObject]) {
        r += ((float)([c element1]) / 255.0);
        g += ((float)([c element2]) / 255.0);
        b += ((float)([c element3]) / 255.0);
    }

    // 平均値算出
    r = ((r / (float)([cols count])) * 255.0);
    g = ((g / (float)([cols count])) * 255.0);
    b = ((b / (float)([cols count])) * 255.0);

    // 色検索
    if (buffer != nil) {
        // 保持している色から探す
        ch = [buffer findWithBuffer:palette
                            withRed:(int)(floor(r))
                          withGreen:(int)(floor(g))
                           withBlue:(int)(floor(b))];
    } else {
        // 逐次探索
        ch = [PoCoColorBuffer find:palette
                           withRed:(int)(floor(r))
                         withGreen:(int)(floor(g))
                          withBlue:(int)(floor(b))];
    }

    return ch;
}


//
// 色演算(任意個数の平均)
//  HLS 演算
//
//  Call
//    palette : 使用パレット
//    cols    : 対象の色群
//    buffer  : 色保持
//              == nil : 使用しないで逐次検索
//              != nil : バッファを探索
//    org     : 演算中心の色番号
//
//  Return
//    function : 塗装色
//
+(unsigned char)calcColorHLS:(PoCoPalette *)palette
                  withColors:(NSArray *)cols
                      buffer:(PoCoColorBuffer *)buffer
                    orgColor:(unsigned char)org
{
    unsigned char ch = org;
    NSEnumerator *iter;
    PoCoColorMixerUnit *c;
    int h;
    float l;
    float s;
    int cnum;
    int hbuf;
    int rbuf;
    int bbuf;
    PoCoColor *cd;

    iter = [cols objectEnumerator];
    cnum = 0;

    // 順番に足す
    h = [[palette palette:org] hue];
    l = 0.0;
    s = 0.0;
    bbuf = [[palette palette:org] saturation];
    rbuf = ((bbuf == 0) ? -1 : 0);
    for (c = [iter nextObject]; c != nil; c = [iter nextObject]) {
        hbuf = [c element1];
        if (bbuf == 0) {
            if (rbuf < 0) {
                if ([c element3] > 0) {
                    rbuf = hbuf;
                    (cnum)++;
                }
            } else if ([c element3] > 0) {
                if (hbuf < rbuf) {
                    if ((rbuf - hbuf) < (255 - rbuf + hbuf)) {
                        rbuf = ((rbuf + hbuf) >> 1);
                    } else {
                        rbuf += ((255 - rbuf + hbuf) >> 1);
                        if (rbuf > 255) {
                            rbuf -= 255;
                        }
                    }
                } else {
                    if ((hbuf - rbuf) < (255 - hbuf + rbuf)) {
                        rbuf = ((rbuf + hbuf) >> 1);
                    } else {
                        rbuf -= ((255 - hbuf + rbuf) >> 1);
                        if (rbuf < 0) {
                            rbuf += 255;
                        }
                    }
                }
                s += ((float)([c element3]) / 255.0);
                (cnum)++;
            }
        } else if ([c element3] > 0) {
            if (h < hbuf) {
                if ((hbuf - h) <= (256 - hbuf + h)) {
                    rbuf += ((hbuf - h) >> 1);
                } else {
                    rbuf += ((hbuf - 255 - h) >> 1);
                }
            } else {
                if ((h - hbuf) <= (256 - h + hbuf)) {
                    rbuf += ((hbuf - h) >> 1);
                } else {
                    rbuf += ((255 - h + hbuf) >> 1);
                }
            }
            s += ((float)([c element3]) / 255.0);
            (cnum)++;
        }
        l += ((float)([c element2]) / 255.0);
    }

    // 平均値算出
    if (cnum > 0) {
        if (bbuf == 0) {
            h = rbuf;
        } else {
            h += (rbuf / cnum);
        }
        l = ((l / (float)([cols count])) * 255.0);
        s = ((s / (float)(cnum)) * 255.0);
        if (h < 0) {
            h += 255;
        } else if (h > 255) {
            h -= 255;
        }

        // 色検索
        cd = [[PoCoColor alloc] init];
        [cd setHue:h setLightness:(int)(floor(l)) setSaturation:(int)(floor(s))];
        if (buffer != nil) {
            // 保持している色から探す
            ch = [buffer findWithBuffer:palette
                                withRed:[cd red]
                              withGreen:[cd green]
                               withBlue:[cd blue]];
        } else {
            // 逐次探索
            ch = [PoCoColorBuffer find:palette
                               withRed:[cd red]
                             withGreen:[cd green]
                              withBlue:[cd blue]];
        }
        [cd release];
    }

    return ch;
}

@end
