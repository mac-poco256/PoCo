//
//	Pelistina on Cocoa - PoCo -
//	色置換設定パネル
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import "PoCoColorReplacePanel.h"

#import "PoCoMyDocument.h"
#import "PoCoPicture.h"
#import "PoCoPalette.h"
#import "PoCoColorReplaceColorView.h"

// 内部変数
static NSString *COLREP_SELRANGE = @"PoCoColorReplaceSelectionRange";

// ======================================================= PoCoColorReplacePair

// ------------------------------------------------------------------ interface
@interface PoCoColorReplacePair : NSObject
{
    int src_;                           // 置換元色番号
    int dst_;                           // 置換先色番号
}

// initialize
-(id)initWithSrc:(int)s
         withDst:(int)d;

// deallocate
-(void)dealloc;

// 取得
-(int)src;
-(int)dst;

// 表記文字列の取得
-(NSString *)srcString;
-(NSString *)dstString;

@end


// ------------------------------------------------------------- implementation
@implementation PoCoColorReplacePair

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    s : 変換元の色番号
//    d : 変換先の色番号
//
//  Return
//    function : 実体
//    src_     : 変換元の色番号(instance 変数)
//    dst_     : 変換先の色番号(instance 変数)
//
-(id)initWithSrc:(int)s
         withDst:(int)d
{
    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->src_ = s;
        self->dst_ = d;
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
    // super class を解放
    [super dealloc];

    return;
}


//
// 取得(変換元の色番号)
//
//  Call
//    src_ : 変換元の色番号(instance 変数)
//
//  Return
//    function : 値
//
-(int)src
{
    return self->src_;
}


//
// 取得(変換先の色番号)
//
//  Call
//    dst_ : 変換先の色番号(instance 変数)
//
//  Return
//    function : 値
//
-(int)dst
{
    return self->dst_;
}


//
// 変換元の表記文字列の取得
//
//  Call
//    src_ : 変換元の色番号(instance 変数)
//
//  Return
//    function : 文字列
//
-(NSString *)srcString
{
    PoCoColor *col = [[[[[NSDocumentController sharedDocumentController] currentDocument] picture] palette] palette:self->src_];

    return [NSString stringWithFormat:@"%3d:%02X-%02X-%02X", self->src_, [col red], [col green], [col blue]];
}


//
// 変換先の表記文字列の取得
//
//  Call
//    dst_ : 変換先の色番号(instance 変数)
//
//  Return
//    function : 文字列
//
-(NSString *)dstString
{
    PoCoColor *col = [[[[[NSDocumentController sharedDocumentController] currentDocument] picture] palette] palette:self->dst_];

    return [NSString stringWithFormat:@"%3d:%02X-%02X-%02X", self->dst_, [col red], [col green], [col blue]];
}

@end




// ============================================================================
@implementation PoCoColorReplacePanel

// ------------------------------------------------------------- class - public
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
    [dic setObject:[NSNumber numberWithInt:1]
            forKey:COLREP_SELRANGE];

    // default を設定
    [[NSUserDefaults standardUserDefaults] registerDefaults:dic];

    return;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    doc  : 編集対象
//    info : 編集情報
//
//  Return
//    function      : 実体
//    document_     : 編集対象(instance 変数)
//    editInfo_     : 編集情報(instance 変数)
//    isOk_         : 実行するか(instance 変数)
//    replaceTable_ : 置換データ群(instance 変数)
//
-(id)initWithDoc:(MyDocument *)doc
    withEditInfo:(PoCoEditInfo *)info
{
    DPRINT((@"[PoCoColorReplacePanel initWithDoc:]\n"));

    // super class の初期化
    self = [super initWithWindowNibName:@"PoCoColorReplacePanel"];

    // 自身の初期化
    if (self != nil) {
        self->isOk_ = NO;
        self->document_ = doc;
        self->editInfo_ = info;
        [self->document_ retain];
        [self->editInfo_ retain];

        // リストを生成
        self->replaceTable_ = [[NSMutableArray alloc] init];
        if (self->replaceTable_ == nil) {
            DPRINT((@"can't alloc replaceTable.\n"));
            [self release];
            self = nil;
            goto EXIT;
        }
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
//    document_     : 編集対象(instance 変数)
//    editInfo_     : 編集情報(instance 変数)
//    replaceTable_ : 置換データ群(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoColorReplacePanel dealloc]\n"));

    // 対情報を全て破棄
    [self->replaceTable_ removeAllObjects];

    // 資源の解放
    [self->document_ release];
    [self->editInfo_ release];
    [self->replaceTable_ release];
    self->replaceTable_ = nil;
    self->document_ = nil;
    self->editInfo_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 開始
//
//  Call
//    Nnoe
//
//  Return
//    rangeEdit_ : 範囲(outlet)
//
-(void)startWindow
{
    // 範囲の値を設定
    [self->rangeEdit_ setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:COLREP_SELRANGE]];

    // modal session 開始
    [NSApp runModalForWindow:[self window]];

    return;
}


// --------------------------------------------------- instance - public - 結果
//
// 実行するか
//
//  Call
//    isOk_ : 実行するか(instance 変数)
//
//  Return
//    function : 結果
//
-(BOOL)isOk
{
    return self->isOk_;
}


//
// 置換表
//
//  Call
//    replaceTable_ : 置換データ群(instance 変数)
//
//  Return
//    function : 置換表
//    matrix_  : 置換表(instance 変数)
//
-(const unsigned char *)matrix
{
    int l;
    NSEnumerator *iter;
    PoCoColorReplacePair *elm;

    // 置換表を初期化(配列添字と同じ値にする)
    for (l = 0; l < COLOR_MAX; (l)++) {
        self->matrix_[l] = l;
    }

    // 置換データ群の設定内容を反映
    iter = [self->replaceTable_ objectEnumerator];
    for (elm = [iter nextObject]; elm != nil; elm = [iter nextObject]) {
        if ([elm src] != [elm dst]) {
            self->matrix_[[elm src]] = [elm dst];
        }
    }

    return self->matrix_;
}


// ----------------------------------- instance - public - データソースメソッド
//
// 行数の取得
//
//  Call
//    table         : 対象(api 変数)
//    replaceTable_ : 置換データ群(instance 変数)
//
//  Return
//    function : 行数
//
-(int)numberOfRowsInTableView:(NSTableView *)table
{
    DPRINT((@"[PoCoPaletteReplaceView numberOfRowsInTableView]\n"));

    return (int)([self->replaceTable_ count]);
}


//
// 表示
//
//  Call
//    table  : 対象(api 変数)
//    column : 対象桁(api 変数)
//    row    : 対象行(api 変数)
//
//  Return
//    function : 表示内容
//
-(id)tableView:(NSTableView *)table
objectValueForTableColumn:(NSTableColumn *)column
                      row:(int)row
{
    NSString *identifier;
    PoCoColorReplacePair *pair;

    DPRINT((@"[PoCoPaletteReplaceView tableView: objectValueForTableColumn: row]\n"));

    // 識別子の取得
    identifier = [column identifier];

    // 対象行の内容の取得
    pair = [self->replaceTable_ objectAtIndex:row];

    return [pair valueForKey:identifier];
}


//
// 編集
//    編集不可なので何もしない
//
//  Call
//    table  : 対象(api 変数)
//    object : 編集内容(api 変数)
//    column : 対象桁(api 変数)
//    row    : 対象行(api 変数)
//
//  Return
//    None
//
-(void)tableView:(NSTableView *)table
  setObjectValue:(id)object
  forTableColumn:(NSTableColumn *)column
             row:(int)row
{
    DPRINT((@"[PoCoPaletteReplaceView tableView: setObjectValue: ForTableColumn: row]\n"));

    // 何もしない
    ;

    return;
}


// -------------------------------------------- instance - public - IBAction 系
//
// 追加
//
//  Call
//    sender      : 操作対象(api 変数)
//    colorList_  : 一覧表(outlet)
//    selectView_ : 色選択領域(outlet)
//    rangeEdit_  : 範囲(outlet)
//
//  Return
//    replaceTable_ : 置換データ群(instance 変数)
//
-(IBAction)addColor:(id)sender
{
    PoCoColorReplacePair *pair;
    int l;
    int s;
    int d;

    s = [self->selectView_ leftNum];
    d = [self->selectView_ rightNum];

    // 対情報を生成
    l = [self->rangeEdit_ intValue];
    while (l != 0) {
        pair = [[PoCoColorReplacePair alloc] initWithSrc:s
                                                 withDst:d];
        if (pair == nil) {
            DPRINT((@"can't alloc PoCoColorReplacePair.\n"));
        } else {
            // データ群末尾に追加
            [self->replaceTable_ addObject:pair];
            [pair release];
        }

        // 次へ
        if (l < 0) {
            (s)--;
            (d)--;
            (l)++;
            if (s < 0) {
                s = 0;
            }
            if (d < 0) {
                d = 0;
            }
        } else if (l > 0) {
            (s)++;
            (d)++;
            (l)--;
            if (s >= COLOR_MAX) {
                s = (COLOR_MAX - 1);
            }
            if (d >= COLOR_MAX) {
                d = (COLOR_MAX - 1);
            }
        }
    }

    // 一覧表を更新
    [self->colorList_ reloadData];

    return;
}


//
// 取り消し
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    None
//
-(IBAction)cancel:(id)sender
{
    // 閉じる
    [[self window] close];

    // modal session 終了
    [NSApp stopModal];

    return;
}


//
// 設定
//
//  Call
//    sender     : 操作対象(api 変数)
//    rangeEdit_ : 範囲(outlet)
//
//  Return
//    isOk_ : 実行するか(instance 変数)
//
-(IBAction)ok:(id)sender
{
    self->isOk_ = YES;

    // 範囲の設定を記憶
    [[NSUserDefaults standardUserDefaults] setInteger:[self->rangeEdit_ integerValue]
                                               forKey:COLREP_SELRANGE];

    // 閉じる
    [self cancel:sender];               // cancel の実装で閉じる

    return;
}


//
// 範囲
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    None
//
-(IBAction)rangeEdit:(id)sender
{
    // 何もしない
    ;

    return;
}

@end
