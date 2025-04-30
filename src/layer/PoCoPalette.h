//
//	Pelistina on Cocoa - PoCo -
//	palette 宣言
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import <Foundation/Foundation.h>

// 参照 class
@class PoCoPNGDecoder;

// ----------------------------------------------------------------------------
@interface PoCoColor : NSObject <NSCopying>
{
    unsigned char red_;                 // 赤(0-255)
    unsigned char green_;               // 緑(0-255)
    unsigned char blue_;                // 青(0-255)

    BOOL isTrans_;                      // YES : 透過
    BOOL noDropper_;                    // YES : 吸い取り禁止
    BOOL isMask_;                       // YES : 上書き禁止

    wchar_t *paletteTable_;
    BOOL *transTable_;
}

// initialize
-(id)init;
-(id)initRed:(unsigned char)r            // 指定イニシャライザ
       Green:(unsigned char)g
        Blue:(unsigned char)b
withPaletteTable:(wchar_t *)pal
  withTransTable:(BOOL *)trn;
-(id)copyWithZone:(NSZone *)zone;       // 複製

// deallocate
-(void)dealloc;

// 一致確認
-(BOOL)isEqualColor:(PoCoColor *)target
          checkAttr:(BOOL)attrFlag;

// 参照
-(unsigned char)red;
-(unsigned char)green;
-(unsigned char)blue;
-(unsigned char)hue;
-(unsigned char)lightness;
-(unsigned char)saturation;
-(float)floatRed;
-(float)floatGreen;
-(float)floatBlue;
-(BOOL)isTrans;
-(BOOL)noDropper;
-(BOOL)isMask;

// 設定
-(void)setRed:(unsigned char)r
     setGreen:(unsigned char)g
      setBlue:(unsigned char)b;
-(void)setHue:(unsigned char)h
 setLightness:(unsigned char)l
setSaturation:(unsigned char)s;
-(void)setTrans:(BOOL)flg;
-(void)setDropper:(BOOL)flg;
-(void)setMask:(BOOL)flg;

@end


// ----------------------------------------------------------------------------
@interface PoCoPalette : NSObject <NSCopying>
{
    PoCoColor *palette_[COLOR_MAX];
}

// initialize
-(id)init;
-(id)initWithTable:(wchar_t *)pal       // 指定イニシャライザ
         withTrans:(BOOL *)trn;
-(id)copyWithZone:(NSZone *)zone;       // 複製

// deallocate
-(void)dealloc;

// 参照
-(PoCoColor *)palette:(int)index;

// 一致確認
-(BOOL)isEqualPalette:(PoCoPalette *)target
            checkAttr:(BOOL)attrFlag;

// ファイル操作系
-(NSData *)createFileData:(BOOL)toAlpha;    // 保存
-(BOOL)loadPLTEChunk:(PoCoPNGDecoder *)png; // 読み込み(PLTE Chunk)
-(BOOL)loadTRNSChunk:(PoCoPNGDecoder *)png; // 読み込み(tRNS Chunk)
-(BOOL)loadDROPChunk:(PoCoPNGDecoder *)png; // 読み込み(drOP Chunk)
-(BOOL)loadMASKChunk:(PoCoPNGDecoder *)png; // 読み込み(maSK Chunk)

@end
