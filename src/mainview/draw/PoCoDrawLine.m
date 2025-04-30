//
//	Pelistina on Cocoa - PoCo -
//	描画編集系 - 直線
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoDrawLine.h"

#import <Carbon/Carbon.h>

#import "PoCoMyDocument.h"
#import "PoCoSelLayer.h"
#import "PoCoEditInfo.h"
#import "PoCoEditState.h"
#import "PoCoControllerFactory.h"

// ============================================================================
@implementation PoCoDrawLineBase

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


//
// 点を追加
//
//  Call
//    pt : 点
//
//  Return
//    points_ : 点群(instance 変数)
//
-(void)addPointToPoints:(PoCoPoint *)pt
{
    PoCoPoint *tmp;

    tmp = [[PoCoPoint alloc] initX:[pt x]
                             initY:[pt y]];
    [self->points_ addObject:tmp];
    [tmp release];

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
//    points_  : 点群(instance 変数)
//
-(id)initWithDoc:(MyDocument *)doc
{
    DPRINT((@"[PoCoDrawLineBase initWithDoc]\n"));

    // super class の初期化
    self = [super initWithDoc:doc];

    // 自身の初期化
    if (self != nil) {
        // 何もしない
        self->points_ = [[NSMutableArray alloc] init];
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
//    points_ : 点群(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoDrawLineBase dealloc]\n"));

    // ガイドライン消去
    [self drawGuideLine];

    // 取り消し終了
    [super endUndo:NO];

    // 編集終了
    [self->editState_ endEditMode];

    // 矩形枠の通達
    [self setInfoPDRect];

    // 資源の解放
    [self->points_ removeAllObjects];
    [self->points_ release];
    self->points_ = nil;

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
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//    points_    : 点群(instance 変数)
//
//  Return
//    None
//
-(void)drawGuideLine
{
    if ([self->points_ count] != 0) {
        // 直線群
        if ([self->editInfo_ interGuide] != PoCoInterpolationGuideView_Curve) {
            // 直線ガイド
            [self->factory_ createInvertPolylineEditter:YES
                                                  layer:[[self->document_ selLayer] sel]
                                                   poly:self->points_];
        }
        if ([self->editInfo_ interGuide] != PoCoInterpolationGuideView_Line) {
            // 曲線ガイド
            [self->factory_ createInvertCurveWithPointsEditter:YES
                                                         layer:[[self->document_ selLayer] sel]
                                                        points:self->points_
                                                          type:[self->editInfo_ interType]
                                                          freq:[self->editInfo_ interFreq]];
        }
    } else {
        // 直線
        if ([self->editState_ hasSecondPoint]) {
            [self->factory_ createInvertLineEditter:YES
                                              layer:[[self->document_ selLayer] sel]
                                              start:[self->editState_ firstPoint]
                                                end:[self->editState_ secondPoint]];
        }
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
//    points_ : 点群(instance 変数)
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
        [self->points_ removeAllObjects];

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
//    points_    : 点群(instance 変数)
//
//  Return
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    points_    : 点群(instance 変数)
//
-(void)mouseDown:(NSEvent *)evt
{
    const BOOL inter = ([self->points_ count] != 0);

    if ([super isNotEditLayer]) {
        // 編集禁止レイヤー
        ;
    } else if ((([evt modifierFlags] & NSCommandKeyMask) != 0x00) &&
               (([evt modifierFlags] & NSControlKeyMask) != 0x00)) {
        // Command + Control はスポイトとする
        [self drawGuideLine];           // ガイドライン消去
        [super dropper];
        [self drawGuideLine];           // ガイドライン表示
    } else if ([self->editState_ isFirstPoint]) {
        // 状態遷移開始
        [self->editState_ beginEditMode];

        // 座標を設定
        [self->editState_ setFirstPoint:nil];

        // 点群を無しにする
        [self->points_ removeAllObjects];

        // 取り消し開始
        [super beginUndo:NO];
    } else if ((([evt modifierFlags] & NSCommandKeyMask) != 0x00) &&
               ([evt clickCount] <= 1)) {
        // 直線群

        // ガイドライン消去
        [self drawGuideLine];

        // 点を追加
        if (inter) {
            // 2点目以降
            [self->editState_ setSecondPoint:nil];
            [self addPointToPoints:[self->editState_ secondPoint]];
        } else {
            // 初回
            [self addPointToPoints:[self->editState_ firstPoint]];  // 1点目
            [self->editState_ setSecondPoint:nil];
            [self addPointToPoints:[self->editState_ secondPoint]]; // 2点目
            [self addPointToPoints:[self->editState_ secondPoint]]; // 3点目(2点目と同じ)
        }

        // ガイドライン描画
        [self drawGuideLine];
    } else {
        // ガイドライン消去
        [self drawGuideLine];

        // 終点決定
        if (inter) {
            // 直線群
#if 0   // mouseMove で登録しているので要らない
            [self->editState_ setSecondPoint:nil];
            [self->points_ removeLastObject];
            [self addPointToPoints:[self->editState_ secondPoint]];
#endif  // 0
        } else {
            // 直線
            if (!([self->editState_ isIdenticalShape])) {
                [self->editState_ setSecondPoint:nil];
            }
        }

        // 描画実行
        [self->editState_ countUpEdit];
        [self exec];

        // 形状変更
        if (inter) {
            // 直線群の場合は形状は維持しない
            [self->points_ removeAllObjects];

            // 最終 PD 位置更新
            [self->editState_ setSecondPoint:nil];
            [self->editInfo_ setLastPos:[self->editState_ secondPoint]];

            // 編集状態を抜ける
            [self->editState_ endEditMode]; // 編集終了
            [super endUndo:NO];             // 取り消し終了
            [self setInfoPDRect];           // 矩形枠の通達
        } else {
            // 直線の場合は設定に依る
            if ([self->editState_ isPointMove]) {
                [self->editState_ setFirstPoint:[self->editState_ secondPoint]];
            }

            // 最終 PD 位置更新
            [self->editInfo_ setLastPos:[self->editState_ secondPoint]];

            // ガイドライン描画
            [self drawGuideLine];
        }
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
//    points_    : 点群(instance 変数)
//
//  Return
//    None
//
-(void)rightMouseDown:(NSEvent *)evt
{
    if ([self->editState_ isFirstPoint]) {
        // 色吸い取り
        [super dropper];
    } else if ([self->points_ count] != 0) {
        // ガイドライン消去
        [self drawGuideLine];

        // 直線群の数を減らす
        [self->editState_ setSecondPoint:nil];
        [self->points_ removeLastObject];
        if ([self->points_ count] < 3) {
            // 3点未満の場合は直線に戻る
            [self->points_ removeAllObjects];
        } else {
            // 3点以上の場合は更に減らした上で現在位置を制御点にし直す
            [self->points_ removeLastObject];
            [self addPointToPoints:[self->editState_ secondPoint]];
        }

        // ガイドライン描画
        [self drawGuideLine];
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
//    points_    : 点群(instance 変数)
//
//  Return
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    points_    : 点群(instance 変数)
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
        if ([self->points_ count] != 0) {
            // 直線群
            [self->editState_ setSecondPoint:nil];
            [self->points_ removeLastObject];
            [self addPointToPoints:[self->editState_ secondPoint]];
        } else {
            // 直線の場合は設定に依る
            if ([self->editState_ isIdenticalShape]) {
                // 形状固定状態
                [self->editState_
                    moveX:([[self->editInfo_ pdPos] x] - [[self->editState_ secondPoint] x])
                    moveY:([[self->editInfo_ pdPos] y] - [[self->editState_ secondPoint] y])];
            } else {
                // 起点固定
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
@implementation PoCoDrawLineNormal

// ---------------------------------------------------------- instance - public
//
// 描画実行
//
//  Call
//    document_  : 編集対象(基底 instance 変数)
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//    points_    : 点群(基底 instance 変数)
//
//  Return
//    None
//
-(void)exec
{
    NSString *name;

    // 描画
    if ([self->points_ count] != 0) {
        // 直線群
        [self->factory_ createNormalCurveWithPointsEditter:YES
                                                     layer:[[self->document_ selLayer] sel]
                                                    points:self->points_
                                                      type:[self->editInfo_ interType]
                                                      freq:[self->editInfo_ interFreq]];
    } else {
        // 名称取得
        name = [[NSBundle mainBundle]
                   localizedStringForKey:@"DrawLineShape"
                                   value:@"line shape"
                                   table:nil];

        // 直線
        [self->factory_ createNormalFreeLineEditter:YES
                                              layer:[[self->document_ selLayer] sel]
                                              start:[self->editState_ firstPoint]
                                                end:[self->editState_ secondPoint]
                                           undoName:name];
    }

    return;
}

@end




// ============================================================================
@implementation PoCoDrawLineUniformedDensity

// ---------------------------------------------------------- instance - public
//
// 描画実行
//
//  Call
//    document_  : 編集対象(基底 instance 変数)
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//    points_    : 点群(基底 instance 変数)
//
//  Return
//    None
//
-(void)exec
{
    NSString *name;

    // 描画
    if ([self->points_ count] != 0) {
        // 直線群
        [self->factory_ createUniformedDensityCurveWithPointsEditter:YES
                                                               layer:[[self->document_ selLayer] sel]
                                                              points:self->points_
                                                                type:[self->editInfo_ interType]
                                                                freq:[self->editInfo_ interFreq]];
    } else {
        // 名称取得
        name = [[NSBundle mainBundle]
                   localizedStringForKey:@"DrawLineShape"
                                   value:@"line shape"
                                   table:nil];

        // 直線
        [self->factory_ createUniformedDensityFreeLineEditter:YES
                                                        layer:[[self->document_ selLayer] sel]
                                                        start:[self->editState_ firstPoint]
                                                          end:[self->editState_ secondPoint]
                                                     undoName:name];
    }

    return;
}

@end




// ============================================================================
@implementation PoCoDrawLineDensity

// ---------------------------------------------------------- instance - public
//
// 描画実行
//
//  Call
//    document_  : 編集対象(基底 instance 変数)
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//    points_    : 点群(基底 instance 変数)
//
//  Return
//    None
//
-(void)exec
{
    NSString *name;

    // 描画
    if ([self->points_ count] != 0) {
        // 直線群
        [self->factory_ createDensityCurveWithPointsEditter:YES
                                                      layer:[[self->document_ selLayer] sel]
                                                     points:self->points_
                                                       type:[self->editInfo_ interType]
                                                       freq:[self->editInfo_ interFreq]];
    } else {
        // 名称取得
        name = [[NSBundle mainBundle]
                   localizedStringForKey:@"DrawLineShape"
                                   value:@"line shape"
                                   table:nil];

        // 直線
        [self->factory_ createDensityFreeLineEditter:YES
                                               layer:[[self->document_ selLayer] sel]
                                               start:[self->editState_ firstPoint]
                                                 end:[self->editState_ secondPoint]
                                            undoName:name];
    }

    return;
}

@end




// ============================================================================
@implementation PoCoDrawLineAtomizer

// ---------------------------------------------------------- instance - public
//
// 描画実行
//
//  Call
//    document_  : 編集対象(基底 instance 変数)
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//    points_    : 点群(基底 instance 変数)
//
//  Return
//    None
//
-(void)exec
{
    NSString *name;

    // 描画
    if ([self->points_ count] != 0) {
        // 直線群
        [self->factory_ createAtomizerCurveWithPointsEditter:YES
                                                       layer:[[self->document_ selLayer] sel]
                                                      points:self->points_
                                                        type:[self->editInfo_ interType]
                                                        freq:[self->editInfo_ interFreq]];
    } else {
        // 名称取得
        name = [[NSBundle mainBundle]
                   localizedStringForKey:@"DrawLineShape"
                                   value:@"line shape"
                                   table:nil];

        // 直線
        [self->factory_ createAtomizerFreeLineEditter:YES
                                                layer:[[self->document_ selLayer] sel]
                                                start:[self->editState_ firstPoint]
                                                  end:[self->editState_ secondPoint]
                                             undoName:name];
    }

    return;
}

@end




// ============================================================================
@implementation PoCoDrawLineGradation

// ---------------------------------------------------------- instance - public
//
// 描画実行
//
//  Call
//    document_  : 編集対象(基底 instance 変数)
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//    points_    : 点群(基底 instance 変数)
//
//  Return
//    None
//
-(void)exec
{
    NSString *name;

    // 描画
    if ([self->points_ count] != 0) {
        // 直線群
        [self->factory_ createGradationCurveWithPointsEditter:YES
                                                        layer:[[self->document_ selLayer] sel]
                                                       points:self->points_
                                                         type:[self->editInfo_ interType]
                                                         freq:[self->editInfo_ interFreq]];
    } else {
        // 名称取得
        name = [[NSBundle mainBundle]
                   localizedStringForKey:@"DrawLineShape"
                                   value:@"line shape"
                                   table:nil];

        // 直線
        [self->factory_ createGradationFreeLineEditter:YES
                                                 layer:[[self->document_ selLayer] sel]
                                                 start:[self->editState_ firstPoint]
                                                   end:[self->editState_ secondPoint]
                                              undoName:name];
    }

    return;
}

@end




// ============================================================================
@implementation PoCoDrawLineRandom

// ---------------------------------------------------------- instance - public
//
// 描画実行
//
//  Call
//    document_  : 編集対象(基底 instance 変数)
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//    points_    : 点群(基底 instance 変数)
//
//  Return
//    None
//
-(void)exec
{
    NSString *name;

    // 描画
    if ([self->points_ count] != 0) {
        // 直線群
        [self->factory_ createRandomCurveWithPointsEditter:YES
                                                     layer:[[self->document_ selLayer] sel]
                                                    points:self->points_
                                                      type:[self->editInfo_ interType]
                                                      freq:[self->editInfo_ interFreq]];
    } else {
        // 名称取得
        name = [[NSBundle mainBundle]
                   localizedStringForKey:@"DrawLineShape"
                                   value:@"line shape"
                                   table:nil];

        // 直線
        [self->factory_ createRandomFreeLineEditter:YES
                                              layer:[[self->document_ selLayer] sel]
                                              start:[self->editState_ firstPoint]
                                                end:[self->editState_ secondPoint]
                                           undoName:name];
    }

    return;
}

@end




// ============================================================================
@implementation PoCoDrawLineWaterDrop

// ---------------------------------------------------------- instance - public
//
// 描画実行
//
//  Call
//    document_  : 編集対象(基底 instance 変数)
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//    points_    : 点群(基底 instance 変数)
//
//  Return
//    None
//
-(void)exec
{
    NSString *name;

    // 描画
    if ([self->points_ count] != 0) {
        // 直線群
        [self->factory_ createWaterDropCurveWithPointsEditter:YES
                                                        layer:[[self->document_ selLayer] sel]
                                                       points:self->points_
                                                        type:[self->editInfo_ interType]
                                                        freq:[self->editInfo_ interFreq]];
    } else {
        // 名称取得
        name = [[NSBundle mainBundle]
                   localizedStringForKey:@"DrawLineShape"
                                   value:@"line shape"
                                   table:nil];

        // 直線
        [self->factory_ createWaterDropFreeLineEditter:YES
                                                 layer:[[self->document_ selLayer] sel]
                                                 start:[self->editState_ firstPoint]
                                                   end:[self->editState_ secondPoint]
                                              undoName:name];
    }

    return;
}

@end
