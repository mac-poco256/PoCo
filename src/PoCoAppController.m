//
// PoCoAppController.m
// implementation of PoCoAppController class.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoAppController.h"

#import "PoCoControllerFactory.h"
#import "PoCoGlobalObserver.h"
#import "PoCoEditInfo.h"
#import "PoCoPenStyle.h"
#import "PoCoTilePattern.h"
#import "PoCoMyDocument.h"
#import "PoCoPicture.h"

#import "PoCoPreferencesPanel.h"
#import "PoCoNewDocumentPanel.h"
#import "PoCoSubViewWindow.h"
#import "PoCoPaletteWindow.h"
#import "PoCoPenStyleWindow.h"
#import "PoCoLayerWindow.h"
#import "PoCoInformationWindow.h"
#import "PoCoToolbarWindow.h"
#import "PoCoColorPatternWindow.h"

// 内部変数
static NSString *SUBVIEW_OPEN_NAME = @"PoCoSubViewWindowOpened";
static NSString *PALETTE_OPEN_NAME = @"PoCoPaletteWindowOpened";
static NSString *PENSTYLE_OPEN_NAME = @"PoCoPenStyleWindowOpened";
static NSString *LAYER_OPEN_NAME = @"PoCoLayerWindowOpened";
static NSString *INFORMATION_OPEN_NAME = @"PoCoInformationWindowOpened";
static NSString *TOOLBAR_OPEN_NAME = @"PoCoToolbarWindowOpened";
static NSString *COLORPATTERN_OPEN_NAME = @"PoCoColorPaternWindowOpened";
static NSString *DEFAULT_RESOLUTION = @"PoCoNewDocumentDefaultResolution";
static NSString *DEFAULT_COLOR = @"PoCoNewDocumentDefaultColor";

// ============================================================================
@implementation PoCoAppController

// --------------------------------------------------------- instance - private
//
// ウィンドウ開閉情報の記憶
//
//  Call
//    name : user default の名称
//    type : 開閉状況
//
//  Return
//    None
//
-(void)setOpenedState:(NSString *)name 
                 type:(BOOL)type
{
    [[NSUserDefaults standardUserDefaults] setBool:type
                                            forKey:name];

    return;
}


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
    [dic setObject:[NSNumber numberWithBool:YES] forKey:SUBVIEW_OPEN_NAME];
    [dic setObject:[NSNumber numberWithBool:YES] forKey:PALETTE_OPEN_NAME];
    [dic setObject:[NSNumber numberWithBool:YES] forKey:PENSTYLE_OPEN_NAME];
    [dic setObject:[NSNumber numberWithBool:YES] forKey:LAYER_OPEN_NAME];
    [dic setObject:[NSNumber numberWithBool:YES] forKey:TOOLBAR_OPEN_NAME];
    [dic setObject:[NSNumber numberWithBool:NO]  forKey:COLORPATTERN_OPEN_NAME];
    [dic setObject:[NSNumber numberWithBool:NO]  forKey:INFORMATION_OPEN_NAME];

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
//    function            : 実体
//    willFinish_         : 終了処理中か(instance 変数)
//    preferencesPanel_   : 環境設定パネル(instance 変数)
//    newDocumentPanel_   : 新規画像パネル(instance 変数)
//    subViewWindow_      : 参照(instance 変数)
//    toolbarWindow_      : 主ツールバー(instance 変数)
//    paletteWindow_      : パレット(instance 変数)
//    colorPatternWindow_ : カラーパターン(instance 変数)
//    layerWindow_        : レイヤー(instance 変数)
//    penStyleWindow_     : ペン先形状(instance 変数)
//    informationWindow_  : 編集情報(instance 変数)
//    factory_            : 編集部の生成部(instance 変数)
//    observer_           : 広域通知受信部(instance 変数)
//    editInfo_           : 編集情報(instance 変数)
//    penStyle_           : ペン先(instance 変数)
//    penSteadyStyle_     : 定常ペン先(instance 変数)
//    tilePattern_        : タイルパターン(instance 変数)
//    tileSteadyPattern_  : 定常タイルパターン(instance 変数)
//
-(id)init
{
    DPRINT((@"[PoCoAppController init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->willFinish_ = NO;

        self->preferencesPanel_ = nil;
        self->newDocumentPanel_ = nil;
        self->subViewWindow_ = nil;
        self->toolbarWindow_ = nil;
        self->paletteWindow_ = nil;
        self->colorPatternWindow_ = nil;
        self->layerWindow_ = nil;
        self->penStyleWindow_ = nil;
        self->informationWindow_ = nil;

        self->factory_ = nil;
        self->observer_ = nil;
        self->editInfo_ = nil;
        self->penStyle_ = nil;
        self->penSteadyStyle_ = nil;
        self->tilePattern_ = nil;
        self->tileSteadyPattern_ = nil;

        // 編集部の生成部の生成
        self->factory_ = [[PoCoControllerFactory alloc] init];
        if (self->factory_ == nil) {
            DPRINT((@"can't create PoCoControllerFactory\n"));
            [self release];
            self = nil;
            goto EXIT;
        }

        // 広域通知受信部を生成
        self->observer_ = [[PoCoGlobalObserver alloc] init];
        if (self->observer_ == nil) {
            DPRINT((@"can't create PoCoGlobalObserver\n"));
            [self release];
            self = nil;
            goto EXIT;
        }

        // 編集情報を生成
        self->editInfo_ = [[PoCoEditInfo alloc] init];
        if (self->editInfo_ == nil) {
            DPRINT((@"can't create PoCoEditInfo\n"));
            [self release];
            self = nil;
            goto EXIT;
        }

        // ペン先情報を準備
        self->penStyle_ = [[PoCoPenStyle alloc] init];
        if (self->penStyle_ == nil) {
            DPRINT((@"can't create PoCoPenStyle\n"));
            [self release];
            self = nil;
            goto EXIT;
        }
        self->penSteadyStyle_ = [[PoCoPenSteadyStyle alloc] init];
        if (self->penSteadyStyle_ == nil) {
            DPRINT((@"can't create PoCoPenSteadyStyle\n"));
            [self release];
            self = nil;
            goto EXIT;
        }

        // タイルパターン情報を準備
        self->tilePattern_ = [[PoCoTilePattern alloc] init];
        if (self->tilePattern_ == nil) {
            DPRINT((@"can't create PoCoTilePattern\n"));
            [self release];
            self = nil;
            goto EXIT;
        }
        self->tileSteadyPattern_ = [[PoCoTileSteadyPattern alloc] init];
        if (self->tileSteadyPattern_ == nil) {
            DPRINT((@"can't create PoCoPenSteadyPattern\n"));
            [self release];
            self = nil;
            goto EXIT;
        }
    }

EXIT:
    return self;
}


//
// deallocate
//
//  Call
//    None
//
//  Return
//    preferencesPanel_   : 環境設定パネル(instance 変数)
//    newDocumentPanel_   : 新規画像パネル(instance 変数)
//    subViewWindow_      : 参照(instance 変数)
//    toolbarWindow_      : 主ツールバー(instance 変数)
//    paletteWindow_      : パレット(instance 変数)
//    colorPatternWindow_ : カラーパターン(instance 変数)
//    layerWindow_        : レイヤー(instance 変数)
//    penStyleWindow_     : ペン先形状(instance 変数)
//    informationWindow_  : 編集情報(instance 変数)
//    factory_            : 編集部の生成部(instance 変数)
//    observer_           : 広域通知受信部(instance 変数)
//    editInfo_           : 編集情報(instance 変数)
//    penStyle_           : ペン先(instance 変数)
//    penSteadyStyle_     : 定常ペン先(instance 変数)
//    tilePattern_        : タイルパターン(instance 変数)
//    tileSteadyPattern_  : 定常タイルパターン(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoAppController dealloc]\n"));

    // 各パネル/ウィンドウを release
    [self->penStyleWindow_ release];
    [self->paletteWindow_ release];
    [self->subViewWindow_ release];
    [self->layerWindow_ release];
    [self->informationWindow_ release];
    [self->toolbarWindow_ release];
    [self->colorPatternWindow_ release];
    [self->newDocumentPanel_ release];
    [self->preferencesPanel_ release];

    // 参照 pointer を nil にする
    self->informationWindow_ = nil;
    self->penStyleWindow_ = nil;
    self->layerWindow_ = nil;
    self->colorPatternWindow_ = nil;
    self->paletteWindow_ = nil;
    self->toolbarWindow_ = nil;
    self->subViewWindow_ = nil;
    self->newDocumentPanel_ = nil;
    self->preferencesPanel_ = nil;

    // タイルパターン情報を解放
    [self->tilePattern_ release];
    [self->tileSteadyPattern_ release];
    self->tilePattern_ = nil;
    self->tileSteadyPattern_ = nil;

    // ペン先情報を解放
    [self->penStyle_ release];
    [self->penSteadyStyle_ release];
    self->penStyle_ = nil;
    self->penSteadyStyle_ = nil;

    // 編集情報を解放
    [self->editInfo_ release];
    self->editInfo_ = nil;

    // 広域通知受信部を解放
    [self->observer_ release];
    self->observer_ = nil;

    // 編集部の生成部を解放
    [self->factory_ release];
    self->factory_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// untitled window の抑止
//  起動直後の空ウィンドウを抑止する
//
//  Call
//    sender : 要求の通知元(api 引数)
//
//  Return
//    function : NO(常時)
//
-(BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    DPRINT((@"[PoCoAppController applicationShouldOpenUntitledFile]\n"));

    if ([self->editInfo_ noOpenNewDocPanel]) {
        // 次からは開かない設定
        ;
    } else {
        // 新規ドキュメント作成になる
        [self showNewDocumentPanel:sender];
    }

    return NO;                          // 常時 NO
}


//
// nib が読み込まれた
//
//  Call
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(void)awakeFromNib
{
    NSUserDefaults *def;

    def = [NSUserDefaults standardUserDefaults];

    // 各ウィンドウを開ける
    if ([def boolForKey:SUBVIEW_OPEN_NAME]) {
        [self showSubViewWindow:nil];
    }
    if ([def boolForKey:PALETTE_OPEN_NAME]) {
        [self showPaletteWindow:nil];
    }
    if ([def boolForKey:PENSTYLE_OPEN_NAME]) {
        [self showPenStyleWindow:nil];
    }
    if ([def boolForKey:LAYER_OPEN_NAME]) {
        [self showLayerWindow:nil];
    }
    if ([def boolForKey:INFORMATION_OPEN_NAME]) {
        [self showInformationWindow:nil];
    }
    if ([def boolForKey:TOOLBAR_OPEN_NAME]) {
        [self showToolbarWindow:nil];
    }
    if ([def boolForKey:COLORPATTERN_OPEN_NAME]) {
        [self showColorPatternWindow:nil];
    }

    return;
}


//
// アプリケーションが終了する
//
//  Call
//    note : 通知(api 引数)
//
//  Return
//    willFinish_ : 終了処理中か(instance 変数)
//
-(void)applicationWillTerminate:(NSNotification *)note
{
    self->willFinish_ = YES;
   
    return;
}


//
// express this app supports secure state restoration.
//
//  Call:
//    none.
//
//  Return:
//    function : always YES.
//
- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app
{
    return YES;
}


//
// 主ツールバーを取得
//
//  Call
//    toolbarWindow_ : ツールバー(instance 変数)
//
//  Return
//    function : ツールバー
//
-(PoCoToolbarWindow *)toolbarWindow
{
    return self->toolbarWindow_;
}


//
// 新規タブ
//
//  Call
//    sender : 送信元(api 変数)
//
//  Return
//    None
//
-(IBAction)newWindowForTab:(id)sender
{
    id newDoc;

    // 新規 document を生成
    newDoc = [[MyDocument alloc] initWidth:[[[[[NSDocumentController sharedDocumentController] currentDocument] picture] bitmapPoCoRect] width]
                                initHeight:[[[[[NSDocumentController sharedDocumentController] currentDocument] picture] bitmapPoCoRect] height]
                            initResolution:(int)([[NSUserDefaults standardUserDefaults] integerForKey:DEFAULT_RESOLUTION])
                              defaultColor:(unsigned char)([[NSUserDefaults standardUserDefaults] integerForKey:DEFAULT_COLOR])];
    if (newDoc == nil) {
        DPRINT((@"can't make new document.\n"));
    } else {
        [[NSDocumentController sharedDocumentController] addDocument:newDoc];
        [newDoc makeWindowControllers];
        [newDoc showWindows];
#if 0   // そもそも名称が指定できないので拡張子の与えようもない
        if ([[self->name_ stringValue] length] > 0) {
            nm = [[NSString stringWithString:[self->name_ stringValue]]
              stringByAppendingPathExtension:@"poco"];
            [newDoc setFileURL:[NSURL URLWithString:nm]];
        }
#endif  // 0

        // DocumentController に引き渡したので忘れる
        [newDoc release];
    }

    return;
}


// ------------------------- instance - public - アプリケーション共通情報の取得
//
// 終了処理中ではないか
//
//  Call
//    willFinish_ : 終了処理中か(instance 変数)
//
//  Return
//    function : 終了処理中ではないか
//
-(BOOL)noFinishProc
{
    return !(self->willFinish_);
}


//
// 編集部の生成部の取得
//
//  Call
//    factory_ : 編集部の生成部(instance 変数)
//
//  Return
//    function : 編集部の生成部
//
-(PoCoControllerFactory *)factory
{
    return self->factory_;
}


//
// 共通編集情報の取得
//
//  Call
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    function : 編集情報の実体
//
-(PoCoEditInfo *)editInfo
{
    return self->editInfo_;
}


//
// ペン先情報の取得
//
//  Call
//    penStyle_ : ペン先情報(instance 変数)
//
//  Return
//    function : ペン先情報の実体
//
-(PoCoPenStyle *)penStyle
{
    return self->penStyle_;
}


//
// 定常ペン先情報の取得
//
//  Call
//    penSteadyStyle_ : 定常ペン先情報(instance 変数)
//
//  Return
//    function : 定常ペン先情報の実体
//
-(PoCoPenSteadyStyle *)penSteadyStyle
{
    return self->penSteadyStyle_;
}


//
// タイルパターン情報の取得
//
//  Call
//    tilePattern_ : タイルパターン情報(instance 変数)
//
//  Return
//    function : タイルパターン情報の実体
//
-(PoCoTilePattern *)tilePattern
{
    return self->tilePattern_;
}


//
// メニューを更新
//
//  Call
//    menu           : menu(api 変数)
//    editInfo_      : 編集情報(instance 変数)
//    paletteWindow_ : パレット(instance 変数)
//
//  Return
//    function : 可否
//
-(BOOL)validateMenuItem:(NSMenuItem *)menu
{
    BOOL result;

    result = YES;

    if ([menu action] == @selector(showSubViewWindow:)) {
        [menu setState:(([[NSUserDefaults standardUserDefaults] boolForKey:SUBVIEW_OPEN_NAME]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(showPaletteWindow:)) {
        [menu setState:(([[NSUserDefaults standardUserDefaults] boolForKey:PALETTE_OPEN_NAME]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(showPenStyleWindow:)) {
        [menu setState:(([[NSUserDefaults standardUserDefaults] boolForKey:PENSTYLE_OPEN_NAME]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(showLayerWindow:)) {
        [menu setState:(([[NSUserDefaults standardUserDefaults] boolForKey:LAYER_OPEN_NAME]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(showInformationWindow:)) {
        [menu setState:(([[NSUserDefaults standardUserDefaults] boolForKey:INFORMATION_OPEN_NAME]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(showToolbarWindow:)) {
        [menu setState:(([[NSUserDefaults standardUserDefaults] boolForKey:TOOLBAR_OPEN_NAME]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(showColorPatternWindow:)) {
        [menu setState:(([[NSUserDefaults standardUserDefaults] boolForKey:COLORPATTERN_OPEN_NAME]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(changeFunction:)) {
        [menu setState:(((int)([self->editInfo_ drawModeType]) == [menu tag]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(changeDrawing:)) {
        [menu setState:(((int)([self->editInfo_ penStyleType]) == [menu tag]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(continuesLine:)) {
        [menu setState:(([self->editInfo_ continuationType]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(flipPattern:)) {
        [menu setState:(([self->editInfo_ flipType]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(useHandle:)) {
        [menu setState:(([self->editInfo_ useHandle]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(changePointMove:)) {
        [menu setState:(((int)([self->editInfo_ pointModeType]) == [menu tag]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(changePenSizeProp:)) {
        [menu setState:(((int)([self->editInfo_ sizePropType]) == [menu tag]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(changeDensityProp:)) {
        [menu setState:(((int)([self->editInfo_ densityPropType]) == [menu tag]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(normalTone:)) {
        [menu setState:(([self->editInfo_ atomizerType]) ? NSControlStateValueOff : NSControlStateValueOn)];
    } else if ([menu action] == @selector(halfTone:)) {
        [menu setState:(([self->editInfo_ atomizerType]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(changeAtomizerSkip:)) {
        [menu setState:(((int)([self->editInfo_ atomizerSkip]) == [menu tag]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(colorMixingRGB:)) {
        [menu setState:(([self->editInfo_ colorMode] == PoCoColorMode_RGB) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(colorMixingHLS:)) {
        [menu setState:(([self->editInfo_ colorMode] == PoCoColorMode_HLS) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(lockPalette:)) {
        [menu setState:(([self->editInfo_ lockPalette]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(paletteDisclose:)) {
        [menu setState:(([self->paletteWindow_ isDisclose]) ? NSControlStateValueOn : NSControlStateValueOff)];
    } else if ([menu action] == @selector(registerColorPattern:)) {
        result = (!([[self->editInfo_ selRect] empty]));
    }

    return result;
}


//
// 定常タイルパターン情報の取得
//
//  Call
//    tileSteadyPattern_ : 定常タイルパターン(instance 変数)
//
//  Return
//    function : タイルパターン情報の実体
//
-(PoCoTileSteadyPattern *)tileSteadyPattern
{
    return self->tileSteadyPattern_;
}


// ------------------------------------- instance - public - 各ウィンドウの開閉
//
// 環境設定パネルを開ける
//
//  Call
//    sender : 送信元(api 変数)
//
//  Return
//    preferencesPanel_ : 環境設定パネル(instance 変数)
//
-(IBAction)showPreferencesPanel:(id)sender
{
    // 実体は共有
    if (self->preferencesPanel_ == nil) {
        self->preferencesPanel_ = [[PoCoPreferencesPanel alloc] init];
    }

    // ウィンドウを開ける
    [[self->preferencesPanel_ window] center];
    [self->preferencesPanel_ startWindow];
    [self->preferencesPanel_ showWindow:self];

    return;
}


//
// 新規画像パネルを開ける
//
//  Call
//    sender : 送信元(api 引数)
//
//  Return
//    newDocumentPanel_ : 新規画像パネル(instance 変数)
//
-(IBAction)showNewDocumentPanel:(id)sender
{
    // 実体は共有
    if (self->newDocumentPanel_ == nil) {
        self->newDocumentPanel_ = [[PoCoNewDocumentPanel alloc] init];
    }

    // ウィンドウを開ける
    [[self->newDocumentPanel_ window] center];
    [self->newDocumentPanel_ startWindow];

    return;
}


//
// 参照ウィンドウを開ける
//
//  Call
//    sender    : 送信元(api 引数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    subViewWindow_ : 参照ウィンドウ(instance 変数)
//
-(IBAction)showSubViewWindow:(id)sender
{
    // 実体は共有
    if (self->subViewWindow_ == nil) {
        self->subViewWindow_ = [[PoCoSubViewWindow alloc] init];
    }

    // ウィンドウを開ける
    [self->subViewWindow_ showWindow:self];

    // 開けていることを記憶
    [self setOpenedState:SUBVIEW_OPEN_NAME
                    type:YES];

    // 位置固定
    [[self->subViewWindow_ window] setMovable:!([self->editInfo_ holdSubWindowPos])];

    return;
}


//
// パレットウィンドウを開ける
//
//  Call
//    sender    : 送信元(api 引数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    paletteWindow_ : パレットウィンドウ(instance 変数)
//
-(IBAction)showPaletteWindow:(id)sender
{
    // 実体は共有
    if (self->paletteWindow_ == nil) {
        self->paletteWindow_ = [[PoCoPaletteWindow alloc] init];
    }

    // ウィンドウを開ける
    [self->paletteWindow_ showWindow:self];

    // 開けていることを記憶
    [self setOpenedState:PALETTE_OPEN_NAME
                    type:YES];

    // 位置固定
    [[self->paletteWindow_ window] setMovable:!([self->editInfo_ holdSubWindowPos])];

    return;
}


//
// ペン先ウィンドウを開ける
//
//  Call
//    sender    : 送信元(api 引数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    penStyleWindow_ : ペン先ウィンドウ(instance 変数)
//
-(IBAction)showPenStyleWindow:(id)sender
{
    // 実体は共有
    if (self->penStyleWindow_ == nil) {
        self->penStyleWindow_ = [[PoCoPenStyleWindow alloc] init];
    }

    // ウィンドウを開ける
    [self->penStyleWindow_ showWindow:self];

    // 開けていることを記憶
    [self setOpenedState:PENSTYLE_OPEN_NAME
                    type:YES];

    // 位置固定
    [[self->penStyleWindow_ window] setMovable:!([self->editInfo_ holdSubWindowPos])];

    return;
}


//
// レイヤーウィンドウを開ける
//
//  Call
//    sender    : 送信元(api 引数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    layerWindow_ : レイヤーウィンドウ(instance 変数)
//
-(IBAction)showLayerWindow:(id)sender
{
    // 実体は共有
    if (self->layerWindow_ == nil) {
        self->layerWindow_ = [[PoCoLayerWindow alloc] init];
    }

    // ウィンドウを開ける
    [self->layerWindow_ showWindow:self];

    // 開けていることを記憶
    [self setOpenedState:LAYER_OPEN_NAME
                    type:YES];

    // 位置固定
    [[self->layerWindow_ window] setMovable:!([self->editInfo_ holdSubWindowPos])];

    return;
}


//
// 編集情報ウィンドウを開ける
//
//  Call
//    sender    : 送信元(api 引数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    informationWindow_ : 情報ウィンドウ(instance 変数)
//
-(IBAction)showInformationWindow:(id)sender
{
    // 実体は共有
    if (self->informationWindow_ == nil) {
        self->informationWindow_ = [[PoCoInformationWindow alloc] init];
    }

    // ウィンドウを開ける
    [self->informationWindow_ showWindow:self];

    // 開けていることを記憶
    [self setOpenedState:INFORMATION_OPEN_NAME
                    type:YES];

    // 位置固定
    [[self->informationWindow_ window] setMovable:!([self->editInfo_ holdSubWindowPos])];

    return;
}


//
// ツールバーを開ける
//
//  Call
//    sender    : 送信元(api 引数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    toolbarWindow_ : ツールバー(instance 変数)
//
-(IBAction)showToolbarWindow:(id)sender
{
    // 実体は共有
    if (self->toolbarWindow_ == nil) {
        self->toolbarWindow_ = [[PoCoToolbarWindow alloc] init];
    }

    // ウィンドウを開ける
    [self->toolbarWindow_ showWindow:self];

    // 開けていることを記憶
    [self setOpenedState:TOOLBAR_OPEN_NAME
                    type:YES];

    // 位置固定
    [[self->toolbarWindow_ window] setMovable:!([self->editInfo_ holdSubWindowPos])];

    return;
}


//
// カラーパターンウィンドウを開ける
//
//  Call
//    sender    : 送信元(api 引数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    colorPatternWindow_ : カラーパターン(instance 変数)
//
-(IBAction)showColorPatternWindow:(id)sender
{
    // 実体は共有
    if (self->colorPatternWindow_ == nil) {
        self->colorPatternWindow_ = [[PoCoColorPatternWindow alloc] init];
    }

    // ウィンドウを開ける
    [self->colorPatternWindow_ showWindow:self];

    // 開けていることを記憶
    [self setOpenedState:COLORPATTERN_OPEN_NAME
                    type:YES];

    // 位置固定
    [[self->colorPatternWindow_ window] setMovable:!([self->editInfo_ holdSubWindowPos])];

    return;
}


//
// 参照ウィンドウが閉じられた
//
//  Call
//    None
//
//  Return
//    None
//
-(void)closedSubViewWindow
{
    // 閉じたことを記憶
    if ([self noFinishProc]) {
        [self setOpenedState:SUBVIEW_OPEN_NAME
                        type:NO];
    }

    return;
}


//
// パレットウィンドウが閉じられた
//
//  Call
//    None
//
//  Return
//    None
//
-(void)closedPaletteWindow
{
    // 閉じたことを記憶
    if ([self noFinishProc]) {
        [self setOpenedState:PALETTE_OPEN_NAME
                        type:NO];
    }

    return;
}


//
// ペン先ウィンドウが閉じられた
//
//  Call
//    None
//
//  Return
//    None
//
-(void)closedPenStyleWindow
{
    // 閉じたことを記憶
    if ([self noFinishProc]) {
        [self setOpenedState:PENSTYLE_OPEN_NAME
                        type:NO];
    }

    return;
}


//
// レイヤーウィンドウが閉じられた
//
//  Call
//    None
//
//  Return
//    None
//
-(void)closedLayerWindow
{
    // 閉じたことを記憶
    if ([self noFinishProc]) {
        [self setOpenedState:LAYER_OPEN_NAME
                        type:NO];
    }

    return;
}


//
// 編集情報ウィンドウが閉じられた
//
//  Call
//    None
//
//  Return
//    None
//
-(void)closedInformationWindow
{
    // 閉じたことを記憶
    if ([self noFinishProc]) {
        [self setOpenedState:INFORMATION_OPEN_NAME
                        type:NO];
    }

    return;
}


//
// ツールバーが閉じられた
//
//  Call
//    None
//
//  Return
//    None
//
-(void)closedToolbarWindow
{
    // 閉じたことを記憶
    if ([self noFinishProc]) {
        [self setOpenedState:TOOLBAR_OPEN_NAME
                        type:NO];
    }

    return;
}


//
// カラーパターンウィンドウが閉じられた
//
//  Call
//    None
//
//  Return
//    None
//
-(void)closedColorPatternWindow
{
    // 閉じたことを記憶
    if ([self noFinishProc]) {
        [self setOpenedState:COLORPATTERN_OPEN_NAME
                        type:NO];
    }

    return;
}


//
// 補助ウィンドウの移動抑止
//
//  Call
//    type                : 設定内容
//                          YES : 抑止
//                          NO  : 解除
//    subViewWindow_      : 参照(instance 変数)
//    toolbarWindow_      : 主ツールバー(instance 変数)
//    paletteWindow_      : パレット(instance 変数)
//    colorPatternWindow_ : カラーパターン(instance 変数)
//    layerWindow_        : レイヤー(instance 変数)
//    penStyleWindow_     : ペン先形状(instance 変数)
//    informationWindow_  : 編集情報(instance 変数)
//
//  Return
//    None
//
-(void)subWindowHold:(BOOL)type
{
    type = !(type);

    // 切り替え
    [[self->subViewWindow_      window] setMovable:type];
    [[self->toolbarWindow_      window] setMovable:type];
    [[self->paletteWindow_      window] setMovable:type];
    [[self->colorPatternWindow_ window] setMovable:type];
    [[self->layerWindow_        window] setMovable:type];
    [[self->penStyleWindow_     window] setMovable:type];
    [[self->informationWindow_  window] setMovable:type];

    return;
}


// ------------------------------------- instance - public - 編集機能の切り替え
//
// 描画機能
//
//  Call
//    sender         : 送信元(api 引数)
//    toolbarWindow_ : ツールバー(instance 変数)
//
//  Return
//    None
//
-(IBAction)changeFunction:(id)sender
{
    [self->toolbarWindow_ drawMode:sender];

    return;
}


//
// ペン先(描画)
//
//  Call
//    sender         : 送信元(api 引数)
//    toolbarWindow_ : ツールバー(instance 変数)
//
//  Return
//    None
//
-(IBAction)changeDrawing:(id)sender
{
    [self->toolbarWindow_ penStyle:sender];

    return;
}


// --------------------------------- instance - public - 編集補助機能の切り替え
//
// 連続/不連続
//
//  Call
//    sender         : 送信元(api 引数)
//    toolbarWindow_ : ツールバー(instance 変数)
//
//  Return
//    None
//
-(IBAction)continuesLine:(id)sender
{
    [self->toolbarWindow_ continuation:sender];

    return;
}


//
// パターン入れ替え
//
//  Call
//    sender         : 送信元(api 引数)
//    toolbarWindow_ : ツールバー(instance 変数)
//
//  Return
//    None
//
-(IBAction)flipPattern:(id)sender
{
    [self->toolbarWindow_ flip:sender];

    return;
}


//
// ハンドル有無
//
//  Call
//    sender         : 送信元(api 引数)
//    toolbarWindow_ : ツールバー(instance 変数)
//
//  Return
//    None
//
-(IBAction)useHandle:(id)sender
{
    [self->toolbarWindow_ handle:sender];

    return;
}


//
// 形状(原点)
//
//  Call
//    sender         : 送信元(api 引数)
//    toolbarWindow_ : ツールバー(instance 変数)
//
//  Return
//    None
//
-(IBAction)changePointMove:(id)sender
{
    [self->toolbarWindow_ pointMode:sender];

    return;
}


//
// 筆圧比例(サイズ)
//
//  Call
//    sender         : 送信元(api 引数)
//    toolbarWindow_ : ツールバー(instance 変数)
//
//  Return
//    None
//
-(IBAction)changePenSizeProp:(id)sender
{
    [self->toolbarWindow_ penSize:sender];

    return;
}


//
// 筆圧比例(濃度)
//
//  Call
//    sender         : 送信元(api 引数)
//    toolbarWindow_ : ツールバー(instance 変数)
//
//  Return
//    None
//
-(IBAction)changeDensityProp:(id)sender
{
    [self->toolbarWindow_ density:sender];

    return;
}


//
// 通常霧吹き
//
//  Call
//    sender         : 送信元(api 引数)
//    toolbarWindow_ : ツールバー(instance 変数)
//
//  Return
//    None
//
-(IBAction)normalTone:(id)sender
{
    [self->toolbarWindow_ normalTone:sender];

    return;
}


//
// 半値霧吹き
//
//  Call
//    sender         : 送信元(api 引数)
//    toolbarWindow_ : ツールバー(instance 変数)
//
//  Return
//    None
//
-(IBAction)halfTone:(id)sender
{
    [self->toolbarWindow_ halfTone:sender];

    return;
}


//
// 霧吹き移動
//
//  Call
//    sender         : 送信元(api 引数)
//    toolbarWindow_ : ツールバー(instance 変数)
//
//  Return
//    None
//
-(IBAction)changeAtomizerSkip:(id)sender
{
    [self->toolbarWindow_ atomizerSkip:sender];

    return;
}


// ------------------------ instance - public - ペン先/タイルパターンの切り替え
//
// 次のペン先へ
//
//  Call
//    sender          : 送信元(api 引数)
//    penStyleWindow_ : ペン先ウィンドウ(instance 変数)
//
//  Return
//    None
//
-(IBAction)nextPenStyle:(id)sender
{
    [self->penStyleWindow_ nextPenStyle];

    return;
}


//
// 前のペン先へ
//
//  Call
//    sender          : 送信元(api 引数)
//    penStyleWindow_ : ペン先ウィンドウ(instance 変数)
//
//  Return
//    None
//
-(IBAction)prevPenStyle:(id)sender
{
    [self->penStyleWindow_ prevPenStyle];

    return;
}


//
// 次のペン太さへ
//
//  Call
//    sender          : 送信元(api 引数)
//    penStyleWindow_ : ペン先ウィンドウ(instance 変数)
//
//  Return
//    None
//
-(IBAction)nextPenSize:(id)sender
{
    [self->penStyleWindow_ nextPenSize];

    return;
}


//
// 前のペン太さへ
//
//  Call
//    sender          : 送信元(api 引数)
//    penStyleWindow_ : ペン先ウィンドウ(instance 変数)
//
//  Return
//    None
//
-(IBAction)prevPenSize:(id)sender
{
    [self->penStyleWindow_ prevPenSize];

    return;
}


//
// 次のタイルパターンへ
//
//  Call
//    sender          : 送信元(api 引数)
//    penStyleWindow_ : ペン先ウィンドウ(instance 変数)
//
//  Return
//    None
//
-(IBAction)nextTilePattern:(id)sender
{
    [self->penStyleWindow_ nextTilePattern];

    return;
}


//
// 前のタイルパターンへ
//
//  Call
//    sender          : 送信元(api 引数)
//    penStyleWindow_ : ペン先ウィンドウ(instance 変数)
//
//  Return
//    None
//
-(IBAction)prevTilePattern:(id)sender
{
    [self->penStyleWindow_ prevTilePattern];

    return;
}


//
// 濃度を変更
//
//  Call
//    sender          : 送信元(api 引数)
//    penStyleWindow_ : ペン先ウィンドウ(instance 変数)
//
//  Return
//    None
//
-(IBAction)changeDensity:(id)sender
{
    [self->penStyleWindow_ addDensity:(int)([sender tag])];

    return;
}


// ------------------------------------------- instance - public - パレット編集
//
// パレット固定
//
//  Call
//    sender         : 送信元(api 引数)
//    paletteWindow_ : パレット(instance 変数)
//
//  Return
//    None
//
-(IBAction)lockPalette:(id)sender
{
    [self->paletteWindow_ lockPalette:sender];

    return;
}


//
// ウィンドウ拡縮
//
//  Call
//    sender         : 送信元(api 引数)
//    paletteWindow_ : パレット(instance 変数)
//
//  Return
//    None
//
-(IBAction)paletteDisclose:(id)sender
{
    [self->paletteWindow_ changeDisclose:sender];

    return;
}


//
// RGB 演算
//
//  Call
//    sender         : 送信元(api 引数)
//    paletteWindow_ : パレット(instance 変数)
//
//  Return
//    None
//
-(IBAction)colorMixingRGB:(id)sender
{
    [self->paletteWindow_ changeMode:sender];

    return;
}


//
// HLS 演算
//
//  Call
//    sender         : 送信元(api 引数)
//    paletteWindow_ : パレット(instance 変数)
//
//  Return
//    None
//
-(IBAction)colorMixingHLS:(id)sender
{
    [self->paletteWindow_ changeMode:sender];

    return;
}


//
// パレット補助属性設定
//
//  Call
//    sender         : 送信元(api 引数)
//    paletteWindow_ : パレット(instance 変数)
//
//  Return
//    None
//
-(IBAction)alternateColorSetting:(id)sender
{
    [self->paletteWindow_ raiseAttributeSheet:sender];

    return;
}


//
// パレットグラデーション生成
//
//  Call
//    sender         : 送信元(api 引数)
//    paletteWindow_ : パレット(instance 変数)
//
//  Return
//    None
//
-(IBAction)createGradation:(id)sender
{
    [self->paletteWindow_ raiseGradationSheet:sender];

    return;
}


//
// 色交換
//
//  Call
//    sender         : 送信元(api 引数)
//    paletteWindow_ : パレット(instance 変数)
//
//  Return
//    None
//
-(IBAction)exchangeColor:(id)sender
{
    [self->paletteWindow_ raiseExchangeSheet:sender];

    return;
}


//
// 色複写
//
//  Call
//    sender         : 送信元(api 引数)
//    paletteWindow_ : パレット(instance 変数)
//
//  Return
//    None
//
-(IBAction)pastePalette:(id)sender
{
    [self->paletteWindow_ raisePasteSheet:sender];

    return;
}


// ------------------------------------------- instance - public - レイヤー編集
//
// 画像レイヤー追加
//
//  Call
//    sender       : 送信元(api 引数)
//    layerWindow_ : レイヤー(instance 変数)
//
//  Return
//    None
//
- (IBAction)addBitmapLayer:(id)sender
{
    [self->layerWindow_ newBitmapLayer:sender];

    return;
}


//
// 文字列レイヤー追加
//
//  Call
//    sender       : 送信元(api 引数)
//    layerWindow_ : レイヤー(instance 変数)
//
//  Return
//    None
//
- (IBAction)addStringLayer:(id)sender
{
    [self->layerWindow_ newStringLayer:sender];

    return;
}


//
// copy layer.
//
//  Call:
//    sender       : 送信元(api 引数)
//    layerWindow_ : レイヤー(instance 変数)
//
//  Return:
//    none.
//
- (IBAction)copyLayer:(id)sender
{
    [self->layerWindow_ copyLayer:sender];

    return;
}


//
// レイヤー削除
//
//  Call
//    sender       : 送信元(api 引数)
//    layerWindow_ : レイヤー(instance 変数)
//
//  Return
//    None
//
- (IBAction)deleteLayer:(id)sender
{
    [self->layerWindow_ deleteLayer:sender];

    return;
}


//
// 表示レイヤー統合
//
//  Call
//    sender       : 送信元(api 引数)
//    layerWindow_ : レイヤー(instance 変数)
//
//  Return
//    None
//
- (IBAction)unificateLayer:(id)sender
{
    [self->layerWindow_ unificateLayer:sender];

    return;
}


// ------------------------------------------------- instance - public - その他
//
// カラーパターン登録
//
//  Call
//    sender              : 送信元(api 引数)
//    colorPatternWindow_ : カラーパターン(instance 変数)
//
//  Return
//    None
//
-(IBAction)registerColorPattern:(id)sender
{
    [self->colorPatternWindow_ setPattern:sender];

    return;
}


// -------------------------------------------------- instance - public - ヘルプ
//
// PoCo のホームページへ
//
//  Call
//    sender : 送信元(api 引数)
//
//  Return
//    None
//
-(IBAction)visitPoCoHomepage:(id)sender
{
    if ([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"ja_JP"]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.poco256.org/"]];
    } else {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.poco256.org/en/"]];
    }

    return;
}


//
// PoCo のマニュアルへ
//
//  Call
//    sender : 送信元(api 引数)
//
//  Return
//    None
//
-(IBAction)visitPoCoManualPage:(id)sender
{
    if ([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"ja_JP"]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.poco256.org/man/man.html"]];
    } else {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.poco256.org/en/man/man.html"]];
    }

    return;
}

@end
