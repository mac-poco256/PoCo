//
//	Pelistina on Cocoa - PoCo -
//	自動グラデーション色サイズ対群管理
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import "PoCoAutoGradationSizePairOperate.h"

// ============================================================================
@implementation PoCoAutoGradationSizePairOperate

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function : 実体
//    pair_    : 色と大きさの対群(instance 変数)
//
-(id)init
{
    // super class へ回送
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->pair_ = nil;
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
//    pair_ : 色と大きさの対群(instance 変数)
//
-(void)dealloc
{
    // 資源を解放
    [self->pair_ removeAllObjects];
    [self->pair_ release];
    self->pair_ = nil;

    // super class へ回送
    [super dealloc];

    return;
}


// ------------------------------------------ instance - public - property(get)
//
// 色と大きさの対群を取得
//
//  Call
//    pair_ : 色と大きさの対群(instance 変数)
//
//  Return
//    function : 色と大きさの対群(instance 変数)
//
-(NSArray *)sizeDetail
{
    return (NSArray *)(self->pair_);
}


// ------------------------------------------ instance - public - property(set)
//
// 色と大きさの対群を設定
//
//  Call
//    pair : 色と大きさの対群
//
//  Return
//    pair_ : 色と大きさの対群(instance 変数)
//
-(void)setSizeDetail:(NSDictionary *)pair
{
    NSEnumerator *iter;
    PoCoGradationPairInfo *info;
    PoCoGradationPairInfo *tmp;
    int idx;
    int bidx;
    int eidx;

    // 以前の分を忘れる
    [self->pair_ removeAllObjects];
    [self->pair_ release];
    self->pair_ = nil;

    // 指定の分を覚える(複製)
    if (pair != nil) {
        // 値の範囲を抽出
        bidx = INT_MAX;
        eidx = INT_MIN;
        iter = [pair objectEnumerator];
        for (info = [iter nextObject]; info != nil; info = [iter nextObject]) {
            bidx = MIN(bidx, (int)([info first]));
            eidx = MAX(eidx, (int)([info first]));
            bidx = MIN(bidx, (int)([info second]));
            eidx = MAX(eidx, (int)([info second]));
        }

        // sort 済みの array に持たせる
        self->pair_ = [[NSMutableArray alloc] init];
        for (idx = bidx; idx < eidx; (idx)++) {
            // 上り方向
            info = [pair objectForKey:[PoCoGradationPairInfo pairString:(unsigned int)(idx)
                                                             withSecond:(unsigned int)(idx + 1)]];
            if (info != nil) {
                tmp = [[PoCoGradationPairInfo alloc] initWithFirst:[info first]
                                                        withSecond:[info second]
                                                          withSize:[info size]];
                [self->pair_ addObject:tmp];
                [tmp release];
            }

            // 下り方向
            info = [pair objectForKey:[PoCoGradationPairInfo pairString:(unsigned int)(idx + 1)
                                                             withSecond:(unsigned int)(idx)]];
            if (info != nil) {
                tmp = [[PoCoGradationPairInfo alloc] initWithFirst:[info first]
                                                        withSecond:[info second]
                                                          withSize:[info size]];
                [self->pair_ addObject:tmp];
                [tmp release];
            }
        }
    }

    return;
}


// --------------------------------------- instance - public - delegate methods
//
// 編集可否
//
//  Call
//    table  : 対象(api 変数)
//    column : 対象桁(api 変数)
//    row    : 対象行(api 変数)
//
//  Return
//    function 可否
//
-(BOOL)tableView:(NSTableView *)table
shouldEditTableColumn:(NSTableColumn *)column
                  row:(NSInteger)row
{
    return ([[column identifier] compare:@"sizeForSlider"] == NSOrderedSame);
}


// ------------------------------------ instance - public - data source methods
//
// 行数の取得
//
//  Call
//    table : 対象(api 変数)
//    pair_ : 色と大きさの対群(instance 変数)
//
//  Return
//    function : 行数
//
-(int)numberOfRowsInTableView:(NSTableView *)table
{
    return (int)([self->pair_ count]);
}


//
// 表示
//
//  Call
//    table  : 対象(api 変数)
//    column : 対象桁(api 変数)
//    row    : 対象行(api 変数)
//    pair_  : 色と大きさの対群(instance 変数)
//
//  Return
//    function : 表示内容
//
-(id)tableView:(NSTableView *)table
objectValueForTableColumn:(NSTableColumn *)column
                      row:(int)row
{
    return [(PoCoGradationPairInfo *)([self->pair_ objectAtIndex:row]) valueForKey:[column identifier]];
}


//
// 編集
//
//  Call
//    table  : 対象(api 変数)
//    object : 編集内容(api 変数)
//    column : 対象桁(api 変数)
//    row    : 対象行(api 変数)
//
// Return
//    pair_ : 色と大きさの対群(instance 変数)
//
-(void)tableView:(NSTableView *)table
  setObjectValue:(id)object
  forTableColumn:(NSTableColumn *)column
             row:(int)row
{
    if ([[column identifier] compare:@"sizeForSlider"] == NSOrderedSame) {
        [(PoCoGradationPairInfo *)([self->pair_ objectAtIndex:row]) setSize:([object intValue] * 8)];
    }

    return;
}

@end
