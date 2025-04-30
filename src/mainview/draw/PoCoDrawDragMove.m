//
//	Pelistina on Cocoa - PoCo -
//	描画編集系 - ずりずり
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoDrawDragMove.h"

#import "PoCoEditInfo.h"

// ============================================================================
@implementation PoCoDrawDragMove

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    doc : 編集対象
//
//  Return
//    function : 実体
//
-(id)initWithDoc:(MyDocument *)doc
{
    DPRINT((@"[PoCoDrawDragMove initWithDoc]\n"));

    // super class の初期化
    self = [super initWithDoc:doc];

    // 自身の初期化
    if (self != nil) {
        // 何もしない
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
    DPRINT((@"[PoCoDrawDragMove dealloc]\n"));

    // 資源の解放
    ;

    // super class の解放
    [super dealloc];

    return;
}


//
// 主ボタンダウン
//
//  Call
//    evt : 取得イベント
//
//  Return
//    None
//
-(void)mouseDown:(NSEvent *)evt
{
    // 何もしない
    ;

    return;
}


//
// 主ボタンドラッグ
//
//  Call
//    evt : 取得イベント
//
//  Return
//    None
//
-(void)mouseDrag:(NSEvent *)evt
{
    // ずりずり
    [super dragMove:evt];

    return;
}


//
// 主ボタンリリース
//
//  Call
//    evt       : 取得イベント
//    editInfo_ : 編集情報(基底 instance 変数)
//
//  Return
//    editInfo_ : 編集情報(基底 instance 変数)
//
-(void)mouseUp:(NSEvent *)evt
{
    // 最終 PD 位置更新
    [self->editInfo_ setLastPos:[self->editInfo_ pdPos]];

    return;
}


//
// 副ボタンダウン
//
//  Call
//    evt : 取得イベント
//
//  Return
//    None
//
-(void)rightMouseDown:(NSEvent *)evt
{
    // 吸い取りのみ
    [super dropper];

    return;
}


//
// マウス移動
//
//  Call
//    evt : 取得イベント
//
//  Return
//    None
//
-(void)mouseMove:(NSEvent *)evt
{
    // 何もしない
    ;

    return;
}

@end
