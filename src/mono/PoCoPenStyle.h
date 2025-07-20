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


// ----------------------------------------------------------------------------
// declare immutable pen style container.

@interface PoCoPenSteadyStyle : PoCoMonochromePatternContainerBase
{
    PoCoMonochromePattern *pattern_[PEN_STYLE_NUM];
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
