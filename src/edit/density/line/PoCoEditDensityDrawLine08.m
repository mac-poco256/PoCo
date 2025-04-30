//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 濃度 - 直線(8dot)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditDensityDrawLine08.h"

// ============================================================================
@implementation PoCoEditDensityDrawLine08

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
    DPRINT((@"[PoCoEditDensityDrawLine08 init]\n"));

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
    DPRINT((@"[PoCoEditDensityDrawLine08 dealloc]\n"));

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
    return 4;
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
         0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, //  2
         0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, //  3
         0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  0,  0,  0,  0,  0,  0, //  4
         0,  0,  0,  0,  0,  1,  2,  3,  3,  2,  1,  0,  0,  0,  0,  0, //  5
         0,  0,  0,  0,  1,  2,  5,  7,  7,  5,  2,  1,  0,  0,  0,  0, //  6
         0,  0,  0,  0,  1,  3,  7, 10, 10,  7,  3,  1,  0,  0,  0,  0, //  7
         0,  0,  0,  0,  1,  3,  7, 10, 10,  7,  3,  1,  0,  0,  0,  0, //  8
         0,  0,  0,  0,  1,  2,  5,  7,  7,  5,  2,  1,  0,  0,  0,  0, //  9
         0,  0,  0,  0,  0,  1,  2,  3,  3,  2,  1,  0,  0,  0,  0,  0, // 10
         0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  0,  0,  0,  0,  0,  0, // 11
         0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, // 12
         0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, // 13
         0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, // 14
         0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, // 15
    };
    static  const int drow = 16;
    PoCoPoint *dp = [[PoCoPoint alloc] initX:[p x] initY:[p y]];
    int i;
    int l;
    const unsigned char *dbmp = den_tbl;

    DPRINT((@"[PoCoEditDensityDrawLine08 drawPoint:]\n"));

    bbmp -= (((brow << 1) + brow) + 1);
    pbmp -= (((prow << 1) + prow) + 1);
    dbmp += ((drow << 2) + 6);
    [dp moveX:-1 moveY:-3];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }

    bbmp += (brow - 4); pbmp += (prow - 4); dbmp += (drow - 4);
    [dp moveX:-4 moveY:1];
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

    bbmp += (brow - 6); pbmp += (prow - 6); dbmp += (drow - 6);
    [dp moveX:-6 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 7; l++) {
        (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
    }

    for (i = 0; i < 3; i++) {
        bbmp += (brow - 7); pbmp += (prow - 7); dbmp += (drow - 7);
        [dp moveX:-7 moveY:1];
        if (([self->drawRect_ isPointInRect:dp]) &&
            (![[self->palette_ palette:*(bbmp)] isMask])) {
            *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                color1:*(bbmp)
                                color2:*(pbmp)];
        }
        for (l = 0; l < 7; l++) {
            (bbmp)++; (pbmp)++; (dbmp)++; [dp moveX:1];
            if (([self->drawRect_ isPointInRect:dp]) &&
                (![[self->palette_ palette:*(bbmp)] isMask])) {
                *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                                    color1:*(bbmp)
                                    color2:*(pbmp)];
            }
        }
    }

    bbmp += (brow - 6); pbmp += (prow - 6); dbmp += (drow - 6);
    [dp moveX:-6 moveY:1];
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

    bbmp += (brow - 4); pbmp += (prow - 4); dbmp += (drow - 4);
    [dp moveX:-4 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:((*(dbmp) * self->density_) / 10)
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    for (l = 0; l < 3; l++) {
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
