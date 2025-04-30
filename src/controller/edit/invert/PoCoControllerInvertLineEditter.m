//
//	Pelistina on Cocoa - PoCo -
//	直線 - 反転
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerInvertLineEditter.h"

#import "PoCoEditInvertDrawLine.h"

// ============================================================================
@implementation PoCoControllerInvertLineEditter

// --------------------------------------------------------- instance - private
//
// 描画予定領域の算出
//
//  Call
//    corr      : 補正量
//    picture_  : 編集対象画像(基底 instance 変数)
//    startPos_ : 描画始点(中心点)(instance 変数)
//    endPos_   : 描画終点(中心点)(instance 変数)
//
//  Return
//    function : 領域
//
-(PoCoRect *)calcArea:(int)corr
{
    PoCoRect *r;

    r = [[PoCoRect alloc] init];

    // 水平軸の算出
    if ([self->startPos_ x] < [self->endPos_ x]) {
        [r setLeft:([self->startPos_ x] - corr)];
        [r setRight:(([self->endPos_ x] + corr) + 1)];
    } else {
        [r setLeft:([self->endPos_ x] - corr)];
        [r setRight:(([self->startPos_ x] + corr) + 1)];
    }

    // 垂直軸の算出
    if ([self->startPos_ y] < [self->endPos_ y]) {
        [r setTop:([self->startPos_ y] - corr)];
        [r setBottom:(([self->endPos_ y] + corr) + 1)];
    } else {
        [r setTop:([self->endPos_ y] - corr)];
        [r setBottom:(([self->startPos_ y] + corr) + 1)];
    }

    return r;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    s    : 描画始点(中心点)
//    e    : 描画終点(中心点)
//    idx  : 対象レイヤー番号
//
//  Return
//    function  : 実体
//    startPos_ : 描画始点(中心点)(instance 変数)
//    endPos_   : 描画終点(中心点)(instance 変数)
//
-(id)init:(PoCoPicture *)pict
    start:(PoCoPoint *)s
      end:(PoCoPoint *)e
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerInvertLineEditter init]\n"));

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
        // 点を複製
        self->startPos_ = [[PoCoPoint alloc] initX:[s x] initY:[s y]];
        self->endPos_   = [[PoCoPoint alloc] initX:[e x] initY:[e y]];
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
//    startPos_ : 描画始点(中心点)(instance 変数)
//    endPos_   : 描画終点(中心点)(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerInvertLineEditter dealloc]\n"));

    // 資源の解放
    [self->startPos_ release]; 
    [self->endPos_ release];
    self->startPos_ = nil;
    self->endPos_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    layer_    : 対象レイヤー(基底 instance 変数)
//    startPos_ : 描画始点(中心点)(instance 変数)
//    endPos_   : 描画終点(中心点)(instance 変数)
//
//  Return
//    function : 編集可否
//
-(BOOL)execute
{
    PoCoEditInvertDrawLine *edit;
    PoCoRect *r;

    // 再描画範囲算出
    r = [self calcArea:(PEN_STYLE_SIZE >> 1)];
    [super correctRect:r];

    // 描画実行
    edit = [[PoCoEditInvertDrawLine alloc] initWithBitmap:[self->layer_ bitmap]
                                               isZeroOnly:NO];
    if (edit != nil) {
        [edit addPoint:self->startPos_];
        if ((self->endPos_ != nil) &&
           (!([self->startPos_ isEqualPos:self->endPos_]))) {
            [edit addPoint:self->endPos_];
        }
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
