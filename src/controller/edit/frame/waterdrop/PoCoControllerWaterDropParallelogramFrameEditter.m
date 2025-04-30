//
//	Pelistina on Cocoa - PoCo -
//	平行四辺形 - ぼかし
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerWaterDropParallelogramFrameEditter.h"

#import "PoCoEditWaterDropFactory.h"
#import "PoCoEditWaterDropDrawLineBase.h"

// ============================================================================
@implementation PoCoControllerWaterDropParallelogramFrameEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    buf  : 色保持情報
//    s    : 描画始点(中心点)
//    e    : 描画終点(中心点)
//    idx  : 対象レイヤー番号
//
//  Return
//    function : 実体
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
    first:(PoCoPoint *)f
   second:(PoCoPoint *)s
    third:(PoCoPoint *)t
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerWaterDropParallelogramFrameEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:nil
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
//    DPRINT((@"[PoCoControllerWaterDropParallelogramFrameEditter dealloc]\n"));

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
//
//  Return
//    function : 編集可否
//
-(BOOL)execute
{
    BOOL result;
    PoCoEditWaterDropDrawLineBase *edit;

    result = NO;
    edit = nil;

    // 編集開始
    if ([super startEdit:(PEN_STYLE_SIZE >> 1)
            withUndoCorr:(PEN_STYLE_SIZE >> 1)]) {
        // 編集系を生成
        edit = [PoCoEditWaterDropDrawLineFactory
                    create:[self->layer_ bitmap]
                   colMode:[self->editInfo_ colorMode]
                   palette:[self->picture_ palette]
                    buffer:self->colorBuffer_
                   penSize:[self->editInfo_ penSize]];

        // 編集実行
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
