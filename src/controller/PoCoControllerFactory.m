//
//	Pelistina on Cocoa - PoCo -
//	編集部生成部
//
//	Copyright (C) 2005-2019 KAENRYUU Koutoku.
//

#import "PoCoControllerFactory.h"

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"
#import "PoCoMyDocument.h"
#import "PoCoPicture.h"
#import "PoCoPalette.h"
#import "PoCoLayer.h"
#import "PoCoColorBuffer.h"
#import "PoCoCalcRotation.h"

// 各 controller
#import "PoCoControllerLayerNoEditter.h"
#import "PoCoControllerPaletteNoEditter.h"
#import "PoCoControllerResizeNoEditter.h"
#import "PoCoControllerClipNoEditter.h"

#import "PoCoControllerPaletteIncrementer.h"
#import "PoCoControllerPaletteDecrementer.h"
#import "PoCoControllerPaletteAttributeSetter.h"
#import "PoCoControllerPaletteGradationMaker.h"
#import "PoCoControllerPaletteElementSetter.h"
#import "PoCoControllerPaletteImporter.h"
#import "PoCoControllerPaletteSingleSetter.h"

#import "PoCoControllerPictureColorExchanger.h"
#import "PoCoControllerPictureColorPaster.h"
#import "PoCoControllerPictureLayerUnificater.h"
#import "PoCoControllerPictureCanvasResizer.h"
#import "PoCoControllerPictureImageClipper.h"
#import "PoCoControllerPictureBitmapReplacer.h"

#import "PoCoControllerLayerBitmapAdder.h"
#import "PoCoControllerLayerStringAdder.h"
#import "PoCoControllerLayerDeleter.h"
#import "PoCoControllerLayerInserter.h"
#import "PoCoControllerLayerMover.h"
#import "PoCoControllerLayerDisplaySetter.h"
#import "PoCoControllerLayerLockSetter.h"
#import "PoCoControllerLayerNameSetter.h"

#import "PoCoControllerColorPatternSetter.h"

#import "PoCoControllerInvertLineEditter.h"
#import "PoCoControllerInvertPolylineEditter.h"
#import "PoCoControllerInvertPolygonFrameEditter.h"

#import "PoCoControllerInvertCurveWithPointsEditter.h"
#import "PoCoControllerNormalCurveWithPointsEditter.h"
#import "PoCoControllerUniformedDensityCurveWithPointsEditter.h"
#import "PoCoControllerDensityCurveWithPointsEditter.h"
#import "PoCoControllerAtomizerCurveWithPointsEditter.h"
#import "PoCoControllerGradationCurveWithPointsEditter.h"
#import "PoCoControllerRandomCurveWithPointsEditter.h"
#import "PoCoControllerWaterDropCurveWithPointsEditter.h"

#import "PoCoControllerInvertBoxFrameEditter.h"
#import "PoCoControllerNormalBoxFrameEditter.h"
#import "PoCoControllerUniformedDensityBoxFrameEditter.h"
#import "PoCoControllerDensityBoxFrameEditter.h"
#import "PoCoControllerAtomizerBoxFrameEditter.h"
#import "PoCoControllerGradationBoxFrameEditter.h"
#import "PoCoControllerRandomBoxFrameEditter.h"
#import "PoCoControllerWaterDropBoxFrameEditter.h"

#import "PoCoControllerInvertEllipseFrameEditter.h"
#import "PoCoControllerNormalEllipseFrameEditter.h"
#import "PoCoControllerUniformedDensityEllipseFrameEditter.h"
#import "PoCoControllerDensityEllipseFrameEditter.h"
#import "PoCoControllerAtomizerEllipseFrameEditter.h"
#import "PoCoControllerGradationEllipseFrameEditter.h"
#import "PoCoControllerRandomEllipseFrameEditter.h"
#import "PoCoControllerWaterDropEllipseFrameEditter.h"

#import "PoCoControllerInvertParallelogramFrameEditter.h"
#import "PoCoControllerNormalParallelogramFrameEditter.h"
#import "PoCoControllerUniformedDensityParallelogramFrameEditter.h"
#import "PoCoControllerDensityParallelogramFrameEditter.h"
#import "PoCoControllerAtomizerParallelogramFrameEditter.h"
#import "PoCoControllerGradationParallelogramFrameEditter.h"
#import "PoCoControllerRandomParallelogramFrameEditter.h"
#import "PoCoControllerWaterDropParallelogramFrameEditter.h"

#import "PoCoControllerNormalBoxFillEditter.h"
#import "PoCoControllerUniformedDensityBoxFillEditter.h"
#import "PoCoControllerDensityBoxFillEditter.h"
#import "PoCoControllerAtomizerBoxFillEditter.h"
#import "PoCoControllerGradationBoxFillEditter.h"
#import "PoCoControllerRandomBoxFillEditter.h"
#import "PoCoControllerWaterDropBoxFillEditter.h"

#import "PoCoControllerNormalEllipseFillEditter.h"
#import "PoCoControllerUniformedDensityEllipseFillEditter.h"
#import "PoCoControllerDensityEllipseFillEditter.h"
#import "PoCoControllerAtomizerEllipseFillEditter.h"
#import "PoCoControllerGradationEllipseFillEditter.h"
#import "PoCoControllerRandomEllipseFillEditter.h"
#import "PoCoControllerWaterDropEllipseFillEditter.h"

#import "PoCoControllerNormalParallelogramFillEditter.h"
#import "PoCoControllerUniformedDensityParallelogramFillEditter.h"
#import "PoCoControllerDensityParallelogramFillEditter.h"
#import "PoCoControllerAtomizerParallelogramFillEditter.h"
#import "PoCoControllerGradationParallelogramFillEditter.h"
#import "PoCoControllerRandomParallelogramFillEditter.h"
#import "PoCoControllerWaterDropParallelogramFillEditter.h"

#import "PoCoControllerNormalProportionalFreeLineEditter.h"
#import "PoCoControllerUniformedDensityProportionalFreeLineEditter.h"
#import "PoCoControllerDensityProportionalFreeLineEditter.h"
#import "PoCoControllerAtomizerProportionalFreeLineEditter.h"
#import "PoCoControllerGradationProportionalFreeLineEditter.h"
#import "PoCoControllerRandomProportionalFreeLineEditter.h"
#import "PoCoControllerWaterDropProportionalFreeLineEditter.h"

#import "PoCoControllerInvertRegionFillEditter.h"
#import "PoCoControllerInvertRegionBorderEditter.h"
#import "PoCoControllerNormalPaintEditter.h"
#import "PoCoControllerNormalPasteImageEditter.h"

// ============================================================================
@implementation PoCoControllerFactory

// --------------------------------------------------------- instance - private
//
// 編集対象画像を取得
//
//  Call
//    None
//
//  Return
//    function : 編集対象画像
//
-(id)getPict
{
    return [[[NSDocumentController sharedDocumentController] currentDocument] picture];
}


//
// 編集情報を取得
//
//  Call
//    None
//
//  Return
//    function : 編集情報
//
-(id)getInfo
{
    return [(PoCoAppController *)([NSApp delegate]) editInfo];
}


//
// 取り消し情報を取得
//
//  Call
//    None
//
//  Return
//    function : 取り消し情報
//
-(id)getUndo
{
    return [[[NSDocumentController sharedDocumentController] currentDocument] undoManager];
}


//
// 色保持情報を取得
//
//  Call
//    None
//
//  Return
//    function : 色保持情報
//
-(id)getColorBuffer
{
    return [[[NSDocumentController sharedDocumentController] currentDocument] colorBuffer];
}


//
// 消しゴム用画像を取得
//
//  Call
//    None
//
//  Return
//    function : 消しゴム用画像
//
-(id)getEraser
{
    return [[[NSDocumentController sharedDocumentController] currentDocument] eraser];
}


//
// ペン先を取得
//
//  Call
//    None
//
//  Return
//    function : ペン先
//
-(id)getPen
{
    return [(PoCoAppController *)([NSApp delegate]) penStyle];
}


//
// タイルパターンを取得
//
//  Call
//    None
//
//  Return
//    function : タイルパターン
//
-(id)getTile
{
    return [(PoCoAppController *)([NSApp delegate]) tilePattern];
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function : 実体
//
-(id)init
{
    DPRINT((@"[PoCoControllerFactory init]\n"));

    // super class の初期化
    self = [super init];

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
    DPRINT((@"[PoCoControllerFactory dealloc]\n"));

    // super class の解放
    [super dealloc];

    return;
}


//
// レイヤー構造更新無編集通知
//  controller を passive で呼んだ場合に、最後に通知を投げる為のもの
//
//  Call
//    exec   : 実行
//    name   : 取り消し名称
//    update : レイヤー構造の更新か
//
//  Return
//    function : 編集部の実体
//
-(id)createLayerNoEditter:(BOOL)exec
                     name:(NSString *)name
                   update:(BOOL)update
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerLayerNoEditter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
               name:name
             update:update];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerLayerNoEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// パレット更新無編集通知
//  controller を passive で呼んだ場合に、最後に通知を投げる為のもの
//
//  Call
//    exec  : 実行
//    name  : 取り消し名称
//    index : 対象パレット番号
//
//  Return
//    function : 編集部の実体
//
-(id)createPaletteNoEditter:(BOOL)exec
                       name:(NSString *)name
                      index:(int)index
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerPaletteNoEditter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
               name:name
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerPaletteNoEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 画像サイズ変更無編集通知
//  controller を passive で呼んだ場合に、最後に通知を投げる為のもの
//
//  Call
//    exec : 実行
//    name : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createResizeNoEditter:(BOOL)exec
                      name:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerResizeNoEditter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
               name:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerResizeNoEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 切り抜き無編集通知
//  controller を passive で呼んだ場合に、最後に通知を投げる為のもの
//
//  Call
//    exec : 実行
//    name : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createClipNoEditter:(BOOL)exec
                    name:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerClipNoEditter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
               name:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerClipNoEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// パレット要素値の加算
//
//  Call
//    exec : 実行
//    n    : 対象色番号
//    r    : 赤要素を対象にするか
//    g    : 緑要素を対象にするか
//    b    : 青要素を対象にするか
//    s    : 増減値
//
//  Return
//    function : 編集部の実体
//
-(id)createPaletteIncrementer:(BOOL)exec
                          num:(int)n
                          red:(BOOL)r
                        green:(BOOL)g
                         blue:(BOOL)b
                         step:(unsigned int)s
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerPaletteIncrementer alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
             buffer:[self getColorBuffer]
                num:n
                red:r
              green:g
               blue:b
               step:s];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerPaletteIncrementer.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// パレット要素値の減算
//
//  Call
//    exec : 実行
//    n    : 対象色番号
//    r    : 赤要素を対象にするか
//    g    : 緑要素を対象にするか
//    b    : 青要素を対象にするか
//    s    : 増減値
//
//  Return
//    function : 編集部の実体
//
-(id)createPaletteDecrementer:(BOOL)exec
                          num:(int)n
                          red:(BOOL)r
                        green:(BOOL)g
                         blue:(BOOL)b
                         step:(unsigned int)s
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerPaletteDecrementer alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
             buffer:[self getColorBuffer]
                num:n
                red:r
              green:g
               blue:b
               step:s];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerPaletteDecrementer.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// パレット補助属性の設定(1色ごとの設定)
//
//  Call
//    exec : 実行
//    n    : 対象色番号
//    s    : 設定内容(flag の上げ下げ)
//    m    : 上塗り禁止を対象とするか
//    d    : 吸い取り禁止を対象とするか
//    t    : 透過を対象とするか
//
//  Return
//    function : 編集部の実体
//
-(id)createPaletteAttributeSetter:(BOOL)exec
                              num:(int)n
                          setType:(BOOL)s
                             mask:(BOOL)m
                          dropper:(BOOL)d
                            trans:(BOOL)t
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerPaletteAttributeSetter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
             buffer:[self getColorBuffer]
            withNum:n
            setType:s
               mask:m
            dropper:d
              trans:t];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerPaletteAttributeSetter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// パレット補助属性の設定(一括設定)
//
//  Call
//    exec : 実行
//    s    : 対象色番号始点
//    e    : 対象色番号終点
//    m    : 上塗り禁止の設定内容(配列)
//    d    : 吸い取り禁止の設定内容(配列)
//    t    : 透過の設定内容(配列)
//
//  Return
//    function : 編集部の実体
//
-(id)createPaletteAttributeSetter:(BOOL)exec
                            start:(int)s
                              end:(int)e
                             mask:(const BOOL *)m
                          dropper:(const BOOL *)d
                            trans:(const BOOL *)t
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerPaletteAttributeSetter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
             buffer:[self getColorBuffer]
          withStart:s
            withEnd:e
               mask:m
            dropper:d
              trans:t];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerPaletteAttributeSetter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// パレットグラデーションの生成
//
//  Call
//    exec : 実行
//    s    : 始点色番号
//    e    : 終点色番号
//
//  Return
//    function : 編集部の実体
//
-(id)createPaletteGradationMaker:(BOOL)exec
                           start:(int)s
                             end:(int)e
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerPaletteGradationMaker alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
             buffer:[self getColorBuffer]
           startNum:s
             endNum:e];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerPaletteGradationMaker.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// パレット要素設定
//
//  Call
//    exec    : 実行
//    palette : 設定内容
//
//  Return
//    function : 編集部の実体
//
-(id)createPaletteElementSetter:(BOOL)exec
                        palette:(PoCoPalette *)palette
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerPaletteElementSetter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
             buffer:[self getColorBuffer]
            palette:palette];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerPaletteElementSetter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 単一パレット設定
//
//  Call
//    exec  : 実行
//    num   : 対象色番号
//    red   : 赤
//    green : 緑
//    blue  : 青
//    mask  : 上塗り禁止
//    drop  : 吸い取り禁止
//    trans : 透明指定
//    name  : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createPaletteSingleSetter:(BOOL)exec
                           num:(int)num
                           red:(unsigned char)red
                         green:(unsigned char)green
                          blue:(unsigned char)blue
                        isMask:(BOOL)mask
                        noDrop:(BOOL)drop
                       isTrans:(BOOL)trans
                          name:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerPaletteSingleSetter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
             buffer:[self getColorBuffer]
                num:num
                red:red
              green:green
               blue:blue
             isMask:mask
             noDrop:drop
            isTrans:trans
               name:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerPaletteSingleSetter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// パレット取り込み(ペーストボードから複写)
//
//  Call
//    exec    : 実行
//    palette : 設定内容
//    flags   : 設定対象
//
//  Return
//    function : 編集部の実体
//
-(id)createPaletteImporter:(BOOL)exec
             targetPalette:(PoCoPalette *)target
                 withFlags:(const BOOL *)flags
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerPaletteImporter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
             buffer:[self getColorBuffer]
      targetPalette:target
          withFlags:flags];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerPaletteImporter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// パレット入れ替え
//
//  Call
//    exec : 実行
//    s    : 交換元色番号
//    d    : 交換先色番号
//
//  Return
//    function : 編集部の実体
//
-(id)createPictureColorExchanger:(BOOL)exec
                             src:(int)s
                             dst:(int)d
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerPictureColorExchanger alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
             buffer:[self getColorBuffer]
             active:YES
                src:s
                dst:d];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerPictureColorExchanger.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// パレット入れ替え(結果を通知しない)
//
//  Call
//    exec : 実行
//    s    : 交換元色番号
//    d    : 交換先色番号
//
//  Return
//    function : 編集部の実体
//
-(id)createPictureColorExchangerPassive:(BOOL)exec
                                    src:(int)s
                                    dst:(int)d
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerPictureColorExchanger alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
             buffer:[self getColorBuffer]
             active:NO
                src:s
                dst:d];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerPictureColorExchanger.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// パレット複写
//
//  Call
//    exec : 実行
//    s    : 複写元色番号
//    d    : 複写先色番号
//
//  Return
//    function : 編集部の実体
//
-(id)createPictureColorPaster:(BOOL)exec
                          src:(int)s
                          dst:(int)d
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerPictureColorPaster alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
             buffer:[self getColorBuffer]
             active:YES
                src:s
                dst:d];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerPictureColorPaster.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// パレット複写(結果を通知しない)
//
//  Call
//    exec : 実行
//    s    : 複写元色番号
//    d    : 複写先色番号
//
//  Return
//    function : 編集部の実体
//
-(id)createPictureColorPasterPassive:(BOOL)exec
                                 src:(int)s
                                 dst:(int)d
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerPictureColorPaster alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
             buffer:[self getColorBuffer]
             active:NO
                src:s
                dst:d];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerPictureColorPaster.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 画像レイヤー追加
//
//  Call
//    exec : 実行
//    c    : 初期色
//
//  Return
//    function : 編集部の実体
//
-(id)createLayerBitmapAdder:(BOOL)exec
                      color:(unsigned char)c
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerLayerBitmapAdder alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
              color:c];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerLayerBitmapAdder.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 文字列レイヤー追加
//
//  Call
//    exec : 実行
//    c    : 初期色
//
//  Return
//    function : 編集部の実体
//
-(id)createLayerStringAdder:(BOOL)exec
                      color:(unsigned char)c
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerLayerStringAdder alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
              color:c];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerLayerStringAdder.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// レイヤー削除
//
//  Call
//    exec  : 実行
//    index : 削除対象
//
//  Return
//    function : 編集部の実体
//
-(id)createLayerDeleter:(BOOL)exec
                  index:(int)index
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerLayerDeleter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
             active:YES
            atIndex:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerLayerDeleter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// レイヤー削除(結果を通知しない)
//
//  Call
//    exec  : 実行
//    index : 削除対象
//
//  Return
//    function : 編集部の実体
//
-(id)createLayerDeleterPassive:(BOOL)exec
                         index:(int)index
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerLayerDeleter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
             active:NO
            atIndex:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerLayerDeleter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// レイヤー挿入
//
//  Call
//    exec  : 実行
//    layer : レイヤー
//    index : 挿入先
//
//  Return
//    function : 編集部の実体
//
-(id)createLayerInserter:(BOOL)exec
                   layer:(PoCoLayerBase *)layer
                   index:(int)index
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerLayerInserter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
             active:YES
              layer:layer
            atIndex:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerLayerInserter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// レイヤー挿入(結果を通知しない)
//
//  Call
//    exec  : 実行
//    layer : レイヤー
//    index : 挿入先
//
//  Return
//    function : 編集部の実体
//
-(id)createLayerInserterPassive:(BOOL)exec
                          layer:(PoCoLayerBase *)layer
                          index:(int)index
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerLayerInserter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
             active:NO
              layer:layer
            atIndex:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerLayerInserter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// レイヤー移動
//
//  Call
//    exec : 実行
//    src  : 移動元レイヤー番号
//    dst  : 移動先レイヤー番号
//    copy : YES : 移動
//           NO  : 複製
//
//  Return
//    function : 編集部の実体
//
-(id)createLayerMover:(BOOL)exec
                  src:(int)src
               target:(int)dst
                 copy:(BOOL)copy
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerLayerMover alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
          fromIndex:src
            toIndex:dst
             isCopy:copy];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerLayerMover.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// レイヤー表示設定
//
//  Call
//    exec  : 実行
//    disp  : 設定内容
//    index : 設定対象
//
//  Return
//    function : 編集部の実体
//
-(id)createLayerDisplaySetter:(BOOL)exec
                         disp:(BOOL)disp
                        index:(int)index
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerLayerDisplaySetter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
          isDisplay:disp
            atIndex:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerLayerDisplaySetter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// レイヤー描画抑止設定
//
//  Call
//    exec  : 実行
//    lock  : 設定内容
//    index : 設定対象
//
//  Return
//    function : 編集部の実体
//
-(id)createLayerLockSetter:(BOOL)exec
                      lock:(BOOL)lock
                     index:(int)index
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerLayerLockSetter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
           drawLock:lock
            atIndex:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerLayerLockSetter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// レイヤー名称設定
//
//  Call
//    exec  : 実行
//    name  : 名称
//    index : 設定対象
//
//  Return
//    function : 編集部の実体
//
-(id)createLayerNameSetter:(BOOL)exec
                      name:(NSString *)name
                     index:(int)index
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerLayerNameSetter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
               name:name
            atIndex:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerLayerNameSetter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// レイヤー統合
//
//  Call
//    exec : 実行
//
//  Return
//    function : 編集部の実体
//
-(id)createPictureLayerUnificater:(BOOL)exec
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerPictureLayerUnificater alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerPictureLayerUnificator.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// サイズ変更
//
//  Call
//    exec   : 実行
//    fit    : YES : 変倍
//             NO  : clip
//    width  : 幅(pixel 単位)
//    height : 高さ(pixel 単位)
//
//  Return
//    function : 編集部の実体
//
-(id)createCanvasResizer:(BOOL)exec
                   isFit:(BOOL)fit
                   width:(int)width
                  height:(int)height
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerPictureCanvasResizer alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
              isFit:fit
              width:width
             height:height];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerPictureCanvasResizer.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 切り抜き
//
//  Call
//    exec : 実行
//    rect : 切り抜き領域
//
//  Return
//    function : 編集部の実体
//
-(id)createImageClipper:(BOOL)exec
                   rect:(PoCoRect *)rect
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerPictureImageClipper alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
               rect:rect];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerPictureImageClipper.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 画像置換
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    rect   : 置換領域
//    bitmap : 置換内容
//    name   : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createPictureBitmapReplacer:(BOOL)exec
                           layer:(int)index
                            rect:(PoCoRect *)rect
                          bitmap:(PoCoBitmap *)bitmap
                            name:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerPictureBitmapReplacer alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
              layer:index
               rect:rect
             bitmap:bitmap
               name:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerPictureBitmapReplacer.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// カラーパターン設定(レイヤーから取得)
//
//  Call
//    exec  : 実行
//    num   : 対象カラーパターン番号
//    layer : 取得レイヤー番号
//    rect  : 取得矩形枠
//
//  Return
//    function : 編集部の実体
//
-(id)createColorPatternSetter:(BOOL)exec
                          num:(int)num
                        layer:(int)index
                         rect:(PoCoRect *)rect
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerColorPatternSetter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
                num:num
              layer:index
               rect:rect];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerColorPatternSetter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// カラーパターン設定(パターン指定)
//
//  Call
//    exec : 実行
//    num  : 対象カラーパターン番号
//    pat  : パターン
//
//  Return
//    function : 編集部の実体
//
-(id)createColorPatternSetter:(BOOL)exec
                          num:(int)num
                      pattern:(PoCoColorPattern *)pat
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerColorPatternSetter alloc]
               init:[self getPict]
               info:[self getInfo]
               undo:[self getUndo]
                num:num
            pattern:pat];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerColorPatternSetter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 自由曲線(通常)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点(中点)
//    end   : 終点(中点)
//    name  : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createNormalFreeLineEditter:(BOOL)exec
                           layer:(int)index
                           start:(PoCoPoint *)start
                             end:(PoCoPoint *)end
                        undoName:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerNormalProportionalFreeLineEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
                pen:[self getPen]
               tile:[self getTile]
              start:start
                end:end
              index:index
               prop:NO
           undoName:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerNormalFreeLineEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 自由曲線(均一濃度)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点(中点)
//    end   : 終点(中点)
//    name  : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createUniformedDensityFreeLineEditter:(BOOL)exec
                                     layer:(int)index
                                     start:(PoCoPoint *)start
                                       end:(PoCoPoint *)end
                                  undoName:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerUniformedDensityProportionalFreeLineEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
              index:index
               prop:NO
           undoName:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerUniformedDensityProportionalFreeLineEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 自由曲線(濃度)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点(中点)
//    end   : 終点(中点)
//    name  : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createDensityFreeLineEditter:(BOOL)exec
                            layer:(int)index
                            start:(PoCoPoint *)start
                              end:(PoCoPoint *)end
                         undoName:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerDensityProportionalFreeLineEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
              index:index
               prop:NO
           undoName:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerDensityProportionalFreeLineEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 自由曲線(霧吹き)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点(中点)
//    end   : 終点(中点)
//    name  : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createAtomizerFreeLineEditter:(BOOL)exec
                             layer:(int)index
                             start:(PoCoPoint *)start
                               end:(PoCoPoint *)end
                          undoName:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerAtomizerProportionalFreeLineEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
              start:start
                end:end
              index:index
               prop:NO
           undoName:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerAtomizerProportionalFreeLineEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 自由曲線(グラデーション)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点(中点)
//    end   : 終点(中点)
//    name  : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createGradationFreeLineEditter:(BOOL)exec
                              layer:(int)index
                              start:(PoCoPoint *)start
                                end:(PoCoPoint *)end
                           undoName:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerGradationProportionalFreeLineEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
              index:index
               prop:NO
           undoName:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerGradationProportionalFreeLineEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 自由曲線(拡散)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点(中点)
//    end   : 終点(中点)
//    name  : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createRandomFreeLineEditter:(BOOL)exec
                           layer:(int)index
                           start:(PoCoPoint *)start
                             end:(PoCoPoint *)end
                        undoName:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerRandomProportionalFreeLineEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
               tile:[self getTile]
              start:start
                end:end
              index:index
               prop:NO
           undoName:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerRandomProportionalFreeLineEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 自由曲線(ぼかし)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点(中点)
//    end   : 終点(中点)
//    name  : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createWaterDropFreeLineEditter:(BOOL)exec
                              layer:(int)index
                              start:(PoCoPoint *)start
                                end:(PoCoPoint *)end
                           undoName:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerWaterDropProportionalFreeLineEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             buffer:[self getColorBuffer]
              start:start
                end:end
              index:index
               prop:NO
           undoName:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerWaterDropProportionalFreeLineEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 直線(ガイドライン)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点(中点)
//    end   : 終点(中点)
//
//  Return
//    function : 編集部の実体
//
-(id)createInvertLineEditter:(BOOL)exec
                       layer:(int)index
                       start:(PoCoPoint *)start
                         end:(PoCoPoint *)end
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerInvertLineEditter alloc]
               init:[self getPict]
              start:start
                end:end
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerInvertLineEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 直線群(開路)(ガイドライン)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    points : 支点群
//
//  Return
//    function : 編集部の実体
//
-(id)createInvertPolylineEditter:(BOOL)exec
                           layer:(int)index
                            poly:(NSMutableArray *)points
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerInvertPolylineEditter alloc]
               init:[self getPict]
               poly:points
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerInvertPolylineEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 直線群(閉路)(ガイドライン)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    points : 支点群
//
//  Return
//    function : 編集部の実体
//
-(id)createInvertPolygonEditter:(BOOL)exec
                          layer:(int)index
                           poly:(NSMutableArray *)points
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerInvertPolygonFrameEditter alloc]
               init:[self getPict]
               poly:points
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerInvertPolygonFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 直線群(曲線)(ガイドライン)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    points : 支点群
//    type   : 補間曲線の種類
//    freq   : 補間曲線の補間頻度
//
//  Return
//    function : 編集部の実体
//
-(id)createInvertCurveWithPointsEditter:(BOOL)exec
                                  layer:(int)index
                                 points:(NSMutableArray *)points
                                   type:(PoCoCurveWithPointsType)type
                                   freq:(unsigned int)freq
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerInvertCurveWithPointsEditter alloc]
               init:[self getPict]
             points:points
               type:type
               freq:freq
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerInvertCurveWithPointsEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 直線群(曲線)(通常)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    points : 支点群
//    type   : 補間曲線の種類
//    freq   : 補間曲線の補間頻度
//
//  Return
//    function : 編集部の実体
//
-(id)createNormalCurveWithPointsEditter:(BOOL)exec
                                  layer:(int)index
                                 points:(NSMutableArray *)points
                                   type:(PoCoCurveWithPointsType)type
                                   freq:(unsigned int)freq
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerNormalCurveWithPointsEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
                pen:[self getPen]
               tile:[self getTile]
             points:points
               type:type
               freq:freq
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerNormalCurveWithPointsEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 直線群(曲線)(均一濃度)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    points : 支点群
//    type   : 補間曲線の種類
//    freq   : 補間曲線の補間頻度
//
//  Return
//    function : 編集部の実体
//
-(id)createUniformedDensityCurveWithPointsEditter:(BOOL)exec
                                            layer:(int)index
                                           points:(NSMutableArray *)points
                                             type:(PoCoCurveWithPointsType)type
                                             freq:(unsigned int)freq
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerUniformedDensityCurveWithPointsEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
             points:points
               type:type
               freq:freq
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerUniformedDensityCurveWithPointsEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 直線群(曲線)(濃度)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    points : 支点群
//    type   : 補間曲線の種類
//    freq   : 補間曲線の補間頻度
//
//  Return
//    function : 編集部の実体
//
-(id)createDensityCurveWithPointsEditter:(BOOL)exec
                                   layer:(int)index
                                  points:(NSMutableArray *)points
                                    type:(PoCoCurveWithPointsType)type
                                    freq:(unsigned int)freq
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerDensityCurveWithPointsEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
             points:points
               type:type
               freq:freq
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerDensityCurveWithPointsEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 直線群(曲線)(霧吹き)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    points : 支点群
//    type   : 補間曲線の種類
//    freq   : 補間曲線の補間頻度
//
//  Return
//    function : 編集部の実体
//
-(id)createAtomizerCurveWithPointsEditter:(BOOL)exec
                                    layer:(int)index
                                   points:(NSMutableArray *)points
                                     type:(PoCoCurveWithPointsType)type
                                     freq:(unsigned int)freq
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerAtomizerCurveWithPointsEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             points:points
               type:type
               freq:freq
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerAtomizerCurveWithPointsEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 直線群(曲線)(グラデーション)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    points : 支点群
//    type   : 補間曲線の種類
//    freq   : 補間曲線の補間頻度
//
//  Return
//    function : 編集部の実体
//
-(id)createGradationCurveWithPointsEditter:(BOOL)exec
                                     layer:(int)index
                                    points:(NSMutableArray *)points
                                      type:(PoCoCurveWithPointsType)type
                                      freq:(unsigned int)freq
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerGradationCurveWithPointsEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
             points:points
               type:type
               freq:freq
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerGradationCurveWithPointsEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 直線群(曲線)(拡散)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    points : 支点群
//    type   : 補間曲線の種類
//    freq   : 補間曲線の補間頻度
//
//  Return
//    function : 編集部の実体
//
-(id)createRandomCurveWithPointsEditter:(BOOL)exec
                                  layer:(int)index
                                 points:(NSMutableArray *)points
                                   type:(PoCoCurveWithPointsType)type
                                   freq:(unsigned int)freq
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerRandomCurveWithPointsEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
               tile:[self getTile]
             points:points
               type:type
               freq:freq
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerRandomCurveWithPointsEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 直線群(曲線)(ぼかし)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    points : 支点群
//    type   : 補間曲線の種類
//    freq   : 補間曲線の補間頻度
//
//  Return
//    function : 編集部の実体
//
-(id)createWaterDropCurveWithPointsEditter:(BOOL)exec
                                     layer:(int)index
                                    points:(NSMutableArray *)points
                                      type:(PoCoCurveWithPointsType)type
                                      freq:(unsigned int)freq
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerWaterDropCurveWithPointsEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             buffer:[self getColorBuffer]
             points:points
               type:type
               freq:freq
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerWaterDropCurveWithPointsEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 矩形枠(ガイドライン)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createInvertBoxEditter:(BOOL)exec
                      layer:(int)index
                      start:(PoCoPoint *)start
                        end:(PoCoPoint *)end
                orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerInvertBoxFrameEditter alloc]
               init:[self getPict]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerInvertBoxFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 矩形枠(通常)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createNormalBoxEditter:(BOOL)exec
                      layer:(int)index
                      start:(PoCoPoint *)start
                        end:(PoCoPoint *)end
                orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerNormalBoxFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
                pen:[self getPen]
               tile:[self getTile]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerNormalBoxFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 矩形枠(均一濃度)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createUniformedDensityBoxEditter:(BOOL)exec
                                layer:(int)index
                                start:(PoCoPoint *)start
                                  end:(PoCoPoint *)end
                          orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerUniformedDensityBoxFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerUniformedDensityBoxFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 矩形枠(濃度)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createDensityBoxEditter:(BOOL)exec
                       layer:(int)index
                       start:(PoCoPoint *)start
                         end:(PoCoPoint *)end
                 orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerDensityBoxFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerDensityBoxFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 矩形枠(霧吹き)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createAtomizerBoxEditter:(BOOL)exec
                        layer:(int)index
                        start:(PoCoPoint *)start
                          end:(PoCoPoint *)end
                  orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerAtomizerBoxFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerAtomizerBoxFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 矩形枠(グラデーション)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createGradationBoxEditter:(BOOL)exec
                         layer:(int)index
                         start:(PoCoPoint *)start
                           end:(PoCoPoint *)end
                   orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerGradationBoxFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerGradationBoxFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 矩形枠(拡散)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createRandomBoxEditter:(BOOL)exec
                      layer:(int)index
                      start:(PoCoPoint *)start
                        end:(PoCoPoint *)end
                orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerRandomBoxFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
               tile:[self getTile]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerRandomBoxFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 矩形枠(ぼかし)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createWaterDropBoxEditter:(BOOL)exec
                         layer:(int)index
                         start:(PoCoPoint *)start
                           end:(PoCoPoint *)end
                   orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerWaterDropBoxFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             buffer:[self getColorBuffer]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerWaterDropBoxFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 円/楕円(ガイドライン)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createInvertEllipseEditter:(BOOL)exec
                          layer:(int)index
                          start:(PoCoPoint *)start
                            end:(PoCoPoint *)end
                    orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerInvertEllipseFrameEditter alloc]
               init:[self getPict]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerInvertEllipseFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 円/楕円(通常)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createNormalEllipseEditter:(BOOL)exec
                          layer:(int)index
                          start:(PoCoPoint *)start
                            end:(PoCoPoint *)end
                    orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerNormalEllipseFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
                pen:[self getPen]
               tile:[self getTile]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerNormalEllipseFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 円/楕円(均一濃度)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createUniformedDensityEllipseEditter:(BOOL)exec
                                    layer:(int)index
                                    start:(PoCoPoint *)start
                                      end:(PoCoPoint *)end
                              orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerUniformedDensityEllipseFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerUniformedDensityEllipseFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 円/楕円(濃度)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createDensityEllipseEditter:(BOOL)exec
                           layer:(int)index
                           start:(PoCoPoint *)start
                             end:(PoCoPoint *)end
                     orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerDensityEllipseFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerDensityEllipseFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 円/楕円(霧吹き)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createAtomizerEllipseEditter:(BOOL)exec
                            layer:(int)index
                            start:(PoCoPoint *)start
                              end:(PoCoPoint *)end
                      orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerAtomizerEllipseFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerAtomizerEllipseFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 円/楕円(グラデーション)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createGradationEllipseEditter:(BOOL)exec
                             layer:(int)index
                             start:(PoCoPoint *)start
                               end:(PoCoPoint *)end
                       orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerGradationEllipseFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerGradationEllipseFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 円/楕円(拡散)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createRandomEllipseEditter:(BOOL)exec
                          layer:(int)index
                          start:(PoCoPoint *)start
                            end:(PoCoPoint *)end
                    orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerRandomEllipseFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
               tile:[self getTile]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerRandomEllipseFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 円/楕円(ぼかし)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createWaterDropEllipseEditter:(BOOL)exec
                             layer:(int)index
                             start:(PoCoPoint *)start
                               end:(PoCoPoint *)end
                       orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerWaterDropEllipseFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             buffer:[self getColorBuffer]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerWaterDropEllipseFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 平行四辺形(ガイドライン)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    first  : 1点
//    second : 2点
//    third  : 3点
//
//  Return
//    function : 編集部の実体
//
-(id)createInvertParallelogramEditter:(BOOL)exec
                                layer:(int)index
                                first:(PoCoPoint *)first
                               second:(PoCoPoint *)second
                                third:(PoCoPoint *)third
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerInvertParallelogramFrameEditter alloc]
               init:[self getPict]
              first:first
             second:second
              third:third
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerInvertParallelogramFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 平行四辺形(通常)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    first  : 1点
//    second : 2点
//    third  : 3点
//
//  Return
//    function : 編集部の実体
//
-(id)createNormalParallelogramEditter:(BOOL)exec
                                layer:(int)index
                                first:(PoCoPoint *)first
                               second:(PoCoPoint *)second
                                third:(PoCoPoint *)third
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerNormalParallelogramFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
                pen:[self getPen]
               tile:[self getTile]
              first:first
             second:second
              third:third
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerNormalParallelogramFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 平行四辺形(均一濃度)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    first  : 1点
//    second : 2点
//    third  : 3点
//
//  Return
//    function : 編集部の実体
//
-(id)createUniformedDensityParallelogramEditter:(BOOL)exec
                                          layer:(int)index
                                          first:(PoCoPoint *)first
                                         second:(PoCoPoint *)second
                                          third:(PoCoPoint *)third
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerUniformedDensityParallelogramFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              first:first
             second:second
              third:third
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerUniformedDensityParallelogramFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 平行四辺形(濃度)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    first  : 1点
//    second : 2点
//    third  : 3点
//
//  Return
//    function : 編集部の実体
//
-(id)createDensityParallelogramEditter:(BOOL)exec
                                 layer:(int)index
                                 first:(PoCoPoint *)first
                                second:(PoCoPoint *)second
                                 third:(PoCoPoint *)third
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerDensityParallelogramFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              first:first
             second:second
              third:third
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerDensityParallelogramFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 平行四辺形(霧吹き)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    first  : 1点
//    second : 2点
//    third  : 3点
//
//  Return
//    function : 編集部の実体
//
-(id)createAtomizerParallelogramEditter:(BOOL)exec
                                  layer:(int)index
                                  first:(PoCoPoint *)first
                                 second:(PoCoPoint *)second
                                  third:(PoCoPoint *)third
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerAtomizerParallelogramFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
              first:first
             second:second
              third:third
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerAtomizerParallelogramFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 平行四辺形(グラデーション)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    first  : 1点
//    second : 2点
//    third  : 3点
//
//  Return
//    function : 編集部の実体
//
-(id)createGradationParallelogramEditter:(BOOL)exec
                                   layer:(int)index
                                   first:(PoCoPoint *)first
                                  second:(PoCoPoint *)second
                                   third:(PoCoPoint *)third
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerGradationParallelogramFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              first:first
             second:second
              third:third
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerGradationParallelogramFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 平行四辺形(拡散)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    first  : 1点
//    second : 2点
//    third  : 3点
//
//  Return
//    function : 編集部の実体
//
-(id)createRandomParallelogramEditter:(BOOL)exec
                                layer:(int)index
                                first:(PoCoPoint *)first
                               second:(PoCoPoint *)second
                                third:(PoCoPoint *)third
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerRandomParallelogramFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
               tile:[self getTile]
              first:first
             second:second
              third:third
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerRandomParallelogramFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 平行四辺形(ぼかし)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    first  : 1点
//    second : 2点
//    third  : 3点
//
//  Return
//    function : 編集部の実体
//
-(id)createWaterDropParallelogramEditter:(BOOL)exec
                                   layer:(int)index
                                   first:(PoCoPoint *)first
                                  second:(PoCoPoint *)second
                                   third:(PoCoPoint *)third
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerWaterDropParallelogramFrameEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             buffer:[self getColorBuffer]
              first:first
             second:second
              third:third
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerWaterDropParallelogramFrameEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし矩形枠(通常)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createNormalBoxFillEditter:(BOOL)exec
                          layer:(int)index
                          start:(PoCoPoint *)start
                            end:(PoCoPoint *)end
                    orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerNormalBoxFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
               tile:[self getTile]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerNormalBoxFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし矩形枠(単一濃度)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createUniformedDensityBoxFillEditter:(BOOL)exec
                                    layer:(int)index
                                    start:(PoCoPoint *)start
                                      end:(PoCoPoint *)end
                              orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerUniformedDensityBoxFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerUniformedDensityBoxFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし矩形枠(濃度)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createDensityBoxFillEditter:(BOOL)exec
                           layer:(int)index
                           start:(PoCoPoint *)start
                             end:(PoCoPoint *)end
                     orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerDensityBoxFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerDensityBoxFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし矩形枠(霧吹き)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createAtomizerBoxFillEditter:(BOOL)exec
                            layer:(int)index
                            start:(PoCoPoint *)start
                              end:(PoCoPoint *)end
                      orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerAtomizerBoxFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerAtomizerBoxFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし矩形枠(グラデーション)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createGradationBoxFillEditter:(BOOL)exec
                             layer:(int)index
                             start:(PoCoPoint *)start
                               end:(PoCoPoint *)end
                       orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerGradationBoxFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerGradationBoxFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし矩形枠(拡散)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createRandomBoxFillEditter:(BOOL)exec
                          layer:(int)index
                          start:(PoCoPoint *)start
                            end:(PoCoPoint *)end
                    orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerRandomBoxFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
               tile:[self getTile]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerRandomBoxFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし矩形枠(ぼかし)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createWaterDropBoxFillEditter:(BOOL)exec
                             layer:(int)index
                             start:(PoCoPoint *)start
                               end:(PoCoPoint *)end
                       orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerWaterDropBoxFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             buffer:[self getColorBuffer]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerWaterDropBoxFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし円/楕円(通常)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createNormalEllipseFillEditter:(BOOL)exec
                              layer:(int)index
                              start:(PoCoPoint *)start
                                end:(PoCoPoint *)end
                        orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerNormalEllipseFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
               tile:[self getTile]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerNormalEllipseFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし円/楕円(単一濃度)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createUniformedDensityEllipseFillEditter:(BOOL)exec
                                        layer:(int)index
                                        start:(PoCoPoint *)start
                                          end:(PoCoPoint *)end
                                  orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerUniformedDensityEllipseFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerUniformedDensityEllipseFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし円/楕円(濃度)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createDensityEllipseFillEditter:(BOOL)exec
                               layer:(int)index
                               start:(PoCoPoint *)start
                                 end:(PoCoPoint *)end
                         orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerDensityEllipseFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerDensityEllipseFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし円/楕円(霧吹き)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createAtomizerEllipseFillEditter:(BOOL)exec
                                layer:(int)index
                                start:(PoCoPoint *)start
                                  end:(PoCoPoint *)end
                          orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerAtomizerEllipseFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerAtomizerEllipseFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし円/楕円(グラデーション)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createGradationEllipseFillEditter:(BOOL)exec
                                 layer:(int)index
                                 start:(PoCoPoint *)start
                                   end:(PoCoPoint *)end
                           orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerGradationEllipseFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerGradationEllipseFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし円/楕円(拡散)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createRandomEllipseFillEditter:(BOOL)exec
                              layer:(int)index
                              start:(PoCoPoint *)start
                                end:(PoCoPoint *)end
                        orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerRandomEllipseFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
               tile:[self getTile]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerRandomEllipseFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし円/楕円(ぼかし)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点
//    end   : 終点
//    ort   : 方向点
//
//  Return
//    function : 編集部の実体
//
-(id)createWaterDropEllipseFillEditter:(BOOL)exec
                                 layer:(int)index
                                 start:(PoCoPoint *)start
                                   end:(PoCoPoint *)end
                           orientation:(PoCoPoint *)ort
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerWaterDropEllipseFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             buffer:[self getColorBuffer]
              start:start
                end:end
        orientation:ort
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerWaterDropEllipseFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし平行四辺形(通常)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    first  : 1点
//    second : 2点
//    third  : 3点
//
//  Return
//    function : 編集部の実体
//
-(id)createNormalParallelogramFillEditter:(BOOL)exec
                                    layer:(int)index
                                    first:(PoCoPoint *)first
                                   second:(PoCoPoint *)second
                                    third:(PoCoPoint *)third
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerNormalParallelogramFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
               tile:[self getTile]
              first:first
             second:second
              third:third
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerNormalParallelogramFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし平行四辺形(単一濃度)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    first  : 1点
//    second : 2点
//    third  : 3点
//
//  Return
//    function : 編集部の実体
//
-(id)createUniformedDensityParallelogramFillEditter:(BOOL)exec
                                              layer:(int)index
                                              first:(PoCoPoint *)first
                                             second:(PoCoPoint *)second
                                              third:(PoCoPoint *)third
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerUniformedDensityParallelogramFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              first:first
             second:second
              third:third
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerUniformedDensityParallelogramFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし平行四辺形(濃度)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    first  : 1点
//    second : 2点
//    third  : 3点
//
//  Return
//    function : 編集部の実体
//
-(id)createDensityParallelogramFillEditter:(BOOL)exec
                                     layer:(int)index
                                     first:(PoCoPoint *)first
                                    second:(PoCoPoint *)second
                                     third:(PoCoPoint *)third
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerDensityParallelogramFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              first:first
             second:second
              third:third
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerDensityParallelogramFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし平行四辺形(霧吹き)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    first  : 1点
//    second : 2点
//    third  : 3点
//
//  Return
//    function : 編集部の実体
//
-(id)createAtomizerParallelogramFillEditter:(BOOL)exec
                                      layer:(int)index
                                      first:(PoCoPoint *)first
                                     second:(PoCoPoint *)second
                                      third:(PoCoPoint *)third
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerAtomizerParallelogramFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
              first:first
             second:second
              third:third
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerAtomizerParallelogramFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし平行四辺形(グラデーション)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    first  : 1点
//    second : 2点
//    third  : 3点
//
//  Return
//    function : 編集部の実体
//
-(id)createGradationParallelogramFillEditter:(BOOL)exec
                                       layer:(int)index
                                       first:(PoCoPoint *)first
                                      second:(PoCoPoint *)second
                                       third:(PoCoPoint *)third
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerGradationParallelogramFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              first:first
             second:second
              third:third
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerGradationParallelogramFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし平行四辺形(拡散)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    first  : 1点
//    second : 2点
//    third  : 3点
//
//  Return
//    function : 編集部の実体
//
-(id)createRandomParallelogramFillEditter:(BOOL)exec
                                    layer:(int)index
                                    first:(PoCoPoint *)first
                                   second:(PoCoPoint *)second
                                    third:(PoCoPoint *)third
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerRandomParallelogramFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
               tile:[self getTile]
              first:first
             second:second
              third:third
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerRandomParallelogramFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし平行四辺形(ぼかし)
//
//  Call
//    exec   : 実行
//    index  : 対象レイヤー番号
//    first  : 1点
//    second : 2点
//    third  : 3点
//
//  Return
//    function : 編集部の実体
//
-(id)createWaterDropParallelogramFillEditter:(BOOL)exec
                                       layer:(int)index
                                       first:(PoCoPoint *)first
                                      second:(PoCoPoint *)second
                                       third:(PoCoPoint *)third
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerWaterDropParallelogramFillEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             buffer:[self getColorBuffer]
              first:first
             second:second
              third:third
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerWaterDropParallelogramFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 筆圧比例自由曲線(通常)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点(中点)
//    end   : 終点(中点)
//    name  : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createNormalProportionalFreeLineEditter:(BOOL)exec
                                       layer:(int)index
                                       start:(PoCoPoint *)start
                                         end:(PoCoPoint *)end
                                    undoName:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerNormalProportionalFreeLineEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
                pen:[self getPen]
               tile:[self getTile]
              start:start
                end:end
              index:index
               prop:YES
           undoName:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerNormalProportionalFreeLineEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 筆圧比例自由曲線(均一濃度)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点(中点)
//    end   : 終点(中点)
//    name  : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createUniformedDensityProportionalFreeLineEditter:(BOOL)exec
                                                 layer:(int)index
                                                 start:(PoCoPoint *)start
                                                   end:(PoCoPoint *)end
                                              undoName:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerUniformedDensityProportionalFreeLineEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
              index:index
               prop:YES
           undoName:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerUniformedDensityProportionalFreeLineEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 筆圧比例自由曲線(濃度)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点(中点)
//    end   : 終点(中点)
//    name  : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createDensityProportionalFreeLineEditter:(BOOL)exec
                                        layer:(int)index
                                        start:(PoCoPoint *)start
                                          end:(PoCoPoint *)end
                                     undoName:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerDensityProportionalFreeLineEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
              index:index
               prop:YES
           undoName:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerDensityProportionalFreeLineEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 筆圧比例自由曲線(霧吹き)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点(中点)
//    end   : 終点(中点)
//    name  : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createAtomizerProportionalFreeLineEditter:(BOOL)exec
                                         layer:(int)index
                                         start:(PoCoPoint *)start
                                           end:(PoCoPoint *)end
                                      undoName:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerAtomizerProportionalFreeLineEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
              start:start
                end:end
              index:index
               prop:YES
           undoName:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerAtomizerProportionalFreeLineEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 筆圧比例自由曲線(グラデーション)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点(中点)
//    end   : 終点(中点)
//    name  : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createGradationProportionalFreeLineEditter:(BOOL)exec
                                          layer:(int)index
                                          start:(PoCoPoint *)start
                                            end:(PoCoPoint *)end
                                       undoName:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerGradationProportionalFreeLineEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
             buffer:[self getColorBuffer]
              start:start
                end:end
              index:index
               prop:YES
           undoName:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerGradationProportionalFreeLineEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 筆圧比例自由曲線(拡散)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点(中点)
//    end   : 終点(中点)
//    name  : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createRandomProportionalFreeLineEditter:(BOOL)exec
                                       layer:(int)index
                                       start:(PoCoPoint *)start
                                         end:(PoCoPoint *)end
                                    undoName:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerRandomProportionalFreeLineEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
               tile:[self getTile]
              start:start
                end:end
              index:index
               prop:YES
           undoName:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerRandomProportionalFreeLineEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 筆圧比例自由曲線(ぼかし)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    start : 始点(中点)
//    end   : 終点(中点)
//    name  : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createWaterDropProportionalFreeLineEditter:(BOOL)exec
                                          layer:(int)index
                                          start:(PoCoPoint *)start
                                            end:(PoCoPoint *)end
                                       undoName:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerWaterDropProportionalFreeLineEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             buffer:[self getColorBuffer]
              start:start
                end:end
              index:index
               prop:YES
           undoName:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerWaterDropProportionalFreeLineEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし(任意形状)(ガイドライン)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    r     : 矩形枠
//    mask  : 形状マスク
//
//  Return
//    function : 編集部の実体
//
-(id)createInvertRegionFillEditter:(BOOL)exec
                             layer:(int)index
                              rect:(PoCoRect *)r
                              mask:(PoCoBitmap *)mask
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerInvertRegionFillEditter alloc]
               init:[self getPict]
               mask:mask
               rect:r
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerInvertRegionFillEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし境界(任意形状)(ガイドライン)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    r     : 矩形枠
//    mask  : 形状マスク
//
//  Return
//    function : 編集部の実体
//
-(id)createInvertRegionBorderEditter:(BOOL)exec
                               layer:(int)index
                                rect:(PoCoRect *)r
                                mask:(PoCoBitmap *)mask
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerInvertRegionBorderEditter alloc]
               init:[self getPict]
               mask:mask
               rect:r
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerInvertRegionBorderEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 塗りつぶし(seed paint)
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    pos   : 始点
//
//  Return
//    function : 編集部の実体
//
-(id)createNormalPaintEditter:(BOOL)exec
                        layer:(int)index
                          pos:(PoCoPoint *)pos
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerNormalPaintEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
             eraser:[self getEraser]
               tile:[self getTile]
                pos:pos
              index:index];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerNormalPaintEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}


//
// 画像貼り付け
//
//  Call
//    exec  : 実行
//    index : 対象レイヤー番号
//    r     : 貼り付け先矩形枠
//    bmp   : 貼り付ける画像
//    mask  : 任意領域の形状
//    pr    : 移動元の矩形枠
//    pbmp  : 編集前の画像
//    name  : 取り消し名称
//
//  Return
//    function : 編集部の実体
//
-(id)createNormalPasteImageEditter:(BOOL)exec
                             layer:(int)index
                              rect:(PoCoRect *)r
                            bitmap:(PoCoBitmap *)bmp
                            region:(PoCoBitmap *)mask
                          prevRect:(PoCoRect *)pr
                        prevBitmap:(PoCoBitmap *)pbmp
                           undoName:(NSString *)name
{
    id cntl;

    cntl = nil;

    // controller を生成
    cntl = [[PoCoControllerNormalPasteImageEditter alloc]
               init:[self getPict]
               info:[self getInfo] 
               undo:[self getUndo]
               tile:[self getTile]
               rect:r
             bitmap:bmp
             region:mask
           prevRect:pr
         prevBitmap:pbmp
              index:index
           undoName:name];
    if (cntl == nil) {
        DPRINT((@"can't alloc PoCoControllerNormalPasteImageEditter.\n"));
    } else if (exec) {
        // 実行してすぐ解放
        [cntl execute];
        [cntl release];
        cntl = nil;
    }

    return cntl;
}

@end
