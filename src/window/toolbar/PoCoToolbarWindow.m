//
//	Pelistina on Cocoa - PoCo -
//	ツールバーウィンドウ管理部
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoToolbarWindow.h"

#import <Carbon/Carbon.h>

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"

// ============================================================================
@implementation PoCoToolbarWindow

// --------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function        : 実体
//    info_           : 編集情報(instance 変数)
//    continueImage_  : 連続(instance 変数)
//    discreteImage_  : 非連続(instance 変数)
//    handleImage_    : ハンドルあり(instance 変数)
//    nohandleImage_  : ハンドルなし(instance 変数)
//    selectImage_    : 矩形選択(instance 変数)
//    anyselectImage_ : 任意領域選択(instance 変数)
//
-(id)init
{
    DPRINT((@"[PoCoToolbarWindow init]\n"));

    // super class を初期化
    self = [super initWithWindowNibName:@"PoCoToolbarWindow"];

    // 自身を初期化
    if (self != nil) {
        self->continueImage_ = nil;
        self->discreteImage_ = nil;
        self->handleImage_ = nil;
        self->nohandleImage_ = nil;
        self->selectImage_ = nil;
        self->anyselectImage_ = nil;

        // 編集情報の取得
        self->info_ = [(PoCoAppController *)([NSApp delegate]) editInfo];
        [self->info_ retain];

        // 位置保存
        [self setWindowFrameAutosaveName:@"ToolbarWindowPos"];
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
//    info_           : 編集情報(instance 変数)
//    continueImage_  : 連続(instance 変数)
//    discreteImage_  : 非連続(instance 変数)
//    handleImage_    : ハンドルあり(instance 変数)
//    nohandleImage_  : ハンドルなし(instance 変数)
//    selectImage_    : 矩形選択(instance 変数)
//    anyselectImage_ : 任意領域選択(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoToolbarWindow dealloc]\n"));

    // 資源の解放
    [self->info_ release];
    [self->continueImage_ release];
    [self->discreteImage_ release];
    [self->handleImage_ release];
    [self->nohandleImage_ release];
    [self->selectImage_ release];
    [self->anyselectImage_ release];
    self->info_ = nil;
    self->continueImage_ = nil;
    self->discreteImage_ = nil;
    self->handleImage_ = nil;
    self->nohandleImage_ = nil;
    self->selectImage_ = nil;
    self->anyselectImage_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// nib が読み込まれた
//
//  Call
//    freeLine_            : 自由曲線(outlet)
//    line_                : 直線(outlet)
//    box_                 : 矩形枠(outlet)
//    ellipse_             : 円/楕円(outlet)
//    parallelogram_       : 平行四辺形(outlet)
//    boxFill_             : 塗りつぶし矩形枠(outlet)
//    ellipseFill_         : 塗りつぶし円/楕円(outlet)
//    parallelogramFill_   : 塗りつぶし平行四辺形(outlet)
//    paint_               : 塗りつぶし(outlet)
//    propotionalFreeLine_ : 筆圧比例自由曲線(outlet)
//    selection_           : 選択(outlet)
//    drogMove_            : ずりずり(outlet)
//    normal_              : 通常(outlet)
//    atomizer_            : 霧吹き(outlet)
//    random_              : 拡散(outlet)
//    density_             : 濃度(outlet)
//    gradation_           : グラデーション(outlet)
//    uniformedDensity_    : 単一濃度(outlet)
//    waterDrop_           : ぼかし(outlet)
//    pointHold_           : 起点固定(outlet)
//    pointMove_           : 起点移動(outlet)
//    identicalShape_      : 形状固定(outlet)
//    sizeRelation_        : 筆圧比例(サイズ)(outlet)
//    sizeHold_            : 筆圧固定(サイズ)(outlet)
//    sizeWithPattern_     : パターンを使用(サイズ)(outlet)
//    densityRelation_     : 筆圧比例(濃度)(outlet)
//    densityHold_         : 筆圧固定(濃度)(outlet)
//    densityWithPattern_  : パターンを使用(濃度)(outlet)
//    skipAlways_          : 常に移動(outlet)
//    skipBinary_          : 偶数ないし奇数(outlet)
//    skipHold_            : 維持(outlet)
//    continueImage_       : 連続(instance 変数)
//    discreteImage_       : 非連続(instance 変数)
//    handleImage_         : ハンドルあり(instance 変数)
//    nohandleImage_       : ハンドルなし(instance 変数)
//    selectImage_         : 矩形選択(instance 変数)
//    anyselectImage_      : 任意領域選択(instance 変数)
//
//  Return
//    drawMode_[]     : 描画機能系パーツ群(instance 変数)
//    penStyle_[]     : ペン先指定系パーツ群(instance 変数)
//    pointMode_[]    : 形状指定系パーツ群(instance 変数)
//    penSizeProp_[]  : サイズ指定系パーツ群(instance 変数)
//    densityProp_[]  : 濃度指定系パーツ群(instance 変数)
//    atomizerSkip_[] : 霧吹き移動系パーツ群(instance 変数)
//
-(void)awakeFromNib
{
    DPRINT((@"[PoCoToolbarWindow awakeFromNib]\n"));

    // 参照ポインタの複写(retain はしない)
    self->drawMode_[PoCoDrawModeType_FreeLine] = self->freeLine_;
    self->drawMode_[PoCoDrawModeType_Line] = self->line_;
    self->drawMode_[PoCoDrawModeType_Box] = self->box_;
    self->drawMode_[PoCoDrawModeType_Ellipse] = self->ellipse_;
    self->drawMode_[PoCoDrawModeType_Parallelogram] = self->parallelogram_;
    self->drawMode_[PoCoDrawModeType_BoxFill] = self->boxFill_;
    self->drawMode_[PoCoDrawModeType_EllipseFill] = self->ellipseFill_;
    self->drawMode_[PoCoDrawModeType_ParallelogramFill] = self->parallelogramFill_;
    self->drawMode_[PoCoDrawModeType_Paint] = self->paint_;
    self->drawMode_[PoCoDrawModeType_ProportionalFreeLine] = self->propotionalFreeLine_;
    self->drawMode_[PoCoDrawModeType_Selection] = self->selection_;
    self->drawMode_[PoCoDrawModeType_DragMove] = self->drogMove_;

    self->pointMode_[PoCoPointModeType_PointHold] = self->pointHold_;
    self->pointMode_[PoCoPointModeType_PointMove] = self->pointMove_;
    self->pointMode_[PoCoPointModeType_IdenticalShape] = self->identicalShape_;

    self->penStyle_[PoCoPenStyleType_Normal] = self->normal_;
    self->penStyle_[PoCoPenStyleType_Atomizer] = self->atomizer_;
    self->penStyle_[PoCoPenStyleType_Random] = self->random_;
    self->penStyle_[PoCoPenStyleType_Density] = self->density_;
    self->penStyle_[PoCoPenStyleType_Gradation] = self->gradation_;
    self->penStyle_[PoCoPenStyleType_UniformedDensity] = self->uniformedDensity_;
    self->penStyle_[PoCoPenStyleType_WaterDrop] = self->waterDrop_;
    self->penSizeProp_[PoCoProportionalType_Relation] = self->sizeRelation_;
    self->penSizeProp_[PoCoProportionalType_Hold] = self->sizeHold_;
    self->penSizeProp_[PoCoProportionalType_Pattern] = self->sizeWithPattern_;
    self->densityProp_[PoCoProportionalType_Relation] = self->densityRelation_;
    self->densityProp_[PoCoProportionalType_Hold] = self->densityHold_;
    self->densityProp_[PoCoProportionalType_Pattern] = self->densityWithPattern_;
    self->atomizerSkip_[PoCoAtomizerSkipType_Always] = self->skipAlways_;
    self->atomizerSkip_[PoCoAtomizerSkipType_Binary] = self->skipBinary_;
    self->atomizerSkip_[PoCoAtomizerSkipType_Pattern] = self->skipHold_;

    // 画像を取得
    self->continueImage_ = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"continue" ofType:@"tiff"]];
    self->discreteImage_ = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"discrete" ofType:@"tiff"]];
    self->handleImage_ = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"handle" ofType:@"tiff"]];
    self->nohandleImage_ = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"nohandle" ofType:@"tiff"]];
    self->selectImage_ = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"select" ofType:@"tiff"]];
    self->anyselectImage_ = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"anyselect" ofType:@"tiff"]];

    return;
}


//
// ウィンドウが読み込まれた
//
//  Call
//    selection_      : 選択(outlet)
//    continuation_   : 連続(outlet)
//    flip_           : 濃度反転(outlet)
//    handle_         : ハンドル有無(outlet)
//    normalTone_     : 通常(outlet)
//    halfTone_       : 半値(outlet)
//    info_           : 編集情報(instance 変数)
//    drawMode_[]     : 描画機能系パーツ群(instance 変数)
//    penStyle_[]     : ペン先指定系パーツ群(instance 変数)
//    pointMode_[]    : 形状指定系パーツ群(instance 変数)
//    penSizeProp_[]  : サイズ指定系パーツ群(instance 変数)
//    densityProp_[]  : 濃度指定系パーツ群(instance 変数)
//    atomizerSkip_[] : 霧吹き移動系パーツ群(instance 変数)
//    continueImage_  : 連続(instance 変数)
//    discreteImage_  : 非連続(instance 変数)
//    handleImage_    : ハンドルあり(instance 変数)
//    nohandleImage_  : ハンドルなし(instance 変数)
//    selectImage_    : 矩形選択(instance 変数)
//    anyselectImage_ : 任意領域選択(instance 変数)
//
//  Return
//    None
//
-(void)windowDidLoad
{
    unsigned int l;
    unsigned int sel;

    DPRINT((@"[PoCoToolbarWindow windowDidLoad]\n"));

    // 編集機能系パーツの状態初期化
    sel = (unsigned int)([self->info_ drawModeType]);
    for (l = 0; l < PoCoDrawModeType_MAX; (l)++) {
        [self->drawMode_[l] setIntValue:((sel == l) ? 1 : 0)];
    }

    // ペン先指定系パーツの状態初期化
    sel = (unsigned int)([self->info_ penStyleType]);
    for (l = 0; l < PoCoPenStyleType_MAX; (l)++) {
        [self->penStyle_[l] setIntValue:((sel == l) ? 1 : 0)];
    }

    // 連続指定パーツの状態初期化
    if ([self->info_ continuationType]) {
        [self->continuation_ setIntValue:1];
        [self->continuation_ setImage:self->continueImage_];
        [self->selection_ setImage:self->anyselectImage_];
    } else {
        [self->continuation_ setIntValue:0];
        [self->continuation_ setImage:self->discreteImage_];
        [self->selection_ setImage:self->selectImage_];
    }

    // 濃度反転指定パーツの状態初期化
    [self->flip_ setIntValue:([self->info_ flipType] ? 1 : 0)];

    // ハンドル有無指定パーツの状態初期化
    if ([self->info_ useHandle]) {
        [self->handle_ setIntValue:1];
        [self->handle_ setImage:self->handleImage_];
    } else {
        [self->handle_ setIntValue:0];
        [self->handle_ setImage:self->nohandleImage_];
    }

    // 形状指定系パーツの状態初期化
    sel = (unsigned int)([self->info_ pointModeType]);
    for (l = 0; l < PoCoPointModeType_MAX; (l)++) {
        [self->pointMode_[l] setIntValue:((sel == l) ? 1 : 0)];
    }

    // サイズ指定系パーツの状態初期化
    sel = (unsigned int)([self->info_ sizePropType]);
    for (l = 0; l < PoCoProportionalType_MAX; (l)++) {
        [self->penSizeProp_[l] setIntValue:((sel == l) ? 1 : 0)];
    }

    // 濃度指定系パーツの状態初期化
    sel = (unsigned int)([self->info_ densityPropType]);
    for (l = 0; l < PoCoProportionalType_MAX; (l)++) {
        [self->densityProp_[l] setIntValue:((sel == l) ? 1 : 0)];
    }

    // 霧吹き移動系パーツの状態初期化
    sel = (unsigned int)([self->info_ atomizerSkip]);
    for (l = 0; l < PoCoAtomizerSkipType_MAX; (l)++) {
        [self->atomizerSkip_[l] setIntValue:((sel == l) ? 1 : 0)];
    }

    // 霧吹き移動系パーツの状態初期化
    [self->normalTone_ setIntValue:(([self->info_ atomizerType]) ? 0 : 1)];
    [self->halfTone_ setIntValue:(([self->info_ atomizerType]) ? 1 : 0)];

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
    [(PoCoAppController *)([NSApp delegate]) closedToolbarWindow];

    return;
}


//
// 取り消し情報の引き渡し
//
//  Call
//    sender : 管理元ウィンドウ(api 変数)
//  
//  Return
//    function : 取り消し情報
//
-(NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender
{
    return [[[NSDocumentController sharedDocumentController] currentDocument] undoManager];
}


//
// 描画機能を切り替え(番号指定)
//
//  Call
//    type        : 番号(編集機能番号)
//    drawMode_[] : 描画機能系パーツ群(instance 変数)
//
//  Return
//    None
//
-(void)setDrawModeAtType:(PoCoDrawModeType)type
{
    // 範囲内の番号なら切り替え
    if (type < PoCoDrawModeType_MAX) {
        [self->drawMode_[type] setIntValue:1];
        [self drawMode:self->drawMode_[type]];
    }

    return;
}


// -------------------------------------------- instance - public - IBAction 系
//
// 描画機能系
//  自由曲線、直線、矩形枠、円/楕円、平行四辺形、塗りつぶし矩形枠、
//  塗りつぶし円/楕円、塗りつぶし平行四辺形、塗りつぶし、
//  筆圧比例自由曲線、選択、ずりずり
//
//  Call
//    sender : 操作対象
//    info_  : 編集情報(instance 変数)
//
//  Return
//    info_       : 編集情報(instance 変数)
//    drawMode_[] : 描画機能系パーツ群(instance 変数)
//
-(IBAction)drawMode:(id)sender
{
    const unsigned int sel = (int)([sender tag]);
    const unsigned int old = (unsigned int)([self->info_ drawModeType]);

    if (old != sel) { 
        [self->drawMode_[old] setIntValue:0];
        [self->drawMode_[sel] setIntValue:1];
        [self->info_ setDrawModeType:(PoCoDrawModeType)(sel)];

        // 切り替えを通知
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoChangeDrawTool
                          object:nil];
    } else {
        [self->drawMode_[old] setIntValue:1];
    }

    return;
}


//
// ペン先指定
//  通常、霧吹き、拡散、濃度拡散、グラデーション、単一濃度、ぼかし
//
//  Call
//    sender : 操作対象
//    info_  : 編集情報(instance 変数)
//
//  Return
//    info_       : 編集情報(instance 変数)
//    penStyle_[] : ペン先指定系パーツ群(instance 変数)
//
-(IBAction)penStyle:(id)sender
{
    const unsigned int sel = (unsigned int)([sender tag]);
    const unsigned int old = (unsigned int)([self->info_ penStyleType]);

    if (old != sel) { 
        [self->penStyle_[old] setIntValue:0];
        [self->penStyle_[sel] setIntValue:1];
        [self->info_ setPenStyleType:(PoCoPenStyleType)(sel)];

        // 切り替えを通知
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoChangeDrawTool
                          object:nil];
    } else {
        [self->penStyle_[old] setIntValue:1];
    }

    return;
}


//
// 連続
//  連続(補助属性)
//
//  Call
//    sender          : 操作対象
//    info_           : 編集情報(instance 変数)
//    continueImage_  : 連続(instance 変数)
//    discreteImage_  : 非連続(instance 変数)
//    selectImage_    : 矩形選択(instance 変数)
//    anyselectImage_ : 任意領域選択(instance 変数)
//
//  Return
//    selection_    : 選択(outlet)
//    continuation_ : 連続(outlet)
//    info_         : 編集情報(instance 変数)
//
-(IBAction)continuation:(id)sender
{
    // 設定を反転
    [self->info_ setContinuationType:(([self->info_ continuationType]) ? NO : YES)];

    // 表示に反映
    if ([self->info_ continuationType]) {
        [self->continuation_ setIntValue:1];
        [self->continuation_ setImage:self->continueImage_];
        [self->selection_ setImage:self->anyselectImage_];
    } else {
        [self->continuation_ setIntValue:0];
        [self->continuation_ setImage:self->discreteImage_];
        [self->selection_ setImage:self->selectImage_];
    }

#if 0   // DrawTool の切り替えとはしないので通知しない
    // 切り替えを通知
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoChangeDrawTool
                      object:nil];
#endif  // 0

    return;
}


//
// 反転
//  濃度反転(補助属性)
//
//  Call
//    sender : 操作対象
//    info_  : 編集情報(instance 変数)
//
//  Return
//    flip_ : 反転(outlet)
//    info_ : 編集情報(instance 変数)
//
-(IBAction)flip:(id)sender
{
    // 設定を反転
    [self->info_ setFlipType:(([self->info_ flipType]) ? NO : YES)];

    // 表示に反映
    [self->flip_ setIntValue:([self->info_ flipType] ? 1 : 0)];

    return;
}


//
// ハンドル有無
//
//  Call
//    sender         : 操作対象
//    info_          : 編集情報(instance 変数)
//    handleImage_   : ハンドルあり(instance 変数)
//    nohandleImage_ : ハンドルなし(instance 変数)
//
//  Return
//    handle_ : ハンドル有無(outlet)
//    info_   : 編集情報(instance 変数)
//
-(IBAction)handle:(id)sender
{
    // ガイドライン消去
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoRedrawGuideLine
                      object:nil];

    // 設定を反転
    [self->info_ setUseHandle:(([self->info_ useHandle]) ? NO : YES)];

    // 表示に反映
    if ([self->info_ useHandle]) {
        [self->handle_ setIntValue:1];
        [self->handle_ setImage:self->handleImage_];
    } else {
        [self->handle_ setIntValue:0];
        [self->handle_ setImage:self->nohandleImage_];
    }

    // ガイドライン再描画
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoRedrawGuideLine
                      object:nil];

    return;
}


//
// 形状指定
//  起点固定、起点移動、形状固定
//
//  Call
//    sender : 操作対象
//    info_  : 編集情報(instance 変数)
//
//  Return
//    info_        : 編集情報(instance 変数)
//    pointMode_[] : 形状指定系パーツ群(instance 変数)
//
//
-(IBAction)pointMode:(id)sender
{
    const unsigned int sel = (unsigned int)([sender tag]);
    const unsigned int old = (unsigned int)([self->info_ pointModeType]);

    if (old != sel) { 
        [self->pointMode_[old] setIntValue:0];
        [self->pointMode_[sel] setIntValue:1];
        [self->info_ setPointModeType:(PoCoPointModeType)(sel)];
    } else {
        [self->pointMode_[old] setIntValue:1];
    }

    return;
}


//
// 筆圧比例(サイズ)
//  筆圧比例、筆圧固定、パターン使用
//
//  Call
//    sender : 操作対象
//    info_  : 編集情報(instance 変数)
//
//  Return
//    info_      : 編集情報(instance 変数)
//    penSizeProp_[] : サイズ指定系パーツ群(instance 変数)
//
-(IBAction)penSize:(id)sender
{
    const unsigned int sel = (unsigned int)([sender tag]);
    const unsigned int old = (unsigned int)([self->info_ sizePropType]);

    if (old != sel) { 
        [self->penSizeProp_[old] setIntValue:0];
        [self->penSizeProp_[sel] setIntValue:1];
        [self->info_ setSizePropType:(PoCoProportionalType)(sel)];
    } else {
        [self->penSizeProp_[old] setIntValue:1];
    }

    return;
}


//
// 筆圧比例(濃度)
//  筆圧比例、筆圧固定、パターン使用
//
//  Call
//    sender : 操作対象
//    info_  : 編集情報(instance 変数)
//
//  Return
//    info_          : 編集情報(instance 変数)
//    densityProp_[] : 濃度指定系パーツ群(instance 変数)
//
-(IBAction)density:(id)sender
{
    const unsigned int sel = (unsigned int)([sender tag]);
    const unsigned int old = (unsigned int)([self->info_ densityPropType]);

    if (old != sel) { 
        [self->densityProp_[old] setIntValue:0];
        [self->densityProp_[sel] setIntValue:1];
        [self->info_ setDensityPropType:(PoCoProportionalType)(sel)];
    } else {
        [self->densityProp_[old] setIntValue:1];
    }

    return;
}


//
// 通常霧吹き
//
//  Call
//    sender : 操作対象
//    info_  : 編集情報(instance 変数)
//
//  Return
//    None
//    normalTone_ : 通常(outlet)
//    halfTone_   : 半値(outlet)
//    info_       : 編集情報(instance 変数)
//
-(IBAction)normalTone:(id)sender
{
    // 設定
    [self->info_ setAtomizerType:NO];

    // 表示に反映
    [self->normalTone_ setIntValue:YES];
    [self->halfTone_ setIntValue:NO];

    return;
}


//
// 半値霧吹き
//
//  Call
//    sender : 操作対象
//    info_  : 編集情報(instance 変数)
//
//  Return
//    halfTone_ : 半値(outlet)
//    info_     : 編集情報(instance 変数)
//
-(IBAction)halfTone:(id)sender
{
    // 設定
    [self->info_ setAtomizerType:YES];

    // 表示に反映
    [self->normalTone_ setIntValue:NO];
    [self->halfTone_ setIntValue:YES];

    return;
}


//
// 霧吹き移動
//  常に、２値、形状
//
//  Call
//    sender : 操作対象
//    info_  : 編集情報(instance 変数)
//
//  Return
//    info_           : 編集情報(instance 変数)
//    atomizerSkip_[] : 霧吹き移動系パーツ群(instance 変数)
//
-(IBAction)atomizerSkip:(id)sender
{
    const unsigned int sel = (unsigned int)([sender tag]);
    const unsigned int old = (unsigned int)([self->info_ atomizerSkip]);

    if (old != sel) { 
        [self->atomizerSkip_[old] setIntValue:0];
        [self->atomizerSkip_[sel] setIntValue:1];
        [self->info_ setAtomizerSkip:(PoCoAtomizerSkipType)(sel)];
    } else {
        [self->atomizerSkip_[old] setIntValue:1];
    }

    return;
}


// ----------------------------------------- instance - public - イベントの取得
//
// キーダウン処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    None
//
-(void)keyDown:(NSEvent *)evt
{
    // スペースキーイベント(keyDown)を通知
    if ([evt keyCode] == kVK_Space) {
        if (!([evt isARepeat])) {
            [[NSNotificationCenter defaultCenter]
                postNotificationName:PoCoSpaceKeyEvent
                              object:[NSNumber numberWithBool:YES]];
        }
    } else {
        // super class へ回送
        [super keyDown:evt];
    }

    return;
}


//
// キーリリース処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    None
//
-(void)keyUp:(NSEvent *)evt
{
    // スペースキーイベント(keyUp)を通知
    if ([evt keyCode] == kVK_Space) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoSpaceKeyEvent
                          object:[NSNumber numberWithBool:NO]];
    } else {
        // super class へ回送
        [super keyUp:evt];
    }

    return;
}

@end
