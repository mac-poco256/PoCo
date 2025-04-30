//
//	Pelistina on Cocoa - PoCo -
//	環境設定パネル
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoPreferencesPanel.h"

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"

// ============================================================================
@implementation PoCoPreferencesPanel

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
    DPRINT((@"[PoCoPerferencesPanel init]\n"));

    // super class の初期化
    self = [super initWithWindowNibName:@"PoCoPreferencesPanel"];

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
    DPRINT((@"[PoCoPreferencesPanel dealloc]\n"));

    // 資源の解放
    ;   // 何もしない

    // super class の初期化
    [super dealloc];

    return;
}


//
// ウィンドウが読み込まれた
//
//  Call
//    None
//
//  Return
//    None
//
-(void)windowDidLoad
{
    // 何もしない
    ;

    return;
}


//
// ウィンドウが閉じられる(delegate method)
//
//  Call
//    note : 通知内容(api 変数)
//
//  Return
//    None
//
-(void)windowWillClose:(NSNotification *)note
{
#if 0   // 最近の標準アプリケーションにならって modal にしない
    // modal session 終了
    [NSApp stopModal];
#endif  // 0

    return;
}


//
// 開始
//
//  Call
//    None
//
//  Return
//    enableUndo_         : 取り消し有効(outlet)
//    enableLiveResize_   : LiveResize 可否(outlet)
//    enableEraser_       : 消しゴム有効可否(outlet)
//    undoMax_            : 取り消し最大数(outlet)
//    enableColorBuffer_  : 色保持情報可否(outlet)
//    showSelectionFill_  : 選択領域塗りつぶし表示(outlet)
//    liveEditSelection_  : 選択範囲の編集を随時表示(outlet)
//    saveDocWindowPos_   : 主ウィンドウの位置を記憶(outlet)
//    holdSubWindowPos_   : 補助ウィンドウの位置を固定(outlet)
//    showScrollerOnView_ : view で scroller を表示(outlet)
//    pixelGrid_          : ピクセルグリッドの間隔(outlet)
//    showTransGrid_      : 透明グリッドを表示(outlet)
//    backColorR_         : 背景色（R）(outlet)
//    backColorG_         : 背景色（G）(outlet)
//    backColorB_         : 背景色（B）(outlet)
//    previewQuality_     : プレビューの品質(outlet)
//    previewSize_        : プレビューの大きさ(outlet)
//    grayToAlpha_        : Grayscale を不透明度にする(outlet)
//    interGuide_         : 補間曲線のガイドライン表示(outlet)
//    interType_          : 補間曲線の種類(outlet)
//    interFreq_          : 補間曲線の補間頻度(outlet)
//    colorRange_         : 色範囲(outlet)
//    syncWithSubView_    : 表示ウィンドウとの同期(outlet)
//    syncWithPalette_    : 選択色との同期(outlet)
//
-(void)startWindow
{
    PoCoEditInfo *editInfo = [(PoCoAppController *)([NSApp delegate]) editInfo];

    // 取り消し可否
    [self->enableUndo_ setState:([editInfo enableUndo]) ? 1 : 0];

    // 取り消し最大数
    [self->undoMax_ setIntValue:[editInfo undoMaxLevel]];

    // LiveResize 可否
    [self->enableLiveResize_ setState:([editInfo enableLiveResize]) ? 1 : 0];

    // 消しゴム有効可否
    [self->enableEraser_ setState:([editInfo enableEraser]) ? 1 : 0];

    // 色保持情報可否
    [self->enableColorBuffer_ setState:([editInfo enableColorBuffer]) ? 1 : 0];

    // 選択領域塗りつぶし表示
    [self->showSelectionFill_ setState:([editInfo selectionFill]) ? 1 : 0];

    // 選択範囲の編集を随時表示
    [self->liveEditSelection_ setState:([editInfo liveEditSelection]) ? 1 : 0];

    // 主ウィンドウの位置を記憶
    [self->saveDocWindowPos_ setState:([editInfo saveDocWindowPos]) ? 1 : 0];

    // 補助ウィンドウの位置を固定
    [self->holdSubWindowPos_ setState:([editInfo holdSubWindowPos]) ? 1 : 0];

    // view で scroller を表示
    switch ([editInfo showScrollerView]) {
        default:
        case PoCoScrollerType_default:
            [self->showScrollerView_ setState:1 atRow:0 column:0];
            [self->showScrollerView_ setState:0 atRow:0 column:1];
            [self->showScrollerView_ setState:0 atRow:0 column:2];
            break;
        case PoCoScrollerType_always:
            [self->showScrollerView_ setState:0 atRow:0 column:0];
            [self->showScrollerView_ setState:1 atRow:0 column:1];
            [self->showScrollerView_ setState:0 atRow:0 column:2];
            break;
        case PoCoScrollerType_overlay:
            [self->showScrollerView_ setState:0 atRow:0 column:0];
            [self->showScrollerView_ setState:0 atRow:0 column:1];
            [self->showScrollerView_ setState:1 atRow:0 column:2];
            break;
    }

    // ピクセルグリッドの間隔
    [self->pixelGrid_ setIntValue:[[editInfo supplement] gridStep]];

    // 透明グリッドを表示
    [self->showTransGrid_ setState:([[editInfo supplement] isPattern]) ? 1 : 0];

    // 背景色（R、G、B）
    [self->backColorR_ setIntValue: ([[editInfo supplement] backgroundColor] & 0x000000ff)       ];
    [self->backColorG_ setIntValue:(([[editInfo supplement] backgroundColor] & 0x0000ff00) >>  8)];
    [self->backColorB_ setIntValue:(([[editInfo supplement] backgroundColor] & 0x00ff0000) >> 16)];

    // プレビューの品質、大きさ
    [self->previewQuality_ setIntValue:[editInfo previewQuality]];
    [self->previewSize_ setIntValue:[editInfo previewSize]];

    // Grayscale を不透明度にする
    [self->grayToAlpha_ setState:([editInfo grayToAlpha]) ? 1 : 0];

    // 補間曲線のガイドライン表示
    switch ([editInfo interGuide]) {
        default:
        case PoCoInterpolationGuideView_Line:
            [self->interGuide_ setState:1 atRow:0 column:0];
            [self->interGuide_ setState:0 atRow:0 column:1];
            [self->interGuide_ setState:0 atRow:0 column:2];
            break;
        case PoCoInterpolationGuideView_Curve:
            [self->interGuide_ setState:0 atRow:0 column:0];
            [self->interGuide_ setState:1 atRow:0 column:1];
            [self->interGuide_ setState:0 atRow:0 column:2];
            break;
        case PoCoInterpolationGuideView_CurveLine:
            [self->interGuide_ setState:0 atRow:0 column:0];
            [self->interGuide_ setState:0 atRow:0 column:1];
            [self->interGuide_ setState:1 atRow:0 column:2];
            break;
    }

    // 補間曲線の種類
    switch ([editInfo interType]) {
        default:
        case PoCoCurveWithPoints_Lagrange:
            [self->interType_ setState:1 atRow:0 column:0];
            [self->interType_ setState:0 atRow:0 column:1];
            break;
        case PoCoCurveWithPoints_Spline:
            [self->interType_ setState:0 atRow:0 column:0];
            [self->interType_ setState:1 atRow:0 column:1];
            break;
    }

    // 補間曲線の補間頻度
    [self->interFreq_ setIntValue:[editInfo interFreq]];

    // 色範囲
    [self->colorRange_ setIntValue:[editInfo colorRange]];

    // 表示ウィンドウとの同期
    [self->syncWithSubView_ setState:([editInfo syncSubView]) ? 1 : 0];

    // 表示ウィンドウとの同期
    [self->syncWithPalette_ setState:([editInfo syncPalette]) ? 1 : 0];

#if 0   // 最近の標準アプリケーションにならって modal にしない
    // modal session 開始
    [NSApp runModalForWindow:[self window]];
#endif  // 0

    return;
}


// -------------------------------------------- instance - public - IBAction 系
//
// 取り消し有効
//
//  Call
//    sender      : 操作対象(api 変数)
//    enableUndo_ : 取り消し有効(outlet)
//
//  Return
//    None
//
-(IBAction)enableUndo:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setEnableUndo:([self->enableUndo_ state] != 0)];

    return;
}


//
// 取り消し最大数
//
//  Call
//    sender   : 操作対象(api 変数)
//    undoMax_ : 取り消し最大数(outlet)
//
//  Return
//    None
//
-(IBAction)undoMax:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setUndoMaxLevel:[self->undoMax_ intValue]];

    return;
}


//
// LiveResize 可否
//
//  Call
//    sender            : 操作対象(api 変数)
//    enableLiveResize_ : LiveResize 可否(outlet)
//
//  Return
//    None
//
-(IBAction)enableLiveResize:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setEnableLiveResize:([self->enableLiveResize_ state] != 0)];

    return;
}


//
// 消しゴム有効可否
//
//  Call
//    sender        : 操作対象(api 変数)
//    enableEraser_ : 消しゴム有効可否(outlet)
//
//  Return
//    None
//
-(IBAction)enableEraser:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setEnableEraser:([self->enableEraser_ state] != 0)];

    return;
}


//
// 色保持情報可否
//
//  Call
//    sender             : 操作対象(api 変数)
//    enableColorBuffer_ : 色保持情報可否(outlet)
//
//  Return
//    None
//
-(IBAction)enableColorBuffer:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setEnableColorBuffer:([self->enableColorBuffer_ state] != 0)];

    return;
}


//
// 選択領域塗りつぶし表示
//
//  Call
//    sender             : 操作対象(api 変数)
//    showSelectionFill_ : 選択領域塗りつぶし表示(outlet)
//
//  Return
//    None
//
-(IBAction)showSelectionFill:(id)sender
{
    // ガイドライン消去
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoRedrawGuideLine
                      object:nil];

    // 設定を反映
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setSelectionFill:([self->showSelectionFill_ state] != 0)];

    // ガイドライン再描画
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoRedrawGuideLine
                      object:nil];

    return;
}


//
// 選択範囲の編集を随時表示
//
//  Call
//    sender             : 操作対象(api 変数)
//    liveEditSelection_ : 選択範囲の編集を随時表示(outlet)
//
//  Return
//    None
//
-(IBAction)liveEditSelection:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setLiveEditSelection:([self->liveEditSelection_ state] != 0)];

#if 0   // 特に必要ではない(編集中にパネルも操作なんてできないし)
    // 再描画
    [[NSNotificationCenter defaultCenter] postNotificationName:PoCoRedrawPicture
                                                        object:nil];
#endif  // 0

    return;
}


//
// 主ウィンドウの位置を記憶
//
//  Call
//    sender            : 操作対象(api 変数)
//    saveDocWindowPos_ : 主ウィンドウの位置を記憶(outlet)
//
//  Return
//    None
//
-(IBAction)saveDocWindowPos:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setSaveDocWindowPos:([self->saveDocWindowPos_ state] != 0)];

    return;
}


//
// 補助ウィンドウの位置を固定
//
//  Call
//    sender            : 操作対象(api 変数)
//    holdSubWindowPos_ : 補助ウィンドウの位置を固定(outlet)
//
//  Return
//    None
//
-(IBAction)holdSubWindowPos:(id)sender
{
    PoCoAppController *cntl = (PoCoAppController *)([NSApp delegate]);
    BOOL type;

    type = ([self->holdSubWindowPos_ state] != 0);
    [cntl subWindowHold:type];
    [[cntl editInfo] setHoldSubWindowPos:type];

    return;
}


//
// view で scroller を表示
//
//  Call
//    sender            : 操作対象(api 変数)
//    showScrollerView_ : view で scroller を表示(outlet)
//
//  Return
//    None
//
-(IBAction)showScrollerView:(id)sender
{
    switch ([sender selectedColumn]) {
        default:
        case 0:
            [[(PoCoAppController *)([NSApp delegate]) editInfo] setShowScrollerView:PoCoScrollerType_default];
            [self->showScrollerView_ setState:1 atRow:0 column:0];
            [self->showScrollerView_ setState:0 atRow:0 column:1];
            [self->showScrollerView_ setState:0 atRow:0 column:2];
            break;
        case 1:
            [[(PoCoAppController *)([NSApp delegate]) editInfo] setShowScrollerView:PoCoScrollerType_always];
            [self->showScrollerView_ setState:0 atRow:0 column:0];
            [self->showScrollerView_ setState:1 atRow:0 column:1];
            [self->showScrollerView_ setState:0 atRow:0 column:2];
            break;
        case 2:
            [[(PoCoAppController *)([NSApp delegate]) editInfo] setShowScrollerView:PoCoScrollerType_overlay];
            [self->showScrollerView_ setState:0 atRow:0 column:0];
            [self->showScrollerView_ setState:0 atRow:0 column:1];
            [self->showScrollerView_ setState:1 atRow:0 column:2];
            break;
    }

    return;
}


//
// ピクセルグリッド間隔
//
//  Call
//    sender     : 操作対象(api 変数)
//    pixelGrid_ : ピクセルグリッドの間隔(outlet)
//
//  Return
//    None
//
-(IBAction)pixelGrid:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setGridStep:(unsigned int)([self->pixelGrid_ intValue])];

    // 再描画
    [[NSNotificationCenter defaultCenter] postNotificationName:PoCoRedrawPicture
                                                        object:nil];

    return;
}


//
// 透明グリッド表示
//
//  Call
//    sender         : 操作対象(api 変数)
//    showTransGrid_ : 透明グリッドを表示(outlet)
//
//  Return
//    None
//
-(IBAction)showTransGrid:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setPattern:([self->showTransGrid_ state] != 0)];

    // 再描画
    [[NSNotificationCenter defaultCenter] postNotificationName:PoCoRedrawPicture
                                                        object:nil];

    return;
}


//
// 背景色
//
//  Call
//    sender      : 操作対象(api 変数)
//    backColorR_ : 背景色（R）(outlet)
//    backColorG_ : 背景色（G）(outlet)
//    backColorB_ : 背景色（B）(outlet)
//
//  Return
//    None
//
-(IBAction)backColor:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setBackgroundColor:(unsigned int)(0xff000000 | ([self->backColorB_ intValue] << 16) | ([self->backColorG_ intValue] << 8) | ([self->backColorR_ intValue]))];

    // 再描画
    [[NSNotificationCenter defaultCenter] postNotificationName:PoCoRedrawPicture
                                                        object:nil];

    return;
}


//
// プレビューの品質
//
//  Call
//    sender          : 操作対象(api 変数)
//    previewQuality_ : プレビューの品質(outlet)
//
//  Return
//    None
//
-(IBAction)previewQuality:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setPreviewQuality:(unsigned int)([self->previewQuality_ intValue])];

    // 再描画
    [[NSNotificationCenter defaultCenter] postNotificationName:PoCoLayerPreviewUpdate
                                                        object:nil];

    return;
}


//
// プレビューの大きさ
//
//  Call
//    sender       : 操作対象(api 変数)
//    previewSize_ : プレビューの大きさ(outlet)
//
//  Return
//    None
//
-(IBAction)previewSize:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setPreviewSize:(unsigned int)([self->previewSize_ intValue])];

    // 再描画
    [[NSNotificationCenter defaultCenter] postNotificationName:PoCoLayerPreviewUpdate
                                                        object:nil];

    return;
}


//
// Grayscale を不透明度にする
//
//  Call
//    sender       : 操作対象(api 変数)
//    grayToAlpha_ : Grayscale を不透明度にする(outlet)
//
//  Return
//    None
//
-(IBAction)grayToAlpha:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setGrayToAlpha:([self->grayToAlpha_ state] != 0)];

    return;
}


//
// 補間曲線のガイドライン表示
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    interGuide_ : 補間曲線のガイドライン表示(outlet)
//
-(IBAction)interGuide:(id)sender
{
    // ガイドライン消去
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoRedrawGuideLine
                      object:nil];

    // 設定を反映
    switch ([sender selectedColumn]) {
        default:
        case 0:
            [[(PoCoAppController *)([NSApp delegate]) editInfo] setInterGuide:PoCoInterpolationGuideView_Line];
            [self->interGuide_ setState:1 atRow:0 column:0];
            [self->interGuide_ setState:0 atRow:0 column:1];
            [self->interGuide_ setState:0 atRow:0 column:2];
            break;
        case 1:
            [[(PoCoAppController *)([NSApp delegate]) editInfo] setInterGuide:PoCoInterpolationGuideView_Curve];
            [self->interGuide_ setState:0 atRow:0 column:0];
            [self->interGuide_ setState:1 atRow:0 column:1];
            [self->interGuide_ setState:0 atRow:0 column:2];
            break;
        case 2:
            [[(PoCoAppController *)([NSApp delegate]) editInfo] setInterGuide:PoCoInterpolationGuideView_CurveLine];
            [self->interGuide_ setState:0 atRow:0 column:0];
            [self->interGuide_ setState:0 atRow:0 column:1];
            [self->interGuide_ setState:1 atRow:0 column:2];
            break;
    }

    // ガイドライン再描画
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoRedrawGuideLine
                      object:nil];

    return;
}


//
// 補間曲線の種類
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    interType_ : 補間曲線の種類(outlet)
//
-(IBAction)interType:(id)sender
{
    // ガイドライン消去
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoRedrawGuideLine
                      object:nil];

    // 設定を反映
    switch ([sender selectedColumn]) {
        default:
        case 0:
            [[(PoCoAppController *)([NSApp delegate]) editInfo] setInterType:PoCoCurveWithPoints_Lagrange];
            [self->interType_ setState:1 atRow:0 column:0];
            [self->interType_ setState:0 atRow:0 column:1];
            break;
        case 1:
            [[(PoCoAppController *)([NSApp delegate]) editInfo] setInterType:PoCoCurveWithPoints_Spline];
            [self->interType_ setState:0 atRow:0 column:0];
            [self->interType_ setState:1 atRow:0 column:1];
            break;
    }

    // ガイドライン再描画
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoRedrawGuideLine
                      object:nil];

    return;
}


//
// 補間曲線の補間頻度
//
//  Call
//    sender     : 操作対象(api 変数)
//    interFreq_ : 補間曲線の補間頻度(outlet)
//
//  Return
//    None
//
-(IBAction)intreFreq:(id)sender
{
    // ガイドライン消去
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoRedrawGuideLine
                      object:nil];

    // 設定を反映
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setInterFreq:(unsigned int)([self->interFreq_ intValue])];

    // ガイドライン再描画
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoRedrawGuideLine
                      object:nil];

    return;
}


//
// 色範囲
//
//  Call
//    sender      : 操作対象(api 変数)
//    colorRange_ : 色範囲(outlet)
//
//  Return
//    None
//
-(IBAction)colorRange:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setColorRange:(int)([self->colorRange_ intValue])];

    return;
}


//
// 表示ウィンドウとの同期
//
//  Call
//    sender           : 操作対象(api 変数)
//    syncWithSubView_ : 表示ウィンドウとの同期(outlet)
//
//  Return
//    None
//
-(IBAction)syncWithSubView:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setSyncSubView:([self->syncWithSubView_ state] != 0)];

    return;
}


//
// 選択色との同期
//
//  Call
//    sender           : 操作対象(api 変数)
//    syncWithPalette_ : 選択色との同期(outlet)
//
//  Return
//    None
//
-(IBAction)syncWithPalette:(id)sender
{
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setSyncPalette:([self->syncWithPalette_ state] != 0)];

    return;
}

@end
