//
//	Pelistina on Cocoa - PoCo -
//	平行四辺形 - 濃度
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerDensityParallelogramFrameEditter.h"

#import "PoCoEditDensityFactory.h"
#import "PoCoEditDensityDrawLineBase.h"

// ============================================================================
@implementation PoCoControllerDensityParallelogramFrameEditter

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
//    f      : 1点
//    s      : 2点
//    t      : 3点
//    idx    : 対象レイヤー番号
//
//  Return
//    function : 実体
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   eraser:(PoCoColorPattern *)eraser
   buffer:(PoCoColorBuffer *)buf
    first:(PoCoPoint *)f
   second:(PoCoPoint *)s
    third:(PoCoPoint *)t
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerDensityParallelogramFrameEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:buf
                   withPen:nil
                  withTile:nil
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
//    DPRINT((@"[PoCoControllerDensityParallelogramFrameEditter dealloc]\n"));

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
//
//  Return
//    function : 編集可否
//
-(BOOL)execute
{
    BOOL result;
    PoCoEditDensityDrawLineBase *edit;
    int density;                        // 濃度

    result = NO;
    edit = nil;

    // 濃度を算出
    density = [self->editInfo_ density];
    if (density <= 0) {
        // 濃さが0なら描画しない
        goto EXIT;
    }

    // 編集開始
    if ([super startEdit:(PEN_STYLE_SIZE >> 1)
            withUndoCorr:(PEN_STYLE_SIZE >> 1)]) {
        // 編集系を生成
        edit = [PoCoEditDensityDrawLineFactory
                    create:[self->layer_ bitmap]
                   colMode:[self->editInfo_ colorMode]
                   palette:[self->picture_ palette]
                   pattern:self->drawPattern_
                    buffer:self->colorBuffer_
                   penSize:[self->editInfo_ penSize]];

        // 編集実行
        [edit setDensity:density];
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

EXIT:
    return result;
}

@end
