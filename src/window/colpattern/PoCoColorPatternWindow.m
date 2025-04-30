//
//	Pelistina on Cocoa - PoCo -
//	カラーパターンウィンドウ管理部
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoColorPatternWindow.h"

#import <Carbon/Carbon.h>

#import "PoCoAppController.h"
#import "PoCoColorPatternView.h"

// ============================================================================
@implementation PoCoColorPatternWindow

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    None
//
-(id)init
{
    DPRINT((@"[PoCoColorPatternWindow init]\n"));

    // super class を初期化
    self = [super initWithWindowNibName:@"PoCoColorPatternWindow"];

    // 自身を初期化
    if (self != nil) {
        // 位置保存
        [self setWindowFrameAutosaveName:@"ColorPatternWindowPos"];
    }

    return self;
}


//
// deallocate
//
//  Call
//    None
//
//  Return
//    None
//
-(void)dealloc
{
    DPRINT((@"[PoCoColorPatternWindow dealloc]\n"));

    // super class の解放
    [super dealloc];

    return;
}


//
// ウィンドウが読み込まれた
//
//  Call
//    None
//
//  Return
//    None
//
-(void)windowDidLoad
{
    return;
}


//
// ウィンドウが閉じられる(delegate method)
//
//  Call
//    note : 通知内容(api 変数)
//
//  Return
//    None
//
-(void)windowWillClose:(NSNotification *)note
{
    [(PoCoAppController *)([NSApp delegate]) closedColorPatternWindow];

    return;
}
  
    
//
// 取り消し情報の引き渡し
//
//  Call
//    sender : 管理元ウィンドウ(api 変数)
//  
//  Return
//    function : 取り消し情報
//
-(NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender
{
    return [[[NSDocumentController sharedDocumentController] currentDocument] undoManager];
}


//
// パターンを設定
//
//  Call
//    sender           : 操作対象
//    patternInfoView_ : カラーパターン管理部(outlet)
//
//  Return
//    None
//
-(void)setPattern:(id)sender
{
    // そのまま回送
    [self->patternInfoView_ setPattern:sender];

    return;
}


// ----------------------------------------- instance - public - イベントの取得
//
// キーダウン処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    None
//
-(void)keyDown:(NSEvent *)evt
{
    // スペースキーイベント(keyDown)を通知
    if ([evt keyCode] == kVK_Space) {
        if (!([evt isARepeat])) {
            [[NSNotificationCenter defaultCenter]
                postNotificationName:PoCoSpaceKeyEvent
                              object:[NSNumber numberWithBool:YES]];
        }
    } else {
        // super class へ回送
        [super keyDown:evt];
    }

    return;
}


//
// キーリリース処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    None
//
-(void)keyUp:(NSEvent *)evt
{
    // スペースキーイベント(keyUp)を通知
    if ([evt keyCode] == kVK_Space) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoSpaceKeyEvent
                          object:[NSNumber numberWithBool:NO]];
    } else {
        // super class へ回送
        [super keyUp:evt];
    }

    return;
}

@end
