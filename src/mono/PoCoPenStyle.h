//
//	Pelistina on Cocoa - PoCo -
//	ペン先管理部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoMonochromePattern.h"

// ----------------------------------------------------------------------------
@interface PoCoPenStyle : PoCoMonochromePatternContainerBase
{
    PoCoMonochromePattern *pattern_[PEN_STYLE_NUM];
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


// ----------------------------------------------------------------------------
@ interface PoCoPenSteadyStyle : PoCoMonochromePatternContainerBase
{
    PoCoMonochromePattern *pattern_[PEN_STYLE_NUM];
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
