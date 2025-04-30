//
//	Pelistina on Cocoa - PoCo -
//	画像貼り付け - 通常
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerNormalPasteImageEditter.h"

#import "PoCoEditNormalPasteImage.h"

// ============================================================================
@implementation PoCoControllerNormalPasteImageEditter

// --------------------------------------------------------- instance - private
//
// 描画予定領域の算出
//
//  Call
//    dstRect_  : 貼り付け先矩形枠(instance 変数)
//    prevRect_ : 貼り付け元矩形枠(instance 変数)
//
//  Return
//    function : 領域
//
-(PoCoRect *)calcArea
{
    // 矩形枠の和をとる
    return [[PoCoRect alloc]
                 initLeft:MIN([self->dstRect_   left], [self->prevRect_   left])
                  initTop:MIN([self->dstRect_    top], [self->prevRect_    top])
                initRight:MAX([self->dstRect_  right], [self->prevRect_  right])
               initBottom:MAX([self->dstRect_ bottom], [self->prevRect_ bottom])];
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    tile : タイルパターン
//    r    : 貼り付け先矩形枠
//    bmp  : 貼り付ける画像
//    mask : 任意領域の形状
//    pr   : 貼り付け元矩形枠
//    pbmp : 貼り付け前画像
//    idx  : 対象レイヤー番号
//    name : 取り消し名称
//
//  Return
//    function  : 実体
//    dstRect_  : 貼り付け先矩形枠(instance 変数)
//    pasteBmp_ : 貼り付ける画像(instance 変数)
//    mask_     : 任意領域の形状(instance 変数)
//    prevRect_ : 貼り付け元矩形枠(instance 変数)
//    prevBmp_  : 貼り付け前画像(instance 変数)
//    undoName_ : 取り消し名称(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
     tile:(PoCoTilePattern *)tile
     rect:(PoCoRect *)r
   bitmap:(PoCoBitmap *)bmp
   region:(PoCoBitmap *)mask
 prevRect:(PoCoRect *)pr
prevBitmap:(PoCoBitmap *)pbmp
    index:(int)idx
 undoName:(NSString *)name
{
//    DPRINT((@"[PoCoControllerNormalPasteImageEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:nil
                withBuffer:nil
                   withPen:nil
                  withTile:tile
                   atIndex:idx];

    // 自身の初期化
    if (self != nil) {
        self->dstRect_ = r;
        self->pasteBmp_ = bmp;
        self->mask_ = mask;
        self->prevRect_ = pr;
        self->prevBmp_ = pbmp;
        self->undoName_ = name;
        [self->dstRect_ retain];
        [self->pasteBmp_ retain];
        [self->mask_ retain];
        [self->prevRect_ retain];
        [self->prevBmp_ retain];
        [self->undoName_ retain];
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
//    dstRect_  : 貼り付け先矩形枠(instance 変数)
//    pasteBmp_ : 貼り付ける画像(instance 変数)
//    mask_     : 任意領域の形状(instance 変数)
//    prevRect_ : 貼り付け元矩形枠(instance 変数)
//    prevBmp_  : 貼り付け前画像(instance 変数)
//    undoName_ : 取り消し名称(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerNormalPasteImageEditter dealloc]\n"));

    // 資源の解放
    [self->dstRect_ release];
    [self->pasteBmp_ release];
    [self->mask_ release];
    [self->prevRect_ release];
    [self->prevBmp_ release];
    [self->undoName_ release];
    self->dstRect_ = nil;
    self->pasteBmp_ = nil;
    self->mask_ = nil;
    self->prevRect_ = nil;
    self->prevBmp_ = nil;
    self->undoName_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    picture_  : 編集対象画像(基底 instance 変数)
//    layer_    : 対象レイヤー(基底 instance 変数)
//    drawTile_ : 使用タイルパターン(基底 instance 変数)
//    dstRect_  : 貼り付け先矩形枠(instance 変数)
//    pasteBmp_ : 貼り付ける画像(instance 変数)
//    mask_     : 任意領域の形状(instance 変数)
//    prevRect_ : 貼り付け元矩形枠(instance 変数)
//                != nil : 元に戻す
//                == nil : 元に戻さない
//    prevBmp_  : 貼り付け前画像(instance 変数)
//                != nil : 元に戻す
//                == nil : 元に戻さない
//
//  Return
//    function : 編集可否
//
-(BOOL)execute
{
    BOOL result;
    PoCoEditNormalPasteImage *edit;
    PoCoRect *dr;
    PoCoRect *ur;
    PoCoRect *prevAreaRect;             // 移動元画像の領域
    PoCoBitmap *prevAreaBmp;            // 移動元画像

    result = NO;
    edit = nil;

    // 範囲を生成
    dr = [self calcArea];
    ur = [self calcArea];
    [super correctRect:dr];
    [super correctRect:ur];

    // 編集開始
    if ([super startEdit:dr
            withUndoRect:ur]) {
        // 移動元を戻す
        if ((self->prevRect_ != nil) && (self->prevBmp_ != nil)) {
            prevAreaBmp = [self->prevBmp_ getBitmap:self->prevRect_];
            prevAreaRect = [[PoCoRect alloc]
                                 initLeft:MAX(0,
                                              [self->prevRect_ left])
                                  initTop:MAX(0,
                                              [self->prevRect_ top])
                                initRight:MIN([[self->layer_ bitmap] width],
                                              [self->prevRect_ right])
                               initBottom:MIN([[self->layer_ bitmap] height],
                                              [self->prevRect_ bottom])];
            [[self->layer_ bitmap] setBitmap:[prevAreaBmp pixelmap]
                                    withRect:prevAreaRect];
            [prevAreaRect release];
            [prevAreaBmp release];
        }

        // 編集系を生成
        edit = [[PoCoEditNormalPasteImage alloc]
                   initWithBitmap:[self->layer_ bitmap]
                          palette:[self->picture_ palette]
                             tile:self->drawTile_
                             mask:self->mask_
                      pasteBitmap:self->pasteBmp_];

        // 編集実行
        [edit executeDraw:self->dstRect_];

        // 編集終了
        [super endEdit:self->undoName_];

        // 編集系を解放
        [edit release];

        // 正常終了
        result = YES;
    }

    // 範囲を解放
    [dr release];
    [ur release];

    return result;
}

@end
