//
//	Pelistina on Cocoa - PoCo -
//	編集情報ウィンドウ管理部
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class の宣言
@class PoCoEditInfo;

// ----------------------------------------------------------------------------
@interface PoCoInformationWindow : NSWindowController
{
    PoCoEditInfo *info_;                // 編集情報

    // 対象画像サイズ関連
    IBOutlet NSTextField *sizeWidth_;   // 幅
    IBOutlet NSTextField *sizeHeight_;  // 高さ
    IBOutlet NSTextField *viewLeft_;    // 実表示左辺
    IBOutlet NSTextField *viewTop_;     // 実表示上底
    IBOutlet NSTextField *viewRight_;   // 実表示右辺
    IBOutlet NSTextField *viewBottom_;  // 実表示下底

    // 実軸指示座標関連
    IBOutlet NSTextField *posX_;        // PD 水平位置
    IBOutlet NSTextField *posY_;        // PD 垂直位置
    IBOutlet NSTextField *posLeft_;     // 枠左辺
    IBOutlet NSTextField *posTop_;      // 枠上底
    IBOutlet NSTextField *posRight_;    // 枠右辺
    IBOutlet NSTextField *posBottom_;   // 枠下底
    IBOutlet NSTextField *posWidth_;    // 枠幅
    IBOutlet NSTextField *posHeight_;   // 枠高さ

    // 実軸選択範囲関連
    IBOutlet NSTextField *selLeft_;     // 左辺
    IBOutlet NSTextField *selTop_;      // 上底
    IBOutlet NSTextField *selRight_;    // 右辺
    IBOutlet NSTextField *selBottom_;   // 下底
    IBOutlet NSTextField *selWidth_;    // 幅
    IBOutlet NSTextField *selHeight_;   // 高さ
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// 座標情報の更新(通知)
-(void)editInfoChangePos:(NSNotification *)note;

// ウィンドウが読み込まれた
-(void)windowDidLoad;

// ウィンドウが閉じられる
-(void)windowWillClose:(NSNotification *)note;

// 取り消し情報の引き渡し
-(NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender;

// 各内容の表示
-(void)displayPictureSize;              // 画像サイズの表示
-(void)displayDisplayRect;              // 表示範囲の表示
-(void)displayPDPos;                    // PD 位置の表示
-(void)displayPDRect;                   // 編集範囲の表示
-(void)displaySelectionRect;            // 選択範囲の表示

// イベントの取得
-(void)keyDown:(NSEvent *)evt;          // キーダウン処理
-(void)keyUp:(NSEvent *)evt;            // キーリリース処理

@end
