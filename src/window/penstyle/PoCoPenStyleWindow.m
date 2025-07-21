//
// PoCoPenStyleWindow.m
// implementation of PoCoPenStyleWindow class.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoPenStyleWindow.h"

#import <Carbon/Carbon.h>

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"
#import "PoCoMonochromePattern.h"
#import "PoCoMonochromePatternView.h"
#import "PoCoMonochromePatternEditView.h"

// ============================================================================
@implementation PoCoPenStyleWindow

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
//
-(id)init
{
    // super class を初期化
    self = [super initWithWindowNibName:@"PoCoPenStyleWindow"];

    // 自身を初期化
    if (self != nil) {
        // 位置保存
        [self setWindowFrameAutosaveName:@"PenStyleWindowPos"];
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
//    penSizeSlider_ : ペン先大きさ(outlet)
//    densitySlider_ : 濃度(outlet)
//
//  Return
//    None
//
-(void)windowDidLoad
{
    PoCoEditInfo *info = [(PoCoAppController *)([NSApp delegate]) editInfo];

    [self->penSizeSlider_ setIntValue:[info penSize]];
    [self->densitySlider_ setFloatValue:((float)([info density]) / 100.0)];

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
    [(PoCoAppController *)([NSApp delegate]) closedPenStyleWindow];

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


// ----------------------------------------------------------------------------
// instance - public - for IBActions.

//
// ペン先太さ指定
//
//  Call
//    sender : 操作対象
//
//  Return
//    None
//
-(IBAction)penSizeSet:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setPenSize:[sender intValue]];

    return;
}


//
// 濃度指定
//
//  Call
//    sender : 操作対象
//
//  Return
//    None
//
-(IBAction)densitySet:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setDensity:(int)(floor([sender floatValue] * 100.0))];

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


// ----------------------------------------------------------------------------
// instance - public - for pattern setting sheet.

//
// パターン設定シートを開ける
//
//  Call
//    sender           : 操作元
//    pat              : パターン
//    patternSheet_    : 設定シート(outlet)
//    patternEditView_ : 設定領域(outlet)
//
//  Return
//    None
//
- (void)raisePatternSheet:(id)sender
                  pattern:(PoCoMonochromePattern *)pat
{
    DPRINT((@"open patternSheet\n"));

    // 設定を初期化
    [self->patternEditView_ setPattern:pat];

    // パレット入れ替えシートを開ける
    [self->patternEditView_ setNeedsDisplay:YES];
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
    __block typeof(self) tmpSelf = self;
    [[self window] beginSheet:self->patternSheet_
            completionHandler:^(NSModalResponse returnCode) {
        [tmpSelf patternSheetDidEnd:returnCode
                        contextInfo:(void *)(sender)];
    }];
#else   // (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
    [NSApp beginSheet:self->patternSheet_
       modalForWindow:[self window]
        modalDelegate:self
       didEndSelector:@selector(patternSheetDidEnd:returnCode:contextInfo:)
          contextInfo:(void *)(sender)];
#endif  // (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)

    return;
}


//
// パターン設定シートを閉じる
//
//  Call
//    sender        : 実行対象(api 変数)
//    patternSheet_ : 設定シート(outlet)
//
//  Return
//    None
//
- (IBAction)endPatternSheet:(id)sender
{
    DPRINT((@"will close patternSheet\n"));

    // パターン設定シートを閉じる
    [self->patternSheet_ orderOut:sender];
    [NSApp endSheet:self->patternSheet_
         returnCode:[sender tag]];

    return;
}


//
// パターン設定シートが閉じられた
//
//  Call
//    sheet            : 閉じたsheet(api 変数)
//    returnCode       : 終了時返り値(api 変数)
//    contextInfo      : 補助情報(api 変数）
//    patternEditView_ : 設定領域(outlet)
//
//  Return
//    None
//
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
- (void)patternSheetDidEnd:(NSModalResponse)returnCode
               contextInfo:(void *)contextInfo
#else   // (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
- (void)patternSheetDidEnd:(NSWindow *)sheet
                returnCode:(int)returnCode
               contextInfo:(void *)contextInfo
#endif  // (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
{
    PoCoMonochromePatternView *view = (PoCoMonochromePatternView *)(contextInfo);

    DPRINT((@"did close patternSheet\n"));

    if (returnCode != 0) {
        goto EXIT;
    }

    // パターンを更新
    [view updatePattern:[self->patternEditView_ pattern]];

EXIT:
    return;
}


// ----------------------------------------------------------------------------
// instance - public - set pen style / pen size / tile pattern / density.

//
// 次のペン先
//
//  Call
//    penStyleView_ : ペン先(outlet)
//
//  Return
//    None
//
- (void)nextPenStyle
{
    [self->penStyleView_ nextSelection];

    return;
}


//
// 前のペン先
//
//  Call
//    penStyleView_ : ペン先(outlet)
//
//  Return
//    None
//
- (void)prevPenStyle
{
    [self->penStyleView_ prevSelection];

    return;
}


//
// revert all pen styles to default.
//
//  Call:
//    penStyleView_ : view for pen style.(outlet)
//
//  Return:
//    none.
//
- (void)revertAllPenStyles
{
    [self->penStyleView_ revertAllPatterns];

    return;
}


//
// revert current pen style to default.
//
//  Call:
//    penStyleView_ : view for pen style.(outlet)
//
//  Return:
//    none.
//
- (void)revertPenStyle
{
    [self->penStyleView_ revertPattern];
    
    return;
}


//
// ペン太さのスライダーを次の値へ
//
//  Call
//    None
//
//  Return
//    penSizeSlider_ : ペン先大きさ(outlet)
//
- (void)nextPenSize
{
    PoCoEditInfo *info = [(PoCoAppController *)([NSApp delegate]) editInfo];

    if ([info penSize] < PEN_STYLE_SIZE) {
        [info setPenSize:([info penSize] + 1)];
        [self->penSizeSlider_ setIntValue:[info penSize]];
    }

    return;
}


//
// ペン太さのスライダーを前の値へ
//
//  Call
//    None
//
//  Return
//    penSizeSlider_ : ペン先大きさ(outlet)
//
- (void)prevPenSize
{
    PoCoEditInfo *info = [(PoCoAppController *)([NSApp delegate]) editInfo];

    if ([info penSize] > 1) {
        [info setPenSize:([info penSize] - 1)];
        [self->penSizeSlider_ setIntValue:[info penSize]];
    }

    return;
}


//
// 次のタイルパターン
//
//  Call
//    tilePatternView_ : タイルパターン(outlet)
//
//  Return
//    None
//
- (void)nextTilePattern
{
    [self->tilePatternView_ nextSelection];

    return;
}


//
// 前のタイルパターン
//
//  Call
//    tilePatternView_ : タイルパターン(outlet)
//
//  Return
//    None
//
- (void)prevTilePattern
{
    [self->tilePatternView_ prevSelection];

    return;
}


//
// revert all tile patterns to default.
//
//  Call:
//    tilePatternView_ : view for tile pattern.(outlet)
//
//  Return:
//    none.
//
- (void)revertAllTilePatterns
{
    [self->tilePatternView_ revertAllPatterns];

    return;
}


//
// revert current tile pattern to default.
//
//  Call:
//    tilePatternView_ : view for tile pattern.(outlet)
//
//  Return:
//    none.
//
- (void)revertTilePattern
{
    [self->tilePatternView_ revertPattern];

    return;
}


//
// 濃度のスライダーの値変更
//
//  Call
//    val : 変量(0.1% 単位)
//
//  Return
//    densitySlider_ : 濃度(outlet)
//
- (void)addDensity:(int)val
{
    PoCoEditInfo *info = [(PoCoAppController *)([NSApp delegate]) editInfo];
    int den;

    den = ((int)([info density]) + val);
    if (den < 0) {
        den = 0;
    } else if (den > (100 * 10)) {
        den = (100 * 10);
    }
    [info setDensity:(unsigned int)(den)];
    [self->densitySlider_ setFloatValue:((float)([info density]) / 100.0)];

    return;
}

@end
