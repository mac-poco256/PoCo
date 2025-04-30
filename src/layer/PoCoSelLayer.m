//
//	Pelistina on Cocoa - PoCo -
//	選択中レイヤー情報
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoSelLayer.h"

// ============================================================================
@implementation PoCoSelLayer

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function : 実体
//    sel_     : 選択番号(編集対象)(instance 変数)
//
-(id)init
{
    DPRINT((@"[PoCoSelLayer init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->sel_ = 0;
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
    DPRINT((@"[PoCoSelLayer dealloc]\n"));

    // super class の解放
    [super dealloc];

    return;
}


//
// 選択番号(直接の編集対象)の取得
//
//  Call
//    sel_ : 選択番号(編集対象)(instance 変数)
//
//  Return
//    function : 値
//
-(int)sel
{
    return self->sel_;
}


//
// 選択番号(直接の編集対象)の設定
//
//  Call
//    s : 選択番号
//
//  Return
//    sel_ : 選択番号(編集対象)(instance 変数)
//
-(void)setSel:(int)s
{
    self->sel_ = s;

    return;
}

@end
