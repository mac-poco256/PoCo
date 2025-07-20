//
// PoCoTilePattern.h
// declare interface of classes to management tile patterns.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoMonochromePattern.h"

// ----------------------------------------------------------------------------
// declare mutable tile pattern container.

@interface PoCoTilePattern : PoCoMonochromePatternContainerBase
{
    PoCoMonochromePattern *pattern_[TILE_PATTERN_NUM];
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
// declare immutable tile pattern container.

@interface PoCoTileSteadyPattern : PoCoMonochromePatternContainerBase
{
    PoCoMonochromePattern *pattern_[TILE_PATTERN_NUM];
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
