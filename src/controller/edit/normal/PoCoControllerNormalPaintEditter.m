//
//	Pelistina on Cocoa - PoCo -
//	塗りつぶし(seed paint) - 通常
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerNormalPaintEditter.h"

#import "PoCoEditNormalPaint.h"

// ============================================================================
@implementation PoCoControllerNormalPaintEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict   : 編集対象画像
//    info   : 編集情報
//    undo   : 取り消し情報
//    eraser : 消しゴム用画像
//    tile   : タイルパターン
//    p      : 始点
//    idx    : 対象レイヤー番号
//
//  Return
//    function : 実体
//    pos_     : 始点(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   eraser:(PoCoColorPattern *)eraser
     tile:(PoCoTilePattern *)tile
      pos:(PoCoPoint *)p
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerNormalPaintEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:nil
                   withPen:nil
                  withTile:tile
                   atIndex:idx];

    // 自身の初期化
    if (self != nil) {
        self->pos_ = p;
        [self->pos_ retain];
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
//    pos_ : 始点(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerNormalPaintEditter dealloc]\n"));

    // 資源の解放
    [self->pos_ release];
    self->pos_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    picture_     : 編集対象画像(基底 instance 変数)
//    layer_       : 対象レイヤー(基底 instance 変数)
//    drawPattern_ : 描画パターン(基底 instance 変数)
//    drawTile_    : 使用タイルパターン(基底 instance 変数)
//    pos_         : 始点(instance 変数)
//
//  Return
//    function    : 編集可否
//    undoRect_   : 取り消し領域(基底 instance 変数)
//    undoBitmap_ : 取り消し画像(基底 instance 変数)
//
-(BOOL)execute
{
    BOOL result;
    PoCoEditNormalPaint *edit;
    PoCoRect *dr;
    PoCoRect *ur;
    PoCoBitmap *tmp;

    result = NO;
    edit = nil;

    // 範囲を生成
    dr = [self->picture_ bitmapPoCoRect];
    ur = [self->picture_ bitmapPoCoRect];

    // 編集開始
    if ([super startEdit:dr
            withUndoRect:ur]) {
        // 編集系を生成
        edit = [[PoCoEditNormalPaint alloc]
                   initWithPattern:[self->layer_ bitmap]
                           palette:[self->picture_ palette]
                              tile:self->drawTile_
                           pattern:self->drawPattern_
                             range:0];

        // 編集実行
        [edit executeDraw:self->pos_];

        // 実範囲を取得
        if (!([[edit drect] empty])) {
            // 取り消し用画像を実範囲におさめる
            [self->undoRect_    setLeft:[[edit drect]   left]];
            [self->undoRect_     setTop:[[edit drect]    top]];
            [self->undoRect_   setRight:[[edit drect]  right]];
            [self->undoRect_  setBottom:[[edit drect] bottom]];
            if (self->undoBitmap_ != nil) {
                tmp = [self->undoBitmap_ getBitmap:self->undoRect_];
                [self->undoBitmap_ release];
                self->undoBitmap_ = tmp;
            }
        }

        // 編集終了
        [super endEdit:[[NSBundle mainBundle]
                           localizedStringForKey:@"DrawPaint"
                                           value:@"paint"
                                           table:nil]];

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
