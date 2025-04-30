//
//	Pelistina on Cocoa - PoCo -
//	矩形 - 霧吹き
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoControllerAtomizerBoxFrameEditter.h"

#import "PoCoEditAtomizerDrawLine.h"

// ============================================================================
@implementation PoCoControllerAtomizerBoxFrameEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict   : 編集対象画像
//    info   : 編集情報
//    undo   : 取り消し情報
//    eraser : 消しゴム用画像
//    s      : 描画始点(中心点)
//    e      : 描画終点(中心点)
//    o      : 方向点
//    idx    : 対象レイヤー番号
//
//  Return
//    function : 実体
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   eraser:(PoCoColorPattern *)eraser
    start:(PoCoPoint *)s
      end:(PoCoPoint *)e
orientation:(PoCoPoint *)o
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerAtomizerBoxFrameEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:nil
                   withPen:nil
                  withTile:nil
                 withStart:s
                   withEnd:e
               ifAnyOrient:o
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
//    DPRINT((@"[PoCoControllerAtomizerBoxFrameEditter dealloc]\n"));

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
//    layer_       : 対象レイヤー(基底 instance 変数)
//    drawPattern_ : 描画パターン(基底 instance 変数)
//
//  Return
//    function : 編集可否
//
-(BOOL)execute
{
    BOOL result;
    PoCoEditAtomizerDrawLine *edit;
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
        edit = [[PoCoEditAtomizerDrawLine alloc]
                      init:[self->layer_ bitmap]
                   palette:[self->picture_ palette]
                   pattern:self->drawPattern_
                   penSize:[self->editInfo_ penSize]];

        // 編集実行
        [edit setRatio:ratio
             pointSkip:[self->editInfo_ atomizerSkip]
           patternType:[self->editInfo_ atomizerType]
             isFlipped:[self->editInfo_ flipType]];
        [super drawFrame:edit];

        // 編集終了
        [super endEdit:[[NSBundle mainBundle]
                           localizedStringForKey:@"DrawBoxShape"
                                           value:@"box shape"
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
