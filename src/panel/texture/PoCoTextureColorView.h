//
//	Pelistina on Cocoa - PoCo -
//	テクスチャ色設定領域
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// ----------------------------------------------------------------------------
@interface PoCoTextureColorView : NSView
{
    int top_;                           // 先頭の選択色
    int hori_;                          // 水平範囲
    int vert_;                          // 垂直範囲
    BOOL matrix_[COLOR_MAX];            // 選択表示用

    NSDocumentController *docCntl_;
}

// initialize
-(id)initWithFrame:(NSRect)frameRect;

// deallocate
-(void)dealloc;

// 表示要求
-(void)drawRect:(NSRect)rect;

// 座標系を反転
-(BOOL)isFlipped;

// 1色分の描画
-(void)drawColor:(int)num
        isSelect:(BOOL)sel
          isDown:(BOOL)down;

// 設定
-(void)setHoriRange:(int)val;
-(void)setVertRange:(int)val;
-(void)setHoriRange:(int)h
       andVertRange:(int)v;

// 選択内容
-(int)topIndex;

// ボタンダウン処理
-(void)mouseDown:(NSEvent *)evt;

@end
