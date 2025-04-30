//
//	Pelistina on Cocoa - PoCo -
//	平行四辺形-通常
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerNormalParallelogramFrameEditter.h"

#import "PoCoLayer.h"
#import "PoCoEditNormalDrawPoint.h"
#import "PoCoEditNormalDrawLine.h"

// ============================================================================
@implementation PoCoControllerNormalParallelogramFrameEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict   : 編集対象画像
//    info   : 編集情報
//    undo   : 取り消し情報
//    eraser : 消しゴム用画像
//    pen    : ペン先
//    tile   : タイルパターン
//    f      : 1点
//    s      : 2点
//    t      : 3点
//    idx    : 対象レイヤー番号
//
//  Return
//    function  : 実体
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   eraser:(PoCoColorPattern *)eraser
      pen:(PoCoPenStyle *)pen
     tile:(PoCoTilePattern *)tile
    first:(PoCoPoint *)f
   second:(PoCoPoint *)s
    third:(PoCoPoint *)t
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerNormalParallelogramFrameEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:nil
                   withPen:pen
                  withTile:tile
                 withFirst:f
                withSecond:s
                 withThird:t
                   atIndex:idx];

    // 自身の初期化
    if (self != nil) {
        ;
    }

    return self;
}


//
// dellocate
//
//  Call
//    None
//
//  Return
//    None
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerNormalParallelogramFrameEditter dealloc]\n"));

    // 資源の解放
    ;

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    picture_     : 編集対象画像(基底 instance 変数)
//    editInfo_    : 編集情報(基底 instance 変数)
//    colorBuffer_ : 色保持情報(基底 instance 変数)
//    layer_       : 対象レイヤー(基底 instance 変数)
//    drawPattern_ : 描画パターン(基底 instance 変数)
//    drawPen_     : 使用ペン先(基底 instance 変数)
//    drawTile_    : 使用タイルパターン(基底 instance 変数)
//
//  Return
//    function : 編集可否
//
-(BOOL)execute
{
    BOOL result;
    id edit;

    result = NO;
    edit = nil;

    // 編集開始
    if ([super startEdit:(PEN_STYLE_SIZE >> 1)
            withUndoCorr:(PEN_STYLE_SIZE >> 1)]) {
        // 編集系を生成
        if ([self->editInfo_ continuationType]) {
            // 連続線分
            edit = [[PoCoEditNormalDrawLine alloc]
                       initWithPattern:[self->layer_ bitmap]
                               palette:[self->picture_ palette]
                                   pen:self->drawPen_
                                  tile:self->drawTile_
                               pattern:self->drawPattern_];
        } else {
            // 非連続線分
            edit = [[PoCoEditNormalDrawPoint alloc]
                       initWithPattern:[self->layer_ bitmap]
                               palette:[self->picture_ palette]
                                   pen:self->drawPen_
                                  tile:self->drawTile_
                               pattern:self->drawPattern_];
        }

        // 編集実行
        [super setCont];
        [super drawFrame:edit];

        // 編集終了
        [super endEdit:[[NSBundle mainBundle]
                           localizedStringForKey:@"DrawParallelogramShape"
                                           value:@"parallelogram shape"
                                           table:nil]];

        // 編集系を解放
        [edit release];

        // 正常終了
        result = YES;
    }

    return result;
}

@end
