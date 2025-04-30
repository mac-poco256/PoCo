//
//	Pelistina on Cocoa - PoCo -
//	タイルパターン管理部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoMonochromePattern.h"

// ----------------------------------------------------------------------------
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
