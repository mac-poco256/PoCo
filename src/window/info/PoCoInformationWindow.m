//
//	Pelistina on Cocoa - PoCo -
//	編集情報ウィンドウ管理部
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoInformationWindow.h"

#import <Carbon/Carbon.h>

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"

// ============================================================================
@implementation PoCoInformationWindow

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function : 実体
//    info_    : 編集情報(instance 変数)
//
-(id)init
{
    DPRINT((@"[PoCoInformationWindow init]\n"));

    // super class を初期化
    self = [super initWithWindowNibName:@"PoCoInformationWindow"];

    // 自身を初期化
    if (self != nil) {
        // 編集情報の取得
        self->info_ = [(PoCoAppController *)([NSApp delegate]) editInfo];
        [self->info_ retain];

        // observer の登録
        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(editInfoChangePos:)
                   name:PoCoEditInfoChangePos object:nil];

        // 位置保存
        [self setWindowFrameAutosaveName:@"InformationWindowPos"];
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
//    info_ : 編集情報(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoInformationWindow dealloc]\n"));

    // 資源の解放
    [self->info_ release];
    self->info_ = nil;

    // observer の登録を解除
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // super class の解放
    [super dealloc];

    return;
}


//
// 座標情報の更新(通知)
//
//  Call
//    note : 通知内容
//
//  Return
//    None
//
-(void)editInfoChangePos:(NSNotification *)note
{
    PoCoEditInfoPos type = [[note object] intValue];

    // 画像サイズ変更
    if (type & PoCoEditInfoPos_pictureRect) {
        [self displayPictureSize];
    }

    // 表示範囲変更
    if (type & PoCoEditInfoPos_viewRect) {
        [self displayDisplayRect];
    }

    // PD 位置移動
    if (type & PoCoEditInfoPos_pdPos) {
        [self displayPDPos];
    }

    // 編集範囲変動
    if (type & PoCoEditInfoPos_pdRect) {
        [self displayPDRect];
    }

    // 選択範囲変更
    if (type & PoCoEditInfoPos_selRect) {
        [self displaySelectionRect];
    }

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
    // 画像サイズの表示
    [self displayPictureSize];

    // 表示範囲の表示
    [self displayDisplayRect];

    // PD 位置の表示
    [self displayPDPos];

    // 編集範囲の表示
    [self displayPDRect];

    // 選択範囲の表示
    [self displaySelectionRect];

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
    [(PoCoAppController *)([NSApp delegate]) closedInformationWindow];

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


// ------------------------------------------- instance - public - 各内容の表示
//
// 画像サイズの表示
//
//  Call
//    info_       : 編集情報(instance 変数)
//    sizeWidth_  : 高さ(outlet)
//    sizeHeight_ : 幅(outlet)
//
//  Return
//   None
//
-(void)displayPictureSize
{
    PoCoRect *r;

    r = [self->info_ pictureRect];

    [self->sizeWidth_ setStringValue:[NSString stringWithFormat:@"%5d", [r width]]];
    [self->sizeHeight_ setStringValue:[NSString stringWithFormat:@"%5d", [r height]]];

    return;
}


//
// 表示範囲の表示
//
//  Call
//    info_       : 編集情報(instance 変数)
//    viewLeft_   : 実表示左辺(outlet)
//    viewTop_    : 実表示上底(outlet)
//    viewRight_  : 実表示右辺(outlet)
//    viewBottom_ : 実表示下底(outlet)
//
//  Return
//    None
//
-(void)displayDisplayRect
{
    PoCoRect *r;

    r = [self->info_ pictureView];

    [self->viewLeft_ setStringValue:[NSString stringWithFormat:@"%5d", [r left]]];
    [self->viewTop_ setStringValue:[NSString stringWithFormat:@"%5d", [r top]]];
    [self->viewRight_ setStringValue:[NSString stringWithFormat:@"%5d", [r right]]];
    [self->viewBottom_ setStringValue:[NSString stringWithFormat:@"%5d", [r bottom]]];

    return;
}


//
// PD 位置の表示
//
//  Call
//    info_ : 編集情報(instance 変数)
//    posX_ : PD 水平位置(outlet)
//    posY_ : PD 垂直位置(outlet)
//
//  Return
//    None
//
-(void)displayPDPos
{
    PoCoPoint *p;

    p = [self->info_ pdPos];

    [self->posX_ setStringValue:[NSString stringWithFormat:@"%5d", [p x]]];
    [self->posY_ setStringValue:[NSString stringWithFormat:@"%5d", [p y]]];

    return;
}


//
// 編集範囲の表示
//
//  Call
//    info_      : 編集情報(instance 変数)
//    posLeft_   : 枠左辺(outlet)
//    posTop_    : 枠上底(outlet)
//    posRight_  : 枠右辺(outlet)
//    posBottom_ : 枠下底(outlet)
//    posWidth_  : 枠幅(outlet)
//    posHeight_ : 枠高さ(outlet)
//
//  Return
//    None
//
-(void)displayPDRect
{
    PoCoRect *r;

    r = [self->info_ pdRect];

    [self->posLeft_ setStringValue:[NSString stringWithFormat:@"%5d", [r left]]];
    [self->posTop_ setStringValue:[NSString stringWithFormat:@"%5d", [r top]]];
    [self->posRight_ setStringValue:[NSString stringWithFormat:@"%5d", [r right]]];
    [self->posBottom_ setStringValue:[NSString stringWithFormat:@"%5d", [r bottom]]];
    [self->posWidth_ setStringValue:[NSString stringWithFormat:@"%5d", [r width]]];
    [self->posHeight_ setStringValue:[NSString stringWithFormat:@"%5d", [r height]]];

    return;
}


//
// 選択範囲の表示
//
//  Call
//    info_      : 編集情報(instance 変数)
//    selLeft_   : 左辺(outlet)
//    selTop_    : 上底(outlet)
//    selRight_  : 右辺(outlet)
//    selBottom_ : 下底(outlet)
//    selWidth_  : 幅(outlet)
//    selHeight_ : 高さ(outlet)
//
//  Return
//    None
//
-(void)displaySelectionRect
{
    PoCoRect *r;

    r = [self->info_ selRect];

    [self->selLeft_ setStringValue:[NSString stringWithFormat:@"%5d", [r left]]];
    [self->selTop_ setStringValue:[NSString stringWithFormat:@"%5d", [r top]]];
    [self->selRight_ setStringValue:[NSString stringWithFormat:@"%5d", [r right]]];
    [self->selBottom_ setStringValue:[NSString stringWithFormat:@"%5d", [r bottom]]];
    [self->selWidth_ setStringValue:[NSString stringWithFormat:@"%5d", [r width]]];
    [self->selHeight_ setStringValue:[NSString stringWithFormat:@"%5d", [r height]]];

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
