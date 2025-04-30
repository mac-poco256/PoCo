//
//	Pelistina on Cocoa - PoCo -
//	新規画像色選択領域
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class の宣言
@class PoCoPalette;

// ----------------------------------------------------------------------------
@interface PoCoNewDocumentColorSelectView : NSView
{
    PoCoPalette *palette_;              // 色見本
    unsigned char selnum_;              // 選択番号
}

// initialize
-(id)initWithFrame:(NSRect)frameRect;

// deallocate
-(void)dealloc;

// 座標系を反転
-(BOOL)isFlipped;

// 表示要求
-(void)drawRect:(NSRect)rect;

// 選択番号の設定
-(void)setSelnum:(unsigned char)num;

// 選択番号の取得
-(unsigned char)selnum;

// イベント処理系
-(void)mouseDown:(NSEvent *)evt;
-(void)mouseDragged:(NSEvent *)evt;

@end
