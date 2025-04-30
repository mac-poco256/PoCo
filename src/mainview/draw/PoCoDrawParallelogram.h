//
//	Pelistina on Cocoa - PoCo -
//	描画編集系 - 平行四辺形
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoDrawBase.h"

// ----------------------------------------------------------------------------
@interface PoCoDrawParallelogramBase : PoCoDrawBase
{
}

// initialize
-(id)initWithDoc:(MyDocument *)doc;

// deallocate
-(void)dealloc;

// 描画実行
-(void)exec;

// 補助
-(void)drawGuideLine;                   // ガイドライン描画
-(void)cancelEdit;                      // 編集状態解除
-(BOOL)canAutoScroll;                   // autoscroll 実行可否

// イベント処理系
-(void)mouseDown:(NSEvent *)evt;        // 主ボタンダウン
-(void)mouseDrag:(NSEvent *)evt;        // 主ボタンドラッグ
-(void)mouseUp:(NSEvent *)evt;          // 主ボタンリリース
-(void)rightMouseDown:(NSEvent *)evt;   // 副ボタンダウン
-(void)keyDown:(NSEvent *)evt;          // キーダウン
-(void)keyUp:(NSEvent *)evt;            // キーリリース
-(void)mouseMove:(NSEvent *)evt;        // マウス移動

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawParallelogramNormal : PoCoDrawParallelogramBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawParallelogramUniformedDensity : PoCoDrawParallelogramBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawParallelogramDensity : PoCoDrawParallelogramBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawParallelogramAtomizer : PoCoDrawParallelogramBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawParallelogramGradation : PoCoDrawParallelogramBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawParallelogramRandom : PoCoDrawParallelogramBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawParallelogramWaterDrop : PoCoDrawParallelogramBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawParallelogramFillNormal : PoCoDrawParallelogramBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawParallelogramFillUniformedDensity : PoCoDrawParallelogramBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawParallelogramFillDensity : PoCoDrawParallelogramBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawParallelogramFillAtomizer : PoCoDrawParallelogramBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawParallelogramFillGradation : PoCoDrawParallelogramBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawParallelogramFillRandom : PoCoDrawParallelogramBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawParallelogramFillWaterDrop : PoCoDrawParallelogramBase
{
}

// 描画実行
-(void)exec;

@end
