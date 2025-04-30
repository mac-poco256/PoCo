//
//	Pelistina on Cocoa - PoCo -
//	塗りつぶし矩形枠 - グラデーション
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoControllerGradationBoxFillEditter.h"

#import "PoCoAppController.h"
#import "PoCoEditGradationFill.h"

// ============================================================================
@implementation PoCoControllerGradationBoxFillEditter

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
   buffer:(PoCoColorBuffer *)buf
    start:(PoCoPoint *)s
      end:(PoCoPoint *)e
orientation:(PoCoPoint *)o
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerGradationBoxFillEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:buf
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
//    DPRINT((@"[PoCoControllerGradationBoxFillEditter dealloc]\n"));

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
    PoCoEditGradationFill *edit;
    int penSize;                        // 太さ
    int ratio;                          // 頻度
    float density;                      // 濃度
    int tnum;                           // タイルパターン番号
    int tend;                           // タイルパターン終点
    float d;
    float t;
    float dskip;                        // 濃度変量
    float tskip;                        // タイルパターン変量
    PoCoBitmap *workBitmap;

    result = NO;
    edit = nil;

    // 太さを算出
    penSize = ([self->editInfo_ penSize] + 7);

    // 濃度を取得、有効濃度を算出
    density = 1000.0;
    dskip = (density / (float)(penSize));

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

    // パターンの変量を算出
    tskip = (8.0 / penSize);
    tnum = (([self->editInfo_ flipType]) ? 8 : 0);
    tend = (tnum + 8);
    t = (float)(tnum);

    // 編集開始
    if ([super startEdit:YES
             withPenSize:penSize
            withDrawCorr:0
            withUndoCorr:(PEN_STYLE_SIZE / 2)]) {
        // 編集系を生成
        edit = [[PoCoEditGradationFill alloc]
                      init:nil
                   colMode:[self->editInfo_ colorMode]
                   palette:[self->picture_ palette]
                   pattern:self->drawPattern_
                    buffer:self->colorBuffer_
                     ratio:ratio];

        // 編集実行
        d = 1.0;
        do {
            if (!([self->trueRect_ empty])) {
                // 作業用ビットマップを生成
                workBitmap = [super getWorkBitmap];

                // 作業用ビットマップに描画
                [edit replaceDensity:(int)(floor(d))
                          withBitmap:workBitmap];
                [super drawFill:edit
                       withTile:[[(PoCoAppController *)([NSApp delegate]) tileSteadyPattern] pattern:tnum]];

                // 作業用ビットマップから複写
                [super pasteFromWork:workBitmap];

                // 作業用ビットマップを解放
                [workBitmap release];
            }

            // 次へ
            [super next];
            d += dskip;
            t += tskip; 
            tnum = (int)(floor(t));
        } while ((d <= density) && (tnum != tend));

        // 編集終了
        [super endEdit:[[NSBundle mainBundle]
                           localizedStringForKey:@"DrawBoxFillShape"
                                           value:@"box fill shape"
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
