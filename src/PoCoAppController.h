//
// PoCoAppController.h
// declare interface of application controller.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import <Foundation/Foundation.h>

// 参照 class の宣言
@class PoCoPreferencesPanel;
@class PoCoNewDocumentPanel;

@class PoCoSubViewWindow;
@class PoCoToolbarWindow;
@class PoCoPaletteWindow;
@class PoCoColorPatternWindow;
@class PoCoLayerWindow;
@class PoCoPenStyleWindow;
@class PoCoInformationWindow;

@class PoCoControllerFactory;
@class PoCoGlobalObserver;
@class PoCoEditInfo;
@class PoCoPenStyle;
@class PoCoPenSteadyStyle;
@class PoCoTilePattern;
@class PoCoTileSteadyPattern;

// ----------------------------------------------------------------------------
@interface PoCoAppController : NSObject {
    BOOL willFinish_;                   // 終了処理中か

    // 各補助・設定パネルの管理用 instance 変数
    PoCoPreferencesPanel *preferencesPanel_;  // 環境設定
    PoCoNewDocumentPanel *newDocumentPanel_;  // 新規画像

    // 各ウィンドウの管理用 instance 変数
    PoCoSubViewWindow *subViewWindow_;            // 参照
    PoCoToolbarWindow *toolbarWindow_;            // 主ツールバー
    PoCoPaletteWindow *paletteWindow_;            // パレット
    PoCoColorPatternWindow *colorPatternWindow_;  // カラーパターン
    PoCoLayerWindow *layerWindow_;                // レイヤー
    PoCoPenStyleWindow *penStyleWindow_;          // ペン先形状
    PoCoInformationWindow *informationWindow_;    // 編集情報

    // 編集部の生成部
    PoCoControllerFactory *factory_;

    // 広域通知受信部
    PoCoGlobalObserver *observer_;

    // 編集情報(application 共通)
    PoCoEditInfo *editInfo_;

    // ペン先情報(application 共通)
    PoCoPenStyle *penStyle_;
    PoCoPenSteadyStyle *penSteadyStyle_;

    // タイルパターン情報(application 共通)
    PoCoTilePattern *tilePattern_;
    PoCoTileSteadyPattern *tileSteadyPattern_;
}

// 初期設定
+(void)initialize;

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// untitled window の抑止
-(BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender;

// nib が読み込まれた
-(void)awakeFromNib;

// アプリケーションが終了する
-(void)applicationWillTerminate:(NSNotification *)note;

// メニューを更新
-(BOOL)validateMenuItem:(NSMenuItem *)menu;

// 主ツールバーを取得
-(PoCoToolbarWindow *)toolbarWindow;

// 新規タブ
-(IBAction)newWindowForTab:(id)sender;

// アプリケーションの共通情報の取得
-(BOOL)noFinishProc;                          // 終了処理中ではないか
-(PoCoControllerFactory *)factory;            // 編集部の生成部の取得
-(PoCoEditInfo *)editInfo;                    // 共通編集情報の取得
-(PoCoPenStyle *)penStyle;                    // ペン先の取得
-(PoCoPenSteadyStyle *)penSteadyStyle;        // 定常ペン先の取得
-(PoCoTilePattern *)tilePattern;              // タイルパターンの取得
-(PoCoTileSteadyPattern *)tileSteadyPattern;  // 定常タイルパターンの取得

// 各ウィンドウの開閉用
-(IBAction)showPreferencesPanel:(id)sender;
-(IBAction)showNewDocumentPanel:(id)sender;
-(IBAction)showSubViewWindow:(id)sender;
-(IBAction)showPaletteWindow:(id)sender;
-(IBAction)showPenStyleWindow:(id)sender;
-(IBAction)showLayerWindow:(id)sender;
-(IBAction)showInformationWindow:(id)sender;
-(IBAction)showToolbarWindow:(id)sender;
-(IBAction)showColorPatternWindow:(id)sender;
-(void)closedSubViewWindow;
-(void)closedPaletteWindow;
-(void)closedPenStyleWindow;
-(void)closedLayerWindow;
-(void)closedInformationWindow;
-(void)closedToolbarWindow;
-(void)closedColorPatternWindow;
-(void)subWindowHold:(BOOL)type;

// 編集機能の切り替え
-(IBAction)changeFunction:(id)sender;
-(IBAction)changeDrawing:(id)sender;

// 編集補助機能の切り替え
-(IBAction)continuesLine:(id)sender;
-(IBAction)flipPattern:(id)sender;
-(IBAction)useHandle:(id)sender;
-(IBAction)changePointMove:(id)sender;
-(IBAction)changePenSizeProp:(id)sender;
-(IBAction)changeDensityProp:(id)sender;
-(IBAction)normalTone:(id)sender;
-(IBAction)halfTone:(id)sender;
-(IBAction)changeAtomizerSkip:(id)sender;

// ペン先/タイルパターンの切り替え
-(IBAction)nextPenStyle:(id)sender;
-(IBAction)prevPenStyle:(id)sender;
-(IBAction)nextPenSize:(id)sender;
-(IBAction)prevPenSize:(id)sender;
-(IBAction)nextTilePattern:(id)sender;
-(IBAction)prevTilePattern:(id)sender;
-(IBAction)changeDensity:(id)sender;

// パレット編集
-(IBAction)lockPalette:(id)sender;
-(IBAction)paletteDisclose:(id)sender;
-(IBAction)colorMixingRGB:(id)sender;
-(IBAction)colorMixingHLS:(id)sender;
-(IBAction)alternateColorSetting:(id)sender;
-(IBAction)createGradation:(id)sender;
-(IBAction)exchangeColor:(id)sender;
-(IBAction)pastePalette:(id)sender;

// レイヤー編集
-(IBAction)addBitmapLayer:(id)sender;
-(IBAction)addStringLayer:(id)sender;
-(IBAction)deleteLayer:(id)sender;
-(IBAction)unificateLayer:(id)sender;

// カラーパターン登録
-(IBAction)registerColorPattern:(id)sender;

// ヘルプ
-(IBAction)visitPoCoHomepage:(id)sender;
-(IBAction)visitPoCoManualPage:(id)sender;

@end
