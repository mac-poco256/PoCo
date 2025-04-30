//
//	Pelistina on Cocoa - PoCo -
//	パレット補助属性設定領域
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//
// 上塗り禁止/吸い取り禁止/透過で共通の class を使用
//

#import <Cocoa/Cocoa.h>

// ----------------------------------------------------------------------------
@interface PoCoPaletteAttributeView : NSView
{
    BOOL isOn_[COLOR_MAX];              // 設定内容
    BOOL setValue_;                     // 設定値
    NSDocumentController *docCntl_;
    int range_;                         // 選択の連続数
    IBOutlet id ownerWindow_;
}

// initialize
-(id)initWithFrame:(NSRect)frameRect;

// deallocate
-(void)dealloc;

// 表示要求
-(void)drawRect:(NSRect)rect;

// 座標系を反転
-(BOOL)isFlipped;

// 取得
-(const BOOL *)attribute;

// 選択の連続数を指定
-(void)setRange:(int)val;

// 設定
-(void)setAttribute:(BOOL)on
              index:(int)index;

// ボタンダウン処理
-(void)mouseDown:(NSEvent *)evt;

// ドラッグ処理
-(void)mouseDragged:(NSEvent *)evt;

@end
