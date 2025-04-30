//
//	Pelistina on Cocoa - PoCo -
//	参照ウィンドウ管理部
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoSubViewWindow.h"

#import <Carbon/Carbon.h>

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"

// ============================================================================
@implementation PoCoSubViewWindow

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function : 実体
//
-(id)init
{
    // super class の初期化
    self = [super initWithWindowNibName:@"PoCoSubViewWindow"];

    // 自身の初期化
    if (self != nil) {
        // 位置保存
        [self setWindowFrameAutosaveName:@"SubViewWindowPos"];
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
    // super class の解放
    [super dealloc];

    return;
}


//
// ウィンドウが読み込まれた
//
//  Call
//    scroller_ : scroller(outlet)
//
//  Return
//    None
//
-(void)windowDidLoad
{
    // scrollbar の表示方法
    switch ([[(PoCoAppController *)([NSApp delegate]) editInfo] showScrollerView]) {
        default:
        case PoCoScrollerType_default:
            // OS の設定に依存
            ;
            break;
        case PoCoScrollerType_always:
            // 常時
            [self->scroller_ setScrollerStyle:NSScrollerStyleLegacy];
            break;
        case PoCoScrollerType_overlay:
            // 適宜
            [self->scroller_ setScrollerStyle:NSScrollerStyleOverlay];
            break;
    }

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
    [(PoCoAppController *)([NSApp delegate]) closedSubViewWindow];

    return;
}


//
// 取り消し情報の引き渡し
//
//  Call
//    sender  : 管理元ウィンドウ(api 変数)
//  
//  Return
//    function : 取り消し情報
//
-(NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender
{
    return [[[NSDocumentController sharedDocumentController] currentDocument] undoManager];
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
