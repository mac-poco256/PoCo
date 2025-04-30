//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - ぼかし - 直線(2dot)
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoEditWaterDropDrawLine02.h"

// ============================================================================
@implementation PoCoEditWaterDropDrawLine02

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
    DPRINT((@"[PoCoEditWaterDropDrawLine02 init]\n"));

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
    DPRINT((@"[PoCoEditWaterDropDrawLine02 dealloc]\n"));

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
    return 1;
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

    DPRINT((@"[PoCoEditWaterDropDrawLine02 drawPoint:]\n"));

    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];

    [dp moveX:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];

    [dp moveY:1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];

    [dp moveX:-1];
    [super calcColor:dp
        withDrawRect:self->drawRect_
            withMask:nil];

    [dp release];
    return;
}

@end
