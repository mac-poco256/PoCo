//
// PoCoSubView.m
// implementation of PoCoSubView class.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoSubView.h"

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"
#import "PoCoMyDocument.h"
#import "PoCoPicture.h"


// 内部変数
static const int ZOOM_FACTOR[] = {      // 表示倍率テーブル(0.1%単位)
     10,   20,   25,   50,  100,  200,  250,  300,   400,   500,   600,    700,   750,   800,   900,
    1000,
    2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 11000, 12000, 13000, 14000, 15000, 16000
};

static const NSRect EMPTY_RECT = {{0.0, 0.0}, {0.0, 0.0}}; // 空領域

// ============================================================================
@implementation PoCoSubView

// ----------------------------------------------------------------------------
// instance - private.

//
// observer を登録
//
//  Call
//    None
//
//  Return
//    None
//
-(void)registerObserver
{
    NSNotificationCenter *nc;

    nc = [NSNotificationCenter defaultCenter];
    if (nc != nil) {
        // layer resize を受信
        [nc addObserver:self            // 編集対象変更通知
               selector:@selector(changePicture:)
                   name:PoCoChangePicture
                 object:nil];
        [nc addObserver:self            // 画像サイズ変更通知
               selector:@selector(changePicture:)
                   name:PoCoCanvasResize
                 object:nil];
        [nc addObserver:self            // 切り抜き通知
               selector:@selector(changePicture:)
                   name:PoCoImageClip
                 object:nil];

        // palette 変更を受信
        [nc addObserver:self
               selector:@selector(changePaletteElm:)
                   name:PoCoChangePalette
                 object:nil];

        // レイヤー構造の変更を受信
        [nc addObserver:self
               selector:@selector(editLayer:)
                   name:PoCoEditLayer
                 object:nil];

        // パレット属性更新を受信
        [nc addObserver:self
               selector:@selector(changePaletteAttr:)
                   name:PoCoChangePaletteAttr
                 object:nil];

        // 画像編集の受信
        [nc addObserver:self
               selector:@selector(editPicture:)
                   name:PoCoEditPicture
                 object:nil];

        // 再描画の発行の受信
        [nc addObserver:self
               selector:@selector(editPicture:)
                   name:PoCoRedrawPicture
                 object:nil];

        // 編集通知の受信
        [nc addObserver:self
               selector:@selector(execDrawing:)
                   name:PoCoExecDrawing
                 object:nil];
    }

    return;
}


//
// 実寸の座標に変換
//  呼び出し元で返り値の実体に release を送ること
//
//  Call
//    p        : ウィンドウ内の位置
//    zfact    : 表示倍率
//    orgRect_ : 表示画像の実数領域(instance 変数)
//
//  Return
//    function : 位置
//
-(PoCoPoint *)calcSrcPoint:(NSPoint)p
                     zfact:(int)zfact
{
    int x;
    int y;
    PoCoRect *r;

    // 算出
    if (zfact == 1000) {
        x = (int)(p.x);
        y = (int)(p.y);
    } else {
        x = ((((int)(p.x)) * 1000) / zfact);
        y = ((((int)(p.y)) * 1000) / zfact);
    }

    // 画像範囲内に収める
    r = [[PoCoRect alloc] initNSRect:self->orgRect_];
    if (x < [r left]) {
        x = [r left];
    } else if (x >= [r right]) {
        x = ([r right] - 1);
    }
    if (y < [r top]) {
        y = [r top];
    } else if (y >= [r bottom]) {
        y = ([r bottom] - 1);
    }
    [r release];

    return [[PoCoPoint alloc] initX:x initY:y];
}


//      
// 実寸での範囲の取得
//  呼び出し元で返り値の実体に release を送ること
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

    // 要表示領域/描画領域を算出
    r = [[PoCoRect alloc] initNSRect:rect];
    if (zfact != 1000) {
        // 拡大/縮小(端数が出ないので共通)
        [r   setLeft:(((rect.origin.x) * 1000) / zfact)];
        [r    setTop:(((rect.origin.y) * 1000) / zfact)];
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
    NSRect dr;
    const int zfact = ZOOM_FACTOR[self->zfactNum_];

    if (zfact == 1000) {
        // 等倍
        dr.origin.x = (float)([r left]);
        dr.origin.y = (float)([r top]);
        dr.size.width = (float)([r width]);
        dr.size.height = (float)([r height]);
    } else {
        // 拡大/縮小(端数が出ないので共通)
        dr.origin.x = (float)((([r left] * zfact) / 1000));
        dr.origin.y = (float)((([r top] * zfact) / 1000));
        dr.size.width = (float)(([r width] * zfact) / 1000);
        dr.size.height = (float)(([r height] * zfact) / 1000);
    }

    return dr;
}


//
// 表示倍率変更
//
//  Call
//    num        : 変更予定の倍率番号
//    zfactNum_  : 表示倍率の選択番号(instance 変数)
//    lastPoint_ : 最終 PD 位置(instance 変数)
//    orgRect_   : 表示画像の実数領域(instance 変数)
//
//  Return
//    zfactNum_ : 表示倍率の選択番号(instance 変数)
//
-(void)changeZoom:(int)num
{
    int zchg;
    PoCoRect *r;
    PoCoRect *or = [[PoCoRect alloc] initNSRect:self->orgRect_];

    if (self->zfactNum_ != num) {
        // 現在の表示範囲を取得
        r = [self calcSrcRect:[self visibleRect]
                        zfact:ZOOM_FACTOR[self->zfactNum_]];
        zchg = (((ZOOM_FACTOR[num] - ZOOM_FACTOR[self->zfactNum_]) * 1000) / ZOOM_FACTOR[num]);
        [r shiftX:((([self->lastPoint_ x] - [r left]) * zchg) / 1000)];
        [r shiftY:((([self->lastPoint_ y] - [r top ]) * zchg) / 1000)];
        if ([r left] < 0) {
            [r setLeft:0];
        }
        if ([r top] < 0) {
            [r setTop:0];
        }
        if ([r right] >= [or right]) {
            [r setRight:[or right]];
        }
        if ([r bottom] >= [or bottom]) {
            [r setBottom:[or bottom]];
        }

        // 更新
        self->zfactNum_ = num;

        // view の範囲を更新
        [self updateFrame:NO];

        // 表示位置を調整して再描画要求を発行
        if (!([self scrollRectToVisible:[self toDispRect:r]])) {
            [self setNeedsDisplay:YES];
        }
        [r release];
    }
    [or release];

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
    [self scrollRectToVisible:vr];

    return;
}


#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
// ----------------------------------------------------------------------------
// class - public.

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


// ----------------------------------------------------------------------------
// instance - public.

//
// initialize
//
//  Call
//    frameRect : 矩形枠(api 引数)
//
//  Return
//    function   : 実体
//    zfactNum_  : 表示倍率の選択番号 (instance 変数)
//    orgRect_   : 表示画像の実数領域 (instance 変数)
//    lastPoint_ : 最終 PD 位置(instance 変数)
//    docCntl_   : document controller(instance 変数)
//
-(id)initWithFrame:(NSRect)frameRect
{
    DPRINT((@"[PoCoSubView initWithFrame:{%f, %f, %f, %f}]\n", frameRect.origin.x, frameRect.origin.y, frameRect.size.width, frameRect.size.height));

    // super class の初期化
    self = [super initWithFrame:frameRect];

    // 自身の初期化
    if (self != nil) {
        self->zfactNum_ = 15;
        self->lastPoint_ = nil;

        // document controller を取得
        self->docCntl_ = [NSDocumentController sharedDocumentController];
        [self->docCntl_ retain];

        // 領域の初期化
        [self setFrame:EMPTY_RECT];
        if ([NSApp mainWindow] == nil) {
            // 主ウィンドウがなければ空に
            self->orgRect_ = EMPTY_RECT;
        } else {
            self->orgRect_ = [[[self->docCntl_ currentDocument] picture] bitmapRect];
            [self updateFrame:NO];

            // 中心表示
            [self centering];
            self->lastPoint_ = [[PoCoPoint alloc] initX:(int)(self->orgRect_.size.width / 2)
                                                  initY:(int)(self->orgRect_.size.height / 2)];
        }

        // observer を登録
        [self registerObserver];
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
//    lastPoint_ : 最終 PD 位置(instance 変数)
//    docCntl_   : document controller(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoSubView dealloc]\n"));

    // 資源の解放
    [self->lastPoint_ release];
    [self->docCntl_ release];
    self->lastPoint_ = nil;
    self->docCntl_ = nil;

    // observer の登録を解除
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // super class の解放
    [super dealloc];

    return;
}


//
// awake from nib.
//
//  Call:
//    none.
//
//  Return:
//    none.
//
- (void)awakeFromNib
{
    // forwarded to super class.
    [super awakeFromNib];

    // set property.
    [self setClipsToBounds:YES];
    
    return;
}


//
// 表示画像を切り替え
//
//  Call
//    note     : 通知内容
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    orgRect_   : 表示画像の実数領域(instance 変数)
//    lastPoint_ : 最終 PD 位置(instance 変数)
//
-(void)changePicture:(NSNotification *)note
{
    PoCoPicture *picture = [[self->docCntl_ currentDocument] picture];

    if (picture != nil) {
        // view の領域を更新
        self->orgRect_ = [picture bitmapRect];
        [self updateFrame:YES];

        // 中心表示
        [self centering];
        [self->lastPoint_ release];
        self->lastPoint_ = [[PoCoPoint alloc] initX:(int)(self->orgRect_.size.width / 2)
                                              initY:(int)(self->orgRect_.size.height / 2)];
    }

    return;
}


//
// パレット要素変更通知
//
//  Call
//    note     : 通知内容
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    orgRect_   : 表示画像の実数領域(instance 変数)
//    lastPoint_ : 最終 PD 位置(instance 変数)
//
-(void)changePaletteElm:(NSNotification *)note
{
    PoCoPicture *picture = [[self->docCntl_ currentDocument] picture];

    if (picture != nil) {
        // view の領域を更新
        self->orgRect_ = [picture bitmapRect];
        [self updateFrame:YES];
    }

    return;
}


//
// レイヤー構造の変更を受信
//
//  Call
//    note : 通知内容
//
//  Return
//    None
//
-(void)editLayer:(NSNotification *)note
{
    // 全再描画
    [self setNeedsDisplay:YES];

    return;
}


//
// パレット属性更新通知
//
//  Call
//    note : 通知内容
//
//  Return
//    None
//
-(void)changePaletteAttr:(NSNotification *)note
{
    int i;

    if ([note object] == nil) {
        [self setNeedsDisplay:YES];
    } else {
        i = [[note object] intValue];
        if (i & 0x00040000) {
            [self setNeedsDisplay:YES];
        }
    }

    return;
}


//
// 画像編集(通知)
//
//  Call
//    note : 通知内容
//
//  Return
//    None
//
-(void)editPicture:(NSNotification *)note
{
    PoCoEditPictureNotification *obj;

    obj = [note object];
    if (obj != nil) {
        // 再描画の実行
        [self setNeedsDisplayInRect:[self toDispRect:[obj rect]]];
    } else {
        // 全再描画
        [self setNeedsDisplay:YES];
    }

    return;
}


//
// 編集通知(通知)
//  主ウィンドウで mouseDown/mouseDragged/mouseUp の発生を受け取る
//  表示位置の同期が目的の通知
//
//  Call
//    note       : 通知内容
//    lastPoint_ : 最終 PD 位置(instance 変数)
//
//  Return
//    lastPoint_ : 最終 PD 位置(instance 変数)
//
-(void)execDrawing:(NSNotification *)note
{
    NSPoint p1;
    NSPoint p2;
    NSRect vr;
    PoCoPoint *dp;
    PoCoRect *dr;
    const int zfact = ZOOM_FACTOR[self->zfactNum_];

    dp = [[(PoCoAppController *)([NSApp delegate]) editInfo] pdPos];
    vr = [self visibleRect];
    dr = [self calcSrcRect:vr
                     zfact:zfact];

    // 表示位置を算出
    if (zfact == 1000) {
        // 等倍
        p1.x = (float)([dp x]);
        p1.y = (float)([dp y]);
    } else {
        // 拡大/縮小(端数が出ないので共通)
        p1.x = (float)((([dp x] * zfact) / 1000));
        p1.y = (float)((([dp y] * zfact) / 1000));
    }

    // スクロール位置を算出
    p2 = vr.origin;
    if ((p1.x < vr.origin.x) ||
        (p1.x > (vr.origin.x + vr.size.width))) {
        p2.x = (p1.x - (float)(((([self->lastPoint_ x] - [dr left]) * zfact) / 1000)));
    }
    if ((p1.y < vr.origin.y) ||
        (p1.y > (vr.origin.y + vr.size.height))) {
        p2.y = (p1.y - (float)(((([self->lastPoint_ y] - [dr top]) * zfact) / 1000)));
    }

    // スクロールを実行
    if ((p2.x != vr.origin.x) || (p2.y != vr.origin.y)) {
        [self scrollPoint:p2];
    }

    // 最終 PD 位置を更新(先に算出した表示位置を PD 位置に見立てる)
    [self->lastPoint_ release];
    self->lastPoint_ = [self calcSrcPoint:p1
                                    zfact:zfact];

    [dr release];
    return;
}


//
// View に拡大率を反映した領域を設定
//
//  Call
//    sendRedraw : YES : 再描画要求を発行する
//                 NO  : 再描画要求は発行しない
//    zfactNum_  : 表示倍率の選択番号(instance 変数)
//    orgRect_   : 表示画像の実数領域(instance 変数)
//
//  Return
//    None
//
-(void)updateFrame:(BOOL)sendRedraw
{
    NSRect r;

    r.origin.x = 0;
    r.origin.y = 0;
    r.size.width = ((self->orgRect_.size.width * ZOOM_FACTOR[self->zfactNum_]) / 1000);
    r.size.height = ((self->orgRect_.size.height * ZOOM_FACTOR[self->zfactNum_]) / 1000);
    [self setFrame:r];

    // 再描画要求を発行
    if (sendRedraw) {
        [self setNeedsDisplay:YES];
    }

    return;
}


//
// 描画
//
//  Call
//    rect      : 描画領域(api 引数)
//    zfactNum_ : 表示倍率の選択番号(instance 変数)
//    docCntl_  : document controller(instance 変数)
//
//  Return
//    None
//
-(void)drawRect:(NSRect)rect
{
    NSRect dr;                          // 表示領域
    PoCoRect *sr;                       // 取得領域
    NSBitmapImageRep *img;              // 表示画像
    const PoCoPicture *picture = [[self->docCntl_ currentDocument] picture];
    const int zfact = ZOOM_FACTOR[self->zfactNum_];

    // 要表示領域/描画領域を算出
    sr = [self calcSrcRect:rect
                     zfact:zfact];
    dr = rect;
    if (zfact == 1000) {
        // 等倍
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
        img = [picture getMainImage:sr
                          withScale:1000
                     withSupplement:nil];
        [img drawAtPoint:dr.origin];
    } else if (zfact > 1000) {
        // 拡大
        dr.origin.x = (([sr left] * zfact) / 1000);
        dr.origin.y = (([sr  top] * zfact) / 1000);
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
        img = [picture getMainImage:sr
                          withScale:zfact
                     withSupplement:nil];
        [img drawAtPoint:dr.origin];
    } else {
        // 縮小
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        img = [picture getMainImage:sr
                          withScale:1000
                     withSupplement:nil];
        [img drawInRect:rect];
    }
    [sr release];

    // 表示画像を release
    [img release];

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
    return YES;                         // 常時 YES
}


// ----------------------------------------------------------------------------
// instance - public - event handler.

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


//
// ボタンダウン処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    lastPoint_ : 最終 PD 位置(instance 変数)
//
-(void)mouseDown:(NSEvent *)evt
{
    // 最終 PD 位置を更新
    [self->lastPoint_ release];
    self->lastPoint_ = [self calcSrcPoint:[PoCoPoint corrNSPoint:[self convertPoint:[evt locationInWindow] fromView:nil]]
                                    zfact:ZOOM_FACTOR[self->zfactNum_]];

    // ダブルクリックの場合は通知を投函
    if ([evt clickCount] > 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PoCoDClickOnSubView
                                                            object:self->lastPoint_];
    }

    return;
}


//
// ドラッグ処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    lastPoint_ : 最終 PD 位置(instance 変数)
//
-(void)mouseDragged:(NSEvent *)evt
{
    NSRect r = [self visibleRect];
    const float dx = [evt deltaX];
    const float dy = [evt deltaY];

#if 0
    // 一斉に動かす
    if ((dx != 0.0) || (dy != 0.0)) {
        r.origin.x -= dx;
        r.origin.y -= dy;
        [self scrollRectToVisible:r];
    }
#else   // 0
    // 水平
    if (dx != 0.0) {
        r.origin.x -= dx;
        [self scrollRectToVisible:r];
    }

    // 垂直
    if (dy != 0.0) {
        r.origin.y -= dy;
        [self scrollRectToVisible:r];
    }
#endif  // 0

    // 最終 PD 位置を更新
    [self->lastPoint_ release];
    self->lastPoint_ = [self calcSrcPoint:[PoCoPoint corrNSPoint:[self convertPoint:[evt locationInWindow] fromView:nil]]
                                    zfact:ZOOM_FACTOR[self->zfactNum_]];

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
    } else {
        // 通常の wheel 回転
        [super scrollWheel:evt];
    }
            
    return; 
}


//
// magnify ジェスチャ
//
//  Call
//    evt       : 発生イベント(api 変数)
//    slider_   : 倍率の slider(outlet)
//    zfactNum_ : 表示倍率の選択番号(instance 変数)
//
//  Return
//    None
//
-(void)magnifyWithEvent:(NSEvent *)evt
{
    int num = self->zfactNum_;

    // 表示倍率変更   
    if ([evt magnification] < -0.02) {
        (num)--;
    } else if ([evt magnification] >= 0.02) {
        (num)++;
    }
        
    // 表示に反映
    if ((num != self->zfactNum_) &&
        (num >= (int)([self->slider_ minValue])) &&
        (num <= (int)([self->slider_ maxValue]))) {
        [self->slider_ setFloatValue:(float)(num)];
        [self changeZoom:num];
    }

    return; 
}


// ----------------------------------------------------------------------------
// instance - public - IBActions.

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

@end
