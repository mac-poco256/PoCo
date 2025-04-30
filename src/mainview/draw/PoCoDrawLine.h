//
//	Pelistina on Cocoa - PoCo -
//	描画編集系 - 直線
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoDrawBase.h"

// ----------------------------------------------------------------------------
@interface PoCoDrawLineBase : PoCoDrawBase
{
    NSMutableArray *points_;            // 点群
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
@interface PoCoDrawLineNormal : PoCoDrawLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawLineUniformedDensity : PoCoDrawLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawLineDensity : PoCoDrawLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawLineAtomizer : PoCoDrawLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawLineGradation : PoCoDrawLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawLineRandom : PoCoDrawLineBase
{
}

// 描画実行
-(void)exec;

@end


// ----------------------------------------------------------------------------
@interface PoCoDrawLineWaterDrop : PoCoDrawLineBase
{
}

// 描画実行
-(void)exec;

@end
