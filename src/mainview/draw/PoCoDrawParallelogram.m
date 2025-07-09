//
//	Pelistina on Cocoa - PoCo -
//	描画編集系 - 平行四辺形
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoDrawParallelogram.h"

#import <Carbon/Carbon.h>

#import "PoCoMyDocument.h"
#import "PoCoSelLayer.h"
#import "PoCoEditInfo.h"
#import "PoCoEditState.h"
#import "PoCoControllerFactory.h"

// ============================================================================
@implementation PoCoDrawParallelogramBase

// --------------------------------------------------------- instance - private
//  
// 矩形枠の通達
//
//  Call
//    editState_ : 編集の状態遷移(基底 instance 変数)
//
//  Return
//    editInfo_ : 編集情報(基底 instance 変数)
//
-(void)setInfoPDRect
{
    PoCoRect *r;

    r = nil;
    if ([self->editState_ hasThirdPoint]) {
        // 2-3点
        r = [[PoCoRect alloc] initLeft:[[self->editState_ firstPoint] x]
                               initTop:[[self->editState_ firstPoint] y]
                             initRight:[[self->editState_ thirdPoint] x]
                            initBottom:[[self->editState_ thirdPoint] y]];
        [self->editInfo_ setPDRect:r];
    } else {
        // 1-2点
        r = [[PoCoRect alloc] initLeft:[[self->editState_  firstPoint] x]
                               initTop:[[self->editState_  firstPoint] y]
                             initRight:[[self->editState_ secondPoint] x]
                            initBottom:[[self->editState_ secondPoint] y]];
        [self->editInfo_ setPDRect:r];
    }
    [r release];

    return;
}


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
    DPRINT((@"[PoCoDrawParallelogramBase initWithDoc]\n"));

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
    DPRINT((@"[PoCoDrawParallelogramBase dealloc]\n"));

    // ガイドライン消去
    if ([self->editState_ hasFirstPoint]) {
        [self drawGuideLine];
    }

    // 取り消し終了
    [super endUndo:NO];

    // 編集終了
    [self->editState_ endEditMode];

    // 矩形枠の通達
    [self setInfoPDRect];     

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


// --------------------------------------------------- instance - public - 補助
//
// ガイドライン描画
//
//  Call
//    document_  : 編集対象(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//
//  Return
//    None
//
-(void)drawGuideLine
{
    if ([self->editState_ hasThirdPoint]) {
        // 2-3点
        [self->factory_ createInvertParallelogramEditter:YES
                                                   layer:[[self->document_ selLayer] sel]
                                                   first:[self->editState_ firstPoint]
                                                  second:[self->editState_ secondPoint]
                                                   third:[self->editState_ thirdPoint]];
    } else if ([self->editState_ hasSecondPoint]) {
        // 1-2点
        [self->factory_ createInvertLineEditter:YES
                                          layer:[[self->document_ selLayer] sel]
                                          start:[self->editState_ firstPoint]
                                            end:[self->editState_ secondPoint]];
    }

    return;
}


//
// 編集状態解除
//
//  Call
//    editState_ : 編集の状態遷移(基底 instance 変数)
//
//  Return
//    None
//
-(void)cancelEdit
{
    if (!([self->editState_ isFirstPoint])) {
        // ガイドライン消去
        [self drawGuideLine];

        // 取り消し終了
        [super endUndo:NO];

        // 編集終了
        [self->editState_ endEditMode];

        // 矩形枠の通達
        [self setInfoPDRect];     
    }

    return;
}


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


// ----------------------------------------- instance - public - イベント処理系
//
// 主ボタンダウン
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
-(void)mouseDown:(NSEvent *)evt
{
    if ([super isNotEditLayer]) {
        // 編集禁止レイヤー
        ;
    } else if ((([evt modifierFlags] & NSEventModifierFlagCommand) != 0x00) &&
               (([evt modifierFlags] & NSEventModifierFlagControl) != 0x00)) {
        // Command + Control はスポイトとする
        [self drawGuideLine];           // ガイドライン消去
        [super dropper];
        [self drawGuideLine];           // ガイドライン表示
    } else if ([self->editState_ isFirstPoint]) {
        // 状態遷移開始
        [self->editState_ beginEditMode];

        // 座標を設定
        [self->editState_ setFirstPoint:nil];

        // 取り消し開始
        [super beginUndo:NO];
    } else if (!([self->editState_ hasThirdPoint])) {
        // ガイドライン消去
        [self drawGuideLine];

        // 3点目取得に入る
        [self->editState_ setSecondPoint:nil];
        [self->editState_ setThirdPoint:nil];

        // ガイドライン描画
        [self drawGuideLine];
    } else {
        // ガイドライン消去
        [self drawGuideLine];

        // 終点決定
        if (!([self->editState_ isIdenticalShape])) {
            [self->editState_ setThirdPoint:nil];
        }

        // 描画実行
        [self->editState_ countUpEdit];
        [self exec];

        // 形状変更
        if ([self->editState_ isPointHold]) {
            [self->editState_ clearSecondPoint];
            [self->editState_ clearThirdPoint];
            [self->editState_ setSecondPoint:nil];
        } else if ([self->editState_ isPointMove]) {
            [self->editState_ clearFirstPoint];
            [self->editState_ clearSecondPoint];
            [self->editState_ clearThirdPoint];
            [self->editState_ setFirstPoint:nil];
        }

        // ガイドライン描画
        [self drawGuideLine];

        // 最終 PD 位置更新
        [self->editInfo_ setLastPos:[self->editInfo_ pdPos]];
    }

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
    // 通常のマウス移動と同じ扱いにする
    [self mouseMove:evt];

    return;
}


//
// 主ボタンリリース
//
//  Call
//    None
//
//  Return
//    None
//
-(void)mouseUp:(NSEvent *)evt
{
    // 何もしない
    ;

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
    if ([self->editState_ isFirstPoint]) {
        // 色吸い取り
        [super dropper];
    } else {
        // 編集状態解除
        [self cancelEdit];
    }

    return;
}


//
// キーダウン
//
//  Call
//    evt : 取得イベント
//
//  Return
//    None
//
-(void)keyDown:(NSEvent *)evt
{
    // なにもしない
    ;

    return;
}


//
// キーリリース
//
//  Call
//    evt : 取得イベント
//
//  Return
//    None
//
-(void)keyUp:(NSEvent *)evt
{
    // Escape キーの場合は常に編集解除
    if ([evt keyCode] == kVK_Escape) {
        // 編集状態解除
        [self cancelEdit];
    }

    return;
}


//
// マウス移動
//
//  Call
//    evt        : 取得イベント
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//
//  Return
//    editState_ : 編集の状態遷移(基底 instance 変数)
//
-(void)mouseMove:(NSEvent *)evt
{
    if ([self->editState_ isFirstPoint]) {
        // 始点がない
        ;
    } else {
        // 以前のガイドラインを消去描画
        if (([self->editState_ hasSecondPoint]) ||
            ([self->editState_ hasThirdPoint])) {
            [self drawGuideLine];
        }

        if ([self->editState_ isIdenticalShape]) {
            // 形状固定状態
            [self->editState_
                moveX:([[self->editInfo_ pdPos] x] - [[self->editState_ thirdPoint] x])
                moveY:([[self->editInfo_ pdPos] y] - [[self->editState_ thirdPoint] y])];
        } else {
            // 起点固定
            if ([self->editState_ hasThirdPoint]) {
                [self->editState_ setThirdPoint:nil];
            } else {
                [self->editState_ setSecondPoint:nil];
            }
        }

        // ガイドライン描画
        [self drawGuideLine];

        // 矩形枠の通達
        [self setInfoPDRect];     
    }

    return;
}

@end




// ============================================================================
@implementation PoCoDrawParallelogramNormal

// ---------------------------------------------------------- instance - public
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
    // 描画
    [self->factory_ createNormalParallelogramEditter:YES
                                               layer:[[self->document_ selLayer] sel]
                                               first:[self->editState_ firstPoint]
                                              second:[self->editState_ secondPoint]
                                               third:[self->editState_ thirdPoint]];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawParallelogramUniformedDensity

// ---------------------------------------------------------- instance - public
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
    // 描画
    [self->factory_ createUniformedDensityParallelogramEditter:YES
                                                         layer:[[self->document_ selLayer] sel]
                                                         first:[self->editState_ firstPoint]
                                                        second:[self->editState_ secondPoint]
                                                         third:[self->editState_ thirdPoint]];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawParallelogramDensity

// ---------------------------------------------------------- instance - public
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
    // 描画
    [self->factory_ createDensityParallelogramEditter:YES
                                                layer:[[self->document_ selLayer] sel]
                                                first:[self->editState_ firstPoint]
                                               second:[self->editState_ secondPoint]
                                                third:[self->editState_ thirdPoint]];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawParallelogramAtomizer

// ---------------------------------------------------------- instance - public
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
    // 描画
    [self->factory_ createAtomizerParallelogramEditter:YES
                                                 layer:[[self->document_ selLayer] sel]
                                                 first:[self->editState_ firstPoint]
                                                second:[self->editState_ secondPoint]
                                                 third:[self->editState_ thirdPoint]];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawParallelogramGradation

// ---------------------------------------------------------- instance - public
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
    // 描画
    [self->factory_ createGradationParallelogramEditter:YES
                                                  layer:[[self->document_ selLayer] sel]
                                                  first:[self->editState_ firstPoint]
                                                 second:[self->editState_ secondPoint]
                                                  third:[self->editState_ thirdPoint]];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawParallelogramRandom

// ---------------------------------------------------------- instance - public
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
    // 描画
    [self->factory_ createRandomParallelogramEditter:YES
                                               layer:[[self->document_ selLayer] sel]
                                               first:[self->editState_ firstPoint]
                                              second:[self->editState_ secondPoint]
                                               third:[self->editState_ thirdPoint]];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawParallelogramWaterDrop

// ---------------------------------------------------------- instance - public
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
    // 描画
    [self->factory_ createWaterDropParallelogramEditter:YES
                                                  layer:[[self->document_ selLayer] sel]
                                                  first:[self->editState_ firstPoint]
                                                 second:[self->editState_ secondPoint]
                                                  third:[self->editState_ thirdPoint]];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawParallelogramFillNormal

// ---------------------------------------------------------- instance - public
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
    // 描画
    [self->factory_ createNormalParallelogramFillEditter:YES
                                                   layer:[[self->document_ selLayer] sel]
                                                   first:[self->editState_ firstPoint]
                                                  second:[self->editState_ secondPoint]
                                                   third:[self->editState_ thirdPoint]];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawParallelogramFillUniformedDensity

// ---------------------------------------------------------- instance - public
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
    // 描画
    [self->factory_ createUniformedDensityParallelogramFillEditter:YES
                                                             layer:[[self->document_ selLayer] sel]
                                                             first:[self->editState_ firstPoint]
                                                            second:[self->editState_ secondPoint]
                                                             third:[self->editState_ thirdPoint]];
    
    return;
}

@end




// ============================================================================
@implementation PoCoDrawParallelogramFillDensity

// ---------------------------------------------------------- instance - public
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
    // 描画
    [self->factory_ createDensityParallelogramFillEditter:YES
                                                    layer:[[self->document_ selLayer] sel]
                                                    first:[self->editState_ firstPoint]
                                                   second:[self->editState_ secondPoint]
                                                    third:[self->editState_ thirdPoint]];
    
    return;
}

@end




// ============================================================================
@implementation PoCoDrawParallelogramFillAtomizer

// ---------------------------------------------------------- instance - public
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
    // 描画
    [self->factory_ createAtomizerParallelogramFillEditter:YES
                                                     layer:[[self->document_ selLayer] sel]
                                                     first:[self->editState_ firstPoint]
                                                    second:[self->editState_ secondPoint]
                                                     third:[self->editState_ thirdPoint]];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawParallelogramFillGradation

// ---------------------------------------------------------- instance - public
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
    // 描画
    [self->factory_ createGradationParallelogramFillEditter:YES
                                                      layer:[[self->document_ selLayer] sel]
                                                      first:[self->editState_ firstPoint]
                                                     second:[self->editState_ secondPoint]
                                                      third:[self->editState_ thirdPoint]];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawParallelogramFillRandom

// ---------------------------------------------------------- instance - public
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
    // 描画
    [self->factory_ createRandomParallelogramFillEditter:YES
                                                   layer:[[self->document_ selLayer] sel]
                                                   first:[self->editState_ firstPoint]
                                                  second:[self->editState_ secondPoint]
                                                   third:[self->editState_ thirdPoint]];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawParallelogramFillWaterDrop

// ---------------------------------------------------------- instance - public
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
    // 描画
    [self->factory_ createWaterDropParallelogramFillEditter:YES
                                                      layer:[[self->document_ selLayer] sel]
                                                      first:[self->editState_ firstPoint]
                                                     second:[self->editState_ secondPoint]
                                                      third:[self->editState_ thirdPoint]];

    return;
}

@end
