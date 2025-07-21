//
// PoCoLayerOperate.h
// implementation of PoCoLayerOperate class.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//


#import "PoCoLayerOperate.h"

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"
#import "PoCoMyDocument.h"
#import "PoCoSelLayer.h"
#import "PoCoLayer.h"

#import "PoCoControllerFactory.h"
#import "PoCoControllerLayerBitmapAdder.h"
#import "PoCoControllerLayerStringAdder.h"
#import "PoCoControllerLayerDeleter.h"
#import "PoCoControllerLayerMover.h"
#import "PoCoControllerLayerDisplaySetter.h"
#import "PoCoControllerLayerLockSetter.h"
#import "PoCoControllerLayerNameSetter.h"
#import "PoCoControllerPictureLayerUnificater.h"

// 内部定数
enum ColumnType {                       // 一覧表の桁毎の区分
    ColumnType_Display,                 // 表示/非表示
    ColumnType_DrawLock,                // 編集許可/禁止
    ColumnType_LayerType,               // レイヤー種別名称
    ColumnType_Sample,                  // 見本
    ColumnType_Name                     // レイヤー名称
};

// ============================================================================
@implementation PoCoLayerOperate

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
        // 編集対象変更を受信
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

        // パレット変更を受信
        [nc addObserver:self
               selector:@selector(changePalette:)
                   name:PoCoChangePalette
                 object:nil];

        // レイヤー構造の変更通知
        [nc addObserver:self
               selector:@selector(editLayer:)
                   name:PoCoEditLayer
                 object:nil];

        // 画像編集の受信
        [nc addObserver:self
               selector:@selector(editPicture:)
                   name:PoCoEditPicture
                 object:nil];

        // レイヤー見本の更新通知
        [nc addObserver:self
               selector:@selector(updatePreview:)
                   name:PoCoLayerPreviewUpdate
                 object:nil];
    }

    return;
}


// ----------------------------------------------------------------------------
// instance - public.

//
// initialize
//
//  Call
//    None
//
//  Return
//    function       : 実体
//    docCntl_       : document controller(instance 変数)
//    selLayer_      : 選択中レイヤー(instance 変数)
//    targetRow_     : 移動目標行(instance 変数)
//    info_          : 編集情報(instance 変数)
//    prevSelectRow_ : 以前の選択行(instance 変数)
//
-(id)init
{
    DPRINT((@"[PoCoLayerOperate init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->selLayer_ = nil;
        self->targetRow_ = -1;
        self->prevSelectRow_ = -1;

        // observer を登録
        [self registerObserver];

        // document controller を取得
        self->docCntl_ = [NSDocumentController sharedDocumentController];
        self->selLayer_ = [[self->docCntl_ currentDocument] selLayer];
        [self->docCntl_ retain];
        [self->selLayer_ retain];

        // 編集情報を取得
        self->info_ = [(PoCoAppController *)([NSApp delegate]) editInfo];
        [self->info_ retain];
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
//    docCntl_  : document controller(instance 変数)
//    selLayer_ : 選択中レイヤー情報(instance 変数)
//    info_     : 編集情報(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoLayerOperate dealloc]\n"));

    // observer の登録を解除
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // 資源の解放
    [self->docCntl_ release];
    [self->selLayer_ release];
    [self->info_ release];
    self->docCntl_ = nil;
    self->selLayer_ = nil;
    self->info_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


// ----------------------------------------------------------------------------
// instance - public - for observer.

//
// 表示画像を切り替え(通知)
//
//  Call
//    note       : 通知内容
//    layerList_ : 一覧表(outlet)
//    docCntl_   : document controller(instance 変数)
//
//  Return
//    selLayer_ : 選択中レイヤー情報(instance 変数)
//
-(void)changePicture:(NSNotification *)note
{
    // 選択中レイヤー情報を current のものに変更
    if ([[self->docCntl_ currentDocument] selLayer] != nil) {
        // 以前の分を忘れる
        [self->selLayer_ release];
        self->selLayer_ = nil;

        // 選択中のものを記憶
        self->selLayer_ = [[self->docCntl_ currentDocument] selLayer];
        [self->selLayer_ retain];

        // 一覧表を初期化
        [self->layerList_ reloadData];

        // 表示位置/選択対象を切り替え
        [self->layerList_ selectRowIndexes:[NSIndexSet indexSetWithIndex:([[[[self->docCntl_ currentDocument] picture] layer] count] - [self->selLayer_ sel] - 1)]
                      byExtendingSelection:NO];
    }

    return;
}


//
// パレットを編集(通知)
//
//  Call
//    note       : 通知内容
//    layerList_ : 一覧表(outlet)
//
//  Return
//    None
//
-(void)changePalette:(NSNotification *)note
{
    // 一覧表の表示を更新
    [self->layerList_ reloadData];

    return;
}


//
// レイヤー構造の変更(通知)
//
//  Call
//    note       : 通知内容
//    layerList_ : 一覧表(outlet)
//    docCntl_   : document controller(instance 変数)
//
//  Return
//    selLayer_ : 選択中レイヤー情報(instance 変数)
//
-(void)editLayer:(NSNotification *)note
{
    // 一覧表を更新
    if ([[note object] boolValue]) {
        // 構造変動なので全再描画
        [self->layerList_ reloadData];

        // 選択番号をはみ出さないようにする
        if ([[[[self->docCntl_ currentDocument] picture] layer] count] <= [self->selLayer_ sel]) {
            [self->selLayer_ setSel:((int)([[[[self->docCntl_ currentDocument] picture] layer] count]) - 1)];
        }
    } else {
        // 単純再描画
        [self->layerList_ setNeedsDisplay:YES];
    }

    return;
}


//
// 画像編集(通知)
//
//  Call
//    note       : 通知内容
//    layerList_ : 一覧表(outlet)
//    docCntl_   : document controller(instance 変数)
//
//  Return
//    None
//
-(void)editPicture:(NSNotification *)note
{
    NSRect r;
    int cnt;
    PoCoEditPictureNotification *obj;

    obj = [note object];
    if (obj != nil) {
        // 対象レイヤーのみ更新
        cnt = (int)([[[[self->docCntl_ currentDocument] picture] layer] count]);
        r = NSIntersectionRect([self->layerList_ rectOfRow:(cnt - [obj index] - 1)], 
                               [self->layerList_ rectOfColumn:ColumnType_Sample]);
        [[[self->docCntl_ currentDocument] picture] updateLayerPreview:[obj index]];
        [self->layerList_ setNeedsDisplayInRect:r];
    } else {
        // 全再描画
        [[[self->docCntl_ currentDocument] picture] updateLayerPreview:-1];
        [self->layerList_ reloadData];
    }

    return;
}


//
// 見本更新(全更新)
//
//  Call
//    note       : 通知内容
//    layerList_ : 一覧表(outlet)
//    docCntl_   : document controller(instance 変数)
//
//  Return
//    None
//
-(void)updatePreview:(NSNotification *)note
{
    // 全再描画
    [[[self->docCntl_ currentDocument] picture] updateLayerPreview:-1];
    [self->layerList_ reloadData];

    return;
}


// ----------------------------------------------------------------------------
// instance - public - IBActions.

//
// 画像レイヤー生成
//
//  Call
//    sender     : 操作対象
//    layerList_ : 一覧表(outlet)
//    docCntl_   : document controller(instance 変数)
//    info_      : 編集情報(instance 変数)
//
//  Return
//    selLayer_ : 選択中レイヤー情報(instance 変数)
//
- (IBAction)newBitmapLayer:(id)sender
{
    id cntl;

    // 選択変更を通知(編集状態を解除)
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoSelLayerChange
                      object:nil];

    // 編集
    cntl = [[(PoCoAppController *)([NSApp delegate]) factory]
               createLayerBitmapAdder:NO
                                color:[[self->info_ selColor] num]];
    if ([cntl execute]) {
        // 選択中レイヤーの切り替え
        [self->selLayer_ setSel:((int)([[[[self->docCntl_ currentDocument] picture] layer] count]) - 1)];
        [self->layerList_ selectRowIndexes:[NSIndexSet indexSetWithIndex:0]
                      byExtendingSelection:NO];
        [self->layerList_ scrollRowToVisible:0];
    }
    [cntl release];

    return;
}


//
// 文字列レイヤー生成
//
//  Call
//    sender     : 操作対象
//    layerList_ : 一覧表(outlet)
//    docCntl_   : document controller(instance 変数)
//    info_      : 編集情報(instance 変数)
//
//  Return
//    selLayer_ : 選択中レイヤー情報(instance 変数)
//
- (IBAction)newStringLayer:(id)sender
{
    id cntl;

    // 選択変更を通知(編集状態を解除)
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoSelLayerChange
                      object:nil];

    // 編集
    cntl = [[(PoCoAppController *)([NSApp delegate]) factory]
               createLayerStringAdder:NO
                                color:[[self->info_ selColor] num]];
    if ([cntl execute]) {
        // 選択中レイヤーの切り替え
        [self->selLayer_ setSel:((int)([[[[self->docCntl_ currentDocument] picture] layer] count]) - 1)];
        [self->layerList_ selectRowIndexes:[NSIndexSet indexSetWithIndex:0]
                      byExtendingSelection:NO];
        [self->layerList_ scrollRowToVisible:0];
    }
    [cntl release];

    return;
}


//
// copy layer.
//
//  Call:
//    sender     : 操作対象
//    layerList_ : 一覧表(outlet)
//    docCntl_   : document controller(instance 変数)
//    info_      : 編集情報(instance 変数)
//
//  Return:
//    selLayer_ : 選択中レイヤー情報(instance 変数)
//
- (IBAction)copyLayer:(id)sender
{
    const int cnt = (int)([[[[self->docCntl_ currentDocument] picture] layer] count]);
    const int sel = ([self->selLayer_ sel] + 1);
    id  cntl;

    // to cancel selection, notify the changing current layer.
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoSelLayerChange
                      object:nil];

    // create the edit controller.
    cntl = [[(PoCoAppController *)([NSApp delegate]) factory]
               createLayerMover:NO
                            src:[self->selLayer_ sel]
                         target:sel
                           copy:YES];
    if ([cntl execute]) {
        // redraw the layer list.
        [self->layerList_ selectRowIndexes:[NSIndexSet indexSetWithIndex:(cnt - sel)]
                      byExtendingSelection:NO];
        [self->layerList_ scrollRowToVisible:(cnt - sel)];

        // change current layer.
        [self->selLayer_ setSel:sel];
    }
    [cntl release];

    return;
}


//
// レイヤー削除
//
//  Call
//    sender     : 操作対象
//    layerList_ : 一覧表(outlet)
//    docCntl_   : document controller(instance 変数)
//    selLayer_  : 選択中レイヤー情報(instance 変数)
//
//  Return
//    selLayer_ : 選択中レイヤー情報(instance 変数)
//
- (IBAction)deleteLayer:(id)sender
{
    id cntl;
    int cnt;
    int sel;

    // 選択変更を通知(編集状態を解除)
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoSelLayerChange
                      object:nil];

    // 編集
    cntl = [[(PoCoAppController *)([NSApp delegate]) factory]
               createLayerDeleter:NO
                            index:[self->selLayer_ sel]];
    if ([cntl execute]) {
        // 選択中レイヤーの切り替え
        cnt = (int)([[[[self->docCntl_ currentDocument] picture] layer] count]);
        sel = [self->selLayer_ sel];
        if (sel >= cnt) {
            sel = (cnt - 1);
        } else if (sel > 0) {
            (sel)--;
        }
        [self->selLayer_ setSel:sel];
        [self->layerList_ selectRowIndexes:[NSIndexSet indexSetWithIndex:(cnt-sel-1)]
                      byExtendingSelection:NO];
        [self->layerList_ scrollRowToVisible:(cnt - sel - 1)];
    }
    [cntl release];

    return;
}


//
// 表示レイヤー統合
//
//  Call
//    sender     : 操作対象
//    layerList_ : 一覧表(outlet)
//    docCntl_   : document controller(instance 変数)
//
//  Return
//    selLayer_ : 選択中レイヤー情報(instance 変数)
//
- (IBAction)unificateLayer:(id)sender
{
    id cntl;

    // 選択変更を通知(編集状態を解除)
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoSelLayerChange
                      object:nil];

    // 編集
    cntl = [[(PoCoAppController *)([NSApp delegate]) factory]
               createPictureLayerUnificater:NO];
    if ([cntl execute]) {
        // 選択中レイヤーの切り替え
        [self->selLayer_ setSel:((int)([[[[self->docCntl_ currentDocument] picture] layer] count]) - 1)];
        [self->layerList_ selectRowIndexes:[NSIndexSet indexSetWithIndex:0]
                      byExtendingSelection:NO];
        [self->layerList_ scrollRowToVisible:0];
    }
    [cntl release];

    return;
}


// ----------------------------------------------------------------------------
// instance - public - delegate for table list.

//
// 行の選択可否
//
//  Call
//    table : 対象(api 変数)
//    row   : 対象行(api 変数)
//
//  Return
//    function       : 可否(常に YES)
//    selLayer_      : 選択中レイヤー情報(instance 変数)
//    prevSelectRow_ : 以前の選択行(instance 変数)
//
-(BOOL)tableView:(NSTableView *)table
 shouldSelectRow:(int)row
{
//    DPRINT((@"[PoCoLayerOperate tableView: shouldSelectRow:%d]\n", row));

    // 選択変更を通知(編集状態を解除)
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoSelLayerChange
                      object:nil];

    // 選択レイヤーを切り替え
    self->prevSelectRow_ = (int)([table selectedRow]);
    [self->selLayer_ setSel:((int)([table numberOfRows]) - row - 1)];

    return YES;
}


//
// 行を選択した
//  実際に選択が切り替わったら notify されるもの
//
//  Call
//    note : 通知内容
//
//  Return
//    prevSelectRow_ : 以前の選択行(instance 変数)
//
-(void)tableViewSelectionDidChange:(NSNotification *)note
{
    // 以前の選択を忘れる(切り替えが有効なので強制的に戻す必要がない)
    self->prevSelectRow_ = -1;

    return;
}


//
// 予定移動目標の取得
//  独自追加 api
//
//  Call
//    table      : 対象
//    targetRow_ : 目標行(instance 変数)
//
//  Return
//    function : 目標行
//
-(int)targetRowInTableView:(NSTableView *)table
{
//    DPRINT((@"[PoCoLayerOperate targetRowInTableView]\n"));

    return self->targetRow_;
}


//
// 予定移動目標の設定
//  独自追加 api
//
//  Call
//    table : 対象
//    row   : 目標行
//
//  Return
//    targetRow_ : 目標行(instance 変数)
//
-(void)tableView:(NSTableView *)table
    setTargetRow:(int)row
{
//    DPRINT((@"[PoCoLayerOperate tableView: setTargetRow:%d]\n", row));

    self->targetRow_ = row;

    return;
}


// ----------------------------------------------------------------------------
// instance - public - delegate for table data source.

//
// 行数の取得
//
//  Call
//    table    : 対象(api 変数)
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    function : 行数   
//      
-(int)numberOfRowsInTableView:(NSTableView *)table
{
//    DPRINT((@"[PoCoLayerOperate numberOfRowsInTableView]\n"));

    return (int)([[[[self->docCntl_ currentDocument] picture] layer] count]);
}


//
// 表示
//
//  Call
//    table    : 対象(api 変数)
//    column   : 対象桁(api 変数)
//    row      : 対象行(api 変数)
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    function : 表示内容
//
-(id)tableView:(NSTableView *)table
objectValueForTableColumn:(NSTableColumn *)column
                      row:(int)row
{
    NSString *identifier;
    NSMutableArray *layerArray;
    PoCoLayerBase *layer;

//    DPRINT((@"[PoCoLayerOperate tableView: objectValueForTableColumn: row:%d]\n", row));

    identifier = [column identifier];
    layerArray = [[[self->docCntl_ currentDocument] picture] layer];
    layer = [layerArray objectAtIndex:([layerArray count] - row - 1)];

    return [layer valueForKey:identifier];
}


//
// 編集
//
//  Call
//    table          : 対象(api 変数)
//    object         : 編集内容(api 変数)
//    column         : 対象桁(api 変数)
//    row            : 対象行(api 変数)
//    docCntl_       : document controller(instance 変数)
//    selLayer_      : 選択中レイヤー(instance 変数)
//    prevSelectRow_ : 以前の選択行(instance 変数)
//
//  Return
//    selLayer_ : 選択中レイヤー情報(instance 変数)
//
-(void)tableView:(NSTableView *)table
  setObjectValue:(id)object
  forTableColumn:(NSTableColumn *)column
             row:(int)row
{
    NSString *identifier;
    id cntl;
    int idx;
    int cnt;
    PoCoControllerFactory *factory = [(PoCoAppController *)([NSApp delegate]) factory];

//    DPRINT((@"[PoCoLayerOperate tableView: setObjectValue: ForTableColumn: row:%d]\n", row));

    // 対象を範囲内に収める
    idx = [self->selLayer_ sel];
    cnt = (int)([[[[self->docCntl_ currentDocument] picture] layer] count]);
    if (idx < 0) {
        idx = 0;
    } else if (idx >= cnt) {
        idx = (cnt - 1);
    }

    // 編集部を生成
    cntl = nil;
    identifier = [column identifier];
    if ([identifier compare:@"isDisplay"] == NSOrderedSame) {
        // 表示可否
        cntl = [factory createLayerDisplaySetter:NO
                                            disp:([object intValue] != 0)
                                           index:idx];
    } else if ([identifier compare:@"drawLock"] == NSOrderedSame) {
        // 編集可否
        cntl = [factory createLayerLockSetter:NO
                                         lock:([object intValue] != 0)
                                        index:idx];
    } else if ([identifier compare:@"name"] == NSOrderedSame) {
        // レイヤー名
        cntl = [factory createLayerNameSetter:NO
                                         name:object
                                        index:idx];
    }

    // 編集を実行
    [cntl execute];

    // 以前の選択レイヤーに戻す
    if ((cntl != nil) && (self->prevSelectRow_ >= 0)) {
        [table selectRowIndexes:[NSIndexSet indexSetWithIndex:self->prevSelectRow_]
           byExtendingSelection:NO];
        [self->selLayer_ setSel:((int)([table numberOfRows]) - self->prevSelectRow_ - 1)];
    }
    [cntl release];

    return;
}


//
// 移動の実行
//  独自追加 api
//
//  Call
//    table      : 対象
//    row        : 移動目標行
//    copy       : YES : 複写
//                 NO  : 移動
//    layerList_ : 一覧表(outlet)
//    docCntl_   : document controller(instance 変数)
//    selLayer_  : 選択中レイヤー情報(instance 変数)
//
//  Return
//    selLayer_ : 選択中レイヤー情報(instance 変数)
//
-(void)tableView:(NSTableView *)table
       moveToRow:(int)row
          isCopy:(BOOL)copy
{
    id  cntl;
    int cnt;
    int sel;

//    DPRINT((@"[PoCoLayerOperate tableView: moveToRow:%d isCopy:%s]\n", row, (copy) ? "YES" : "NO"));

    cnt = (int)([[[[self->docCntl_ currentDocument] picture] layer] count]);
    if (row >= cnt) {
        sel = 0;
    } else {
        sel = (cnt - row);
    }
    cntl = [[(PoCoAppController *)([NSApp delegate]) factory]
               createLayerMover:NO
                            src:[self->selLayer_ sel]
                         target:sel
                           copy:copy];
    if ([cntl execute]) {
        // 再描画の実行
        if (copy) {
            [self->layerList_ selectRowIndexes:[NSIndexSet indexSetWithIndex:(cnt - sel)]
                          byExtendingSelection:NO];
            [self->layerList_ scrollRowToVisible:(cnt - sel)];
        } else {
            if ([self->selLayer_ sel] < sel) {
                (sel)--;
            }
            [self->layerList_ selectRowIndexes:[NSIndexSet indexSetWithIndex:(cnt - sel - 1)]
                          byExtendingSelection:NO];
            [self->layerList_ scrollRowToVisible:(cnt - sel - 1)];
        }

        // 選択中レイヤーの切り替え
        [self->selLayer_ setSel:sel];
    } else {
        // 単に再描画だけしておく
        [table setNeedsDisplay:YES];
    }
    [cntl release];

    return;
}

@end
