//
//	Pelistina on Cocoa - PoCo -
//	描画編集系 - 矩形枠
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoDrawBox.h"

#import <Carbon/Carbon.h>

#import "PoCoMyDocument.h"
#import "PoCoSelLayer.h"
#import "PoCoEditInfo.h"
#import "PoCoEditState.h"
#import "PoCoControllerFactory.h"

// ============================================================================
@implementation PoCoDrawBoxBase

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

    r = [[PoCoRect alloc] initLeft:[[self->editState_  firstPoint] x]
                           initTop:[[self->editState_  firstPoint] y]
                         initRight:[[self->editState_ secondPoint] x]
                        initBottom:[[self->editState_ secondPoint] y]];
    [self->editInfo_ setPDRect:r];
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
    DPRINT((@"[PoCoDrawBoxBase initWithDoc]\n"));

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
    DPRINT((@"[PoCoDrawBoxBase dealloc]\n"));

    // ガイドライン消去
    [self drawGuideLine];

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
        [self->factory_ createInvertBoxEditter:YES
                                         layer:[[self->document_ selLayer] sel]
                                         start:[self->editState_ firstPoint]
                                           end:[self->editState_ secondPoint]
                                   orientation:[self->editState_ thirdPoint]];
    } else if ([self->editState_ hasSecondPoint]) {
        [self->factory_ createInvertBoxEditter:YES
                                         layer:[[self->document_ selLayer] sel]
                                         start:[self->editState_ firstPoint]
                                           end:[self->editState_ secondPoint]
                                   orientation:nil];
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
    } else if ((!([self->editState_ hasThirdPoint])) &&
               (([evt modifierFlags] & NSEventModifierFlagCommand) != 0x00) &&
               ([evt clickCount] <= 1)) {
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
            if ([self->editState_ hasThirdPoint]) {
                [self->editState_ setThirdPoint:nil];
            } else {
                [self->editState_ setSecondPoint:nil];
            }
        }

        // 描画実行
        [self->editState_ countUpEdit];
        [self exec];

        // 形状変更
        if ([self->editState_ isPointMove]) {
            if ([self->editState_ hasThirdPoint]) {
                [self->editState_ clearThirdPoint];
            }
            [self->editState_ setFirstPoint:[self->editState_ secondPoint]];
        }

        // ガイドライン描画
        [self drawGuideLine];

        // 最終 PD 位置更新
        [self->editInfo_ setLastPos:[self->editState_ secondPoint]];
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
        [self drawGuideLine];

        // 形状を設定
        if ([self->editState_ isIdenticalShape]) {
            // 形状固定状態
            if ([self->editState_ hasThirdPoint]) {
                [self->editState_
                    moveX:([[self->editInfo_ pdPos] x] - [[self->editState_ thirdPoint] x])
                    moveY:([[self->editInfo_ pdPos] y] - [[self->editState_ thirdPoint] y])];
            } else {
                [self->editState_
                    moveX:([[self->editInfo_ pdPos] x] - [[self->editState_ secondPoint] x])
                    moveY:([[self->editInfo_ pdPos] y] - [[self->editState_ secondPoint] y])];
            }
        } else if ([self->editState_ hasThirdPoint]) {
            // 方向指定
            [self->editState_ setThirdPoint:nil];
        } else {
            // 起点固定
            [self->editState_ setSecondPoint:nil];
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
@implementation PoCoDrawBoxNormal

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
    [self->factory_ createNormalBoxEditter:YES
                                     layer:[[self->document_ selLayer] sel]
                                     start:[self->editState_ firstPoint]
                                       end:[self->editState_ secondPoint]
                               orientation:(([self->editState_ hasThirdPoint]) ? [self->editState_ thirdPoint] : nil)];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawBoxUniformedDensity

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
    [self->factory_ createUniformedDensityBoxEditter:YES
                                layer:[[self->document_ selLayer] sel]
                                start:[self->editState_ firstPoint]
                                  end:[self->editState_ secondPoint]
                          orientation:(([self->editState_ hasThirdPoint]) ? [self->editState_ thirdPoint] : nil)];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawBoxDensity

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
    [self->factory_ createDensityBoxEditter:YES
                                      layer:[[self->document_ selLayer] sel]
                                      start:[self->editState_ firstPoint]
                                        end:[self->editState_ secondPoint]
                                orientation:(([self->editState_ hasThirdPoint]) ? [self->editState_ thirdPoint] : nil)];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawBoxAtomizer

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
    [self->factory_ createAtomizerBoxEditter:YES
                                       layer:[[self->document_ selLayer] sel]
                                       start:[self->editState_ firstPoint]
                                         end:[self->editState_ secondPoint]
                                 orientation:(([self->editState_ hasThirdPoint]) ? [self->editState_ thirdPoint] : nil)];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawBoxGradation

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
    [self->factory_ createGradationBoxEditter:YES
                                        layer:[[self->document_ selLayer] sel]
                                        start:[self->editState_ firstPoint]
                                          end:[self->editState_ secondPoint]
                                  orientation:(([self->editState_ hasThirdPoint]) ? [self->editState_ thirdPoint] : nil)];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawBoxRandom

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
    [self->factory_ createRandomBoxEditter:YES
                                     layer:[[self->document_ selLayer] sel]
                                     start:[self->editState_ firstPoint]
                                       end:[self->editState_ secondPoint]
                               orientation:(([self->editState_ hasThirdPoint]) ? [self->editState_ thirdPoint] : nil)];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawBoxWaterDrop

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
    [self->factory_ createWaterDropBoxEditter:YES
                                        layer:[[self->document_ selLayer] sel]
                                        start:[self->editState_ firstPoint]
                                          end:[self->editState_ secondPoint]
                                  orientation:(([self->editState_ hasThirdPoint]) ? [self->editState_ thirdPoint] : nil)];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawBoxFillNormal

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
    [self->factory_ createNormalBoxFillEditter:YES
                                         layer:[[self->document_ selLayer] sel]
                                         start:[self->editState_ firstPoint]
                                           end:[self->editState_ secondPoint]
                                   orientation:(([self->editState_ hasThirdPoint]) ? [self->editState_ thirdPoint] : nil)];

    return;
}

@end




// ============================================================================
@implementation PoCoDrawBoxFillUniformedDensity

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
    [self->factory_ createUniformedDensityBoxFillEditter:YES
                                                   layer:[[self->document_ selLayer] sel]
                                                   start:[self->editState_ firstPoint]
                                                     end:[self->editState_ secondPoint]
                                             orientation:(([self->editState_ hasThirdPoint]) ? [self->editState_ thirdPoint] : nil)];
    
    return;
}

@end




// ============================================================================
@implementation PoCoDrawBoxFillDensity

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
    [self->factory_ createDensityBoxFillEditter:YES
                                          layer:[[self->document_ selLayer] sel]
                                          start:[self->editState_ firstPoint]
                                            end:[self->editState_ secondPoint]
                                    orientation:(([self->editState_ hasThirdPoint]) ? [self->editState_ thirdPoint] : nil)];
    
    return;
}

@end




// ============================================================================
@implementation PoCoDrawBoxFillAtomizer

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
    [self->factory_ createAtomizerBoxFillEditter:YES
                                           layer:[[self->document_ selLayer] sel]
                                           start:[self->editState_ firstPoint]
                                             end:[self->editState_ secondPoint]
                                     orientation:(([self->editState_ hasThirdPoint]) ? [self->editState_ thirdPoint] : nil)];
    
    return;
}

@end




// ============================================================================
@implementation PoCoDrawBoxFillGradation

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
    [self->factory_ createGradationBoxFillEditter:YES
                                            layer:[[self->document_ selLayer] sel]
                                            start:[self->editState_ firstPoint]
                                              end:[self->editState_ secondPoint]
                                      orientation:(([self->editState_ hasThirdPoint]) ? [self->editState_ thirdPoint] : nil)];
    
    return;
}

@end




// ============================================================================
@implementation PoCoDrawBoxFillRandom

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
    [self->factory_ createRandomBoxFillEditter:YES
                                         layer:[[self->document_ selLayer] sel]
                                         start:[self->editState_ firstPoint]
                                           end:[self->editState_ secondPoint]
                                   orientation:(([self->editState_ hasThirdPoint]) ? [self->editState_ thirdPoint] : nil)];
    
    return;
}

@end




// ============================================================================
@implementation PoCoDrawBoxFillWaterDrop

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
    [self->factory_ createWaterDropBoxFillEditter:YES
                                            layer:[[self->document_ selLayer] sel]
                                            start:[self->editState_ firstPoint]
                                              end:[self->editState_ secondPoint]
                                      orientation:(([self->editState_ hasThirdPoint]) ? [self->editState_ thirdPoint] : nil)];
    
    return;
}

@end
