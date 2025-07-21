//
// PoCoMonochromePattern.h
// declare interface of base classes for monochrome pattern.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//
// the monochrome pattern is used by pen style and tile pattern.
// monochrome pattern is represented by 1 byte per 1 pixel.
// but this is not intended that have alpha channel.
// (rather, this is to reduce bit field computation.)
//

#import <Cocoa/Cocoa.h>

// declare prtotype of classes.
@class PoCoBitmap;

// ----------------------------------------------------------------------------
// declare PoCoMonochromePattern that represents base class of the monochrome pattern.

@interface PoCoMonochromePattern : NSObject <NSSecureCoding>
{
    unsigned int width_;                // 幅(dot 単位)
    unsigned int height_;               // 高さ(dot 単位)

    unsigned char *pattern_;            // パターン(mask pattern)
                                        // == 0 : 透過    =! 0 : 描画
}

// 初期設定
+(void)initialize;

// property: supportsSecureCoding.
+ (BOOL)supportsSecureCoding;

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
// declare PoCoMonochromePatternConatainerBase that represents base class of the monochrome pattern container.

@interface PoCoMonochromePatternContainerBase : NSObject
{
}

// initialise (class).
+ (void)initialize;

// initialise (instance).
- (id)init;

// deallocate.
- (void)dealloc;

// get pattern at index.
- (PoCoMonochromePattern *)pattern:(int)index;

// set pattern at index.
- (void)setPattern:(PoCoMonochromePattern *)pat
           atIndex:(int)index;

// revert.
- (void)revertAllPatterns;
- (void)revertPattern:(int)index;

@end
