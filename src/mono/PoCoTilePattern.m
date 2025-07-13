//
// PoCoTilePattern.m
// implementation of classes to management tile patterns.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoTilePattern.h"

#import "PoCoTilePatternDefault.h"

// 内部変数
static NSString *PATTERN_NAME = @"PoCoTilePatternData_%d";

// 内部関数プロトタイプ
static void  setPattern(PoCoMonochromePattern *pat, int i);

// ------------------------------------------------------------------- 内部関数
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
    [pat setPattern:(const unsigned char *)(&(PoCoTilePatternDefault[i]))
              width:TILE_PATTERN_SIZE
             height:TILE_PATTERN_SIZE];

    return;
}




// ============================================================================
@implementation PoCoTilePattern

// ----------------------------------------------------------------------------
// class - public.

//
// 初期設定
//
//  Call
//    PoCoTilePatternDefault[] : 初期値(内部変数)
//
//  Return
//    None
//
+(void)initialize
{
    int l;
    NSMutableDictionary *dic;
    PoCoMonochromePattern *pat;

    DPRINT((@"[PoCoTilePattern initialize]\n"));

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
//  Call:
//    none.
//
//  Return:
//    function   : instance.
//    pattern_[] : tile patterns.(instance)
//
-(id) init
{
    int l;
    NSUserDefaults *def;
    NSData *data;
    PoCoMonochromePattern *pat;
    NSData *newData;


    DPRINT((@"[PoCoTilePattern init]\n"));

    // forward to super class.
    self = [super init];

    // initialise myself.
    if (self != nil) {
        for (l = 0; l < TILE_PATTERN_NUM; (l)++) {
            self->pattern_[l] = nil;
        }

        // load each tile pattern from UserDefaults.
        def = [NSUserDefaults standardUserDefaults];
        for (l = 0; l < TILE_PATTERN_NUM; (l)++) {
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
#if 0    // official document says; this method is unnecessary and shouldn’t be used.
                [def synchronize];
#endif   // 0
            }
            self->pattern_[l] = pat;
            if (self->pattern_[l] == nil) {
                DPRINT((@"can't create tile pattern : %d\n", l));
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
    for (l = 0; l < TILE_PATTERN_NUM; (l)++) {
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

    if ((index < 0) || (index >= TILE_PATTERN_NUM)) {
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
    if ((index < 0) || (index >= TILE_PATTERN_NUM)) {
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
@implementation PoCoTileSteadyPattern

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
//    PoCoTilePatternDefault[] : 初期値(内部変数)
//
//  Return
//    function   : 実体
//    pattern_[] : ペン先(instance 変数)
//
-(id)init
{
    int l;
    int i;

    DPRINT((@"[PoCoTileSteadyPattern init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        for (l = 0; l < TILE_PATTERN_NUM; (l)++) {
            self->pattern_[l] = nil;
        }

        // ペン先の読み込み
        for (l = 0, i = 0; l < (TILE_PATTERN_NUM >> 1); (l)++, (i)++) {
            self->pattern_[i] = [[PoCoMonochromePattern alloc] init];
            setPattern(self->pattern_[i], l);
        }
        for (l = (TILE_PATTERN_NUM - 2);
             l >= ((TILE_PATTERN_NUM >> 1) - 1);
             (l)--, (i)++) {
            self->pattern_[i] = [[PoCoMonochromePattern alloc] init];
            setPattern(self->pattern_[i], l);
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
    for (l = 0; l < TILE_PATTERN_NUM; (l)++) {
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

    if ((index < 0) || (index >= TILE_PATTERN_NUM)) {
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
