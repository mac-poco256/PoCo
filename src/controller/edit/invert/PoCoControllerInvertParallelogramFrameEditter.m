//
//	Pelistina on Cocoa - PoCo -
//	平行四辺形 - 反転
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerInvertParallelogramFrameEditter.h"

#import "PoCoEditInvertDrawLine.h"

// ============================================================================
@implementation PoCoControllerInvertParallelogramFrameEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    f    : 1点
//    s    : 2点
//    t    : 3点
//    idx  : 対象レイヤー番号
//
//  Return
//    function  : 実体
//
-(id)init:(PoCoPicture *)pict
    first:(PoCoPoint *)f
   second:(PoCoPoint *)s
    third:(PoCoPoint *)t
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerInvertParallelogramFrameEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:nil
                  withUndo:nil
                withEraser:nil
                withBuffer:nil
                   withPen:nil
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
//    DPRINT((@"[PoCoControllerInvertParallelogramFrameEditter dealloc]\n"));

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
//    layer_     : 対象レイヤー(基底 instance 変数)
//    firstPos_  : 1点(基底 instance 変数)
//    secondPos_ : 2点(基底 instance 変数)
//    thirdPos_  : 3点(基底 instance 変数)
//    fourthPos_ : 4点(基底 instance 変数)
//
//  Return
//    function : 編集可否
//
-(BOOL)execute
{
    PoCoEditInvertDrawLine *edit;
    PoCoRect *r;

    // 再描画範囲算出
    r = [super calcArea:(PEN_STYLE_SIZE >> 1)];
    [super correctRect:r];

    // 描画実行
    edit = [[PoCoEditInvertDrawLine alloc] initWithBitmap:[self->layer_ bitmap]
                                               isZeroOnly:NO];
    if (edit != nil) {
        [edit addPoint:self->firstPos_];
        [edit addPoint:self->secondPos_];
        [edit addPoint:self->thirdPos_];
        [edit addPoint:self->fourthPos_];
        [edit addPoint:self->firstPos_];
        [edit executeDraw];
    }

    // 再描画通知
    [r expand:(PEN_STYLE_SIZE >> 1)];
    [super correctRect:r];
    [super postNotifyNoEdit:r];

    // 正常終了
    [edit release];
    [r release];

    return YES;                         // 常時 YES
}

@end
