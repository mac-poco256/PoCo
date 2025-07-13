//
// PoCoPenStyle.m
// implementation of classes to management pen styles.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoPenStyle.h"

#import "PoCoPenStyleDefault.h"

// 内部変数
static NSString *PATTERN_NAME = @"PoCoPenStyleData_%d";

// 内部関数プロトタイプ
static void  setPattern(PoCoMonochromePattern *pat, int i);

// ----------------------------------------------------------------------------
// local functions.

//
// 初期値を設定
//
//  Call
//    pat : パターン
//    i   : インデックス
//
//  Return
//    pat : パターン
//
static void  setPattern(PoCoMonochromePattern *pat, int i)
{
    [pat setPattern:(const unsigned char *)(&(PoCoPenStyleDefault[i]))
              width:PEN_STYLE_SIZE
             height:PEN_STYLE_SIZE];

    return;
}




// ============================================================================
@implementation PoCoPenStyle

// ----------------------------------------------------------------------------
// class - public.

//
// 初期設定
//
//  Call
//    PoCoPenStyleDefault[] : 初期値(内部変数)
//
//  Return
//    None
//
+(void)initialize
{
    int l;
    NSMutableDictionary *dic;
    PoCoMonochromePattern *pat;

    DPRINT((@"[PoCoPenStyle initialize]\n"));

    dic = [NSMutableDictionary dictionary];

    // ペン先初期値を順次設定
    for (l = 0; l < PEN_STYLE_NUM; (l)++) {
        pat = [[PoCoMonochromePattern alloc] init];
        setPattern(pat, l);
        [dic setObject:[NSKeyedArchiver archivedDataWithRootObject:pat
                                             requiringSecureCoding:YES
                                                             error:nil]
                forKey:[NSString stringWithFormat:PATTERN_NAME, l]];
        [pat release];
    }

    // default を設定
    [[NSUserDefaults standardUserDefaults] registerDefaults:dic];

    return;
}


// ----------------------------------------------------------------------------
// instance - public.

//
// initialise.
//
//  Call
//    None
//
//  Return
//    function   : instance.
//    pattern_[] : pen styles.(instance)
//
- (id)init
{
    int l;
    NSUserDefaults *def;
    NSData *data;
    PoCoMonochromePattern *pat;
    NSData *newData;

    DPRINT((@"[PoCoPenStyle init]\n"));

    // forward to super class.
    self = [super init];

    // initialise myself.
    if (self != nil) {
        for (l = 0; l < PEN_STYLE_NUM; (l)++) {
            self->pattern_[l] = nil;
        }

        // load each pen style from UserDefaults.
        def = [NSUserDefaults standardUserDefaults];
        for (l = 0; l < PEN_STYLE_NUM; (l)++) {
            // retrieve pen style with key.
            data = [def objectForKey:[NSString stringWithFormat:PATTERN_NAME, l]];

            // unarichve data.
            pat = [NSKeyedUnarchiver unarchivedObjectOfClass:[PoCoMonochromePattern class]
                                                    fromData:data
                                                       error:nil];

            // whether data could be unarchived.
            if (pat == nil) {
                // could not be unarchied, then assuming that this is old version. so that, convert data unarchived to current class.
# pragma clang diagnostic push
# pragma clang diagnostic ignored "-Wdeprecated-declarations"
                pat = [NSUnarchiver unarchiveObjectWithData:data];
# pragma clang diagnostic pop
                newData = [NSKeyedArchiver archivedDataWithRootObject:pat
                                                requiringSecureCoding:YES
                                                                error:nil];
                [def setObject:newData
                        forKey:[NSString stringWithFormat:PATTERN_NAME, l]];
                [def synchronize];
            }
            self->pattern_[l] = pat;
            if (self->pattern_[l] == nil) {
                DPRINT((@"can't create pen style : %d\n", l));
                [self release];
                self = nil;
                break;
            }
            [self->pattern_[l] retain];
        }
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
//    pattern_[] : ペン先(instance 変数)
//
-(void)dealloc
{
    int l;

    // 資源の解放
    for (l = 0; l < PEN_STYLE_NUM; (l)++) {
        [self->pattern_[l] release];
        self->pattern_[l] = nil;
    }

    // super class の解放
    [super dealloc];

    return;
}


//
// 参照
//
//  Call
//    index      : 番号
//    pattern_[] : ペン先(instance 変数)
//
//  Return
//    function : ペン先
//
-(PoCoMonochromePattern *)pattern:(int)index
{
    PoCoMonochromePattern *pat;

    if ((index < 0) || (index >= PEN_STYLE_NUM)) {
        pat = nil;
    } else {
        pat = self->pattern_[index];
    }

    return pat;
}


//
// 設定
//
//  Call
//    pat   : パターン
//    index : 番号
//
//  Return
//    pattern_[] : ペン先(instance 変数)
//
-(void)setPattern:(PoCoMonochromePattern *)pat
          atIndex:(int)index
{
    if ((index < 0) || (index >= PEN_STYLE_NUM)) {
        ;
    } else {
        [self->pattern_[index] setPattern:[pat pattern]
                                    width:[pat width]
                                   height:[pat height]];

        // 設定を更新
        [[NSUserDefaults standardUserDefaults]
            setObject:[NSKeyedArchiver archivedDataWithRootObject:self->pattern_[index]
                                            requiringSecureCoding:YES
                                                            error:nil]
               forKey:[NSString stringWithFormat:PATTERN_NAME, index]];
    }

    return;
}

@end




// ============================================================================
@implementation PoCoPenSteadyStyle

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
    // 何もしない
    ;

    return;
}


// ----------------------------------------------------------------------------
// instance - public.

//
// initialize
//
//  Call
//    PoCoPenStyleDefault[] : 初期値(内部変数)
//
//  Return
//    function  : 実体
//    pattern_[] : ペン先(instance 変数)
//
-(id)init
{
    int l;

    DPRINT((@"[PoCoPenSteadyStyle init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        for (l = 0; l < PEN_STYLE_NUM; (l)++) {
            self->pattern_[l] = nil;
        }

        // ペン先の読み込み
        for (l = 0; l < PEN_STYLE_NUM; (l)++) {
            self->pattern_[l] = [[PoCoMonochromePattern alloc] init];
            setPattern(self->pattern_[l], l);
        }
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
//    pattern_[] : ペン先(instance 変数)
//
-(void)dealloc
{
    int l;

    // 資源の解放
    for (l = 0; l < PEN_STYLE_NUM; (l)++) {
        [self->pattern_[l] release];
        self->pattern_[l] = nil;
    }

    // super class の解放
    [super dealloc];

    return;
}


//
// 参照
//
//  Call
//    index      : 番号
//    pattern_[] : ペン先(instance 変数)
//
//  Return
//    function : ペン先
//
-(PoCoMonochromePattern *)pattern:(int)index
{
    PoCoMonochromePattern *pat;

    if ((index < 0) || (index >= PEN_STYLE_NUM)) {
        pat = nil;
    } else {
        pat = self->pattern_[index];
    }

    return pat;
}


//
// 設定
//
//  Call
//    pat   : パターン
//    index : 番号
//
//  Return
//    None
//
-(void)setPattern:(PoCoMonochromePattern *)pat
          atIndex:(int)index
{
    // 何もしない
    ;

    return;
}

@end
