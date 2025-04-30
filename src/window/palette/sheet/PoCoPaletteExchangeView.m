//
//	Pelistina on Cocoa - PoCo -
//	パレット入れ替え設定領域
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoPaletteExchangeView.h"

#import "PoCoAppController.h"
#import "PoCoMyDocument.h"
#import "PoCoPicture.h"
#import "PoCoPalette.h"

// 内部定数
static  unsigned int SEL_SIZE = 8;      // 1要素の大きさ(dot 単位)(枠含む)
static  unsigned int H_MAX = 16;        // 水平要素数(個数)

// ============================================================================
@implementation PoCoPaletteExchangePair

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
-(id)initWithSrc:(int)s withDst:(int)d
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
@implementation PoCoPaletteExchangeView

// --------------------------------------------------------- instance - private
//
// 色番号から矩形領域変換
//
//  Call
//    num : 色番号
//
//  Return
//    function : 対象矩形領域
//
-(NSRect)numToRect:(int)num
{
    NSRect r;

    r.origin.x = (float)((num % H_MAX) * SEL_SIZE);
    r.origin.y = (float)((num / H_MAX) * SEL_SIZE);
    r.size.width = (float)(SEL_SIZE);
    r.size.height = (float)(SEL_SIZE);

    return r;
}


//
// 選択の更新
//
//  Call
//    num : 選択番号
//    evt : 取得イベント
//
//  Return
//    function : 選択番号
//
-(int)selColor:(int)num
         event:(NSEvent *)evt
{
    const int oldNum = num;
    const NSPoint p = [PoCoPoint corrNSPoint:[self convertPoint:[evt locationInWindow] fromView:nil]];

    if ([self mouse:p inRect:[self bounds]]) {
        // 選択番号を取得
        num = ((int)(p.x) / SEL_SIZE) + (((int)(p.y) / SEL_SIZE) * H_MAX);

        // 切り替えた場合は再描画を発行
        if (oldNum != num) {
            [self setNeedsDisplayInRect:[self numToRect:oldNum]];
            [self setNeedsDisplayInRect:[self numToRect:num]];
        }
    }

    return num;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//   
//  Call
//    frameRect : 矩形領域(api 変数)
//     
//  Return
//    function       : 実体
//    leftNum_       : 主ボタンでの設定値(instance変数)
//    rightNum_      : 右ボタンでの設定値(instance変数)
//    exchangeTable_ : 交換データ群(instance変数)
//    docCntl_       : document controller(instance変数)
//
-(id)initWithFrame:(NSRect)frameRect;
{
    DPRINT((@"[PoCoPaletteExchangeView initWithFrame]\n"));

    // super class の初期化
    self = [super initWithFrame:frameRect];

    // 自身の初期化
    if (self != nil) {
        self->leftNum_ = 0;
        self->rightNum_ = 0;
        self->exchangeTable_ = nil;
        self->docCntl_ = nil;

        // リストを生成
        self->exchangeTable_ = [[NSMutableArray alloc] init];
        if (self->exchangeTable_ == nil) {
            DPRINT((@"can't alloc exchangeTable.\n"));
            [self release];
            self = nil;
            goto EXIT;
        }

        // document controller を取得
        self->docCntl_ = [NSDocumentController sharedDocumentController];
        [self->docCntl_ retain];
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
//    exchangeTable_ : 交換データ群(instance 変数)
//    docCntl_       : document controller(instance変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoPaletteExchangeView dealloc]\n"));

    // 対情報を全て破棄
    [self->exchangeTable_ removeAllObjects];

    // 資源を解放
    [self->exchangeTable_ release];
    [self->docCntl_ release];
    self->exchangeTable_ = nil;
    self->docCntl_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// 表示要求
//
//  Call
//    rect      : 表示領域(api 変数)
//    leftNum_  : 主ボタンでの設定値(instance 変数)
//    rightNum_ : 右ボタンでの設定値(instance 変数)
//
//  Return
//    None
//
-(void)drawRect:(NSRect)rect
{
    int l;

    DPRINT((@"[PoCoPaletteExchangeView drawRect]\n"));

    for (l = 0; l < COLOR_MAX; (l)++) {
        if (NSIntersectsRect(rect, [self numToRect:l])) {
            [self drawColor:l
                   isSelect:((l == self->leftNum_) || (l == self->rightNum_))
                     isDown:(l == self->rightNum_)];
        }
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
// 設定を初期化
//
//  Call
//    colorList_     : 一覧表(outlet)
//    exchangeTable_ : 交換データ群(instance 変数)
//
//  Return
//    exchangeTable_ : 交換データ群(instance 変数)
//
-(void)setUp
{
    // 対情報を全て破棄
    [self->exchangeTable_ removeAllObjects];

    // 一覧表を初期化
    [self->colorList_ reloadData];

    return;
}


//
// 一覧表の取得
//
//  Call
//    exchangeTable_ : 交換データ群(instance 変数)
//
//  Return
//    function : データ群
//
-(NSMutableArray *)exchangeTable
{
    return self->exchangeTable_;
}


//
// 1色分の描画
//
//  Call
//    num      : 番号
//    sel      : YES : 選択中表示
//               NO  : 非選択中表示
//    down     : YES : 下がり表示
//               NO  : 上がり表示
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)drawColor:(int)num
        isSelect:(BOOL)sel
          isDown:(BOOL)down
{
    NSRect  r;
    const PoCoPalette *plt = [[[self->docCntl_ currentDocument] picture] palette];
    const PoCoColor *col = [plt palette:num];

    if (col != nil) {
        // 座標を算出
        r = [self numToRect:num];

        // 選択中なら枠をつける
        if (sel) {
            if (down) {
                [[NSColor blackColor] set];
            } else {
                [[NSColor whiteColor] set];
            }
            [NSBezierPath fillRect:r];
            (r.origin.x)++;
            (r.origin.y)++;
            (r.size.width)--;
            (r.size.height)--;
            if (down) {
                [[NSColor whiteColor] set];
            } else {
                [[NSColor blackColor] set];
            }
            [NSBezierPath fillRect:r];
            (r.size.width)--;
            (r.size.height)--;
        }

        // 色を描画
        [[NSColor colorWithCalibratedRed:[col floatRed]
                                   green:[col floatGreen]
                                    blue:[col floatBlue]
                                   alpha:(float)(1.0)] set];
        [NSBezierPath fillRect:r];
    }

    return;
}


// -------------------------------------------- instance - public - IBAction 系
//
// 追加
//
//  Call
//    sender     : 操作対象(api 変数)
//    colorList_ : 一覧表(outlet)
//    leftNum_   : 主ボタンでの設定値(instance 変数)
//    rightNum_  : 右ボタンでの設定値(instance 変数)
//
//  Return
//    exchangeTable : 交換データ群(instance 変数)
//
-(IBAction)addColor:(id)sender
{
    PoCoPaletteExchangePair *pair;

    // 対情報を生成
    pair = [[PoCoPaletteExchangePair alloc] initWithSrc:self->leftNum_
                                                withDst:self->rightNum_];
    if (pair == nil) {
        DPRINT((@"can't alloc PoCoPaletteExchangePair.\n"));
    } else {
        // データ群末尾に追加
        [self->exchangeTable_ addObject:pair];
        [pair release];

        // 一覧表を更新
        [self->colorList_ reloadData];
    }

    return;
}


// ----------------------------------- instance - public - データソースメソッド
//
// 行数の取得
//
//  Call
//    table          : 対象(api 変数)
//    exchangeTable_ : 交換データ群(instance 変数)
//
//  Return
//    function : 行数
//
-(int)numberOfRowsInTableView:(NSTableView *)table
{
    DPRINT((@"[PoCoPaletteExchangeView numberOfRowsInTableView]\n"));

    return (int)([self->exchangeTable_ count]);
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
    PoCoPaletteExchangePair *pair;

    DPRINT((@"[PoCoPaletteExchangeView tableView: objectValueForTableColumn: row]\n"));

    // 識別子の取得
    identifier = [column identifier];

    // 対象行の内容の取得
    pair = [self->exchangeTable_ objectAtIndex:row];

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
    DPRINT((@"[PoCoPaletteExchangeView tableView: setObjectValue: ForTableColumn: row]\n"));

    // 何もしない
    ;

    return;
}


// ----------------------------------------- instance - public - イベント処理系
//
// ボタンダウン処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    leftNum_ : 主ボタンでの設定値(instance 変数)
//
-(void)mouseDown:(NSEvent *)evt
{
    self->leftNum_ = [self selColor:self->leftNum_
                              event:evt];

    return;
}


//
// ドラッグ処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    leftNum_ : 主ボタンでの設定値(instance 変数)
//
-(void)mouseDragged:(NSEvent *)evt
{
    self->leftNum_ = [self selColor:self->leftNum_
                              event:evt];

    return;
}


//
// 右ボタンダウン処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    rightNum_ : 右ボタンでの設定値(instance 変数)
//
-(void)rightMouseDown:(NSEvent *)evt
{
    self->rightNum_ = [self selColor:self->rightNum_
                               event:evt];

    return;
}


//
// 右ボタンドラッグ処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    rightNum_ : 右ボタンでの設定値(instance 変数)
//
-(void)rightMouseDragged:(NSEvent *)evt
{
    self->rightNum_ = [self selColor:self->rightNum_
                               event:evt];

    return;
}

@end
