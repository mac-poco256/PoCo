//
// PoCoColorPatternView.h
// declare interface of colour pattern list view.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class の宣言
@class PoCoEditInfo;

// ----------------------------------------------------------------------------
@interface PoCoColorPatternView : NSView
{
    IBOutlet id set_;
    PoCoEditInfo *info_;                // 編集情報
    NSDocumentController *docCntl_;
}

// initialize
-(id)initWithFrame:(NSRect)frameRect;

// deallocate
-(void)dealloc;

// 座標系を反転
-(BOOL)isFlipped;

// set the clips to bound property (always return YES).
- (BOOL)clipsToBounds;

// 表示要求
-(void)drawRect:(NSRect)rect;

// 1マス分の描画
-(void)drawCell:(int)num
       isSelect:(BOOL)sel;

// observer 系
-(void)changePicture:(NSNotification *)note;  // 表示画像を切り替え
-(void)changePalette:(NSNotification *)note;  // パレットを編集
-(void)changeColor:(NSNotification *)note;    // 選択色の切り替え

// IBAction 系
-(IBAction)setPattern:(id)sender;       // パターンを設定

// イベント処理系
-(BOOL)acceptsFirstMouse:(NSEvent *)evt;
-(void)mouseDown:(NSEvent *)evt;
-(void)mouseDragged:(NSEvent *)evt;

@end
