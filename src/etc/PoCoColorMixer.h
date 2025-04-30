//
//	Pelistina on Cocoa - PoCo -
//	色混合
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class
@class PoCoPalette;
@class PoCoColorBuffer;

// ----------------------------------------------------------------------------
@interface PoCoColorMixerUnit : NSObject
{
    int e1_;                            // 要素1(red ないし hue)
    int e2_;                            // 要素2(green ないし lightness)
    int e3_;                            // 要素3(blue ないし saturation)
}

// initialize
-(id)initWithElement1:(int)e1
         withElement2:(int)e2
         withElement3:(int)e3;

// deallocate
-(void)dealloc;

// 取得
-(int)element1;
-(int)element2;
-(int)element3;

@end


// ----------------------------------------------------------------------------
@interface PoCoColorMixer : NSObject
{
}

// 色演算(2色混合の平均)
+(unsigned char)calcColor:(PoCoPalette *)palette
                  colMode:(PoCoColorMode)colMode
                 density2:(int)d2
                   color1:(unsigned char)i1
                   color2:(unsigned char)i2
                   buffer:(PoCoColorBuffer *)buffer;

// 色演算(任意個数の平均)
+(unsigned char)calcColorRGB:(PoCoPalette *)palette
                  withColors:(NSArray *)cols
                      buffer:(PoCoColorBuffer *)buffer
                    orgColor:(unsigned char)or;
+(unsigned char)calcColorHLS:(PoCoPalette *)palette
                  withColors:(NSArray *)cols
                      buffer:(PoCoColorBuffer *)buffer
                    orgColor:(unsigned char)org;

@end
