//
//	Pelistina on Cocoa - PoCo -
//	描画編集系 - 塗りつぶし
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoDrawBase.h"

// ----------------------------------------------------------------------------
@interface PoCoDrawPaint : PoCoDrawBase
{
}

// initialize
-(id)initWithDoc:(MyDocument *)doc;

// deallocate
-(void)dealloc;

// イベント処理系
-(void)mouseDown:(NSEvent *)evt;        // 主ボタンダウン
-(void)mouseDrag:(NSEvent *)evt;        // 主ボタンドラッグ
-(void)mouseUp:(NSEvent *)evt;          // 主ボタンリリース
-(void)rightMouseDown:(NSEvent *)evt;   // 副ボタンダウン
-(void)mouseMove:(NSEvent *)evt;        // マウス移動

@end
