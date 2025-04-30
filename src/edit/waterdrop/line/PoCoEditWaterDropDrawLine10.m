//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - ぼかし - 直線(10dot)
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoEditWaterDropDrawLine10.h"

// ============================================================================
@implementation PoCoEditWaterDropDrawLine10

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp   : 編集対象
//    cmode : 色演算モード
//    plt   : 使用パレット
//    buf   : 色保持情報
//
//  Return
//    function : 実体
//
-(id)init:(PoCoBitmap *)bmp
  colMode:(PoCoColorMode)cmode
  palette:(PoCoPalette *)plt
   buffer:(PoCoColorBuffer *)buf
{
    DPRINT((@"[PoCoEditWaterDropDrawLine10 init]\n"));

    // super class の初期化
    self = [super init:bmp
               colMode:cmode
               palette:plt
                buffer:buf];

    // 自身の初期化
    if (self != nil) {
        // 何もしない
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
    DPRINT((@"[PoCoEditWaterDropDrawLine10 dealloc]\n"));

    // 資源の解放
    ;

    // super class の解放
    [super dealloc];

    return;
}


//
// 描画範囲
//
//  Call
//    None
//
//  Return
//    function : 描画範囲
//
-(int)pointSize
{
    return 5;
}


//
// 点の描画
//
//  Call
//    p         : 描画中心
//    drawRect_ : 描画範囲(instance 変数)
//
//  Return
//    None
//
-(void)drawPoint:(PoCoPoint *)p
{
    PoCoPoint *dp = [[PoCoPoint alloc] initX:[p x]
                                       initY:[p y]];
    int i;
    int l;

    DPRINT((@"[PoCoEditWaterDropDrawLine10 drawPoint:]\n"));

    [dp moveX:-1 moveY:-4];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];
    for (l = 0; l < 3; l++) {
        [dp moveX:1];
        [super calcColor:dp
            withDrawRect:self->drawRect_
                withMask:nil];
    }

    [dp moveX:-4 moveY:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];
    for (l = 0; l < 5; l++) {
        [dp moveX:1];
        [super calcColor:dp
            withDrawRect:self->drawRect_
                withMask:nil];
    }

    [dp moveX:-6 moveY:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];
    for (l = 0; l < 7; l++) {
        [dp moveX:1];
        [super calcColor:dp
            withDrawRect:self->drawRect_
                withMask:nil];
    }

    [dp moveX:-8 moveY:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];
    for (l = 0; l < 9; l++) {
        [dp moveX:1];
        [super calcColor:dp
            withDrawRect:self->drawRect_
                withMask:nil];
    }

    for (i = 0; i < 3; i++) {
        [dp moveX:-9 moveY:1];
        [super calcColor:dp
            withDrawRect:self->drawRect_
                withMask:nil];
        for (l = 0; l < 9; l++) {
            [dp moveX:1];
            [super calcColor:dp
                withDrawRect:self->drawRect_
                    withMask:nil];
        }
    }

    [dp moveX:-8 moveY:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];
    for (l = 0; l < 7; l++) {
        [dp moveX:1];
        [super calcColor:dp
            withDrawRect:self->drawRect_
                withMask:nil];
    }

    [dp moveX:-6 moveY:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];
    for (l = 0; l < 5; l++) {
        [dp moveX:1];
        [super calcColor:dp
            withDrawRect:self->drawRect_
                withMask:nil];
    }

    [dp moveX:-4 moveY:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];
    for (l = 0; l < 3; l++) {
        [dp moveX:1];
        [super calcColor:dp
            withDrawRect:self->drawRect_
                withMask:nil];
    }

    [dp release];
    return;
}

@end
