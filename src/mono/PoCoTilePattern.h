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
// declare immutable tile pattern container.

@interface PoCoTileSteadyPattern : PoCoMonochromePatternContainerBase
{
    PoCoMonochromePattern *pattern_[TILE_PATTERN_NUM];
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
