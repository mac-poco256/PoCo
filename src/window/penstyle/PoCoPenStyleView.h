//
//	Pelistina on Cocoa - PoCo -
//	ペン先表示・選択部
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoMonochromePatternView.h"

// ----------------------------------------------------------------------------
@interface PoCoPenStyleView : PoCoMonochromePatternView
{
}

// initialize
-(id)initWithFrame:(NSRect)frame;

// deallocate
-(void)dealloc;

// パターンを更新
-(void)updatePattern:(PoCoMonochromePattern *)pat;

// 表示要求
-(void)drawRect:(NSRect)rect;

// イベント処理系
-(BOOL)acceptsFirstMouse:(NSEvent *)evt;
-(void)mouseDown:(NSEvent *)evt;

// 選択内容の切り替え
-(void)nextSelection;
-(void)prevSelection;

@end
