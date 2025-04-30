//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 濃度 - 直線(16dot)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditDensityDrawLine16.h"

// ============================================================================
@implementation PoCoEditDensityDrawLine16

// ----------------------------------------------------------------------------
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
    DPRINT((@"[PoCoEditDensityDrawLine16 init]\n"));

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
    DPRINT((@"[PoCoEditDensityDrawLine16 dealloc]\n"));

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
    return 8;
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
//
-(void)drawPoint:(PoCoPoint *)p
          bitmap:(unsigned char *)bbmp
       bitmapRow:(const int)brow
         pattern:(const unsigned char *)pbmp
      patternRow:(const int)prow
{
    static  const unsigned char den_tbl[] = {
      // 0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15
         0,  0,  0,  0,  0,  1,  1,  1,  1,  1,  1,  0,  0,  0,  0,  0, //  0
         0,  0,  0,  1,  1,  2,  2,  2,  2,  2,  2,  1,  1,  0,  0,  0, //  1
         0,  0,  1,  2,  2,  3,  3,  3,  3,  3,  3,  2,  2,  1,  0,  0, //  2
         0,  1,  2,  3,  3,  4,  4,  4,  4,  4,  4,  3,  3,  2,  1,  0, //  3
         0,  1,  2,  3,  4,  5,  5,  6,  6,  5,  5,  4,  3,  2,  1,  0, //  4
         1,  2,  3,  4,  5,  6,  7,  8,  8,  7,  6,  5,  4,  3,  2,  1, //  5
         1,  2,  3,  4,  6,  7,  8,  9,  9,  8,  7,  6,  4,  3,  2,  1, //  6
         1,  2,  3,  4,  6,  8,  9, 10, 10,  9,  8,  6,  4,  3,  2,  1, //  7
         1,  2,  3,  4,  6,  8,  9, 10, 10,  9,  8,  6,  4,  3,  2,  1, //  8
         1,  2,  3,  4,  6,  7,  8,  9,  9,  8,  7,  6,  4,  3,  2,  1, //  9
         1,  2,  3,  4,  5,  6,  7,  8,  8,  7,  6,  5,  4,  3,  2,  1, // 10
         0,  1,  2,  3,  4,  5,  6,  6,  6,  6,  5,  4,  3,  2,  1,  0, // 11
         0,  1,  2,  3,  3,  4,  4,  4,  4,  4,  4,  3,  3,  2,  1,  0, // 12
         0,  0,  1,  2,  2,  3,  3,  3,  3,  3,  3,  2,  2,  1,  0,  0, // 13
         0,  0,  0,  1,  1,  2,  2,  2,  2,  2,  2,  1,  1,  0,  0,  0, // 14
         0,  0,  0,  0,  0,  1,  1,  1,  1,  1,  1,  0,  0,  0,  0,  0  // 15
    };
    static  const int drow = 16;
    PoCoPoint *dp = [[PoCoPoint alloc] initX:[p x] initY:[p y]];
    int i;
    int l;
    const unsigned char *dbmp = den_tbl;

    DPRINT((@"[PoCoEditDensityDrawLine16 drawPoint:]\n"));

    bbmp -= ((brow << 3) + 3);
    pbmp -= ((prow << 3) + 3);
    dbmp += 5;
    [dp moveX:-3 moveY:-8];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 5; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 7); pbmp += (prow - 7); dbmp += (drow - 7);
    [dp moveX:-7 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 9; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 10); pbmp += (prow - 10); dbmp += (drow - 10);
    [dp moveX:-10 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 11; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 12); pbmp += (prow - 12); dbmp += (drow - 12);
    [dp moveX:-12 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 13; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 13); pbmp += (prow - 13); dbmp += (drow - 13);
    [dp moveX:-13 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 13; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 14); pbmp += (prow - 14); dbmp += (drow - 14);
    [dp moveX:-14 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 15; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    for (i = 0; i < 5; i++) {
        bbmp += (brow - 15); pbmp += (prow - 15); dbmp += (drow - 15);
        [dp moveX:-15 moveY:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
        for (l = 0; l < 15; l++) {
            (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
            if (([self->drawRect_ isPointInRect:dp]) &&
                (![[self->palette_ palette:*(bbmp)] isMask])) {
                 *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                     color1:*(bbmp)
                                     color2:*(pbmp)];
            }
        }
    }

    bbmp += (brow - 14); pbmp += (prow - 14); dbmp += (drow - 14);
    [dp moveX:-14 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 13; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 13); pbmp += (prow - 13); dbmp += (drow - 13);
    [dp moveX:-13 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 13; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 12); pbmp += (prow - 12); dbmp += (drow - 12);
    [dp moveX:-12 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 11; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 10); pbmp += (prow - 10); dbmp += (drow - 10);
    [dp moveX:-10 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 9; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 7); pbmp += (prow - 7); dbmp += (drow - 7);
    [dp moveX:-7 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 5; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    [dp release];
    return;
}

@end
