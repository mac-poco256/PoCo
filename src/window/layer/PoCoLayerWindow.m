//
// PoCoLayerWindow.h
// implementation of PoCoLayerWindow class.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoLayerWindow.h"

#import <Carbon/Carbon.h>

#import "PoCoAppController.h"
#import "PoCoLayerTableView.h"
#import "PoCoLayerOperate.h"

// 内部定数
#if 0
static const NSSize RESIZE_INC = (NSSize){1.0, 52.0};
#endif  // 0

// ============================================================================
@implementation PoCoLayerWindow

// ----------------------------------------------------------------------------
// instance - public.

//
// initialize
//
//  Call
//    None
//
//  Return
//    function : 実体
//    docCntl_ : document controller(instance 変数)
//
-(id)init
{
    // supler class の初期化
    self = [super initWithWindowNibName:@"PoCoLayerWindow"];

    // 自身の初期化
    if (self != nil) {
        // document controller を取得
        self->docCntl_ = [NSDocumentController sharedDocumentController];
        [self->docCntl_ retain];

        // 位置保存
        [self setWindowFrameAutosaveName:@"LayerWindowPos"];
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
//    docCntl_ : document controller(instance 変数)
//
-(void)dealloc
{
    // 資源の解放
    [self->docCntl_ release];
    self->docCntl_ = nil;

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
#if 0
    [[self window] setResizeIncrements:RESIZE_INC];
#endif  // 0

    // scrollbar を常時表示にする
    [self->scroller_ setScrollerStyle:NSScrollerStyleLegacy];

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
    [(PoCoAppController *)([NSApp delegate]) closedLayerWindow];

    return;
}


//  
// 取り消し情報の引き渡し
//
//  Call
//    sender   : 管理元ウィンドウ(api 変数)
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    function : 取り消し情報
//
-(NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender
{
    return [[self->docCntl_ currentDocument] undoManager];
}


// ----------------------------------------------------------------------------
// instance - public - for menu.

//
// 画像レイヤー生成
//
//  Call
//    sender          : 操作対象
//    layerTableView_ : レイヤー一覧テーブル(outlet)
//
//  Return
//    None
//
- (void)newBitmapLayer:(id)sender
{
    [(PoCoLayerOperate *)([self->layerTableView_ delegate]) newBitmapLayer:sender];

    return;
}


//
// 文字列レイヤー生成
//
//  Call
//    sender          : 操作対象
//    layerTableView_ : レイヤー一覧テーブル(outlet)
//
//  Return
//    None
//
- (void)newStringLayer:(id)sender
{
    [(PoCoLayerOperate *)([self->layerTableView_ delegate]) newStringLayer:sender];

    return;
}


//
// copy layer.
//
//  Call:
//    sender          : 操作対象
//    layerTableView_ : レイヤー一覧テーブル(outlet)
//
//  Return:
//    none.
//
- (void)copyLayer:(id)sender
{
    [(PoCoLayerOperate *)([self->layerTableView_ delegate]) copyLayer:sender];

    return;
}


//
// レイヤー削除
//
//  Call
//    sender          : 操作対象
//    layerTableView_ : レイヤー一覧テーブル(outlet)
//
//  Return
//    None
//
- (void)deleteLayer:(id)sender
{
    [(PoCoLayerOperate *)([self->layerTableView_ delegate]) deleteLayer:sender];

    return;
}


//
// 表示レイヤー統合
//
//  Call
//    sender          : 操作対象
//    layerTableView_ : レイヤー一覧テーブル(outlet)
//
//  Return
//    None
//
- (void)unificateLayer:(id)sender
{
    [(PoCoLayerOperate *)([self->layerTableView_ delegate]) unificateLayer:sender];

    return;
}


// ----------------------------------------------------------------------------
// instance - public - event handler.

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
