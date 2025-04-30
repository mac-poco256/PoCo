//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 均一濃度 - 直線(13dot)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditUniformedDensityDrawLine13.h"

// ============================================================================
@implementation PoCoEditUniformedDensityDrawLine13

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
    DPRINT((@"[PoCoEditUniformedDensityDrawLine13 init]\n"));

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
    DPRINT((@"[PoCoEditUniformedDensityDrawLine13 dealloc]\n"));

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
    return 7;
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

    DPRINT((@"[PoCoEditUniformedDensityDrawLine13 drawPoint:]\n"));

    bbmp -= (((brow << 2) + (brow << 1)) + 2);
    pbmp -= (((prow << 2) + (prow << 1)) + 2);
    [dp moveX:-2 moveY:-6];
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

    bbmp += (brow - 11); pbmp += (prow - 11); [dp moveX:-11 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 12; l++) {
        (bbmp)++; (pbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:self->density_
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    for (i = 0; i < 4; i++) {
        bbmp += (brow - 12); pbmp += (prow - 12); [dp moveX:-12 moveY:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:self->density_
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
        for (l = 0; l < 12; l++) {
            (bbmp)++; (pbmp)++; [dp moveX:1];
            if (([self->drawRect_ isPointInRect:dp]) &&
                (![[self->palette_ palette:*(bbmp)] isMask])) {
                *(bbmp) = [super calcColor:self->density_
                                    color1:*(bbmp)
                                    color2:*(pbmp)];
            }
        }
    }

    bbmp += (brow - 11); pbmp += (prow - 11); [dp moveX:-11 moveY:1];
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
