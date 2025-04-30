//
//	Pelistina on Cocoa - PoCo -
//	パレット要素加算部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerPaletteIncrementer.h"

#import "PoCoPalette.h"
#import "PoCoControllerFactory.h"
#import "PoCoControllerPaletteDecrementer.h"
#import "PoCoColorBuffer.h"

// ============================================================================
@implementation PoCoControllerPaletteIncrementer

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    buf  : 色保持情報
//    n    : 対象色番号
//    r    : 赤要素を対象にするか
//    g    : 緑要素を対象にするか
//    b    : 青要素を対象にするか
//    s    : 増減値
//
//  Return
//    function     : 実体
//    num_         : 対象色番号(instance 変数)
//    isRed_       : 赤要素を対象にするか(instance 変数)
//    isGreen_     : 緑要素を対象にするか(instance 変数)
//    isBlue_      : 青要素を対象にするか(instance 変数)
//    step_        : 増減値(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
      num:(int)n
      red:(BOOL)r
    green:(BOOL)g
     blue:(BOOL)b
     step:(unsigned int)s
{
//    DPRINT((@"[PoCoControllerPaletteIncrementer init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo];

    // 自身の初期化
    if (self != nil) {
        self->num_ = n;
        self->isRed_ = r;
        self->isGreen_ = g;
        self->isBlue_ = b;
        self->step_ = s;
        self->colorBuffer_ = buf;
        [self->colorBuffer_ retain];
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
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerPaletteIncrementer dealloc]\n"));

    // 資源の解放
    [self->colorBuffer_ release];
    self->colorBuffer_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    picture_ : 編集対象画像(基底 instance 変数)
//    num_     : 対象色番号(instance 変数)
//    isRed_   : 赤要素を対象にするか(instance 変数)
//    isGreen_ : 緑要素を対象にするか(instance 変数)
//    isBlue_  : 青要素を対象にするか(instance 変数)
//    step_    : 増減値(instance 変数)
//
//  Return
//    function     : 編集正否
//    prevElm_[]   : 変更前の色要素(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(BOOL)execute
{
    BOOL  result;
    int elm[3];
    PoCoColor *col = [[self->picture_ palette] palette:self->num_];

//    DPRINT((@"[PoCoControllerPaletteIncrementer execute]\n"));

    result = NO;

    // 値を変更
    elm[0] = (int)([col red]);
    self->prevElm_[0] = elm[0];
    if (self->isRed_) {
        elm[0] = MIN(255, elm[0] + self->step_);
    }
    elm[1] = (int)([col green]);
    self->prevElm_[1] = elm[1];
    if (self->isGreen_) {
        elm[1] = MIN(255, elm[1] + self->step_);
    }
    elm[2] = (int)([col blue]);
    self->prevElm_[2] = elm[2];
    if (self->isBlue_) {
        elm[2] = MIN(255, elm[2] + self->step_);
    }

    // 変更した値を反映
    if ((elm[0] != self->prevElm_[0]) ||
        (elm[1] != self->prevElm_[1]) ||
        (elm[2] != self->prevElm_[2])) {
        [col setRed:(unsigned char)(elm[0])
           setGreen:(unsigned char)(elm[1])
            setBlue:(unsigned char)(elm[2])];

        result = YES;

        // 取り消しの生成
        [self createUndo];

        // パレットの更新を通知
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoChangePalette
                          object:[NSNumber numberWithInt:self->num_]];

        // 色保持情報を初期化
        [self->colorBuffer_ reset:nil];
    }

    return result;
}


//
// 取り消しの生成
//
//  Call
//    undoManager_ : 取り消し情報(基底 instance 変数)
//    factory_     : 編集部の生成部(基底 instance 変数)
//    picture_     : 編集対象画像(基底 instance 変数)
//    num_         : 対象色番号(instance 変数)
//    prevElm_[]   : 変更前の色要素(instance 変数)
//
//  Return
//    None
//
-(void)createUndo
{
    [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
        createPaletteSingleSetter:YES
                              num:self->num_
                              red:self->prevElm_[0]
                            green:self->prevElm_[1]
                             blue:self->prevElm_[2]
                           isMask:[[[self->picture_ palette] palette:self->num_] isMask]
                           noDrop:[[[self->picture_ palette] palette:self->num_] noDropper]
                          isTrans:[[[self->picture_ palette] palette:self->num_] isTrans]
                             name:[[NSBundle mainBundle]
                                      localizedStringForKey:@"PaletteIncrement"
                                                      value:@"increment palette"
                                                      table:nil]];
    [super setUndoName:[[NSBundle mainBundle]
                           localizedStringForKey:@"PaletteIncrement"
                                           value:@"increment palette"
                                           table:nil]];

    return;
}

@end
