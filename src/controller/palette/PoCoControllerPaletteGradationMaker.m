//
//	Pelistina on Cocoa - PoCo -
//	パレットグラデーション生成部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerPaletteGradationMaker.h"

#import "PoCoPalette.h"
#import "PoCoControllerFactory.h"
#import "PoCoControllerPaletteElementSetter.h"
#import "PoCoColorBuffer.h"

// ============================================================================
@implementation PoCoControllerPaletteGradationMaker

// --------------------------------------------------------- instance - private
//
// RGB 系で生成
//
//  Call
//    picture_  : 編集対象画像(基底 instance 変数)
//    startNum_ : 始点色番号(instance 変数)
//    endNum_   : 終点色番号(instance 変数)
//
//  Return
//    None
//
-(void)createRGB
{
    int idx;                            // 対象色番号
    int num;                            // 操作回数
    int rstep;
    int gstep;
    int bstep;
    int st = (self->endNum_ - self->startNum_);
    PoCoPalette *palette = [self->picture_ palette];
    PoCoColor *sc = [palette palette:self->startNum_];
    PoCoColor *ec = [palette palette:self->endNum_];
    int r = (int)([sc red]);
    int g = (int)([sc green]);
    int b = (int)([sc blue]);

    // 変量を算出
    rstep = ((((int)([ec red])   - (int)([sc red]))   << 8) / st);
    gstep = ((((int)([ec green]) - (int)([sc green])) << 8) / st);
    bstep = ((((int)([ec blue])  - (int)([sc blue]))  << 8) / st);

    // (startNum_, endNum_) の範囲の値を設定
    for (idx = (self->startNum_ + 1), num = 1;
         idx < self->endNum_;
         (idx)++, (num)++) {
        [[palette palette:idx] setRed:(unsigned char)(r + ((rstep * num) >> 8))
                             setGreen:(unsigned char)(g + ((gstep * num) >> 8))
                              setBlue:(unsigned char)(b + ((bstep * num) >> 8))];
    }

    return;
}


//
// HLS 系で生成
//
//  Call
//    picture_  : 編集対象画像(基底 instance 変数)
//    startNum_ : 始点色番号(instance 変数)
//    endNum_   : 終点色番号(instance 変数)
//
//  Return
//    None
//
-(void)createHLS
{
    int idx;                            // 対象色番号
    int num;                            // 操作回数
    int hs;
    int ls;
    int ss;
    int st = (self->endNum_ - self->startNum_);
    PoCoPalette *palette = [self->picture_ palette];
    PoCoColor *sc = [palette palette:self->startNum_];
    PoCoColor *ec = [palette palette:self->endNum_];
    int h = (int)([sc hue]);
    int l = (int)([sc lightness]);
    int s = (int)([sc saturation]);

    // 明度の変量を算出
    ls = ((((int)([ec lightness]) - (int)([sc lightness])) << 8) / st);

    if ([sc saturation] == 0) {
        // (startNum_, endNum_) の範囲の値を設定(終了側の色で固定)
        for (idx = (self->startNum_ + 1), num = 1;
             idx < self->endNum_;
             (idx)++, (num)++) {
            [[palette palette:idx] setHue:[ec hue]
                             setLightness:(unsigned char)(l + ((ls * num) >> 8))
                            setSaturation:[ec saturation]];
        }
    } else if ([ec saturation] == 0) {
        // (startNum_, endNum_) の範囲の値を設定(開始側の色で固定)
        for (idx = (self->startNum_ + 1), num = 1;
             idx < self->endNum_;
             (idx)++, (num)++) {
            [[palette palette:idx] setHue:[sc hue]
                             setLightness:(unsigned char)(l + ((ls * num) >> 8))
                            setSaturation:[sc saturation]];
        }
    } else {
        // 彩度の変量を算出
        ss = ((((int)([ec saturation]) - (int)([sc saturation])) << 8) / st);

        // 色相の変量を算出
        hs = ((int)([ec hue]) - (int)([sc hue]));
        if(hs != 0){
            if (hs < -128) {
                hs = (255 - ((int)([sc hue]) - (int)([ec hue])));
            } else if (hs > 128) {
                hs = ((int)([ec hue]) - (int)([sc hue]) - 255);
            }
            hs = ((hs << 8) / st);
        }

        // (startNum_, endNum_) の範囲の値を設定
        for (idx = (self->startNum_ + 1), num = 1;
             idx < self->endNum_;
             (idx)++, (num)++) {
            [[palette palette:idx] setHue:(unsigned char)(h + ((hs * num) >> 8))
                             setLightness:(unsigned char)(l + ((ls * num) >> 8))
                            setSaturation:(unsigned char)(s + ((ss * num) >> 8))];
        }
    }

    return;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    buf  : 色保持情報
//    s    : 始点色番号
//    e    : 終点色番号
//
//  Return
//    function     : 実体
//    startNum_    : 始点色番号(instance 変数)
//    endNum_      : 終点色番号(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
 startNum:(int)s
   endNum:(int)e
{
//    DPRINT((@"[PoCoControllerPaletteGradationMaker init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo];

    // 自身の初期化
    if (self != nil) {
        self->startNum_ = MIN(s, e);
        self->endNum_ = MAX(s, e);
        self->colorBuffer_ = buf;
        [self->colorBuffer_ retain];
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
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerPaletteGradationMaker dealloc]\n"));

    // 資源の解放
    [self->colorBuffer_ release];
    self->colorBuffer_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    editInfo_ : 編集情報(基底 instance 変数）
//    startNum_ : 始点色番号(instance 変数)
//    endNum_   : 終点色番号(instance 変数)
//
//  Return
//    function     : 編集正否
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(BOOL)execute
{
    BOOL  result;

//    DPRINT((@"[PoCoControllerPaletteGradationMaker execute]\n"));

    result = NO;

    if (self->startNum_ >= self->endNum_) {
        // 色の指定がおかしい
        ;
    } else {
        // 取り消しを生成
        [self createUndo];

        // 色演算方法で分岐
        switch ([self->editInfo_ colorMode]) {
            case PoCoColorMode_RGB:
            default:
                // RGB 系(不定時も RGB 系で生成する)
                [self createRGB];
                break;
            case PoCoColorMode_HLS:
                // HLS 系
                [self createHLS];
                break;
        }
        result = YES;

        // パレットの更新を通知
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoChangePalette
                          object:nil];

        // 色保持情報を初期化
        [self->colorBuffer_ reset:nil];
    }

    return result;
}


//
// 取り消しの生成
//
//  Call
//    picture_     : 編集対象画像(基底 instance 変数)
//    undoManager_ : 取り消し情報(基底 instance 変数)
//    factory_     : 編集部の生成部(基底 instance 変数)
//
//  Return
//    None
//
-(void)createUndo
{
    [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
        createPaletteElementSetter:YES
                           palette:[[self->picture_ palette] copy]];
    [super setUndoName:[[NSBundle mainBundle]
                           localizedStringForKey:@"PaletteGradation"
                                           value:@"make gradation palette"
                                           table:nil]];

    return;
}
  
@end
