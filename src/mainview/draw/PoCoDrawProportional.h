//
//	Pelistina on Cocoa - PoCo -
//	描画編集系 - 筆圧比例自由曲線
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoDrawBase.h"

// ----------------------------------------------------------------------------
@interface PoCoDrawProportionalFreeLineBase : PoCoDrawBase
{
    BOOL prevEraser_;                   // 以前の消しゴム指定
}

// initialize
-(id)initWithDoc:(MyDocument *)doc;

// deallocate
-(void)dealloc;

// 描画実行
-(void)exec;

// 補助
-(BOOL)canAutoScroll;                   // autoscroll 実行可否

// イベント処理系
-(void)mouseDown:(NSEvent *)evt;        // 主ボタンダウン
-(void)mouseDrag:(NSEvent *)evt;        // 主ボタンドラッグ
-(void)mouseUp:(NSEvent *)evt;          // 主ボタンリリース
-(void)rightMouseDown:(NSEvent *)evt;   // 副ボタンダウン
-(void)mouseMove:(NSEvent *)evt;        // マウス移動

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawProportionalFreeLineNormal : PoCoDrawProportionalFreeLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawProportionalFreeLineUniformedDensity : PoCoDrawProportionalFreeLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawProportionalFreeLineDensity : PoCoDrawProportionalFreeLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawProportionalFreeLineAtomizer : PoCoDrawProportionalFreeLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawProportionalFreeLineGradation : PoCoDrawProportionalFreeLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawProportionalFreeLineRandom : PoCoDrawProportionalFreeLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawProportionalFreeLineWaterDrop : PoCoDrawProportionalFreeLineBase
{
}

// 描画実行
-(void)exec;

@end
