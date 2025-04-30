//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 均一濃度 - 直線(6dot)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditUniformedDensityDrawLine06.h"

// ============================================================================
@implementation PoCoEditUniformedDensityDrawLine06

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
    DPRINT((@"[PoCoEditUniformedDensityDrawLine06 init]\n"));

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
    DPRINT((@"[PoCoEditUniformedDensityDrawLine06 dealloc]\n"));

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

    DPRINT((@"[PoCoEditUniformedDensityDrawLine06 drawPoint:]\n"));

    bbmp -= (brow << 1); pbmp -= (prow << 1); [dp moveY:-2];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }

    bbmp += (brow - 2); pbmp += (prow - 2); [dp moveX:-2 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }

    bbmp += (brow - 4); pbmp += (prow - 4); [dp moveX:-4 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }

    bbmp += (brow - 5); pbmp += (prow - 5); [dp moveX:-5 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }

    bbmp += (brow - 4); pbmp += (prow - 4); [dp moveX:-4 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }

    bbmp += (brow - 2); pbmp += (prow - 2); [dp moveX:-2 moveY:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }
    (bbmp)++; (pbmp)++; [dp moveX:1];
    if (([self->drawRect_ isPointInRect:dp]) &&
        (![[self->palette_ palette:*(bbmp)] isMask])) {
        *(bbmp) = [super calcColor:self->density_
                            color1:*(bbmp)
                            color2:*(pbmp)];
    }

    [dp release];
    return;
}

@end
