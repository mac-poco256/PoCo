//
//	Pelistina on Cocoa - PoCo -
//	塗りつぶし系描画部基底
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoControllerFillEditterBase.h"

#import "PoCoCreateStyleMask.h"

#import "PoCoEditNormalPasteImage.h"
#import "PoCoEditRegionFill.h"
#import "PoCoEditUniformedDensityFill.h"
#import "PoCoEditAtomizerFill.h"
#import "PoCoEditGradationFill.h"
#import "PoCoEditRandomFill.h"

// ============================================================================
@implementation PoCoControllerBoxFillEditterBase

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
//    tile   : タイルパターン
//    s      : 描画始点(中心点)
//    e      : 描画終点(中心点)
//    o      : 方向点
//    idx    : 対象レイヤー番号
//
//  Return
//    function   : 実体
//    trueRect_  : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_      : 形状マスク(instance 変数)
//    orgRect_   : 編集前画像範囲(画像全体)(instance 変数)
//    orgBitmap_ : 編集前画像(instance 変数)
//
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
     withTile:(PoCoTilePattern *)tile
    withStart:(PoCoPoint *)s
      withEnd:(PoCoPoint *)e
  ifAnyOrient:(PoCoPoint *)o
      atIndex:(int)idx
{
//    DPRINT((@"[PoCoControllerBoxFillEditterBase init]\n"));

    // super class を初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:buf
                   withPen:nil
                  withTile:tile
                 withStart:s
                   withEnd:e
               ifAnyOrient:o
                   atIndex:idx];

    // 自身を初期化
    if (self != nil) {
        self->trueRect_ = nil;
        self->mask_ = nil;
        self->orgRect_ = nil;
        self->orgBitmap_ = nil;
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
//    trueRect_  : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_      : 形状マスク(instance 変数)
//    orgRect_   : 編集前画像範囲(画像全体)(instance 変数)
//    orgBitmap_ : 編集前画像(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerBoxFillEditterBase dealloc]\n"));

    // 資源を解放
    [self->trueRect_ release];
    [self->mask_ release];
    [self->orgRect_ release];
    [self->orgBitmap_ release];
    self->trueRect_ = nil;
    self->mask_ = nil;
    self->orgRect_ = nil;
    self->orgBitmap_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// 編集開始
//
//  Call
//    org       : 編集前画像を記憶するか
//                YES : 記憶する(orgRect_、orgBitmap_ を生成する)
//                NO  : 記憶しない
//    penSize   : ペン先大きさ
//                == 0 : ペン先の大きさは用いない
//                != 0 : ペン先の大きさに応じた値も算出する
//    dc        : 再描画領域の補正量
//    uc        : 取り消し領域の補正量
//    picture_  : 編集対象画像(基底 instance 変数)
//    layer_    : 対象レイヤー(基底 instance 変数)
//    startPos_ : 描画始点(中心点)(基底 instance 変数)
//    endPos_   : 描画終点(中心点)(基底 instance 変数)
//
//  Return
//    trueRect_  : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_      : 形状マスク(instance 変数)
//    xskip_     : 水平変量(instance 変数)
//    yskip_     : 垂直変量(instance 変数)
//    x_[]       : 水平座標(instance 変数)
//    y_[]       : 垂直座標(instance 変数)
//    orgRect_   : 編集前画像範囲(画像全体)(instance 変数)
//    orgBitmap_ : 編集前画像(instance 変数)
//
-(BOOL)startEdit:(BOOL)org
     withPenSize:(int)penSize
    withDrawCorr:(int)dc
    withUndoCorr:(int)uc
{
    // 描画範囲(画像範囲外含む)を算出
    self->trueRect_ = [super calcArea:0];

    // 形状マスクを生成
    self->mask_ = [[PoCoCreateStyleMask alloc] init];

    // 変量を算出
    if (penSize != 0) {
        self->xskip_ = ((float)(([self->endPos_ x] - [self->startPos_ x]) >> 1) / (float)(penSize));
        self->yskip_ = ((float)(([self->endPos_ y] - [self->startPos_ y]) >> 1) / (float)(penSize));
        self->x_[0] =  (float)([self->startPos_ x]);
        self->y_[0] =  (float)([self->startPos_ y]);
        self->x_[1] = ((float)([self->endPos_   x]) + 0.9);
        self->y_[1] = ((float)([self->endPos_   y]) + 0.9);
    }

    // 編集前画像を記憶
    if (org) {
        self->orgRect_ = [self->picture_ bitmapPoCoRect];
        self->orgBitmap_ = [[self->layer_ bitmap] getBitmap:self->orgRect_];
    }

    // super class へ回送
    return [super startEdit:dc
               withUndoCorr:uc];
}


//
// 編集終了
//
//  Call
//    name : 取り消し名称文字列
//
//  Return
//    trueRect_  : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_      : 形状マスク(instance 変数)
//    orgRect_   : 編集前画像範囲(画像全体)(instance 変数)
//    orgBitmap_ : 編集前画像(instance 変数)
//
-(void)endEdit:(NSString *)name
{
    // 開始時に生成した資源を解放
    [self->trueRect_ release];
    [self->mask_ release];
    [self->orgRect_ release];
    [self->orgBitmap_ release];
    self->trueRect_ = nil;
    self->mask_ = nil;
    self->orgRect_ = nil;
    self->orgBitmap_ = nil;

    // super class へ回送
    [super endEdit:name];

    return;
}


//
// 座標移動
//
//  Call
//    xskip_ : 水平変量(instance 変数)
//    yskip_ : 垂直変量(instance 変数)
//
//  Return
//    startPos_ : 描画始点(中心点)(基底 instance 変数)
//    endPos_   : 描画終点(中心点)(基底 instance 変数)
//    trueRect_ : 描画範囲(画像範囲外含む)(instance 変数)
//    x_[]      : 水平座標(instance 変数)
//    y_[]      : 垂直座標(instance 変数)
//
-(void)next
{
    // 座標を更新
    self->x_[0] += self->xskip_;
    self->y_[0] += self->yskip_;
    self->x_[1] -= self->xskip_;        
    self->y_[1] -= self->yskip_;
    [self->startPos_ setX:(int)(floor(self->x_[0] + 0.5))
                     setY:(int)(floor(self->y_[0] + 0.5))];
    [self->endPos_   setX:(int)(floor(self->x_[1] + 0.5))
                     setY:(int)(floor(self->y_[1] + 0.5))];

    // 以前の範囲を忘れる
    [self->trueRect_ release];
    self->trueRect_ = nil;

    // 範囲を再算出
    self->trueRect_ = [self calcArea:0];

    return;
}


//
// 塗りつぶし矩形の描画
//
//  Call
//    edit      : 編集系
//    tile      : タイルパターン
//    startPos_ : 描画始点(中心点)(基底 instance 変数)
//    endPos_   : 描画終点(中心点)(基底 instance 変数)
//    ortPos_   : 方向点(基底 instance 変数)
//    diagonal_ : 回転で対角を使用(基底 instance 変数)
//    drawRect_ : 再描画領域(基底 instance 変数)
//    trueRect_ : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_     : 形状マスク(instance 変数)
//
//  Return
//    None
//
-(void)drawFill:(id)edit
       withTile:(PoCoMonochromePattern *)tile
{
    if (!([self->trueRect_ empty])) {
        // 形状マスクを生成
        if ([self->mask_ box:self->startPos_
                         end:self->endPos_
                 orientation:self->ortPos_
                  isDiagonal:self->diagonal_]) {
            // 描画
            [edit executeDraw:[self->mask_ mask]
                     withTile:tile
                 withTrueRect:self->trueRect_
                 withDrawRect:self->drawRect_];
        }
    }

    return;
}


//
// 編集前画像を複製
//  関数返り値には呼び出し元で release を送ること
//
//  Call
//    orgRect_   : 編集前画像範囲(画像全体)(instance 変数)
//    orgBitmap_ : 編集前画像(instance 変数)
//
//  Return
//    function : 画像の実体
//
-(PoCoBitmap *)getWorkBitmap
{
    return [self->orgBitmap_ getBitmap:self->orgRect_];
}


//
// 画像を複写
//
//  Call
//    work      : 作業用ビットマップ
//    picture_  : 編集対象画像(基底 instance 変数)
//    layer_    : 対象レイヤー(基底 instance 変数)
//    trueRect_ : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_     : 形状マスク(instance 変数)
//
//  Return
//    None
//
-(void)pasteFromWork:(PoCoBitmap *)work
{
    PoCoEditNormalPasteImage *edit;
    PoCoBitmap *tmp;

    // 転送元画像から複写内容を取得
    tmp = [work getBitmap:self->trueRect_];

    // 編集系を生成
    edit = [[PoCoEditNormalPasteImage alloc]
               initWithBitmap:[self->layer_ bitmap]
                      palette:[self->picture_ palette]
                         tile:nil
                         mask:[self->mask_ mask]
                  pasteBitmap:tmp];

    // 複写
    [edit executeDraw:self->trueRect_];

    // 資源を解放
    [edit release];
    [tmp release];

    return;
}

@end




// ============================================================================
@implementation PoCoControllerEllipseFillEditterBase

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
//    tile   : タイルパターン
//    s      : 描画始点(中心点)
//    e      : 描画終点(中心点)
//    o      : 方向点
//    idx    : 対象レイヤー番号
//
//  Return
//    function   : 実体
//    trueRect_  : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_      : 形状マスク(instance 変数)
//    orgRect_   : 編集前画像範囲(画像全体)(instance 変数)
//    orgBitmap_ : 編集前画像(instance 変数)
//
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
     withTile:(PoCoTilePattern *)tile
    withStart:(PoCoPoint *)s
      withEnd:(PoCoPoint *)e
  ifAnyOrient:(PoCoPoint *)o
      atIndex:(int)idx
{
//    DPRINT((@"[PoCoControllerEllipseFillEditterBase init]\n"));

    // super class を初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:buf
                   withPen:nil
                  withTile:tile
                 withStart:s
                   withEnd:e
               ifAnyOrient:o
                   atIndex:idx];

    // 自身を初期化
    if (self != nil) {
        self->trueRect_ = nil;
        self->mask_ = nil;
        self->orgRect_ = nil;
        self->orgBitmap_ = nil;
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
//    trueRect_  : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_      : 形状マスク(instance 変数)
//    orgRect_   : 編集前画像範囲(画像全体)(instance 変数)
//    orgBitmap_ : 編集前画像(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerEllipseFillEditterBase dealloc]\n"));

    // 資源を解放
    [self->trueRect_ release];
    [self->mask_ release];
    [self->orgRect_ release];
    [self->orgBitmap_ release];
    self->trueRect_ = nil;
    self->mask_ = nil;
    self->orgRect_ = nil;
    self->orgBitmap_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// 編集開始
//
//  Call
//    org       : 編集前画像を記憶するか
//                YES : 記憶する(orgRect_、orgBitmap_ を生成する)
//                NO  : 記憶しない
//    penSize   : ペン先大きさ
//                == 0 : ペン先の大きさは用いない
//                != 0 : ペン先の大きさに応じた値も算出する
//    dc        : 再描画領域の補正量
//    uc        : 取り消し領域の補正量
//    picture_  : 編集対象画像(基底 instance 変数)
//    layer_    : 対象レイヤー(基底 instance 変数)
//    startPos_ : 描画始点(中心点)(基底 instance 変数)
//    endPos_   : 描画終点(中心点)(基底 instance 変数)
//
//  Return
//    trueRect_  : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_      : 形状マスク(instance 変数)
//    xskip_     : 水平変量(instance 変数)
//    yskip_     : 垂直変量(instance 変数)
//    x_         : 水平座標(instance 変数)
//    y_         : 垂直座標(instance 変数)
//    orgRect_   : 編集前画像範囲(画像全体)(instance 変数)
//    orgBitmap_ : 編集前画像(instance 変数)
//
-(BOOL)startEdit:(BOOL)org
     withPenSize:(int)penSize
    withDrawCorr:(int)dc
    withUndoCorr:(int)uc
{
    // 描画範囲(画像範囲外含む)を算出
    self->trueRect_ = [super calcArea:0];

    // 形状マスクを生成
    self->mask_ = [[PoCoCreateStyleMask alloc] init];

    // 変量を算出
    if (penSize != 0) {
        self->xskip_ = ((float)([self->endPos_ x] - [self->startPos_ x]) / (float)(penSize));
        self->yskip_ = ((float)([self->endPos_ y] - [self->startPos_ y]) / (float)(penSize));

        self->x_ = (float)([self->endPos_ x]);   
        self->y_ = (float)([self->endPos_ y]);   
    }

    // 編集前画像を記憶
    if (org) {
        self->orgRect_ = [self->picture_ bitmapPoCoRect];
        self->orgBitmap_ = [[self->layer_ bitmap] getBitmap:self->orgRect_];
    }

    // super class へ回送
    return [super startEdit:dc
               withUndoCorr:uc];

}


//
// 編集終了
//
//  Call
//    name : 取り消し名称文字列
//
//  Return
//    trueRect_  : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_      : 形状マスク(instance 変数)
//    orgRect_   : 編集前画像範囲(画像全体)(instance 変数)
//    orgBitmap_ : 編集前画像(instance 変数)
//
-(void)endEdit:(NSString *)name
{
    // 開始時に生成した資源を解放
    [self->trueRect_ release];
    [self->mask_ release];
    [self->orgRect_ release];
    [self->orgBitmap_ release];
    self->trueRect_ = nil;
    self->mask_ = nil;
    self->orgRect_ = nil;
    self->orgBitmap_ = nil;

    // super class へ回送
    [super endEdit:name];

    return;
}


//
// 座標移動
//
//  Call
//    xskip_ : 水平変量(instance 変数)
//    yskip_ : 垂直変量(instance 変数)
//
//  Return
//    endPos_   : 描画終点(中心点)(基底 instance 変数)
//    trueRect_ : 描画範囲(画像範囲外含む)(instance 変数)
//    x_        : 水平座標(instance 変数)
//    y_        : 垂直座標(instance 変数)
//
-(void)next
{
    // 座標を更新
    self->x_ -= self->xskip_;
    self->y_ -= self->yskip_;
    [self->endPos_ setX:(int)(floor(self->x_ + 0.5))
                   setY:(int)(floor(self->y_ + 0.5))];

    // 以前の範囲を忘れる
    [self->trueRect_ release];
    self->trueRect_ = nil;

    // 範囲を再算出
    self->trueRect_ = [self calcArea:0];

    return;
}


//
// 塗りつぶし円/楕円の描画
//
//  Call
//    edit      : 編集系
//    tile      : タイルパターン
//    startPos_ : 描画始点(中心点)(基底 instance 変数)
//    endPos_   : 描画終点(中心点)(基底 instance 変数)
//    ortPos_   : 方向点(基底 instance 変数)
//    drawRect_ : 再描画領域(基底 instance 変数)
//    trueRect_ : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_     : 形状マスク(instance 変数)
//
//  Return
//    None
//
-(void)drawFill:(id)edit
       withTile:(PoCoMonochromePattern *)tile
{
    if (!([self->trueRect_ empty])) {
        // 形状マスクを生成
        if ([self->mask_ ellipse:self->startPos_
                             end:self->endPos_
                     orientation:self->ortPos_]) {
            // 描画
            [edit executeDraw:[self->mask_ mask]
                     withTile:tile
                 withTrueRect:self->trueRect_
                 withDrawRect:self->drawRect_];
        }
    }

    return;
}


//
// 編集前画像を複製
//  関数返り値には呼び出し元で release を送ること
//
//  Call
//    orgRect_   : 編集前画像範囲(画像全体)(instance 変数)
//    orgBitmap_ : 編集前画像(instance 変数)
//
//  Return
//    function : 画像の実体
//
-(PoCoBitmap *)getWorkBitmap
{
    return [self->orgBitmap_ getBitmap:self->orgRect_];
}


//
// 画像を複写
//
//  Call
//    work      : 作業用ビットマップ
//    picture_  : 編集対象画像(基底 instance 変数)
//    layer_    : 対象レイヤー(基底 instance 変数)
//    trueRect_ : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_     : 形状マスク(instance 変数)
//
//  Return
//    None
//
-(void)pasteFromWork:(PoCoBitmap *)work
{
    PoCoEditNormalPasteImage *edit;
    PoCoBitmap *tmp;

    // 転送元画像から複写内容を取得
    tmp = [work getBitmap:self->trueRect_];

    // 編集系を生成
    edit = [[PoCoEditNormalPasteImage alloc]
               initWithBitmap:[self->layer_ bitmap]
                      palette:[self->picture_ palette]
                         tile:nil
                         mask:[self->mask_ mask]
                  pasteBitmap:tmp];

    // 複写
    [edit executeDraw:self->trueRect_];

    // 資源を解放
    [edit release];
    [tmp release];

    return;
}

@end




// ============================================================================
@implementation PoCoControllerParallelogramFillEditterBase

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
//    tile   : タイルパターン
//    f      : 1点(中心点)
//    s      : 2点(中心点)
//    t      : 3点(中心点)
//    idx    : 対象レイヤー番号
//
//  Return
//    function   : 実体
//    trueRect_  : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_      : 形状マスク(instance 変数)
//    orgRect_   : 編集前画像範囲(画像全体)(instance 変数)
//    orgBitmap_ : 編集前画像(instance 変数)
//
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
   withEraser:(PoCoColorPattern *)eraser
   withBuffer:(PoCoColorBuffer *)buf
     withTile:(PoCoTilePattern *)tile
    withFirst:(PoCoPoint *)f
   withSecond:(PoCoPoint *)s
    withThird:(PoCoPoint *)t
      atIndex:(int)idx
{
//    DPRINT((@"[PoCoControllerParallelogramFillEditterBase init]\n"));

    // super class を初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:buf
                   withPen:nil
                  withTile:tile
                 withFirst:f
                withSecond:s
                 withThird:t
                   atIndex:idx];

    // 自身を初期化
    if (self != nil) {
        self->trueRect_ = nil;
        self->mask_ = nil;
        self->orgRect_ = nil;
        self->orgBitmap_ = nil;
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
//    trueRect_  : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_      : 形状マスク(instance 変数)
//    orgRect_   : 編集前画像範囲(画像全体)(instance 変数)
//    orgBitmap_ : 編集前画像(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerParallelogramFillEditterBase dealloc]\n"));

    // 資源を解放
    [self->trueRect_ release];
    [self->mask_ release];
    [self->orgRect_ release];
    [self->orgBitmap_ release];
    self->trueRect_ = nil;
    self->mask_ = nil;
    self->orgRect_ = nil;
    self->orgBitmap_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// 編集開始
//
//  Call
//    org        : 編集前画像を記憶するか
//                 YES : 記憶する(orgRect_、orgBitmap_ を生成する)
//                 NO  : 記憶しない
//    penSize    : ペン先大きさ
//                 == 0 : ペン先の大きさは用いない
//                 != 0 : ペン先の大きさに応じた値も算出する
//    dc         : 再描画領域の補正量
//    uc         : 取り消し領域の補正量
//    picture_   : 編集対象画像(基底 instance 変数)
//    layer_     : 対象レイヤー(基底 instance 変数)
//    firstPos_  : 1点(中心点)(基底 instance 変数)
//    secondPos_ : 2点(中心点)(基底 instance 変数)
//    thirdPos_  : 3点(中心点)(基底 instance 変数)
//
//  Return
//    trueRect_  : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_      : 形状マスク(instance 変数)
//    xskip_     : 水平変量(instance 変数)
//    yskip_     : 垂直変量(instance 変数)
//    x_[]       : 水平座標(instance 変数)
//    y_[]       : 垂直座標(instance 変数)
//    orgRect_   : 編集前画像範囲(画像全体)(instance 変数)
//    orgBitmap_ : 編集前画像(instance 変数)
//
-(BOOL)startEdit:(BOOL)org
     withPenSize:(int)penSize
    withDrawCorr:(int)dc
    withUndoCorr:(int)uc
{
    // 描画範囲(画像範囲外含む)を算出
    self->trueRect_ = [super calcArea:0];

    // 形状マスクを生成
    self->mask_ = [[PoCoCreateStyleMask alloc] init];

    // 変量を算出
    if (penSize != 0) {
        self->xskip_ = ((float)([self->thirdPos_ x] - [self->secondPos_ x]) / (float)(penSize));
        self->yskip_ = ((float)([self->thirdPos_ y] - [self->secondPos_ y]) / (float)(penSize));
        self->x_[0] = (float)([self->firstPos_  x]);
        self->y_[0] = (float)([self->firstPos_  y]);
        self->x_[1] = (float)([self->secondPos_ x]);
        self->y_[1] = (float)([self->secondPos_ y]);
    }

    // 編集前画像を記憶
    if (org) {
        self->orgRect_ = [self->picture_ bitmapPoCoRect];
        self->orgBitmap_ = [[self->layer_ bitmap] getBitmap:self->orgRect_];
    }

    // super class へ回送
    return [super startEdit:dc
               withUndoCorr:uc];

}


//
// 編集終了
//
//  Call
//    name : 取り消し名称文字列
//
//  Return
//    trueRect_  : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_      : 形状マスク(instance 変数)
//    orgRect_   : 編集前画像範囲(画像全体)(instance 変数)
//    orgBitmap_ : 編集前画像(instance 変数)
//
-(void)endEdit:(NSString *)name
{
    // 開始時に生成した資源を解放
    [self->trueRect_ release];
    [self->mask_ release];
    [self->orgRect_ release];
    [self->orgBitmap_ release];
    self->trueRect_ = nil;
    self->mask_ = nil;
    self->orgRect_ = nil;
    self->orgBitmap_ = nil;

    // super class へ回送
    [super endEdit:name];

    return;
}


//
// 座標移動
//
//  Call
//    xskip_ : 水平変量(instance 変数)
//    yskip_ : 垂直変量(instance 変数)
//
//  Return
//    firstPos_  : 1点(中心点)(基底 instance 変数)
//    secondPos_ : 2点(中心点)(基底 instance 変数)
//    trueRect_  : 描画範囲(画像範囲外含む)(instance 変数)
//    x_[]       : 水平座標(instance 変数)
//    y_[]       : 垂直座標(instance 変数)
//
-(void)next
{
    // 座標を更新
    self->x_[0] += self->xskip_;
    self->y_[0] += self->yskip_;
    self->x_[1] += self->xskip_;
    self->y_[1] += self->yskip_;
    [self->firstPos_  setX:(int)(floor(self->x_[0] + 0.5))
                      setY:(int)(floor(self->y_[0] + 0.5))];
    [self->secondPos_ setX:(int)(floor(self->x_[1] + 0.5))
                      setY:(int)(floor(self->y_[1] + 0.5))];


    // 以前の範囲を忘れる
    [self->trueRect_ release];
    self->trueRect_ = nil;

    // 範囲を再算出
    self->trueRect_ = [self calcArea:0];

    return;
}


//
// 塗りつぶし平行四辺形の描画
//
//  Call
//    edit       : 編集系
//    tile       : タイルパターン
//    firstPos_  : 1点(中心点)(基底 instance 変数)
//    secondPos_ : 2点(中心点)(基底 instance 変数)
//    thirdPos_  : 3点(中心点)(基底 instance 変数)
//    fourthPos_ : 4点(中心点)(基底 instance 変数)
//    trueRect_  : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_      : 形状マスク(instance 変数)
//
//  Return
//    None
//
-(void)drawFill:(id)edit
       withTile:(PoCoMonochromePattern *)tile
{
    if (!([self->trueRect_ empty])) {
        // 形状マスクを生成
        if ([self->mask_ parallelogram:self->firstPos_
                                second:self->secondPos_
                                 third:self->thirdPos_
                                fourth:self->fourthPos_]) {
            // 描画
            [edit executeDraw:[self->mask_ mask]
                     withTile:tile
                 withTrueRect:self->trueRect_
                 withDrawRect:self->drawRect_];
        }
    }

    return;
}


//
// 編集前画像を複製
//  関数返り値には呼び出し元で release を送ること
//
//  Call
//    orgRect_   : 編集前画像範囲(画像全体)(instance 変数)
//    orgBitmap_ : 編集前画像(instance 変数)
//
//  Return
//    function : 画像の実体
//
-(PoCoBitmap *)getWorkBitmap
{
    return [self->orgBitmap_ getBitmap:self->orgRect_];
}


//
// 画像を複写
//
//  Call
//    work      : 作業用ビットマップ
//    picture_  : 編集対象画像(基底 instance 変数)
//    layer_    : 対象レイヤー(基底 instance 変数)
//    trueRect_ : 描画範囲(画像範囲外含む)(instance 変数)
//    mask_     : 形状マスク(instance 変数)
//
//  Return
//    None
//
-(void)pasteFromWork:(PoCoBitmap *)work
{
    PoCoEditNormalPasteImage *edit;
    PoCoBitmap *tmp;

    // 転送元画像から複写内容を取得
    tmp = [work getBitmap:self->trueRect_];

    // 編集系を生成
    edit = [[PoCoEditNormalPasteImage alloc]
               initWithBitmap:[self->layer_ bitmap]
                      palette:[self->picture_ palette]
                         tile:nil
                         mask:[self->mask_ mask]
                  pasteBitmap:tmp];

    // 複写
    [edit executeDraw:self->trueRect_];

    // 資源を解放
    [edit release];
    [tmp release];

    return;
}

@end
