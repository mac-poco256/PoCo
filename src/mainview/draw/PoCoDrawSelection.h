//
// PoCoDrawSelection.h
// declare interface of the drawing feature with selection shape.
// (the drawing features are to link between UI and the edit controllers.
//  this class focuses on selection shape.)
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoDrawBase.h"
#import "PoCoLayer.h"
#import "PoCoSelectionShape.h"

// ----------------------------------------------------------------------------
@interface PoCoDrawSelection : PoCoDrawBase
{
    BOOL isCopy_;                       // 複写指定
    BOOL isDrag_;                       // ドラッグ中か
    BOOL isPaint_;                      // 塗り選択中か
    PoCoSelectionShape *shape_;         // 範囲形状
    PoCoBitmap *prevImage_;             // 以前の画像(全体)
    PoCoPoint *prevPos_;                // 以前の点
    PoCoRect *prevRect_;                // 以前の範囲(外接長方形)
    PoCoHandleType prevHandle_;         // 以前のハンドル
    unsigned int modify_;               // 修飾キー
}

// initialise.
-(id)initWithDoc:(MyDocument *)doc;

// deallocate.
-(void)dealloc;

// features with selection shape.
-(void)pasteBitmap:(PoCoLayerBase *)lyr;// ペーストボードから貼り付け
-(void)delete;                          // 削除
- (void)flipImage:(BOOL)hori;           // flip image.
- (void)autoGrad:(int)size              // auto gradient.
      isAdjacent:(BOOL)adj
          matrix:(const BOOL *)mtx
    withSizePair:(NSDictionary *)sizePair;
- (void)colorReplace:(const unsigned char *)mtx; // replace color.
- (void)texture:(NSArray *)base         // texture.
   withGradient:(NSArray *)grad;
-(void)selectAll;                       // 全選択
-(void)selectClear;                     // 選択解除
-(void)recreatePasteImage;              // 移動画像を再生成

// assistance functions.
-(void)updateCursorRect;                // Pointer 形状範囲更新
-(void)drawGuideLine;                   // ガイドライン描画
-(void)cancelEdit;                      // 編集状態解除
-(PoCoBitmap *)originalImage;           // 変形前画像
-(PoCoBitmap *)originalShape;           // 変形前形状
-(BOOL)canAutoScroll;                   // autoscroll 実行可否

// event handlers.
-(void)mouseDown:(NSEvent *)evt;        // 主ボタンダウン
-(void)mouseDrag:(NSEvent *)evt;        // 主ボタンドラッグ
-(void)mouseUp:(NSEvent *)evt;          // 主ボタンリリース
-(void)rightMouseDown:(NSEvent *)evt;   // 副ボタンダウン
-(void)rightMouseUp:(NSEvent *)evt;     // 副ボタンリリース
-(void)keyDown:(NSEvent *)evt;          // キーダウン
-(void)keyUp:(NSEvent *)evt;            // キーリリース
-(void)mouseMove:(NSEvent *)evt;        // マウス移動

@end
