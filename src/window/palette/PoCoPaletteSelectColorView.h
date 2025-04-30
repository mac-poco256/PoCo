//
//	Pelistina on Cocoa - PoCo -
//	選択色表示部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// ----------------------------------------------------------------------------
@interface PoCoPaletteSelectColorView : NSView
{
    NSDocumentController *docCntl_;
}

// initialize
-(id)initWithFrame:(NSRect)frameRect;

// deallocate
-(void)dealloc;

// observer
-(void)updateView:(NSNotification *)note; // 表示更新要求

// 再描画要求
-(void)drawRect:(NSRect)rect;

// イベント処理系
-(BOOL)acceptsFirstMouse:(NSEvent *)evt;
-(void)mouseDown:(NSEvent *)evt;

@end
