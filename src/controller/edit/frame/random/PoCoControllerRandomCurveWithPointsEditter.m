//
//	Pelistina on Cocoa - PoCo -
//	直線群(曲線) - 拡散
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoControllerRandomCurveWithPointsEditter.h"

#import "PoCoEditRandomDrawLine.h"

// ============================================================================
@implementation PoCoControllerRandomCurveWithPointsEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict   : 編集対象画像
//    info   : 編集情報
//    undo   : 取り消し情報
//    tile   : タイルパターン
//    points : 直線群
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
     tile:(PoCoTilePattern *)tile
   points:(NSMutableArray *)points
     type:(PoCoCurveWithPointsType)type
     freq:(unsigned int)freq
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerRandomCurveWithPointsEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:nil
                withBuffer:nil
                   withPen:nil
                  withTile:tile
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
//    DPRINT((@"[PoCoControllerRandomCurveWithPointsEditter dealloc]\n"));

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
    PoCoEditRandomDrawLine *edit;
    int ratio;                          // 頻度

    result = NO;
    edit = nil;

    // 頻度を算出
    ratio = [self->editInfo_ density];
    if (ratio < 250) {
        ratio /= 75;
    } else if (ratio < 750) {
        ratio /= 50;
    } else if (ratio < 1000) {
        ratio /= 25;
    }
    if (ratio <= 0) {
        // 頻度が 0 なら描画しない
        goto EXIT;
    }

    // 編集開始
    if ([super startEdit:(ATOMIZER_SIZE >> 1)
            withUndoCorr:(ATOMIZER_SIZE >> 1)]) {
        // 編集系を生成
        edit = [[PoCoEditRandomDrawLine alloc]
                      init:[self->layer_ bitmap]
                   palette:[self->picture_ palette]
                      tile:self->drawTile_
                     ratio:ratio
                     range:([self->editInfo_ penSize] * 4)];

        // 編集実行
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
