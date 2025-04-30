//
//	Pelistina on Cocoa - PoCo -
//	パレット取り込み設定領域
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class
@class PoCoPalette;

// ----------------------------------------------------------------------------
@interface PoCoImportPaletteColorSelectView : NSView
{
    BOOL isOn_[COLOR_MAX];              // 設定内容
    BOOL setValue_;                     // 設定値
    PoCoPalette *targetPalette_;        // 取り込み対象パレット
}

// initialize
-(id)initWithFrame:(NSRect)frameRect;

// deallocate
-(void)dealloc;

// 対象パレットを設定
-(void)setTarget:(PoCoPalette *)target;

// 表示要求
-(void)drawRect:(NSRect)rect;

// 座標系を反転
-(BOOL)isFlipped;

// 取得
-(BOOL)attribute:(int)index;
-(const BOOL *)attributs;

// 設定
-(void)setAttribute:(BOOL)on
            atIndex:(int)index;

// ボタンダウン処理
-(void)mouseDown:(NSEvent *)evt;

// ドラッグ処理
-(void)mouseDragged:(NSEvent *)evt;

@end
