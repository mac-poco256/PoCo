//
//	Pelistina on Cocoa - PoCo -
//	色保持
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class
@class PoCoPalette;

// ----------------------------------------------------------------------------
@interface PoCoColorBuffer : NSObject
{
    NSMutableDictionary *buffer_;
}

// 色探索
+(unsigned char)find:(PoCoPalette *)palette
             withRed:(unsigned char)r
           withGreen:(unsigned char)g
            withBlue:(unsigned char)b;

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// 初期化
-(void)reset:(PoCoPalette *)palette;

// 構築
-(void)create:(PoCoPalette *)palette
     isAlways:(BOOL)always;

// 検索
-(unsigned char)findWithBuffer:(PoCoPalette *)palette
                       withRed:(unsigned char)r
                     withGreen:(unsigned char)g
                      withBlue:(unsigned char)b;

// 以前の演算結果を探す
-(int)findOnceCalc:(PoCoColorMode)colMode
      withDensity1:(int)d1
      withDensity2:(int)d2
        withColor1:(unsigned char)i1
        withColor2:(unsigned char)i2;

// 以前の演算結果に追加
-(void)addOnceCalc:(PoCoColorMode)colMode
      withDensity1:(int)d1
      withDensity2:(int)d2
        withColor1:(unsigned char)i1
        withColor2:(unsigned char)i2
        withResult:(unsigned char)ch;

@end
