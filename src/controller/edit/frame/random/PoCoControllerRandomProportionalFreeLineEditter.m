//
//	Pelistina on Cocoa - PoCo -
//	筆圧比例自由曲線 - 拡散
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerRandomProportionalFreeLineEditter.h"

#import "PoCoEditRandomDrawLine.h"

// ============================================================================
@implementation PoCoControllerRandomProportionalFreeLineEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    tile : タイルパターン
//    s    : 描画始点(中心点)
//    e    : 描画終点(中心点)
//    idx  : 対象レイヤー番号
//    p    : 筆圧比例
//    name : 取り消し名称
//
//  Return
//    function  : 実体
//    undoName_ : 取り消し名称(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
     tile:(PoCoTilePattern *)tile
    start:(PoCoPoint *)s
      end:(PoCoPoint *)e
    index:(int)idx
     prop:(BOOL)p
 undoName:(NSString *)name
{
//    DPRINT((@"[PoCoControllerRandomProportionalFreeLineEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:nil
                withBuffer:nil
                   withPen:nil
                  withTile:tile
                 withStart:s
                   withEnd:e
                    isProp:p
                   atIndex:idx];

    // 自身の初期化
    if (self != nil) {
        self->undoName_ = name;
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
//    undoName_ : 取り消し名称(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerRandomProportionalFreeLineEditter dealloc]\n"));

    // 資源の解放
    [self->undoName_ release];
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
//    editInfo_ : 編集情報(基底 instance 変数)
//    layer_    : 対象レイヤー(基底 instance 変数)
//    drawTile_ : 使用タイルパターン(基底 instance 変数)
//    undoName_ : 取り消し名称(instance 変数)
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
    ratio = [super selectDensity];
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
                     range:([super selectPenSize] * 4)];

        // 編集実行
        [super drawFrame:edit];

        // 編集終了
        [super endEdit:self->undoName_];

        // 編集系を解放
        [edit release];

        // 正常終了
        result = YES;
    }

EXIT:
    return result;
}

@end
