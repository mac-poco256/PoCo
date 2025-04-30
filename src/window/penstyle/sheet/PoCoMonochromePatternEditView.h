//
//	Pelistina on Cocoa - PoCo -
//	2値パターン編集領域
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class の宣言
@class PoCoMonochromePattern;
@class PoCoMonochromePatternSampleView;

// ----------------------------------------------------------------------------
@interface PoCoMonochromePatternEditView : NSView
{
    BOOL isSet_;                        // YES : 設定    NO : 解除
    PoCoMonochromePattern *pattern_;    // 編集対象パターン
    IBOutlet PoCoMonochromePatternSampleView *sampleView_;
}

// initialize
-(id)initWithFrame:(NSRect)frame;

// deallocate
-(void)dealloc;

// パターンを取得
-(PoCoMonochromePattern *)pattern;

// パターンを設定
-(void)setPattern:(PoCoMonochromePattern *)pat;

// 表示要求
-(void)drawRect:(NSRect)rect;

// 座標系を反転
-(BOOL)isFlipped;

// マウスイベント処理
-(void)mouseDown:(NSEvent *)evt;
-(void)mouseDragged:(NSEvent *)evt;

@end
