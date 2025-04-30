//
//	Pelistina on Cocoa - PoCo -
//	描画編集系 - 基底
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoDrawBase.h"

#import "PoCoMyDocument.h"
#import "PoCoView.h"
#import "PoCoAppController.h"
#import "PoCoView.h"
#import "PoCoLayer.h"
#import "PoCoPicture.h"
#import "PoCoSelLayer.h"
#import "PoCoEditInfo.h"
#import "PoCoEditState.h"
#import "PoCoControllerFactory.h"

// ============================================================================
@implementation PoCoDrawBase

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    doc : 編集対象
//
//  Return
//    function   : 実体
//    document_  : 編集対象(instance 変数)
//    editInfo_  : 編集情報(instance 変数)
//    editState_ : 編集の状態遷移(instance 変数)
//    factory_   : 編集の生成部(instance 変数)
//
-(id)initWithDoc:(MyDocument *)doc
{
    DPRINT((@"[PoCoDrawBase initWithDoc]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->document_ = nil;
        self->editInfo_ = nil;
        self->editState_ = nil;
        self->factory_ = nil;

        // それぞれの実体を取得
        self->document_ = doc;
        self->editInfo_ = [(PoCoAppController *)([NSApp delegate]) editInfo];
        self->editState_ = [[PoCoEditState alloc] init];
        self->factory_ = [(PoCoAppController *)([NSApp delegate]) factory];

        // それぞれの実体を retain
        [self->document_ retain];
        [self->editInfo_ retain];
#if 0   // editState_ は alloc しているので retain 不要
        [self->editState_ retain];
#endif  // 0
        [self->factory_ retain];
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
//    documnet_  : 編集対象(instance 変数)
//    editInfo_  : 編集情報(instance 変数)
//    editState_ : 編集の状態遷移(instance 変数)
//    factory_   : 編集の生成部(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoDrawBase dealloc]\n"));

    // 資源の解放
    [self->document_ release];
    [self->editInfo_ release];
    [self->editState_ release];
    [self->factory_ release];
    self->document_ = nil;
    self->editInfo_ = nil;
    self->editState_ = nil;
    self->factory_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


// --------------------------------------------- instance - public - 範囲選択系
//
// ペーストボードから貼り付け
//
//  Call
//    lyr : 貼り付け画像
//
//  Return
//    None
//
-(void)pasteBitmap:(PoCoLayerBase *)lyr
{
    // 基底ではなにもしない
    ;

    return;
}


//
// 削除
//
//  Call
//    None
//
//  Return
//    None
//
-(void)delete
{
    // 基底では何もしない
    ;

    return;
}


//
// 画像反転
//
//  Call
//    hori : 水平か
//           YES : 水平に画像反転
//           NO  : 垂直に画像反転
//
//  Return
//    None
//
-(void)flipImage:(BOOL)hori
{
    // 基底では何もしない
    ;

    return;
}


//
// 自動グラデーション
//
//  Call
//    size     : 大きさ(0: 任意、1-128 の範囲)
//    adj      : 隣接(YES: 隣り合う色番号のみ)
//    mtx      : 対象色配列(256 固定長、YES: 対象)
//    sizePair : 大きさと色番号の対群
//
//  Return
//    None
//
-(void)autoGrad:(int)size
     isAdjacent:(BOOL)adj
         matrix:(const BOOL *)mtx
   withSizePair:(NSDictionary *)sizePair
{
    // 基底では何もしない
    ;

    return;
}


//
// 色置換
//
//  Call
//    mtx : 置換表(256 固定長)
//
//  Return
//    None
//
-(void)colorReplace:(const unsigned char *)mtx
{
    // 基底では何もしない
    ;

    return;
}


//
// テクスチャ
//
//  Call
//    base : 基本色(NSArray<unsigned int>)
//    grad : 濃淡対(NSArray<unsinged int, NSArray<unsigned int> >)
//
//  Return
//    None
//
-(void)texture:(NSArray *)base
  withGradient:(NSArray *)grad
{
    // 基底では何もしない
    ;

    return;
}


//
// 全選択
//
//  Call
//    None
//
//  Return
//    None
//
-(void)selectAll
{
    // 基底では何もしない
    ;

    return;
}


//
// 選択解除
//
//  Call
//    None
//
//  Return
//    None
//
-(void)selectClear
{
    // 基底では何もしない
    ;

    return;
}


//
// 移動画像を再生成
//
//  Call
//    None
//
//  Return
//    None
//
-(void)recreatePasteImage
{
    // 基底では何もしない
    ;

    return;
}


// --------------------------------------------------- instance - public - 補助
//
// 編集禁止レイヤー判定
//  
//  Call
//    document_ : 編集対象(instance 変数)
// 
//  Return
//    function : YES : 禁止
//               NO  : 許可
//
-(BOOL)isNotEditLayer
{
    return [[[self->document_ picture] layer:[[self->document_ selLayer] sel]] drawLock];
}


//
// 色吸い取り
//
//  Call
//    documnet_ : 編集対象(instance 変数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    editInfo_ : 編集情報(instance 変数)
//
-(void)dropper
{
    int num;                            // 選択色
    PoCoRect *r;
    PoCoPoint *p;                       // 画像内座標
    PoCoSelColor *old;                  // 以前の選択色

    p = [self->editInfo_ pdPos];
    r = [[self->document_ picture] bitmapPoCoRect];
    if ([r isPointInRect:p]) {
        old = [self->editInfo_ selColor];
        num = [[self->document_ picture] pointColor:p
                                            atIndex:[[self->document_ selLayer] sel]];

        // 色を切り替え
        if (([old isPattern]) || ([old num] != num)) {
            [self->editInfo_ setSelColor:num];

            // 切り替えを通知
            [[NSNotificationCenter defaultCenter]
                postNotificationName:PoCoChangeColor
                              object:nil];

        }
    }
    [r release];

    return;
}


//
// ずりずり
//
//  Call
//    evt       : 取得イベント
//    document_ : 編集対象(instance 変数)
//
//  Return
//    None
//
-(void)dragMove:(NSEvent *)evt
{
    NSRect r;

    // 表示矩形枠取得
    r = [[self->document_ view] visibleRect];

    // 水平移動
    if ([evt deltaX] != 0) {
        r.origin.x -= [evt deltaX]; 
        [[self->document_ view] scrollRectToVisible:r];
    }
    
    // 垂直移動
    if ([evt deltaY] != 0) {
        r.origin.y -= [evt deltaY];
        [[self->document_ view] scrollRectToVisible:r];
    }

    return;
}


//
// 取り消し開始
//
//  Call
//    group     : 取り消し群指定
//    document_ : 編集対象(instance 変数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    editInfo_ : 編集情報(instance 変数)
//
-(void)beginUndo:(BOOL)group
{
    // 取り消し群開始
    if ([self->editInfo_ enableUndo]) {
        if (group) {
            [[self->document_ undoManager] beginUndoGrouping];
        }
    }

    // 消しゴム用画像取得
    if (([self->editInfo_ enableEraser]) &&
        (!([self->editInfo_ eraserType]))) {
        [self->document_ setEraser];
    }

    return;
}


//
// 取り消し終了
//
//  Call
//    group     : 取り消し群指定
//    document_ : 編集対象(instance 変数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(void)endUndo:(BOOL)group
{
    // 取り消し群終了
    if ([self->editInfo_ enableUndo]) {
        if (group) {
            [[self->document_ undoManager] endUndoGrouping];
        }
    }

    return;
}


//
// Pointer 形状範囲更新
//
//  Call
//    document_ : 編集対象(instance 変数)
//
//  Return
//    None
//
-(void)updateCursorRect
{
    // 基底では範囲をすべて解除するだけ
    [[self->document_ view] discardCursorRects];

    return;
}


//
// ガイドライン描画
//
//  Call
//    None
//
//  Return
//    None
//
-(void)drawGuideLine
{
    // 基底では何もしない
    ;

    return;
}


//
// 編集状態解除
//
//  Call
//    None
//
//  Return
//    None
//
-(void)cancelEdit
{
    // 基底では何もしない
    ;

    return;
}


//
// 変形前画像
//
//  Call
//    None
//
//  Return
//    function : 画像
//
-(PoCoBitmap *)originalImage
{
    // 基底では何もしない
    ;

    return nil;
}


//
// 変形前形状
//
//  Call
//    None
//
//  Return
//    function : 形状 
//
-(PoCoBitmap *)originalShape
{
    // 基底では何もしない
    ;

    return nil;
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
    // 基底では何もしない
    ;

    return NO;
}


// ------------------------------------------- instance - public - イベント操作
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
    // 基底ではなにもしない
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
    // 基底ではなにもしない
    ;

    return;
}


//
// 主ボタンリリース
//
//  Call
//    evt : 取得イベント
//
//  Return
//    None
//
-(void)mouseUp:(NSEvent *)evt
{
    // 基底ではなにもしない
    ;

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
    // 基底ではなにもしない
    ;

    return;
}


//
// 副ボタンドラッグ
//
//  Call
//    evt : 取得イベント
//
//  Return
//    None
//
-(void)rightMouseDrag:(NSEvent *)evt
{
    // 基底ではなにもしない
    ;

    return;
}


//
// 副ボタンリリース
//
//  Call
//    evt : 取得イベント
//
//  Return
//    None
//
-(void)rightMouseUp:(NSEvent *)evt
{
    // 基底ではなにもしない
    ;

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
    // 基底ではなにもしない
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
    // 基底ではなにもしない
    ;

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
    // 基底ではなにもしない
    ;

    return;
}

@end
