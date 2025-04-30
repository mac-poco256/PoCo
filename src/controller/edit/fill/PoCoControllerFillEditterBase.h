//
//	Pelistina on Cocoa - PoCo -
//	塗りつぶし系描画部基底
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoControllerEditterBase.h"

#import "PoCoCreateStyleMask.h"

// ----------------------------------------------------------------------------
// 塗りつぶし矩形
@interface PoCoControllerBoxFillEditterBase : PoCoControllerBoxEditterBase
{
    PoCoRect *trueRect_;                // 描画範囲(画像範囲外含む)
    PoCoCreateStyleMask *mask_;         // 形状マスク
    float xskip_;                       // 水平変量
    float yskip_;                       // 垂直変量
    float x_[2];                        // 水平座標
    float y_[2];                        // 垂直座標
    PoCoRect *orgRect_;                 // 編集前画像範囲(画像全体)
    PoCoBitmap *orgBitmap_;             // 編集前画像
}

// initialize
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
     withTile:(PoCoTilePattern *)tile
    withStart:(PoCoPoint *)s
      withEnd:(PoCoPoint *)e
  ifAnyOrient:(PoCoPoint *)o
      atIndex:(int)idx;

// deallocate
-(void)dealloc;

// 編集開始
-(BOOL)startEdit:(BOOL)org
     withPenSize:(int)penSize
    withDrawCorr:(int)dc
    withUndoCorr:(int)uc;

// 編集終了
-(void)endEdit:(NSString *)name;

// 座標移動
-(void)next;

// 塗りつぶし矩形の描画
-(void)drawFill:(id)edit
       withTile:(PoCoMonochromePattern *)tile;

// 編集前画像を複製
-(PoCoBitmap *)getWorkBitmap;

// 画像を複写
-(void)pasteFromWork:(PoCoBitmap *)work;

@end


// ----------------------------------------------------------------------------
// 塗りつぶし円/楕円
@interface PoCoControllerEllipseFillEditterBase : PoCoControllerEllipseEditterBase
{
    PoCoRect *trueRect_;                // 描画範囲(画像範囲外含む)
    PoCoCreateStyleMask *mask_;         // 形状マスク
    float xskip_;                       // 水平変量
    float yskip_;                       // 垂直変量
    float x_;                           // 水平座標
    float y_;                           // 垂直座標
    PoCoRect *orgRect_;                 // 編集前画像範囲(画像全体)
    PoCoBitmap *orgBitmap_;             // 編集前画像
}

// initialize
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
     withTile:(PoCoTilePattern *)tile
    withStart:(PoCoPoint *)s
      withEnd:(PoCoPoint *)e
  ifAnyOrient:(PoCoPoint *)o
      atIndex:(int)idx;

// deallocate
-(void)dealloc;

// 編集開始
-(BOOL)startEdit:(BOOL)org
     withPenSize:(int)penSize
    withDrawCorr:(int)dc
    withUndoCorr:(int)uc;

// 編集終了
-(void)endEdit:(NSString *)name;

// 座標移動
-(void)next;

// 塗りつぶし円/楕円の描画
-(void)drawFill:(id)edit
       withTile:(PoCoMonochromePattern *)tile;

// 編集前画像を複製
-(PoCoBitmap *)getWorkBitmap;

// 画像を複写
-(void)pasteFromWork:(PoCoBitmap *)work;

@end


// ----------------------------------------------------------------------------
// 塗りつぶし平行四辺形
@interface PoCoControllerParallelogramFillEditterBase : PoCoControllerParallelogramEditterBase
{
    PoCoRect *trueRect_;                // 描画範囲(画像範囲外含む)
    PoCoCreateStyleMask *mask_;         // 形状マスク
    float xskip_;                       // 水平変量
    float yskip_;                       // 垂直変量
    float x_[4];                        // 水平座標
    float y_[4];                        // 垂直座標
    PoCoRect *orgRect_;                 // 編集前画像範囲(画像全体)
    PoCoBitmap *orgBitmap_;             // 編集前画像
}

// initialize
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
     withTile:(PoCoTilePattern *)tile
    withFirst:(PoCoPoint *)f
   withSecond:(PoCoPoint *)s
    withThird:(PoCoPoint *)t
      atIndex:(int)idx;

// deallocate
-(void)dealloc;

// 編集開始
-(BOOL)startEdit:(BOOL)org
     withPenSize:(int)penSize
    withDrawCorr:(int)dc
    withUndoCorr:(int)uc;

// 編集終了
-(void)endEdit:(NSString *)name;

// 座標移動
-(void)next;

// 塗りつぶし平行四辺形の描画
-(void)drawFill:(id)edit
       withTile:(PoCoMonochromePattern *)tile;

// 編集前画像を複製
-(PoCoBitmap *)getWorkBitmap;

// 画像を複写
-(void)pasteFromWork:(PoCoBitmap *)work;

@end
