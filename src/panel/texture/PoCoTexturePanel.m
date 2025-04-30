//
//	Pelistina on Cocoa - PoCo -
//	テクスチャ設定パネル
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import "PoCoTexturePanel.h"

#import "PoCoMyDocument.h"
#import "PoCoPicture.h"
#import "PoCoPalette.h"
#import "PoCoTextureColorView.h"

// 内部変数
static NSString *TEXTURE_HSELRANGE = @"PoCoTextureHoriSelectionRange";
static NSString *TEXTURE_VSELRANGE = @"PoCoTextureVertSelectionRange";

// ============================================================================
@implementation PoCoTexturePanel

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
            forKey:TEXTURE_HSELRANGE];
    [dic setObject:[NSNumber numberWithInt:1]
            forKey:TEXTURE_VSELRANGE];

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
//    function  : 実体
//    document_ : 編集対象(instance 変数)
//    editInfo_ : 編集情報(instance 変数)
//    isOk_     : 実行するか(instance 変数)
//    base_     : texture の基本色(instance 変数)
//    gradient_ : 濃淡色(instance 変数)
//
-(id)initWithDoc:(MyDocument *)doc
    withEditInfo:(PoCoEditInfo *)info
{
    DPRINT((@"[PoCoTexturePanel initWithDoc:]\n"));

    // super class の初期化
    self = [super initWithWindowNibName:@"PoCoTexturePanel"];

    // 自身の初期化
    if (self != nil) {
        self->isOk_ = NO;
        self->base_ = nil;
        self->gradient_ = nil;
        self->document_ = doc;
        self->editInfo_ = info;
        [self->document_ retain];
        [self->editInfo_ retain];

        // リストを生成
        self->base_ = [[NSMutableArray alloc] init];
        if (self->base_ == nil) {
            DPRINT((@"can't alloc base colors table.\n"));
            [self release];
            self = nil;
            goto EXIT;
        }
        self->gradient_ = [[NSMutableArray alloc] init];
        if (self->gradient_ == nil) {
            DPRINT((@"can't alloc gradient colors table.\n"));
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
//    document_ : 編集対象(instance 変数)
//    editInfo_ : 編集情報(instance 変数)
//    base_     : texture の基本色(instance 変数)
//    gradient_ : 濃淡色(instance 変数)
//
-(void)dealloc
{
    NSEnumerator *iter;
    PoCoBaseGradientPair *obj;

    DPRINT((@"[PoCoTexturePanel dealloc]\n"));

    // 情報を全て破棄
    iter = [self->gradient_ objectEnumerator];
    for (obj = [iter nextObject]; obj != nil; obj = [iter nextObject]) {
        [(NSMutableArray *)([obj colors]) removeAllObjects];
    }
    [self->gradient_ removeAllObjects];
    [self->base_ removeAllObjects];

    // 資源の解放
    [self->document_ release];
    [self->editInfo_ release];
    [self->base_ release];
    [self->gradient_ release];
    self->document_ = nil;
    self->editInfo_ = nil;
    self->base_ = nil;
    self->gradient_ = nil;

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
//    horiRangeEdit_ : 水平範囲(濃淡色の範囲用)(outlet)
//    vertRangeEdit_ : 垂直範囲(基本色の範囲用)(outlet)
//
-(void)startWindow
{
    // 範囲の値を設定
    [self->horiRangeEdit_ setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:TEXTURE_HSELRANGE]];
    [self->vertRangeEdit_ setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:TEXTURE_VSELRANGE]];

    [self->gradientView_ setHoriRange:(int)([[NSUserDefaults standardUserDefaults] integerForKey:TEXTURE_HSELRANGE])];
    [self->baseView_     setVertRange:(int)([[NSUserDefaults standardUserDefaults] integerForKey:TEXTURE_VSELRANGE])];
    [self->replaceView_  setHoriRange:(int)([[NSUserDefaults standardUserDefaults] integerForKey:TEXTURE_HSELRANGE])
                         andVertRange:(int)([[NSUserDefaults standardUserDefaults] integerForKey:TEXTURE_VSELRANGE])];

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
// texture の基本色
//
//  Call
//    base_ : texture の基本色(instance 変数)
//
//  Return
//    function : texture の基本色
//
-(NSArray *)base
{
    return (NSArray *)(self->base_);
}


//
// 濃淡色
//
//  Call
//    gradient_ : 濃淡色(instance 変数)
//
//  Return
//    function : 濃淡色
//
-(NSArray *)gradient
{
    return (NSArray *)(self->gradient_);
}


// -------------------------------------------- instance - public - IBAction 系
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
//    sender         : 操作対象(api 変数)
//    baseView_      : texture の基本色選択領域(outlet)
//    gradientView_  : 濃淡色選択領域(outlet)
//    replaceView_   : 置換色選択領域(outlet)
//    horiRangeEdit_ : 水平範囲(濃淡色の範囲用)(outlet)
//    vertRangeEdit_ : 垂直範囲(基本色の範囲用)(outlet)
//
//  Return
//    isOk_ : 実行するか(instance 変数)
//    base_     : texture の基本色(instance 変数)
//    gradient_ : 濃淡色(instance 変数)
//
-(IBAction)ok:(id)sender
{
    const int hori = (int)([self->horiRangeEdit_ integerValue]);
    const int vert = (int)([self->vertRangeEdit_ integerValue]);
    int val1;
    int val2;
    int cnt1;
    int cnt2;
    PoCoBaseGradientPair *pair;
    NSMutableArray *cl;

    // texture の基本色を取得
    val1 = [self->baseView_ topIndex];
    for (cnt1 = 0; cnt1 < vert; (cnt1)++) {
        // 基本色をリストに登録
        [self->base_ addObject:[NSNumber numberWithInt:val1]];

        // 次へ
        if ((val1 + 16) < COLOR_MAX) {
            val1 += 16;
        }
    }

    // 濃淡色を取得
    val1 = [self->gradientView_ topIndex];
    for (cnt1 = 0; cnt1 < hori; (cnt1)++) {
        cl = [[NSMutableArray alloc] init];
        val2 = [self->replaceView_ topIndex];
        if ((val2 + cnt1) < COLOR_MAX) {
            val2 += cnt1;
        }
        for (cnt2 = 0; cnt2 < vert; (cnt2)++) {
            // 置換色をリストに登録
            [cl addObject:[NSNumber numberWithInt:val2]];

            // 次へ
            if ((val2 + 16) < COLOR_MAX) {
                val2 += 16;
            }
        }

        // 濃淡と置換色群のペアを生成
        pair = [[PoCoBaseGradientPair alloc] init:(unsigned int)(val1)
                                           colors:(NSArray *)(cl)];

        // ペアをリストに登録
        [self->gradient_ addObject:pair];
        [cl release];
        [pair release];

        // 次へ
        if ((val1 + 16) < COLOR_MAX) {
            (val1)++;
        }
    }
#if 0
{
  int i1;
  int i2;

  printf("\n");
  printf("\n");
  printf("\n");
  printf("\n");
  printf("--------base colors\n");
  for (i1 = 0; i1 < [self->base_ count]; (i1)++) {
    printf("%3d, ", [(NSNumber *)([self->base_ objectAtIndex:i1]) intValue]);
  }
  printf("\n");

  printf("--------pair colors\n");
  for (i1 = 0; i1 < [self->gradient_ count]; (i1)++) {
    printf("%3d : ", [(PoCoBaseGradientPair *)([self->gradient_ objectAtIndex:i1]) base]);
    for (i2 = 0; i2 < [[(PoCoBaseGradientPair *)([self->gradient_ objectAtIndex:i1]) colors] count]; (i2)++) {
      printf("%3d, ", [(NSNumber *)([[(PoCoBaseGradientPair *)([self->gradient_ objectAtIndex:i1]) colors] objectAtIndex:i2]) intValue]);
    }
    printf("\n");
  }
}
#endif  // 0

    // 実行で抜ける
    self->isOk_ = YES;

    // 範囲の設定を記憶
    [[NSUserDefaults standardUserDefaults] setInteger:[self->horiRangeEdit_ integerValue]
                                               forKey:TEXTURE_HSELRANGE];
    [[NSUserDefaults standardUserDefaults] setInteger:[self->vertRangeEdit_ integerValue]
                                               forKey:TEXTURE_VSELRANGE];

    // 閉じる
    [self cancel:sender];               // cancel の実装で閉じる

    return;
}


//
// 水平範囲
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    gradientView_ : 濃淡色選択領域(outlet)
//    replaceView_  : 置換色選択領域(outlet)
//
-(IBAction)horiRangeEdit:(id)sender
{
    // 水平連続数の指定を色選択領域に反映
    [self->gradientView_ setHoriRange:(int)([sender integerValue])];
    [self->replaceView_ setHoriRange:(int)([sender integerValue])];

    return;
}


//
// 垂直範囲
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    baseView_    : texture の基本色選択領域(outlet)
//    replaceView_ : 置換色選択領域(outlet)
//
-(IBAction)vertRangeEdit:(id)sender
{
    // 垂直連続数の指定を色選択領域に反映
    [self->baseView_ setVertRange:(int)([sender integerValue])];
    [self->replaceView_ setVertRange:(int)([sender integerValue])];

    return;
}

@end
