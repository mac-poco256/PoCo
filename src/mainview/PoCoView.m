//
//	Pelistina on Cocoa - PoCo -
//	PoCoView class
//
//	Copyright (C) 2005-2019 KAENRYUU Koutoku.
//

#import "PoCoView.h"

#import <Carbon/Carbon.h>

#import "PoCoAppController.h"
#import "PoCoSelLayer.h"
#import "PoCoEditInfo.h"
#import "PoCoPalette.h"
#import "PoCoPicture.h"
#import "PoCoMyDocument.h"

#import "PoCoDrawBase.h"
#import "PoCoDrawSelection.h"
#import "PoCoDrawFactory.h"

#import "PoCoDocumentSettingPanel.h"
#import "PoCoCanvasResizePanel.h"
#import "PoCoImportPalettePanel.h"
#import "PoCoAutoGradationPanel.h"
#import "PoCoColorReplacePanel.h"
#import "PoCoTexturePanel.h"
#import "PoCoToolbarWindow.h"

#import "PoCoControllerFactory.h"
#import "PoCoControllerPaletteIncrementer.h"
#import "PoCoControllerPaletteDecrementer.h"
#import "PoCoControllerPaletteAttributeSetter.h"


// 内部定数
static const int FRAME_GAP = 50;


// 内部変数
static const int ZOOM_FACTOR[] = {      // 表示倍率テーブル(0.1%単位)
      10,   20,   25,   50,  100,  200,  250,  300,   400,   500,   600,   700,   750,   800,   900,
    1000,
    2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 11000, 12000, 13000, 14000, 15000, 16000
};

// ============================================================================
@implementation PoCoView

// --------------------------------------------------------- instance - private
//
// 倍率に合わせたアキを算出
//
//  Call
//    zfact     : 表示倍率
//    frameGap_ : アキ(instance 変数)
//
//  Return
//    function : アキ
//
-(int)calcFrameGap:(int)zfact
{
    return self->frameGap_;
}


//
// 実寸での範囲の取得
//
//  Call
//    rect  : 再描画領域(要求領域)
//    zfact : 表示倍率
//
//  Return
//    function : 実寸での座標
//
-(PoCoRect *)calcSrcRect:(NSRect)rect
                   zfact:(int)zfact
{
    PoCoRect *r;
    const int gap = [self calcFrameGap:zfact];

    // 要表示領域/描画領域を算出
    r = [[PoCoRect alloc] initNSRect:rect];
    if (zfact == 1000) {
        // 等倍
        [r shiftX:-(gap)];
        [r shiftY:-(gap)];
    } else {
        // 拡大/縮小(端数が出ないので共通)
        [r   setLeft:(((rect.origin.x -              gap) * 1000) / zfact)];
        [r    setTop:(((rect.origin.y -              gap) * 1000) / zfact)];
        [r  setRight:(((rect.origin.x +  rect.size.width) * 1000) / zfact)];
        [r setBottom:(((rect.origin.y + rect.size.height) * 1000) / zfact)];
        if (((int)((rect.origin.x + rect.size.width) * 1000) % zfact) != 0) {
            [r setRight:([r right] + 1)];
        }
        if (((int)((rect.origin.y + rect.size.height) * 1000) % zfact) != 0) {
            [r setBottom:([r bottom] + 1)];
        }
    }

    return r;
}


//
// 再描画の実行
//
//  Call
//    rect      : 再描画領域(要求領域)
//    zfact     : 表示倍率
//    document_ : 編集対象の元締め(outlet)
//
//  Return
//    None
//
-(void)execDraw:(NSRect)rect
          zfact:(int)zfact
{
    NSRect dr;                          // 表示領域
    PoCoRect *sr;                       // 取得領域
    NSBitmapImageRep *img;              // 表示画像
    const int gap = [self calcFrameGap:zfact];

//    DPRINT((@"execDraw rect:{%f, %f, %f, %f}]\n", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height));

    // 要表示領域/描画領域を算出
    sr = [self calcSrcRect:rect
                     zfact:zfact];
    dr = rect;
    if (zfact == 1000) {
        // 等倍
        if (rect.origin.x < gap) {
            dr.origin.x += (gap - rect.origin.x);
        }
        if (rect.origin.y < gap) {
            dr.origin.y += (gap - rect.origin.y);
        }
    } else {
        // 拡大/縮小(端数が出ないので共通)
        if (rect.origin.x <= gap) {
            dr.origin.x = gap;
        } else {
            dr.origin.x = ((([sr left] * zfact) / 1000) + gap);
        }
        if (rect.origin.y <= gap) {
            dr.origin.y = gap;
        } else {
            dr.origin.y = ((([sr top] * zfact) / 1000) + gap);
        }
    }

    // 表示画像を取得
    img = [[self->document_ picture] getMainImage:sr
                                        withScale:zfact
                                   withSupplement:[self->editInfo_ supplement]];
    if (img != nil) {
        // 表示を実行
        [img drawAtPoint:dr.origin];

        // 表示画像を release
        [img release];
    }
    [sr release];

    return;
}


//
// ウィンドウ内座標から画像内座標への変換
//
//  Call
//    p         : PD 位置(ウィンドウ内)
//    zfactNum_ : 表示倍率の選択番号(instance 変数)
//
//  Return
//    function : 座標
//
-(PoCoPoint *)toPictPos:(NSPoint)p
{
    int x;
    int y;
    const int zfact = ZOOM_FACTOR[self->zfactNum_];
    const int gap = [self calcFrameGap:zfact];

    if (zfact == 1000) {
        x = ((int)(p.x) - gap);
        y = ((int)(p.y) - gap);
    } else {
        x = ((((int)(p.x - gap)) * 1000) / zfact);
        y = ((((int)(p.y - gap)) * 1000) / zfact);
    }

    return [[PoCoPoint alloc] initX:x initY:y];
}


//
// PD 位置の通達
//
//  Call
//    p         : PD 位置(ウィンドウ内)
//    document_ : 編集対象の元締め(outlet)
//
//  Return
//    editInfo_ : 編集情報(instance 変数)
//
-(void)setInfoPDPos:(NSPoint)p
{
    PoCoPoint *pos;
    PoCoRect *r;

    r = [[self->document_ picture] bitmapPoCoRect];

    // 倍率を反映した位置を算出
    pos = [self toPictPos:p];

    // 画像範囲内に収める
    if ([pos x] < [r left]) {
        [pos setX:[r left]];
    } else if ([pos x] >= [r right]) {
        [pos setX:([r right] - 1)];
    }
    if ([pos y] < [r top]) {
        [pos setY:[r top]];
    } else if ([pos y] >= [r bottom]) {
        [pos setY:([r bottom] - 1)];
    }

    // 設定
    [self->editInfo_ setPDPos:pos];
    [pos release];
    [r release];

    return;
}


//
// 表示倍率変更
//
//  Call
//    num       : 変更予定の倍率番号
//    zfactNum_ : 表示倍率の選択番号(instance 変数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    zfactNum_ : 表示倍率の選択番号(instance 変数)
//
-(void)changeZoom:(int)num
{
    int zchg;
    PoCoPoint *p;
    PoCoRect *r;

    r = nil;

    if (self->zfactNum_ != num) {
        // ガイドライン消去
        [self drawGuideLine];

        // 現在の表示範囲を取得
        r = [self calcSrcRect:[self visibleRect]
                        zfact:ZOOM_FACTOR[self->zfactNum_]];
        p = [self->editInfo_ lastPos];
        zchg = ((ZOOM_FACTOR[self->zfactNum_] * 1000) / ZOOM_FACTOR[num]);
        [r   setLeft:([p x] - ((([p x] - [r   left]) * zchg) / 1000))];
        [r    setTop:([p y] - ((([p y] - [r    top]) * zchg) / 1000))];
        [r  setRight:([p x] - ((([p x] - [r  right]) * zchg) / 1000))];
        [r setBottom:([p y] - ((([p y] - [r bottom]) * zchg) / 1000))];

        // 更新
        self->zfactNum_ = num;

        // レイヤー変形扱いで view の範囲を更新
        [self layerResize:NO];

        // 表示位置を調整して再描画要求を発行
        [self scrollPoint:[self toDispRect:r].origin];

        // ガイドライン表示
        [self drawGuideLine];
    }
    [r release];

    return;
}


#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
// ------------------------------------------------------------- class - public
//
// responsive scroll
//
//  Call
//    None
//
//  Return
//    function : 常時 YES
//
+(BOOL)isCompatibleWithResponsiveScrolling
{
    return YES;
}
#endif  // (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    frameRect : 矩形枠(api 引数)
//
//  Return
//    function          : 実体
//    zfactNum_         : 表示倍率の選択番号(instance 変数)
//    frameGap_         : アキ(instance 変数)
//    isDrawing_        : 描画中(instance 変数)
//    isAltMode_        : ALT 同時押し状態(instance 変数)
//    isSpaceMode_      : SPACE 同時押し状態(instance 変数)
//    editInfo_         : 編集情報(instance 変数)
//    drawTool_         : 編集機能の実体(instance 変数)
//    prevContinuation_ : 以前の連続/不連続(instance 変数)
//    prevDrawMode_     : 以前の描画機能(instance 変数)
//    prevPenStyle_     : 以前のペン先(instance 変数)
//
-(id)initWithFrame:(NSRect)frameRect
{
    NSNotificationCenter *notes;

    DPRINT((@"[PoCoView initWithFrame:{%f, %f, %f, %f}]\n", frameRect.origin.x, frameRect.origin.y, frameRect.size.width, frameRect.size.height));

    // super class の初期化
    self = [super initWithFrame:frameRect];

    // 自身の初期化
    if (self != nil) {
        self->zfactNum_ = 15;
        self->frameGap_ = FRAME_GAP;
        self->isDrawing_ = NO;
        self->isAltMode_ = NO;
        self->isSpaceMode_ = NO;
        self->editInfo_ = nil;
        self->drawTool_ = nil;
        self->prevDrawMode_ = PoCoDrawModeType_MAX;
        self->prevPenStyle_ = PoCoPenStyleType_MAX;

        // 編集情報の取得
        self->editInfo_ = [(PoCoAppController *)([NSApp delegate]) editInfo];
        [self->editInfo_ retain];
        self->prevContinuation_ = [self->editInfo_ continuationType];

        // アキを算出
        self->frameGap_ = (int)(MIN([[NSScreen mainScreen] frame].size.width, [[NSScreen mainScreen] frame].size.height) * 0.1);

        // observer へ登録
        notes = [NSNotificationCenter defaultCenter];
        [notes addObserver:self
                  selector:@selector(undoManagementing:)
                      name:NSUndoManagerWillUndoChangeNotification 
                    object:nil];
        [notes addObserver:self
                  selector:@selector(undoManagementing:)
                      name:NSUndoManagerDidUndoChangeNotification 
                    object:nil];
        [notes addObserver:self
                  selector:@selector(undoManagementing:)
                      name:NSUndoManagerWillRedoChangeNotification 
                    object:nil];
        [notes addObserver:self
                  selector:@selector(undoManagementing:)
                      name:NSUndoManagerDidRedoChangeNotification 
                    object:nil];

#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6)
        // touch event を受け取る
        [self setAcceptsTouchEvents:YES];
        [self setWantsRestingTouches:YES];
#endif  // MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6
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
//    editInfo_ : 編集情報(instance 変数)
//    drawTool_ : 編集機能の実体(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoView dealloc]\n"));

    // observer の登録解除
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // 資源の解放
    [self->editInfo_ release];
    [self->drawTool_ release];
    self->editInfo_ = nil;
    self->drawTool_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// レイヤーサイズの変形に伴う再描画
//
//  Call
//    isRedraw  : YES : 再描画要求を発行する
//                NO  : 再描画要求を発行しない
//    document_ : 編集対象の元締め(outlet)
//    zfactNum_ : 表示倍率の選択番号(instance 変数)
//
//  Return
//    None
//
-(void)layerResize:(BOOL)isRedraw
{
    NSRect r;
    const int zfact = ZOOM_FACTOR[self->zfactNum_];
    const int gap = [self calcFrameGap:zfact];

    // view の領域を更新
    r = [[self->document_ picture] bitmapRect];
    r.size.width = ((r.size.width * zfact) / 1000);
    r.size.height = ((r.size.height * zfact) / 1000);
    r.size.width += (gap << 1);
    r.size.height += (gap << 1);
    [self setFrame:r];

    // 再描画要求を発行
    if (isRedraw) {
        [self setNeedsDisplay:YES];
    }

    return;
}


//
// 中心表示
//
//  Call
//    None
//
//  Return
//    None
//
-(void)centering
{
    NSRect fr = [self frame];
    NSRect vr = [self visibleRect];

    vr.origin.x = ((fr.size.width - vr.size.width) / 2);
    vr.origin.y = ((fr.size.height - vr.size.height) / 2);
    if (!([self scrollRectToVisible:vr])) {
        [self setNeedsDisplay:YES];
    }

    return;
}


//
// 再描画指定
//  実寸の座標系で指示
//
//  Call
//    r : 再描画領域
//
//  Return
//    None
//
-(void)setNeedsDisplayInOriginalRect:(PoCoRect *)r
{
    // 表示矩形枠に置き換える
    [self setNeedsDisplayInRect:[self toDispRect:r]];

    return;
}


//
// 描画編集切り替え通知
//  切り替えた機能番号は PoCoEditInfo に記憶している
//
//  Call
//    document_         : 編集対象の元締め(outlet)
//    editInfo_         : 編集情報(instance 変数)
//    prevContinuation_ : 以前の連続/不連続(instance 変数)
//    prevDrawMode_     : 以前の描画機能(instance 変数)
//    prevPenStyle_     : 以前のペン先(instance 変数)
//
//  Return
//    drawTool_         : 編集機能の実体(instance 変数)
//    prevContinuation_ : 以前の連続/不連続(instance 変数)
//    prevDrawMode_     : 以前の描画機能(instance 変数)
//    prevPenStyle_     : 以前のペン先(instance 変数)
//
-(void)didChangeDrawTool
{
    DPRINT((@"[PoCoView didChangeDrawTool]\n"));

    if (([self->editInfo_ drawModeType] != self->prevDrawMode_) ||
        ([self->editInfo_ penStyleType] != self->prevPenStyle_) ||
        ([self->editInfo_ continuationType] != self->prevContinuation_)) {
        // 以前の実体を破棄
        [self->drawTool_ release];
        self->drawTool_ = nil;

        // 編集機能の実体を生成
        self->drawTool_ = [PoCoDrawFactory create:self->document_
                                         withDraw:[self->editInfo_ drawModeType]
                                          withPen:[self->editInfo_ penStyleType]];
    }
    self->prevContinuation_ = [self->editInfo_ continuationType];
    self->prevDrawMode_ = [self->editInfo_ drawModeType];
    self->prevPenStyle_ = [self->editInfo_ penStyleType];

    return;
}


//
// 表示ウィンドウダブルクリック通知
//
//  Call
//    dp        : 表示ウィンドウ内での実寸の最終 PD 位置
//    zfactNum_ : 表示倍率の選択番号(instance 変数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(void)doubleClickedOnSubView:(PoCoPoint *)dp
{
    NSPoint p1;
    NSPoint p2;
    NSRect vr;
    PoCoPoint *lp;
    PoCoRect *dr;
    const int zfact = ZOOM_FACTOR[self->zfactNum_];
    const int gap = [self calcFrameGap:zfact];

    // 同期が有効な場合、表示位置を移動する
    if ((dp != nil) &&
        ([self->editInfo_ syncSubView])) {
        lp = [self->editInfo_ lastPos];
        vr = [self visibleRect];
        dr = [self calcSrcRect:vr
                         zfact:zfact];

        // 表示位置を算出
        p1.x = (float)(gap + (([dp x] * zfact) / 1000));
        p1.y = (float)(gap + (([dp y] * zfact) / 1000));

        // スクロール位置を算出
        p2 = vr.origin;
        if ((p1.x < vr.origin.x) ||
            (p1.x > (vr.origin.x + vr.size.width))) {
            p2.x = (p1.x - (float)(((([lp x] - [dr left]) * zfact) / 1000)));
        }
        if ((p1.y < vr.origin.y) ||
            (p1.y > (vr.origin.y + vr.size.height))) {
            p2.y = (p1.y - (float)(((([lp y] - [dr top]) * zfact) / 1000)));
        }

        // スクロールを実行
        if ((p2.x != vr.origin.x) || (p2.y != vr.origin.y)) {
            [self scrollPoint:p2];
        }

        // 最終 PD 位置とする
        [self->editInfo_ setLastPos:dp];
    }

    return;
}


//
// 描画
//
//  Call
//    rect      : 描画領域(api 引数)
//    zfactNum_ : 表示倍率の選択番号(instance 変数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(void)drawRect:(NSRect)rect
{
    long l;
    NSInteger cnt;
    const NSRect *r;
    PoCoRect *tr;

//    DPRINT((@"[PoCoView rect:{%f, %f, %f, %f}]\n", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height));

    // liveResize を抑制
    if ((!([self->editInfo_ enableLiveResize])) && ([self inLiveResize])) {
        return;
    }

    // 表示範囲を通達
    tr = [self calcSrcRect:[self visibleRect]
                     zfact:ZOOM_FACTOR[self->zfactNum_]];
    [self->editInfo_ setPictureView:tr];
    [tr release];

    // 表示実行
    [self getRectsBeingDrawn:&(r)
                       count:&(cnt)];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
    for (l = 0; l < cnt; (l)++) {
        [self execDraw:r[l] 
                 zfact:ZOOM_FACTOR[self->zfactNum_]];
    }

    return;
}


//
// 座標系を反転
//
//  Call
//    None
//
//  Return
//    function : YES
//
-(BOOL)isFlipped
{
    return YES;
}


//
// メニューを更新
//
//  Call
//    menu      : menu(api 変数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    function : 可否
//
-(BOOL)validateMenuItem:(NSMenuItem *)menu
{
    BOOL result;
    PoCoColor *col = [[[self->document_ picture] palette] palette:[[self->editInfo_ selColor] num]];

    result = YES;

    if (([menu action] == @selector(copy:)) ||
        ([menu action] == @selector(delete:)) ||
        ([menu action] == @selector(flipHorizontal:)) ||
        ([menu action] == @selector(flipVertical:)) ||
        ([menu action] == @selector(autoGradation:)) ||
        ([menu action] == @selector(colorReplace:)) ||
        ([menu action] == @selector(selectClear:)) ||
        ([menu action] == @selector(clipImage:))) {
        result = (([[self->editInfo_ selRect] empty]) ? NO : YES);
    } else if ([menu action] == @selector(texture:)) {
        if ([[self->editInfo_ selRect] empty]) {
            // 選択範囲が無い
            result = NO;
        } else if ([[self->document_ selLayer] sel] < 1) {
            // 下のレイヤーが無い(上層レイヤーを選択していない)
            result = NO;
        }
    } else if (([menu action] == @selector(colorElementAll:)) ||
               ([menu action] == @selector(colorElementRed:)) ||
               ([menu action] == @selector(colorElementGreen:)) ||
               ([menu action] == @selector(colorElementBlue:))) {
        if ([self->editInfo_ lockPalette]) {
            // パレット固定
            result = NO;
        } else if ([self->editInfo_ colorMode] != PoCoColorMode_RGB) {
            // RGB 演算ではない
            result = NO;
        }
    } else if ([menu action] == @selector(colorAttributeMask:)) {
        [menu setState:(([col isMask]) ? NSOnState : NSOffState)];
    } else if ([menu action] == @selector(colorAttribueDropper:)) {
        [menu setState:(([col noDropper]) ? NSOnState : NSOffState)];
    } else if ([menu action] == @selector(colorAttribueTransparent:)) {
        [menu setState:(([col isTrans]) ? NSOnState : NSOffState)];
    } else if ([menu action] == @selector(useUnderLayer:)) {
        [menu setState:(([self->editInfo_ useUnderPattern]) ? NSOnState : NSOffState)];
    }

    return result;
}


//
// 画像内領域からウィンドウ内領域へ変換
//
//  Call
//    r         : 画像内座標
//    zfactNum_ : 表示倍率の選択番号(instance 変数)
//
//  Return
//    function : 領域
//
-(NSRect)toDispRect:(PoCoRect *)r
{
    NSRect nr;
    const int zfact = ZOOM_FACTOR[self->zfactNum_];
    const int gap = [self calcFrameGap:zfact];

    if (zfact == 1000) {
        // 等倍
        nr.origin.x = (float)([r left] + gap);
        nr.origin.y = (float)([r top] + gap);
        nr.size.width = (float)([r width]);
        nr.size.height = (float)([r height]);
    } else {
        // 拡大/縮小(端数が出ないので共通)
        nr.origin.x = (float)((([r left] * zfact) / 1000) + gap);
        nr.origin.y = (float)((([r top] * zfact) / 1000) + gap);
        nr.size.width = (float)(([r width] * zfact) / 1000);
        nr.size.height = (float)(([r height] * zfact) / 1000);
    }

    return nr;
}


//
// 表示倍率に応じたハンドルの拡張幅取得
//  縮小表示の場合にハンドルを大きくするための値を取得する
//
//  Call
//    zfactNum_ : 表示倍率の選択番号(instance 変数)
//
//  Return
//    function : 値
//
-(int)handleRectGap;
{
    const int zfact = ZOOM_FACTOR[self->zfactNum_];

    return ((zfact < 1000) ? (2000 / zfact) : 0);
}


//
// Pointer 形状範囲指定
//
//  Call
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(void)resetCursorRects
{
    // 編集機能ごとに更新
    [self->drawTool_ updateCursorRect];

    return;
}


//
// ガイドライン表示
//
//  Call
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(void)drawGuideLine
{
    [self->drawTool_ drawGuideLine];

    return;
}


//
// 編集状態解除
//
//  Call
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(void)cancelEdit
{
    [self->drawTool_ cancelEdit];

    return;
}


//
// スペースキーイベント
//
//  Call
//    isPress    : key down か
//                 YES : keyDown によるもの
//                 NO  : keyUp によるもの
//    isDrawing_ : 描画中(instance 変数)
//
//  Return
//    isAltMode_   : ALT 同時押し状態(instance 変数)
//    isSpaceMode_ : SPACE 同時押し状態(instance 変数)
//
-(void)spaceKeyEvent:(BOOL)isPress
{
    if (!(self->isDrawing_)) {
        self->isAltMode_ = isPress;
        self->isSpaceMode_ = isPress;
    }

    return;
}


//
// undo/redo 実行前後処理(observer)
//  WillUndo、DidUndo、WillRedo、DidRedo の各通知を受け取る
//  選択枠とかは反転描画なので、
//    取り消し実行前に(今の選択枠に)反転をかけて消してしまい、
//    取り消しを実行して状態を復元し
//    状態復元後にもう一度、今の選択枠を反転再描画
//  という段取りを踏むので、すべての通知で同じ処理となる。
//
//  Call
//    note      : 通知内容
//    document_ : 編集対象の元締め(outlet)
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(void)undoManagementing:(NSNotification *)note
{
    DPRINT((@"[PoCoView undoManagementing]\n"));

    if ([[NSDocumentController sharedDocumentController] currentDocument] == self->document_) {
        // ガイドラインを強制再描画(反転描画)
        [self->drawTool_ drawGuideLine];
        if (([[note name] compare:NSUndoManagerWillUndoChangeNotification] == NSOrderedSame) ||
            ([[note name] compare:NSUndoManagerWillRedoChangeNotification] == NSOrderedSame)) {
            [self->drawTool_ recreatePasteImage];
        }
    }

    return;
}


// ---------------------------------- instance - public - PasteBoard、menu 操作
//
// ペーストボードへ複写
//
//  Call
//    sender    : メニュー項目へのインスタンス(api 変数)
//    document_ : 編集対象の元締め(outlet)
//    editInfo_ : 編集情報(instance 変数)
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(IBAction)copy:(id)sender
{
    // 選択枠消去
    [self->drawTool_ drawGuideLine];

    // ペーストボードへ張り付け
    [self->document_ writePngToPasteboard:[NSPasteboard generalPasteboard]
                                 withRect:[self->editInfo_ selRect]
                                  atIndex:[[self->document_ selLayer] sel]];

    // 選択枠表示
    [self->drawTool_ drawGuideLine];

    return;
}


//
// ペーストボードから複写
//
//  Call
//    sender    : メニュー項目へのインスタンス(api 変数)
//    document_ : 編集対象の元締め(outlet)
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(IBAction)paste:(id)sender
{
    BOOL result;
    PoCoLayerBase *lyr;
    PoCoPalette *plt;
    PoCoImportPalettePanel *panel;

    lyr = nil;
    plt = nil;

    // 描画禁止レイヤーなら何もしない
    if ([[[self->document_ picture] layer:[[self->document_ selLayer] sel]] drawLock]) {
        NSBeep();
        goto EXIT;
    }

    // パレットを複製
    plt = [[[self->document_ picture] palette] copy];

    // 実行
    [[self->document_ picture] pushPaletteTable];
    result = [MyDocument readPngFromPasteboard:[NSPasteboard generalPasteboard]
                                   resultLayer:&(lyr)
                                 resultPalette:plt];
    [[self->document_ picture] popPaletteTable];
    if ((result == YES) && (lyr != nil)) {
        // 複写パレット選択
        if (!([[[self->document_ picture] palette] isEqualPalette:plt
                                                       checkAttr:NO])) {
            panel = [[PoCoImportPalettePanel alloc] initWithDoc:self->document_
                                              withTargetPalette:plt];
            if (panel != nil) {
                [[panel window] center];
                [panel startWindow];
                [panel release];
            }
        }

        // 選択枠消去
        [self->drawTool_ drawGuideLine];

        // DrawSelection に切り替え
        [[(PoCoAppController *)([NSApp delegate]) toolbarWindow] setDrawModeAtType:PoCoDrawModeType_Selection];

        // 範囲選択の drawTool_ に引き渡し
        [self->drawTool_ pasteBitmap:lyr];
    } else {
        NSBeep();
    }

    // 取得した内容を解放
    [plt release];
    [lyr release];

EXIT:
    return;
}


//
// ドラッグ元操作宣言
//
//  Call
//    isLocal : flag
//
//  Return
//    function : 種別
//
-(NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
    return NSDragOperationCopy;
}


//
// 削除
//
//  Call
//    sender    : メニュー項目へのインスタンス(api 変数)
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(IBAction)delete:(id)sender
{
    // 実行
    [self->drawTool_ delete];

    return;
}


//
// 水平反転
//
//  Call
//    sender    : メニュー項目へのインスタンス(api 変数)
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(IBAction)flipHorizontal:(id)sender
{
    // 実行
    [self->drawTool_ flipImage:YES];

    return;
}


//
// 垂直反転
//
//  Call
//    sender    : メニュー項目へのインスタンス(api 変数)
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(IBAction)flipVertical:(id)sender
{
    [self->drawTool_ flipImage:NO];

    return;
}


//
// 自動グラデーション
//
//  Call
//    sender    : メニュー項目へのインスタンス(api 変数)
//    document_ : 編集対象の元締め(outlet)
//    editInfo_ : 編集情報(instance 変数)
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(IBAction)autoGradation:(id)sender
{
    PoCoAutoGradationPanel *panel;

    panel = [[PoCoAutoGradationPanel alloc] initWithDoc:self->document_
                                           withEditInfo:self->editInfo_
                                              withImage:[self->drawTool_ originalImage]
                                              withShape:[self->drawTool_ originalShape]];
    if (panel != nil) {
        [[panel window] center];
        [panel startWindow];
        if ([panel isOk]) {
            [self->drawTool_ autoGrad:[panel penSize]
                           isAdjacent:[panel isAdjacent]
                               matrix:[panel matrix]
                         withSizePair:[panel sizePair]];
        }
        [panel release];
    }

    return;
}


//
// 色置換
//
//  Call
//    sender    : メニュー項目へのインスタンス(api 変数)
//    document_ : 編集対象の元締め(outlet)
//    editInfo_ : 編集情報(instance 変数)
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(IBAction)colorReplace:(id)sender
{
    PoCoColorReplacePanel *panel;

    panel = [[PoCoColorReplacePanel alloc] initWithDoc:self->document_
                                          withEditInfo:self->editInfo_];
    if (panel != nil) {
        [[panel window] center];
        [panel startWindow];
        if ([panel isOk]) {
            [self->drawTool_ colorReplace:[panel matrix]];
        }
        [panel release];
    }

    return;
}


//
// テクスチャ
//
//  Call
//    sender    : メニュー項目へのインスタンス(api 変数)
//    document_ : 編集対象の元締め(outlet)
//    editInfo_ : 編集情報(instance 変数)
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(IBAction)texture:(id)sender
{
    PoCoTexturePanel *panel;

    panel = [[PoCoTexturePanel alloc] initWithDoc:self->document_
                                     withEditInfo:self->editInfo_];
    if (panel != nil) {
        [[panel window] center];
        [panel startWindow];
        if ([panel isOk]) {
            [self->drawTool_ texture:[panel base]
                        withGradient:[panel gradient]];
        }
        [panel release];
    }

    return;
}


//   
// 全選択
//
//  Call
//    sender    : メニュー項目へのインスタンス(api 変数)
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(IBAction)selectAll:(id)sender
{
    // DrawSelection に切り替え
    [[(PoCoAppController *)([NSApp delegate]) toolbarWindow] setDrawModeAtType:PoCoDrawModeType_Selection];
    [self->drawTool_ selectAll];

    return;
}


//
// 選択解除
//
//  Call
//    sender    : メニュー項目へのインスタンス(api 変数)
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(IBAction)selectClear:(id)sender
{
    [self->drawTool_ selectClear];

    return;
}


//
// 表示拡大
//
//  Call
//    sender    : メニュー項目へのインスタンス(api 変数)
//    slider_   : 倍率の slider(outlet)
//    zfactNum_ : 表示倍率の選択番号(instance 変数)
//
//  Return
//    None
//
-(IBAction)zoomIn:(id)sender
{
    int num;

    num = (self->zfactNum_ + 1);

    // 表示に反映
    if ((num >= (int)([self->slider_ minValue])) &&
        (num <= (int)([self->slider_ maxValue]))) {
        [self->slider_ setFloatValue:(float)(num)];
        [self changeZoom:num];
    }

    return;
}


//
// 表示縮小
//
//  Call
//    sender    : メニュー項目へのインスタンス(api 変数)
//    slider_   : 倍率の slider(outlet)
//    zfactNum_ : 表示倍率の選択番号(instance 変数)
//
//  Return
//    None
//
-(IBAction)zoomOut:(id)sender
{
    int num;

    num = (self->zfactNum_ - 1);

    // 表示に反映
    if ((num >= (int)([self->slider_ minValue])) &&
        (num <= (int)([self->slider_ maxValue]))) {
        [self->slider_ setFloatValue:(float)(num)];
        [self changeZoom:num];
    }

    return;
}


//
// 等倍
//
//  Call
//    sender    : メニュー項目へのインスタンス(api 変数)
//    slider_   : 倍率の slider(outlet)
//    zfactNum_ : 表示倍率の選択番号(instance 変数)
//
//  Return
//    None
//
-(IBAction)actualSize:(id)sender
{
    int num;

    num = ((int)([self->slider_ maxValue] - [self->slider_ minValue]) / 2);

    [self->slider_ setFloatValue:(float)(num)];
    [self changeZoom:num];

    return;
}


//
// ドキュメント設定
//
//  Call
//    sender    : 操作対象(api 引数)
//    document_ : 編集対象の元締め(outlet)
//
//  Return
//    None
//
-(IBAction)documentSetting:(id)sender
{
    PoCoDocumentSettingPanel *panel;

    panel = [[PoCoDocumentSettingPanel alloc] initWithDoc:self->document_];
    if (panel != nil) {
        [[panel window] center];
        [panel startWindow];
        [panel release];
    }

    return;
}


//
// サイズ変更
//
//  Call
//    sender    : 操作対象(api 引数)
//    document_ : 編集対象の元締め(outlet)
//
//  Return
//    None
//
-(IBAction)canvasResize:(id)sender
{
    PoCoCanvasResizePanel *panel;

    panel = [[PoCoCanvasResizePanel alloc] initWithDoc:self->document_];
    if (panel != nil) {
        [[panel window] center];
        [panel startWindow];
        [panel release];
    }

    return;
}


//
// 切り抜き
//
//  Call
//    sender    : 操作対象(api 引数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(IBAction)clipImage:(id)sender
{
    PoCoRect *r;

    r = nil;

    // 選択範囲が空なら何もしない
    if ([[self->editInfo_ selRect] empty]) {
        goto EXIT;
    }

    // 選択範囲の矩形枠を取得
    r = [[PoCoRect alloc] initPoCoRect:[self->editInfo_ selRect]];

    // 編集状態解除
    [self->document_ cancelEdit];

    // 実行
    [[(PoCoAppController *)([NSApp delegate]) factory] createImageClipper:YES
                                                                     rect:r];

EXIT:
    [r release];
    return;
}


// --------------------------------------- instance - public - パレット操作関連
//
// 前の色へ
//
//  Call
//    sender    : 送信元(api 引数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(IBAction)nextColor:(id)sender
{
    PoCoSelColor *col;
    int num;

    col = [self->editInfo_ selColor];
    if (([col isPattern]) || ([col isUnder])) {
        // カラーパターン、下層レイヤー時は切り替えない
        ;
    } else {
        num = (((([col num] + 1) >= COLOR_MAX) ? -1 : [col num]) + 1);
        [self->editInfo_ setSelColor:num];

        // 切り替えを通知
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoChangeColor
                          object:nil];
    }

    return;
}


//
// 次の色へ
//
//  Call
//    sender    : 送信元(api 引数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(IBAction)prevColor:(id)sender
{
    PoCoSelColor *col;
    int num;

    col = [self->editInfo_ selColor];
    if (([col isPattern]) || ([col isUnder])) {
        // カラーパターン、下層レイヤー時は切り替えない
        ;
    } else {
        num = ((([col num] <= 0) ? COLOR_MAX : [col num]) - 1);
        [self->editInfo_ setSelColor:num];

        // 切り替えを通知
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoChangeColor
                          object:nil];
    }

    return;
}


//
// 下層レイヤーを使用
//
//  Call
//    sender    : 送信元(api 引数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(IBAction)useUnderLayer:(id)sender
{
    // 設定を反転
    [self->editInfo_ toggleUseUnderPattern];

    // 切り替えを通知(自身も受け取る)
    [[NSNotificationCenter defaultCenter] postNotificationName:PoCoChangeColor
                                                        object:nil];


    return;
}


//
// 色要素(すべて)
//
//  Call
//    sender    : 送信元(api 引数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(IBAction)colorElementAll:(id)sender
{
    if ([self->editInfo_ lockPalette]) {
        // パレット固定
        ;
    } else if ([self->editInfo_ colorMode] != PoCoColorMode_RGB) {
        // RGB 演算ではない
        ;
    } else if ([sender tag] < 0) {
        [[(PoCoAppController *)([NSApp delegate]) factory]
            createPaletteDecrementer:YES
                                 num:[[self->editInfo_ selColor] num]
                                 red:YES
                               green:YES
                                blue:YES
                                step:(unsigned int)(-([sender tag]))];
    } else {
        [[(PoCoAppController *)([NSApp delegate]) factory]
            createPaletteIncrementer:YES
                                 num:[[self->editInfo_ selColor] num]
                                 red:YES
                               green:YES
                                blue:YES
                                step:(unsigned int)([sender tag])];
    }

    return;
}


//
// 色要素(赤)
//
//  Call
//    sender    : 送信元(api 引数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(IBAction)colorElementRed:(id)sender
{
    if ([self->editInfo_ lockPalette]) {
        // パレット固定
        ;
    } else if ([self->editInfo_ colorMode] != PoCoColorMode_RGB) {
        // RGB 演算ではない
        ;
    } else if ([sender tag] < 0) {
        [[(PoCoAppController *)([NSApp delegate]) factory]
            createPaletteDecrementer:YES
                                 num:[[self->editInfo_ selColor] num]
                                 red:YES
                               green:NO
                                blue:NO
                                step:(unsigned int)(-([sender tag]))];
    } else {
        [[(PoCoAppController *)([NSApp delegate]) factory]
            createPaletteIncrementer:YES
                                 num:[[self->editInfo_ selColor] num]
                                 red:YES
                               green:NO
                                blue:NO
                                step:(unsigned int)([sender tag])];
    }

    return;
}


//
// 色要素(緑)
//
//  Call
//    sender    : 送信元(api 引数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(IBAction)colorElementGreen:(id)sender
{
    if ([self->editInfo_ lockPalette]) {
        // パレット固定
        ;
    } else if ([self->editInfo_ colorMode] != PoCoColorMode_RGB) {
        // RGB 演算ではない
        ;
    } else if ([sender tag] < 0) {
        [[(PoCoAppController *)([NSApp delegate]) factory]
            createPaletteDecrementer:YES
                                 num:[[self->editInfo_ selColor] num]
                                 red:NO
                               green:YES
                                blue:NO
                                step:(unsigned int)(-([sender tag]))];
    } else {
        [[(PoCoAppController *)([NSApp delegate]) factory]
            createPaletteIncrementer:YES
                                 num:[[self->editInfo_ selColor] num]
                                 red:NO
                               green:YES
                                blue:NO
                                step:(unsigned int)([sender tag])];
    }

    return;
}


//
// 色要素(青)
//
//  Call
//    sender    : 送信元(api 引数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(IBAction)colorElementBlue:(id)sender
{
    if ([self->editInfo_ lockPalette]) {
        // パレット固定
        ;
    } else if ([self->editInfo_ colorMode] != PoCoColorMode_RGB) {
        // RGB 演算ではない
        ;
    } else if ([sender tag] < 0) {
        [[(PoCoAppController *)([NSApp delegate]) factory]
            createPaletteDecrementer:YES
                                 num:[[self->editInfo_ selColor] num]
                                 red:NO
                               green:NO
                                blue:YES
                                step:(unsigned int)(-([sender tag]))];
    } else {
        [[(PoCoAppController *)([NSApp delegate]) factory]
            createPaletteIncrementer:YES
                                 num:[[self->editInfo_ selColor] num]
                                 red:NO
                               green:NO
                                blue:YES
                                step:(unsigned int)([sender tag])];
    }

    return;
}


//
// 上塗り禁止
//
//  Call
//    sender    : 送信元(api 引数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(IBAction)colorAttributeMask:(id)sender
{
    PoCoSelColor *scol = [self->editInfo_ selColor];
    PoCoColor *col = [[[self->document_ picture] palette] palette:[scol num]];

    [[(PoCoAppController *)([NSApp delegate]) factory]
        createPaletteAttributeSetter:YES
                                 num:[scol num]
                             setType:(([col isMask]) ? NO : YES)
                                mask:YES
                             dropper:NO
                               trans:NO];

    return;
}


//
// 吸い取り禁止
//
//  Call
//    sender : 送信元(api 引数)
//
//  Return
//    None
//
-(IBAction)colorAttribueDropper:(id)sender
{
    PoCoSelColor *scol = [self->editInfo_ selColor];
    PoCoColor *col = [[[self->document_ picture] palette] palette:[scol num]];

    [[(PoCoAppController *)([NSApp delegate]) factory]
        createPaletteAttributeSetter:YES
                                 num:[scol num]
                             setType:(([col noDropper]) ? NO : YES)
                                mask:NO
                             dropper:YES
                               trans:NO];

    return;
}


//
// 透明
//
//  Call
//    sender : 送信元(api 引数)
//
//  Return
//    None
//
-(IBAction)colorAttribueTransparent:(id)sender
{
    PoCoSelColor *scol = [self->editInfo_ selColor];
    PoCoColor *col = [[[self->document_ picture] palette] palette:[scol num]];

    [[(PoCoAppController *)([NSApp delegate]) factory]
        createPaletteAttributeSetter:YES
                                 num:[scol num]
                             setType:(([col isTrans]) ? NO : YES)
                                mask:NO
                             dropper:NO
                               trans:YES];

    return;
}


// ----------------------------------------- instance - public - イベント処理系
//
// ボタンダウンイベントの受け入れ可否
//
//  Call
//    evt : 発生イベント(api 変数)
// 
//  Return
//    function : 可否
//
-(BOOL)acceptsFirstMouse:(NSEvent *)evt
{
    // 種別判定は無視
    ;

    return YES;
}


#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)
//
// ペン先取得
//
//  Call
//    evt       : 発生イベント(api 変数)
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    editInfo_ : 編集情報(instance 変数)
//
-(void)tabletProximity:(NSEvent *)evt
{
//    DPRINT((@"\nenter : %s\npointingDeviceType : %d\nPointingDeviceID : %d\n", [evt isEnteringProximity] ? "YES" : "NO", [evt pointingDeviceType], [evt pointingDeviceID]));

    if ([self->editInfo_ enableEraser]) {
        [self->editInfo_ setEraserType:([evt pointingDeviceType] == NSEraserPointingDevice)];
    }

    return;
}
#endif  // MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3


//
// ボタンダウン処理
//
//  Call
//    evt          : 発生イベント(api 変数)
//    isDrawing_   : 描画中(instance 変数)
//    editInfo_    : 編集情報(instance 変数)
//    drawTool_    : 編集機能の実体(instance 変数)
//    isSpaceMode_ : SPACE 同時押し状態(instance 変数)
//
//  Return
//    isDrawing_ : 描画中(instance 変数)
//    isAltMode_ : ALT 同時押し状態(instance 変数)
//
-(void)mouseDown:(NSEvent *)evt
{
    NSPoint p;

    // PD 位置取得
    p = [PoCoPoint corrNSPoint:[self convertPoint:[evt locationInWindow]
                                         fromView:nil]];

    // PD 位置の通達
    [self setInfoPDPos:p];

    // Alt 同時押し判定
    if (self->isDrawing_) {
        // すでに描画中
        ;
    } else if (!(self->isSpaceMode_)) {
        self->isAltMode_ = ((([evt modifierFlags] & NSCommandKeyMask) == 0) && (([evt modifierFlags] & NSAlternateKeyMask) != 0));
    }

    // 操作実行
    if (self->isAltMode_) {
        // [Alt] 同時押し
        ;
    } else {
        // 実行
        [self->drawTool_ mouseDown:evt];
        self->isDrawing_ = YES;
    }

    // 編集の実行を通知
    if ([self->editInfo_ syncSubView]) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoExecDrawing
                          object:nil];
    }

    return;
}


//
// ドラッグ処理
//
//  Call
//    evt        : 発生イベント(api 変数)
//    isAltMode_ : ALT 同時押し状態(instance 変数)
//    drawTool_  : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(void)mouseDragged:(NSEvent *)evt
{
    NSPoint p;

    // PD 位置取得
    p = [PoCoPoint corrNSPoint:[self convertPoint:[evt locationInWindow]
                                         fromView:nil]];

    // PD 位置の通達
    [self setInfoPDPos:p];

    // 編集機能ごとの分類
    if (self->isAltMode_) {
        // [Alt] 同時押し
        [self->drawTool_ dragMove:evt];
    } else {
        // auto-scroll を実行
        if ([self->drawTool_ canAutoScroll]) {
            [self autoscroll:evt];
        }

        // 実行
        [self->drawTool_ mouseDrag:evt];
    }

    // 編集の実行を通知
    if ([self->editInfo_ syncSubView]) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoExecDrawing
                          object:nil];
    }

    return;
}


//
// ボタンリリース処理
//
//  Call
//    evt        : 発生イベント(api 変数)
//    isAltMode_ : ALT 同時押し状態(instance 変数)
//    editInfo_  : 編集情報(instance 変数)
//    drawTool_  : 編集機能の実体(instance 変数)
//
//  Return
//    isDrawing_ : 描画中(instance 変数)
//    editInfo_  : 編集情報(instance 変数)
//
-(void)mouseUp:(NSEvent *)evt
{
    // 編集機能ごとの分類
    if (self->isAltMode_) {
        // [Alt] 同時押し
        [self->editInfo_ setLastPos:[self->editInfo_ pdPos]];
    } else {
        // 実行
        [self->drawTool_ mouseUp:evt];
        self->isDrawing_ = NO;
    }

    // 編集の実行を通知
    if ([self->editInfo_ syncSubView]) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoExecDrawing
                          object:nil];
    }

    return;
}


//
// 右ボタンダウン処理
//  非編集中なら色吸い取り
//  編集中なら編集解除
//
//  Call
//    evt       : 発生イベント(api 変数)
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(void)rightMouseDown:(NSEvent *)evt
{
    NSPoint p;

    // PD 位置取得
    p = [PoCoPoint corrNSPoint:[self convertPoint:[evt locationInWindow]
                                         fromView:nil]];
    if ([self mouse:p
             inRect:[self visibleRect]]) {
        // PD 位置の通達
        [self setInfoPDPos:p];

        // 実行
        [self->drawTool_ rightMouseDown:evt];
    }

    return;
}


//
// 右ボタンドラッグ処理
//
//  Call
//    evt       : 発生イベント(api 変数)
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(void)rightMouseDragged:(NSEvent *)evt
{
    NSPoint p;

    // PD 位置取得
    p = [PoCoPoint corrNSPoint:[self convertPoint:[evt locationInWindow]
                                         fromView:nil]];

    // PD 位置の通達
    [self setInfoPDPos:p];

    // 実行
    [self->drawTool_ rightMouseDrag:evt];

    return;
}


//
// 右ボタンリリース処理
//
//  Call
//    evt       : 発生イベント(api 変数)
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(void)rightMouseUp:(NSEvent *)evt
{
    NSPoint p;

    // PD 位置取得
    p = [PoCoPoint corrNSPoint:[self convertPoint:[evt locationInWindow]
                                         fromView:nil]];

    // PD 位置の通達
    [self setInfoPDPos:p];

    // 実行
    [self->drawTool_ rightMouseUp:evt];

    return;
}


//
// キーダウン処理
//
//  Call
//    evt        : 発生イベント(api 変数)
//    isDrawing_ : 描画中(instance 変数)
//    drawTool_  : 編集機能の実体(instance 変数)
//
//  Return
//    isAltMode_   : ALT 同時押し状態(instance 変数)
//    isSpaceMode_ : SPACE 同時押し状態(instance 変数)
//
-(void)keyDown:(NSEvent *)evt
{
    if ((!(self->isDrawing_)) && ([evt keyCode] == kVK_Space)) {
        // スペースは常にずりずりにする
        if ([evt isARepeat]) {
            // key repeat 中は無視
            ;
        } else {
            self->isAltMode_ = YES;
            self->isSpaceMode_ = YES;
        }
    } else {
        // 実行
        [self->drawTool_ keyDown:evt];
    }

    return;
}


//
// キーリリース処理
//
//  Call
//    evt       : 発生イベント(api 変数)
//    drawTool_ : 編集機能の実体(instance 変数)
//
//  Return
//    isDrawing_   : 描画中(instance 変数)
//    isAltMode_   : ALT 同時押し状態(instance 変数)
//    isSpaceMode_ : SPACE 同時押し状態(instance 変数)
//
-(void)keyUp:(NSEvent *)evt
{
    if ((!(self->isDrawing_)) && ([evt keyCode] == kVK_Space)) {
        // スペースは常にずりずりにする
        self->isAltMode_ = NO;
        self->isSpaceMode_ = NO;
    } else {
        // 実行
        [self->drawTool_ keyUp:evt];
    }

    return;
}


//
// PD 移動
//
//  Call
//    evt        : 発生イベント(api 変数)
//    isAltMode_ : ALT 同時押し状態(instance 変数)
//    drawTool_  : 編集機能の実体(instance 変数)
//
//  Return
//    None
//
-(void)mouseMoved:(NSEvent *)evt
{
    NSPoint p;

    // PD 位置取得
    p = [PoCoPoint corrNSPoint:[self convertPoint:[evt locationInWindow]
                                         fromView:nil]];
    if ([self mouse:p
             inRect:[self visibleRect]]) {
        // PD 位置の通達
        [self setInfoPDPos:p];

        // 編集機能ごとの分類
        if (self->isAltMode_) {
            // [Alt] 同時押し
            ;
        } else {
            // 実行
            [self->drawTool_ mouseMove:evt];
        }
    }

    return;
}


//
// wheel 回転
//
//  Call
//    evt       : 発生イベント(api 変数)
//    slider_   : 倍率の slider(outlet)
//    zfactNum_ : 表示倍率の選択番号(instance 変数)
//
//  Return
//    None
//
-(void)scrollWheel:(NSEvent *)evt
{
    int num;

    if ([evt modifierFlags] & NSControlKeyMask) {
        // 表示倍率変更
        if (((int)([evt deltaX]) == 0) &&
            ((int)([evt deltaY]) == 0) &&
            ((int)([evt deltaZ]) == 0)) {
            // 変量無しは何もしない(Wacom Tablet Driver の bug)
            ;
        } else {
            if (((int)([evt deltaX]) < 0) || ((int)([evt deltaY]) < 0)) {
                num = (self->zfactNum_ - 1);
            } else {
                num = (self->zfactNum_ + 1);
            }

            // 表示に反映
            if ((num >= (int)([self->slider_ minValue])) &&
                (num <= (int)([self->slider_ maxValue]))) {
                [self->slider_ setFloatValue:(float)(num)];
                [self changeZoom:num];
            }
        }
    } else {
        // 通常の wheel 回転
        [super scrollWheel:evt];
    }

    return;
}


#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6)
//
// touch 開始
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    None
//
-(void)touchesBeganWithEvent:(NSEvent *)evt
{
    // 何もしない
    ;

    // super class へ回送
    [super touchesBeganWithEvent:evt];

    return;
}


//
// touch 移動
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    None
//
-(void)touchesMovedWithEvent:(NSEvent *)evt
{
    // pointer 形状更新
    [[self window] invalidateCursorRectsForView:self];

    // super class へ回送
    [super touchesMovedWithEvent:evt];

    return;
}


//
// touch 終了
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    None
//
-(void)touchesEndedWithEvent:(NSEvent *)evt
{
    // pointer 形状更新
    [[self window] invalidateCursorRectsForView:self];

    // super class へ回送
    [super touchesEndedWithEvent:evt];

    return;
}


//
// touch 拒否
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    None
//
-(void)touchesCancelledWithEvent:(NSEvent *)evt
{
    // 何もしない(拒否しない)
    ;

    // super class へ回送
    [super touchesCancelledWithEvent:evt];

    return;
}
#endif  // MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_6


// -------------------------------------------- instance - public - IBAction 系
//
// 倍率の slider の管理
//
//  Call
//    sender : 操作している slider(api 引数)
//
//  Return
//    None
//
-(IBAction)zoomFactor:(id)sender
{
    [self changeZoom:(int)(floor([sender floatValue]))];

    return;
}


// ---------------------------------------- instance - public - liveResize 制御
//
// live resize 開始
//
//  Call
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(void)viewWillStartLiveResize
{
    if ([self->editInfo_ enableLiveResize]) {
        [super viewWillStartLiveResize];
    }

    return;
}


//
// live resize 終了
//
//  Call
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    None
//
-(void)viewDidEndLiveResize
{
    if (!([self->editInfo_ enableLiveResize])) {
        [self setNeedsDisplay:YES];
    }

    return;
}

@end
