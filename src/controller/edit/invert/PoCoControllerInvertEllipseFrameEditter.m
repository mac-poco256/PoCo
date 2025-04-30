//
//	Pelistina on Cocoa - PoCo -
//	円/楕円 - 反転
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoControllerInvertEllipseFrameEditter.h"

#import "PoCoCalcEllipse.h"
#if 1
#import "PoCoEditInvertBase.h"
#else   // 1
#import "PoCoEditInvertDrawLine.h"
#endif  // 1

// ============================================================================
@implementation PoCoControllerInvertEllipseFrameEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    s    : 描画始点(中点)
//    e    : 描画終点(中点)
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
//    DPRINT((@"[PoCoControllerInvertEllipseFrameEditter init]\n"));

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
//    DPRINT((@"[PoCoControllerInvertEllipseFrameEditter dealloc]\n"));

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
//
//  Return
//    function : 編集可否
//
-(BOOL)execute
#if 1
{
    PoCoEditInvertBase *edit;
    PoCoRect *r;
    PoCoCalcEllipse *calc;
    PoCoPoint *p;
    int fx;
    int fy;

    // 再描画範囲算出
    r = [super calcArea:(PEN_STYLE_SIZE >> 1)];
    [super correctRect:r];

    // 描画実行
    edit = [[PoCoEditInvertBase alloc] initWithBitmap:[self->layer_ bitmap]
                                           isZeroOnly:NO];
    if (edit != nil) {
        fx = -1;
        fy = -1;
        calc = [[PoCoCalcEllipse alloc] init];
        [calc calc:self->startPos_
            endPos:self->endPos_
       orientation:self->ortPos_];
        [calc points];                  // 終点でも描くので最初を飛ばす
        for (p = [calc points]; p != nil; p = [calc points]) {
            if (([p x] != fx) || ([p y] != fy)) {
                [edit drawPoint:p];
                fx = [p x];
                fy = [p y];
                [r   setLeft:MIN(fx, [r   left])];
                [r    setTop:MIN(fy, [r    top])];
                [r  setRight:MAX(fx, [r  right])];
                [r setBottom:MAX(fy, [r bottom])];
            }
        }
        [calc release];
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
#else   // 1
{
    PoCoEditInvertDrawLine *edit;
    PoCoRect *r;
    PoCoPoint *p;
    PoCoCalcEllipse *calc;
    int fx;
    int fy;

    // 再描画範囲算出
    r = [super calcArea:(PEN_STYLE_SIZE >> 1)];
    [super correctRect:r];

    // 描画実行
    edit = [[PoCoEditInvertDrawLine alloc] initWithBitmap:[self->layer_ bitmap]
                                               isZeroOnly:NO];
    if (edit != nil) {
        fx = -1;
        fy = -1;
        calc = [[PoCoCalcEllipse alloc] init];
        [calc calc:self->startPos_
            endPos:self->endPos_
       orientation:self->ortPos_];
#if 0
        [calc points];                  // 終点でも描くので最初を飛ばす
#endif  // 0
        for (p = [calc points]; p != nil; p = [calc points]) {
            if (([p x] != fx) || ([p y] != fy)) {
                [edit addPoint:p];
                fx = [p x];
                fy = [p y];
                [r   setLeft:MIN(fx, [r   left])];
                [r    setTop:MIN(fy, [r    top])];
                [r  setRight:MAX(fx, [r  right])];
                [r setBottom:MAX(fy, [r bottom])];
            }
        }
        [calc release];
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
#endif  // 1

@end
