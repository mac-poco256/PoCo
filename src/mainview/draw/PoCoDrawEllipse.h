//
//	Pelistina on Cocoa - PoCo -
//	描画編集系 - 円/楕円
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoDrawBase.h"

// ----------------------------------------------------------------------------
@interface PoCoDrawEllipseBase : PoCoDrawBase
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
@interface PoCoDrawEllipseNormal : PoCoDrawEllipseBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawEllipseUniformedDensity : PoCoDrawEllipseBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawEllipseDensity : PoCoDrawEllipseBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawEllipseAtomizer : PoCoDrawEllipseBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawEllipseGradation : PoCoDrawEllipseBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawEllipseRandom : PoCoDrawEllipseBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawEllipseWaterDrop : PoCoDrawEllipseBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawEllipseFillNormal : PoCoDrawEllipseBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawEllipseFillUniformedDensity : PoCoDrawEllipseBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawEllipseFillDensity : PoCoDrawEllipseBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawEllipseFillAtomizer : PoCoDrawEllipseBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawEllipseFillGradation : PoCoDrawEllipseBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawEllipseFillRandom : PoCoDrawEllipseBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawEllipseFillWaterDrop : PoCoDrawEllipseBase
{
}

// 描画実行
-(void)exec;

@end
