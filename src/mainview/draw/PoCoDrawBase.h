//
//	Pelistina on Cocoa - PoCo -
//	描画編集系 - 基底
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class
@class MyDocument;
@class PoCoEditInfo;
@class PoCoEditState;
@class PoCoControllerFactory;
@class PoCoLayerBase;
@class PoCoBitmap;

// ----------------------------------------------------------------------------
@interface PoCoDrawBase : NSObject
{
    MyDocument *document_;               // 編集対象
    PoCoEditInfo *editInfo_;             // 編集情報
    PoCoEditState *editState_;           // 編集の状態遷移
    PoCoControllerFactory *factory_;     // 編集の生成部
}

// initialize
-(id)initWithDoc:(MyDocument *)doc;

// deallocate
-(void)dealloc;

// 範囲選択系
-(void)pasteBitmap:(PoCoLayerBase *)lyr;// ペーストボードから貼り付け
-(void)delete;                          // 削除
-(void)flipImage:(BOOL)hori;            // 画像反転
-(void)autoGrad:(int)size               // 自動グラデーション
     isAdjacent:(BOOL)adj
         matrix:(const BOOL *)mtx
   withSizePair:(NSDictionary *)sizePair;
-(void)colorReplace:(const unsigned char *)mtx; // 色置換
-(void)texture:(NSArray *)base          // テクスチャ
  withGradient:(NSArray *)grad;
-(void)selectAll;                       // 全選択
-(void)selectClear;                     // 選択解除
-(void)recreatePasteImage;              // 移動画像を再生成

// 補助
-(BOOL)isNotEditLayer;                  // 編集禁止レイヤー判定
-(void)dropper;                         // 色吸い取り
-(void)dragMove:(NSEvent *)evt;         // ずりずり
-(void)beginUndo:(BOOL)group;           // 取り消し開始
-(void)endUndo:(BOOL)group;             // 取り消し終了
-(void)updateCursorRect;                // Pointer 形状範囲更新
-(void)drawGuideLine;                   // ガイドライン描画
-(void)cancelEdit;                      // 編集状態解除
-(PoCoBitmap *)originalImage;           // 変形前画像
-(PoCoBitmap *)originalShape;           // 変形前形状
-(BOOL)canAutoScroll;                   // autoscroll 実行可否

// イベント操作
-(void)mouseDown:(NSEvent *)evt;        // 主ボタンダウン
-(void)mouseDrag:(NSEvent *)evt;        // 主ボタンドラッグ
-(void)mouseUp:(NSEvent *)evt;          // 主ボタンリリース
-(void)rightMouseDown:(NSEvent *)evt;   // 副ボタンダウン
-(void)rightMouseDrag:(NSEvent *)evt;   // 副ボタンドラッグ
-(void)rightMouseUp:(NSEvent *)evt;     // 副ボタンリリース
-(void)keyDown:(NSEvent *)evt;          // キーダウン
-(void)keyUp:(NSEvent *)evt;            // キーリリース
-(void)mouseMove:(NSEvent *)evt;        // マウス移動

@end
