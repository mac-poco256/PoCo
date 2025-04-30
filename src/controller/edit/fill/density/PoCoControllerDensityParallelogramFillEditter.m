//
//	Pelistina on Cocoa - PoCo -
//	塗りつぶし平行四辺形 - 濃度
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import "PoCoControllerDensityParallelogramFillEditter.h"

#import "PoCoEditUniformedDensityFill.h"

// ============================================================================
@implementation PoCoControllerDensityParallelogramFillEditter

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
   buffer:(PoCoColorBuffer *)buf
    first:(PoCoPoint *)f
   second:(PoCoPoint *)s
    third:(PoCoPoint *)t
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerDensityParallelogramFillEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:buf
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
// deallcate
//
//  Call
//    None
//
//  Return
//    None
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerDensityParallelogramFillEditter dealloc]\n"));

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
    PoCoEditUniformedDensityFill *edit;
    int penSize;                        // 太さ
    float density;                      // 濃度
    float d;
    float dskip;                        // 濃度変量
    PoCoBitmap *workBitmap;

    result = NO;
    edit = nil;

    // 太さを算出(最大が256階調なので *16 でよい(16*16=256))
    penSize = ([self->editInfo_ penSize] * 16);

    // 濃度を取得、有効濃度を算出
    density = (float)([self->editInfo_ density]);
    if (density <= 0.0) {
        // 濃度が 0 なら描画しない
        goto EXIT;
    }
    dskip = (density / (float)(penSize));

    // 編集開始
    if ([super startEdit:YES
             withPenSize:penSize
            withDrawCorr:0
            withUndoCorr:(PEN_STYLE_SIZE / 2)]) {
        // 編集系を生成
        edit = [[PoCoEditUniformedDensityFill alloc]
                      init:nil
                   colMode:[self->editInfo_ colorMode]
                   palette:[self->picture_ palette]
                   pattern:self->drawPattern_
                    buffer:self->colorBuffer_
                   density:0];

        // 編集実行
        d = 1.0;
        do {
            if (!([self->trueRect_ empty])) {
                // 作業用ビットマップを生成
                workBitmap = [super getWorkBitmap];

                // 作業用ビットマップに描画
                if ([self->editInfo_ flipType]) {
                    [edit replaceDensity:(int)(floor(density - d))
                              withBitmap:workBitmap];
                } else {
                    [edit replaceDensity:(int)(floor(d))
                              withBitmap:workBitmap];
                }
                [super drawFill:edit
                       withTile:nil];

                // 作業用ビットマップから複写
                [super pasteFromWork:workBitmap];

                // 作業用ビットマップを解放
                [workBitmap release];
            }

            // 次へ
            [super next];
            d += dskip;
        } while (d <= density);

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
