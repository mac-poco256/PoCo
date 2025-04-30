//
//	Pelistina on Cocoa - PoCo -
//	編集情報管理部
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoEditInfo.h"

#import "PoCoPalette.h"

// 内部変数
static NSString *COLOR_MODE_NAME = @"PoCoSelectedColorModeType";
static NSString *PEN_NUMBER_NAME = @"PoCoSelectedPenNumber";
static NSString *PEN_SIZE_NAME = @"PoCoSetPenSize";
static NSString *TILE_PATTERN_NAME = @"PoCoSelectedTilePattern";
static NSString *DENSITY_NAME = @"PoCoSetDensityValue";
static NSString *DRAWMODE_NAME = @"PoCoDrawModeType";
static NSString *CONTINUATION_NAME = @"PoCoContinuationType";
static NSString *FLIP_NAME = @"PoCoFlipType";
static NSString *POINTMODE_NAME = @"PoCoPointModeType";
static NSString *DRAWPENSTYLE_NAME = @"PoCoPenStyleType";
static NSString *ENABLEUNDO_NAME = @"PoCoEnableUndo";
static NSString *ENABLEERASER_NAME = @"PoCoEnableEraser";
static NSString *UNDOMAXLEVEL_NAME = @"PoCoUndoMaxLevel";
static NSString *ENABLELIVERESIZE_NAME = @"PoCoEnableLiveResize";
static NSString *ENABLECOLORBUFFER_NAME = @"PoCoEnableColorBuffer";
static NSString *SIZEPROPTYPE_NAME = @"PoCoProportionalTypePenSize";
static NSString *DENSITYPROPTYPE_NAME = @"PoCoProportionalTypeDensity";
static NSString *ATOMIZERSKIPTYPE_NAME = @"PoCoAtomizerSkipType";
static NSString *ATOMIZERTYPE_NAME = @"PoCoAtomizerType";
static NSString *SELECTIONFILL_NAME = @"PoCoSelectionFillType";
static NSString *LIVEEDITSELECTION_NAME = @"PoCoLiveEditSelectionType";
static NSString *PALETTELOCK_NAME = @"PoCoPaletteLockType";
static NSString *WITHHANDLESELECTION_NAME = @"PoCoWithHandleSelectionType";
static NSString *SAVEDOCWINDOWPOS_NAME = @"PoCoSaveDocWindowPosType";
static NSString *HOLDDOCWINDOWPOS_NAME = @"PoCoHoldSubWindowPosType";
static NSString *NOOPENNEWDOCPANEL_NAME = @"PoCoNoOpenNewDocPanelType";
static NSString *SHOWSCROLLERVIEW_NAME = @"PoCoShowScrollerView";
static NSString *BACKGROUNDCOLOR_NAME = @"PoCoBackgroundColor";
static NSString *BACKGROUNDPATTERN_NAME = @"PoCoBackgroundPattern";
static NSString *PIXELGRIDSTEP_NAME = @"PoCoPixelGridStep";
static NSString *PREVIEWQUALITY_NAME = @"PoCoPreviewQuality";
static NSString *PREVIEWSIZE_NAME = @"PoCoPreviewSize";
static NSString *GRAYSCALETOALPHA_NAME = @"PoCoGrayscaleToAlpha";
static NSString *INTERGUIDE_VIEW_NAME = @"PoCoInterpolationGuideView";
static NSString *INTERPOLATION_TYPE_NAME = @"PoCoCurveWithPointsType";
static NSString *INTERPOLATION_FREQ_NAME = @"PoCoInterpolationFrequency";
static NSString *RANGEOFCOLOR_NAME = @"PoCoRangeOfColorNumber";
static NSString *SYNCSUBVIEW_NAME = @"PoCoSyncSubView";
static NSString *SYNCPALETTE_NAME = @"PoCoSyncPalette";

// ============================================================================
@implementation PoCoEditInfo

// ------------------------------------------------------------ class - public
//
// 初期設定
//
//  Call
//    None
//
//  Return
//    None
//
+(void)initialize
{
    NSMutableDictionary *dic;

    dic = [NSMutableDictionary dictionary];

    // 各初期値を設定
    [dic setObject:[NSNumber numberWithInt:0]
            forKey:COLOR_MODE_NAME];
    [dic setObject:[NSNumber numberWithInt:0]
            forKey:PEN_NUMBER_NAME];
    [dic setObject:[NSNumber numberWithInt:16]
            forKey:PEN_SIZE_NAME];
    [dic setObject:[NSNumber numberWithInt:7]
            forKey:TILE_PATTERN_NAME];
    [dic setObject:[NSNumber numberWithInt:(100 * 10)]
            forKey:DENSITY_NAME];
    [dic setObject:[NSNumber numberWithInt:PoCoDrawModeType_FreeLine]
            forKey:DRAWMODE_NAME];
    [dic setObject:[NSNumber numberWithBool:YES]
            forKey:CONTINUATION_NAME];
    [dic setObject:[NSNumber numberWithBool:NO]
            forKey:FLIP_NAME];
    [dic setObject:[NSNumber numberWithInt:PoCoPointModeType_PointHold]
            forKey:POINTMODE_NAME];
    [dic setObject:[NSNumber numberWithInt:PoCoPenStyleType_Normal]
            forKey:DRAWPENSTYLE_NAME];
    [dic setObject:[NSNumber numberWithBool:YES]
            forKey:ENABLEUNDO_NAME];
    [dic setObject:[NSNumber numberWithBool:YES]
            forKey:ENABLEERASER_NAME];
    [dic setObject:[NSNumber numberWithInt:100]
            forKey:UNDOMAXLEVEL_NAME];
    [dic setObject:[NSNumber numberWithBool:YES]
            forKey:ENABLELIVERESIZE_NAME];
    [dic setObject:[NSNumber numberWithBool:YES]
            forKey:ENABLECOLORBUFFER_NAME];
    [dic setObject:[NSNumber numberWithInt:PoCoProportionalType_Relation]
            forKey:SIZEPROPTYPE_NAME];
    [dic setObject:[NSNumber numberWithInt:PoCoProportionalType_Relation]
            forKey:DENSITYPROPTYPE_NAME];
    [dic setObject:[NSNumber numberWithInt:PoCoAtomizerSkipType_Always]
            forKey:ATOMIZERSKIPTYPE_NAME];
    [dic setObject:[NSNumber numberWithBool:NO]
            forKey:ATOMIZERTYPE_NAME];
    [dic setObject:[NSNumber numberWithBool:NO]
            forKey:SELECTIONFILL_NAME];
    [dic setObject:[NSNumber numberWithBool:NO]
            forKey:LIVEEDITSELECTION_NAME];
    [dic setObject:[NSNumber numberWithBool:NO]
            forKey:PALETTELOCK_NAME];
    [dic setObject:[NSNumber numberWithBool:YES]
            forKey:WITHHANDLESELECTION_NAME];
    [dic setObject:[NSNumber numberWithBool:NO]
            forKey:SAVEDOCWINDOWPOS_NAME];
    [dic setObject:[NSNumber numberWithBool:NO]
            forKey:HOLDDOCWINDOWPOS_NAME];
    [dic setObject:[NSNumber numberWithBool:NO]
            forKey:NOOPENNEWDOCPANEL_NAME];
    [dic setObject:[NSNumber numberWithInt:PoCoScrollerType_default]
            forKey:SHOWSCROLLERVIEW_NAME];
    [dic setObject:[NSNumber numberWithInt:0xffcccccc]
            forKey:BACKGROUNDCOLOR_NAME];
    [dic setObject:[NSNumber numberWithBool:YES]
            forKey:BACKGROUNDPATTERN_NAME];
    [dic setObject:[NSNumber numberWithInt:0]
            forKey:PIXELGRIDSTEP_NAME];
    [dic setObject:[NSNumber numberWithInt:4]
            forKey:PREVIEWQUALITY_NAME];
    [dic setObject:[NSNumber numberWithInt:48]
            forKey:PREVIEWSIZE_NAME];
    [dic setObject:[NSNumber numberWithBool:NO]
            forKey:GRAYSCALETOALPHA_NAME];
    [dic setObject:[NSNumber numberWithInt:PoCoInterpolationGuideView_Line]
            forKey:INTERGUIDE_VIEW_NAME];
    [dic setObject:[NSNumber numberWithInt:PoCoCurveWithPoints_Lagrange]
            forKey:INTERPOLATION_TYPE_NAME];
    [dic setObject:[NSNumber numberWithInt:2]
            forKey:INTERPOLATION_FREQ_NAME];
    [dic setObject:[NSNumber numberWithInt:0]
            forKey:RANGEOFCOLOR_NAME];
    [dic setObject:[NSNumber numberWithBool:NO]
            forKey:SYNCSUBVIEW_NAME];
    [dic setObject:[NSNumber numberWithBool:NO]
            forKey:SYNCPALETTE_NAME];

    // default を設定
    [[NSUserDefaults standardUserDefaults] registerDefaults:dic];

    return;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function             : 実体
//    selColor_            : 選択中の色(instance 変数)
//    oldColor_            : 以前の色(instance 変数)
//    colorMode_           : 色演算モード(instance 変数)
//    lockPalette_         : パレット固定(instance 変数)
//    penNumber_           : ペン先選択番号(instance 変数)
//    penSize_             : 筆圧比例時のペン先(instance 変数)
//    tileNumber_          : タイルパターン(instance 変数)
//    density_             : 濃度上限値(instance 変数)
//    pressure_            : 筆圧(instance 変数)
//    pdPos_               : PD 位置(実寸)(instance 変数)
//    lastPos_             : 最終 PD 位置(実寸)(instance 変数)
//    pictureRect_         : 画像サイズ(実寸)(instance 変数)
//    viewRect_            : 表示範囲(実寸)(instance 変数)
//    pdRect_              : PD 範囲(実寸)(instance 変数)
//    selRect_             : 選択範囲(実寸)(instance 変数)
//    drawModeType_        : 描画機能系(instance 変数)
//    continuationType_    : 連続/不連続(instance 変数)
//    flipType_            : 濃度反転(instance 変数)
//    pointModeType_       : 形状指定(instance 変数)
//    penStyleType_        : ペン先指定(描画)(instance 変数)
//    enableUndo_          : 取り消し可否(instance 変数)
//    enableEraser_        : 消しゴム有効可否(instance 変数)
//    eraserType_          : 消しゴム指定(instance 変数)
//    undoMaxLevel_        : 取り消し最大数(instance 変数)
//    enableLiveResize_    : LiveResize可否(instance 変数)
//    enableColorBuffer_   : 色保持情報可否(instance 変数)
//    sizePropType_        : サイズの筆圧比例(instance 変数)
//    densityPropType_     : 濃度の筆圧比例(instance 変数)
//    atomizerSkip_        : 霧吹きの移動方法(instance 変数)
//    atomizerType_        : 霧吹きの種類(instance 変数)
//    selectionFill_       : 選択領域塗りつぶし表示(instance 変数)
//    liveEditSelection_   : 選択範囲の編集を随時表示(instance 変数)
//    withHandleSelection_ : 選択範囲のハンドル有無(instance 変数)
//    saveDocWindowPos_    : 主ウィンドウ位置保存(instance 変数)
//    holdSubWindowPos_    : 補助ウィンドウ位置固定(instance 変数)
//    noOpenNewDocPanel_   : 新規ドキュメントパネルを開かない(instance 変数)
//    showScrollerView_    : view で scroller を表示(instance 変数)
//    supplement_          : 主ウィンドウの表示修飾(instance 変数)
//    previewQuality_      : プレビューの品質(instance 変数)
//    previewSize_         : プレビューの大きさ(instance 変数)
//    grayToAlpha_         : Grascale を不透明度とする(instance 変数)
//    interGuide_          : 補間曲線のガイドライン表示(instance 変数)
//    interType_           : 補間曲線の種類(instance 変数)
//    interFreq_           : 補間曲線の補間頻度(instance 変数)
//    colorRange_          : 色範囲(instance 変数)
//    syncSubView_         : 表示ウィンドウとの同期(instance 変数)
//    syncPalette_         : 選択色との同期(instance 変数)
//
-(id)init
{
    NSUserDefaults *def;

    DPRINT((@"[PoCoEditInfo init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->selColor_ = nil;
        self->oldColor_ = nil;
        self->pdPos_ = nil;
        self->lastPos_ = nil;
        self->pictureRect_ = nil;
        self->viewRect_ = nil;
        self->pdRect_ = nil;
        self->selRect_ = nil;
        self->supplement_ = nil;

        // 主ウィンドウの表示修飾
        self->supplement_ = [[PoCoMainViewSupplement alloc] init];

        // 初期値の設定
        def = [NSUserDefaults standardUserDefaults];
        self->lockPalette_ = [def integerForKey:PALETTELOCK_NAME];
        self->penNumber_ = (unsigned int)([def integerForKey:PEN_NUMBER_NAME]);
        self->penSize_ = (unsigned int)([def integerForKey:PEN_SIZE_NAME]);
        self->tileNumber_ = (unsigned int)([def integerForKey:TILE_PATTERN_NAME]);
        self->density_ = (unsigned int)([def integerForKey:DENSITY_NAME]);
        self->drawModeType_ = (PoCoDrawModeType)([def integerForKey:DRAWMODE_NAME]);
        self->continuationType_ = [def boolForKey:CONTINUATION_NAME];
        self->flipType_ = [def boolForKey:FLIP_NAME];
        self->pointModeType_ = (PoCoPointModeType)([def integerForKey:POINTMODE_NAME]);
        self->penStyleType_ = (PoCoPenStyleType)([def integerForKey:DRAWPENSTYLE_NAME]);
        self->enableUndo_ = [def boolForKey:ENABLEUNDO_NAME];
        self->enableEraser_ = [def boolForKey:ENABLEERASER_NAME];
        self->undoMaxLevel_ = (int)([def integerForKey:UNDOMAXLEVEL_NAME]);
        self->enableLiveResize_ = [def boolForKey:ENABLELIVERESIZE_NAME];
        self->enableColorBuffer_ = [def boolForKey:ENABLECOLORBUFFER_NAME];
        self->sizePropType_ = (PoCoProportionalType)([def integerForKey:SIZEPROPTYPE_NAME]);
        self->densityPropType_ = (PoCoProportionalType)([def integerForKey:DENSITYPROPTYPE_NAME]);
        self->atomizerSkip_ = (PoCoAtomizerSkipType)([def integerForKey:ATOMIZERSKIPTYPE_NAME]);
        self->atomizerType_ = [def boolForKey:ATOMIZERTYPE_NAME];
        self->selectionFill_ = [def boolForKey:SELECTIONFILL_NAME];
        self->liveEditSelection_ = [def boolForKey:LIVEEDITSELECTION_NAME];
        self->withHandleSelection_ = [def boolForKey:WITHHANDLESELECTION_NAME];
        self->saveDocWindowPos_ = [def boolForKey:SAVEDOCWINDOWPOS_NAME];
        self->holdSubWindowPos_ = [def boolForKey:HOLDDOCWINDOWPOS_NAME];
        self->noOpenNewDocPanel_ = [def boolForKey:NOOPENNEWDOCPANEL_NAME];
        self->showScrollerView_ = (PoCoScrollerType)([def integerForKey:SHOWSCROLLERVIEW_NAME]);
        self->previewQuality_ = (unsigned int)([def integerForKey:PREVIEWQUALITY_NAME]);
        self->previewSize_ = (unsigned int)([def integerForKey:PREVIEWSIZE_NAME]);
        self->grayToAlpha_ = [def boolForKey:GRAYSCALETOALPHA_NAME];
        self->interFreq_ = (unsigned int)([def integerForKey:INTERPOLATION_FREQ_NAME]);
        self->colorRange_ = (int)([def integerForKey:RANGEOFCOLOR_NAME]);
        [self->supplement_ setBackgroundColor:(unsigned int)([def integerForKey:BACKGROUNDCOLOR_NAME])];
        [self->supplement_ setPattern:[def boolForKey:BACKGROUNDPATTERN_NAME]];
        [self->supplement_ setGridStep:(unsigned int)([def integerForKey:PIXELGRIDSTEP_NAME])];
        self->syncSubView_ = [def boolForKey:SYNCSUBVIEW_NAME];
        self->syncPalette_ = [def boolForKey:SYNCPALETTE_NAME];
        switch ([def integerForKey:COLOR_MODE_NAME]) {
            case 0:
            default:
                self->colorMode_ = PoCoColorMode_RGB;
                break;
            case 1:
                self->colorMode_ = PoCoColorMode_HLS;
                break;
        }
        switch ([def integerForKey:INTERGUIDE_VIEW_NAME]) {
            default:
            case 0:
                self->interGuide_ = PoCoInterpolationGuideView_Line;
                break;
            case 1:
                self->interGuide_ = PoCoInterpolationGuideView_Curve;
                break;
            case 2:
                self->interGuide_ = PoCoInterpolationGuideView_CurveLine;
                break;
        }
        switch ([def integerForKey:INTERPOLATION_TYPE_NAME]) {
            default:
            case 0:
                self->interType_ = PoCoCurveWithPoints_Lagrange;
                break;
            case 1:
                self->interType_ = PoCoCurveWithPoints_Spline;
                break;
        }

        // NSUserDefaults によらない分の初期化
        self->eraserType_ = NO;
        self->pressure_ = 1000;

        // 資源を確保
        self->selColor_ = [[PoCoSelColor alloc] initWithColorNum:0];
        if (self->selColor_ == nil) {
            DPRINT((@"can't alloc selColor.\n"));
            [self release];
            self = nil;
            goto EXIT;
        }
        self->oldColor_ = [[PoCoSelColor alloc] initWithColorNum:-1];
        if (self->oldColor_ == nil) {
            DPRINT((@"can't alloc oldColor.\n"));
            [self release];
            self = nil;
            goto EXIT;
        }

        // 各座標の初期化
        self->pdPos_ = [[PoCoPoint alloc] init];
        self->lastPos_ = [[PoCoPoint alloc] init];
        self->pictureRect_ = [[PoCoRect alloc] init];
        self->viewRect_ = [[PoCoRect alloc] init];
        self->pdRect_ = [[PoCoRect alloc] init];
        self->selRect_ = [[PoCoRect alloc] init];
    }

EXIT:
    return self;
}


//
// deallocate
//
//  Call
//    selColor_    : 選択中の色(instance 変数)
//    oldColor_    : 以前の色(instance 変数)
//    pdPos_       : PD 位置(実寸)(instance 変数)
//    lastPos_     : 最終 PD 位置(実寸)(instance 変数)
//    pictureRect_ : 画像サイズ(実寸)(instance 変数)
//    viewRect_    : 表示範囲(実寸)(instance 変数)
//    pdRect_      : PD 範囲(実寸)(instance 変数)
//    selRect_     : 選択範囲(実寸)(instance 変数)
//    supplement_  : 主ウィンドウの表示修飾(instance 変数)
//
//  Return
//    None
//
-(void)dealloc
{
    DPRINT((@"[PoCoEditInfo dealloc]\n"));

    // 資源の解放
    [self->supplement_ release];
    [self->selRect_ release];
    [self->pdRect_ release];
    [self->viewRect_ release];
    [self->pictureRect_ release];
    [self->pdPos_ release];
    [self->oldColor_ release];
    [self->selColor_ release];

    self->selColor_ = nil;
    self->oldColor_ = nil;
    self->pdPos_ = nil;
    self->lastPos_ = nil;
    self->pictureRect_ = nil;
    self->viewRect_ = nil;
    self->pdRect_ = nil;
    self->selRect_ = nil;
    self->supplement_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


// ----------------------------------------- instance - public - 選択中の色関連
//
// 選択中の色の取得
//
//  Call
//    selColor_ : 選択中の色(instance 変数)
//
//  Return
//    function : 選択色情報
//
-(PoCoSelColor *)selColor
{
    return self->selColor_;
}


//
// 選択中の色の取得
//
//  Call
//    oldColor_ : 以前の色(instance 変数)
//
//  Return
//    function : 選択色情報
//
-(PoCoSelColor *)oldColor
{
    return self->oldColor_;
}


//
// 選択中の色の設定
//
//  Call
//    num : 色番号
//
//  Return
//    selColor_ : 選択中の色(instance 変数)
//    oldColor_ : 以前の色(instance 変数)
//
-(void)setSelColor:(int)num
{
    // 範囲外では設定しない
    if ((num >= 0) && (num < COLOR_MAX)) {
        // 以前の色を覚える
        if ([self->selColor_ isColor]) {
            [self->oldColor_ setColor:[self->selColor_ num]];
        } else {
            [self->oldColor_ setPattern:[self->selColor_ num]];
        }

        // 設定色を覚える
        [self->selColor_ setColor:num];
    }

    return;
}


//
// 選択中のパターンの設定
//
//  Call
//    num : パターン番号
//
//  Return
//    selColor_ : 選択中の色(instance 変数)
//    oldColor_ : 以前の色(instance 変数)
//
-(void)setSelPattern:(int)num
{
    // 範囲外では設定しない
    if ((num >= 0) && (num < 16)) {
        // 以前の色を覚える
        if ([self->selColor_ isColor]) {
            [self->oldColor_ setColor:[self->selColor_ num]];
        } else {
            [self->oldColor_ setPattern:[self->selColor_ num]];
        }

        // 設定色を覚える
        [self->selColor_ setPattern:num];
    }

    return;
}


//
// カラーパターンの使用の取得
//
//  Call
//    selColor_ : 選択中の色(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)useUnderPattern
{
    return [self->selColor_ isUnder];
}


//
// カラーパターンの使用の切り替え
//
//  Call
//    selColor_ : 選択中の色(instance 変数)
//
//  Return
//    None
//
-(void)toggleUseUnderPattern
{
    [self->selColor_ toggleUnder];

    return;
}


// --------------------------------------- instance - public - 色演算モード関連
//
// 色演算モードの取得
//
//  Call
//    colorMode_ : 色演算モード(instance 変数）
//
//  Return
//    function : 設定値
//
-(PoCoColorMode)colorMode
{
    return self->colorMode_;
}


//
// 色演算モードの設定
//
//  Call
//    mode : 設定値
//
//  Return
//    colorMode_ : 色演算モード(instance 変数）
//
-(void)setColorMode:(PoCoColorMode)mode
{
    NSUserDefaults *def;

    self->colorMode_ = mode;

    def = [NSUserDefaults standardUserDefaults];
    switch (self->colorMode_) {
        case PoCoColorMode_RGB:
        default:
            [def setInteger:0 forKey:COLOR_MODE_NAME];
            break;
        case PoCoColorMode_HLS:
            [def setInteger:1 forKey:COLOR_MODE_NAME];
            break;
    }

    return;
}


//
// パレット固定の取得
//
//  Call
//    lockPalette_ : パレット固定(instance 変数)
//
//  Return
//    funtion : 設定内容
//
-(BOOL)lockPalette
{
    return self->lockPalette_;
}


//
// パレット固定の設定
//
//  Call
//    type : 設定内容
//
//  Return
//    lockPalette_ : パレット固定(instance 変数)
//
-(void)setLockPalette:(BOOL)type
{
    self->lockPalette_ = type;
    [[NSUserDefaults standardUserDefaults] setBool:self->lockPalette_
                                            forKey:PALETTELOCK_NAME];

    return;
}


// --------------------------------------------- instance - public - ペン先関連
//
// ペン先選択番号の取得
//
//  Call
//    penNumber_ : ペン先選択番号(instance 変数)
//
//  Return
//    function : 値
//
-(unsigned int)penNumber
{
    return self->penNumber_;
}


//
// ペン先大きさの取得
//
//  Call
//    penSize_ : 筆圧比例時のペン先大きさ(dot単位)(instance 変数)
//
//  Return
//    function : 値(dot 単位)
//
-(unsigned int)penSize
{
    return self->penSize_;
}


//
// ペン先選択番号の設定
//
//  Call
//    num : 番号
//
//  Return
//    penNumber_ : ペン先選択番号(instance 変数)
//
-(void)setPenNumber:(unsigned int)num
{
    if (/* (num >= 0) && */(num < PEN_STYLE_NUM)) {
        self->penNumber_ = num;
        [[NSUserDefaults standardUserDefaults] setInteger:self->penNumber_
                                                   forKey:PEN_NUMBER_NAME];
    }

    return;
}


//
// ペン先大きさの設定
//
//  Call
//    size : 大きさ(dot 単位)
//
//  Return
//    penSize_ : 筆圧比例時のペン先大きさ(dot単位)(instance 変数)
//
-(void)setPenSize:(unsigned int)size
{
    if ((size > 0) && (size <= PEN_STYLE_SIZE)) {
        self->penSize_ = size;
        [[NSUserDefaults standardUserDefaults] setInteger:self->penSize_
                                                   forKey:PEN_SIZE_NAME];
    }

    return;
}


// --------------------------- instance 関数 - public - タイルパターン/濃度関連
//
// タイルパターン選択番号の取得
//
//  Call
//    tileNumber_ : タイルパターン選択番号(instance 変数)
//
//  Return
//    function : 値
//
-(unsigned int)tileNumber
{
    return self->tileNumber_;
}


//
// 濃度の取得
//
//  Call
//    density_ : 濃度上限値(0.1% 単位)(instance 変数)
//
//  Return
//    function : 値(0.1% 単位)
//
-(unsigned int)density
{
    return self->density_;
}


//
// タイルパターン選択番号の設定
//
//  Call
//    num : 番号
//
//  Return
//    tileNumber_ : タイルパターン選択番号(instance 変数)
//
-(void)setTileNumber:(unsigned int)num
{
    if (/* (num >= 0) && */(num < TILE_PATTERN_NUM)) {
        self->tileNumber_ = num;
        [[NSUserDefaults standardUserDefaults] setInteger:self->tileNumber_
                                                   forKey:TILE_PATTERN_NAME];
    }

    return;
}


//
// 濃度の設定
//
//  Call
//    val : 値(0.1% 単位)
//
//  Return
//    density_ : 濃度上限値(0.1% 単位)(instance 変数)
//
-(void)setDensity:(unsigned int)val
{
    if (/* (val >= 0) && */(val <= (100 * 10))) {
        self->density_ = val;
        [[NSUserDefaults standardUserDefaults] setInteger:self->density_
                                                   forKey:DENSITY_NAME];
    }

    return;
}


// ----------------------------- instance - public - ポインタプレス時の筆圧関連
//
// 筆圧を取得
//
//  Call
//    pressure_ : ポインタプレス時の筆圧(0.1%単位)(instance 変数)
//
//  Return
//    function : 値(0.1% 単位)
//
-(unsigned int)pressure
{
    return self->pressure_;
}


//
// 筆圧を設定
//
//  Call
//    press : 値(0.1% 単位)
//
//  Return
//    pressure_ : ポインタプレス時の筆圧(0.1%単位)(instance 変数)
//
-(void)setPressure:(unsigned int)press
{
    self->pressure_ = press;

    return;
}


// ------------------------------------------- instance - public - 表示位置関連
//
// 画像サイズの取得
//
//  Call
//    pictureRect_ : 画像サイズ(実寸)(instance 変数)
//
//  Return
//    function : 範囲
//
-(PoCoRect *)pictureRect
{
    return self->pictureRect_;
}


//
// 表示画像サイズの取得
//  主ウィンドウでの倍率を反映した実寸の表示範囲
//
//  Call
//    viewRect_ : 表示範囲(実寸)(instance 変数)
//
//  Return
//    function : 範囲
//
-(PoCoRect *)pictureView
{
    return self->viewRect_;
}


//
// 画像サイズの設定
//
//  Call
//    r : 範囲
//
//  Return
//    pictureRect_ : 画像サイズ(実寸)(instance 変数)
//
-(void)setPictureRect:(PoCoRect *)r
{
    if (!([self->pictureRect_ isEqualRect:r])) {
        [self->pictureRect_   setLeft:[r   left]];
        [self->pictureRect_    setTop:[r    top]];
        [self->pictureRect_  setRight:[r  right]];
        [self->pictureRect_ setBottom:[r bottom]];

        // 画像サイズの変更を通知
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoEditInfoChangePos
                          object:[NSNumber numberWithInt:PoCoEditInfoPos_pictureRect]];
    }

    return;
}


//
// 表示画像サイズの設定
//  主ウィンドウでの倍率を反映した実寸の表示範囲
//
//  Call
//    r            : 範囲
//    pictureRect_ : 画像サイズ(実寸)(instance 変数)
//
//  Return
//    viewRect_ : 表示範囲(実寸)(instance 変数)
//
-(void)setPictureView:(PoCoRect *)r
{
    if (!([self->viewRect_ isEqualRect:r])) {
        [self->viewRect_   setLeft:[r   left]];
        [self->viewRect_    setTop:[r    top]];
        [self->viewRect_  setRight:[r  right]];
        [self->viewRect_ setBottom:[r bottom]];

        // 値を補正
        if ([self->viewRect_ left] < [self->pictureRect_ left]) {
            [self->viewRect_ setLeft:[self->pictureRect_ left]];
        }
        if ([self->viewRect_ top] < [self->pictureRect_ top]) {
            [self->viewRect_ setTop:[self->pictureRect_ top]];
        }
        if ([self->viewRect_ right] >= [self->pictureRect_ right]) {
            [self->viewRect_ setRight:([self->pictureRect_ right] - 1)];
        }
        if ([self->viewRect_ bottom] >= [self->pictureRect_ bottom]) {
            [self->viewRect_ setBottom:([self->pictureRect_ bottom] - 1)];
        }

        // 表示範囲の変更を通知
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoEditInfoChangePos
                          object:[NSNumber numberWithInt:PoCoEditInfoPos_viewRect]];
    }

    return;
}


// ---------------------------------------- instance - public - PD 指示位置関連
//
// PD 位置の取得
//
//  Call
//    pdPos_ : PD 位置(実寸)(instance 変数)
//
//  Return
//    function : 位置
//
-(PoCoPoint *)pdPos
{
    return self->pdPos_;
}


//
// 最終 PD 位置の取得
//
//  Call
//    lastPos_ : 最終 PD 位置(実寸)(instance 変数)
//
//  Return
//    function : 位置
//
-(PoCoPoint *)lastPos
{
    return self->lastPos_;
}


//
// 範囲の取得
//  選択範囲ではない(通常の編集に用いる)矩形領域の取得
//
//  Call
//    pdRect_ : PD 範囲(実寸)(instance 変数)
//
//  Return
//    function : 範囲
//
-(PoCoRect *)pdRect
{
    return self->pdRect_;
}


//
// PD 位置の設定
//
//  Call
//    p : 位置
//
//  Return
//    pdPos_ : PD 位置(実寸)(instance 変数)
//
-(void)setPDPos:(PoCoPoint *)p
{
    if (!([self->pdPos_ isEqualPos:p])) {
        [self->pdPos_ setX:[p x]];
        [self->pdPos_ setY:[p y]];

        // PD 位置の移動を通知
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoEditInfoChangePos
                          object:[NSNumber numberWithInt:PoCoEditInfoPos_pdPos]];
    }

    return;
}


//
// 最終 PD 位置の設定
//
//  Call
//    p : 位置
//
//  Return
//    lastPos_ : 最終 PD 位置(実寸)(instance 変数)
//
-(void)setLastPos:(PoCoPoint *)p
{
    [self->lastPos_ setX:[p x]];
    [self->lastPos_ setY:[p y]];

    return;
}


//
// 範囲の設定
//  選択範囲ではない(通常の編集に用いる)矩形領域の設定
//
//  Call
//    r : 範囲
//
//  Return
//    pdRect_ : PD 範囲(実寸)(instance 変数)
//
-(void)setPDRect:(PoCoRect *)r
{
    if (!([self->pdRect_ isEqualRect:r])) {
        [self->pdRect_   setLeft:[r   left]];
        [self->pdRect_    setTop:[r    top]];
        [self->pdRect_  setRight:[r  right]];
        [self->pdRect_ setBottom:[r bottom]];

        // 範囲の変更を通知
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoEditInfoChangePos
                          object:[NSNumber numberWithInt:PoCoEditInfoPos_pdRect]];
    }

    return;
}


// ------------------------------------------- instance - public - 選択範囲関連
//
// 選択範囲の取得
//
//  Call
//    selRect_ : 選択範囲(実寸)(instance 変数)
//
//  Return
//    function : 範囲
//
-(PoCoRect *)selRect
{
    return self->selRect_;
}


//
// 選択範囲の設定
//
//  Call
//    r : 範囲
//
//  Return
//    selRect_ : 選択範囲(実寸)(instance 変数)
//
-(void)setSelRect:(PoCoRect *)r
{
    if (!([self->selRect_ isEqualRect:r])) {
        [self->selRect_   setLeft:[r   left]];
        [self->selRect_    setTop:[r    top]];
        [self->selRect_  setRight:[r  right]];
        [self->selRect_ setBottom:[r bottom]];

        // 選択範囲の変更を通知
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoEditInfoChangePos
                          object:[NSNumber numberWithInt:PoCoEditInfoPos_selRect]];
    }

    return;
}


// ------------------------------------------- instance - public - 表示修飾関連
//
// 主ウィンドウの表示修飾取得
//
//  Call
//    supplement_ : 主ウィンドウの表示修飾(instance 変数)
//
//  Return
//    function : 実体
//
-(PoCoMainViewSupplement *)supplement
{
    return self->supplement_;
}


//
// 背景色設定
//
//  Call
//    col : 設定値
//
//  Return
//    supplement_ : 主ウィンドウの表示修飾(instance 変数)
//
-(void)setBackgroundColor:(unsigned int)col
{
    [self->supplement_ setBackgroundColor:col];
    [[NSUserDefaults standardUserDefaults] setInteger:[self->supplement_ backgroundColor]
                                               forKey:BACKGROUNDCOLOR_NAME];

    return;
}


//
// 背景種類設定
//
//  Call
//    flag : 設定値
//
//  Return
//    supplement_ : 主ウィンドウの表示修飾(instance 変数)
//
-(void)setPattern:(BOOL)flag
{
    [self->supplement_ setPattern:flag];
    [[NSUserDefaults standardUserDefaults] setBool:[self->supplement_ isPattern]
                                            forKey:BACKGROUNDPATTERN_NAME];

    return;
}


//
// ピクセルグリッド実線ステップ設定
//
//  Call
//    step : 設定値
//
//  Return
//    supplement_ : 主ウィンドウの表示修飾(instance 変数)
//
-(void)setGridStep:(unsigned int)step
{
    [self->supplement_ setGridStep:step];
    [[NSUserDefaults standardUserDefaults] setInteger:[self->supplement_ gridStep]
                                               forKey:PIXELGRIDSTEP_NAME];

    return;
}


// ------------------------------------------- instance - public - 補間曲線関連
//
// 補間曲線ガイドの表示方法取得
//
//  Call
//    interGuide_ : 補間曲線のガイドライン表示(instance 変数)
//
//  Return
//    function 設定内容
//
-(PoCoInterpolationGuideView)interGuide
{
    return self->interGuide_;
}


//
// 補間曲線の種類取得
//
//  Call
//    interType_ : 補間曲線の種類(instance 変数)
//
//  Return
//    function 設定内容
//
-(PoCoCurveWithPointsType)interType
{
    return self->interType_;
}


//
// 補間曲線の補間頻度取得
//
//  Call
//    interFreq_ : 補間曲線の補間頻度(instance 変数)
//
//  Return
//    function 設定内容
//
-(unsigned int)interFreq
{
    return self->interFreq_;
}


//
// 補間曲線ガイドの表示方法設定
//
//  Call
//    type : 設定内容
//
//  Return
//    interGuide_ : 補間曲線のガイドライン表示(instance 変数)
//
-(void)setInterGuide:(PoCoInterpolationGuideView)type
{
    self->interGuide_ = type;
    [[NSUserDefaults standardUserDefaults] setInteger:self->interGuide_
                                               forKey:INTERGUIDE_VIEW_NAME];

    return;
}


//
// 補間曲線の種類設定
//
//  Call
//    type : 設定内容
//
//  Return
//    interType_ : 補間曲線の種類(instance 変数)
//
-(void)setInterType:(PoCoCurveWithPointsType)type
{
    self->interType_ = type;
    [[NSUserDefaults standardUserDefaults] setInteger:self->interType_
                                               forKey:INTERPOLATION_TYPE_NAME];

    return;
}


//
// 補間曲線の補間頻度設定
//
//  Call
//    val : 設定内容
//
//  Return
//    interFreq_ : 補間曲線の補間頻度(instance 変数)
//
-(void)setInterFreq:(unsigned int)val
{
    self->interFreq_ = val;
    [[NSUserDefaults standardUserDefaults] setInteger:self->interFreq_
                                               forKey:INTERPOLATION_FREQ_NAME];

    return;
}


// ------------------------------------------- instance - public - 編集機能関連
//
// 選択中描画機能を取得
//
//  Call
//    drawModeType_ : 描画機能系(instance 変数)
//
//  Return
//    function : 設定内容
//
-(PoCoDrawModeType)drawModeType
{
    return self->drawModeType_;
}


//
// 連続指定を取得
//
//  Call
//    continuationType_ : 連続/不連続(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)continuationType
{
    return self->continuationType_;
}


//
// 濃度反転指定を取得
//
//  Call
//    flipType_ : 濃度反転(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)flipType
{
    return self->flipType_;
}


//
// 形状指定を取得
//
//  Call
//    pointModeType_ : 形状指定(instance 変数)
//
//  Return
//    function : 設定内容
//
-(PoCoPointModeType)pointModeType
{
    return self->pointModeType_;
}


//
// 描画ペン先指定を取得
//
//  Call
//    penStyleType_ : ペン先指定(描画)(instance 変数)
//
//  Return
//    function : 設定内容
//
-(PoCoPenStyleType)penStyleType
{
    return self->penStyleType_;
}


//
// 取り消し可否を取得
//
//  Call
//    enableUndo_ : 取り消し可否(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)enableUndo
{
    return self->enableUndo_;
}


//
// 消しゴム有効可否を取得
//
//  Call
//    enableEraser_ : 消しゴム有効可否(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)enableEraser
{
    return self->enableEraser_;
}


//
// 消しゴム指定を取得
//
//  Call
//    eraserType_ : 消しゴム指定(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)eraserType
{
    return self->eraserType_;
}


//
// 取り消し最大数を取得
//
//  Call
//    undoMaxLevel_ : 取り消し最大数(instance 変数)
//
//  Return
//    function : 設定内容
//
-(int)undoMaxLevel
{
    return self->undoMaxLevel_;
}


//
// LiveResize 可否を取得
//
//  Call
//    enableLiveResize_ : LiveResize 可否(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)enableLiveResize
{
    return self->enableLiveResize_;
}


//
// 色保持情報可否を取得
//
//  Call
//    enableColorBuffer_ : 色保持情報可否(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)enableColorBuffer
{
    return self->enableColorBuffer_;
}


//
// サイズの筆圧比例指定を取得
//
//  Call
//    sizePropType_ : サイズの筆圧比例指定(instance 変数)
//
//  Return
//    function : 設定内容
//
-(PoCoProportionalType)sizePropType
{
    return self->sizePropType_;
}


//
// 濃度の筆圧比例指定を取得
//
//  Call
//    densityPropType_ : 濃度の筆圧比例指定(instance 変数)
//
//  Return
//    function : 設定内容
//
-(PoCoProportionalType)densityPropType
{
    return self->densityPropType_;
}


//
// 霧吹きの移動方法を取得
//
//  Call
//    atomizerSkip_ : 霧吹きの移動方法(instance 変数)
//
//  Return
//    function : 設定内容
//
-(PoCoAtomizerSkipType)atomizerSkip
{
    return self->atomizerSkip_;
}


//
// 霧吹きの種類を取得
//
//  Call
//    atomizerType_ : 霧吹きの種類(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)atomizerType
{
    return self->atomizerType_;
}


//
// 選択領域塗りつぶし表示を取得
//
//  Call
//    selectionFill_ : 選択領域塗りつぶし表示(instance 変数)
//
//  Return
//    funtion : 設定内容
//
-(BOOL)selectionFill
{
    return self->selectionFill_;
}


//
// 選択範囲の編集を随時表示取得
//
//  Call
//    liveEditSelection_ : 選択範囲の編集を随時表示(instance 変数)
//
//  Return
//    funtion : 設定内容
//
-(BOOL)liveEditSelection
{
    return self->liveEditSelection_;
}


//
// 選択範囲のハンドル有無を取得
//
//  Call
//    withHandleSelection_ : 選択範囲のハンドル有無(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)useHandle
{
    return self->withHandleSelection_;
}


//
// 主ウィンドウ位置保存を取得
//
//  Call
//    saveDocWindowPos_ : 主ウィンドウ位置保存(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)saveDocWindowPos
{
    return self->saveDocWindowPos_;
}


//
// 補助ウィンドウ位置固定を取得
//
//  Call
//    holdSubWindowPos_ : 補助ウィンドウ位置固定(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)holdSubWindowPos
{
    return self->holdSubWindowPos_;
}


//
// 新規ドキュメントパネルを開かないを取得
//
//  Call
//    noOpenNewDocPanel_ : 新規ドキュメントパネルを開かない(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)noOpenNewDocPanel
{
    return self->noOpenNewDocPanel_;
}


//
// view で scroller 表示を取得
//
//  Call
//    showScrollerView_ : view で scroller を表示(instance 変数)
//
//  Return
//    function: 設定内容
//
-(PoCoScrollerType)showScrollerView
{
    return self->showScrollerView_;
}


//
// プレビューの品質を取得
//
//  Call
//    previewQuality_ : プレビューの品質(instance 変数)
//
//  Return
//    function : 設定内容
//
-(unsigned int)previewQuality
{
    return self->previewQuality_;
}


//
// プレビューの大きさを取得
//
//  Call
//    previewSize_ : プレビューの大きさ(instance 変数)
//
//  Return
//    function : 設定内容
//
-(unsigned int)previewSize
{
    return self->previewSize_;
}


//
// Grascale を不透明度とするを取得
//
//  Call
//    grayToAlpha_ : Grascale を不透明度とする(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)grayToAlpha
{
    return self->grayToAlpha_;
}


//
// 色範囲を取得
// 
//  Call
//    colorRange_ : 色範囲(instance 変数)
//
//  Return
//    function : 設定内容
//
-(int)colorRange
{
    return self->colorRange_;
}


//
// 表示ウィンドウとの同期を取得
//
//  Call
//    syncSubView_ : 表示ウィンドウとの同期(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)syncSubView
{
    return self->syncSubView_;
}


//
// 選択色との同期を取得
//
//  Call
//    syncPalette_ : 選択色との同期(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)syncPalette
{
    return self->syncPalette_;
}


//
// 描画機能を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    drawModeType_ : 描画機能系(instance 変数)
//
-(void)setDrawModeType:(PoCoDrawModeType)type
{
    self->drawModeType_ = type;
    [[NSUserDefaults standardUserDefaults] setInteger:self->drawModeType_
                                               forKey:DRAWMODE_NAME];

    return;
}


//
// 連続指定を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    continuationType_ : 連続/不連続(instance 変数)
//
-(void)setContinuationType:(BOOL)type
{
    self->continuationType_ = type;
    [[NSUserDefaults standardUserDefaults] setBool:self->continuationType_
                                            forKey:CONTINUATION_NAME];

    return;
}


//
// 濃度反転を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    flipType_ : 濃度反転(instance 変数)
//
-(void)setFlipType:(BOOL)type
{
    self->flipType_ = type;
    [[NSUserDefaults standardUserDefaults] setBool:self->flipType_
                                            forKey:FLIP_NAME];

    return;
}


//
// 形状指定を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    pointModeType_ : 形状指定(instance 変数)
//
-(void)setPointModeType:(PoCoPointModeType)type
{
    self->pointModeType_ = type;
    [[NSUserDefaults standardUserDefaults] setInteger:self->pointModeType_
                                               forKey:POINTMODE_NAME];

    return;
}


//
// 描画ペン先を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    penStyleType_ : ペン先指定(描画)(instance 変数)
//
-(void)setPenStyleType:(PoCoPenStyleType)type
{
    self->penStyleType_ = type;
    [[NSUserDefaults standardUserDefaults] setInteger:self->penStyleType_
                                               forKey:DRAWPENSTYLE_NAME];

    return;
}


//
// 取り消し可否を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    enableUndo_ : 取り消し可否(instance 変数)
//
-(void)setEnableUndo:(BOOL)type
{
    self->enableUndo_ = type;
    [[NSUserDefaults standardUserDefaults] setBool:self->enableUndo_
                                            forKey:ENABLEUNDO_NAME];

    return;
}


//
// 消しゴム有効可否を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    enableEraser_ : 消しゴム有効可否(instance 変数)
//
-(void)setEnableEraser:(BOOL)type
{
    self->enableEraser_ = type;
    [[NSUserDefaults standardUserDefaults] setBool:self->enableEraser_
                                            forKey:ENABLEERASER_NAME];

    return;
}


//
// 消しゴム指定を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    eraserType_ : 消しゴム指定(instance 変数)
//
-(void)setEraserType:(BOOL)type
{
    self->eraserType_ = type;

    return;
}


//
// 取り消し最大数を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    undoMaxLevel_ : 取り消し最大数(instance 変数)
//
-(void)setUndoMaxLevel:(int)type
{
    self->undoMaxLevel_ = type;
    [[NSUserDefaults standardUserDefaults] setInteger:self->undoMaxLevel_
                                               forKey:UNDOMAXLEVEL_NAME];

    // current document に反映させる
    [[[[NSDocumentController sharedDocumentController] currentDocument] undoManager] setLevelsOfUndo:self->undoMaxLevel_];


    return;
}


//
// LiveResize 可否を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    enableLiveResize_ : LiveResize 可否(instance 変数)
//
-(void)setEnableLiveResize:(BOOL)type
{
    self->enableLiveResize_ = type;
    [[NSUserDefaults standardUserDefaults] setBool:self->enableLiveResize_
                                            forKey:ENABLELIVERESIZE_NAME];

    return;
}


//
// 色保持情報可否を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    enableColorBuffer_ : 色保持情報可否(instance 変数)
//
-(void)setEnableColorBuffer:(BOOL)type
{
    self->enableColorBuffer_ = type;
    [[NSUserDefaults standardUserDefaults] setBool:self->enableColorBuffer_
                                            forKey:ENABLECOLORBUFFER_NAME];

    return;
}


//
// サイズの筆圧比例指定を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    sizePropType_ : サイズの筆圧比例指定(instance 変数)
//
-(void)setSizePropType:(PoCoProportionalType)type
{
    self->sizePropType_ = type;
    [[NSUserDefaults standardUserDefaults] setInteger:self->sizePropType_
                                               forKey:SIZEPROPTYPE_NAME];

    return;
}


//
// 濃度の筆圧比例指定を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    densityPropType_ : 濃度の筆圧比例指定(instance 変数)
//
-(void)setDensityPropType:(PoCoProportionalType)type
{
    self->densityPropType_ = type;
    [[NSUserDefaults standardUserDefaults] setInteger:self->densityPropType_
                                               forKey:DENSITYPROPTYPE_NAME];

    return;
}


//
// 霧吹きの移動方法を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    atomizerSkip_ : 霧吹きの移動方法(instance 変数)
//
-(void)setAtomizerSkip:(PoCoAtomizerSkipType)type
{
    self->atomizerSkip_ = type;
    [[NSUserDefaults standardUserDefaults] setInteger:self->atomizerSkip_
                                               forKey:ATOMIZERSKIPTYPE_NAME];

    return;
}


//
// 霧吹きの種類を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    atomizerType_ : 霧吹きの種類instance 変数)
//
-(void)setAtomizerType:(BOOL)type
{
    self->atomizerType_ = type;
    [[NSUserDefaults standardUserDefaults] setBool:self->atomizerType_
                                            forKey:ATOMIZERTYPE_NAME];

    return;
}


//
// 選択領域塗りつぶし表示を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    selectionFill_ : 選択領域塗りつぶし表示(instance 変数)
//
-(void)setSelectionFill:(BOOL)type
{
    self->selectionFill_ = type;
    [[NSUserDefaults standardUserDefaults] setBool:self->selectionFill_
                                            forKey:SELECTIONFILL_NAME];

    return;
}


//
// 選択範囲の編集を随時表示を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    liveEditSelection_ : 選択範囲の編集を随時表示(instance 変数)
//
-(void)setLiveEditSelection:(BOOL)type
{
    self->liveEditSelection_ = type;
    [[NSUserDefaults standardUserDefaults] setBool:self->liveEditSelection_
                                            forKey:LIVEEDITSELECTION_NAME];

    return;
}


//
// 選択範囲のハンドル有無を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    withHandleSelection_ : 選択範囲のハンドル有無(instance 変数)
//
-(void)setUseHandle:(BOOL)type
{
    self->withHandleSelection_ = type;
    [[NSUserDefaults standardUserDefaults] setBool:self->withHandleSelection_
                                            forKey:WITHHANDLESELECTION_NAME];

    return;
}


//
// 主ウィンドウ位置保存を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    saveDocWindowPos_ : 主ウィンドウ位置保存(instance 変数)
//
-(void)setSaveDocWindowPos:(BOOL)type
{
    self->saveDocWindowPos_ = type;
    [[NSUserDefaults standardUserDefaults] setBool:self->saveDocWindowPos_
                                            forKey:SAVEDOCWINDOWPOS_NAME];

    return;
}


//
// 補助ウィンドウ位置固定を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    holdSubWindowPos_ : 補助ウィンドウ位置固定(instance 変数)
//
-(void)setHoldSubWindowPos:(BOOL)type
{
    self->holdSubWindowPos_ = type;
    [[NSUserDefaults standardUserDefaults] setBool:self->holdSubWindowPos_
                                            forKey:HOLDDOCWINDOWPOS_NAME];

    return;
}


//
// 新規ドキュメントパネルを開かないを設定
//
//  Call
//    type : 設定内容
//
//  Return
//    noOpenNewDocPanel_ : 新規ドキュメントパネルを開かない(instance 変数)
//
-(void)setNoOpenNewDocPanel:(BOOL)type
{
    self->noOpenNewDocPanel_ = type;
    [[NSUserDefaults standardUserDefaults] setBool:self->noOpenNewDocPanel_ 
                                            forKey:NOOPENNEWDOCPANEL_NAME];

    return;
}


//
// view で scroller 表示を設定
//
//  Call
//    type : 設定内容
//
//  Return
//    showScrollerView_ : view で scroller を表示(instance 変数)
//
-(void)setShowScrollerView:(PoCoScrollerType)type
{
    self->showScrollerView_ = type;
    [[NSUserDefaults standardUserDefaults] setInteger:self->showScrollerView_
                                               forKey:SHOWSCROLLERVIEW_NAME];

    return;
}


//
// プレビューの品質を設定
//
//  Call
//    val : 設定内容
//
//  Return
//    previewQuality_ : プレビューの品質(instance 変数)
//
-(void)setPreviewQuality:(unsigned int)val
{
    self->previewQuality_ = val;
    [[NSUserDefaults standardUserDefaults] setInteger:self->previewQuality_
                                               forKey:PREVIEWQUALITY_NAME];

    return;
}


//
// プレビューの大きさを設定
//
//  Call
//    val : 設定内容
//
//  Return
//    previewSize_ : プレビューの大きさ(instance 変数)
//
-(void)setPreviewSize:(unsigned int)val
{
    self->previewSize_ = val;
    [[NSUserDefaults standardUserDefaults] setInteger:self->previewSize_
                                               forKey:PREVIEWSIZE_NAME];

    return;
}


//
// Grascale を不透明度とするを設定
//
//  Call
//    flag : 設定内容
//
//  Return
//    grayToAlpha_ : Grascale を不透明度とする(instance 変数)
//
-(void)setGrayToAlpha:(BOOL)flag
{
    self->grayToAlpha_ = flag;
    [[NSUserDefaults standardUserDefaults] setBool:self->grayToAlpha_
                                            forKey:GRAYSCALETOALPHA_NAME];

    return;
}


//
// 色範囲を設定
// 
//  Call
//    val : 設定内容
//
//  Return
//    colorRange_ : 色範囲(instance 変数)
//
-(void)setColorRange:(int)val
{
    self->colorRange_ = val;
    [[NSUserDefaults standardUserDefaults] setInteger:self->colorRange_
                                               forKey:RANGEOFCOLOR_NAME];

    return;
}


//
// 表示ウィンドウとの同期を設定
//
//  Call
//    flag : 設定内容
//
//  Return
//    syncSubView_ : 表示ウィンドウとの同期(instance 変数)
//
-(void)setSyncSubView:(BOOL)flag
{
    self->syncSubView_ = flag;
    [[NSUserDefaults standardUserDefaults] setBool:self->syncSubView_
                                            forKey:SYNCSUBVIEW_NAME];

    return;
}


//
// 選択色との同期を設定
//
//  Call
//    flag : 設定内容
//
//  Return
//    syncPalette_ : 選択色との同期(instance 変数)
//
-(void)setSyncPalette:(BOOL)flag
{
    self->syncPalette_ = flag;
    [[NSUserDefaults standardUserDefaults] setBool:self->syncPalette_
                                            forKey:SYNCPALETTE_NAME];
}

@end
