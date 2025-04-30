//
//	Pelistina on Cocoa - PoCo -
//	レイヤーウィンドウ管理部
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class の宣言
@class PoCoLayerTableView;

// ----------------------------------------------------------------------------
@interface PoCoLayerWindow : NSWindowController
{
    NSDocumentController *docCntl_;
    IBOutlet id layerTableView_;
    IBOutlet NSScrollView *scroller_;
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

// メニュー関連
-(void)newBitmapLayer:(id)sender;       // 画像レイヤー生成
-(void)newStringLayer:(id)sender;       // 文字列レイヤー生成
-(void)deleteLayer:(id)sender;          // レイヤー削除
-(void)unificateLayer:(id)sender;       // 表示レイヤー統合

// イベントの取得
-(void)keyDown:(NSEvent *)evt;          // キーダウン処理
-(void)keyUp:(NSEvent *)evt;            // キーリリース処理

@end
