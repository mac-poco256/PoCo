//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - ぼかし - 領域塗りつぶし
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoEditWaterDropFill.h"

#import "PoCoColorMixer.h"

// ============================================================================
@implementation PoCoEditWaterDropFill

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
    DPRINT((@"[PoCoEditWaterDropFill init]\n"));

    // super class の初期化
    self = [super initWithBitmap:bmp
                         colMode:cmode
                         palette:plt
                          buffer:buf];

    // 自身の初期化
    if (self != nil) {
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
    DPRINT((@"[PoCoEditWaterDropFill dealloc]\n"));

    // 資源の解放
    ;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//
//  Call
//    mask       : 形状
//    tile       : タイルパターン
//    trueRect   : 描画範囲(画像範囲外含む)
//    drawRect   : 描画範囲(画像範囲内のみ)
//    srcBitmap_ : 描画元(複製)(instance 変数)
//
//  Return
//    None
//
-(void)executeDraw:(PoCoBitmap *)mask
          withTile:(PoCoMonochromePattern *)tile
      withTrueRect:(PoCoRect *)trueRect
      withDrawRect:(PoCoRect *)drawRect
{
    PoCoRect *tr;
    PoCoRect *dr;
    PoCoPoint *p;
    int mrow;                           // 形状の rowbytes
    int mskip;                          // 形状の次の行までのアキ
    const unsigned char *mbmp;          // 形状の走査用

    tr = nil;
    dr = nil;

    // 描画領域なし
    if ([drawRect empty]) {
        goto EXIT;
    }

    // half-open property にするので右下に +1
    tr = [[PoCoRect alloc] initLeft:[trueRect left]
                            initTop:[trueRect top]
                          initRight:([trueRect right] + 1)
                         initBottom:([trueRect bottom] + 1)];
    dr = [[PoCoRect alloc] initLeft:[drawRect left]
                            initTop:[drawRect top]
                          initRight:([drawRect right] + 1)
                         initBottom:([drawRect bottom] + 1)];
    if ([self->srcBitmap_ width] < [dr right]) {
        [dr setRight:[self->srcBitmap_ width]];
    }
    if ([self->srcBitmap_ height] < [dr bottom]) {
        [dr setBottom:[self->srcBitmap_ height]];
    }

    // 各種値の算出
    mrow = ([mask width] + ([mask width] & 1));
    mskip = (mrow - [tr width]);

    // 各種走査用ビットマップを取得
    mbmp = [mask pixelmap];

    // 走査/描画
    p = [[PoCoPoint alloc] init];
    for ([p setY:[tr top]]; [p y] < [tr bottom]; [p moveY:1]) {
        for ([p setX:[tr left]]; [p x] < [tr right]; [p moveX:1]) {
            if (([dr isPointInRect:p]) &&
                (*(mbmp) != 0)) {
                [super calcColor:p
                    withDrawRect:dr
                        withMask:mask];
            }

            // 次へ
            (mbmp)++;
        }

        // 次へ
        mbmp += mskip;
    }
    [p release];

EXIT:
    [tr release];
    [dr release];
    return;
}

@end
