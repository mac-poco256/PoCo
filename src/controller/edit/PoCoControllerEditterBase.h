//
//	Pelistina on Cocoa - PoCo -
//	描画部基底
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

#import "PoCoLayer.h"
#import "PoCoPenStyle.h"
#import "PoCoTilePattern.h"
#import "PoCoColorPattern.h"
#import "PoCoColorBuffer.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerEditterBase : PoCoControllerBase
{
    PoCoPenStyle *penStyle_;            // ペン先
    PoCoTilePattern *tilePattern_;      // タイルパターン
    PoCoColorPattern *eraserPattern_;   // 消しゴム用画像
    PoCoColorBuffer *colorBuffer_;      // 色保持情報
    int index_;                         // 対象レイヤー番号
    PoCoLayerBase *layer_;              // 対象レイヤー
    PoCoRect *drawRect_;                // 再描画領域
    PoCoRect *undoRect_;                // 取り消し領域
    PoCoBitmap *undoBitmap_;            // 取り消し画像
    PoCoColorPattern* drawPattern_;     // 描画パターン
    PoCoMonochromePattern *drawPen_;    // 使用ペン先
    PoCoMonochromePattern *drawTile_;   // 使用タイルパターン
}

// initialize
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
      withPen:(PoCoPenStyle *)pen
     withTile:(PoCoTilePattern *)tile
      atIndex:(int)idx;

// deallocate
-(void)dealloc;

// 範囲の補正(画像範囲内に抑制)
-(void)correctRect:(PoCoRect *)r;

// 編集開始
-(BOOL)startEdit:(PoCoRect *)dr
    withUndoRect:(PoCoRect *)ur;

// 編集終了
-(void)endEdit:(NSString *)name;

// 編集通知
-(void)postNotify:(PoCoRect *)r;
-(void)postNotifyNoEdit:(PoCoRect *)r;

@end


// ----------------------------------------------------------------------------
// 矩形枠、塗りつぶし矩形
@interface PoCoControllerBoxEditterBase : PoCoControllerEditterBase
{
    PoCoPoint *startPos_;               // 描画始点(中心点)
    PoCoPoint *endPos_;                 // 描画終点(中心点)
    PoCoPoint *ortPos_;                 // 方向点
    BOOL diagonal_;                     // 回転で対角を使用
}

// initialize
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
      withPen:(PoCoPenStyle *)pen
     withTile:(PoCoTilePattern *)tile
    withStart:(PoCoPoint *)s
      withEnd:(PoCoPoint *)e
  ifAnyOrient:(PoCoPoint *)o
      atIndex:(int)idx;

// deallocate
-(void)dealloc;

// 描画予定領域の算出
-(PoCoRect *)calcArea:(int)corr;

// 編集開始
-(BOOL)startEdit:(int)dc
    withUndoCorr:(int)uc;

// 編集終了
-(void)endEdit:(NSString *)name;

@end


// ----------------------------------------------------------------------------
// 円/楕円、塗りつぶし円/楕円
@interface PoCoControllerEllipseEditterBase : PoCoControllerEditterBase
{
    PoCoPoint *startPos_;               // 描画始点(中心点)
    PoCoPoint *endPos_;                 // 描画終点(中心点)
    PoCoPoint *ortPos_;                 // 方向点
}

// initialize
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
      withPen:(PoCoPenStyle *)pen
     withTile:(PoCoTilePattern *)tile
    withStart:(PoCoPoint *)s
      withEnd:(PoCoPoint *)e
  ifAnyOrient:(PoCoPoint *)o
      atIndex:(int)idx;

// deallocate
-(void)dealloc;

// 描画予定領域の算出
-(PoCoRect *)calcArea:(int)corr;

// 編集開始
-(BOOL)startEdit:(int)dc
    withUndoCorr:(int)uc;

// 編集終了
-(void)endEdit:(NSString *)name;

@end


// ----------------------------------------------------------------------------
// 平行四辺形、塗りつぶし平行四辺形
@interface PoCoControllerParallelogramEditterBase : PoCoControllerEditterBase
{
    PoCoPoint *firstPos_;               // 1点(中心点)
    PoCoPoint *secondPos_;              // 2点(中心点)
    PoCoPoint *thirdPos_;               // 3点(中心点)
    PoCoPoint *fourthPos_;              // 4点(中心点)
}

// initialize
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
      withPen:(PoCoPenStyle *)pen
     withTile:(PoCoTilePattern *)tile
    withFirst:(PoCoPoint *)f
   withSecond:(PoCoPoint *)s
    withThird:(PoCoPoint *)t
      atIndex:(int)idx;

// deallocate
-(void)dealloc;

// 描画予定領域の算出
-(PoCoRect *)calcArea:(int)corr;

// 編集開始
-(BOOL)startEdit:(int)dc
    withUndoCorr:(int)uc;

// 編集終了
-(void)endEdit:(NSString *)name;

@end


// ----------------------------------------------------------------------------
// 直線群(曲線)
@interface PoCoControllerCurveEditterBase : PoCoControllerEditterBase
{
    NSMutableArray *points_;            // 支点群
    PoCoCurveWithPointsType type_;      // 補間方法
    unsigned int freq_;                 // 補間頻度
}

// initialize
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
      withPen:(PoCoPenStyle *)pen
     withTile:(PoCoTilePattern *)tile
   withPoints:(NSMutableArray *)points
     withType:(PoCoCurveWithPointsType)type
     withFreq:(unsigned int)freq
      atIndex:(int)idx;

// deallocate
-(void)dealloc;

// 描画予定領域の算出
-(PoCoRect *)calcArea:(int)corr;

// 編集開始
-(BOOL)startEdit:(int)dc
    withUndoCorr:(int)uc;

// 編集終了
-(void)endEdit:(NSString *)name;

@end
