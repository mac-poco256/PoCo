//
//	Pelistina on Cocoa - PoCo -
//	MyDocument(編集対象の管理の主幹部)
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoMyDocument.h"

#import "PoCoLayer.h"
#import "PoCoPicture.h"
#import "PoCoSelLayer.h"
#import "PoCoColorPattern.h"
#import "PoCoView.h"
#import "PoCoAppController.h"
#import "PoCoEditInfo.h"
#import "PoCoPNG.h"
#import "PoCoColorBuffer.h"


// 内部変数
static const unsigned char header[8] = {  // PNG signature
                               0x89, 0x50, 0x4e, 0x47,
                               0x0d, 0x0a, 0x1a, 0x0a
                           };


// 外部変数
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)
extern NSString* NSPNGPboardType;
#else   // (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)
static NSString* NSPNGPboardType = @"Apple PNG pasteboard type";
#endif  // (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)

// ============================================================================
@implementation MyDocument

// ------------------------------------------------------------ class - private
//
// PNG ヘッダを確認
//
//  Call
//    data  : 読み込み内容
//    range : 読み込み範囲
//
//  Return
//    function : YES : 正常
//               NO  : 異常
//    range    : 読み込み範囲(location を更新)
//
+(BOOL)checkFileHeader:(NSData *)data
             withRange:(NSRange *)range
{
    BOOL result;
    unsigned char buf[8];

    DPRINT((@"[MyDocument checkFileHeader]\n"));

    // 先頭 8 bytes を読み込み
    range->length = 8;
    [data getBytes:buf range:*(range)];
    range->location += range->length;

    // 照合
    result = (memcmp(buf, header, 8) == 0);

    return result;
}


// ------------------------------------------------------------- class - public
//
// ペーストボードから貼り付け実行
//
//  Call
//    pb  : ペーストボード
//    lyr : 取り込んだ内容に対するレイヤー
//    plt : 取り込んだ内容に対するパレット
//
//  Return
//    function : YES : 正常
//               NO  : 異常
//    lyr      : 取り込んだ内容に対するレイヤー
//    plt      : 取り込んだ内容に対するパレット
//
+(BOOL)readPngFromPasteboard:(NSPasteboard *)pb
                 resultLayer:(PoCoLayerBase **)lyr
               resultPalette:(PoCoPalette *)plt
{
    BOOL result;
    NSString *type;
    NSData *data;
    NSRange range;

    DPRINT((@"[PoCoDocument readPngFromPasteboard]\n"));

    result = NO;                        // 初期値は失敗
    range.location = 0;
    range.length = 0;

    // 種別確認(PNG のみ受け入れ)
    type = [pb availableTypeFromArray:[NSArray arrayWithObject:NSPNGPboardType]];
    if (type == nil) {
        DPRINT((@"not exist PNG data.\n"));
        goto EXIT;
    }

    // 内容取得
    data = [pb dataForType:NSPNGPboardType];
    if (data == nil) {
        DPRINT((@"can't get data from PasteBoard.\n"));
        goto EXIT;
    }

    // ヘッダを確認
    result = [MyDocument checkFileHeader:data
                               withRange:&(range)];
    if (result != YES) {
        DPRINT((@"not match header.\n"));
        goto EXIT;
    }

    // 画像を読み込み
    result = [PoCoPicture pastePBoardData:data
                                withRange:&(range)
                              resultLayer:lyr
                            resultPalette:plt];
    if (result != YES) {
        DPRINT((@"not paste data.\n"));
        goto EXIT;
    }

    // 正常終了
    result = YES;

EXIT:
    return result;
}


// --------------------------------------------------------- instance - private
//
// ファイルヘッダを作成
//  PNG signature だけを格納した NSData を返す
//
//  Call
//    None
//
//  Return
//    function : data
//
-(NSData *)createFileHeader
{
    DPRINT((@"[MyDocument createFileHeader]\n"));

    return [NSData dataWithBytes:header length:8];
}


//
// ファイルフッタを作成
//  IEND Chunk だけ格納した NSData を返す
//
//  Call
//    None
//
//  Return
//    function : data
//
-(NSData *)createFileFooter
{
    NSData *data;
    PoCoPNGEncoder *png;

    DPRINT((@"[MyDocument createFileFooter]\n"));

    png = [[PoCoPNGEncoder alloc] init];

    // CHUNK を生成
    [png createChunk:(unsigned char *)("IEND")];

    // CHUNK を閉じる
    [png closeChunk];

    // NSData を生成
    data = [png createNSData];
    [png release];

    return data;
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
    // 指定イニシャライザへ回送
    return [self initWidth:640
                initHeight:480
            initResolution:120
              defaultColor:0];
}


//
// initialize(指定イニシャライザ)
//  新規画像を生成する場合に呼ぶ
//
//  Call
//    w : 幅(dot 単位)
//    h : 高さ(dot 単位)
//    r : 解像度(dpi)
//    c : 初期色
//
//  Return
//    function     : 実体
//    picture_     : 編集対象画像(instance 変数)
//    selLayer_    : 選択中レイヤー情報(instance 変数)
//    eraser_      : 消しゴム用画像(instance 変数)
//    colorBuffer_ : 色保持(instance 変数)
//
-(id)initWidth:(int)w
    initHeight:(int)h
initResolution:(int)r
  defaultColor:(unsigned char)c
{
    DPRINT((@"[PoCoMyDocument initWidth initHeight initResolution defaultColor]\n"));

    PoCoErr er;

    // super class を初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->picture_ = nil;
        self->selLayer_ = nil;
        self->eraser_ = nil;
        self->colorBuffer_ = nil;

        // 資源の確保
        self->picture_ = [[PoCoPicture alloc] init:r];
        if (self->picture_ == nil) {
            DPRINT((@"can't alloc PoCoPicture\n"));
            [self release];
            self = nil;
            goto EXIT;
        }
        self->selLayer_ = [[PoCoSelLayer alloc] init];
        if (self->selLayer_ == nil) {
            DPRINT((@"can't alloc PoCoSelLayer\n"));
            [self release];
            self = nil;
            goto EXIT;
        }
        if ([[(PoCoAppController *)([NSApp delegate]) editInfo] enableColorBuffer]) {
            self->colorBuffer_ = [[PoCoColorBuffer alloc] init];
            if (self->colorBuffer_ == nil) {
                DPRINT((@"can't alloc PoCoColorBuffer\n"));
                [self release];
                self = nil;
                goto EXIT;
            }
        }

        // 空レイヤーを追加
        er = [self->picture_ addLayer:-1
                                width:w
                               height:h
                                color:c];
        if (er < ER_OK) {
            DPRINT((@"[self->picture_ addLayer:width:height:color:]: %d\n", er));
            [self release];
            self = nil;
            goto EXIT;
        }

        // 取り消し最大数を設定
        [[self undoManager] setLevelsOfUndo:[[(PoCoAppController *)([NSApp delegate]) editInfo] undoMaxLevel]];
    }

EXIT:
    return self;
}


//
// deallocate
//
//  Call
//    None
//
//  Return
//    picture_     : 編集対象画像(instance 変数)
//    selLayer_    : 選択中レイヤー情報(instance 変数)
//    eraser_      : 消しゴム用画像(instance 変数)
//    colorBuffer_ : 色保持(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoMyDocument dealloc]\n"));

    // 資源の解放
    [self->eraser_ release];
    [self->selLayer_ release];
    [self->picture_ release];
    [self->colorBuffer_ release];
    self->picture_ = nil;
    self->selLayer_ = nil;
    self->eraser_ = nil;
    self->colorBuffer_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集対象画像の取得
//
//  Call
//    picture_ : 編集対象画像(instance 変数)
//
//  Return
//    function : 編集対象画像
//
-(PoCoPicture *)picture
{
    return self->picture_;
}


//
// 選択中レイヤー情報の取得
//
//  Call
//    selLayer_ : 選択中レイヤー情報(instance 変数)
//
//  Return
//    function : 選択中レイヤー情報
//
-(PoCoSelLayer *)selLayer
{
    return self->selLayer_;
}


//
// 色保持を取得
//
//  Call
//    colorBuffer_ : 色保持(instance 変数)
//
//  Return
//    function : 色保持
//
-(PoCoColorBuffer *)colorBuffer
{
    return self->colorBuffer_;
}


//
// view 取得
//
//  Call
//    view_ : 表示部(outlet)
//
//  Return
//    function : view
//
-(PoCoView *)view
{
    return self->view_;
}


//
// 消しゴム用画像を設定
//
//  Call
//    picture_  : 編集対象画像(instance 変数)
//    selLayer_ : 選択中レイヤー情報(instance 変数)
//
//  Return
//    eraser_ : 消しゴム用画像(instance 変数)
//
-(void)setEraser
{
    // 以前の分を解放
    [self clearEraser];

    // 現在のレイヤーをそのまま記憶
    self->eraser_ = [[PoCoColorPattern alloc]
                       initWithBitmap:[[self->picture_ layer:[self->selLayer_ sel]] bitmap]];

    return;
}


//
// 消しゴム用画像を解放
//
//  Call
//    None
//
//  Return
//    eraser_ : 消しゴム用画像(instance 変数)
//
-(void)clearEraser
{
    [self->eraser_ release];
    self->eraser_ = nil;

    return;
}


//
// 消しゴム用画像取得
//
//  Call
//    eraser_ : 消しゴム用画像(instance 変数)
//
//  Return
//    function : 消しゴム用画像
//
-(PoCoColorPattern *)eraser
{
    return self->eraser_;
}


//
// ウィンドウ切り替え
//
//  Call
//    note     : 通知内容(api 変数)
//    view_    : 表示部(outlet)
//    picture_ : 編集対象画像(instance 変数)
//
//  Return
//    None
//
-(void)windowDidBecomeMain:(NSNotification *)note
{
    PoCoRect *r;

    // 各ウィンドウの表示を切り替える
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoChangePicture
                      object:self];

    // 描画編集機能を更新(実体生成)
    [self->view_ didChangeDrawTool];

    // 編集情報の更新
    r = [self->picture_ bitmapPoCoRect];
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setPictureRect:r];
    [r release];

    // 取り消し最大数を設定
    [[self undoManager] setLevelsOfUndo:[[(PoCoAppController *)([NSApp delegate]) editInfo] undoMaxLevel]];

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
    return [self undoManager];
}


//
// 更新通知
//
//  Call
//    type : 設定値
//
//  Return
//    None
//
-(void)setUpdateState:(NSDocumentChangeType)type
{
    [self updateChangeCount:type];

    return;
}


//
// パレット更新通知
//
//  Call
//    view_    : 表示部(outlet)
//    picture_ : 編集対象画像(instance 変数)
//
//  Return
//    None
//
-(void)didUpdatePalette
{
    [self->picture_ didUpdatePalette];
    [self->view_ setNeedsDisplay:YES];

    return;
}


//
// 画像更新通知
//
//  Call
//    r     : 更新矩形枠(実寸)
//    view_ : 表示部(outlet)
//
//  Return
//    None
//
-(void)didUpdatePicture:(PoCoRect *)r
{
    // 主ウィンドウの更新
    if (r == nil) {
        [self->view_ setNeedsDisplay:YES];
    } else {
        [self->view_ setNeedsDisplayInOriginalRect:r];
    }

    return;
}


//
// 描画編集切り替え通知
//  切り替えた機能番号は PoCoEditInfo に記憶している
//
//  Call
//    view_ : 表示部(outlet)
//
//  Return
//    None
//
-(void)didChangeDrawTool
{
    [self->view_ didChangeDrawTool];

    return;
}


//
// レイヤーサイズ変更通知 
//
//  Call
//    view_ : 表示部(outlet)
//
//  Return
//    None
//
-(void)didLayerResize
{
    // view_ の表示更新
    [self->view_ layerResize:YES];

    return;
}


//
// 表示ウィンドウダブルクリック通知
//
//  Call
//    p     : 表示ウィンドウ内での実寸の最終 PD 位置
//    view_ : 表示部(outlet)
//
//  Return
//    None
//
-(void)dclickOnSubView:(PoCoPoint *)p
{
    // view_ の表示更新
    [self->view_ doubleClickedOnSubView:p];

    return;
}


//
// ガイドライン表示
//
//  Call
//    view_ : 表示部(outlet)
//
//  Return
//    None
//
-(void)drawGuideLine
{
    [self->view_ drawGuideLine];

    return;
}


//
// 編集状態解除
//
//  Call
//    view_ : 表示部(outlet)
//
//  Return
//    None
//
-(void)cancelEdit
{
    [self->view_ cancelEdit];

    return;
}


//
// スペースキーイベント
//
//  Call
//    isPress : key down か
//              YES : keyDown によるもの
//              NO  : keyUp によるもの
//    view_   : 表示部(outlet)
//
//  Return
//    None
//
-(void)spaceKeyEvent:(BOOL)isPress
{
    [self->view_ spaceKeyEvent:isPress];

    return;
}


//
// 定義 nib file
//  Xcode 標準実装
//
//  Call
//    None
//
//  Return
//    function : nib file name
//
-(NSString *)windowNibName
{
    return @"MyDocument";
}


//
// nib 読み込み後処理
//  Xcode 標準実装
//
//  Call
//    aController : window 管理部(api 引数)
//    view_       : 表示部(outlet)
//    picture_    : 編集対象画像(instance 変数)
//    scroller_   : scroller(outlet)
//
//  Return
//    None
//
-(void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    PoCoRect *r;
    PoCoPoint *p;

    [super windowControllerDidLoadNib:aController];

    // view_ の再描画要求を発行
    [self->view_ layerResize:YES];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoChangePicture
                      object:self];

    // mouse move を取得可能にする
    [[aController window] setAcceptsMouseMovedEvents:YES];
    [[aController window] makeFirstResponder:self->view_];

    // 最初に開いた位置を記憶
    if ([[(PoCoAppController *)([NSApp delegate]) editInfo] saveDocWindowPos]) {
        [aController setWindowFrameAutosaveName:@"MainViewWindowPos"];
    }

    // 描画編集系の実体を生成
    [self->view_ didChangeDrawTool];

    // scrollbar の表示方法
    switch ([[(PoCoAppController *)([NSApp delegate]) editInfo] showScrollerView]) {
        default:
        case PoCoScrollerType_default:
            // OS の設定に依存
            ;
            break;
        case PoCoScrollerType_always:
            // 常時
            [self->scroller_ setScrollerStyle:NSScrollerStyleLegacy];
            break;
        case PoCoScrollerType_overlay:
            // 適宜
            [self->scroller_ setScrollerStyle:NSScrollerStyleOverlay];
            break;
    }

    // 中心表示
    r = [self->picture_ bitmapPoCoRect];
    p = [[PoCoPoint alloc] initX:([r  width] / 2)
                           initY:([r height] / 2)];
    [self->view_ centering];
    [[(PoCoAppController *)([NSApp delegate]) editInfo] setLastPos:p];
    [p release];
    [r release];

    return;
}


//
// 保存の実行
//  Xcode 標準実装
//
//  Call
//    aType    : 形式名称(api 引数)
//    outError : error(api 引数)
//
//  Return
//    function : 保存内容
//
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)
-(NSData *)dataOfType:(NSString *)aType
                error:(NSError **)outError
{
    NSMutableData *data;

    DPRINT((@"[PoCoDocument dataOfType:%@ error]\n", aType));

    data = nil;
    *(outError) = nil;

    // 未対応形式
    if (!([aType isEqualToString:@"PoCoPicture"])) {
        goto EXIT;
    }

    // ガイドライン消去
    [self drawGuideLine];

    // 生成
    data = [NSMutableData data];
    [data appendData:[self createFileHeader]];
    [data appendData:[self->picture_ createFileData:[[(PoCoAppController *)([NSApp delegate]) editInfo] grayToAlpha]]];
    [data appendData:[self createFileFooter]];

    // ガイドライン表示
    [self drawGuideLine];

EXIT:
    return data;
}
#else   // (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)
-(NSData *)dataRepresentationOfType:(NSString *)aType
{
    NSMutableData *data;

    DPRINT((@"[PoCoDocument dataRepresentationOfType:%@]\n", aType));

    data = nil;

    // 未対応形式
    if (!([aType isEqualToString:@"PoCoPicture"])) {
        goto EXIT;
    }

    // ガイドライン消去
    [self drawGuideLine];

    // 生成
    data = [NSMutableData data];
    [data appendData:[self createFileHeader]];
    [data appendData:[self->picture_ createFileData:[[(PoCoAppController *)([NSApp delegate]) editInfo] grayToAlpha]]];
    [data appendData:[self createFileFooter]];

    // ガイドライン表示
    [self drawGuideLine];

EXIT:
    return data;
}
#endif  // (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)


//
// 読み込みの実行
//  Xcode 標準実装
//
//  Call
//    data     : 読み込み内容(api 引数)
//    aType    : 形式名称(api 引数)
//    outError : error(api 引数)
//    picture_ : 編集対象画像(instance 変数)
//
//  Return
//    function : YES : 正常
//               NO  : 異常
//
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)
-(BOOL)readFromData:(NSData *)data
             ofType:(NSString *)aType
              error:(NSError **)outError
{
    BOOL    result;
    NSRange range;

    DPRINT((@"[PoCoDocument readFromData ofType:%@ error]\n", aType));

    result = NO;                        // 初期値は失敗
    *(outError) = nil;
    range.location = 0;
    range.length = 0;

    // 形式確認
    if (!([aType isEqualToString:@"PoCoPicture"])) {
        goto EXIT;
    }

    // ヘッダを確認
    result = [MyDocument checkFileHeader:data
                               withRange:&(range)];
    if (result != YES) {
        DPRINT((@"not match header.\n"));
        goto EXIT;
    }

    // 画像を読み込み
    result = [self->picture_ loadFileData:data
                                withRange:&(range)];
    if (result != YES) {
        DPRINT((@"can't load data.\n"));
        goto EXIT;
    }

    // 成功
    result = YES;

EXIT:
    return result;
}
#else   // (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)
-(BOOL)loadDataRepresentation:(NSData *)data
                       ofType:(NSString *)aType
{
    BOOL    result;
    NSRange range;

    DPRINT((@"[PoCoDocument loadDataRepresentation ofType:%@]\n", aType));

    result = NO;                        // 初期値は失敗
    range.location = 0;
    range.length = 0;

    // 形式確認
    if (!([aType isEqualToString:@"PoCoPicture"])) {
        goto EXIT;
    }

    // ヘッダを確認
    result = [MyDocument checkFileHeader:data
                               withRange:&(range)];
    if (result != YES) {
        DPRINT((@"not match header.\n"));
        goto EXIT;
    }

    // 画像を読み込み
    result = [self->picture_ loadFileData:data
                                withRange:&(range)];
    if (result != YES) {
        DPRINT((@"can't load data.\n"));
        goto EXIT;
    }

    // 成功
    result = YES;

EXIT:
    return result;
}
#endif  // (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)


//
// ペーストボードへ貼り付け実行
//
//  Call
//    pb       : 張り付け先
//    r        : 切り取り範囲
//    index    : 対象レイヤー
//    picture_ : 編集対象画像(instance 変数)
//
//  Return
//    None
//
-(void)writePngToPasteboard:(NSPasteboard *)pb
                   withRect:(PoCoRect *)r
                    atIndex:(int)index
{
    NSMutableData *data;

    DPRINT((@"[PoCoDocument writePngToPasteboard]\n"));

    // 画像を抜き取り(current layer から PNG で取得する)
    data = [NSMutableData data];
    [data appendData:[self createFileHeader]];
    [data appendData:[self->picture_ createPBoardData:r
                                              atIndex:index
                                              toAlpha:[[(PoCoAppController *)([NSApp delegate]) editInfo] grayToAlpha]]];
    [data appendData:[self createFileFooter]];
    if (data != nil) {
        // 型を登録
        [pb declareTypes:[NSArray arrayWithObject:NSPNGPboardType]
                   owner:self];

        // 内容を設定
        [pb setData:data
            forType:NSPNGPboardType];
    }

    return;
}

@end
