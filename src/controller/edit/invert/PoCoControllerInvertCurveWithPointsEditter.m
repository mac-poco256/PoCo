//
//	Pelistina on Cocoa - PoCo -
//	直線群(曲線) - 反転
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoControllerInvertCurveWithPointsEditter.h"

#import "PoCoEditInvertDrawLine.h"
#import "PoCoCalcCurveWithPoints.h"

// ============================================================================
@implementation PoCoControllerInvertCurveWithPointsEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    p    : 支点群
//    idx  : 対象レイヤー番号
//    type : 補間方法
//    freq : 補間頻度
//
//  Return
//    function : 実体
//    points_  : 支点群(instance 変数)
//    type_    : 補間方法(instance 変数)
//    freq_    : 補間頻度(instance 変数)
//
-(id)init:(PoCoPicture *)pict
   points:(NSMutableArray *)p
     type:(PoCoCurveWithPointsType)type
     freq:(unsigned int)freq
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerInvertCurveWithPointsEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:nil
                  withUndo:nil
                withEraser:nil
                withBuffer:nil
                   withPen:nil
                  withTile:nil
                   atIndex:idx];

    // 自身の初期化
    if (self != nil) {
        self->points_ = p;
        self->type_ = type;
        self->freq_ = freq;
        [self->points_ retain];
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
//    points_ : 支点群(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerInvertCurveWithPointsEditter dealloc]\n"));

    // 資源の解放
    [self->points_ release];
    self->points_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    layer_  : 対象レイヤー(基底 instance 変数)
//    points_ : 支点群(instance 変数)
//    type_   : 補間方法(instance 変数)
//    freq_   : 補間頻度(instance 変数)
//
//  Return
//    function : 編集可否
//
-(BOOL)execute
{
    PoCoEditInvertDrawLine *edit;
    PoCoRect *r;
    NSEnumerator *iter;
    PoCoPoint *p;
    PoCoCalcCurveWithPointsBase *calc;

    r = [[PoCoRect alloc] initLeft:INT_MAX
                           initTop:INT_MAX
                         initRight:INT_MIN
                        initBottom:INT_MIN];

    // 描画実行
    edit = [[PoCoEditInvertDrawLine alloc] initWithBitmap:[self->layer_ bitmap]
                                               isZeroOnly:NO];
    if (edit != nil) {
        // 補間演算を実施
        switch (self->type_) {
            default:
            case PoCoCurveWithPoints_Lagrange:
                calc = [[PoCoCalcLagrange alloc] initWithPoints:self->points_];
                break;
            case PoCoCurveWithPoints_Spline:
                calc = [[PoCoCalcSpline alloc] initWithPoints:self->points_];
                break;
        }
        iter = [[calc exec:self->freq_] objectEnumerator];
        for (p = [iter nextObject]; p != nil; p = [iter nextObject]) {
            [edit addPoint:p];

            // 再描画範囲算出
            if (([p x] - (PEN_STYLE_SIZE >> 1)) < [r left]) {
                [r setLeft:([p x] - (PEN_STYLE_SIZE >> 1))];
            }
            if (([p y] - (PEN_STYLE_SIZE >> 1)) < [r top]) {
                [r setTop:([p y] - (PEN_STYLE_SIZE >> 1))];
            }
            if (([p x] + (PEN_STYLE_SIZE >> 1)) > [r right]) {
                [r setRight:([p x] + (PEN_STYLE_SIZE >> 1))];
            }
            if (([p y] + (PEN_STYLE_SIZE >> 1)) > [r bottom]) {
                [r setBottom:([p y] + (PEN_STYLE_SIZE >> 1))];
            }
        }
        [edit executeDraw];
        [calc release];
    }
    [super correctRect:r];

    // 描画実行を通知
    [r expand:(PEN_STYLE_SIZE >> 1)];
    [super correctRect:r];
    [super postNotifyNoEdit:r];

    // 正常終了
    [edit release];
    [r release];

    return YES;                         // 常時 YES
}

@end
