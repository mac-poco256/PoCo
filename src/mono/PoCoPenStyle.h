//
// PoCoPenStyle.h
// declare interface of classes to management pen styles.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoMonochromePattern.h"

// ----------------------------------------------------------------------------
// declare mutable pen style container.

@interface PoCoPenStyle : PoCoMonochromePatternContainerBase
{
    PoCoMonochromePattern *pattern_[PEN_STYLE_NUM];
}

// 初期設定
+(void)initialize;

// initialize
- (id)init;

// deallocate
-(void)dealloc;

// 参照
-(PoCoMonochromePattern *)pattern:(int)index;

// 設定
-(void)setPattern:(PoCoMonochromePattern *)pat
          atIndex:(int)index;

@end


// ----------------------------------------------------------------------------
// declare immutable pen style container.

@interface PoCoPenSteadyStyle : PoCoMonochromePatternContainerBase
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
