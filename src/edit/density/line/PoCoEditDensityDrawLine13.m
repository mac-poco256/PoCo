//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 濃度 - 直線(13dot)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditDensityDrawLine13.h"

// ============================================================================
@implementation PoCoEditDensityDrawLine13

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
    DPRINT((@"[PoCoEditDensityDrawLine13 init]\n"));

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
    DPRINT((@"[PoCoEditDensityDrawLine13 dealloc]\n"));

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
    static  const unsigned char den_tbl[] = {
      // 0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15
         0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, //  0
         0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, //  1
         0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  1,  0,  0,  0,  0,  0, //  2
         0,  0,  0,  0,  0,  1,  2,  2,  2,  2,  2,  1,  0,  0,  0,  0, //  3
         0,  0,  0,  0,  1,  2,  3,  4,  4,  4,  3,  2,  1,  0,  0,  0, //  4
         0,  0,  0,  1,  2,  4,  5,  5,  6,  5,  5,  4,  2,  1,  0,  0, //  5
         0,  0,  1,  2,  3,  5,  6,  7,  7,  7,  6,  5,  3,  2,  1,  0, //  6
         0,  0,  1,  2,  4,  5,  7,  8,  9,  8,  7,  5,  4,  2,  1,  0, //  7
         0,  0,  1,  2,  4,  6,  7,  9, 10,  9,  7,  6,  4,  2,  1,  0, //  8
         0,  0,  1,  2,  4,  5,  7,  8,  9,  8,  7,  5,  4,  2,  1,  0, //  9
         0,  0,  1,  2,  3,  5,  6,  7,  7,  7,  6,  5,  3,  2,  1,  0, // 10
         0,  0,  0,  1,  2,  4,  5,  5,  6,  5,  5,  4,  2,  1,  0,  0, // 11
         0,  0,  0,  0,  1,  2,  3,  4,  4,  4,  3,  2,  1,  0,  0,  0, // 12
         0,  0,  0,  0,  0,  1,  2,  2,  2,  2,  2,  1,  0,  0,  0,  0, // 13
         0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  1,  0,  0,  0,  0,  0, // 14
         0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0  // 15
    };
    static  const int drow = 16;
    PoCoPoint *dp = [[PoCoPoint alloc] initX:[p x] initY:[p y]];
    int i;
    int l;
    const unsigned char *dbmp = den_tbl;

    DPRINT((@"[PoCoEditDensityDrawLine13 drawPoint:]\n"));

    bbmp -= (((brow << 2) + (brow << 1)) + 2);
    pbmp -= (((prow << 2) + (prow << 1)) + 2);
    dbmp += ((drow << 1) + 6);
    [dp moveX:-2 moveY:-6];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 4; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 5); pbmp += (prow - 5); dbmp += (drow - 5);
    [dp moveX:-5 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 6; l++) {
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
    for (l = 0; l < 8; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 9); pbmp += (prow - 9); dbmp += (drow - 9);
    [dp moveX:-9 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 10; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 11); pbmp += (prow - 11); dbmp += (drow - 11);
    [dp moveX:-11 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 12; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    for (i = 0; i < 4; i++) {
        bbmp += (brow - 12); pbmp += (prow - 12); dbmp += (drow - 12);
        [dp moveX:-12 moveY:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
        for (l = 0; l < 12; l++) {
            (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
            if (([self->drawRect_ isPointInRect:dp]) &&
                (![[self->palette_ palette:*(bbmp)] isMask])) {
                *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                    color1:*(bbmp)
                                    color2:*(pbmp)];
            }
        }
    }

    bbmp += (brow - 11); pbmp += (prow - 11); dbmp += (drow - 11);
    [dp moveX:-11 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 10; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 9); pbmp += (prow - 9); dbmp += (drow - 9);
    [dp moveX:-9 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 8; l++) {
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
    for (l = 0; l < 6; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    bbmp += (brow - 5); pbmp += (prow - 5); dbmp += (drow - 5);
    [dp moveX:-5 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 4; l++) {
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
