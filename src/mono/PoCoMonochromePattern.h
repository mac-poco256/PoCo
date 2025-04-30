//
//	Pelistina on Cocoa - PoCo -
//	2値パターン定義
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//
// 主にペン先・タイルパターンで使用する
// 1dot = 1byte で表現されるが、alpha channel の意図は持っていない
// (単に mask の判定で、bit field の扱いを省くための措置)
//

#import <Cocoa/Cocoa.h>

// 参照 class の宣言
@class PoCoBitmap;

// ----------------------------------------------------------------------------
@interface PoCoMonochromePattern : NSObject <NSCoding>
{
    unsigned int width_;                // 幅(dot 単位)
    unsigned int height_;               // 高さ(dot 単位)

    unsigned char *pattern_;            // パターン(mask pattern)
                                        // == 0 : 透過    =! 0 : 描画
}

// 初期設定
+(void)initialize;

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// 参照
-(unsigned int)width;
-(unsigned int)height;
-(const unsigned char *)pattern;
-(void)getPattern:(const unsigned char **)pat
         getWidth:(unsigned int *)w
        getHeight:(unsigned int *)h;

// 設定
-(void)setPattern:(const unsigned char *)pat
            width:(unsigned int)w
           height:(unsigned int)h;

// 表示用画像の取得(常に実寸のみ)
-(NSBitmapImageRep *)getImage;

// パターンの羅列の取得
-(PoCoBitmap *)getPixelmap:(PoCoRect *)r;

// ファイル操作系
-(id)initWithCoder:(NSCoder *)coder;      // 読み込み
-(void)encodeWithCoder:(NSCoder *)coder;  // 保存

@end


// ----------------------------------------------------------------------------
// ペン先/タイルパターン管理部の基底(共通 interface の定義)
@interface PoCoMonochromePatternContainerBase : NSObject
{
}

// 初期設定
+(void)initialize;

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// 参照
-(PoCoMonochromePattern *)pattern:(int)index;

// 設定
-(void)setPattern:(PoCoMonochromePattern *)pat
          atIndex:(int)index;

@end
