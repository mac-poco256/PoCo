//
//	Pelistina on Cocoa - PoCo -
//	線/枠線系描画部基底
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoControllerEditterBase.h"

// ----------------------------------------------------------------------------
// 自由曲線、筆圧比例自由曲線、直線
@interface PoCoControllerLineEditterBase : PoCoControllerEditterBase
{
    PoCoPoint *startPos_;               // 描画始点(中心点)
    PoCoPoint *endPos_;                 // 描画終点(中心点)
    BOOL prop_;                         // 筆圧比例
    BOOL cont_;                         // 常に連続線分
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
       isProp:(BOOL)prop
      atIndex:(int)idx;

// deallocate
-(void)dealloc;

// ペン太さを選別
-(int)selectPenSize;

// 濃度を選別
-(int)selectDensity;

// 描画予定領域の算出
-(PoCoRect *)calcArea:(int)corr;

// 編集開始
-(BOOL)startEdit:(int)dc
    withUndoCorr:(int)uc;

// 連続線分
-(void)setCont;

// 直線の描画
-(void)drawFrame:(id)edit;

// 編集終了
-(void)endEdit:(NSString *)name;

@end


// ----------------------------------------------------------------------------
// 矩形枠
@interface PoCoControllerBoxFrameEditterBase : PoCoControllerBoxEditterBase
{
    BOOL cont_;                         // 常に連続線分
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

// 連続線分
-(void)setCont;

// 矩形枠の描画
-(void)drawFrame:(id)edit;

@end


// ----------------------------------------------------------------------------
// 円/楕円
@interface PoCoControllerEllipseFrameEditterBase : PoCoControllerEllipseEditterBase
{
    BOOL cont_;                         // 常に連続線分
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

// 連続線分
-(void)setCont;

// 円/楕円枠の描画
-(void)drawFrame:(id)edit;

@end


// ----------------------------------------------------------------------------
// 平行四辺形
@interface PoCoControllerParallelogramFrameEditterBase : PoCoControllerParallelogramEditterBase
{
    BOOL cont_;                         // 常に連続線分
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

// 連続線分
-(void)setCont;

// 平行四辺形枠の描画
-(void)drawFrame:(id)edit;

@end


// ----------------------------------------------------------------------------
// 直線群(曲線)
@interface PoCoControllerCurveWithPointsEditterBase : PoCoControllerCurveEditterBase
{
    BOOL cont_;                         // 常に連続線分
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

// 連続線分
-(void)setCont;

// 直線群(曲線)の描画 
-(void)drawFrame:(id)edit;

@end
