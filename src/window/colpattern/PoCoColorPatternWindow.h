//
//	Pelistina on Cocoa - PoCo -
//	カラーパターンウィンドウ管理部
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class の宣言
@class PoCoColorPatternView;

// ----------------------------------------------------------------------------
@interface PoCoColorPatternWindow : NSWindowController
{
    IBOutlet PoCoColorPatternView *patternInfoView_;
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// ウィンドウが読み込まれた
-(void)windowDidLoad;

// ウィンドウが閉じられる
-(void)windowWillClose:(NSNotification *)note;

// 取り消し情報の引き渡し
-(NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender;

// パターンを設定
-(void)setPattern:(id)sender;

// イベントの取得
-(void)keyDown:(NSEvent *)evt;          // キーダウン処理
-(void)keyUp:(NSEvent *)evt;            // キーリリース処理

@end
