//
// PoCoMonochromePatternView.h
// declare interface of base class for the monochrome pattern view.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class の宣言
@class PoCoMonochromePatternContainerBase;
@class PoCoMonochromePattern;

// ----------------------------------------------------------------------------
@interface PoCoMonochromePatternView : NSView
{
    PoCoMonochromePatternContainerBase *pattern_; // 対象パターン群
}

// initialize
-(id)initWithFrame:(NSRect)frameRect
        setPattern:(id)pat;

// deallocate
-(void)dealloc;

// 座標系を反転
-(BOOL)isFlipped;

// パターンを更新
-(void)updatePattern:(PoCoMonochromePattern *)pat;

// 1パターン分の描画
-(void)drawPattern:(int)num
          isSelect:(BOOL)sel;

// 要素番号から矩形領域へ変換
-(NSRect)numToRect:(int)num;

// 座標から要素番号へ変換
-(unsigned int)pointToNum:(NSPoint)pos;

// 選択内容の切り替え
-(void)nextSelection;
-(void)prevSelection;

// revert.
- (void)revertAllPatterns;
- (void)revertPattern;

@end
