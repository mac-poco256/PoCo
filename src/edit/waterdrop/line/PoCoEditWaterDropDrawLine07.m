//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - ぼかし - 直線(7dot)
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoEditWaterDropDrawLine07.h"

// ============================================================================
@implementation PoCoEditWaterDropDrawLine07

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
    DPRINT((@"[PoCoEditWaterDropDrawLine07 init]\n"));

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
    DPRINT((@"[PoCoEditWaterDropDrawLine07 dealloc]\n"));

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
    return 3;
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
    int l;

    DPRINT((@"[PoCoEditWaterDropDrawLine07 drawPoint:]\n"));

    [dp moveX:-1 moveY:-3];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];
    [dp moveX:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];
    [dp moveX:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];

    [dp moveX:-3 moveY:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];
    for (l = 0; l < 4; l++) {
        [dp moveX:1];
        [super calcColor:dp
            withDrawRect:self->drawRect_
                withMask:nil];
    }

    [dp moveX:-5 moveY:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];
    for (l = 0; l < 6; l++) {
        [dp moveX:1];
        [super calcColor:dp
            withDrawRect:self->drawRect_
                withMask:nil];
    }

    [dp moveX:-6 moveY:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];
    for (l = 0; l < 6; l++) {
        [dp moveX:1];
        [super calcColor:dp
            withDrawRect:self->drawRect_
                withMask:nil];
    }

    [dp moveX:-6 moveY:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];
    for (l = 0; l < 6; l++) {
        [dp moveX:1];
        [super calcColor:dp
            withDrawRect:self->drawRect_
                withMask:nil];
    }

    [dp moveX:-5 moveY:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];
    for (l = 0; l < 4; l++) {
        [dp moveX:1];
        [super calcColor:dp
            withDrawRect:self->drawRect_
                withMask:nil];
    }

    [dp moveX:-3 moveY:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];
    [dp moveX:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];
    [dp moveX:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];

    [dp release];
    return;
}

@end
