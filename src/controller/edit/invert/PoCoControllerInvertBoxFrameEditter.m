//
//	Pelistina on Cocoa - PoCo -
//	矩形枠 - 反転
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoControllerInvertBoxFrameEditter.h"

#import "PoCoCalcRotation.h"
#import "PoCoEditInvertDrawLine.h"

// ============================================================================
@implementation PoCoControllerInvertBoxFrameEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    s    : 描画始点(中心点)
//    e    : 描画終点(中心点)
//    o    : 方向点
//    idx  : 対象レイヤー番号
//
//  Return
//    function : 実体
//
-(id)init:(PoCoPicture *)pict
    start:(PoCoPoint *)s
      end:(PoCoPoint *)e
orientation:(PoCoPoint *)o
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerInvertBoxFrameEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:nil
                  withUndo:nil
                withEraser:nil
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
//    DPRINT((@"[PoCoControllerInvertBoxFrameEditter dealloc]\n"));

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
//    layer_    : 対象レイヤー(基底 instance 変数)
//    startPos_ : 描画始点(中心点)(基底 instance 変数)
//    endPos_   : 描画終点(中心点)(基底 instance 変数)
//    ortPos_   : 方向点(基底 instance 変数)
//    diagonal_ : 回転で対角を使用(基底 instance 変数)
//
//  Return
//    function : 編集可否
//
-(BOOL)execute
{
    PoCoEditInvertDrawLine *edit;
    PoCoRect *r;
    PoCoCalcRotationForBox *rot;

    rot = nil;

    // 再描画範囲算出
    r = [super calcArea:(PEN_STYLE_SIZE >> 1)];
    [super correctRect:r];

    // 回転座標を算出
    rot = [[PoCoCalcRotationForBox alloc] initWithStartPos:self->startPos_
                                                withEndPos:self->endPos_
                                               ifAnyOrient:self->ortPos_];
    [rot calc:self->diagonal_];

    // 描画実行
    edit = [[PoCoEditInvertDrawLine alloc] initWithBitmap:[self->layer_ bitmap]
                                                isZeroOnly:NO];
    [edit addPoint:[rot leftTop]];
    [edit addPoint:[rot leftBottom]];
    [edit addPoint:[rot rightBottom]];
    [edit addPoint:[rot rightTop]];
    [edit addPoint:[rot leftTop]];
    [edit executeDraw];

    // 再描画通知
    [r expand:(PEN_STYLE_SIZE >> 1)];
    [super correctRect:r];
    [super postNotifyNoEdit:r];

    // 正常終了
    [rot release];
    [edit release];
    [r release];

    return YES;                         // 常時 YES
}

@end
