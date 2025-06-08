//
// PoCoPaletteWindow.h
// implementation of PoCoPaletteWindow class.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoPaletteWindow.h"

#import <Carbon/Carbon.h>

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"
#import "PoCoMyDocument.h"
#import "PoCoPicture.h"
#import "PoCoPalette.h"
#import "PoCoPaletteView.h"
#import "PoCoPaletteInfoView.h"
#import "PoCoPaletteAttributeView.h"
#import "PoCoPaletteGradationView.h"
#import "PoCoPaletteExchangeView.h"

#import "PoCoControllerFactory.h"
#import "PoCoControllerPaletteAttributeSetter.h"
#import "PoCoControllerPictureColorExchanger.h"
#import "PoCoControllerPictureColorPaster.h"
#import "PoCoControllerPaletteNoEditter.h"

// 内部変数
static NSString *DISCLOSE_NAME = @"PoCoPaletteWindowDiscloseState";
static NSString *MASK_SELRANGE = @"PoCoPaletteWindowMaskSelectionRange";
static NSString *DROP_SELRANGE = @"PoCoPaletteWindowNoDropperSelectionRange";
static NSString *TRNS_SELRANGE = @"PoCoPaletteWindowTransparentSelectionRange";

// ============================================================================
@implementation PoCoPaletteWindow

// ------------------------------------------------------------- class - public
//
// 初期設定
//
//  Call
//    None
//
//  Return
//    None
//
+(void)initialize
{
    NSMutableDictionary *dic;

    dic = [NSMutableDictionary dictionary];

    // 各初期値を設定
    [dic setObject:[NSNumber numberWithBool:NO]
            forKey:DISCLOSE_NAME];
    [dic setObject:[NSNumber numberWithInt:1]
            forKey:MASK_SELRANGE];
    [dic setObject:[NSNumber numberWithInt:1]
            forKey:DROP_SELRANGE];
    [dic setObject:[NSNumber numberWithInt:1]
            forKey:TRNS_SELRANGE];

    // default を設定
    [[NSUserDefaults standardUserDefaults] registerDefaults:dic];

    return;
}


// ---------------------------------------------------------- instance - public
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
    // super class を初期化
    self = [super initWithWindowNibName:@"PoCoPaletteWindow"];

    // 自身を初期化
    if (self != nil) {
        // document controller を取得
        self->docCntl_ = [NSDocumentController sharedDocumentController];
        [self->docCntl_ retain];

        // 位置保存
        [self setWindowFrameAutosaveName:@"PaletteWindowPos"];
    }

    return self;
}


//
// deallocate.
//
//  Call
//    None
//
//  Return
//    docCntl_ : document controller(instance 変数)
//
- (void)dealloc
{
    // unregister observer.
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // 資源を解放
    [self->docCntl_ release];
    self->docCntl_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// window did load.
//
//  Call
//    mode_            : 色演算モード(outlet)
//    disclose_        : ウィンドウ拡縮(outlet)
//    paletteView_     : パレット一覧(outlet)
//    paletteInfoView_ : パレット詳細(outlet)
//    scroller_        : scroller(outlet)
//
//  Return
//    None
//
- (void)windowDidLoad
{
    BOOL  stat;
    NSRect r = [[self window] frame];

    // user default の取得
    stat = [[NSUserDefaults standardUserDefaults] boolForKey:DISCLOSE_NAME];
    [self->disclose_ setState:stat];

    // window の変形
    r.size.width = ((stat) ? 128 : 431);
    [[self window] setFrame:r
                    display:YES
                    animate:NO];
    [self->paletteInfoView_ setFirstState];
    [self->paletteView_ setDisclosed:stat];

    // 色演算モードの設定
    switch ([[(PoCoAppController *)([NSApp delegate]) editInfo] colorMode]) {
        case PoCoColorMode_RGB:
        default:
            [self->mode_ setState:1 atRow:0 column:0];
            [self->mode_ setState:0 atRow:0 column:1];
            break;
        case PoCoColorMode_HLS:
            [self->mode_ setState:0 atRow:0 column:0];
            [self->mode_ setState:1 atRow:0 column:1];
            break;
    }

    // scrollbar を常時表示にする
    [self->scroller_ setScrollerStyle:NSScrollerStyleLegacy];

    // 慣性スクロール禁止
    [self->scroller_ setVerticalScrollElasticity:NSScrollElasticityNone];

    // instruct to post norification, and register self as observer.
    [[self->scroller_ contentView] setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boundsDidChangeNotification:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:[self->scroller_ contentView]];

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
    [(PoCoAppController *)([NSApp delegate]) closedPaletteWindow];

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


//
// パレット固定
//
//  Call
//    sender           : 操作対象
//    paletteInfoView_ : パレット詳細(outlet)
//
//  Return
//    None
//
-(void)lockPalette:(id)sender
{
    // そのまま回送
    [self->paletteInfoView_ lockPalette:sender];

    return;
}


//
// ウィンドウ拡縮
//
//  Call
//    None
//
//  Return
//    function : 状態
//
-(BOOL)isDisclose
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:DISCLOSE_NAME];
}


//
// receive notification of NSViewBoundsDidChangeNotification.
//
//  Call:
//    note : notification.
//
//  Return:
//    paletteInfoView_ : detail information view of palette.(outlet)
//
- (void)boundsDidChangeNotification:(NSNotification *)note
{
    // instruct self->paletteInfoView_ to redraw.
    [self->paletteInfoView_ setNeedsDisplay:YES];

    return;
}


// -------------------------------------------- instance - public - IBAction 系
//
// ウィンドウ拡縮
//
//  Call
//    sender       : 操作対象(api 変数)
//    disclose_    : ウィンドウ拡縮(outlet)
//    paletteView_ : パレット一覧(outlet)
//
//  Return
//    disclose_ : ウィンドウ拡縮(outlet)
//
-(IBAction)changeDisclose:(id)sender
{
    NSRect r = [[self window] frame];
    const BOOL stat = (([[NSUserDefaults standardUserDefaults] boolForKey:DISCLOSE_NAME]) ? NO : YES);

    [self->disclose_ setState:stat];
    r.size.width = ((stat) ? 128 : 431);
    [[self window] setFrame:r
                    display:YES
                    animate:YES];
    [self->paletteView_ setDisclosed:stat];

    // user default の更新
    [[NSUserDefaults standardUserDefaults] setBool:stat
                                            forKey:DISCLOSE_NAME];

    return;
}


//
// 色演算モード切り替え
//
//  Call
//    sender           : 操作対象(api 変数)
//    mode_            : 色演算モード(outlet)
//    paletteInfoView_ : パレット詳細(outlet)
//
//  Return
//    None
//
-(IBAction)changeMode:(id)sender
{
    switch ((sender == self->mode_) ? [sender selectedColumn] : [sender tag]) {
        case 0:
        default:
            [[(PoCoAppController *)([NSApp delegate]) editInfo] setColorMode:PoCoColorMode_RGB];
            [self->mode_ setState:1 atRow:0 column:0];
            [self->mode_ setState:0 atRow:0 column:1];
            break;
        case 1:
            [[(PoCoAppController *)([NSApp delegate]) editInfo] setColorMode:PoCoColorMode_HLS];
            [self->mode_ setState:0 atRow:0 column:0];
            [self->mode_ setState:1 atRow:0 column:1];
            break;
    }

    // 詳細側の表示を更新
    [self->paletteInfoView_ setNeedsDisplay:YES];

    return;
}


// ----------------------------------------- instance - public - イベントの取得
//
// キーダウン処理
//
//  Call
//    evt              : 発生イベント(api 変数)
//    paletteInfoView_ : パレット詳細(outlet)
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
    } else if ([evt keyCode] == kVK_UpArrow) {
        [self->paletteInfoView_ scrollUp:nil];
        [self->paletteInfoView_ setNeedsDisplay:YES];
    } else if ([evt keyCode] == kVK_DownArrow) {
        [self->paletteInfoView_ scrollDown:nil];
        [self->paletteInfoView_ setNeedsDisplay:YES];
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
    } else if (([evt keyCode] == kVK_UpArrow) ||
               ([evt keyCode] == kVK_DownArrow)) {
        ;
    } else {
        // super class へ回送
        [super keyUp:evt];
    }

    return;
}


// --------------------------------- instance - public - 補助属性設定シート関連
//
// 補助属性設定シートを開く
//  PoCoPaletteWindow 内 [attribute] button の action
//
//  Call
//    sender                    : 実行対象(api 変数)
//    attributeSheet_           : 補助属性設定シート(outlet)
//    attributeMaskView_        : 上塗り禁止設定(outlet)
//    attributeDropperView_     : 吸い取り禁止設定(outlet)
//    attributeTransparentView_ : 透過設定(outlet)
//    rangeOfMask_              : 上塗り禁止指定の連続数(outlet)
//    rangeOfDropper_           : 吸い取り禁止指定の連続数(outlet)
//    rangeOfTransparent_       : 透明指定の連続数(outlet)
//    docCntl_                  : document controller(instance 変数)
//
//  Return
//    None
//
-(IBAction)raiseAttributeSheet:(id)sender
{
    int l;
    PoCoColor *col;
    PoCoPalette *palette = [[[self->docCntl_ currentDocument] picture] palette];

    DPRINT((@"open attributeSheet\n"));

    // 値を設定
    for (l = 0; l < COLOR_MAX; (l)++) {
        col = [palette palette:l];
        [self->attributeMaskView_        setAttribute:[col    isMask] index:l];
        [self->attributeDropperView_     setAttribute:[col noDropper] index:l];
        [self->attributeTransparentView_ setAttribute:[col   isTrans] index:l];
    }
    [self->attributeMaskView_        setNeedsDisplay:YES];
    [self->attributeDropperView_     setNeedsDisplay:YES];
    [self->attributeTransparentView_ setNeedsDisplay:YES];

    // 連続数の指定を設定
    l = (int)([[NSUserDefaults standardUserDefaults] integerForKey:MASK_SELRANGE]);
    [self->rangeOfMask_       setIntegerValue:l];
    [self->attributeMaskView_ setRange:l];
    l = (int)([[NSUserDefaults standardUserDefaults] integerForKey:DROP_SELRANGE]);
    [self->rangeOfDropper_       setIntegerValue:l];
    [self->attributeDropperView_ setRange:l];
    l = (int)([[NSUserDefaults standardUserDefaults] integerForKey:TRNS_SELRANGE]);
    [self->rangeOfTransparent_       setIntegerValue:l];
    [self->attributeTransparentView_ setRange:l];

    // 補助属性設定シートを開ける
    [NSApp beginSheet:self->attributeSheet_
       modalForWindow:[self window]
        modalDelegate:self
       didEndSelector:@selector(attributeSheetDidEnd:returnCode:contextInfo:)
          contextInfo:nil];

    return;
}


//
// 補助属性設定シートを閉じる
//  AttributeSheet 内 [cancel] [set] button の action
//
//  Call
//    sender              : 実行対象(api 変数)
//    attributeSheet_     : 補助属性設定シート(outlet)
//    rangeOfMask_        : 上塗り禁止指定の連続数(outlet)
//    rangeOfDropper_     : 吸い取り禁止指定の連続数(outlet)
//    rangeOfTransparent_ : 透明指定の連続数(outlet)
//
//  Return
//    None
//
-(IBAction)endAttributeSheet:(id)sender
{
    DPRINT((@"will close attributeSheet\n"));

    // 連続数の指定を記憶
    [[NSUserDefaults standardUserDefaults] setInteger:[self->rangeOfMask_ integerValue]
                                               forKey:MASK_SELRANGE];
    [[NSUserDefaults standardUserDefaults] setInteger:[self->rangeOfDropper_ integerValue]
                                               forKey:DROP_SELRANGE];
    [[NSUserDefaults standardUserDefaults] setInteger:[self->rangeOfTransparent_ integerValue]
                                               forKey:TRNS_SELRANGE];

    // 補助属性設定シートを閉じる
    [self->attributeSheet_ orderOut:sender];
    [NSApp endSheet:self->attributeSheet_
         returnCode:[sender tag]];

    return;
}


//
// 補助属性設定シートが閉じられた
//    sheet を開くときに指定した selector
//
//  Call
//    sheet                     : 閉じたsheet (api 変数)
//    returnCode                : 終了時返り値(api 変数)
//    contextInfo               : 補助情報(api 変数)
//    attributeMaskView_        : 上塗り禁止設定(outlet)
//    attributeDropperView_     : 吸い取り禁止設定(outlet)
//    attributeTransparentView_ : 透過設定(outlet)
//
//  Return
//    None
//
-(void)attributeSheetDidEnd:(NSWindow *)sheet
                 returnCode:(int)returnCode
                contextInfo:(void *)contextInfo
{
    DPRINT((@"did close attributeSheet : %d\n", returnCode));

    // [set] で抜けていたら、設定を反映
    if (returnCode == 0) {
        // 設定
        [[(PoCoAppController *)([NSApp delegate]) factory]
            createPaletteAttributeSetter:YES
                                   start:0
                                     end:COLOR_MAX
                                    mask:(const BOOL *)([self->attributeMaskView_ attribute])
                                 dropper:(const BOOL *)([self->attributeDropperView_ attribute])
                                   trans:(const BOOL *)([self->attributeTransparentView_ attribute])];
    }

    return;
}


//
// 上塗り禁止指定の連続数
//
//  Call
//    sender             : 操作対象(api 変数)
//    attributeMaskView_ : 上塗り禁止設定(outlet)
//
//  Return
//    None
//
-(void)rangeOfMask:(id)sender
{
    [self->attributeMaskView_ setRange:(int)([sender integerValue])];

    return;
}


//
// 吸い取り禁止指定の連続数
//
//  Call
//    sender                : 操作対象(api 変数)
//    attributeDropperView_ : 吸い取り禁止設定(outlet)
//
//  Return
//    None
//
-(void)rangeOfDropper:(id)sender
{
    [self->attributeDropperView_ setRange:(int)([sender integerValue])];

    return;
}


//
// 透明指定の連続数
//
//  Call
//    sender                    : 操作対象(api 変数)
//    attributeTransparentView_ : 透過設定(outlet)
//
//  Return
//    None
//
-(void)rangeOfTransparent:(id)sender
{
    [self->attributeTransparentView_ setRange:(int)([sender integerValue])];

    return;
}


//
// すべての範囲を設定
//
//  Call
//    rangeOfMask_        : 上塗り禁止指定の連続数(outlet)
//    rangeOfDropper_     : 吸い取り禁止指定の連続数(outlet)
//    rangeOfTransparent_ : 透明指定の連続数(outlet)
//
//  Return
//    attributeMaskView_        : 上塗り禁止設定(outlet)
//    attributeDropperView_     : 吸い取り禁止設定(outlet)
//    attributeTransparentView_ : 透過設定(outlet)
//
-(void)invokeUpdateAllRange
{
    [self->attributeMaskView_        setRange:(int)([self->rangeOfMask_        integerValue])];
    [self->attributeDropperView_     setRange:(int)([self->rangeOfDropper_     integerValue])];
    [self->attributeTransparentView_ setRange:(int)([self->rangeOfTransparent_ integerValue])];

    return;
}


// --------------------------- instance - public - グラデーション作成シート関連
//
// グラデーション作成シートを開く
//  PoCoPaletteWindow 内 [gradation] button の action
//
//  Call
//    sender          : 実行対象(api 変数)
//    gradationSheet_ : グラデーション作成シート(outlet)
//    gradationView_  : 対象色指定領域(outlet)
//
//  Return
//    None
//
-(IBAction)raiseGradationSheet:(id)sender
{
    DPRINT((@"open gradationSheet\n"));

    // グラデーション作成シートを開ける
    [self->gradationView_ setNeedsDisplay:YES];
    [NSApp beginSheet:self->gradationSheet_
       modalForWindow:[self window]
        modalDelegate:self
       didEndSelector:@selector(gradationSheetDidEnd:returnCode:contextInfo:)
          contextInfo:nil];

    return;
}


//
// グラデーション作成シートを閉じる
//  GradationSheet 内 [cancel] [set] button の action
//
//  Call
//    sender          : 実行対象(api 変数)
//    gradationSheet_ : グラデーション作成シート(outlet)
//
//  Return
//    None
//
-(IBAction)endGradationSheet:(id)sender
{
    DPRINT((@"will close gradationSheet\n"));

    // グラデーション作成シートを閉じる
    [self->gradationSheet_ orderOut:sender];
    [NSApp endSheet:self->gradationSheet_
         returnCode:[sender tag]];

    return;
}


//
// グラデーション作成シートが閉じられた
//  sheet を開くときに指定した selector
//
//  Call
//    sheet          : 閉じたshee (api 変数)
//    returnCode     : 終了時返り値(api 変数)
//    contextInfo    : 補助情報(api 変数）
//    gradationView_ : 対象色指定領域(outlet)
//
//  Return
//    None
//
-(void)gradationSheetDidEnd:(NSWindow *)sheet
                 returnCode:(int)returnCode
                contextInfo:(void *)contextInfo
{
    DPRINT((@"did close gradationSheet : %d\n", returnCode));

    // [set] で抜けていたら、設定を反映
    if (returnCode == 0) {
        [[(PoCoAppController *)([NSApp delegate]) factory]
            createPaletteGradationMaker:YES
                                  start:[self->gradationView_ leftNum]
                                    end:[self->gradationView_ rightNum]];
    }

    return;
}


// ----------------------------- instance - public - パレット入れ替えシート関連
//
// パレット入れ替えシートを開く
//  PoCoPaletteWindow 内 [gradation] button の action
//
//  Call
//    sender         : 実行対象(api 変数)
//    exchangeSheet_ : パレット入れ替えシート(outlet)
//    exchangeView_  : パレット入れ替え設定領域(outlet)
//
//  Return
//    None
//
-(IBAction)raiseExchangeSheet:(id)sender
{
    DPRINT((@"open exchangeSheet\n"));

    // 設定を初期化
    [self->exchangeView_ setUp];

    // パレット入れ替えシートを開ける
    [self->exchangeView_ setNeedsDisplay:YES];
    [NSApp beginSheet:self->exchangeSheet_
       modalForWindow:[self window]
        modalDelegate:self
       didEndSelector:@selector(exchangeSheetDidEnd:returnCode:contextInfo:)
          contextInfo:nil];

    return;
}


//
// パレット入れ替えシートを閉じる
//  GradationSheet 内 [cancel] [set] button の action
//
//  Call
//    sender         : 実行対象(api 変数)
//    exchangeSheet_ : パレット入れ替えシート(outlet)
//
//  Return
//    None
//
-(IBAction)endExchangeSheet:(id)sender
{
    DPRINT((@"will close exchangeSheet\n"));

    // パレット入れ替えシートを閉じる
    [self->exchangeSheet_ orderOut:sender];
    [NSApp endSheet:self->exchangeSheet_
         returnCode:[sender tag]];

    return;
}


//
// パレット入れ替えシートが閉じられた
//  sheet を開くときに指定した selector
//
//  Call
//    sheet         : 閉じたsheet(api 変数)
//    returnCode    : 終了時返り値(api 変数)
//    contextInfo   : 補助情報(api 変数)
//    exchangeView_ : パレット入れ替え設定領域(outlet)
//
//  Return
//    None
//
-(void)exchangeSheetDidEnd:(NSWindow *)sheet
                returnCode:(int)returnCode
               contextInfo:(void *)contextInfo
{
    id  cntl;
    BOOL upd;
    NSEnumerator *iter;
    PoCoPaletteExchangePair *pair;
    PoCoControllerFactory *factory;

    DPRINT((@"did close exchangeSheet : %d\n", returnCode));

    // [set] で抜けていたら、設定を反映
    if (returnCode != 0) {
        goto EXIT;
    }

    // factory の取得
    factory = [(PoCoAppController *)([NSApp delegate]) factory];

    // 定義されている分だけ逐次実行
    iter = [[self->exchangeView_ exchangeTable] objectEnumerator];
    pair = [iter nextObject];
    upd = NO;
    for ( ; pair != nil; pair = [iter nextObject]) {
       cntl = [factory createPictureColorExchangerPassive:NO
                                                      src:[pair src]
                                                      dst:[pair dst]];
       upd |= [cntl execute];
       [cntl release];
    }

    // 通知部を生成
    if (upd) {
        [factory createPaletteNoEditter:YES
                                   name:[[NSBundle mainBundle] localizedStringForKey:@"PaletteExchange"
                                                                               value:@"exchange palette"
                                                                               table:nil]
                                  index:-1];
    }

EXIT:
    return;
}


// --------------------------------- instance - public - パレット複写シート関連
//
// パレット複写シートを開く
//  PoCoPaletteWindow 内 [gradation] button の action
//
//  Call
//    sender      : 実行対象(api 変数)
//    pasteSheet_ : パレット複写シート(outlet)
//    pasteView_  : パレット複写設定領域(outlet)
//
//  Return
//    None
//
-(IBAction)raisePasteSheet:(id)sender
{
    DPRINT((@"open pasteSheet\n"));

    // 設定を初期化
    [self->pasteView_ setUp];

    // パレット複写シートを開ける
    [self->pasteView_ setNeedsDisplay:YES];
    [NSApp beginSheet:self->pasteSheet_
       modalForWindow:[self window]
        modalDelegate:self
       didEndSelector:@selector(pasteSheetDidEnd:returnCode:contextInfo:)
          contextInfo:nil];

    return;
}


//
// パレット複写シートを閉じる
//  GradationSheet 内 [cancel] [set] button の action
//
//  Call
//    sender      : 実行対象(api 変数)
//    pasteSheet_ : パレット複写シート(outlet)
//
//  Return
//    None
//
-(IBAction)endPasteSheet:(id)sender
{
    DPRINT((@"will close pasteSheet\n"));

    // パレット複写シートを閉じる
    [self->pasteSheet_ orderOut:sender];
    [NSApp endSheet:self->pasteSheet_
         returnCode:[sender tag]];

    return;
}


//
// パレット複写シートが閉じられた
//  sheet を開くときに指定した selector
//
//  Call
//    sheet       : 閉じたsheet(api 変数)
//    returnCode  : 終了時返り値(api 変数)
//    contextInfo : 補助情報(api 変数)
//    pasteView_  : パレット複写設定領域(outlet)
//
//  Return
//    None
//
-(void)pasteSheetDidEnd:(NSWindow *)sheet
                returnCode:(int)returnCode
               contextInfo:(void *)contextInfo
{
    id  cntl;
    BOOL upd;
    NSEnumerator *iter;
    PoCoPaletteExchangePair *pair;
    PoCoControllerFactory *factory;

    DPRINT((@"did close pasteSheet : %d\n", returnCode));

    // [set] で抜けていたら、設定を反映
    if (returnCode != 0) {
        goto EXIT;
    }

    // factory の取得
    factory = [(PoCoAppController *)([NSApp delegate]) factory];

    // 定義されている分だけ逐次実行
    iter = [[self->pasteView_ exchangeTable] objectEnumerator];
    pair = [iter nextObject];
    upd = NO;
    for ( ; pair != nil; pair = [iter nextObject]) {
       cntl = [factory createPictureColorPasterPassive:NO
                                                   src:[pair src]
                                                   dst:[pair dst]];
       upd |= [cntl execute];
       [cntl release];
    }

    // 通知部を生成
    if (upd) {
        [factory createPaletteNoEditter:YES
                                   name:[[NSBundle mainBundle] localizedStringForKey:@"PalettePaste"
                                                                               value:@"paste palette"
                                                                               table:nil]
                                  index:-1];
    }

EXIT:
    return;
}

@end
