//
//	Pelistina on Cocoa - PoCo -
//	palette 宣言
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import "PoCoPalette.h"

#import "PoCoPNG.h"

// 内部マクロ
#define RGBtoUW(r,g,b)  (((r) << 16) | ((g) << 8) | (b))
#define HLStoUW(h,l,s)  (((h) << 16) | ((l) << 8) | (s))
#define UWtoR(i)  (((i) & 0x00ff0000) >> 16)
#define UWtoG(i)  (((i) & 0x0000ff00) >> 8)
#define UWtoB(i)  ((i) & 0x000000ff)
#define UWtoH(i)  (((i) & 0x00ff0000) >> 16)
#define UWtoL(i)  (((i) & 0x0000ff00) >> 8)
#define UWtoS(i)  ((i) & 0x000000ff)
#ifdef  __LITTLE_ENDIAN__
#define RGBtoWCHAR(r,g,b) ((0xff000000) | ((b) << 16) | ((g) << 8) | (r))
#else   // __LITTLE_ENDIAN__
#define RGBtoWCHAR(r,g,b) (((r) << 24) | ((g) << 16) | ((b) << 8) | (0xff))
#endif  // __LITTLE_ENDIAN__


// 内部変数
static const unsigned int defaultPalette[COLOR_MAX] = { // 初期値のtable
        0x00000000, 0x0000009f, 0x0000ef00, 0x0000efef,
        0x00ff0000, 0x00ef00ff, 0x00dfdf00, 0x007f7f9f,
        0x00dfdfdf, 0x007f9fff, 0x00bfffaf, 0x00cfffff,
        0x00ff6f6f, 0x00ef8fff, 0x00efff9f, 0x00ffffff, // 0
        0x00000000, 0x0000007f, 0x007f0000, 0x007f007f,
        0x00007f00, 0x00007f7f, 0x007f7f00, 0x007f7f7f,
        0x005f5f5f, 0x000000ff, 0x00ff0000, 0x00ff00ff,
        0x0000ff00, 0x0000ffff, 0x00ffff00, 0x00ffffff, // 1

        0x00000000, 0x00000011, 0x00000022, 0x00000033,
        0x00000044, 0x00000055, 0x00000066, 0x00000077,
        0x00000088, 0x00000099, 0x000000aa, 0x000000bb,
        0x000000cc, 0x000000dd, 0x000000ee, 0x000000ff, // 3
        0x000000ff, 0x001111ff, 0x002222ff, 0x003333ff,
        0x004444ff, 0x005555ff, 0x006666ff, 0x007777ff,
        0x008888ff, 0x009999ff, 0x00aaaaff, 0x00bbbbff,
        0x00ccccff, 0x00ddddff, 0x00eeeeff, 0x00ffffff, // 4

        0x00000000, 0x00110000, 0x00220000, 0x00330000,
        0x00440000, 0x00550000, 0x00660000, 0x00770000,
        0x00880000, 0x00990000, 0x00aa0000, 0x00bb0000,
        0x00cc0000, 0x00dd0000, 0x00ee0000, 0x00ff0000, // 5
        0x00ff0000, 0x00ff1111, 0x00ff2222, 0x00ff3333,
        0x00ff4444, 0x00ff5555, 0x00ff6666, 0x00ff7777,
        0x00ff8888, 0x00ff9999, 0x00ffaaaa, 0x00ffbbbb,
        0x00ffcccc, 0x00ffdddd, 0x00ffeeee, 0x00ffffff, // 6

        0x00000000, 0x00110011, 0x00220022, 0x00330033,
        0x00440044, 0x00550055, 0x00660066, 0x00770077,
        0x00880088, 0x00990099, 0x00aa00aa, 0x00bb00bb,
        0x00cc00cc, 0x00dd00dd, 0x00ee00ee, 0x00ff00ff, // 7
        0x00ff00ff, 0x00ff11ff, 0x00ff22ff, 0x00ff33ff,
        0x00ff44ff, 0x00ff55ff, 0x00ff66ff, 0x00ff77ff,
        0x00ff88ff, 0x00ff99ff, 0x00ffaaff, 0x00ffbbff,
        0x00ffccff, 0x00ffddff, 0x00ffeeff, 0x00ffffff, // 8

        0x00000000, 0x00001100, 0x00002200, 0x00003300,
        0x00004400, 0x00005500, 0x00006600, 0x00007700,
        0x00008800, 0x00009900, 0x0000aa00, 0x0000bb00,
        0x0000cc00, 0x0000dd00, 0x0000ee00, 0x0000ff00, // 9
        0x0000ff00, 0x0011ff11, 0x0022ff22, 0x0033ff33,
        0x0044ff44, 0x0055ff55, 0x0066ff66, 0x0077ff77,
        0x0088ff88, 0x0099ff99, 0x00aaffaa, 0x00bbffbb,
        0x00ccffcc, 0x00ddffdd, 0x00eeffee, 0x00ffffff, // 10

        0x00000000, 0x00001111, 0x00002222, 0x00003333,
        0x00004444, 0x00005555, 0x00006666, 0x00007777,
        0x00008888, 0x00009999, 0x0000aaaa, 0x0000bbbb,
        0x0000cccc, 0x0000dddd, 0x0000eeee, 0x0000ffff, // 11
        0x0000ffff, 0x0011ffff, 0x0022ffff, 0x0033ffff,
        0x0044ffff, 0x0055ffff, 0x0066ffff, 0x0077ffff,
        0x0088ffff, 0x0099ffff, 0x00aaffff, 0x00bbffff,
        0x00ccffff, 0x00ddffff, 0x00eeffff, 0x00ffffff, // 12

        0x00000000, 0x00111100, 0x00222200, 0x00333300,
        0x00444400, 0x00555500, 0x00666600, 0x00777700,
        0x00888800, 0x00999900, 0x00aaaa00, 0x00bbbb00,
        0x00cccc00, 0x00dddd00, 0x00eeee00, 0x00ffff00, // 13
        0x00ffff00, 0x00ffff11, 0x00ffff22, 0x00ffff33,
        0x00ffff44, 0x00ffff55, 0x00ffff66, 0x00ffff77,
        0x00ffff88, 0x00ffff99, 0x00ffffaa, 0x00ffffbb,
        0x00ffffcc, 0x00ffffdd, 0x00ffffee, 0x00ffffff, // 14

        0x00000000, 0x00080808, 0x00101010, 0x00181818,
        0x00202020, 0x00292929, 0x00313131, 0x00393939,
        0x00414141, 0x004a4a4a, 0x00525252, 0x005a5a5a,
        0x00626262, 0x006a6a6a, 0x00737373, 0x007b7b7b, // 15
        0x00838383, 0x008b8b8b, 0x00949494, 0x009c9c9c,
        0x00a4a4a4, 0x00acacac, 0x00b4b4b4, 0x00bdbdbd,
        0x00c5c5c5, 0x00cdcdcd, 0x00d5d5d5, 0x00dedede,
        0x00e6e6e6, 0x00eeeeee, 0x00f6f6f6, 0x00ffffff  // 16
    };


// 内部関数プロトタイプ
static unsigned int rgb_to_hls(unsigned int rgb);
static int to_rgb(int h, double t1, double t2);
static unsigned int hls_to_rgb(unsigned int hls);


// ------------------------------------------------------------------- 内部関数
//
// RGB から HLS へ変換
//
//  Call
//    rgb : RGB 値
//          ---- ---- RRRR RRRR GGGG GGGG BBBB BBBB
//
//  Return
//    hls : HLS 値
//          ---- ---- HHHH HHHH LLLL LLLL SSSS SSSS
//
static unsigned int rgb_to_hls(unsigned int rgb)
{
    int h;                              // 色相
    int l;                              // 明度
    int s;                              // 彩度
    int max;                            // 3要素の最大値
    int min;                            // 3要素の最小値
    int df;                             // 差分
    const int r = UWtoR(rgb);
    const int g = UWtoG(rgb);
    const int b = UWtoB(rgb);

    // 3要素の最大値を算出
    max = (r >= g) ? r : g;
    if (b > max) {
        max = b;
    }

    // 3要素の最小値を算出
    min = (r <= g) ? r : g;
    if (b < min) {
        min = b;
    }

    // 明度を算出
    l = ((max + min) >> 1);

    // 彩度を算出
    df = max - min;
    if (df == 0) {
        // 彩度無し
        s = 0;
        h = 0;                          // 色相も無しにする
    } else {
        // 彩度あり
        if (l < 0x0080) {
            s = (df * 0x00ff) / (max + min);
        } else {
            s = (df * 0x00ff) / ((0x00ff + 0x00ff) - (max + min));
        }

        // 色相を算出(一旦360°表記にする)
        h = 0;
        if (r == max) {
            h = (g - b) * 60 / df;
        } else if (g == max) {
            h = 120 + (b - r) * 60 / df;
        } else if (b == max) {
            h = 240 + (r - g) * 60 / df;
        }
        if (h < 0) {
            h += 360;
        } else if (h >= 360) {
            h -= 360;
        }

        // 彩度を値の範囲内におさめる
        h = h * 256 / 360;
    }

    return HLStoUW(h, l, s);
}


//
// 色相/明度/彩度から値の抽出
//  hls_to_rgb の補助関数
//
//  Call
//    h  : 色相
//    t1 : 明度/彩度の反映用パラメータ
//    t2 : 明度/彩度の反映用パラメータ
//
//  Return
//    function : 算出された値
//
static int to_rgb(int h, double t1, double t2)
{
    int c;

    if (h >= 360) {
        h -= 360;
    } else if (h < 0) {
        h += 360;
    }

    if (h < 60) {
        c = (int)(floor(t1 + (t2 - t1) * (double)(h) / 60.0));
    } else if (h < 180) {
        c = (int)(floor(t2));
    } else if (h < 240) {
        c = (int)(floor(t1 + (t2 - t1) * (240.0 - (double)(h)) / 60.0));
    } else {
        c = (int)(floor(t1));
    }

    return c;
}


//
// HLS から RGB へ変換
//
//  Call
//    hls : HLS 値
//          ---- ---- HHHH HHHH LLLL LLLL SSSS SSSS
//
//  Return
//    rgb : RGB 値
//          ---- ---- RRRR RRRR GGGG GGGG BBBB BBBB
//
static unsigned int hls_to_rgb(unsigned int hls)
{
    int r;                              // 赤
    int g;                              // 緑
    int b;                              // 青
    double t1;                          // 明度/彩度の反映用
    double t2;                          // 明度/彩度の反映用
    const int h = (UWtoH(hls) * 360 / 256);
    const int l = UWtoL(hls);
    const int s = UWtoS(hls);

    if (s == 0) {
        // 彩度がないので明度のみ反映
        r = l;
        g = l;
        b = l;
    } else {
        // 明度/彩度の反映用パラメータの算出
        if (l < 0x0080) {
            t2 = (double)(l) * (255.0 + (double)(s)) / 255.0;
        } else {
            t2 = (double)(l) + (double)(s) - ((double)(l) * (double)(s)) / 255.0;
        }
        t1 = (double)(l) * 2.0 - t2;

        // RGB3要素を算出
        r = to_rgb(h + 120, t1, t2);
        g = to_rgb(h,       t1, t2);
        b = to_rgb(h - 120, t1, t2);
    }

    return RGBtoUW(r, g, b);
}




// ============================================================================
@implementation PoCoColor

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function  : 実体
//
-(id)init
{
    return [self initRed:0x00
                   Green:0x00
                    Blue:0x00
        withPaletteTable:NULL
          withTransTable:NULL];
}


//
// initialize(指定イニシャライザ)
//  色の初期値指定つき(RGB 指定のみ)
//
//  Call
//    r   : 赤
//    g   : 緑
//    b   : 青
//    pal : != NULL : palette 要素値の保管先
//          == NULL : 保管先指定なし
//    trn : != NULL : 透過指定の保管先
//          == NULL : 保管先指定なし
//
//  Return
//    function      : 実体
//    red_          : 赤(instance 変数)
//    green_        : 青(instance 変数)
//    blue_         : 緑(instance 変数)
//    isTrans_      : 透過指定(instance 変数)
//    noDropper_    : 吸い取り禁止指定(instance 変数)
//    isMask_       : 上書き禁止指定(instance 変数)
//    paletteTable_ : palette 要素値の保管先(instance 変数)
//    transTable_   : 透過指定の保管先(instance 変数)
//
-(id)initRed:(unsigned char)r
       Green:(unsigned char)g
        Blue:(unsigned char)b
withPaletteTable:(wchar_t *)pal
  withTransTable:(BOOL *)trn
{
//    DPRINT((@"[PoCoColor init]\n"));

    // super class を初期化
    self = [super init];

    // 自身を初期化
    if (self != nil) {
        self->red_ = r;
        self->green_ = g;
        self->blue_ = b;
        self->isTrans_ = NO;
        self->noDropper_ = NO;
        self->isMask_ = NO;

        self->paletteTable_ = pal;
        if (self->paletteTable_ != NULL) {
            *(self->paletteTable_) = RGBtoWCHAR(self->red_, self->green_, self->blue_);
        }
        self->transTable_ = trn;
        if (self->transTable_ != NULL) {
            *(self->transTable_) = (self->isTrans_) ? NO : YES;   // 反転させる
        }
    }

    return self;
}


//
// initialize(複製)
//
//  Call
//    zone          : zone(api 変数)
//    red_          : 赤(instance 変数)
//    green_        : 青(instance 変数)
//    blue_         : 緑(instance 変数)
//    isTrans_      : 透過指定(instance 変数)
//    noDropper_    : 吸い取り禁止指定(instance 変数)
//    isMask_       : 上書き禁止指定(instance 変数)
//    paletteTable_ : palette 要素値の保管先(instance 変数)
//    transTable_   : 透過指定の保管先(instance 変数)
//
//  Return
//    function : 実体(複製した実体)
//
-(id)copyWithZone:(NSZone *)zone
{
    PoCoColor *copy;

    DPRINT((@"[PoCoColor copyWithZone:%p]\n", zone));

    // 複製を生成
    copy = [[[self class] allocWithZone:zone]
                        initRed:[self red]
                          Green:[self green]
                           Blue:[self blue]
               withPaletteTable:self->paletteTable_
                 withTransTable:self->transTable_];

    // 補助属性を設定
    [copy setMask:[self isMask]];
    [copy setDropper:[self noDropper]];
    [copy setTrans:[self isTrans]];

    return copy;
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
//    DPRINT((@"[PoCoColor dealloc]\n"));

    // super class の解放
    [super dealloc];

    return;
}


//
// 一致確認
//
//  Call
//    target     : 比較対象
//    attrFlag   : 色成分以外も検査対象にするか
//                 YES : 対象に含める
//                 NO  : 対象に含めない
//    red_       : 赤(instance 変数)
//    green_     : 青(instance 変数)
//    blue_      : 緑(instance 変数)
//    isTrans_   : 透過指定(instance 変数)
//    noDropper_ : 吸い取り禁止指定(instance 変数)
//    isMask_    : 上書き禁止指定(instance 変数)
//
//  Return
//    function : 結果
//               YES : すべて一致
//               NO  : 一致しないものあり
//
-(BOOL)isEqualColor:(PoCoColor *)target
          checkAttr:(BOOL)attrFlag
{
    return ((self->red_   == [target red]  ) &&
            (self->green_ == [target green]) &&
            (self->blue_  == [target blue] ) &&
            ((!(attrFlag)) || ((self->isTrans_   == [target isTrans]  ) &&
                               (self->noDropper_ == [target noDropper]) &&
                               (self->isMask_    == [target isMask]   ))));
}


//
// 値の参照(赤)
//
//  Call
//    red_ : 赤(instance 変数)
//
//  Return
//    function : 値
//
-(unsigned char)red
{
    return self->red_;
}


//
// 値の参照(緑)
//
//  Call
//    green_ : 緑(instance 変数)
//
//  Return
//    function : 値
//
-(unsigned char)green
{
    return self->green_;
}


//
// 値の参照(青)
//
//  Call
//    blue_ : 緑(instance 変数)
//
//  Return
//    function : 値
//
-(unsigned char)blue
{
    return self->blue_;
}


//
// 値の参照(色相)
//  変換した値が取得される
//
//  Call
//    red_   : 赤(instance 変数)
//    green_ : 青(instance 変数)
//    blue_  : 緑(instance 変数)
//
//  Return
//    function : 値
//
-(unsigned char)hue
{
    return UWtoH(rgb_to_hls(RGBtoUW(self->red_, self->green_, self->blue_)));
}


//
// 値の参照(明度)
//  変換した値が取得される
//
//  Call
//    red_   : 赤(instance 変数)
//    green_ : 青(instance 変数)
//    blue_  : 緑(instance 変数)
//
//  Return
//    function : 値
//
-(unsigned char)lightness
{
    return UWtoL(rgb_to_hls(RGBtoUW(self->red_, self->green_, self->blue_)));
}


//
// 値の参照(彩度)
//  変換した値が取得される
//
//  Call
//    red_   : 赤(instance 変数)
//    green_ : 青(instance 変数)
//    blue_  : 緑(instance 変数)
//
//  Return
//    function : 値
//
-(unsigned char)saturation
{
    return UWtoS(rgb_to_hls(RGBtoUW(self->red_, self->green_, self->blue_)));
}


//
// 値の参照(実数表記の赤)
//
//  Call
//    red_ : 赤(instance 変数)
//
//  Retuen
//    function : 値
//
-(float)floatRed
{
    return ((float)(self->red_) / (float)(0xff));
}


//
// 値の参照(実数表記の緑)
//
//  Call
//    green_ : 青(instance 変数)
//
//  Retuen
//    function : 値
//
-(float)floatGreen
{
    return ((float)(self->green_) / (float)(0xff));
}


//
// 値の参照(実数表記の青)
//
//  Call
//    blue_ : 緑(instance 変数)
//
//  Retuen
//    function : 値
//
-(float)floatBlue
{
    return ((float)(self->blue_) / (float)(0xff));
}


//
// 値の参照(透過指定)
//
//  Call
//    isTrans_ : 透過指定(instance 変数)
//
//  Return
//    function : == YES : 透過
//               == NO  : 不透明
//
-(BOOL)isTrans
{
    return self->isTrans_;
}


//
// 値の参照(吸い取り禁止指定)
//
//  Call
//    noDropper_ : 吸い取り禁止指定(instance 変数)
//
//  Return
//    function : == YES : 吸い取り禁止
//               == NO  : 吸い取り許可
//
-(BOOL)noDropper
{
    return self->noDropper_;
}


//
// 値の参照(上書き禁止指定)
//
//  Call
//    isMask_ : 上書き禁止指定(instance 変数)
//
//  Return
//    function : == YES : 上書き禁止(色マスク有効)
//               == NO  : 上書き許可(色マスク無効)
//
-(BOOL)isMask
{
    return self->isMask_;
}


//
// 値設定(RGB 指定)
//
//  Call
//    r : 赤
//    g : 緑
//    b : 青
//
//  Return
//    red_          : 赤(instance 変数)
//    green_        : 青(instance 変数)
//    blue_         : 緑(instance 変数)
//    paletteTable_ : palette 要素値の保管先(instance 変数)
//
-(void)setRed:(unsigned char)r
     setGreen:(unsigned char)g
      setBlue:(unsigned char)b
{
    // 単純に上書きするだけ
    self->red_ = r;
    self->green_ = g;
    self->blue_ = b;
    if (self->paletteTable_ != NULL) {
        *(self->paletteTable_) = RGBtoWCHAR(self->red_, self->green_, self->blue_);
    }

    return;
}


//
// 値の設定(HLS 指定)
//
//  Call
//    h : 色相
//    l : 明度
//    s : 彩度
//
//  Return
//    red_          : 赤(instance 変数)
//    green_        : 青(instance 変数)
//    blue_         : 緑(instance 変数)
//    paletteTable_ : palette 要素値の保管先(instance 変数)
//
-(void)setHue:(unsigned char)h
 setLightness:(unsigned char)l
setSaturation:(unsigned char)s
{
    // rgb 値に変換
    const unsigned int rgb = hls_to_rgb(HLStoUW(h, l, s));

    // 変換した値で上書き
    self->red_ = UWtoR(rgb);
    self->green_ = UWtoG(rgb);
    self->blue_ = UWtoB(rgb);
    if (self->paletteTable_ != NULL) {
        *(self->paletteTable_) = RGBtoWCHAR(self->red_, self->green_, self->blue_);
    }

    return;
}


//
// 透過指定の設定
//
//  Call
//    flg : YES : 透過
//          NO  : 不透明
//
//  Return
//    isTrans_    : 透過指定(instance 変数)
//    transTable_ : 透過指定の保管先(instance 変数)
//
-(void)setTrans:(BOOL)flg
{
    // 単純に上書きするだけ
    self->isTrans_ = flg;
    if (self->transTable_ != NULL) {
        *(self->transTable_) = (self->isTrans_) ? NO : YES;   // 反転させる
    }

    return;
}


//
// 吸い取り禁止指定の設定
//
//  Call
//    flg : YES : 吸い取り禁止
//          NO  : 吸い取り許可
//
//  Return
//    noDropper_ : 吸い取り禁止指定(instance 変数)
//
-(void)setDropper:(BOOL)flg
{
    // 単純に上書きするだけ
    self->noDropper_ = flg;

    return;
}


//
// 上書き禁止(色マスク)指定の設定
//
//  Call
//    flg : YES : 上書き禁止(色マスク有効)
//          NO  : 上書き許可(色マスク無効)
//
//  Return
//    isMask_ : 上書き禁止指定(instance 変数)
//
-(void)setMask:(BOOL)flg
{
    // 単純に上書きするだけ
    self->isMask_ = flg;

    return;
}

@end




// ========================================================== class PoCoPalette
@implementation PoCoPalette

// --------------------------------------------------------- instance - private
//
// PLTE Chunk(パレット)を生成
//
//  Call
//    toAlpha    : grayscale を不透明度とするか
//    palette_[] : palette(instance 変数)
//
//  Return
//    function : data
//
-(NSData *)createPLTEChunk:(BOOL)toAlpha
{
    NSData *data;
    int l;
    PoCoPNGEncoder *png;

    DPRINT((@"[PoCoPalette createPLTEChunk]\n"));

    png = [[PoCoPNGEncoder alloc] init];

    // CHUNK を生成
    [png createChunk:(unsigned char *)("PLTE")];

    // PLTE Chunk の内容を書き込み
    for (l = 0; l < COLOR_MAX; (l)++) {
        if ((toAlpha) &&
            ([self->palette_[l] red] >   0) &&
            ([self->palette_[l] red] < 255) &&
            ([self->palette_[l] red] == [self->palette_[l] green]) &&
            ([self->palette_[l] red] == [self->palette_[l]  blue])) {
            [png writeByteChunk:0x00];
            [png writeByteChunk:0x00];
            [png writeByteChunk:0x00];
        } else {
            [png writeByteChunk:[self->palette_[l] red]];
            [png writeByteChunk:[self->palette_[l] green]];
            [png writeByteChunk:[self->palette_[l] blue]];
        }
    }

    // CHUNK を閉じる
    [png closeChunk];

    // NSData を生成
    data = [png createNSData];
    [png release];

    return data;
}


//
// tRNS Chunk(透明指定)を生成
//
//  Call
//    toAlpha    : grayscale を不透明度とするか
//    palette_[] : palette(instance 変数)
//
//  Return
//    function : data
//
-(NSData *)createTRNSChunk:(BOOL)toAlpha
{
    NSData *data;
    int l;
    PoCoPNGEncoder *png;

    DPRINT((@"[PoCoPalette createTRNSChunk]\n"));

    png = [[PoCoPNGEncoder alloc] init];

    // CHUNK を生成
    [png createChunk:(unsigned char *)("tRNS")];

    // tRNS Chunk の内容を書き込み
    for (l = 0; l < COLOR_MAX; (l)++) {
        if ((toAlpha) &&
            ([self->palette_[l] red] >   0) &&
            ([self->palette_[l] red] < 255) &&
            ([self->palette_[l] red] == [self->palette_[l] green]) &&
            ([self->palette_[l] red] == [self->palette_[l]  blue])) {
            [png writeByteChunk:(255 - [self->palette_[l] red])];
        } else {
            [png writeByteChunk:([self->palette_[l] isTrans] ? 0 : 255)];
        }
    }

    // CHUNK を閉じる
    [png closeChunk];

    // NSData を生成
    data = [png createNSData];
    [png release];

    return data;
}


//
// drOP Chunk(吸い取り禁止)を生成
//
//  Call
//    palette_[] : palette(instance 変数)
//
//  Return
//    function : data
//
-(NSData *)createDROPChunk
{
    NSData *data;
    int l;
    PoCoPNGEncoder *png;

    DPRINT((@"[PoCoPalette createDROPChunk]\n"));

    png = [[PoCoPNGEncoder alloc] init];

    // CHUNK を生成
    [png createChunk:(unsigned char *)("drOP")];

    // drOP Chunk の内容を書き込み
    for (l = 0; l < COLOR_MAX; (l)++) {
        [png writeByteChunk:[self->palette_[l] noDropper]];
    }

    // CHUNK を閉じる
    [png closeChunk];

    // NSData を生成
    data = [png createNSData];
    [png release];

    return data;
}


//
// maSK Chunk(上書き禁止)を生成
//
//  Call
//    palette_[] : palette(instance 変数)
//
//  Return
//    function : data
//
-(NSData *)createMASKChunk
{
    NSData *data;
    int l;
    PoCoPNGEncoder *png;

    DPRINT((@"[PoCoPalette createMASKChunk]\n"));

    png = [[PoCoPNGEncoder alloc] init];

    // CHUNK を生成
    [png createChunk:(unsigned char *)("maSK")];

    // maSK Chunk の内容を書き込み
    for (l = 0; l < COLOR_MAX; (l)++) {
        [png writeByteChunk:[self->palette_[l] isMask]];
    }

    // CHUNK を閉じる
    [png closeChunk];

    // NSData を生成
    data = [png createNSData];
    [png release];

    return data;
}


// ----------------------------------------------- PoCoPalette 内 instance 関数
//
// initialize
//
//  Call
//    None
//
//  Return
//    id function : 実体
//
-(id)init
{
    self = [self initWithTable:NULL withTrans:NULL];

    return self;
}


//
// initialize(指定イニシャライザ)
//
//  Call
//    defaultPalette[] : 初期値テーブル(static 変数)
//    pal              : パレット参照テーブル
//    trn              : 透過指定参照テーブル
//
//  Return
//    function   : 実体
//    palette_[] : palette(instance 変数)
//
-(id)initWithTable:(wchar_t *)pal
         withTrans:(BOOL *)trn
{
    int l;                              // 汎用(loop counter)
    id  p;                              // 汎用(生成 PoCoPalette の実体)

    DPRINT((@"[PoCoPalette initWithTable withTrans]\n"));

    // super class を初期化
    self = [super init];

    // 自身を初期化
    if (self != nil) {
        // 一旦、管理下の PoCoPalette を nil にしておく
        for (l = 0; l < COLOR_MAX; (l)++) {
            self->palette_[l] = nil;
        }

        // PoCoPalette の実体を生成(初期値を与えながら生成)
        for (l = 0; l < COLOR_MAX; (l)++) {
            p = [[PoCoColor alloc] initRed:UWtoR(defaultPalette[l])
                                     Green:UWtoG(defaultPalette[l])
                                      Blue:UWtoB(defaultPalette[l])
                          withPaletteTable:((pal != NULL) ? &(pal[l]) : NULL)
                            withTransTable:((trn != NULL) ? &(trn[l]) : NULL)];
            if (p == nil) {
                DPRINT((@"PoCoColor init error : %d\n", l));
                [self release];
                self = nil;
                break;
            }
            self->palette_[l] = p;
        }
    }

    return self;
}


//
// initialize(複製)
//
//  Call
//    zone       : zone(api 変数)
//    palette_[] : palette(instance 変数)
//
//  Return
//    function : 実体(複製した実体)
//
-(id)copyWithZone:(NSZone *)zone
{
    PoCoPalette *copy;
    int l;

    DPRINT((@"[PoCoPalette copyWithZone:%p]\n", zone));

    // 複製を生成
    copy = [[[self class] allocWithZone:zone] init];

    // 複製先の内容の設定
    if (copy != nil) {
        for (l = 0; l < COLOR_MAX; (l)++) {
            [copy->palette_[l] release];
            copy->palette_[l] = [[self palette:l] copy];
        }
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
//    palette_[] : palette(instance 変数)
//
-(void)dealloc
{
    int l;

    DPRINT((@"[PoCoPalette dealloc]\n"));

    for (l = 0; l < COLOR_MAX; (l)++) {
        [self->palette_[l] release];
    }

    // super class の解放
    [super dealloc];

    return;
}


//
// 参照
//  色番号がはみ出している場合は取得できない
//
//  Call
//    index     : 色番号
//    palette_[] : palette(instance 変数)
//
//  Return
//    function : == nil : 取得失敗
//               != nil : 取得
//
-(PoCoColor *)palette:(int)index
{
    PoCoColor *col;

    col = nil;

    if ((index < 0) || (index >= COLOR_MAX)) {
        // 範囲外なので取得できない
        ;
    } else {
        col = self->palette_[index];
    }

    return col;
}


//
// 一致確認
//
//  Call
//    target     : 比較対象
//    attrFlag   : 色成分以外も検査対象にするか
//                 YES : 対象に含める
//                 NO  : 対象に含めない
//    palette_[] : palette(instance 変数)
//
//  Return
//    function : 結果
//               YES : すべて一致
//               NO  : 一致しないものあり
//
-(BOOL)isEqualPalette:(PoCoPalette *)target
            checkAttr:(BOOL)attrFlag
{
    BOOL result;
    int l;

    result = YES;

    // 違うものを探すだけ
    for (l = 0; l < COLOR_MAX; (l)++) {
        if (!([self->palette_[l] isEqualColor:[target palette:l]
                                    checkAttr:attrFlag])) {
            result = NO;
            break;
        }
    }

    return result;
}


// ----------------------------------------- instance - public - ファイル操作系
//
// 保存
//
//  Call
//    toAlpha : grayscale を不透明度とするか
//
//  Return
//    function : data
//
-(NSData *)createFileData:(BOOL)toAlpha
{
    NSMutableData *data;

    DPRINT((@"[PoCoPalette createFileData]\n"));

    data = [NSMutableData data];

    // PLTE Chunk(パレット)を生成
    [data appendData:[self createPLTEChunk:toAlpha]];

    // tRNS Chunk(透明指定)を生成
    [data appendData:[self createTRNSChunk:toAlpha]];

    // drOP Chunk(吸い取り禁止)を生成
    [data appendData:[self createDROPChunk]];

    // maSK Chunk(上書き禁止)を生成
    [data appendData:[self createMASKChunk]];

    return data;
}


//
// 読み込み(PLTE Chunk)
//  データが足りてなくても成功とする
//  RGB3要素取得する途中で足りなくなった場合は、色は設定せず打ち切りにする
//
//  Call
//    png : PNG Decoder
//
//  Return
//    function  : YES : 成功
//                NO  : 失敗
//    palette_[] : palette(instance 変数)
//
-(BOOL)loadPLTEChunk:(PoCoPNGDecoder *)png
{
    int l;
    unsigned char r;
    unsigned char g;
    unsigned char b;

    DPRINT((@"[PoCoPalette loadPLTEChunk]\n"));

    for (l = 0; l < COLOR_MAX; (l)++) {
        // 読み込み
        if (([png readByteChunk:&(r)]) &&
            ([png readByteChunk:&(g)]) &&
            ([png readByteChunk:&(b)])) {
            // 設定
            [self->palette_[l] setRed:r
                             setGreen:g
                              setBlue:b];
        } else {
            // 中断
            break;
        }
    }

    return YES;                         // 常時 YES
}


//
// 読み込み(tRNS Chunk)
//  データが足りてなくても成功とする
//
//  Call
//    png : PNG Decoder
//
//  Return
//    function   : YES : 成功
//                 NO  : 失敗
//    palette_[] : palette(instance 変数)
//
-(BOOL)loadTRNSChunk:(PoCoPNGDecoder *)png
{
    int l;
    unsigned char i;

    DPRINT((@"[PoCoPalette loadTRNSChunk]\n"));

    for (l = 0; l < COLOR_MAX; (l)++) {
        // 読み込み
        if ([png readByteChunk:&(i)]) {
            // 設定
            if (i == 0) {
                [self->palette_[l] setTrans:YES];
            } else {
                [self->palette_[l] setTrans:NO];
                if (i < 255) {
                    if (([self->palette_[l]   red] == 0) &&
                        ([self->palette_[l] green] == 0) &&
                        ([self->palette_[l]  blue] == 0)) {
                        [self->palette_[l] setRed:(255 - i)
                                         setGreen:(255 - i)
                                          setBlue:(255 - i)];
                    }
                }
            }
        } else {
            // 中断
            break;
        }
    }

    return YES;                         // 常時 YES
}


//
// 読み込み(drOP Chunk)
//  データが足りてなくても成功とする
//
//  Call
//    png : PNG Decoder
//
//  Return
//    function   : YES : 成功
//                 NO  : 失敗
//    palette_[] : palette(instance 変数)
//
-(BOOL)loadDROPChunk:(PoCoPNGDecoder *)png
{
    int l;
    unsigned char i;

    DPRINT((@"[PoCoPalette loadDROPChunk]\n"));

    for (l = 0; l < COLOR_MAX; (l)++) {
        // 読み込み
        if ([png readByteChunk:&(i)]) {
            // 設定
            [self->palette_[l] setDropper:i];
        } else {
            // 中断
            break;
        }
    }

    return YES;                         // 常時 YES
}


//
// 読み込み(maSK Chunk)
//  データが足りてなくても成功とする
//
//  Call
//    png : PNG Decoder
//
//  Return
//    function   : YES : 成功
//                 NO  : 失敗
//    palette_[] : palette(instance 変数)
//
-(BOOL)loadMASKChunk:(PoCoPNGDecoder *)png
{
    int l;
    unsigned char i;

    DPRINT((@"[PoCoPalette loadMASKChunk]\n"));

    for (l = 0; l < COLOR_MAX; (l)++) {
        // 読み込み
        if ([png readByteChunk:&(i)]) {
            // 設定
            [self->palette_[l] setMask:i];
        } else {
            // 中断
            break;
        }
    }

    return YES;                         // 常時 YES
}

@end
