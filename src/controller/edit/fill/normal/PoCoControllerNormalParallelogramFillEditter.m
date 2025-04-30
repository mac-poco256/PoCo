//
//	Pelistina on Cocoa - PoCo -
//	塗りつぶし平行四辺形 - 通常
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerNormalParallelogramFillEditter.h"

#import "PoCoCreateStyleMask.h"
#import "PoCoEditRegionFill.h"

// ============================================================================
@implementation PoCoControllerNormalParallelogramFillEditter

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
//    f      : 1点(中心点)
//    s      : 2点(中心点)
//    t      : 3点(中心点)
//    idx    : 対象レイヤー番号
//
//  Return
//    function : 実体
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   eraser:(PoCoColorPattern *)eraser
     tile:(PoCoTilePattern *)tile
    first:(PoCoPoint *)f
   second:(PoCoPoint *)s
    third:(PoCoPoint *)t
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerNormalParallelogramFillEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:nil
                   withPen:nil
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
//    DPRINT((@"[PoCoControllerNormalParallelogramFillEditter dealloc]\n"));

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
//    picture_     : 編集対象画像(基底 instance 変数)
//    firstPos_    : 1点(中心点)(基底 instance 変数)
//    secondPos_   : 2点(中心点)(基底 instance 変数)
//    thirdPos_    : 3点(中心点)(基底 instance 変数)
//    fourthPos_   : 4点(中心点)(基底 instance 変数)
//    layer_       : 対象レイヤー(基底 instance 変数)
//    drawPattern_ : 描画パターン(基底 instance 変数)
//    drawTile_    : 使用タイルパターン(基底 instance 変数)
//
//  Return
//    function : 編集可否
//
-(BOOL)execute
{
    BOOL result;
    PoCoEditRegionFill *edit;
    PoCoRect *trueRect;
    PoCoCreateStyleMask *mask;

    result = NO;
    edit = nil;
    trueRect = nil;
    mask = nil;

    // 編集開始
    if ([super startEdit:0
            withUndoCorr:(PEN_STYLE_SIZE / 2)]) {
        trueRect = [super calcArea:0];

        // 形状マスクを生成
        mask = [[PoCoCreateStyleMask alloc] init];
        if ([mask parallelogram:self->firstPos_
                         second:self->secondPos_
                          third:self->thirdPos_
                         fourth:self->fourthPos_]) {
            // 編集系を生成
            edit = [[PoCoEditRegionFill alloc]
                       initWithPattern:[self->layer_ bitmap]
                               palette:[self->picture_ palette]
                                  tile:self->drawTile_
                               pattern:self->drawPattern_
                             checkDist:YES];

            // 編集実行
            [edit executeDraw:[mask mask]
                 withStartPos:[trueRect lefttop]
                   withEndPos:[trueRect rightbot]];

            // 編集終了
            [super endEdit:[[NSBundle mainBundle]
                           localizedStringForKey:@"DrawParallelogramFillShape"
                                           value:@"parallelogram fill shape"
                                           table:nil]];

            // 編集系を解放
            [edit release];
        }

        // 形状マスクを解放
        [mask release];

        // 正常終了
        result = YES;
    }

    [trueRect release];
    return result;
}

@end
