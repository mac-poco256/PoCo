//
// PoCoTilePattern.m
// implementation of classes to management tile patterns.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoTilePattern.h"

#import "PoCoTilePatternDefault.h"

// declare internal variable.
static NSString *PATTERN_NAME = @"PoCoTilePatternData_%d";

// declare prototype for local functions.
static void  setDefaultPattern(PoCoMonochromePattern *pat, int i);

// ----------------------------------------------------------------------------
// local functions.

//
// set default pattern.
//
//  Call:
//    pat                      : a pattern.
//    i                        : index (default pattern).
//    PoCoTilePatternDefault[] : default patterns.(global)
//
//  Return:
//    pat : a pattern.
//
static void  setDefaultPattern(PoCoMonochromePattern *pat, int i)
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
// initialise (class).
//
//  Call:
//    none.
//
//  Return:
//    none.
//
+ (void)initialize
{
    int l;
    NSMutableDictionary *dic;
    PoCoMonochromePattern *pat;

    DPRINT((@"[PoCoTilePattern initialize]\n"));

    dic = [NSMutableDictionary dictionary];

    // create each default pattern.
    for (l = 0; l < PEN_STYLE_NUM; (l)++) {
        pat = [[PoCoMonochromePattern alloc] init];
        setDefaultPattern(pat, l);
        [dic setObject:[NSKeyedArchiver archivedDataWithRootObject:pat
                                             requiringSecureCoding:YES
                                                             error:nil]
                forKey:[NSString stringWithFormat:PATTERN_NAME, l]];
        [pat release];
    }

    // register the default patterns in UserDefaults.
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
//    pattern_[] : the tile patterns.(instance)
//
- (id)init
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
// deallocate.
//
//  Call:
//    none.
//
//  Return:
//    pattern_[] : the tile patterns.(instance)
//
- (void)dealloc
{
    int l;

    // release resources allocated.
    for (l = 0; l < TILE_PATTERN_NUM; (l)++) {
        [self->pattern_[l] release];
        self->pattern_[l] = nil;
    }

    // forward to super class.
    [super dealloc];

    return;
}


//
// get pattern at index.
//
//  Call:
//    index      : index.
//    pattern_[] : the tile patterns.(instance)
//
//  Return:
//    function : a tile pattern.
//
- (PoCoMonochromePattern *)pattern:(int)index
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
// set pattern at index.
//
//  Call
//    pat   : a tile pattern.
//    index : index.
//
//  Return
//    pattern_[] : the tile patterns.(instance)
//
- (void)setPattern:(PoCoMonochromePattern *)pat
           atIndex:(int)index
{
    if ((index < 0) || (index >= TILE_PATTERN_NUM)) {
        ;
    } else {
        // set pattern.
        [self->pattern_[index] setPattern:[pat pattern]
                                    width:[pat width]
                                   height:[pat height]];

        // update UserDefaults.
        [[NSUserDefaults standardUserDefaults]
            setObject:[NSKeyedArchiver archivedDataWithRootObject:self->pattern_[index]
                                            requiringSecureCoding:YES
                                                            error:nil]
               forKey:[NSString stringWithFormat:PATTERN_NAME, index]];
    }

    return;
}


//
// revert all patterns.
//
//  Call:
//    none.
//
//  Return:
//    none.
//
- (void)revertAllPatterns
{
    int l;

    for (l = 0; l < TILE_PATTERN_NUM; (l)++) {
        [self revertPattern:l];
    }

    return;
}


//
// revert pattern at index.
//
//  Call:
//    index : index.
//
//  Return:
//    none.
//
- (void)revertPattern:(int)index
{
    if ((index < 0) || (index >= TILE_PATTERN_NUM)) {
        ;
    } else {
        // remove from UserDefaults.
        [[NSUserDefaults standardUserDefaults]
            removeObjectForKey:[NSString stringWithFormat:PATTERN_NAME, index]];

        // revert pattern to default.
        setDefaultPattern(self->pattern_[index], index);
    }

    return;
}

@end




// ============================================================================
@implementation PoCoTileSteadyPattern

// ----------------------------------------------------------------------------
// class - public.

//
// initialise (class).
//
//  Call:
//    none.
//
//  Return:
//    none.
//
+ (void)initialize
{
    // do nothing.
    ;

    return;
}


// ----------------------------------------------------------------------------
// instance - public.

//
// initialise (instance).
//
//  Call
//    PoCoTilePatternDefault[] : default patterns.(global)
//
//  Return
//    function   : instance.
//    pattern_[] : the tile patterns.(instance)
//
- (id)init
{
    int l;
    int i;

    DPRINT((@"[PoCoTileSteadyPattern init]\n"));

    // forward to super class.
    self = [super init];

    // initialise myself.
    if (self != nil) {
        for (l = 0; l < TILE_PATTERN_NUM; (l)++) {
            self->pattern_[l] = nil;
        }

        // creat each tile pattern (0 to 7).
        for (l = 0, i = 0; l < (TILE_PATTERN_NUM >> 1); (l)++, (i)++) {
            self->pattern_[i] = [[PoCoMonochromePattern alloc] init];
            setDefaultPattern(self->pattern_[i], l);
        }

        // creat each tile pattern (8 to 14 (the loading is reversed)).
        for (l = (TILE_PATTERN_NUM - 2);
             l >= ((TILE_PATTERN_NUM >> 1) - 1);
             (l)--, (i)++) {
            self->pattern_[i] = [[PoCoMonochromePattern alloc] init];
            setDefaultPattern(self->pattern_[i], l);
        }
    }

    return self;
}


//
// deallocate.
//
//  Call:
//    none.
//
//  Return:
//    pattern_[] : the tile patterns.(instance)
//
- (void)dealloc
{
    int l;

    // release resources allocated.
    for (l = 0; l < TILE_PATTERN_NUM; (l)++) {
        [self->pattern_[l] release];
        self->pattern_[l] = nil;
    }

    // forward to super class.
    [super dealloc];

    return;
}


//
// get pattern at index.
//
//  Call:
//    index      : index.
//    pattern_[] : the tile patterns.(instance)
//
//  Return:
//    function : a tile pattern.
//
- (PoCoMonochromePattern *)pattern:(int)index
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
// set pattern at index.
//
//  Call
//    pat   : a tile pattern.
//    index : index.
//
//  Return
//    pattern_[] : the tile patterns.(instance)
//
- (void)setPattern:(PoCoMonochromePattern *)pat
           atIndex:(int)index
{
    // do nothing.
    ;

    return;
}


//
// revert all patterns.
//
//  Call:
//    none.
//
//  Return:
//    none.
//
- (void)revertAllPatterns
{
    // do nothing.
    ;

    return;
}


//
// revert pattern at index.
//
//  Call:
//    index : index.
//
//  Return:
//    none.
//
- (void)revertPattern:(int)index
{
    // do nothing.
    ;

    return;
}

@end
