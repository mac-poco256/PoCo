//
//	Pelistina on Cocoa - PoCo -
//	塗りつぶし平行四辺形 - 霧吹き
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerAtomizerParallelogramFillEditter.h"

#import "PoCoAppController.h"
#import "PoCoEditAtomizerFill.h"

// ============================================================================
@implementation PoCoControllerAtomizerParallelogramFillEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict   : 編集対象画像
//    info   : 編集情報
//    undo   : 取り消し情報
//    eraser : 消しゴム用画像
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
    first:(PoCoPoint *)f
   second:(PoCoPoint *)s
    third:(PoCoPoint *)t
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerAtomizerParallelogramFillEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:nil
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
//    DPRINT((@"[PoCoControllerAtomizerParallelogramFillEditter dealloc]\n"));

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
    PoCoEditAtomizerFill *edit;
    int penSize;                        // 太さ
    int ratio;                          // 頻度
    int tnum;                           // タイルパターン番号
    int tend;                           // タイルパターン終点
    float t;
    float tskip;                        // タイルパターン変量

    result = NO;
    edit = nil;

    // 太さを算出
    penSize = ([self->editInfo_ penSize] * 8);

    // 頻度を算出
    ratio = [self->editInfo_ density];
    if (ratio < 250) {
        ratio /= 75;
    } else if (ratio < 750) {
        ratio /= 2;
        ratio /= 50;
    } else if (ratio < 1000) {
        ratio /= 5;
        ratio /= 25;
    }
    if (ratio <= 0) {
        // 頻度が 0 なら描画しない
        goto EXIT;
    }

    // パターンの変量を算出
    tskip = (8.0 / (float)(penSize));
    if ([self->editInfo_ flipType]) {
        tnum = (([self->editInfo_ atomizerType]) ? 16 : 8);
    } else {
        tnum = 0;
    }
    tend = (tnum + 8);
    t = (float)(tnum);

    // 編集開始
    if ([super startEdit:NO
             withPenSize:penSize
            withDrawCorr:0
            withUndoCorr:(PEN_STYLE_SIZE / 2)]) {
        // 編集系を生成
        edit = [[PoCoEditAtomizerFill alloc]
                      init:[self->layer_ bitmap]
                   palette:[self->picture_ palette]
                   pattern:self->drawPattern_
                     ratio:ratio];

        // 編集実行
        do {
            [super drawFill:edit
                   withTile:[[(PoCoAppController *)([NSApp delegate]) tileSteadyPattern] pattern:(tnum / ([self->editInfo_ atomizerType] ? 2 : 1))]];

            // 次へ
            [super next];
            t += tskip; 
            tnum = (int)(floor(t));
        } while (tnum != tend);

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

EXIT:
    return result;
}

@end
