//
// PoCoPenStyle.m
// implementation of classes to management pen styles.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoPenStyle.h"

#import "PoCoPenStyleDefault.h"

// declare internal variable.
static NSString *PATTERN_NAME = @"PoCoPenStyleData_%d";

// declare prototype for local functions.
static void  setDefaultPattern(PoCoMonochromePattern *pat, int i);

// ----------------------------------------------------------------------------
// local functions.

//
// set default pattern.
//
//  Call:
//    pat                   : a pattern.
//    i                     : index (default pattern).
//    PoCoPenStyleDefault[] : default patterns.(global)
//
//  Return:
//    pat : a pattern.
//
static void  setDefaultPattern(PoCoMonochromePattern *pat, int i)
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

    DPRINT((@"[PoCoPenStyle initialize]\n"));

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
// initialise (instance).
//
//  Call:
//    none.
//
//  Return
//    function   : instance.
//    pattern_[] : the pen styles.(instance)
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
#if 0    // official document says; this method is unnecessary and shouldn’t be used.
                [def synchronize];
#endif   // 0
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
// deallocate.
//
//  Call:
//    none.
//
//  Return
//    pattern_[] : the pen styles.(instance)
//
- (void)dealloc
{
    int l;

    // release resources allocated.
    for (l = 0; l < PEN_STYLE_NUM; (l)++) {
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
//    pattern_[] : the pen styles.(instance)
//
//  Return:
//    function : a pen style.
//
- (PoCoMonochromePattern *)pattern:(int)index
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
// set pattern at index.
//
//  Call
//    pat   : a pen style.
//    index : index.
//
//  Return
//    pattern_[] : the pen styles.(instance)
//
- (void)setPattern:(PoCoMonochromePattern *)pat
           atIndex:(int)index
{
    if ((index < 0) || (index >= PEN_STYLE_NUM)) {
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

    for (l = 0; l < PEN_STYLE_NUM; (l)++) {
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
    if ((index < 0) || (index >= PEN_STYLE_NUM)) {
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
@implementation PoCoPenSteadyStyle

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
//    PoCoPenStyleDefault[] : default patterns.(global)
//
//  Return
//    function   : instance.
//    pattern_[] : the pen styles.(instance)
//
- (id)init
{
    int l;

    DPRINT((@"[PoCoPenSteadyStyle init]\n"));

    // forward to super class.
    self = [super init];

    // initialise myself.
    if (self != nil) {
        for (l = 0; l < PEN_STYLE_NUM; (l)++) {
            self->pattern_[l] = nil;
        }

        // creat each pen style.
        for (l = 0; l < PEN_STYLE_NUM; (l)++) {
            self->pattern_[l] = [[PoCoMonochromePattern alloc] init];
            setDefaultPattern(self->pattern_[l], l);
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
//    pattern_[] : the pen styles.(instance)
//
- (void)dealloc
{
    int l;

    // release resource allocated.
    for (l = 0; l < PEN_STYLE_NUM; (l)++) {
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
//    pattern_[] : the pen styles.(instance)
//
//  Return:
//    function : a pen style.
//
- (PoCoMonochromePattern *)pattern:(int)index
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
// set pattern at index.
//
//  Call
//    pat   : a pen style.
//    index : index.
//
//  Return
//    pattern_[] : the pen styles.(instance)
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
