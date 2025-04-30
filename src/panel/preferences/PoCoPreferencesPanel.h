//
//	Pelistina on Cocoa - PoCo -
//	環境設定パネル
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// ----------------------------------------------------------------------------
@interface PoCoPreferencesPanel : NSWindowController
{
    IBOutlet NSButton *enableUndo_;         // 取り消し有効
    IBOutlet NSTextField *undoMax_;         // 取り消し最大数
    IBOutlet NSButton *enableLiveResize_;   // LiveResize 可否
    IBOutlet NSButton *enableEraser_;       // 消しゴム有効可否
    IBOutlet NSButton *enableColorBuffer_;  // 色保持情報可否
    IBOutlet NSButton *showSelectionFill_;  // 選択領域塗りつぶし表示
    IBOutlet NSButton *liveEditSelection_;  // 選択範囲の編集を随時表示
    IBOutlet NSButton *saveDocWindowPos_;   // 主ウィンドウの位置を記憶
    IBOutlet NSButton *holdSubWindowPos_;   // 補助ウィンドウの位置を固定
    IBOutlet NSMatrix *showScrollerView_;   // view で scroller を表示
    IBOutlet NSTextField *pixelGrid_;       // ピクセルグリッドの間隔
    IBOutlet NSButton *showTransGrid_;      // 透明グリッドを表示
    IBOutlet NSTextField *backColorR_;      // 背景色（R）
    IBOutlet NSTextField *backColorG_;      // 背景色（G）
    IBOutlet NSTextField *backColorB_;      // 背景色（B）
    IBOutlet NSTextField *previewQuality_;  // プレビューの品質
    IBOutlet NSTextField *previewSize_;     // プレビューの大きさ
    IBOutlet NSButton *grayToAlpha_;        // Grayscale を不透明度にする
    IBOutlet NSMatrix *interGuide_;         // 補間曲線のガイドライン表示
    IBOutlet NSMatrix *interType_;          // 補間曲線の種類
    IBOutlet NSTextField *interFreq_;       // 補間曲線の補間頻度
    IBOutlet NSTextField *colorRange_;      // 色範囲
    IBOutlet NSButton *syncWithSubView_;    // 表示ウィンドウとの同期
    IBOutlet NSButton *syncWithPalette_;    // 選択色との同期
}

// initiailze
-(id)init;

// deallocate
-(void)dealloc;

// ウィンドウが読み込まれた
-(void)windowDidLoad;

// ウィンドウが閉じられる
-(void)windowWillClose:(NSNotification *)note;

// 開始
-(void)startWindow;

// IBAction 系
-(IBAction)enableUndo:(id)sender;
-(IBAction)undoMax:(id)sender;
-(IBAction)enableLiveResize:(id)sender;
-(IBAction)enableEraser:(id)sender;
-(IBAction)enableColorBuffer:(id)sender;
-(IBAction)showSelectionFill:(id)sender;
-(IBAction)liveEditSelection:(id)sender;
-(IBAction)saveDocWindowPos:(id)sender;
-(IBAction)holdSubWindowPos:(id)sender;
-(IBAction)showScrollerView:(id)sender;
-(IBAction)pixelGrid:(id)sender;
-(IBAction)showTransGrid:(id)sender;
-(IBAction)backColor:(id)sender;
-(IBAction)previewQuality:(id)sender;
-(IBAction)previewSize:(id)sender;
-(IBAction)grayToAlpha:(id)sender;
-(IBAction)interGuide:(id)sender;
-(IBAction)interType:(id)sender;
-(IBAction)intreFreq:(id)sender;
-(IBAction)colorRange:(id)sender;
-(IBAction)syncWithSubView:(id)sender;
-(IBAction)syncWithPalette:(id)sender;

@end
