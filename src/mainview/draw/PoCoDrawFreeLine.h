//
//	Pelistina on Cocoa - PoCo -
//	描画編集系 - 自由曲線
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoDrawBase.h"

// ----------------------------------------------------------------------------
@interface PoCoDrawFreeLineBase : PoCoDrawBase
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
@interface PoCoDrawFreeLineNormal : PoCoDrawFreeLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawFreeLineUniformedDensity : PoCoDrawFreeLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawFreeLineDensity : PoCoDrawFreeLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawFreeLineAtomizer : PoCoDrawFreeLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawFreeLineGradation : PoCoDrawFreeLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawFreeLineRandom : PoCoDrawFreeLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawFreeLineWaterDrop : PoCoDrawFreeLineBase
{
}

// 描画実行
-(void)exec;

@end
