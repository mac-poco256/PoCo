//
//	Pelistina on Cocoa - PoCo -
//	参照ウィンドウ管理部
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import <AppKit/AppKit.h>

// ----------------------------------------------------------------------------
@interface PoCoSubViewWindow : NSWindowController
{
    IBOutlet NSScrollView *scroller_;   // scroller
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

// イベントの取得
-(void)keyDown:(NSEvent *)evt;          // キーダウン処理
-(void)keyUp:(NSEvent *)evt;            // キーリリース処理

@end
