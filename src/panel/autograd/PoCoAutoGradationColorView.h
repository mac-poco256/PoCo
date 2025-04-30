//
//	Pelistina on Cocoa - PoCo -
//	自動グラデーション対象色設定領域
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// ----------------------------------------------------------------------------
@interface PoCoAutoGradationColorView : NSView
{
    BOOL isOn_[COLOR_MAX];              // 設定内容
    BOOL setValue_;                     // 設定値
    NSDocumentController *docCntl_;
}

// initialize
-(id)initWithFrame:(NSRect)frameRect;

// deallocate
-(void)dealloc;

// 表示要求
-(void)drawRect:(NSRect)rect;

// 座標系を反転
-(BOOL)isFlipped;

// 取得
-(const BOOL *)matrix;
-(BOOL)attribute:(int)index;

// 設定
-(void)setAttribute:(BOOL)on
            atIndex:(int)index;

// 1色分の描画
-(void)drawColor:(int)num
        isSelect:(BOOL)sel;

// 連続性を検証
-(BOOL)verifyContinuous;

// 選択の有無を検証
-(BOOL)verifySelectExist;

// ボタンダウン処理
-(void)mouseDown:(NSEvent *)evt;

// ドラッグ処理
-(void)mouseDragged:(NSEvent *)evt;

@end
