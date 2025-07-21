//
// PoCoDrawFreeLine.m
// implementation of proportional free line classes.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoDrawFreeLine.h"

#import "PoCoMyDocument.h"
#import "PoCoSelLayer.h"
#import "PoCoEditInfo.h"
#import "PoCoEditState.h"
#import "PoCoControllerFactory.h"

// ============================================================================
@implementation PoCoDrawFreeLineBase

// ----------------------------------------------------------------------------
// instance - public.

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
    DPRINT((@"[PoCoDrawFreeLineBase initWithDoc]\n"));

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
    DPRINT((@"[PoCoDrawFreeLineBase dealloc]\n"));

    // 資源の解放
    ;

    // super class の解放
    [super dealloc];

    return;
}


//
// 描画実行
//
//  Call
//    None
//
//  Return
//    None
//
-(void)exec
{
    // 基底では何もしない
    ;

    return;
}


// ----------------------------------------------------------------------------
// instance - public - supplementaries.

//
// autoscroll 実行可否
//
//  Call
//    None
//
//  Return
//    function : YES : 禁止
//               NO  : 許可
//
-(BOOL)canAutoScroll
{
    return YES;
}


// ----------------------------------------------------------------------------
// instance - public - event handlers.

//
// 主ボタンダウン
//
//  Call
//    evt        : 取得イベント
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//
//  Return
//    editState_  : 編集の状態遷移(基底 instance 変数)
//    prevEraser_ : 以前の消しゴム指定(instance 変数)
//
-(void)mouseDown:(NSEvent *)evt
{
    // 編集禁止レイヤー
    if ([super isNotEditLayer]) {
        ;
    } else {
        // shift+ctrl 押し下時は一時的に消しゴム状態とする
        self->prevEraser_ = [self->editInfo_ eraserType];
        if ((([evt modifierFlags] & NSEventModifierFlagShift) != 0x00) &&
            (([evt modifierFlags] & NSEventModifierFlagControl) != 0x00)) {
            [self->editInfo_ setEraserType:YES];
        }

        // 状態遷移開始
        [self->editState_ beginEditMode];

        // 座標を設定
        [self->editState_ setFirstPoint:nil];
        [self->editState_ setSecondPoint:[self->editState_ firstPoint]];

        // 取り消し開始
        [super beginUndo:YES];

        // 実行
        [self exec];
    }

    return;
}


//
// 主ボタンドラッグ
//
//  Call
//    evt        : 取得イベント
//    editState_ : 編集の状態遷移(基底 instance 変数)
//
//  Return
//    editState_ : 編集の状態遷移(基底 instance 変数)
//
-(void)mouseDrag:(NSEvent *)evt
{
    // 編集禁止レイヤー
    if ([super isNotEditLayer]) {
        ;
    } else {
        // 座標を設定
        [self->editState_ setFirstPoint:[self->editState_ secondPoint]];
        [self->editState_ setSecondPoint:nil];

        // 実行
        [self exec];
    }

    return;
}


//
// 主ボタンリリース
//
//  Call
//    evt         : 取得イベント
//    editInfo_   : 編集情報(基底 instance 変数)
//    prevEraser_ : 以前の消しゴム指定(instance 変数)
//
//  Return
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//
-(void)mouseUp:(NSEvent *)evt
{
    // 編集禁止レイヤー
    if ([super isNotEditLayer]) {
        ;
    } else {
        // 取り消し終了
        [super endUndo:YES];

        // 最終 PD 位置更新
        [self->editInfo_ setLastPos:[self->editState_ secondPoint]];

        // 状態遷移終了
        [self->editState_ endEditMode];

        // 消しゴム状態を元に戻す
        [self->editInfo_ setEraserType:self->prevEraser_];
    }

    return;
}


//
// 副ボタンダウン
//
//  Call
//    evt        : 取得イベント
//    editState_ : 編集の状態遷移(基底 instance 変数)
//
//  Return
//    None
//
-(void)rightMouseDown:(NSEvent *)evt
{
    if ([self->editState_ isEdit]) {
        // 編集中は無視
        ;
    } else {
        // 吸い取りのみ
        [super dropper];
    }

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




// ============================================================================
@implementation PoCoDrawFreeLineNormal

// ----------------------------------------------------------------------------
// instance - public.

//
// 描画実行
//
//  Call
//    document_  : 編集対象(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//
//  Return
//    None
//
-(void)exec
{
    NSString *name;

    // 名称取得
    name = [[NSBundle mainBundle]
               localizedStringForKey:@"DrawFreeLine"
                               value:@"free line"
                               table:nil];

    // 描画
    [self->factory_ createNormalFreeLineEditter:YES
                                          layer:[[self->document_ selLayer] sel]
                                          start:[self->editState_ firstPoint]
                                            end:[self->editState_ secondPoint]
                                       undoName:name];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawFreeLineUniformedDensity

// ----------------------------------------------------------------------------
// instance - public.

//
// 描画実行
//
//  Call
//    document_  : 編集対象(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//
//  Return
//    None
//
-(void)exec
{
    NSString *name;

    // 名称取得
    name = [[NSBundle mainBundle]
               localizedStringForKey:@"DrawFreeLine"
                               value:@"free line"
                               table:nil];

    // 描画
    [self->factory_ createUniformedDensityFreeLineEditter:YES
                                                    layer:[[self->document_ selLayer] sel]
                                                    start:[self->editState_ firstPoint]
                                                      end:[self->editState_ secondPoint]
                                                 undoName:name];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawFreeLineDensity

// ----------------------------------------------------------------------------
// instance - public.

//
// 描画実行
//
//  Call
//    document_  : 編集対象(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//
//  Return
//    None
//
-(void)exec
{
    NSString *name;

    // 名称取得
    name = [[NSBundle mainBundle]
               localizedStringForKey:@"DrawFreeLine"
                               value:@"free line"
                               table:nil];

    // 描画
    [self->factory_ createDensityFreeLineEditter:YES
                                            layer:[[self->document_ selLayer] sel]
                                            start:[self->editState_ firstPoint]
                                              end:[self->editState_ secondPoint]
                                         undoName:name];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawFreeLineAtomizer

// ----------------------------------------------------------------------------
// instance - public.

//
// 描画実行
//
//  Call
//    document_  : 編集対象(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//
//  Return
//    None
//
-(void)exec
{
    NSString *name;

    // 名称取得
    name = [[NSBundle mainBundle]
               localizedStringForKey:@"DrawFreeLine"
                               value:@"free line"
                               table:nil];

    // 描画
    [self->factory_ createAtomizerFreeLineEditter:YES
                                            layer:[[self->document_ selLayer] sel]
                                            start:[self->editState_ firstPoint]
                                              end:[self->editState_ secondPoint]
                                         undoName:name];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawFreeLineGradation

// ----------------------------------------------------------------------------
// instance - public.

//
// 描画実行
//
//  Call
//    document_  : 編集対象(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//
//  Return
//    None
//
-(void)exec
{
    NSString *name;

    // 名称取得
    name = [[NSBundle mainBundle]
               localizedStringForKey:@"DrawFreeLine"
                               value:@"free line"
                               table:nil];

    // 描画
    [self->factory_ createGradationFreeLineEditter:YES
                                             layer:[[self->document_ selLayer] sel]
                                             start:[self->editState_ firstPoint]
                                               end:[self->editState_ secondPoint]
                                          undoName:name];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawFreeLineRandom

// ----------------------------------------------------------------------------
// instance - public.

//
// 描画実行
//
//  Call
//    document_  : 編集対象(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//
//  Return
//    None
//
-(void)exec
{
    NSString *name;

    // 名称取得
    name = [[NSBundle mainBundle]
               localizedStringForKey:@"DrawFreeLine"
                               value:@"free line"
                               table:nil];

    // 描画
    [self->factory_ createRandomFreeLineEditter:YES
                                          layer:[[self->document_ selLayer] sel]
                                          start:[self->editState_ firstPoint]
                                            end:[self->editState_ secondPoint]
                                       undoName:name];

    return;
}

@end





// ============================================================================
@implementation PoCoDrawFreeLineWaterDrop

// ----------------------------------------------------------------------------
// instance - public.

//
// 描画実行
//
//  Call
//    document_  : 編集対象(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//
//  Return
//    None
//
-(void)exec
{
    NSString *name;

    // 名称取得
    name = [[NSBundle mainBundle]
               localizedStringForKey:@"DrawFreeLine"
                               value:@"free line"
                               table:nil];

    // 描画
    [self->factory_ createWaterDropFreeLineEditter:YES
                                             layer:[[self->document_ selLayer] sel]
                                             start:[self->editState_ firstPoint]
                                               end:[self->editState_ secondPoint]
                                          undoName:name];

    return;
}

@end

