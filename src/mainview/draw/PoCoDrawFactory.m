//
//	Pelistina on Cocoa - PoCo -
//	描画編集系生成部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoDrawFactory.h"

#import "PoCoMyDocument.h"
#import "PoCoView.h"
#import "PoCoAppController.h"
#import "PoCoEditInfo.h"

#import "PoCoDrawFreeLine.h"
#import "PoCoDrawLine.h"
#import "PoCoDrawBox.h"
#import "PoCoDrawEllipse.h"
#import "PoCoDrawParallelogram.h"
#import "PoCoDrawPaint.h"
#import "PoCoDrawProportional.h"
#import "PoCoDrawSelection.h"
#import "PoCoDrawDragMove.h"

// ============================================================================
@implementation PoCoDrawFactory

// ------------------------------------------------------------ class - private
//
// 自由曲線
//
//  Call
//    doc : 編集対象
//    pen : ペン先指定
//
//  Return
//    function : 描画編集系の実体
//
+(id)createDrawFreeLine:(MyDocument *)doc
                withPen:(PoCoPenStyleType)pen
{
    id obj;

    DPRINT((@"[PoCoDrawFactory createDrawFreeLine: withPen:%d\n", pen));

    obj = nil;

    // ペン先ごとに分別
    switch (pen) {
        case PoCoPenStyleType_Normal:
        default:
            // 通常
            obj = [[PoCoDrawFreeLineNormal alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_UniformedDensity:
            // 単一濃度
            obj = [[PoCoDrawFreeLineUniformedDensity alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Density:
            // 濃度
            obj = [[PoCoDrawFreeLineDensity alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Atomizer:
            // 霧吹き
            obj = [[PoCoDrawFreeLineAtomizer alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Gradation:
            // グラデーション
            obj = [[PoCoDrawFreeLineGradation alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Random:
            // 拡散
            obj = [[PoCoDrawFreeLineRandom alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_WaterDrop:
            // ぼかし
            obj = [[PoCoDrawFreeLineWaterDrop alloc] initWithDoc:doc];
            break;
    }

    return obj;
}


//
// 直線
//
//  Call
//    doc : 編集対象
//    pen : ペン先指定
//
//  Return
//    function : 描画編集系の実体
//
+(id)createDrawLine:(MyDocument *)doc
            withPen:(PoCoPenStyleType)pen
{
    id obj;

    DPRINT((@"[PoCoDrawFactory createDrawLine: withPen:%d\n", pen));

    obj = nil;

    // ペン先ごとに分別
    switch (pen) {
        case PoCoPenStyleType_Normal:
        default:
            // 通常
            obj = [[PoCoDrawLineNormal alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_UniformedDensity:
            // 単一濃度
            obj = [[PoCoDrawLineUniformedDensity alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Density:
            // 濃度
            obj = [[PoCoDrawLineDensity alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Atomizer:
            // 霧吹き
            obj = [[PoCoDrawLineAtomizer alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Gradation:
            // グラデーション
            obj = [[PoCoDrawLineGradation alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Random:
            // 拡散
            obj = [[PoCoDrawLineRandom alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_WaterDrop:
            // ぼかし
            obj = [[PoCoDrawLineWaterDrop alloc] initWithDoc:doc];
            break;
    }

    return obj;
}


//
// 矩形枠
//
//  Call
//    doc : 編集対象
//    pen : ペン先指定
//
//  Return
//    function : 描画編集系の実体
//
+(id)createDrawBox:(MyDocument *)doc
           withPen:(PoCoPenStyleType)pen
{
    id obj;

    DPRINT((@"[PoCoDrawFactory createDrawBox: withPen:%d\n", pen));

    obj = nil;

    // ペン先ごとに分別
    switch (pen) {
        case PoCoPenStyleType_Normal:
        default:
            // 通常
            obj = [[PoCoDrawBoxNormal alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_UniformedDensity:
            // 単一濃度
            obj = [[PoCoDrawBoxUniformedDensity alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Density:
            // 濃度
            obj = [[PoCoDrawBoxDensity alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Atomizer:
            // 霧吹き
            obj = [[PoCoDrawBoxAtomizer alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Gradation:
            // グラデーション
            obj = [[PoCoDrawBoxGradation alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Random:
            // 拡散
            obj = [[PoCoDrawBoxRandom alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_WaterDrop:
            // ぼかし
            obj = [[PoCoDrawBoxWaterDrop alloc] initWithDoc:doc];
            break;
    }

    return obj;
}


//
// 円/楕円
//
//  Call
//    doc : 編集対象
//    pen : ペン先指定
//
//  Return
//    function : 描画編集系の実体
//
+(id)createDrawEllipse:(MyDocument *)doc
               withPen:(PoCoPenStyleType)pen
{
    id obj;

    DPRINT((@"[PoCoDrawFactory createDrawEllipse: withPen:%d\n", pen));

    obj = nil;

    // ペン先ごとに分別
    switch (pen) {
        case PoCoPenStyleType_Normal:
        default:
            // 通常
            obj = [[PoCoDrawEllipseNormal alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_UniformedDensity:
            // 単一濃度
            obj = [[PoCoDrawEllipseUniformedDensity alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Density:
            // 濃度
            obj = [[PoCoDrawEllipseDensity alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Atomizer:
            // 霧吹き
            obj = [[PoCoDrawEllipseAtomizer alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Gradation:
            // グラデーション
            obj = [[PoCoDrawEllipseGradation alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Random:
            // 拡散
            obj = [[PoCoDrawEllipseRandom alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_WaterDrop:
            // ぼかし
            obj = [[PoCoDrawEllipseWaterDrop alloc] initWithDoc:doc];
            break;
    }

    return obj;
}


//
// 平行四辺形
//
//  Call
//    doc : 編集対象
//    pen : ペン先指定
//
//  Return
//    function : 描画編集系の実体
//
+(id)createDrawParallelogram:(MyDocument *)doc
                     withPen:(PoCoPenStyleType)pen
{
    id obj;

    DPRINT((@"[PoCoDrawFactory createDrawParellelogram: withPen:%d\n", pen));

    obj = nil;

    // ペン先ごとに分別
    switch (pen) {
        case PoCoPenStyleType_Normal:
        default:
            // 通常
            obj = [[PoCoDrawParallelogramNormal alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_UniformedDensity:
            // 単一濃度
            obj = [[PoCoDrawParallelogramUniformedDensity alloc]
                      initWithDoc:doc];
            break;
        case PoCoPenStyleType_Density:
            // 濃度
            obj = [[PoCoDrawParallelogramDensity alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Atomizer:
            // 霧吹き
            obj = [[PoCoDrawParallelogramAtomizer alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Gradation:
            // グラデーション
            obj = [[PoCoDrawParallelogramGradation alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Random:
            // 拡散
            obj = [[PoCoDrawParallelogramRandom alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_WaterDrop:
            // ぼかし
            obj = [[PoCoDrawParallelogramWaterDrop alloc] initWithDoc:doc];
            break;
    }

    return obj;
}


//
// 塗りつぶし矩形枠
//
//  Call
//    doc : 編集対象
//    pen : ペン先指定
//
//  Return
//    function : 描画編集系の実体
//
+(id)createDrawBoxFill:(MyDocument *)doc
               withPen:(PoCoPenStyleType)pen
{
    id obj;

    DPRINT((@"[PoCoDrawFactory createDrawBoxFill: withPen:%d\n", pen));

    obj = nil;

    // ペン先ごとに分別
    switch (pen) {
        case PoCoPenStyleType_Normal:
        default:
            // 通常
            obj = [[PoCoDrawBoxFillNormal alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_UniformedDensity:
            // 単一濃度
            obj = [[PoCoDrawBoxFillUniformedDensity alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Density:
            // 濃度
            obj = [[PoCoDrawBoxFillDensity alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Atomizer:
            // 霧吹き
            obj = [[PoCoDrawBoxFillAtomizer alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Gradation:
            // グラデーション
            obj = [[PoCoDrawBoxFillGradation alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Random:
            // 拡散
            obj = [[PoCoDrawBoxFillRandom alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_WaterDrop:
            // ぼかし
            obj = [[PoCoDrawBoxFillWaterDrop alloc] initWithDoc:doc];
            break;
    }

    return obj;
}


//
// 塗りつぶし円/楕円
//
//  Call
//    doc : 編集対象
//    pen : ペン先指定
//
//  Return
//    function : 描画編集系の実体
//
+(id)createDrawEllipseFill:(MyDocument *)doc
                   withPen:(PoCoPenStyleType)pen
{
    id obj;

    DPRINT((@"[PoCoDrawFactory createDrawEllipseFill: withPen:%d\n", pen));

    obj = nil;

    // ペン先ごとに分別
    switch (pen) {
        case PoCoPenStyleType_Normal:
        default:
            // 通常
            obj = [[PoCoDrawEllipseFillNormal alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_UniformedDensity:
            // 濃度
            obj = [[PoCoDrawEllipseFillUniformedDensity alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Density:
            // 単一濃度
            obj = [[PoCoDrawEllipseFillDensity alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Atomizer:
            // 霧吹き
            obj = [[PoCoDrawEllipseFillAtomizer alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Gradation:
            // グラデーション
            obj = [[PoCoDrawEllipseFillGradation alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Random:
            // 拡散
            obj = [[PoCoDrawEllipseFillRandom alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_WaterDrop:
            // ぼかし
            obj = [[PoCoDrawEllipseFillWaterDrop alloc] initWithDoc:doc];
            break;
    }

    return obj;
}


//
// 塗りつぶし平行四辺形
//
//  Call
//    doc : 編集対象
//    pen : ペン先指定
//
//  Return
//    function : 描画編集系の実体
//
+(id)createDrawParallelogramFill:(MyDocument *)doc
                         withPen:(PoCoPenStyleType)pen
{
    id obj;

    DPRINT((@"[PoCoDrawFactory createDrawParalellogramFill: withPen:%d\n", pen));

    obj = nil;

    // ペン先ごとに分別
    switch (pen) {
        case PoCoPenStyleType_Normal:
        default:
            // 通常
            obj = [[PoCoDrawParallelogramFillNormal alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_UniformedDensity:
            // 単一濃度
            obj = [[PoCoDrawParallelogramFillUniformedDensity alloc]
                      initWithDoc:doc];
            break;
        case PoCoPenStyleType_Density:
            // 濃度
            obj = [[PoCoDrawParallelogramFillDensity alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Atomizer:
            // 霧吹き
            obj = [[PoCoDrawParallelogramFillAtomizer alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Gradation:
            // グラデーション
            obj = [[PoCoDrawParallelogramFillGradation alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_Random:
            // 拡散
            obj = [[PoCoDrawParallelogramFillRandom alloc] initWithDoc:doc];
            break;
        case PoCoPenStyleType_WaterDrop:
            // ぼかし
            obj = [[PoCoDrawParallelogramFillWaterDrop alloc] initWithDoc:doc];
            break;
    }

    return obj;
}


//
// 塗りつぶし
//
//  Call
//    doc : 編集対象
//    pen : ペン先指定
//
//  Return
//    function : 描画編集系の実体
//
+(id)createDrawPaint:(MyDocument *)doc
             withPen:(PoCoPenStyleType)pen
{
    DPRINT((@"[PoCoDrawFactory createDrawPaint: withPen:%d\n", pen));

    return [[PoCoDrawPaint alloc] initWithDoc:doc];
}


//
// 筆圧比例自由曲線
//
//  Call
//    doc : 編集対象
//    pen : ペン先指定
//
//  Return
//    function : 描画編集系の実体
//
+(id)createDrawProportionalFreeLine:(MyDocument *)doc
                            withPen:(PoCoPenStyleType)pen
{
    id obj;

    DPRINT((@"[PoCoDrawFactory createDrawProportionalFreeLine: withPen:%d\n", pen));

    obj = nil;

    // ペン先ごとに分別
    switch (pen) {
        case PoCoPenStyleType_Normal:
        default:
            // 通常
            obj = [[PoCoDrawProportionalFreeLineNormal alloc]
                      initWithDoc:doc];
            break;
        case PoCoPenStyleType_UniformedDensity:
            // 単一濃度
            obj = [[PoCoDrawProportionalFreeLineUniformedDensity alloc]
                      initWithDoc:doc];
            break;
        case PoCoPenStyleType_Density:
            // 濃度
            obj = [[PoCoDrawProportionalFreeLineDensity alloc]
                      initWithDoc:doc];
            break;
        case PoCoPenStyleType_Atomizer:
            // 霧吹き
            obj = [[PoCoDrawProportionalFreeLineAtomizer alloc]
                      initWithDoc:doc];
            break;
        case PoCoPenStyleType_Gradation:
            // グラデーション
            obj = [[PoCoDrawProportionalFreeLineGradation alloc]
                      initWithDoc:doc];
            break;
        case PoCoPenStyleType_Random:
            // 拡散
            obj = [[PoCoDrawProportionalFreeLineRandom alloc]
                      initWithDoc:doc];
            break;
        case PoCoPenStyleType_WaterDrop:
            // ぼかし
            obj = [[PoCoDrawProportionalFreeLineWaterDrop alloc]
                      initWithDoc:doc];
            break;
    }

    return obj;
}


//
// 選択
//
//  Call
//    doc : 編集対象
//    pen : ペン先指定
//
//  Return
//    function : 描画編集系の実体
//
+(id)createDrawSelection:(MyDocument *)doc
                 withPen:(PoCoPenStyleType)pen
{
    DPRINT((@"[PoCoDrawFactory createDrawSelection: withPen:%d\n", pen));

    return  [[PoCoDrawSelection alloc] initWithDoc:doc];
}


//
// ずりずり
//
//  Call
//    doc : 編集対象
//    pen : ペン先指定
//
//  Return
//    function : 描画編集系の実体
//
+(id)createDrawDragMove:(MyDocument *)doc
                withPen:(PoCoPenStyleType)pen
{
    DPRINT((@"[PoCoDrawFactory createDrawDragMove: withPen:%d\n", pen));

    return [[PoCoDrawDragMove alloc] initWithDoc:doc];
}


// ------------------------------------------------------------- class - public
//
// 生成
//
//  Call
//    doc  : 編集対象
//    draw : 機能指定
//    pen  : ペン先指定
//
//  Return
//    function : 描画編集系の実体
//
+(id)create:(MyDocument *)doc
   withDraw:(PoCoDrawModeType)draw
    withPen:(PoCoPenStyleType)pen
{
    id obj;

    DPRINT((@"[PoCoDrawFactory create: withDraw:%d withPen:%d]\n", draw, pen));

    obj = nil;

    // 機能ごとに分別
    switch (draw) {
        case PoCoDrawModeType_FreeLine:
        default:
            // 自由曲線
            obj = [PoCoDrawFactory createDrawFreeLine:doc
                                              withPen:pen];
            break;
        case PoCoDrawModeType_Line:
            // 直線
            obj = [PoCoDrawFactory createDrawLine:doc
                                          withPen:pen];
            break;
        case PoCoDrawModeType_Box:
            // 矩形枠
            obj = [PoCoDrawFactory createDrawBox:doc
                                         withPen:pen];
            break;
        case PoCoDrawModeType_Ellipse:
            // 円/楕円
            obj = [PoCoDrawFactory createDrawEllipse:doc
                                             withPen:pen];
            break;
        case PoCoDrawModeType_Parallelogram:
            // 平行四辺形
            obj = [PoCoDrawFactory createDrawParallelogram:doc
                                                   withPen:pen];
            break;
        case PoCoDrawModeType_BoxFill:
            // 塗りつぶし矩形枠
            obj = [PoCoDrawFactory createDrawBoxFill:doc
                                             withPen:pen];
            break;
        case PoCoDrawModeType_EllipseFill:
            // 塗りつぶし円/楕円
            obj = [PoCoDrawFactory createDrawEllipseFill:doc
                                                 withPen:pen];
            break;
        case PoCoDrawModeType_ParallelogramFill:
            // 塗りつぶし平行四辺形
            obj = [PoCoDrawFactory createDrawParallelogramFill:doc
                                                       withPen:pen];
            break;
        case PoCoDrawModeType_Paint:
            // 塗りつぶし
            obj = [PoCoDrawFactory createDrawPaint:doc
                                           withPen:pen];
            break;
        case PoCoDrawModeType_ProportionalFreeLine:
            // 筆圧比例自由曲線
            obj = [PoCoDrawFactory createDrawProportionalFreeLine:doc
                                                          withPen:pen];
            break;
        case PoCoDrawModeType_Selection:
            // 選択
            obj = [PoCoDrawFactory createDrawSelection:doc
                                               withPen:pen];
            break;
        case PoCoDrawModeType_DragMove:
            // ずりずり
            obj = [PoCoDrawFactory createDrawDragMove:doc
                                              withPen:pen];
            break;
    }

    return obj;
}

@end
