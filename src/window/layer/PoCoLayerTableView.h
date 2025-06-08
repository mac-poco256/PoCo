//
// PoCoLayerTableView.h
// declare interface of PoCoLayerTableView class.
// this class is to manage PoCoLayerTableView.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// ----------------------------------------------------------------------------
@interface PoCoLayerTableView : NSTableView
{
    BOOL isMoving_;                     // YES : 移動操作    NO : 通常操作
    BOOL isRightDown_;                  // 副ボタン押し下
    int startRow_;                      // 移動開始行
}

// awake from nib.
- (void)awakeFromNib;

// 表示要求
-(void)drawRect:(NSRect)rect;

// 高さ
-(CGFloat)rowHeight;

// メニューを更新
-(BOOL)validateMenuItem:(NSMenuItem *)menu;

// 全選択
-(IBAction)selectAll:(id)sender;

// イベント処理系
-(void)mouseDown:(NSEvent *)evt;        // ボタンダウン処理
-(void)mouseDragged:(NSEvent *)evt;     // ドラッグ処理
-(void)mouseUp:(NSEvent *)evt;          // ボタンリリース処理
-(void)rightMouseDown:(NSEvent *)evt;   // 副ボタンダウン処理
-(void)rightMouseUp:(NSEvent *)evt;     // 副ボタンリリース処理
-(void)keyDown:(NSEvent *)evt;          // キーダウン処理
-(void)keyUp:(NSEvent *)evt;            // キーリリース処理

@end
