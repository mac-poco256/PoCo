//
//	Pelistina on Cocoa - PoCo -
//	2値パターン見本表示領域
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class の宣言
@class PoCoMonochromePattern;

// ----------------------------------------------------------------------------
@interface PoCoMonochromePatternSampleView : NSView
{
    PoCoMonochromePattern *pattern_;
}

// initialize
-(id)initWithFrame:(NSRect)frame;

// deallocate
-(void)dealloc;

// 表示パターンを設定
-(void)setPattern:(PoCoMonochromePattern *)pat;

// 表示要求
-(void)drawRect:(NSRect)rect;

// 座標系を反転
-(BOOL)isFlipped;
@end
