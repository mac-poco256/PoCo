//
//	Pelistina on Cocoa - PoCo -
//	パレットウィンドウ管理部
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// ----------------------------------------------------------------------------
@interface PoCoPaletteWindow : NSWindowController
{
    IBOutlet id disclose_;              // ウィンドウ拡縮
    IBOutlet id mode_;                  // 色演算モード
    IBOutlet id attribute_;             // 補助属性
    IBOutlet id gradation_;             // パレットグラデーション
    IBOutlet id exchange_;              // パレット入れ替え
    IBOutlet id paste_;                 // パレット複写
    IBOutlet id paletteView_;           // パレット一覧
    IBOutlet id paletteInfoView_;       // パレット詳細
    IBOutlet NSScrollView *scroller_;   // scroller

    NSDocumentController *docCntl_;

    // 補助属性設定シート関連
    IBOutlet NSWindow *attributeSheet_;
    IBOutlet id attributeMaskView_;
    IBOutlet id attributeDropperView_;
    IBOutlet id attributeTransparentView_;
    IBOutlet id rangeOfMask_;
    IBOutlet id rangeOfDropper_;
    IBOutlet id rangeOfTransparent_;

    // グラデーション作成シート関連
    IBOutlet NSWindow *gradationSheet_;
    IBOutlet id gradationView_;

    // パレット入れ替え関連
    IBOutlet NSWindow *exchangeSheet_;
    IBOutlet id exchangeView_;

    // パレット複写関連
    IBOutlet NSWindow *pasteSheet_;
    IBOutlet id pasteView_;
}

// 初期設定
+(void)initialize;

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// ウィンドウを読み込んだ
-(void)windowDidLoad;

// ウィンドウが閉じられる
-(void)windowWillClose:(NSNotification *)note;

// 取り消し情報の引き渡し
-(NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender;

// パレット固定
-(void)lockPalette:(id)sender;

// ウィンドウ拡縮
-(BOOL)isDisclose;

// パネル内のパーツの処理関数
-(IBAction)changeDisclose:(id)sender;   // ウィンドウ拡縮
-(IBAction)changeMode:(id)sender;       // 色演算モード切り替え

// イベントの取得
-(void)keyDown:(NSEvent *)evt;          // キーダウン処理
-(void)keyUp:(NSEvent *)evt;            // キーリリース処理

// 補助属性設定シート関連
-(IBAction)raiseAttributeSheet:(id)sender;
-(IBAction)endAttributeSheet:(id)sender;
-(void)attributeSheetDidEnd:(NSWindow *)sheet
                 returnCode:(int)returnCode
                contextInfo:(void *)contextInfo;
-(IBAction)rangeOfMask:(id)sender;
-(IBAction)rangeOfDropper:(id)sender;
-(IBAction)rangeOfTransparent:(id)sender;
-(void)invokeUpdateAllRange;

// グラデーション作成シート関連
-(IBAction)raiseGradationSheet:(id)sender;
-(IBAction)endGradationSheet:(id)sender;
-(void)gradationSheetDidEnd:(NSWindow *)sheet
                 returnCode:(int)returnCode
                contextInfo:(void *)contextInfo;

// パレット入れ替えシート関連
-(IBAction)raiseExchangeSheet:(id)sender;
-(IBAction)endExchangeSheet:(id)sender;
-(void)exchangeSheetDidEnd:(NSWindow *)sheet
                returnCode:(int)returnCode
               contextInfo:(void *)contextInfo;

// パレット複写シート関連
-(IBAction)raisePasteSheet:(id)sender;
-(IBAction)endPasteSheet:(id)sender;
-(void)pasteSheetDidEnd:(NSWindow *)sheet
             returnCode:(int)returnCode
            contextInfo:(void *)contextInfo;

@end
