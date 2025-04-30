//
//	Pelistina on Cocoa - PoCo -
//	直線群(曲線) - 均一濃度
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoControllerUniformedDensityCurveWithPointsEditter.h"

#import "PoCoEditUniformedDensityFactory.h"
#import "PoCoEditUniformedDensityDrawLineBase.h"

// ============================================================================
@implementation PoCoControllerUniformedDensityCurveWithPointsEditter

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
//    points : 支点群
//    type   : 補間方法
//    freq   : 補間頻度
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
   points:(NSMutableArray *)points
     type:(PoCoCurveWithPointsType)type
     freq:(unsigned int)freq
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerUniformedDensityCurveWithPointsEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:buf
                   withPen:nil
                  withTile:nil
                withPoints:points
                  withType:type
                  withFreq:freq
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
//    DPRINT((@"[PoCoControllerUniformedDensityCurveWithPointsEditter dealloc]\n"));

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
//    undoName_    : 取り消し名称(instance 変数)
//
//  Return
//    function : 編集可否
//
-(BOOL)execute
{
    BOOL result;
    PoCoEditUniformedDensityDrawLineBase *edit;
    int density;                        // 濃度

    result = NO;
    edit = nil;

    // 濃度を算出
    density = [self->editInfo_ density];
    if (density <= 0) {
        // 濃度が 0 なら描画しない
        goto EXIT;
    }

    // 編集開始
    if ([super startEdit:(PEN_STYLE_SIZE >> 1)
            withUndoCorr:(PEN_STYLE_SIZE >> 1)]) {
        // 編集系を生成
        edit = [PoCoEditUniformedDensityDrawLineFactory
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
                           localizedStringForKey:@"DrawCurveShape"
                                           value:@"curve shape"
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
