//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 均一濃度 - 直線(11dot)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditUniformedDensityDrawLine11.h"

// ============================================================================
@implementation PoCoEditUniformedDensityDrawLine11

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp   : 編集対象
//    cmode : 色演算モード
//    plt   : 使用パレット
//    pat   : 使用カラーパターン
//    buf   : 色保持情報
//
//  Return
//    function : 実体
//
-(id)init:(PoCoBitmap *)bmp
  colMode:(PoCoColorMode)cmode
  palette:(PoCoPalette *)plt
  pattern:(PoCoColorPattern *)pat
   buffer:(PoCoColorBuffer *)buf
{
    DPRINT((@"[PoCoEditUniformedDensityDrawLine11 init]\n"));

    // super class の初期化
    self = [super init:bmp
               colMode:cmode
               palette:plt
               pattern:pat
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
    DPRINT((@"[PoCoEditUniformedDensityDrawLine11 dealloc]\n"));

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
    return 6;
}


//
// 点の描画
//
//  Call
//    p         : 描画中心
//    bbmp      : 描画対象
//    brow      : bbmp の rowbytes
//    pbmp      : パターン
//    prow      : pbmp の rowbytes
//    palette_  : 使用パレット(基底 instance 変数)
//    density_  : 濃度(0.1%単位)(基底 instance 変数)
//    drawRect_ : 描画範囲(基底 instance 変数)
//
//  Return
//    bbmp : 描画対象(描画結果)
//
-(void)drawPoint:(PoCoPoint *)p
          bitmap:(unsigned char *)bbmp
       bitmapRow:(const int)brow
         pattern:(const unsigned char *)pbmp
      patternRow:(const int)prow
{
    PoCoPoint *dp = [[PoCoPoint alloc] initX:[p x] initY:[p y]];
    int i;
    int l;

    DPRINT((@"[PoCoEditUniformedDensityDrawLine11 drawPoint:]\n"));

    bbmp -= (((brow << 2) + brow) + 1);
    pbmp -= (((prow << 2) + prow) + 1);
    [dp moveX:-1 moveY:-5];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 4; l++) {
        (bbmp)++; (pbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:self->density_
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 5); pbmp += (prow - 5); [dp moveX:-5 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 6; l++) {
        (bbmp)++; (pbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:self->density_
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 7); pbmp += (prow - 7); [dp moveX:-7 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 8; l++) {
        (bbmp)++; (pbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:self->density_
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 9); pbmp += (prow - 9); [dp moveX:-9 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 10; l++) {
        (bbmp)++; (pbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:self->density_
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    for (i = 0; i < 4; i++) {
        bbmp += (brow - 10); pbmp += (prow - 10); [dp moveX:-10 moveY:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:self->density_
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
        for (l = 0; l < 10; l++) {
            (bbmp)++; (pbmp)++; [dp moveX:1];
            if (([self->drawRect_ isPointInRect:dp]) &&
                (![[self->palette_ palette:*(bbmp)] isMask])) {
                *(bbmp) = [super calcColor:self->density_
                                color1:*(bbmp)
                                color2:*(pbmp)];
            }
        }
    }

    bbmp += (brow - 9); pbmp += (prow - 9); [dp moveX:-9 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 8; l++) {
        (bbmp)++; (pbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:self->density_
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 7); pbmp += (prow - 7); [dp moveX:-7 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 6; l++) {
        (bbmp)++; (pbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:self->density_
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 5); pbmp += (prow - 5); [dp moveX:-5 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 4; l++) {
        (bbmp)++; (pbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:self->density_
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    [dp release];
    return;
}

@end
