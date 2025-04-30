//
//	Pelistina on Cocoa - PoCo -
//	ペン先ウィンドウ管理部
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class の宣言
@class PoCoMonochromePattern;
@class PoCoMonochromePatternEditView;
@class PoCoMonochromePatternView;

// ----------------------------------------------------------------------------
@interface PoCoPenStyleWindow : NSWindowController
{
    IBOutlet id penSizeSlider_;         // ペン先太さ指定
    IBOutlet id densitySlider_;         // 濃度指定

    // 形状編集シート関連
    IBOutlet NSWindow *patternSheet_;
    IBOutlet PoCoMonochromePatternEditView *patternEditView_;

    // パターン表示
    IBOutlet PoCoMonochromePatternView *penStyleView_;
    IBOutlet PoCoMonochromePatternView *tilePatternView_;
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// ウィンドウが読み込まれた
-(void)windowDidLoad;

// ウィンドウが閉じられる
-(void)windowWillClose:(NSNotification *)note;

// 取り消し情報の引き渡し
-(NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender;

// ペン先太さ指定
-(IBAction)penSizeSet:(id)sender;

// 濃度指定
-(IBAction)densitySet:(id)sender;

// イベントの取得
-(void)keyDown:(NSEvent *)evt;          // キーダウン処理
-(void)keyUp:(NSEvent *)evt;            // キーリリース処理

// パターン設定シート関連
-(void)raisePatternSheet:(id)sender
                 pattern:(PoCoMonochromePattern *)pat;
-(IBAction)endPatternSheet:(id)sender;
-(void)patternSheetDidEnd:(NSWindow *)sheet
               returnCode:(int)returnCode
              contextInfo:(void *)contextInfo;

// パターン/スライダーの切り替え
-(void)nextPenStyle;
-(void)prevPenStyle;
-(void)nextPenSize;
-(void)prevPenSize;
-(void)nextTilePattern;
-(void)prevTilePattern;
-(void)addDensity:(int)val;

@end
