//
//	Pelistina on Cocoa - PoCo -
//	layer 宣言
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import <Foundation/Foundation.h>

// 参照 class の宣言
@class PoCoPalette;
@class PoCoPNGDecoder;

// ----------------------------------------------------------------------------
// bitmap は256色固定
@interface PoCoBitmap : NSObject <NSCopying>
{
    int width_;                         // 幅(dot 数)
    int height_;                        // 高さ(dot 数)
    int size_;                          // 確保容量(byte 単位/常に偶数)

    unsigned char *bitmap_;             // pixelmap(single plane)
}

// initialize
-(id)init;
-(id)initWidth:(int)w                   // 指定イニシャライザ
    initHeight:(int)h
  defaultColor:(unsigned char)c;
-(id)copyWithZone:(NSZone *)zone;       // 複製

// deallocate
-(void)dealloc;

// 参照
-(int)width;
-(int)height;
-(unsigned char *)pixelmap;             // pointer を free() しないこと

// 複製取得
// 得られた bitmap の解放は呼び出しもとの責任(free() を使用すること)
-(unsigned char *)getBitmap;                  // 完全
-(PoCoBitmap *)getBitmap:(const PoCoRect *)r; // 部分

// 部分設定
// bitmap の内容を copy する(retain ではない)
-(void)setBitmap:(const unsigned char *)bmp
        withRect:(const PoCoRect *)r;

// 変形
// 負の値は変形しない
// 拡大/縮小の意図は持たない
-(BOOL)resizeWidth:(int)w
      resizeHeight:(int)h;

// ファイル操作系
-(NSData *)createFileData;                          // 保存
-(id)initWithPNGDecoder:(PoCoPNGDecoder *)png;      // 読み込み(通常)
-(id)initWithPNGDecoderIDAT:(PoCoPNGDecoder *)png   // 読み込み(IDAT CHUNK)
                  sizeWidth:(unsigned int)w
                 sizeHeight:(unsigned int)h;

@end


// ----------------------------------------------------------------------------
// レイヤー基本定義
@interface PoCoLayerBase : NSObject <NSCopying>
{
    PoCoBitmap *bitmap_;                // 内容の実体(編集対象)
    NSBitmapImageRep *preview_;         // 見本の表示用
    NSRect sampleRect_;                 // 見本の大きさ

    BOOL drawLock_;                     // YES : 描画禁止
    BOOL isDisplay_;                    // YES : 表示

    NSString *name_;                    // 名称
}

// initialize
-(id)init;
-(id)initWidth:(int)w                   // 指定イニシャライザ
    initHeight:(int)h
  defaultColor:(unsigned char)c;
-(id)copyWithZone:(NSZone *)zone;       // 複製

// deallocate
-(void)dealloc;

// 種別(各具象 class で実装すること)
-(PoCoLayerType)layerType;
-(NSString *)typeName;

// 参照
-(PoCoBitmap *)bitmap;
-(NSImage *)preview;
-(BOOL)drawLock;
-(BOOL)isDisplay;
-(NSString *)name;

// 設定
-(void)setDrawLock;
-(void)clearDrawLock;
-(void)setIsDisplay;
-(void)clearIsDisplay;
-(void)setName:(NSString *)str;

// preview の更新
-(void)updatePreview:(PoCoPalette *)palette;

// ファイル操作系(各具象 class で実装すること)
-(NSData *)createFileData;                      // 保存
-(id)initWithPNGDecoder:(PoCoPNGDecoder *)png;  // 読み込み

@end


// ----------------------------------------------------------------------------
// 画像レイヤー
// 初期化は [PoCoLayerBase initWidth: initHeight:] を呼ぶのが望ましい
@interface PoCoBitmapLayer : PoCoLayerBase
{
}

// 種別
-(PoCoLayerType)layerType;
-(NSString *)typeName;

// ファイル操作系
-(NSData *)createFileData;                          // 保存
-(id)initWithPNGDecoder:(PoCoPNGDecoder *)png;      // 読み込み(標準)
-(id)initWithPNGDecoderIDAT:(PoCoPNGDecoder *)png   // 読み込み(IDAT CHUNK)
                  sizeWidth:(unsigned int)w
                 sizeHeight:(unsigned int)h;

@end


// ----------------------------------------------------------------------------
// 文字列レイヤー
@interface PoCoStringLayer : PoCoLayerBase
{
    PoCoRect *str_r_;                   // レイアウト領域
    NSString *str_;                     // 対象文字列

// 行頭禁則文字
// 行末禁則文字
// 文字全景色
// 文字背景色
// 書体
// 基本文字サイズ
// 文字倍率
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// 種別
-(PoCoLayerType)layerType;
-(NSString *)typeName;

// ... accessor method がまだ ...

// ファイル操作系
-(NSData *)createFileData;                      // 保存
-(id)initWithPNGDecoder:(PoCoPNGDecoder *)png;  // 読み込み

@end


#if 0
// ----------------------------------------------------------------------------
// 図形レイヤー(概念的な枠組みだけで、使用できない)
@interface PoCoFigureLayer : PoCoLayerBase
{
}

@end


// ----------------------------------------------------------------------------
// ファイルレイヤー(概念的な枠組みだけで、使用できない)
@interface PoCoFileLayer : PoCoLayerBase
{
}

@end

#endif  // 0
