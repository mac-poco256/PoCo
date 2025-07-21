//
// PoCoAutoGradationPanel.m
// implementation of classes with relation to auto gradient setting.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoAutoGradationPanel.h"

#import "PoCoMyDocument.h"
#import "PoCoPicture.h"
#import "PoCoLayer.h"
#import "PoCoPalette.h"
#import "PoCoAutoGradationColorView.h"
#import "PoCoAutoGradationSizePairOperate.h"

// 内部変数
static NSString *DEFAULT_ADJACENT = @"PoCoAutoGradationDefaultAdjacent";
static NSString *DEFAULT_AUTO = @"PoCoAutoGradationDefaultAuto";

// ============================================================================

// ----------------------------------------------------------------------------
// interface.

@interface PoCoAutoGradationAdjacentInitialize : NSObject
{
    // 生成物
    NSMutableDictionary *pair_;

    // 条件
    const BOOL *matrix_;
    PoCoBitmap *image_;
    PoCoBitmap *shape_;
    int size_;

    // 中間状態
    int beginIndex_;                    // 色番号([beginIndex_, endIndex_])
    int endIndex_;                      // 色番号([beginIndex_, endIndex_])
    unsigned int counts_[COLOR_MAX];    // 色ごとの個数
    unsigned int full_;                 // 全ドット数
    int maxIndex_;                      // 個数が最大の色番号
}

// initialize
-(id)initWithDictionary:(NSMutableDictionary *)dict
             withMatrix:(const BOOL *)matrix
              withImage:(PoCoBitmap *)image
              withShape:(PoCoBitmap *)shape
            defaultSize:(int)size;

// deallocate
-(void)dealloc;

// 実行
-(void)createFlatState;
-(void)countupColor;
-(void)distributeSizeForForward;
-(void)distributeSizeForBackword;

@end


// ----------------------------------------------------------------------------
// implementation.

@implementation PoCoAutoGradationAdjacentInitialize


// ----------------------------------------------------------------------------
// instance - public.

//
// initialize
//
//  Call
//    dict   : 色と大きさの対群
//    matrix : 対象色(256 固定配列)
//    image  : 対象画像
//    shape  : 形状
//    size   : 初期サイズ(1-16)
//
//  Return
//    function    : 実体
//    pair_       : 色と大きさの対群(instance 変数)
//    matrix_     : 対象色(256 固定配列)(instance 変数)
//    image_      : 対象画像(instance 変数)
//    shape_      : 形状(instance 変数)
//    size_       : 初期サイズ(1-16)(instance 変数)
//    beginIndex_ : 色番号([beginIndex_, endIndex_])(instance 変数)
//    endIndex_   : 色番号([beginIndex_, endIndex_])(instance 変数)
//    counts_     : 色ごとの個数(instance 変数)
//    full_       : 全ドット数(instance 変数)
//    maxIndex_   : 個数が最大の色番号(instance 変数)
//
-(id)initWithDictionary:(NSMutableDictionary *)dict
             withMatrix:(const BOOL *)matrix
              withImage:(PoCoBitmap *)image
              withShape:(PoCoBitmap *)shape
            defaultSize:(int)size
{
    // super class へ回送
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->pair_ = dict;
        self->matrix_ = matrix;
        self->image_ = image;
        self->shape_ = shape;
        self->size_ = size;
        self->beginIndex_ = -1;
        self->endIndex_ = -1;
        memset(self->counts_, 0x00, (COLOR_MAX * sizeof(unsigned int)));
        self->maxIndex_ = -1;
        [self->pair_ retain];
        [self->image_ retain];
        [self->shape_ retain];
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
//    pair_  : 色と大きさの対群(instance 変数)
//    image_ : 対象画像(instance 変数)
//    shape_ : 形状(instance 変数)
//
-(void)dealloc
{
    // 資源を解放
    [self->pair_ release];
    [self->image_ release];
    [self->shape_ release];
    self->pair_ = nil;
    self->image_ = nil;
    self->shape_ = nil;

    // super class へ回送
    [super dealloc];

    return;
}


// ----------------------------------------------------------------------------
// instance - public - execution.

//
// 均一状態を生成
//  すべての対を生成し、名称登録する(この後の処理は名称で問い合わせること)
//  対象色の数と範囲の抽出も行う
//
//  Call
//    matrix_ : 対象色(256 固定配列)(instance 変数)
//    size_   : 初期サイズ(1-16)(instance 変数)
//
//  Return
//    pair_       : 色と大きさの対群(instance 変数)
//    beginIndex_ : 色番号([beginIndex_, endIndex_])(instance 変数)
//    endIndex_   : 色番号([beginIndex_, endIndex_])(instance 変数)
//
-(void)createFlatState
{
    int idx;
    PoCoGradationPairInfo *tmp;

    // 範囲を探す
    for (idx = 0; idx < COLOR_MAX; (idx)++) {
        if (self->matrix_[idx]) {
            // 最初に達したものなら始点として記憶
            if (self->beginIndex_ < 0) {
                self->beginIndex_ = idx;
            }
        } else {
            // 始点がある状態で対象外なら終点として記憶
            if (self->beginIndex_ >= 0) {
                self->endIndex_ = (idx - 1);
                break;
            }
        }
    }

    // 始点しかない場合は最後までが対象範囲だった
    if ((self->beginIndex_ >= 0) && (self->endIndex_ < 0)) {
        self->endIndex_ = COLOR_MAX;
    }

    // 矛盾する結果なら無視
    if (self->endIndex_ <= self->beginIndex_) {
        goto EXIT;
    }

    // すべて同じサイズの指定で対を生成
    for (idx = self->beginIndex_; idx < self->endIndex_; (idx)++) {
        // 上り方向
        tmp = [[PoCoGradationPairInfo alloc] initWithFirst:(unsigned int)(idx)
                                                withSecond:(unsigned int)(idx + 1)
                                                  withSize:(self->size_ * 8)];
        [self->pair_ setValue:tmp
                       forKey:[tmp name]];
        [tmp release];

        // 下り方向
        tmp = [[PoCoGradationPairInfo alloc] initWithFirst:(unsigned int)(idx + 1)
                                                withSecond:(unsigned int)(idx)
                                                  withSize:(self->size_ * 8)];
        [self->pair_ setValue:tmp
                       forKey:[tmp name]];
        [tmp release];
    }

EXIT:
    return;
}


//
// ドット数の数え上げ
//
//  Call
//    matrix_ : 対象色(256 固定配列)(instance 変数)
//    image_  : 対象画像(instance 変数)
//    shape_  : 形状(instance 変数)
//
//  Return
//    counts_   : 色ごとの個数(instance 変数)
//    full_     : 全ドット数(instance 変数)
//    maxIndex_ : 個数が最大の色番号(instance 変数)
//
-(void)countupColor
{
    int w;
    int h;
    unsigned char *ibmp;
    unsigned char *sbmp;
    int skip;

    ibmp = [self->image_ pixelmap];
    sbmp = [self->shape_ pixelmap];
    skip = ([self->image_ width] & 0x01);
    h = [self->image_ height];
    do {
        w = [self->image_ width];
        do {
            if (*(sbmp) != 0) {
                // そのまま計上
                (self->full_)++;
                if (self->matrix_[*(ibmp)]) {
                    // 対象色のみ対象とする
                    (self->counts_[*(ibmp)])++;

                    // 個数が最大のものを更新
                    if ((self->maxIndex_ < 0) ||
                        (self->counts_[self->maxIndex_] < self->counts_[*(ibmp)])) {
                        self->maxIndex_ = *(ibmp);
                    }
                }
            }

            // 次へ
            (w)--;
            (ibmp)++;
            (sbmp)++;
        } while (w != 0);

        // 次へ
        (h)--;
        ibmp += skip;
        sbmp += skip;
    } while (h != 0);

    return;
}


//
// 上り方向の色分配
//  ドット数に応じたサイズを割り振る
//   (ここでのサイズは 1-128 の範囲となる)
//
//  Call
//    pair_       : 色と大きさの対群(instance 変数)
//    size_       : 初期サイズ(1-16)(instance 変数)
//    beginIndex_ : 色番号([beginIndex_, endIndex_])(instance 変数)
//    endIndex_   : 色番号([beginIndex_, endIndex_])(instance 変数)
//    counts_     : 色ごとの個数(instance 変数)
//    full_       : 全ドット数(instance 変数)
//    maxIndex_   : 個数が最大の色番号(instance 変数)
//
//  Return
//    pair_ : 色と大きさの対群(instance 変数)
//
-(void)distributeSizeForForward
{
    int idx;
    PoCoGradationPairInfo *info;

    if (self->size_ > 4) {
        for (idx = self->beginIndex_; idx < self->endIndex_; (idx)++) {
            info = [self->pair_ objectForKey:[PoCoGradationPairInfo pairString:(unsigned int)(idx)
                                                                    withSecond:(unsigned int)(idx + 1)]];
            [info setSize:(8 * MAX(4, (unsigned int)(self->size_ * ((float)(self->counts_[idx + 1]) / (float)(self->counts_[self->maxIndex_])))))];
        }
    }

    return;
}


//
// 下り方向の色分配
//  ドット数に応じたサイズを割り振る
//   (ここでのサイズは 1-128 の範囲となる)
//
//  Call
//    pair_       : 色と大きさの対群(instance 変数)
//    size_       : 初期サイズ(1-16)(instance 変数)
//    beginIndex_ : 色番号([beginIndex_, endIndex_])(instance 変数)
//    endIndex_   : 色番号([beginIndex_, endIndex_])(instance 変数)
//    counts_     : 色ごとの個数(instance 変数)
//    full_       : 全ドット数(instance 変数)
//    maxIndex_   : 個数が最大の色番号(instance 変数)
//
//  Return
//    pair_ : 色と大きさの対群(instance 変数)
//
-(void)distributeSizeForBackword
{
    int idx;
    PoCoGradationPairInfo *info;

    if (self->size_ > 4) {
        for (idx = self->endIndex_; idx > self->beginIndex_; (idx)--) {
            info = [self->pair_ objectForKey:[PoCoGradationPairInfo pairString:(unsigned int)(idx)
                                                                    withSecond:(unsigned int)(idx - 1)]];
            [info setSize:(8 * MAX(4, (unsigned int)(self->size_ * ((float)(self->counts_[idx - 1]) / (float)(self->counts_[self->maxIndex_])))))];
        }
    }

    return;
}

@end




// ============================================================================
@implementation PoCoAutoGradationPanel

// ----------------------------------------------------------------------------
// class - public.

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
    [dic setObject:[NSNumber numberWithBool:YES]
            forKey:DEFAULT_ADJACENT];
    [dic setObject:[NSNumber numberWithInt:0]
            forKey:DEFAULT_AUTO];

    // default を設定
    [[NSUserDefaults standardUserDefaults] registerDefaults:dic];

    return;
}


// ----------------------------------------------------------------------------
// instance - private.

//
// 色と大きさの対群の初期値を生成
//  ここで生成する初期値は隣接が成立している前提(verify に合格した場合のみ)
//
//  Call
//    selectView_ : 色選択領域(outlet)
//    sizeSlider_ : サイズ(手動用)(outlet)
//    image_      : 対象画像(instance 変数)
//    shape_      : 形状(instance 変数)
//
//  Return
//    sizePair_ : 色と大きさの対群(instance 変数)
//
-(void)createSizePair
{
    PoCoAutoGradationAdjacentInitialize *work;

    work = nil;

    // 実体が無い場合にのみ初期値を生成する
    if (self->sizePair_ != nil) {
        goto EXIT;
    }

    // 最初は均一の大きさで登録
    self->sizePair_ = [[NSMutableDictionary alloc] init];
    work = [[PoCoAutoGradationAdjacentInitialize alloc] initWithDictionary:self->sizePair_
                                                                withMatrix:[self->selectView_ matrix]
                                                                 withImage:self->image_
                                                                 withShape:self->shape_
                                                               defaultSize:[self->sizeSlider_ intValue]];
    [work createFlatState];

    // 対象領域内の各色ごとのドット数を数え上げる
    [work countupColor];

    // ドット数に応じて上り方向の大きさを分配
    [work distributeSizeForForward];

    // 同じく下り方向の大きさを分配
    [work distributeSizeForBackword];

EXIT:
    [work release];
    return;
}


// ----------------------------------------------------------------------------
// instance - public.

//
// initialize
//
//  Call
//    doc   : 編集対象
//    info  : 編集情報
//    image : 対象画像
//    shape : 形状
//
//  Return
//    function  : 実体
//    document_ : 編集対象(instance 変数)
//    editInfo_ : 編集情報(instance 変数)
//    image_    : 対象画像(instance 変数)
//    shape_    : 形状(instance 変数)
//    isOk_     : 実行するか(instance 変数)
//    sizePair_ : 色と大きさの対群(instance 変数)
//
-(id)initWithDoc:(MyDocument *)doc
    withEditInfo:(PoCoEditInfo *)info
       withImage:(PoCoBitmap *)image
       withShape:(PoCoBitmap *)shape
{
    DPRINT((@"[PoCoAutoGradationPanel initWithDoc:]\n"));

    // super class の初期化
    self = [super initWithWindowNibName:@"PoCoAutoGradationPanel"];

    // 自身の初期化
    if (self != nil) {
        self->isOk_ = NO;
        self->document_ = doc;
        self->editInfo_ = info;
        self->image_ = image;
        self->shape_ = shape;
        self->sizePair_ = nil;
        [self->document_ retain];
        [self->editInfo_ retain];
        [self->image_ retain];
        [self->shape_ retain];
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
//    document_ : 編集対象(instance 変数)
//    editInfo_ : 編集情報(instance 変数)
//    image_    : 対象画像(instance 変数)
//    shape_    : 形状(instance 変数)
//    sizePair_ : 色と大きさの対群(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoAutoGradationPanel dealloc]\n"));

    // 資源の解放
    [self->document_ release];
    [self->editInfo_ release];
    [self->image_ release];
    [self->shape_ release];
    [self->sizePair_ release];
    self->document_ = nil;
    self->editInfo_ = nil;
    self->image_ = nil;
    self->shape_ = nil;
    self->sizePair_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 開始
//
//  Call
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    selectView_ : 色選択領域(outlet)
//    adjacent_   : 隣接(outlet)
//    manual_     : 手動(outlet)
//    auto_       : 自動(outlet)
//    pair_       : 対ごと(outlet)
//    sizeSlider_ : サイズ(手動用)(outlet)
//    sizeDetail_ : サイズ詳細(対ごと用)(outlet)
//
-(void)startWindow
{
    // サイズ
    [self->sizeSlider_ setIntValue:[self->editInfo_ penSize]];

    // 隣接
    [self->adjacent_ setState:[[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_ADJACENT]];

    // 対象色は初期値に戻すの実装で初期化
    [self defaultSelect:nil];

    // サイズの指定
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:DEFAULT_AUTO]) {
        case 2:
            // 対ごと
            if (([[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_ADJACENT]) && ([self->selectView_ verifyContinuous])) {
                [self->manual_ setState:0];
                [self->auto_ setState:0];
                [self->pair_ setState:1];
                [self->sizeSlider_ setEnabled:YES];
                [self->sizeDetail_ setEnabled:YES];

                // 初期値を生成
                [self createSizePair];
                break;
            }
            ;   // 通過
        default:
        case 0:
            // 手動
            [self->manual_ setState:1];
            [self->auto_ setState:0];
            [self->pair_ setState:0];
            [self->sizeSlider_ setEnabled:YES];
            [self->sizeDetail_ setEnabled:NO];
            break;
        case 1:
            // 自動
            [self->manual_ setState:0];
            [self->auto_ setState:1];
            [self->pair_ setState:0];
            [self->sizeSlider_ setEnabled:NO];
            [self->sizeDetail_ setEnabled:NO];
            break;
    }

    // modal session 開始
    [NSApp runModalForWindow:[self window]];

    return;
}


//
// 妥当性評価
//
//  Call
//    selectView_ : 色選択領域(outlet)
//    adjacent_   : 隣接(outlet)
//
//  Return
//    exec_       : 実行(outlet)
//    pair_       : 対ごと(outlet)
//    sizeDetail_ : サイズ詳細(対ごと用)(outlet)
//
-(void)verifySetting
{
    if ([self->adjacent_ state] != 0) {
        // 隣接の場合は実行の可否と対ごとの指定の可否を切り替える
        if ([self->selectView_ verifyContinuous]) {
            [self->exec_ setEnabled:YES];
            [self->pair_ setEnabled:YES];
        } else {
            [self->exec_ setEnabled:NO];
            [self->pair_ setEnabled:NO];
        }
    } else {
        // 隣接ではない場合は実行の可否のみ
        if ([self->selectView_ verifySelectExist]) {
            [self->exec_ setEnabled:YES];
        } else {
            [self->exec_ setEnabled:NO];
        }

        // 対ごとの指定はできない
        [self->pair_ setEnabled:NO];
        [self->sizeDetail_ setEnabled:NO];
        if ([self->pair_ state] != 0) {
            [self->manual_ setState:1];
            [self->pair_ setState:0];
        }
    }

    return;
}


// ----------------------------------------------------------------------------
// instance - public - getter (to retrieve the results).

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
// サイズ
//
//  Call
//    auto_       : 自動(outlet)
//    sizeSlider_ : サイズ(outlet)
//
//  Return
//    function : サイズ
//
-(int)penSize
{
    return (([self->auto_ state] != 0) ? 0 : ([self->sizeSlider_ intValue] * 8));
}


//
// 隣接
//
//  Call
//    adjacent_ : 隣接(outlet)
//
//  Return
//    function : 隣接
//
-(BOOL)isAdjacent
{
    return ([self->adjacent_ state] != 0);
}


//
// 対象色
//
//  Call
//    selectView_ : 色選択領域(outlet)
//
//  Return
//    function : 対象色
//
-(const BOOL *)matrix
{
    return [self->selectView_ matrix];
}


//
// 色と大きさの対群
//
//  Call
//    pair_     : 対ごと(outlet)
//    sizePair_ : 色と大きさの対群(instance 変数)
//
//  Return
//    function : 設定内容
//
-(NSDictionary *)sizePair
{
    return (([self->pair_ state] != 0) ? (NSDictionary *)(self->sizePair_) : nil);
}


// ----------------------------------------------------------------------------
// instance - public - IBActions.

//
// 色選択
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    None
//
-(IBAction)colorSelect:(id)sender
{
    // 妥当性評価
    [self verifySetting];

    return;
}


//
// 初期値に戻す
//
//  Call
//    sender    : 操作対象(api 変数)
//    document_ : 編集対象(instance 変数)
//    editInfo_ : 編集情報(instance 変数)
//    image_    : 対象画像(instance 変数)
//    shape_    : 形状(instance 変数)
//
//  Return
//    selectView_ : 色選択領域(outlet)
//
-(IBAction)defaultSelect:(id)sender
{
    int l;
    BOOL flag;
    PoCoColor *col;
    int w;
    int h;
    unsigned char *ibmp;
    unsigned char *sbmp;
    int skip;
    BOOL indeed[COLOR_MAX];

    // 対象画像を走査して実際に使用中の色のみに限定する
    if ((self->image_ == nil) || (self->shape_ == nil)) {
        memset(indeed, 0x01, (sizeof(BOOL) * COLOR_MAX));
    } else {
        memset(indeed, 0x00, (sizeof(BOOL) * COLOR_MAX));
        ibmp = [self->image_ pixelmap];
        sbmp = [self->shape_ pixelmap];
        skip = ([self->image_ width] & 0x01);
        h = [self->image_ height];
        do {
            w = [self->image_ width];
            do {
                if (*(sbmp) != 0) {
                    indeed[*(ibmp)] = YES;
                }

                // 次へ
                (w)--;
                (ibmp)++;
                (sbmp)++;
            } while (w != 0);

            // 次へ
            (h)--;
            ibmp += skip;
            sbmp += skip;
        } while (h != 0);
    }

    // 吸い取り許可、上書き許可を対象色とする
#if 0
    for (l = 0; l < COLOR_MAX; (l)++) {
        col = [[[self->document_ picture] palette] palette:l];
        if ([self->adjacent_ state] == 0) {
            // 隣接でなければ吸い取り・上書きのみを条件とする
            if (([col noDropper]) || ([col isMask])) {
                flag = NO;
            } else {
                flag = YES;
            }
        } else {
            // 隣接の場合は色要素も含む
            if (([col noDropper]) || ([col isMask])) {
                flag = NO;
            } else if (([col red] == 0) && ([col green] == 0) && ([col blue] == 0)) {
                flag = NO;
            } else {
                flag = YES;
            }
        }
        [self->selectView_ setAttribute:((indeed[l]) ? flag : NO)
                                atIndex:l];
    }
#else   // 0
    for (l = 0; l < COLOR_MAX; (l)++) {
        col = [[[self->document_ picture] palette] palette:l];
        if (([col noDropper]) || ([col isMask])) {
            flag = NO;
        } else if (([col red] == 0) && ([col green] == 0) && ([col blue] == 0)) {
            flag = NO;
        } else {
            flag = YES;
        }
        [self->selectView_ setAttribute:((indeed[l]) ? flag : NO)
                                atIndex:l];
    }
#endif  // 0

    // 再描画
    [self->selectView_ setNeedsDisplay:YES];

    // 妥当性評価
    [self verifySetting];

    return;
}


//
// 選択反転
//
//  Call
//    sender      : 操作対象(api 変数)
//    selectView_ : 色選択領域(outlet)
//
//  Return
//    selectView_ : 色選択領域(outlet)
//
-(IBAction)reverseSelect:(id)sender
{
    int l;

    // 設定値を反転する
    for (l = 0; l < COLOR_MAX; (l)++) {
        [self->selectView_ setAttribute:([self->selectView_ attribute:l] ? NO :
YES)
                                atIndex:l];
    }

    // 再描画
    [self->selectView_ setNeedsDisplay:YES];

    // 妥当性評価
    [self verifySetting];

    return;
}


//
// すべて選択
//
//  Call
//    sender      : 操作対象(api 変数)
//    selectView_ : 色選択領域(outlet)
//
//  Return
//    selectView_ : 色選択領域(outlet)
//
-(IBAction)allSelect:(id)sender
{
    int l;

    // すべて YES に切り替える
    for (l = 0; l < COLOR_MAX; (l)++) {
        [self->selectView_ setAttribute:YES
                                atIndex:l];
    }

    // 再描画
    [self->selectView_ setNeedsDisplay:YES];

    // 妥当性評価
    [self verifySetting];

    return;
}


//
// すべて非選択
//
//  Call
//    sender      : 操作対象(api 変数)
//    selectView_ : 色選択領域(outlet)
//
//  Return
//    selectView_ : 色選択領域(outlet)
//
-(IBAction)allClear:(id)sender
{
    int l;

    // すべて NO に切り替える
    for (l = 0; l < COLOR_MAX; (l)++) {
        [self->selectView_ setAttribute:NO
                                atIndex:l];
    }

    // 再描画
    [self->selectView_ setNeedsDisplay:YES];

    // 妥当性評価
    [self verifySetting];

    return;
}


//
// 隣接
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    None
//
-(IBAction)adjacent:(id)sender
{
    // 妥当性評価
    [self verifySetting];

    return;
}


//
// 手動
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    manual_     : 手動(outlet)
//    auto_       : 自動(outlet)
//    pair_       : 対ごと(outlet)
//    sizeSlider_ : サイズ(outlet)
//    sizeDetail_ : サイズ詳細(対ごと用)(outlet)
//
-(IBAction)manual:(id)sender
{
#if 0
    [self->manual_ setState:1];
#endif  // 0
    [self->auto_ setState:0];
    [self->pair_ setState:0];
    [self->sizeSlider_ setEnabled:YES];
    [self->sizeDetail_ setEnabled:NO];

    return;
}


//
// 自動
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    manual_     : 手動(outlet)
//    auto_       : 自動(outlet)
//    pair_       : 対ごと(outlet)
//    sizeSlider_ : サイズ(outlet)
//    sizeDetail_ : サイズ詳細(対ごと用)(outlet)
//
-(IBAction)auto:(id)sender
{
    [self->manual_ setState:0];
#if 0
    [self->auto_ setState:0];
#endif  // 0
    [self->pair_ setState:0];
    [self->sizeSlider_ setEnabled:NO];
    [self->sizeDetail_ setEnabled:NO];

    return;
}


//
// 対ごと
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    manual_     : 手動(outlet)
//    auto_       : 自動(outlet)
//    pair_       : 対ごと(outlet)
//    sizeSlider_ : サイズ(outlet)
//    sizeDetail_ : サイズ詳細(対ごと用)(outlet)
//
-(IBAction)pair:(id)sender
{
    [self->manual_ setState:0];
    [self->auto_ setState:0];
#if 0
    [self->pair_ setState:1];
#endif  // 0
    [self->sizeSlider_ setEnabled:YES];
    [self->sizeDetail_ setEnabled:YES];

    // 初期値を生成
    [self createSizePair];

    return;
}


#if 0   // raiseSizeDetailSheet: に移行する
//
// 詳細(対ごと)
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    None
//
-(IBAction)sizeDetail:(id)sender
{
    // 何もしない
    ;

    return;
}
#endif  // 0


//
// サイズ設定
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    sizePair_ : 色と大きさの対群(instance 変数)
//
-(IBAction)sizeSlide:(id)sender
{
    // 初期値を生成
    if (self->sizePair_ != nil) {
        [self->sizePair_ release];
        self->sizePair_ = nil;
        [self createSizePair];
    }

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
//    sender    : 操作対象(api 変数)
//    adjacent_ : 隣接(outlet)
//    manual_   : 手動(outlet)
//    auto_     : 自動(outlet)
//    pair_     : 対ごと(outlet)
//
//  Return
//    isOk_ : 実行するか(instance 変数)
//
-(IBAction)ok:(id)sender
{
    self->isOk_ = YES;

    // 隣接とサイズの指定方法を記憶
    [[NSUserDefaults standardUserDefaults]
        setBool:([self->adjacent_ state] != 0)
         forKey:DEFAULT_ADJACENT];
    if ([self->auto_ state] != 0) {
        [[NSUserDefaults standardUserDefaults] setInteger:1
                                                   forKey:DEFAULT_AUTO];
    } else if ([self->pair_ state] != 0) {
        [[NSUserDefaults standardUserDefaults] setInteger:2
                                                   forKey:DEFAULT_AUTO];
    } else /* if ([self->manual_ state] != 0) */ { 
        [[NSUserDefaults standardUserDefaults] setInteger:0
                                                   forKey:DEFAULT_AUTO];
    }

    // 閉じる
    [self cancel:sender];               // cancel の実装で閉じる

    return;
}


// ----------------------------------------------------------------------------
// instance - public - for the detail setting sheet.

//
// 個別詳細設定シートを開ける
//
//  Call
//    sender       : 操作対象(api 変数)
//    detailSheet_ : 個別詳細設定シート(outlet)
//    detailList_  : 個別詳細設定リスト(outlet)
//    sizePair_    : 色と大きさの対群(instance 変数)
//
//  Return
//    None
//
- (IBAction)raiseSizeDetailSheet:(id)sender
{
    // 対群を引き渡す
    [(PoCoAutoGradationSizePairOperate *)([self->detailList_ delegate]) setSizeDetail:(NSDictionary *)(self->sizePair_)];

    // シートを開ける
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
    __block typeof(self) tmpSelf = self;
    [[self window] beginSheet:self->detailSheet_
            completionHandler:^(NSModalResponse returnCode) {
        [tmpSelf sizeDetailSheetDidEnd:returnCode];
    }];
#else   // (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
    [NSApp beginSheet:self->detailSheet_
       modalForWindow:[self window]
        modalDelegate:self
       didEndSelector:@selector(sizeDetailSheetDidEnd:returnCode:contextInfo:)
          contextInfo:nil];
#endif  // (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)

    // 一覧表を更新
    [self->detailList_ reloadData];

    return;
}


//
// 個別詳細設定シートを閉じる
//
//  Call
//    sender       : 操作対象(api 変数)
//    detailSheet_ : 個別詳細設定シート(outlet)
//    detailList_  : 個別詳細設定リスト(outlet)
//
//  Return
//    None
//
- (IBAction)endSizeDetailSheet:(id)sender
{
    // シートを閉じる
    [self->detailSheet_ orderOut:sender];
    [NSApp endSheet:self->detailSheet_
         returnCode:[sender tag]];

    // 対群を忘れさせる
    [(PoCoAutoGradationSizePairOperate *)([self->detailList_ delegate]) setSizeDetail:nil];

    return;
}


//
// 個別詳細設定シートが閉じられた
//
//  Call
//    sheet        : 閉じたsheet(api 変数)
//    returnCode   : 終了時返り値(api 変数)
//    contextInfo  : 補助情報(api 変数)
//    detailSheet_ : 個別詳細設定シート(outlet)
//
//  Return
//    sizePair_ : 色と大きさの対群(instance 変数)
//
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
- (void)sizeDetailSheetDidEnd:(NSModalResponse)returnCode
#else   // (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
- (void)sizeDetailSheetDidEnd:(NSWindow *)sheet
                   returnCode:(int)returnCode
                  contextInfo:(void *)contextInfo
#endif  // (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
{
    NSArray *pair;
    NSEnumerator *iter;
    PoCoGradationPairInfo *info;

    // [set] で抜けていたら、設定を反映
    if (returnCode != 0) {
        goto EXIT;
    }

    // 結果を取得
    pair = [(PoCoAutoGradationSizePairOperate *)([self->detailList_ delegate]) sizeDetail];

    // 設定内容を反映(結果の実体を複製するのではなく個々の値を取得してくる)
    iter = [pair objectEnumerator];
    for (info = [iter nextObject]; info != nil; info = [iter nextObject]) {
        [(PoCoGradationPairInfo *)([self->sizePair_ objectForKey:[info name]]) setSize:[info size]];
    }

EXIT:
    return;
}

@end
