//
//	Pelistina on Cocoa - PoCo -
//	ペン先表示・選択部
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import "PoCoPenStyleView.h"

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"
#import "PoCoPenStyle.h"
#import "PoCoPenStyleWindow.h"

// ============================================================================
@implementation PoCoPenStyleView

// --------------------------------------------------------- instance - private
//
// 選択肢切り替え
//
//  Call
//    num : 選択番号(切り替え先)
//
//  Return
//    None
//
-(void)setSelection:(unsigned int)num
{
    const unsigned int sel = [[(PoCoAppController *)([NSApp delegate]) editInfo] penNumber];

    if (num != sel) {
        [[(PoCoAppController *)([NSApp delegate]) editInfo] setPenNumber:num];
        [self setNeedsDisplayInRect:[super numToRect:num]];
        [self setNeedsDisplayInRect:[super numToRect:sel]];
    }

    return;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    frame : 矩形領域
//
//  Return
//    function : 実体
//
-(id)initWithFrame:(NSRect)frame
{
    DPRINT((@"[PoCoPenStyleView initWithFrame]\n"));

    // super class の初期化
    self = [super initWithFrame:frame
                     setPattern:[(PoCoAppController *)([NSApp delegate]) penStyle]];

    // 自身の初期化
    if (self != nil) {
        ;
    }

    return self;
}


//
// deallocate
//
//  Call
//    None
//
//  Return
//    None
//
-(void)dealloc
{
    // super class の解放
    [super dealloc];

    return;
}


//
// パターンを更新
//
//  Call
//    pat : 設定パターン
//
//  Return
//    None
//
-(void)updatePattern:(PoCoMonochromePattern *)pat
{
    const unsigned int sel = [[(PoCoAppController *)([NSApp delegate]) editInfo] penNumber];

    [[(PoCoAppController *)([NSApp delegate]) penStyle] setPattern:pat atIndex:sel];
    [self setNeedsDisplayInRect:[super numToRect:sel]];

    return;
}


//
// 表示要求
//
//  Call
//    rect : 表示領域(api 引数)
//
//  Return
//    None
//
-(void)drawRect:(NSRect)rect
{
    unsigned int l;
    const unsigned int sel = [[(PoCoAppController *)([NSApp delegate]) editInfo] penNumber];

    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
    for (l = 0; l < PEN_STYLE_NUM; (l)++) {
        if (NSIntersectsRect(rect, [super numToRect:l])) {
            [super drawPattern:l isSelect:(l == sel)];
        }
    }

    return;
}


// ----------------------------------------- instance - public - イベント処理系
//
// ボタンダウンイベントの受け入れ可否
//
//  Call
//    evt : 発生イベント(api 変数)
// 
//  Return
//    function : 可否
//
-(BOOL)acceptsFirstMouse:(NSEvent *)evt
{
    // 種別判定は無視
    ;

    return YES;
}


//
// ボタンダウン処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    None
//
-(void)mouseDown:(NSEvent *)evt
{
    const NSPoint p = [self convertPoint:[evt locationInWindow]
                                fromView:nil];
    PoCoPenStyleWindow *wnd;

    // 切り替え
    if ([self mouse:p inRect:[self bounds]]) {
        [self setSelection:[super pointToNum:p]];
    }

    // double click 以上の場合は編集に入る
    if ([evt clickCount] >= 2) {
        wnd = (PoCoPenStyleWindow *)([[self window] delegate]);
        [wnd raisePatternSheet:self
                       pattern:[[(PoCoAppController *)([NSApp delegate]) penStyle] pattern:[[(PoCoAppController *)([NSApp delegate]) editInfo] penNumber]]];
    }

    return;
}


//
// 次の選択肢へ
//
//  Call
//    None
//
//  Return
//    None
//
-(void)nextSelection
{
    unsigned int num = [[(PoCoAppController *)([NSApp delegate]) editInfo] penNumber];

    if (num >= 15) {
        num = 0;
    } else {
        (num)++;
    }
    [self setSelection:num];

    return;
}


//
// 前の選択肢へ
//
//  Call
//    None
//
//  Return
//    None
//
-(void)prevSelection
{
    unsigned int num = [[(PoCoAppController *)([NSApp delegate]) editInfo] penNumber];

    if (num <= 0) {
        num = 15;
    } else {
        (num)--;
    }
    [self setSelection:num];

    return;
}

@end
