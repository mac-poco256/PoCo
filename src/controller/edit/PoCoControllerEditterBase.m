//
//	Pelistina on Cocoa - PoCo -
//	描画部基底
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoControllerEditterBase.h"

#import "PoCoControllerFactory.h"
#import "PoCoControllerPictureBitmapReplacer.h"

#import "PoCoCalcCurveWithPoints.h"
#import "PoCoCalcRotation.h"

// ============================================================================
@implementation PoCoControllerEditterBase

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict   : 編集対象画像
//    info   : 編集情報
//    undo   : 取り消し情報
//    eraser : 消しゴム用画像
//    buf    : 色保持情報
//    pen    : ペン先
//    tile   : タイルパターン
//    idx    : 対象レイヤー番号
//
//  Return
//    function       : 実体
//    penStyle_      : ペン先(instance 変数)
//    tilePattern_   : タイルパターン(instance 変数)
//    eraserPattern_ : 消しゴム用画像(instance 変数)
//    colorBuffer_   : 色保持情報(instance 変数)
//    index_         : 対象レイヤー番号(instance 変数)
//    layer_         : 対象レイヤー(instance 変数)
//    drawRect_      : 再描画領域(instance 変数)
//    undoRect_      : 取り消し領域(instance 変数)
//    undoBitmap_    : 取り消し画像(instance 変数)
//    drawPattern_   : 描画パターン(instance 変数)
//    drawPen_       : 使用ペン先(instance 変数)
//    drawTile_      : 使用タイルパターン(instance 変数)
//
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
      withPen:(PoCoPenStyle *)pen
     withTile:(PoCoTilePattern *)tile
      atIndex:(int)idx
{
//    DPRINT((@"[PoCoControllerEditterBase init]\n"));

    // super class を初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo];

    // 自身を初期化
    if (self != nil) {
        self->penStyle_ = pen;
        self->tilePattern_ = tile;
        self->eraserPattern_ = eraser;
        self->colorBuffer_ = buf;
        self->index_ = idx;
        self->layer_ = nil;
        self->drawRect_ = nil;
        self->undoRect_ = nil;
        self->undoBitmap_ = nil;
        self->drawPattern_ = nil;
        self->drawPen_ = nil;
        self->drawTile_ = nil;

        // 各基底情報を retain
        [self->penStyle_ retain];
        [self->tilePattern_ retain];
        [self->eraserPattern_ retain];
        [self->colorBuffer_ retain];

        // 対象レイヤーを取得
        self->layer_ = [self->picture_ layer:self->index_];
        if (self->layer_ != nil) {
            [self->layer_ retain];
        } else {
            DPRINT((@"can't get target layer.\n"));
            [self release];
            self = nil;
        }
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
//    penStyle_      : ペン先(instance 変数)
//    tilePattern_   : タイルパターン(instance 変数)
//    eraserPattern_ : 消しゴム用画像(instance 変数)
//    colorBuffer_   : 色保持情報(instance 変数)
//    layer_         : 対象レイヤー(instance 変数)
//    drawRect_      : 再描画領域(instance 変数)
//    undoRect_      : 取り消し領域(instance 変数)
//    undoBitmap_    : 取り消し画像(instance 変数)
//    drawPattern_   : 描画パターン(instance 変数)
//    drawPen_       : 使用ペン先(instance 変数)
//    drawTile_      : 使用タイルパターン(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerEditterBase dealloc]\n"));

    // 資源を解放
    [self->penStyle_ release];
    [self->tilePattern_ release];
    [self->eraserPattern_ release];
    [self->colorBuffer_ release];
    [self->layer_ release];
    [self->drawRect_ release];
    [self->undoRect_ release];
    [self->undoBitmap_ release];
    [self->drawPattern_ release];
    [self->drawPen_ release];
    [self->drawTile_ release];
    self->penStyle_ = nil;
    self->tilePattern_ = nil;
    self->eraserPattern_ = nil;
    self->colorBuffer_ = nil;
    self->layer_ = nil;
    self->drawRect_ = nil;
    self->undoRect_ = nil;
    self->undoBitmap_ = nil;
    self->drawPattern_ = nil;
    self->drawPen_ = nil;
    self->drawTile_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// 範囲の補正(画像範囲内に抑制)
//
//  Call
//    r        : 矩形枠
//    picture_ : 編集対象画像(基底 instance 変数)
//
//  Return
//    r : 矩形枠
//
-(void)correctRect:(PoCoRect *)r
{
    PoCoRect *pr;

    pr = [self->picture_ bitmapPoCoRect];
    if ([r left] < [pr left]) {
        [r setLeft:[pr left]];
    }
    if ([r right] >= [pr right]) {
        [r setRight:[pr right]];
    }
    if ([r top] < [pr top]) {
        [r setTop:[pr top]];
    }
    if ([r bottom] >= [pr bottom]) {
        [r setBottom:[pr bottom]];
    }
    [pr release];

    return;
}


//
// 編集開始
//  多重呼び出し禁止(そもそも多重に呼ぶような実装にはならないはず)
//
//  Call
//    dr             : 再描画領域
//    un             : 取り消し領域
//    picture_       : 編集対象画像(基底 instance 変数)
//    editInfo_      : 編集情報(基底 instance 変数)
//    eraserPattern_ : 消しゴム用画像(instance 変数)
//    index_         : 対象レイヤー番号(instance 変数)
//    layer_         : 対象レイヤー(instance 変数)
//
//  Return
//    function     : 可否
//    penStyle_    : ペン先(instance 変数)
//    tilePattern_ : タイルパターン(instance 変数)
//    drawRect_    : 再描画領域(instance 変数)
//    undoRect_    : 取り消し領域(instance 変数)
//    undoBitmap_  : 取り消し画像(instance 変数)
//    drawPattern_ : 描画パターン(instance 変数)
//    drawPen_     : 使用ペン先(instance 変数)
//    drawTile_    : 使用タイルパターン(instance 変数)
//
-(BOOL)startEdit:(PoCoRect *)dr
    withUndoRect:(PoCoRect *)ur
{
    PoCoSelColor *selColor;             // 選択色情報

    // 領域を記憶
    self->drawRect_ = dr;
    self->undoRect_ = ur;
    [self->drawRect_ retain];
    [self->undoRect_ retain];

    // 取り消し用画像を取得
    if ([self->editInfo_ enableUndo]) {
        self->undoBitmap_ = [[self->layer_ bitmap] getBitmap:self->undoRect_];
    }           

    // 使用ペン先を選別
    if (self->penStyle_ != nil) {
        self->drawPen_ = [self->penStyle_ pattern:[self->editInfo_ penNumber]];
        [self->drawPen_ retain];
    }

    // 使用タイルパターンを選別
    if (self->tilePattern_ != nil) {
        self->drawTile_ = [self->tilePattern_ pattern:[self->editInfo_ tileNumber]];
        [self->drawTile_ retain];
    }

    // 描画パターンを選別
    selColor = [self->editInfo_ selColor];
    if (([self->editInfo_ eraserType]) && (self->eraserPattern_ != nil)) {
        // 以前の画像を使用(alloc はしないので retain しておく)
        self->drawPattern_ = self->eraserPattern_;
        [self->drawPattern_ retain];
    } else if (([selColor isUnder]) && (self->index_ > 0)) {
        // 背面レイヤーを使用
        self->drawPattern_ = [[PoCoColorPattern alloc]
                                 initWithBitmap:[[self->picture_ layer:(self->index_ - 1)] bitmap]];
    } else if ([selColor isPattern]) {
        // カラーパターンを使用(alloc はしないので retain しておく)
        self->drawPattern_ = [self->picture_ colpat:[selColor num]];
        [self->drawPattern_ retain];
    } else {
        // 通常の色を使用
        self->drawPattern_ = [[PoCoColorPattern alloc]
                                    initWidth:1
                                   initHeight:1
                                 defaultColor:[selColor num]];
    }

    return YES;                         // 常時 YES
}


//
// 編集終了
//
//  Call    
//    name         : 取り消し名称文字列
//    undoManager_ : 取り消し情報(基底 instance 変数)
//    factory_     : 編集部の生成部(基底 instance 変数)
//    index_       : 対象レイヤー番号(instance 変数)
//    drawRect_    : 再描画領域(instance 変数)
//    undoRect_    : 取り消し領域(instance 変数)
//    undoBitmap_  : 取り消し画像(instance 変数)
//
//  Return  
//    undoManager_ : 取り消し情報(基底 instance 変数)
//          
-(void)endEdit:(NSString *)name
{
    // 取り消しを登録
    if (self->undoBitmap_ != nil) {
        [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
            createPictureBitmapReplacer:YES
                                  layer:self->index_
                                   rect:self->undoRect_
                                 bitmap:self->undoBitmap_
                                   name:name];
        [super setUndoName:name];
    }

    // 編集通知
    [self postNotify:self->drawRect_];

    return;
}


//
// 編集通知
//
//  Call    
//    r      : 再描画領域
//    index_ : 対象レイヤー番号(instance 変数)
//
//  Return  
//    None
//
-(void)postNotify:(PoCoRect *)r
{
    PoCoEditPictureNotification *note;

    note = [[PoCoEditPictureNotification alloc] initWithRect:r
                                                     atIndex:self->index_];
    [[NSNotificationCenter defaultCenter] postNotificationName:PoCoEditPicture
                                                        object:note];
    [note release];

    return;
}


//
// 編集通知
//  undo を伴わない場合用
//
//  Call    
//    r      : 再描画領域
//    index_ : 対象レイヤー番号(instance 変数)
//
//  Return  
//    None
//
-(void)postNotifyNoEdit:(PoCoRect *)r
{
    PoCoEditPictureNotification *note;

    note = [[PoCoEditPictureNotification alloc] initWithRect:r
                                                     atIndex:self->index_];
    [[NSNotificationCenter defaultCenter] postNotificationName:PoCoRedrawPicture
                                                        object:note];
    [note release];

    return;
}

@end




// ============================================================================
@implementation PoCoControllerBoxEditterBase

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict   : 編集対象画像
//    info   : 編集情報
//    undo   : 取り消し情報
//    eraser : 消しゴム用画像
//    buf    : 色保持情報
//    pen    : ペン先
//    tile   : タイルパターン
//    s      : 描画始点(中心点)
//    e      : 描画終点(中心点)
//    o      : 方向点
//    idx    : 対象レイヤー番号
//
//  Return
//    function  : 実体
//    startPos_ : 描画始点(中心点)(instance 変数)
//    endPos_   : 描画終点(中心点)(instance 変数)
//    ortPos_   : 方向点(instance 変数)
//    diagonal_ : 回転で対角を使用(instance 変数)
//
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
      withPen:(PoCoPenStyle *)pen
     withTile:(PoCoTilePattern *)tile
    withStart:(PoCoPoint *)s
      withEnd:(PoCoPoint *)e
  ifAnyOrient:(PoCoPoint *)o
      atIndex:(int)idx;
{
//    DPRINT((@"[PoCoControllerBoxEditterBase init]\n"));

    // super class を初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:buf
                   withPen:pen
                  withTile:tile
                   atIndex:idx];

    // 自身を初期化
    if (self != nil) {
        self->diagonal_ = NO;

        // 点を複製(左上、右下の配置を維持する)
        self->startPos_ = [[PoCoPoint alloc] initX:MIN([s x], [e x])
                                             initY:MIN([s y], [e y])];
        self->endPos_   = [[PoCoPoint alloc] initX:MAX([s x], [e x])
                                             initY:MAX([s y], [e y])];
        if (o != nil) {
            self->ortPos_ = [[PoCoPoint alloc] initX:[o x]
                                               initY:[o y]];
            if (([self->startPos_ isEqualPos:s]) ||
                ([self->startPos_ isEqualPos:e]) ||
                ([self->endPos_ isEqualPos:s]) ||
                ([self->endPos_ isEqualPos:e])) {
                ;
            } else {
                self->diagonal_ = YES;
            }
        } else {
            self->ortPos_ = nil;
        }
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
//    startPos_ : 描画始点(中心点)(instance 変数)
//    endPos_   : 描画終点(中心点)(instance 変数)
//    ortPos_   : 方向点(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerBoxEditterBase dealloc]\n"));

    // 資源を解放
    [self->startPos_ release];
    [self->endPos_ release];
    [self->ortPos_ release];
    self->startPos_ = nil;
    self->endPos_ = nil;
    self->ortPos_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// 描画予定領域の算出
//  返り値の release を呼び出し元で行うこと
//
//  Call
//    corr      : 補正量
//    picture_  : 編集対象画像(基底 instance 変数)
//    startPos_ : 描画始点(中心点)(instance 変数)
//    endPos_   : 描画終点(中心点)(instance 変数)
//    diagonal_ : 回転で対角を使用(instance 変数)
//
//  Return
//    function : 領域
//
-(PoCoRect *)calcArea:(int)corr
{
    PoCoRect *r;
    PoCoCalcRotationForBox *rot;

    // 回転座標を算出
    rot = [[PoCoCalcRotationForBox alloc] initWithStartPos:self->startPos_
                                                withEndPos:self->endPos_
                                               ifAnyOrient:self->ortPos_];
    [rot calc:self->diagonal_];

    r = [[PoCoRect alloc] initLeft:INT_MAX
                           initTop:INT_MAX
                         initRight:INT_MIN
                        initBottom:INT_MIN];

    // 左辺
    [r setLeft:MIN([r left], [[rot leftTop] x])];
    [r setLeft:MIN([r left], [[rot rightTop] x])];
    [r setLeft:MIN([r left], [[rot leftBottom] x])];
    [r setLeft:MIN([r left], [[rot rightBottom] x])];

    // 上底
    [r setTop:MIN([r top], [[rot leftTop] y])];
    [r setTop:MIN([r top], [[rot rightTop] y])];
    [r setTop:MIN([r top], [[rot leftBottom] y])];
    [r setTop:MIN([r top], [[rot rightBottom] y])];

    // 右辺
    [r setRight:MAX([r right], [[rot leftTop] x])];
    [r setRight:MAX([r right], [[rot rightTop] x])];
    [r setRight:MAX([r right], [[rot leftBottom] x])];
    [r setRight:MAX([r right], [[rot rightBottom] x])];

    // 下底
    [r setBottom:MAX([r bottom], [[rot leftTop] y])];
    [r setBottom:MAX([r bottom], [[rot rightTop] y])];
    [r setBottom:MAX([r bottom], [[rot leftBottom] y])];
    [r setBottom:MAX([r bottom], [[rot rightBottom] y])];

    // 補正量を反映
    [r setLeft:([r left] - corr)];
    [r setTop:([r top] - corr)];
    [r setRight:([r right] + corr)];
    [r setBottom:([r bottom] + corr)];

    [rot release];
    return r;
}


//
// 編集開始
//
//  Call
//    dc : 再描画領域の補正量
//    uc : 取り消し領域の補正量
//
//  Return
//    function : 可否
//
-(BOOL)startEdit:(int)dc
    withUndoCorr:(int)uc
{
    BOOL result;
    PoCoRect *dr;
    PoCoRect *ur;

    // 範囲を生成
    dr = [self calcArea:dc];
    ur = [self calcArea:uc];
    [super correctRect:dr];
    [super correctRect:ur];

    // super class へ回送
    result = [super startEdit:dr
                 withUndoRect:ur];

    // 範囲を解放
    [dr release];
    [ur release];
 
    return result;
}


//
// 編集終了
//
//  Call
//    name : 取り消し名称文字列
//
//  Return
//    None
//
-(void)endEdit:(NSString *)name
{
    // super class へ回送
    [super endEdit:name];

    return;
}

@end




// ============================================================================
@implementation PoCoControllerEllipseEditterBase

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict   : 編集対象画像
//    info   : 編集情報
//    undo   : 取り消し情報
//    eraser : 消しゴム用画像
//    buf    : 色保持情報
//    pen    : ペン先
//    tile   : タイルパターン
//    s      : 描画始点(中心点)
//    e      : 描画終点(中心点)
//    o      : 方向点
//    idx    : 対象レイヤー番号
//
//  Return
//    function  : 実体
//    startPos_ : 描画始点(中心点)(instance 変数)
//    endPos_   : 描画終点(中心点)(instance 変数)
//    ortPos_   : 方向点(instance 変数)
//
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
      withPen:(PoCoPenStyle *)pen
     withTile:(PoCoTilePattern *)tile
    withStart:(PoCoPoint *)s
      withEnd:(PoCoPoint *)e
  ifAnyOrient:(PoCoPoint *)o
      atIndex:(int)idx;
{
//    DPRINT((@"[PoCoControllerEllipseEditterBase init]\n"));

    // super class を初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:buf
                   withPen:pen
                  withTile:tile
                   atIndex:idx];

    // 自身を初期化
    if (self != nil) {
        // 点を複製
        self->startPos_ = [[PoCoPoint alloc] initX:[s x]
                                             initY:[s y]];
        self->endPos_ = [[PoCoPoint alloc] initX:[e x]
                                           initY:[e y]];
        if (o != nil) {
            self->ortPos_ = [[PoCoPoint alloc] initX:[o x]
                                               initY:[o y]];
        } else {
            self->ortPos_ = nil;
        }
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
//    startPos_ : 描画始点(中心点)(instance 変数)
//    endPos_   : 描画終点(中心点)(instance 変数)
//    ortPos_   : 方向点(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerEllipseEditterBase dealloc]\n"));

    // 資源を解放
    [self->startPos_ release];
    [self->endPos_ release];
    [self->ortPos_ release];
    self->startPos_ = nil;
    self->endPos_ = nil;
    self->ortPos_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// 描画予定領域の算出
//  返り値の release を呼び出し元で行うこと
//
//  Call
//    corr      : 補正量
//    startPos_ : 描画始点(中心点)(instance 変数)
//    endPos_   : 描画終点(中心点)(instance 変数)
//    ortPos_   : 方向点(instance 変数)
//
//  Return
//    function : 領域
//
-(PoCoRect *)calcArea:(int)corr
{
    PoCoRect *r;
    int i;
    PoCoCalcRotationForEllipse *rot;
    int x;
    int y;
    int h;
    int v;
    int d;

    r = [[PoCoRect alloc] init];

    // 水平軸の算出
    i = ([self->startPos_ x] < [self->endPos_ x]) ?
            ([self->endPos_ x] - [self->startPos_ x]) :
            ([self->startPos_ x] - [self->endPos_ x]);
    [r setLeft:([self->startPos_ x] - i)];
    [r setRight:([self->startPos_ x] + i + 1)];

    // 垂直軸の算出
    i = ([self->startPos_ y] < [self->endPos_ y]) ?
            ([self->endPos_ y] - [self->startPos_ y]) :
            ([self->startPos_ y] - [self->endPos_ y]);
    [r setTop:([self->startPos_ y] - i)];
    [r setBottom:([self->startPos_ y] + i + 1)];

    // 方向点による回転を反映
    rot = [[PoCoCalcRotationForEllipse alloc] initWithCenterPos:self->startPos_
                                                     withEndPos:self->endPos_
                                                    ifAnyOrient:self->ortPos_];
    if ([rot isExec]) {
        h = ([r width] / 2);
        v = ([r height] / 2);
        [r setLeft:INT_MAX];
        [r setTop:INT_MAX];
        [r setRight:INT_MIN];
        [r setBottom:INT_MIN];
        for (d = 0; d < 3600; (d)++) {
            x = ([self->startPos_ x] + [rot calcXAxis:d
                                           horiLength:h
                                           vertLength:v]);
            y = ([self->startPos_ y] + [rot calcYAxis:d
                                           horiLength:h
                                           vertLength:v]);
            if (x < [r left]) {
                [r setLeft:x];
            } else if (x > [r right]) {
                [r setRight:x];
            }
            if (y < [r top]) {
                [r setTop:y];
            } else if (y > [r bottom]) {
                [r setBottom:y];
            }
        }
    }
    [rot release];

    // 補正量を反映
    [r setLeft:([r left] - corr)];
    [r setTop:([r top] - corr)];
    [r setRight:([r right] + corr)];
    [r setBottom:([r bottom] + corr)];

    return r;
}


//
// 編集開始
//
//  Call
//    dc : 再描画領域の補正量
//    uc : 取り消し領域の補正量
//
//  Return
//    function : 可否
//
-(BOOL)startEdit:(int)dc
    withUndoCorr:(int)uc
{
    BOOL result;
    PoCoRect *dr;
    PoCoRect *ur;

    // 範囲を生成
    dr = [self calcArea:dc];
    ur = [self calcArea:uc];
    [super correctRect:dr];
    [super correctRect:ur];

    // super class へ回送
    result = [super startEdit:dr
                 withUndoRect:ur];

    // 範囲を解放
    [dr release];
    [ur release];
 
    return result;
}


//
// 編集終了
//
//  Call
//    name : 取り消し名称文字列
//
//  Return
//    None
//
-(void)endEdit:(NSString *)name
{
    // super class へ回送
    [super endEdit:name];

    return;
}

@end




// ============================================================================
@implementation PoCoControllerParallelogramEditterBase

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict   : 編集対象画像
//    info   : 編集情報
//    undo   : 取り消し情報
//    eraser : 消しゴム用画像
//    buf    : 色保持情報
//    pen    : ペン先
//    tile   : タイルパターン
//    f      : 1点(中心点)
//    s      : 2点(中心点)
//    t      : 3点(中心点)
//    idx    : 対象レイヤー番号
//
//  Return
//    function   : 実体
//    firstPos_  : 1点(中心点)(instance 変数)
//    secondPos_ : 2点(中心点)(instance 変数)
//    thirdPos_  : 3点(中心点)(instance 変数)
//    fourthPos_ : 4点(中心点)(instance 変数)
//
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
      withPen:(PoCoPenStyle *)pen
     withTile:(PoCoTilePattern *)tile
    withFirst:(PoCoPoint *)f
   withSecond:(PoCoPoint *)s
    withThird:(PoCoPoint *)t
      atIndex:(int)idx;
{
//    DPRINT((@"[PoCoControllerParallelogramEditterBase init]\n"));

    // super class を初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:buf
                   withPen:pen
                  withTile:tile
                   atIndex:idx];

    // 自身を初期化
    if (self != nil) {
        // 点を複製
        self->firstPos_ = [[PoCoPoint alloc] initX:[f x]
                                             initY:[f y]];
        self->secondPos_ = [[PoCoPoint alloc] initX:[s x]
                                              initY:[s y]];
        self->thirdPos_ = [[PoCoPoint alloc] initX:[t x]
                                             initY:[t y]];

        // 4点目を生成
        self->fourthPos_ = [[PoCoPoint alloc] initX:([f x] + ([t x] - [s x]))
                                              initY:([f y] + ([t y] - [s y]))];
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
//    firstPos_  : 1点(中心点)(instance 変数)
//    secondPos_ : 2点(中心点)(instance 変数)
//    thirdPos_  : 3点(中心点)(instance 変数)
//    fourthPos_ : 4点(中心点)(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerParallelogramEditterBase dealloc]\n"));

    // 資源を解放
    [self->firstPos_ release];
    [self->secondPos_ release];
    [self->thirdPos_ release];
    [self->fourthPos_ release];
    self->firstPos_ = nil;
    self->secondPos_ = nil;
    self->thirdPos_ = nil;
    self->fourthPos_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// 描画予定領域の算出
//  返り値の release を呼び出し元で行うこと
//
//  Call
//    corr       : 補正量
//    firstPos_  : 1点(中心点)(instance 変数)
//    secondPos_ : 2点(中心点)(instance 変数)
//    thirdPos_  : 3点(中心点)(instance 変数)
//    fourthPos_ : 4点(中心点)(instance 変数)
//
//  Return
//    function : 領域
//
-(PoCoRect *)calcArea:(int)corr
{
    PoCoRect *r;

    r = [[PoCoRect alloc] initLeft:[self->firstPos_ x]
                           initTop:[self->firstPos_ y]
                         initRight:[self->firstPos_ x]
                        initBottom:[self->firstPos_ y]];

    // 左辺
    if ([self->secondPos_ x] < [r left]) {
        [r setLeft:[self->secondPos_ x]];
    }
    if ([self->thirdPos_ x] < [r left]) {
        [r setLeft:[self->thirdPos_ x]];
    }
    if ([self->fourthPos_ x] < [r left]) {
        [r setLeft:[self->fourthPos_ x]];
    }
    [r setLeft:([r left] - corr)];

    // 上底
    if ([self->secondPos_ y] < [r top]) {
        [r setTop:[self->secondPos_ y]];
    }
    if ([self->thirdPos_ y] < [r top]) {
        [r setTop:[self->thirdPos_ y]];
    }
    if ([self->fourthPos_ y] < [r top]) {
        [r setTop:[self->fourthPos_ y]];
    }
    [r setTop:([r top] - corr)];

    // 右辺
    if ([r right] < [self->secondPos_ x]) {
        [r setRight:[self->secondPos_ x]];
    }
    if ([r right] < [self->thirdPos_ x]) {
        [r setRight:[self->thirdPos_ x]];
    }
    if ([r right] < [self->fourthPos_ x]) {
        [r setRight:[self->fourthPos_ x]];
    }
    [r setRight:([r right] + corr)];

    // 下底
    if ([r bottom] < [self->secondPos_ y]) {
        [r setBottom:[self->secondPos_ y]];
    }
    if ([r bottom] < [self->thirdPos_ y]) {
        [r setBottom:[self->thirdPos_ y]];
    }
    if ([r bottom] < [self->fourthPos_ y]) {
        [r setBottom:[self->fourthPos_ y]];
    }
    [r setBottom:([r bottom] + corr)];

    return r;
}


//
// 編集開始
//
//  Call
//    dc : 再描画領域の補正量
//    uc : 取り消し領域の補正量
//
//  Return
//    function : 可否
//
-(BOOL)startEdit:(int)dc
    withUndoCorr:(int)uc
{
    BOOL result;
    PoCoRect *dr;
    PoCoRect *ur;

    // 範囲を生成
    dr = [self calcArea:dc];
    ur = [self calcArea:uc];
    [super correctRect:dr];
    [super correctRect:ur];

    // super class へ回送
    result = [super startEdit:dr
                 withUndoRect:ur];

    // 範囲を解放
    [dr release];
    [ur release];
 
    return result;
}


//
// 編集終了
//
//  Call
//    name : 取り消し名称文字列
//
//  Return
//    None
//
-(void)endEdit:(NSString *)name
{
    // super class へ回送
    [super endEdit:name];

    return;
}

@end




// ============================================================================
@implementation PoCoControllerCurveEditterBase

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict   : 編集対象画像
//    info   : 編集情報
//    undo   : 取り消し情報
//    eraser : 消しゴム用画像
//    buf    : 色保持情報
//    pen    : ペン先
//    tile   : タイルパターン
//    points : 支点群
//    idx    : 対象レイヤー番号
//    type   : 補間方法
//    freq   : 補間頻度
//
//  Return
//    function : 実体
//    points_  : 支点群(instance 変数)
//    type_    : 補間方法(instance 変数)
//    freq_    : 補間頻度(instance 変数)
//
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
      withPen:(PoCoPenStyle *)pen
     withTile:(PoCoTilePattern *)tile
   withPoints:(NSMutableArray *)points
     withType:(PoCoCurveWithPointsType)type
     withFreq:(unsigned int)freq
      atIndex:(int)idx;
{
//    DPRINT((@"[PoCoControllerCurveEditterBase init]\n"));

    // super class を初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:buf
                   withPen:pen
                  withTile:tile
                   atIndex:idx];

    // 自身を初期化
    if (self != nil) {
        self->points_ = points;
        self->type_ = type;
        self->freq_ = freq;
        [self->points_ retain];
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
//    points_ : 支点群(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerCurveEditterBase dealloc]\n"));

    // 資源を解放
    [self->points_ release];
    self->points_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// 描画予定領域の算出
//  返り値の release を呼び出し元で行うこと
//
//  Call
//    corr    : 補正量
//    points_ : 支点群(instance 変数)
//    type_   : 補間方法(instance 変数)
//    freq_   : 補間頻度(instance 変数)
//
//  Return
//    function : 領域
//
-(PoCoRect *)calcArea:(int)corr
{
    PoCoRect *r;
    PoCoCalcCurveWithPointsBase *calc;
    NSEnumerator *iter;
    PoCoPoint *p;

    r = [[PoCoRect alloc] initLeft:INT_MAX
                           initTop:INT_MAX
                         initRight:INT_MIN
                        initBottom:INT_MIN];

    switch (self->type_) {
        default:
        case PoCoCurveWithPoints_Lagrange:
            calc = [[PoCoCalcLagrange alloc] initWithPoints:self->points_];
            break;
        case PoCoCurveWithPoints_Spline:
            calc = [[PoCoCalcSpline alloc] initWithPoints:self->points_];
            break;
    }
    iter = [[calc exec:self->freq_] objectEnumerator];
    for (p = [iter nextObject]; p != nil; p = [iter nextObject]) {
        if (([p x] - corr) < [r left]) {
            [r setLeft:([p x] - corr)];
        }
        if (([p y] - corr) < [r top]) {
            [r setTop:([p y] - corr)];
        }
        if (([p x] + corr) > [r right]) {
            [r setRight:([p x] + corr)];
        }
        if (([p y] + corr) > [r bottom]) {
            [r setBottom:([p y] + corr)];
        }
    }
    [calc release];

    return r;
}


//
// 編集開始
//
//  Call
//    dc : 再描画領域の補正量
//    uc : 取り消し領域の補正量
//
//  Return
//    function : 可否
//
-(BOOL)startEdit:(int)dc
    withUndoCorr:(int)uc
{
    BOOL result;
    PoCoRect *dr;
    PoCoRect *ur;

    // 範囲を生成
    dr = [self calcArea:dc];
    ur = [self calcArea:uc];
    [super correctRect:dr];
    [super correctRect:ur];

    // super class へ回送
    result = [super startEdit:dr
                 withUndoRect:ur];

    // 範囲を解放
    [dr release];
    [ur release];
 
    return result;
}


//
// 編集終了
//
//  Call
//    name : 取り消し名称文字列
//
//  Return
//    None
//
-(void)endEdit:(NSString *)name
{
    // super class へ回送
    [super endEdit:name];

    return;
}

@end
