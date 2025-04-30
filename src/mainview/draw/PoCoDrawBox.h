//
//	Pelistina on Cocoa - PoCo -
//	描画編集系 - 矩形枠
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoDrawBase.h"

// ----------------------------------------------------------------------------
@interface PoCoDrawBoxBase : PoCoDrawBase
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
@interface PoCoDrawBoxNormal : PoCoDrawBoxBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawBoxUniformedDensity : PoCoDrawBoxBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawBoxDensity : PoCoDrawBoxBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawBoxAtomizer : PoCoDrawBoxBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawBoxGradation : PoCoDrawBoxBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawBoxRandom : PoCoDrawBoxBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawBoxWaterDrop : PoCoDrawBoxBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawBoxFillNormal : PoCoDrawBoxBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawBoxFillUniformedDensity : PoCoDrawBoxBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawBoxFillDensity : PoCoDrawBoxBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawBoxFillAtomizer : PoCoDrawBoxBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawBoxFillGradation : PoCoDrawBoxBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawBoxFillRandom : PoCoDrawBoxBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawBoxFillWaterDrop : PoCoDrawBoxBase
{
}

// 描画実行
-(void)exec;

@end
