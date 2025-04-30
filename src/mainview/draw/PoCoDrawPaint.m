//
//	Pelistina on Cocoa - PoCo -
//	描画編集系 - 塗りつぶし
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoDrawPaint.h"

#import "PoCoMyDocument.h"
#import "PoCoSelLayer.h"
#import "PoCoEditInfo.h"
#import "PoCoEditState.h"
#import "PoCoControllerFactory.h"

// ============================================================================
@implementation PoCoDrawPaint

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
    DPRINT((@"[PoCoDrawPaint initWithDoc]\n"));

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
    DPRINT((@"[PoCoDrawPaint dealloc]\n"));

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
//    evt        : 取得イベント
//    document_  : 編集対象(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//
//  Return
//    editState_ : 編集の状態遷移(基底 instance 変数)
//
-(void)mouseDown:(NSEvent *)evt
{
    // 編集禁止レイヤー
    if ([super isNotEditLayer]) {
        goto EXIT;
    }

    // 状態遷移開始
    [self->editState_ beginEditMode];

    // 座標を設定
    [self->editState_ setFirstPoint:nil];

    // 取り消し開始
    [super beginUndo:YES];

    // 実行
    [self->factory_ createNormalPaintEditter:YES
                                       layer:[[self->document_ selLayer] sel]
                                         pos:[self->editState_ firstPoint]];

EXIT:
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
    // 何もしない
    ;

    return;
}


//
// 主ボタンリリース
//
//  Call
//    evt        : 取得イベント
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//
//  Return
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//
-(void)mouseUp:(NSEvent *)evt
{
    // 編集禁止レイヤー
    if ([super isNotEditLayer]) {
        goto EXIT;
    }

    // 取り消し終了
    [super endUndo:YES];

    // 最終 PD 位置更新
    [self->editInfo_ setLastPos:[self->editState_ firstPoint]];

    // 状態遷移終了
    [self->editState_ endEditMode];

EXIT:
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
