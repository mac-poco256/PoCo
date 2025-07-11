//
// PoCoView.h
// declare interface of the main view.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class
@class PoCoPicture;
@class MyDocument;
@class PoCoEditInfo;
@class PoCoControllerFactory;
@class PoCoDrawBase;

// ----------------------------------------------------------------------------
@interface PoCoView : NSView <NSMenuItemValidation>
{
    IBOutlet NSSlider *slider_;         // 倍率の slider
    IBOutlet MyDocument *document_;     // 編集対象の元締め

    int zfactNum_;                      // 表示倍率の選択番号
    int frameGap_;                      // アキ
    BOOL isDrawing_;                    // 描画中
    BOOL isAltMode_;                    // ALT 同時押し状態
    BOOL isSpaceMode_;                  // SPACE 同時押し状態
    PoCoEditInfo *editInfo_;            // 編集情報
    PoCoDrawBase *drawTool_;            // 編集機能の実体
    BOOL prevContinuation_;             // 以前の連続/不連続
    PoCoDrawModeType prevDrawMode_;     // 以前の設定
    PoCoPenStyleType prevPenStyle_;     // 以前のペン先
}

#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
// responsive scroll
+(BOOL)isCompatibleWithResponsiveScrolling;
#endif  // MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9

// initialize
-(id)initWithFrame:(NSRect)frameRect;

// deallocate
-(void)dealloc;

// レイヤーサイズの変形に伴う再描画
-(void)layerResize:(BOOL)isRedraw;

// 中心表示
-(void)centering;

// 再描画指定(実寸の座標系で指示)
-(void)setNeedsDisplayInOriginalRect:(PoCoRect *)r;

// 描画編集切り替え通知
-(void)didChangeDrawTool;

// 表示ウィンドウダブルクリック通知
-(void)doubleClickedOnSubView:(PoCoPoint *)dp;

// 描画
-(void)drawRect:(NSRect)rect;

// 座標系を反転
-(BOOL)isFlipped;

// メニューを更新
-(BOOL)validateMenuItem:(NSMenuItem *)menu;

// 画像内領域からウィンドウ内領域へ変換
-(NSRect)toDispRect:(PoCoRect *)r;

// 表示倍率に応じたハンドルの拡張幅取得
-(int)handleRectGap;

// Pointer 形状範囲指定
-(void)resetCursorRects;

// ガイドライン表示
-(void)drawGuideLine;

// 編集状態解除
-(void)cancelEdit;

// スペースキーイベント
-(void)spaceKeyEvent:(BOOL)isPress;

// undo/redo 実行受け取り(observer)
-(void)undoManagementing:(NSNotification *)note;

// PasteBoard、menu 操作
// -(IBAction)cut:(id)sender;           // 切り取り(PoCo では切り取りは無し)
-(IBAction)copy:(id)sender;
-(IBAction)paste:(id)sender;
-(NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal;
-(IBAction)delete:(id)sender;
-(IBAction)flipHorizontal:(id)sender;
-(IBAction)flipVertical:(id)sender;
-(IBAction)autoGradation:(id)sender;
-(IBAction)colorReplace:(id)sender;
-(IBAction)texture:(id)sender;
-(IBAction)selectAll:(id)sender;
-(IBAction)selectClear:(id)sender;
-(IBAction)zoomIn:(id)sender;
-(IBAction)zoomOut:(id)sender;
-(IBAction)actualSize:(id)sender;
-(IBAction)documentSetting:(id)sender;
-(IBAction)canvasResize:(id)sender;
-(IBAction)clipImage:(id)sender;

// パレット操作関連
-(IBAction)nextColor:(id)sender;
-(IBAction)prevColor:(id)sender;
-(IBAction)useUnderLayer:(id)sender;
-(IBAction)colorElementAll:(id)sender;
-(IBAction)colorElementRed:(id)sender;
-(IBAction)colorElementGreen:(id)sender;
-(IBAction)colorElementBlue:(id)sender;
-(IBAction)colorAttributeMask:(id)sender;
-(IBAction)colorAttribueDropper:(id)sender;
-(IBAction)colorAttribueTransparent:(id)sender;

// イベントの取得
-(BOOL)acceptsFirstMouse:(NSEvent *)evt;  // ボタンダウンの受け入れ可否
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)
-(void)tabletProximity:(NSEvent *)evt;    // ペン先取得
#endif  // MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3
-(void)mouseDown:(NSEvent *)evt;          // 主ボタンダウン
-(void)mouseDragged:(NSEvent *)evt;       // 主ボタンドラッグ
-(void)mouseUp:(NSEvent *)evt;            // 主ボタンリリース
-(void)rightMouseDown:(NSEvent *)evt;     // 副ボタンダウン
-(void)rightMouseDragged:(NSEvent *)evt;  // 副ボタンドラッグ
-(void)rightMouseUp:(NSEvent *)evt;       // 副ボタンリリース
-(void)keyDown:(NSEvent *)evt;            // キーダウン
-(void)keyUp:(NSEvent *)evt;              // キーリリース
-(void)mouseMoved:(NSEvent *)evt;         // マウス移動
-(void)scrollWheel:(NSEvent *)evt;        // ホイール回転
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6)
-(void)touchesBeganWithEvent:(NSEvent *)evt;      // touch 開始
-(void)touchesMovedWithEvent:(NSEvent *)evt;      // touch 移動
-(void)touchesEndedWithEvent:(NSEvent *)evt;      // touch 終了
-(void)touchesCancelledWithEvent:(NSEvent *)evt;  // touch 拒否
#endif  // MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6

// 倍率の slider の実行結果の取得
-(IBAction)zoomFactor:(id)sender;

@end
