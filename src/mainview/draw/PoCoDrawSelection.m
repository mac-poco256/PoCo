//
// PoCoDrawSelection.m
// implementation of PoCoDrawSelection class.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.

#import "PoCoDrawSelection.h"

#import <Carbon/Carbon.h>

#import "PoCoMyDocument.h"
#import "PoCoView.h"
#import "PoCoPicture.h"
#import "PoCoSelLayer.h"
#import "PoCoEditInfo.h"
#import "PoCoEditState.h"
#import "PoCoControllerFactory.h"
#import "PoCoCreateStyleMask.h"

// 内部定数
typedef enum __pocoSelEditType {
    edit_withHandle,
    edit_paste,
    edit_delete,
    edit_flip_hori,
    edit_flip_vert,
    edit_autograd,
    edit_colorreplace,
    edit_texture,
    edit_key_move
} PoCoSelectionEditType;

// ============================================================================
@implementation PoCoDrawSelection

// ----------------------------------------------------------------------------
// class - private.

//
// 選択範囲を拡張
//  half-open property のため +1 する
//
//  Call
//    r : 矩形枠
//
//  Return
//    function : 矩形枠(引数と同じ)
//
+(PoCoRect *)expandForHalfOpen:(PoCoRect *)r
{
    [r setRight:([r right] + 1)];
    [r setBottom:([r bottom] + 1)];

    return r;
}


// ----------------------------------------------------------------------------
// instance - private.

//
// 編集実行
//
//  Call
//    type       : 種別
//    copy       : 複写系操作か
//    document_  : 編集対象(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//    shape_     : 範囲形状(instance 変数)
//    prevRect_  : 移動元の矩形枠(instance 変数)
//    prevImage_ : 編集前の画像(instance 変数)
//
//  Return
//    None
//
-(void)exec:(PoCoSelectionEditType)type
     isCopy:(BOOL)copy
{
    NSBundle *bndl = [NSBundle mainBundle];
    NSString *name;
    PoCoRect *r;

    name = nil;

    // 編集方法の弁別
    switch (type) {
        case edit_paste:
            // 貼り付け
            name = [bndl localizedStringForKey:@"PasteImage"
                                         value:@"paste"
                                         table:nil];
            break;
        case edit_delete:
            // 削除
            name = [bndl localizedStringForKey:@"Delete"
                                         value:@"delete"
                                         table:nil];
            break;
        case edit_flip_hori:
            // 反転(水平)
            name = [bndl localizedStringForKey:@"FlipHori"
                                         value:@"flip(horizontal)"
                                         table:nil];
            break;
        case edit_flip_vert:
            // 反転(垂直)
            name = [bndl localizedStringForKey:@"FlipVert"
                                         value:@"flip(vertical)"
                                         table:nil];
            break;
        case edit_autograd:
            // 自動グラデーション
            name = [bndl localizedStringForKey:@"AutoGrad"
                                         value:@"auto gradation"
                                         table:nil];
            break;
        case edit_colorreplace:
            // 色置換
            name = [bndl localizedStringForKey:@"BitmapColorReplace"
                                         value:@"color replace"
                                         table:nil];
            break;
        case edit_texture:
            // テクスチャ
            name = [bndl localizedStringForKey:@"Texture"
                                         value:@"texture"
                                         table:nil];
            break;
        case edit_key_move:
            // 移動(キー操作)
            goto KEY_MOVE;
            break;

        default:
        case edit_withHandle:
            // ハンドルを伴う操作
            if ([self->shape_ isInnerHandle]) {
                // 移動系
KEY_MOVE:
                if (copy) {
                    // 複写
                    name = [bndl localizedStringForKey:@"CopyImage"
                                                 value:@"copy"
                                                 table:nil];
                } else {
                    // 移動
                    name = [bndl localizedStringForKey:@"MoveImage"
                                                 value:@"move"
                                                 table:nil];
                }
            } else if ([self->shape_ isCornerHandle]) {
                // 変倍系
                name = [bndl localizedStringForKey:@"ResizeWithHandle"
                                             value:@"resize(handle)"
                                             table:nil];
            } else if ([self->shape_ isEdgeHandle]) {
                // 回転系
                name = [bndl localizedStringForKey:@"RotateWithHandle"
                                             value:@"rotate(handle)"
                                             table:nil];
            }
            break;
    }

    // 複写系操作では貼り付け前の画像を退避
    if (copy) {
        // 以前の分を忘れる
        [self->prevImage_ release];
        self->prevImage_ = nil;

        // 全体を複写
        self->prevImage_ = [[[[self->document_ picture] layer:[[self->document_ selLayer] sel]] bitmap] copy];
    }

    // 結果を貼り付け
    if (([self->shape_ resultShape] != nil) &&
        (([self->shape_ resultPoints] == nil) ||
        ([[self->shape_ resultPoints] count] == 0))) {
        r = [[PoCoRect alloc] initPoCoRect:[self->shape_ resultRect]];
    } else {
        r = [PoCoDrawSelection expandForHalfOpen:[[PoCoRect alloc] initPoCoRect:[self->shape_ resultRect]]];
    }
    [self->factory_ createNormalPasteImageEditter:YES
                                            layer:[[self->document_ selLayer] sel]
                                             rect:r
                                           bitmap:[self->shape_ resultImage]
                                           region:[self->shape_ resultShape]
                                         prevRect:((copy) ? nil : self->prevRect_)
                                       prevBitmap:((copy) ? nil : self->prevImage_)
                                         undoName:name];
    [r release];

    return;
}


//
// 選択範囲を更新
//
//  Call
//    r : 矩形枠
//
//  Return
//    editInfo_ : 編集情報(基底 instance 変数)
//
-(void)updateSelectionRect:(PoCoRect *)r
{
    PoCoRect *tmp;

    if ((r == nil) || ([r empty])) {
        tmp = [[PoCoRect alloc] init];
        [self->editInfo_ setPDRect:tmp];
    } else {
        // ポインタ位置
        [self->editInfo_ setPDRect:r];

        // 選択範囲は half-open property のため +1
        tmp = [PoCoDrawSelection expandForHalfOpen:[[PoCoRect alloc] initPoCoRect:r]];
    }
    [self->editInfo_ setSelRect:tmp];
    [tmp release];

    return;
}


//
// 形状初期化
//
//  Call
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//
//  Return
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    shape_     : 範囲形状(instance 変数)
//    prevImage_ : 以前の画像(全体)(instance 変数)
//    prevPos_   : 以前の点(instance 変数)
//    prevRect_  : 以前の範囲(外接長方形)(instance 変数)
//
-(void)initSelectionShape
{
    [self->editState_ beginEditMode];
    [self->editState_ setFirstPoint:nil];
    [self->editState_ setSecondPoint:nil];
    [self->editInfo_ setLastPos:[self->editState_ firstPoint]];
    [self->shape_ release];
    [self->prevImage_ release];
    [self->prevPos_ release];
    [self->prevRect_ release];
    self->shape_ = nil;
    self->prevImage_ = nil;
    self->prevPos_ = nil;
    self->prevRect_ = nil;

    // 範囲形状を新規に起こす(呼び出し元で形状に応じた処理を行うこと)
    self->shape_ = [[PoCoSelectionShape alloc] init];

    return;
}


//
// 形状確定
//  範囲内画像の取得が主目的
//
//  Call
//    document_ : 編集対象(基底 instance 変数)
//
//  Return
//    prevImage_ : 編集前の画像(instance 変数)
//    shape_     : 範囲形状(instance 変数)
//
-(void)decideSelectionShape
{
    PoCoRect *r;

    [self->prevImage_ release];
    self->prevImage_ = [[[[self->document_ picture] layer:[[self->document_ selLayer] sel]] bitmap] copy];
    r = [PoCoDrawSelection expandForHalfOpen:[[PoCoRect alloc] initPoCoRect:[self->shape_ originalRect]]];
    [self->shape_ setImage:[self->prevImage_ getBitmap:r]];
    [r release];

    return;
}


// ----------------------------------------------------------------------------
// instance - public.

//
// initialise.
//
//  Call
//    doc : 編集対象
//
//  Return
//    function    : 実体
//    isCopy_     : 複写指定(instance 変数)
//    isDrag_     : ドラッグ中か(instance 変数)
//    isPaint_    : 塗り選択中か(instance 変数)
//    shape_      : 範囲形状(instance 変数)
//    prevImage_  : 以前の画像(全体)(instance 変数)
//    prevPos_    : 以前の点(instance 変数)
//    prevRect_   : 以前の範囲(外接長方形)(instance 変数)
//    prevHandle_ : 以前のハンドル(instance 変数)
//    modify_     : 修飾キー(instance 変数)
//
-(id)initWithDoc:(MyDocument *)doc
{
    DPRINT((@"[PoCoDrawSelection initWithDoc]\n"));

    // super class の初期化
    self = [super initWithDoc:doc];

    // 自身の初期化
    if (self != nil) {
        self->isCopy_ = NO;
        self->isDrag_ = NO;
        self->isPaint_ = NO;
        self->shape_ = nil;
        self->prevImage_ = nil;
        self->prevPos_ = nil;
        self->prevRect_ = nil;
        self->prevHandle_ = PoCoHandleType_unknown;
    }

    return self;
}


//
// deallocate.
//
//  Call
//    document_  : 編集対象(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//
//  Return
//    shape_     : 範囲形状(instance 変数)
//    prevImage_ : 以前の画像(全体)(instance 変数)
//    prevPos_   : 以前の点(instance 変数)
//    prevRect_  : 以前の範囲(外接長方形)(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoDrawSelection dealloc]\n"));

    // ガイドライン消去
    [self drawGuideLine];

    // Pointer 形状を戻す
    [[self->document_ view] discardCursorRects];

    // 編集終了
    [self->editState_ endEditMode];

    // 矩形枠の通達
    [self updateSelectionRect:nil];

    // 資源の解放
    [self->shape_ release];
    [self->prevImage_ release];
    [self->prevPos_ release];
    [self->prevRect_ release];
    self->shape_ = nil;
    self->prevImage_ = nil;
    self->prevPos_ = nil;
    self->prevRect_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


// ----------------------------------------------------------------------------
// instance - public - features with selection shape.

//
// ペーストボードから貼り付け
//
//  Call
//    lyr       : 貼り付け画像
//    document_ : 編集対象(基底 instance 変数)
//
//  Return
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    shape_     : 範囲形状(instance 変数)
//    prevImage_ : 以前の画像(全体)(instance 変数)
//    prevRect_  : 以前の範囲(外接長方形)(instance 変数)
//
-(void)pasteBitmap:(PoCoLayerBase *)lyr
{
    PoCoView *view = [self->document_ view];
    PoCoPoint *p;
    const int w = [[lyr bitmap] width];
    const int h = [[lyr bitmap] height];
    const int l = ([[self->editInfo_ lastPos] x] - (w >> 1));
    const int t = ([[self->editInfo_ lastPos] y] - (h >> 1));
    const int r = (l + w - 1);
    const int b = (t + h - 1);

    if ([super isNotEditLayer]) {
        // 編集禁止レイヤー
        ;
    } else {
        // 以前の状態を破棄
        [self->shape_ release];
        self->shape_ = nil;
        [self->editState_ beginEditMode];

        // 座標を設定
        self->shape_ = [[PoCoSelectionShape alloc] init];
        p = [[PoCoPoint alloc] initX:l
                               initY:t];
        [self->shape_ addPoint:p];
        [p release];
        p = [[PoCoPoint alloc] initX:r
                               initY:t];
        [self->shape_ addPoint:p];
        [p release];
        p = [[PoCoPoint alloc] initX:r
                               initY:b];
        [self->shape_ addPoint:p];
        [p release];
        p = [[PoCoPoint alloc] initX:l
                               initY:b];
        [self->shape_ addPoint:p];
        [p release];
        [self->shape_ addPoint:nil];

        // 貼り付ける画像を進出(複写)
        [self->shape_ setImage:[[lyr bitmap] copy]];

        // 編集実行
        [super beginUndo:NO];           // 取り消し開始
        [self exec:edit_paste
            isCopy:YES];
        [super endUndo:NO];             // 取り消し終了

        // 選択範囲などを更新
        [self->editState_ setFirstPoint:[[self->shape_ resultRect] lefttop]];
        [self->editState_ setSecondPoint:[[self->shape_ resultRect] rightbot]];
        [self updateSelectionRect:[self->shape_ resultRect]];
        [self->prevRect_ release];
        self->prevRect_ = [PoCoDrawSelection expandForHalfOpen:[[PoCoRect alloc] initPoCoRect:[self->shape_ resultRect]]];

        // pointer 形状更新
        [[view window] invalidateCursorRectsForView:view];

        // ガイドライン表示
        [self drawGuideLine];
    }

    return;
}


//
// 削除
//
//  Call
//    document_ : 編集対象(基底 instance 変数)
//    shape_    : 範囲形状(instance 変数)
//
//  Return
//    None
//
-(void)delete
{
    if ([super isNotEditLayer]) {
        // 編集禁止レイヤー
        ;
    } else if ([[self->shape_ resultRect] empty]) {
        // 選択範囲が空なら何もしない
        ;
    } else {
        // ガイドライン消去
        [self drawGuideLine];

        // 編集実行
        [super beginUndo:NO];           // 取り消し開始
        [self->shape_ delete:self->document_
                withEditInfo:self->editInfo_];
        [self exec:edit_delete
            isCopy:YES];
        [super endUndo:NO];             // 取り消し終了

        // ガイドライン表示
        [self drawGuideLine];
    }

    return;
}


//
// flip image.
//
//  Call:
//    hori : flag, indicate which axis is applied to.
//           `YES` is horizonal.
//           `NO`  is vertical.
//
//  Return:
//    none.
//
- (void)flipImage:(BOOL)hori
{
    if ([super isNotEditLayer]) {
        // if layer is locked, then does not apply.
        ;
    } else if ([[self->shape_ resultRect] empty]) {
        // if selection shape is the empty, then do nothing.
        ;
    } else {
        // hide the guide line.
        [self drawGuideLine];

        // fix selection shape.
        if (([self->shape_ isCornerHandle]) || ([self->shape_ isEdgeHandle])) {
            [self->shape_ copyResultToOriginal];
            [self decideSelectionShape];
            [self updateSelectionRect:[self->shape_ resultRect]];
        }

        // execute the edit.
        [super beginUndo:NO];           // begin undo.
        [self->shape_ flip:hori];
        [self exec:((hori) ? edit_flip_hori : edit_flip_vert)
            isCopy:YES];
        [super endUndo:NO];             // end undo.

        // show the guide line.
        [self drawGuideLine];
    }

    return;
}


//
// auto gradient.
//
//  Call:
//    size      : size (0: free, 1 through 128: fixed).
//    adj       : flag, indicate whether apply to the adjacent colour only.
//                YES is the adjacent colour only.
//    mtx       : matrix of the target index colours (256 fixed array by BOOL.
//                YES means that the corresponding index is specified as target.
//    sizePair  : combining size with the index of a colour.
//    document_ : document.(base instance)
//    shape_    : selection shape.(instance)
//
//  Return:
//    none.
//
- (void)autoGrad:(int)size
      isAdjacent:(BOOL)adj
          matrix:(const BOOL *)mtx
    withSizePair:(NSDictionary *)sizePair
{
    if ([super isNotEditLayer]) {
        // if layer is locked, then does not apply.
        ;
    } else if ([[self->shape_ resultRect] empty]) {
        // if selection shape is the empty, then do nothing.
        ;
    } else {
        // hide the guide line.
        [self drawGuideLine];

        // fix selection shape.
        if (([self->shape_ isCornerHandle]) || ([self->shape_ isEdgeHandle])) {
            [self->shape_ copyResultToOriginal];
            [self decideSelectionShape];
            [self updateSelectionRect:[self->shape_ resultRect]];
        }

        // execute the edit.
        [super beginUndo:NO];           // begin undo.
        [self->shape_ autoGrad:self->document_
                       penSize:size
                    isAdjacent:adj
                        matrix:mtx
                  withSizePair:sizePair];
        [self exec:edit_autograd
            isCopy:YES];
        [super endUndo:NO];             // end undo.

        // show the guide line.
        [self drawGuideLine];
    }

    return;
}


//
// replace color.
//
//  Call:
//    mtx       : matrix for replacement (256 fixed array by unsigned char).
//    document_ : document.(base instance)
//    shape_    : selection shape.(instance)
//
//  Return:
//    none.
//
- (void)colorReplace:(const unsigned char *)mtx
{
    if ([super isNotEditLayer]) {
        // if layer is locked, then does not apply.
        ;
    } else if ([[self->shape_ resultRect] empty]) {
        // if selection shape is the empty, then do nothing.
        ;
    } else {
        // hide the guide line.
        [self drawGuideLine];

        // fix selection shape.
        if (([self->shape_ isCornerHandle]) || ([self->shape_ isEdgeHandle])) {
            [self->shape_ copyResultToOriginal];
            [self decideSelectionShape];
            [self updateSelectionRect:[self->shape_ resultRect]];
        }

        // execute the edit.
        [super beginUndo:NO];           // begin undo.
        [self->shape_ colorReplace:self->document_
                            matrix:mtx];
        [self exec:edit_colorreplace
            isCopy:YES];
        [super endUndo:NO];             // end undo.

        // show the guide line.
        [self drawGuideLine];
    }

    return;
}


//
// texture.
//
//  Call:
//    base : base colours (NSArray<unsigned int>).
//    grad : gradient colours (NSArray<unsinged int, NSArray<unsigned int> >).
//
//  Return:
//    none.
//
- (void)texture:(NSArray *)base
   withGradient:(NSArray *)grad
{
    if ([super isNotEditLayer]) {
        // if layer is locked, then does not apply.
        ;
    } else if ([[self->shape_ resultRect] empty]) {
        // if selection shape is the empty, then do nothing.
        ;
    } else {
        // hide the guide line.
        [self drawGuideLine];

        // fix selection shape.
        if (([self->shape_ isCornerHandle]) || ([self->shape_ isEdgeHandle])) {
            [self->shape_ copyResultToOriginal];
            [self decideSelectionShape];
            [self updateSelectionRect:[self->shape_ resultRect]];
        }

        // execute the edit.
        [super beginUndo:NO];           // begin undo.
        [self->shape_ texture:self->document_
                 withEditInfo:self->editInfo_
                   baseColors:base
               gradientColors:grad];
        [self exec:edit_texture
            isCopy:YES];
        [super endUndo:NO];             // end undo.

        // show the guide line.
        [self drawGuideLine];
    }

    return;
}


//
// 全選択
//
//  Call
//    None
//
//  Return
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    shape_     : 範囲形状(instance 変数)
//    prevImage_ : 以前の画像(全体)(instance 変数)
//    prevRect_  : 以前の範囲(外接長方形)(instance 変数)
//
-(void)selectAll
{
    PoCoView *view = [self->document_ view];
    PoCoPoint *p;
    PoCoRect *r;

    if ([super isNotEditLayer]) {
        // 編集禁止レイヤー
        ;
    } else {
        // 以前の内容を忘れる
        [self selectClear];
        [self->editState_ beginEditMode];

        // 選択範囲生成
        r = [[self->document_ picture] bitmapPoCoRect];
        self->shape_ = [[PoCoSelectionShape alloc] init];
        p = [[PoCoPoint alloc] initX:[r left]
                               initY:[r top]];
        [self->shape_ addPoint:p];
        [p release];
        p = [[PoCoPoint alloc] initX:([r right] - 1)
                               initY:[r top]];
        [self->shape_ addPoint:p];
        [p release];
        p = [[PoCoPoint alloc] initX:([r right] - 1)
                               initY:([r bottom] - 1)];
        [self->shape_ addPoint:p];
        [p release];
        p = [[PoCoPoint alloc] initX:[r left]
                               initY:([r bottom] - 1)];
        [self->shape_ addPoint:p];
        [p release];
        [self->shape_ addPoint:nil];
        [r release];

        // 選択範囲などを更新
        [self->editState_ setFirstPoint:[[self->shape_ resultRect] lefttop]];
        [self->editState_ setSecondPoint:[[self->shape_ resultRect] rightbot]];
        [self updateSelectionRect:[self->shape_ resultRect]];
        [self->prevRect_ release];
        self->prevRect_ = [PoCoDrawSelection expandForHalfOpen:[[PoCoRect alloc] initPoCoRect:[self->shape_ resultRect]]];
        [self->prevImage_ release];
        self->prevImage_ = [[[[self->document_ picture] layer:[[self->document_ selLayer] sel]] bitmap] copy];
        r = [PoCoDrawSelection expandForHalfOpen:[[PoCoRect alloc] initPoCoRect:[self->shape_ originalRect]]];
        [self->shape_ setImage:[self->prevImage_ getBitmap:r]];
        [r release];

        // pointer 形状更新
        [[view window] invalidateCursorRectsForView:view];

        // ガイドライン表示
        [self drawGuideLine];
    }

    return;
}


//
// 選択解除
//
//  Call
//    None
//
//  Return
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    shape_     : 範囲形状(instance 変数)
//    prevImage_ : 以前の画像(全体)(instance 変数)
//    prevPos_   : 以前の点(instance 変数)
//    prevRect_  : 以前の範囲(外接長方形)(instance 変数)
//
-(void)selectClear
{
    PoCoView *view = [self->document_ view];

    // ガイドライン消去
    if (self->shape_ != nil) {
        [self drawGuideLine];
    }

    // 以前の情報はすべて忘れる
    [self->editState_ endEditMode];
    [self->shape_ release];
    [self->prevImage_ release];
    [self->prevPos_ release];
    [self->prevRect_ release];
    self->shape_ = nil;
    self->prevImage_ = nil;
    self->prevPos_ = nil;
    self->prevRect_ = nil;

    // 選択範囲更新
    [self updateSelectionRect:nil];

    // pointer 形状更新
    [[view window] invalidateCursorRectsForView:view];

    return;
}


//
// 移動画像を再生成
//
//  Call
//    document_ : 編集対象(基底 instance 変数)
//
//  Return
//    shape_     : 範囲形状(instance 変数)
//    prevImage_ : 編集前の画像(instance 変数)
//
-(void)recreatePasteImage
{
    PoCoRect *r;
    PoCoBitmap *org;
    PoCoBitmap *bmp;

    if (self->shape_ != nil) {
        // 形状を複写
        [self->shape_ copyResultToOriginal];

        // 編集前の画像を差し替え
        [self->prevImage_ release];
        self->prevImage_ = [[[[self->document_ picture] layer:[[self->document_ selLayer] sel]] bitmap] copy];

        // 画像を取得
        r = [PoCoDrawSelection expandForHalfOpen:[[PoCoRect alloc] initPoCoRect:[self->shape_ originalRect]]];
        bmp = [self->prevImage_ getBitmap:r];
        [r release];

        // 変形前の画像を複製して取得した画像で上書き
        r = [[PoCoRect alloc]
                  initLeft:MAX(0, [[self->shape_ originalRect] left])
                   initTop:MAX(0, [[self->shape_ originalRect] top])
                 initRight:MIN([self->prevImage_ width], ([[self->shape_ originalRect] right] + 1))
                initBottom:MIN([self->prevImage_ height], ([[self->shape_ originalRect] bottom] + 1))];
        org = [[self->shape_ originalImage] copy];
        [org setBitmap:[bmp pixelmap]
              withRect:r];
        [r release];
        [bmp release];

        // 範囲形状に登録
        [self->shape_ setImage:org];
    }

    return;
}


// ----------------------------------------------------------------------------
// instance - public - assistance functions.

//
// Pointer 形状範囲更新
//
//  Call
//    document_ : 編集対象(基底 instance 変数)
//    editInfo_ : 編集情報(基底 instance 変数)
//    isDrag_   : ドラッグ中か(instance 変数)
//    shape_    : 範囲形状(instance 変数)
//
//  Return
//    None
//
-(void)updateCursorRect
{
    PoCoView *view = [self->document_ view];
    PoCoRect *r;
    const int gap = [view handleRectGap];

    // すべて解除
    [super updateCursorRect];

    if (self->shape_ != nil) {
        if (([self->shape_ originalImage] != nil) && (self->isDrag_)) {
            // 変形中
            r = [[self->document_ picture] bitmapPoCoRect];
            [view addCursorRect:[view toDispRect:r]
                         cursor:[NSCursor closedHandCursor]];
            [r release];
        } else if (([NSEvent modifierFlags] & NSCommandKeyMask) != 0x00) {
            // 塗り選択中は形状を変えない
            ;
        } else {
            // 選択範囲
            r = [PoCoDrawSelection expandForHalfOpen:[[PoCoRect alloc] initPoCoRect:[self->shape_ resultRect]]];
            [view addCursorRect:[view toDispRect:r]
                         cursor:[NSCursor openHandCursor]];
            [r release];

            if ([self->editInfo_ useHandle]) {
                // 左上
                r = [[PoCoRect alloc] initPoCoRect:[self->shape_ resultHandle:PoCoHandleType_corner_lt]];
                [r expand:gap];
                [view addCursorRect:[view toDispRect:r]
                             cursor:[NSCursor crosshairCursor]];
                [r release];

                // 上底
                r = [[PoCoRect alloc] initPoCoRect:[self->shape_ resultHandle:PoCoHandleType_edge_t]];
                [r expand:gap];
                [view addCursorRect:[view toDispRect:r]
                             cursor:[NSCursor crosshairCursor]];    
                [r release];

                // 右上
                r = [[PoCoRect alloc] initPoCoRect:[self->shape_ resultHandle:PoCoHandleType_corner_rt]];
                [r expand:gap];
                [view addCursorRect:[view toDispRect:r]
                             cursor:[NSCursor crosshairCursor]];
                [r release];

                // 右辺
                r = [[PoCoRect alloc] initPoCoRect:[self->shape_ resultHandle:PoCoHandleType_edge_r]];
                [r expand:gap];
                [view addCursorRect:[view toDispRect:r]
                             cursor:[NSCursor crosshairCursor]];    
                [r release];

                // 右下
                r = [[PoCoRect alloc] initPoCoRect:[self->shape_ resultHandle:PoCoHandleType_corner_rb]];
                [r expand:gap];
                [view addCursorRect:[view toDispRect:r]
                             cursor:[NSCursor crosshairCursor]];
                [r release];

                // 下底
                r = [[PoCoRect alloc] initPoCoRect:[self->shape_ resultHandle:PoCoHandleType_edge_b]];
                [r expand:gap];
                [view addCursorRect:[view toDispRect:r]
                             cursor:[NSCursor crosshairCursor]];    
                [r release];

                // 左下
                r = [[PoCoRect alloc] initPoCoRect:[self->shape_ resultHandle:PoCoHandleType_corner_lb]];
                [r expand:gap];
                [view addCursorRect:[view toDispRect:r]
                             cursor:[NSCursor crosshairCursor]];
                [r release];

                // 左辺
                r = [[PoCoRect alloc] initPoCoRect:[self->shape_ resultHandle:PoCoHandleType_edge_l]];
                [r expand:gap];
                [view addCursorRect:[view toDispRect:r]
                             cursor:[NSCursor crosshairCursor]];    
                [r release];
            }
        }
    }

    return;
}


//
// ガイドライン描画
//
//  Call
//    document_  : 編集対象(基底 instance 変数)
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    factory_   : 編集の生成部(基底 instance 変数)
//    isDrag_    : ドラッグ中か(instance 変数)
//    shape_     : 範囲形状(instance 変数)
//
//  Return
//    None
//
-(void)drawGuideLine
{
    const int idx = [[self->document_ selLayer] sel];
    const int gap = [[self->document_ view] handleRectGap];
    PoCoRect *r;
    PoCoPoint *p;
    PoCoCreateStyleMask *mask;

    if ([self->editState_ hasSecondPoint]) {
        if ([self->shape_ originalImage] == nil) {
            // 範囲生成中
            if ([self->editInfo_ continuationType]) {
                // 任意形状
                [self->factory_ createInvertPolylineEditter:YES
                                                      layer:idx
                                                       poly:[self->shape_ originalPoints]];
            } else {
                // 矩形形状
                [self->factory_ createInvertPolygonEditter:YES
                                                     layer:idx
                                                      poly:[self->shape_ originalPoints]];
            }
        } else if (([self->shape_ resultRect] != nil) &&
                   (!([[self->shape_ resultRect] empty]))) {
            // 範囲確定
            if (([self->editInfo_ selectionFill]) &&
                ([self->shape_ resultShape] != nil)) {
                // 塗りつぶし
                [self->factory_ createInvertBoxEditter:YES
                                                 layer:idx
                                                 start:[[self->shape_ resultRect] lefttop]
                                                   end:[[self->shape_ resultRect] rightbot]
                                           orientation:nil];
                [self->factory_ createInvertRegionFillEditter:YES
                                                        layer:idx
                                                         rect:[self->shape_ resultRect]
                                                         mask:[self->shape_ resultShape]];
            } else if (([self->shape_ resultShape] != nil) &&
                       (([self->shape_ resultPoints] == nil) ||
                        ([[self->shape_ resultPoints] count] == 0))) {
                // 塗りつぶしの境界
                p = [[PoCoPoint alloc] initX:([[self->shape_ resultRect] right] - 1)
                                       initY:([[self->shape_ resultRect] bottom] - 1)];
                [self->factory_ createInvertBoxEditter:YES
                                                 layer:idx
                                                 start:[[self->shape_ resultRect] lefttop]
                                                   end:p
                                           orientation:nil];
                [p release];
                [self->factory_ createInvertRegionBorderEditter:YES
                                                          layer:idx
                                                           rect:[self->shape_ resultRect]
                                                           mask:[self->shape_ resultShape]];
            } else {
                // 枠
                [self->factory_ createInvertBoxEditter:YES
                                                 layer:idx
                                                 start:[[self->shape_ resultRect] lefttop]
                                                   end:[[self->shape_ resultRect] rightbot]
                                           orientation:nil];
                if (!([self->shape_ isSameStyleResultRectShape])) {
                    [self->factory_ createInvertPolygonEditter:YES
                                                         layer:idx
                                                          poly:[self->shape_ resultPoints]];
                }
            }

            // ハンドル
            if ([self->editInfo_ useHandle]) {
                mask = [[PoCoCreateStyleMask alloc] init];
                if (self->isDrag_) {
#if 0
                    // つかんでいるハンドル
                    r = [[PoCoRect alloc] initPoCoRect:[self->shape_ controlHandle]];
                    if (!([r empty])) {
                        [r expand:gap];
                        if ([mask box:[r lefttop]
                                  end:[r rightbot]
                          orientation:nil
                           isDiagonal:NO]) {
                            [self->factory_ createInvertRegionFillEditter:YES
                                                                    layer:idx
                                                                     rect:r
                                                                     mask:[mask mask]];
                        }
                    }
                    [r release];
#else   // 0
                    // 変形中は何もしない
                    ;
#endif  // 0
                } else {
                    // 左上
                    r = [[PoCoRect alloc] initPoCoRect:[self->shape_ resultHandle:PoCoHandleType_corner_lt]];
                    [r expand:gap];
                    if ([mask box:[r lefttop]
                              end:[r rightbot]
                      orientation:nil
                       isDiagonal:NO]) {
                        [self->factory_ createInvertRegionFillEditter:YES
                                                                layer:idx
                                                                 rect:r
                                                                 mask:[mask mask]];
                    }
                    [r release];

                    // 上底
                    r = [[PoCoRect alloc] initPoCoRect:[self->shape_ resultHandle:PoCoHandleType_edge_t]];
                    [r expand:gap];
                    if ([mask box:[r lefttop]
                              end:[r rightbot]
                      orientation:nil
                       isDiagonal:NO]) {
                        [self->factory_ createInvertRegionFillEditter:YES
                                                                layer:idx
                                                                 rect:r
                                                                 mask:[mask mask]];
                    }
                    [r release];

                    // 右上
                    r = [[PoCoRect alloc] initPoCoRect:[self->shape_ resultHandle:PoCoHandleType_corner_rt]];
                    [r expand:gap];
                    if ([mask box:[r lefttop]
                              end:[r rightbot]
                      orientation:nil
                       isDiagonal:NO]) {
                        [self->factory_ createInvertRegionFillEditter:YES
                                                                layer:idx
                                                                 rect:r
                                                                 mask:[mask mask]];
                    }
                    [r release];

                    // 右辺
                    r = [[PoCoRect alloc] initPoCoRect:[self->shape_ resultHandle:PoCoHandleType_edge_r]];
                    [r expand:gap];
                    if ([mask box:[r lefttop]
                              end:[r rightbot]
                      orientation:nil
                       isDiagonal:NO]) {
                        [self->factory_ createInvertRegionFillEditter:YES
                                                                layer:idx
                                                                 rect:r
                                                                 mask:[mask mask]];
                    }
                    [r release];

                    // 右下
                    r = [[PoCoRect alloc] initPoCoRect:[self->shape_ resultHandle:PoCoHandleType_corner_rb]];
                    [r expand:gap];
                    if ([mask box:[r lefttop]
                              end:[r rightbot]
                      orientation:nil
                       isDiagonal:NO]) {
                        [self->factory_ createInvertRegionFillEditter:YES
                                                                layer:idx
                                                                 rect:r
                                                                 mask:[mask mask]];
                    }
                    [r release];

                    // 下底
                    r = [[PoCoRect alloc] initPoCoRect:[self->shape_ resultHandle:PoCoHandleType_edge_b]];
                    [r expand:gap];
                    if ([mask box:[r lefttop]
                              end:[r rightbot]
                      orientation:nil
                       isDiagonal:NO]) {
                        [self->factory_ createInvertRegionFillEditter:YES
                                                                layer:idx
                                                                 rect:r
                                                                 mask:[mask mask]];
                    }
                    [r release];

                    // 左下
                    r = [[PoCoRect alloc] initPoCoRect:[self->shape_ resultHandle:PoCoHandleType_corner_lb]];
                    [r expand:gap];
                    if ([mask box:[r lefttop]
                              end:[r rightbot]
                      orientation:nil
                       isDiagonal:NO]) {
                        [self->factory_ createInvertRegionFillEditter:YES
                                                                layer:idx
                                                                 rect:r
                                                                 mask:[mask mask]];
                    }
                    [r release];

                    // 左辺
                    r = [[PoCoRect alloc] initPoCoRect:[self->shape_ resultHandle:PoCoHandleType_edge_l]];
                    [r expand:gap];
                    if ([mask box:[r lefttop]
                              end:[r rightbot]
                      orientation:nil
                       isDiagonal:NO]) {
                        [self->factory_ createInvertRegionFillEditter:YES
                                                                layer:idx
                                                                 rect:r
                                                                 mask:[mask mask]];
                    }
                    [r release];
                }
                [mask release];
            }
        }
    }

    return;
}


//
// 編集状態解除
//
//  Call
//    editInfo_ : 編集情報(基底 instance 変数)
//
//  Return
//    None
//
-(void)cancelEdit
{
    if (!([[self->editInfo_ selRect] empty])) {
        [self selectClear];
    }

    return;
}


//
// 変形前画像
//
//  Call
//    shape_ : 範囲形状(instance 変数)
//
//  Return
//    function : 画像
//
-(PoCoBitmap *)originalImage
{
    return [self->shape_ originalImage];
}


//
// 変形前形状
//
//  Call
//    shape_ : 範囲形状(instance 変数)
//
//  Return
//    function : 形状 
//
-(PoCoBitmap *)originalShape
{
    return [self->shape_ originalShape];
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


// ----------------------------------------------------------------------------
// instance - public - event handlers.

//
// 主ボタンダウン
//
//  Call
//    evt        : 取得イベント
//    editInfo_  : 編集情報(基底 instance 変数)
//
//  Return
//    editInfo_  : 編集情報(基底 instance 変数)
//    isPaint_   : 塗り選択中か(instance 変数)
//    shape_     : 範囲形状(instance 変数)
//    prevImage_ : 以前の画像(全体)(instance 変数)
//    prevPos_   : 以前の点(instance 変数)
//    prevRect_  : 以前の範囲(外接長方形)(instance 変数)
//
-(void)mouseDown:(NSEvent *)evt
{
    BOOL create;

    if ([super isNotEditLayer]) {
        // 編集禁止レイヤー
        ;
    } else {
        if (([evt modifierFlags] & NSCommandKeyMask) != 0x00) {
            // 塗り選択
            self->isPaint_ = YES;
            if (self->shape_ != nil) {
                // ガイドライン消去
                [self drawGuideLine];
            }
            if ((([evt modifierFlags] & NSShiftKeyMask) != 0x00) &&
                ([self->shape_ resultRect] != nil) &&
                (!([[self->shape_ resultRect] empty]))) {
                // 結合
                [self->shape_ seedJoin:[self->editInfo_ pdPos]
                                bitmap:[[[self->document_ picture] layer:[[self->document_ selLayer] sel]] bitmap]
                              isBorder:(([evt modifierFlags] & NSControlKeyMask) != 0x00)
                            colorRange:(([self->editInfo_ continuationType]) ? [self->editInfo_ colorRange] : 0)];
            } else if (([evt modifierFlags] & NSAlternateKeyMask) != 0x00) {
                // 分離
                [self->shape_ seedSeparate:[self->editInfo_ pdPos]
                                    bitmap:[[[self->document_ picture] layer:[[self->document_ selLayer] sel]] bitmap]
                                  isBorder:(([evt modifierFlags] & NSControlKeyMask) != 0x00)
                                colorRange:(([self->editInfo_ continuationType]) ? [self->editInfo_ colorRange] : 0)];
            } else {
                // 範囲生成開始
                [self initSelectionShape];
                [self->shape_ seedNew:[self->editInfo_ pdPos]
                               bitmap:[[[self->document_ picture] layer:[[self->document_ selLayer] sel]] bitmap]
                             isBorder:(([evt modifierFlags] & NSControlKeyMask) != 0x00)
                           colorRange:(([self->editInfo_ continuationType]) ? [self->editInfo_ colorRange] : 0)];
            }
        } else if ([self->shape_ startTrans:[self->editInfo_ pdPos]
                                  handleGap:([self->editInfo_ useHandle]) ? [[self->document_ view] handleRectGap] : -(HANDLE_GAP << 1)
                                  withShape:NO]) {
            // 変形開始(選択範囲内、ないしハンドル)
            create = NO;
            if (([PoCoSelectionShape isInner:self->prevHandle_]) &&
                ([PoCoSelectionShape isInner:self->prevHandle_] == [self->shape_ isInnerHandle])) {
                // 移動を継続するので形状などはそのまま
                ;
            } else if (([PoCoSelectionShape isCorner:self->prevHandle_]) &&
                       ([PoCoSelectionShape isCorner:self->prevHandle_] == [self->shape_ isCornerHandle])) {
                if (self->prevHandle_ == [self->shape_ controlHandle]) {
                    // 同じハンドルなので形状などはそのまま
                    ;
                } else {
                    // 違うハンドルなので形状確定
                    create = YES;
                }
            } else if (([PoCoSelectionShape isEdge:self->prevHandle_]) &&
                       ([PoCoSelectionShape isEdge:self->prevHandle_] == [self->shape_ isEdgeHandle])) {
                // 回転は毎回ごとに確定
                create = YES;
            } else {
                // 違う操作系になるので形状確定
                create = YES;
            }
            if (create) {
                // ガイドライン消去
                [self drawGuideLine];

                // 生成(結果を複製)
                [self->shape_ copyResultToOriginal];
                [self->shape_ setImage:[[self->shape_ resultImage] copy]];

#if 0   // 明示的な複写を指示されるまでは最初の状態を維持する
                // 変形前の画像(全体)を再取得
                [self->prevImage_ release];
                self->prevImage_ = [[[[self->document_ picture] layer:[[self->document_ selLayer] sel]] bitmap] copy];
#endif  // 0

                // ガイドライン描画
                [self drawGuideLine];
            }

            // 編集開始
            [self->prevRect_ release];
            self->prevRect_ = [PoCoDrawSelection expandForHalfOpen:[[PoCoRect alloc] initPoCoRect:[self->shape_ resultRect]]];

            // 取り消し開始(取り消し群にする)
            [super beginUndo:YES];
        } else {
            // 選択範囲外ないし初回
            if (self->shape_ != nil) {
                // ガイドライン消去
                [self drawGuideLine];
            }

            // 範囲生成開始
            [self initSelectionShape];
            self->prevPos_ = [[PoCoPoint alloc]
                                 initX:[[self->editInfo_ pdPos] x]
                                 initY:[[self->editInfo_ pdPos] y]];
            [self->shape_ addPoint:self->prevPos_];
        }
        self->prevHandle_ = [self->shape_ controlHandle];
    }

    return;
}


//
// 主ボタンドラッグ
//
//  Call
//    evt        : 取得イベント
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    prevPos_   : 以前の点(instance 変数)
//
//  Return
//    editInfo_  : 編集情報(基底 instance 変数)
//    editState_ : 編集の状態遷移(基底 instance 変数)
//    isDrag_    : ドラッグ中か(instance 変数)
//    isPaint_   : 塗り選択中か(instance 変数)
//    shape_     : 範囲形状(instance 変数)
//    prevPos_   : 以前の点(instance 変数)
//
-(void)mouseDrag:(NSEvent *)evt
{
    PoCoView *view = [self->document_ view];
    PoCoPoint *p;

    if (self->shape_ != nil) {
        if (self->isPaint_) {
            // 塗り選択中は何もしない
            ;
        } else {
            // ガイドライン消去
            [self drawGuideLine];

            // ドラッグ中に入る
            self->isDrag_ = YES;

            // 形状作成
            if ([self->shape_ isOuterHandle]) {
                // 範囲生成
                [self->editState_ setSecondPoint:nil];
                if (([self->prevPos_ x] != [[self->editState_ secondPoint] x]) ||
                    ([self->prevPos_ y] != [[self->editState_ secondPoint] y])) {
                        if ([self->editInfo_ continuationType]) {
                        [self->shape_ addPoint:[self->editState_ secondPoint]];
                    } else {
                        [self->shape_ clearOriginal];
                        [self->shape_ addPoint:[self->editState_ firstPoint]];
                        if ((([[self->editState_ firstPoint] x] < [[self->editState_ secondPoint] x]) &&
                             ([[self->editState_ firstPoint] y] < [[self->editState_ secondPoint] y])) ||
                            (([[self->editState_ firstPoint] x] >= [[self->editState_ secondPoint] x]) &&
                             ([[self->editState_ firstPoint] y] >= [[self->editState_ secondPoint] y]))) {
                            p = [[PoCoPoint alloc] initX:[[self->editState_ firstPoint] x]
                                                   initY:[[self->editState_ secondPoint] y]];
                            [self->shape_ addPoint:p];
                            [p release];
                            p = [[PoCoPoint alloc] initX:[[self->editState_ secondPoint] x]
                                                   initY:[[self->editState_ secondPoint] y]];
                            [self->shape_ addPoint:p];
                            [p release];
                            p = [[PoCoPoint alloc] initX:[[self->editState_ secondPoint] x]
                                                   initY:[[self->editState_ firstPoint] y]];
                            [self->shape_ addPoint:p];
                            [p release];
                        } else {
                            p = [[PoCoPoint alloc] initX:[[self->editState_ secondPoint] x]
                                                   initY:[[self->editState_ firstPoint] y]];
                            [self->shape_ addPoint:p];
                            [p release];
                            p = [[PoCoPoint alloc] initX:[[self->editState_ secondPoint] x]
                                                   initY:[[self->editState_ secondPoint] y]];
                            [self->shape_ addPoint:p];
                            [p release];
                            p = [[PoCoPoint alloc] initX:[[self->editState_ firstPoint] x]
                                                   initY:[[self->editState_ secondPoint] y]];
                            [self->shape_ addPoint:p];
                            [p release];
                        }
                    }
                    [self->prevPos_ setX:[[self->editState_ secondPoint] x]
                                    setY:[[self->editState_ secondPoint] y]];
                }

                // 選択範囲更新
                [self updateSelectionRect:[self->shape_ originalRect]];
            } else {
                // 範囲変形
                [self->shape_ runningTrans:[self->editInfo_ pdPos]
                                 withEvent:evt
                         isLiveUpdateShape:[self->editInfo_ selectionFill]
                        isLiveUpdateResult:[self->editInfo_ liveEditSelection]];

                // 選択範囲更新
                [self updateSelectionRect:[self->shape_ resultRect]];

                // 結果を逐次表示
                if ([self->editInfo_ liveEditSelection]) {
                    if (([self->shape_ resultRect] != nil) &&
                        (!([[self->shape_ resultRect] empty])) &&
                        ([self->shape_ resultShape] != nil)) {
                        // 編集
                        [self exec:edit_withHandle
                            isCopy:NO];
                        [self->prevRect_ release];
                        self->prevRect_ = [PoCoDrawSelection expandForHalfOpen:[[PoCoRect alloc] initPoCoRect:[self->shape_ resultRect]]];
                    }
                }
            }

            // pointer 形状更新
            [[view window] invalidateCursorRectsForView:view];

            // ガイドライン描画
            [self drawGuideLine];
        }
    }

    return;
}


//
// 主ボタンリリース
//
//  Call
//    evt       : 取得イベント
//    document_ : 編集対象(基底 instance 変数)
//    isCopy_   : 複写指定(instance 変数)
//
//  Return
//    isDrag_   : ドラッグ中か(instance 変数)
//    isPaint_  : 塗り選択中か(instance 変数)
//    shape_    : 範囲形状(instance 変数)
//    prevPos_  : 以前の点(instance 変数)
//
-(void)mouseUp:(NSEvent *)evt
{
    PoCoView *view = [self->document_ view];

    if (self->shape_ != nil) {
        if (self->isPaint_) {
            // 塗り選択中なので範囲内画像を取得
            self->isPaint_ = NO;
            [self decideSelectionShape];
        } else {
            // ドラッグ中を外れる
            self->isDrag_ = NO;

            // ガイドライン消去
            [self drawGuideLine];

            // 確定
            if ([self->shape_ isOuterHandle]) {
                // 選択範囲
                [self->shape_ addPoint:nil];
                if ([[self->shape_ resultRect] empty]) {
                    // 範囲をとれていないので却下
                    [self->editState_ endEditMode];
                    [self->shape_ release];
                    [self->prevPos_ release];
                    self->shape_ = nil;
                    self->prevPos_ = nil;
                } else {
                    // 範囲内画像を取得
                    [self decideSelectionShape];
                }
            } else if (!([[self->shape_ resultRect] empty])) {
                // 編集
                [self->shape_ endTrans];

                // 編集実行
                [self exec:edit_withHandle
                    isCopy:((self->isCopy_) ||
                            (([evt modifierFlags] & NSControlKeyMask) != 0x00))];

                // 取り消し終了(取り消し群にする)
                [super endUndo:YES];
            }
        }

        // ガイドライン表示
        [self drawGuideLine];

        // 選択範囲更新
        [self updateSelectionRect:[self->shape_ resultRect]];

        // pointer 形状更新
        [[view window] invalidateCursorRectsForView:view];
    }

    return;
}


//
// 副ボタンダウン
//
//  Call
//    evt     : 取得イベント
//    isDrag_ : ドラッグ中か(instance 変数)
//
//  Return
//    isCopy_ : 複写指定(instance 変数)
//
-(void)rightMouseDown:(NSEvent *)evt
{
    if (self->isDrag_) {
        // 複写指定
        self->isCopy_ = YES;
    } else {
        // 色吸い取り
        [self drawGuideLine];
        [super dropper];
        [self drawGuideLine];
    }

    return;
}


//
// 副ボタンリリース
//
//  Call
//    evt : 取得イベント
//
//  Return
//    isCopy_ : 複写指定(instance 変数)
//
-(void)rightMouseUp:(NSEvent *)evt
{
    // 複写指定解除
    self->isCopy_ = NO;

    return;
}


//
// キーダウン
//
//  Call
//    evt     : 取得イベント
//    isDrag_ : ドラッグ中か(instance 変数)
//    shape_  : 範囲形状(instance 変数)
//
//  Return
//    prevRect_ : 移動元の矩形枠(instance 変数)
//
-(void)keyDown:(NSEvent *)evt
{
    PoCoView *view = [self->document_ view];
    PoCoPoint *p;
    PoCoPoint *cp;
    int gap;

    if (self->isDrag_) {
        // ドラッグ中は何もしない
        ;
    } else if (self->shape_ != nil) {
        if ([evt keyCode] == kVK_Delete) {
            // 削除
            [self delete];
        } else {
            // 移動
            if (([evt modifierFlags] & NSAlternateKeyMask) != 0x00) {
                gap = 1;
            } else {
                gap = MAX(1, [[self->document_ view] handleRectGap]);
            }
            if (([evt modifierFlags] & NSShiftKeyMask) != 0x00) {
                gap *= 5;
            }
            cp = [[self->shape_ originalHandle:PoCoHandleType_center] lefttop];
            p = [[PoCoPoint alloc] initX:[cp x]
                                   initY:[cp y]];
            switch ([evt keyCode]) {
                case kVK_UpArrow:
                    // 上
                    [p moveY:-(gap)];
                    break;
                case kVK_RightArrow:
                    // 右
                    [p moveX:gap];
                    break;
                case kVK_DownArrow:
                    // 下
                    [p moveY:gap];
                    break;
                case kVK_LeftArrow:
                    // 左
                    [p moveX:-(gap)];
                    break;
                default:
                    // 他は何もしない
                    ;
                    break;
            }
            if (!([cp isEqualPos:p])) {
                // ハンドル判定(-HANDLE_GAP: 四方・四隅となるのを打ち消すため)
                if ([self->shape_ startTrans:cp
                                   handleGap:-(HANDLE_GAP << 1)
                                   withShape:NO]) {
                    // ガイドライン消去
                    [self drawGuideLine];

                    // 元の矩形枠を更新
                    [self->prevRect_ release];
                    self->prevRect_ = [PoCoDrawSelection expandForHalfOpen:[[PoCoRect alloc] initPoCoRect:[self->shape_ resultRect]]];

                    // 結果を複製
                    [self->shape_ copyResultToOriginal];
                    [self->shape_ setImage:[[self->shape_ resultImage] copy]];

                    // 編集(単発なので取り消し群ではない)
                    [super beginUndo:NO];   // 取り消し開始
                    [self->shape_ runningTrans:p
                                     withEvent:nil
                             isLiveUpdateShape:NO
                            isLiveUpdateResult:NO];
                    [self->shape_ endTrans];
                    [self exec:edit_key_move
                        isCopy:(([evt modifierFlags] & NSControlKeyMask) != 0x00)];
                    [super endUndo:NO];     // 取り消し終了

                    // 選択範囲更新
                    [self updateSelectionRect:[self->shape_ resultRect]];

                    // pointer 形状更新
                    [[view window] invalidateCursorRectsForView:view];

                    // ガイドライン表示
                    [self drawGuideLine];
                }
            }
            [p release];
        }
    }

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
    // とりあえず、まだ何もしない
    ;

    return;
}


//
// マウス移動
//
//  Call
//    evt       : 取得イベント
//    document_ : 編集対象(基底 instance 変数)
//    shape_    : 範囲形状(instance 変数)
//    modify_   : 修飾キー(instance 変数)
//
//  Return
//    modify_ : 修飾キー(instance 変数)
//
-(void)mouseMove:(NSEvent *)evt
{
    PoCoView *view = [self->document_ view];

    if (self->shape_ != nil) {
        // 修飾キーの状態が違う場合に cursor 形状変更
        if (self->modify_ != (unsigned int)([NSEvent modifierFlags])) {
            [[view window] invalidateCursorRectsForView:view];
        }

        // 現状の指定を覚える
        self->modify_ = (unsigned int)([NSEvent modifierFlags]);
    }

    return;
}

@end
