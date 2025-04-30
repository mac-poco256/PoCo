//
//	Pelistina on Cocoa - PoCo -
//	筆圧比例自由曲線 - グラデーション
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerGradationProportionalFreeLineEditter.h"

#import "PoCoEditGradationDrawLine.h"

// ============================================================================
@implementation PoCoControllerGradationProportionalFreeLineEditter

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
//    s      : 描画始点(中心点)
//    e      : 描画終点(中心点)
//    idx    : 対象レイヤー番号
//    p      : 筆圧比例
//    name   : 取り消し名称
//
//  Return
//    function  : 実体
//    undoName_ : 取り消し名称(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   eraser:(PoCoColorPattern *)eraser
   buffer:(PoCoColorBuffer *)buf
    start:(PoCoPoint *)s
      end:(PoCoPoint *)e
    index:(int)idx
     prop:(BOOL)p
 undoName:(NSString *)name
{
//    DPRINT((@"[PoCoControllerGradationProportionalFreeLineEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:buf
                   withPen:nil
                  withTile:nil
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
//    DPRINT((@"[PoCoControllerGradationProportionalFreeLineEditter dealloc]\n"));

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
    PoCoEditGradationDrawLine *edit;
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
        edit = [[PoCoEditGradationDrawLine alloc]
                      init:[self->layer_ bitmap]
                   colMode:[self->editInfo_ colorMode]
                   palette:[self->picture_ palette]
                   pattern:self->drawPattern_
                    buffer:self->colorBuffer_
                   penSize:[super selectPenSize]];

        // 編集実行
        [edit setRatio:ratio
            setDensity:1000
             pointSkip:[self->editInfo_ atomizerSkip]
             isFlipped:[self->editInfo_ flipType]];
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
