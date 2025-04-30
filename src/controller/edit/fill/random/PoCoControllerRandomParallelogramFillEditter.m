//
//	Pelistina on Cocoa - PoCo -
//	塗りつぶし平行四辺形 - 拡散
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerRandomParallelogramFillEditter.h"

#import "PoCoEditRandomFill.h"

// ============================================================================
@implementation PoCoControllerRandomParallelogramFillEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    tile : タイルパターン
//    f    : 1点
//    s    : 2点
//    t    : 3点
//    idx  : 対象レイヤー番号
//
//  Return
//    function : 実体
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
     tile:(PoCoTilePattern *)tile
    first:(PoCoPoint *)f
   second:(PoCoPoint *)s
    third:(PoCoPoint *)t
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerRandomParallelogramFillEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:nil
                withBuffer:nil
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
//    DPRINT((@"[PoCoControllerRandomParallelogramFillEditter dealloc]\n"));

    // 資源の解放
    ;

    // super class の解放
    [super dealloc];

    return;
}


//
// 描画実行
//
//  Call
//    picture_  : 編集対象画像(基底 instance 変数)
//    editInfo_ : 編集情報(基底 instance 変数)
//    layer_    : 対象レイヤー(基底 instance 変数)
//    drawTile_ : 使用タイルパターン(基底 instance 変数)
//
//  Return
//    function : 編集可否
//
-(BOOL)execute
{
    BOOL result;
    PoCoEditRandomFill *edit;

    result = NO;
    edit = nil;

    // 編集開始
    if ([super startEdit:NO
             withPenSize:0
            withDrawCorr:0
            withUndoCorr:(PEN_STYLE_SIZE / 2)]) {
        // 編集系を生成
        edit = [[PoCoEditRandomFill alloc]
                      init:[self->layer_ bitmap]
                   palette:[self->picture_ palette]
                     ratio:[self->editInfo_ density]
                     range:([self->editInfo_ penSize] * 8)];

        // 編集実行
        [super drawFill:edit
               withTile:self->drawTile_];

        // 編集終了
        [super endEdit:[[NSBundle mainBundle]
                           localizedStringForKey:@"DrawParallelogramFillShape"
                                           value:@"parallelogram fill shape"
                                           table:nil]];

        // 編集系を解放
        [edit release];

        // 正常終了
        result = YES;
    }

    return result;
}

@end
