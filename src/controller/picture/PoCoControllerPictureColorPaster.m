//
//	Pelistina on Cocoa - PoCo -
//	色複写
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerPictureColorPaster.h"

#import "PoCoPalette.h"
#import "PoCoControllerFactory.h"
#import "PoCoColorBuffer.h"

// ============================================================================
@implementation PoCoControllerPictureColorPaster

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    buf  : 色保持情報
//    act  : 通知の有無
//    s    : 複写元色番号
//    d    : 複写先色番号
//
//  Return
//    function     : 実体
//    active_      : 通知の有無(instance 変数)
//    srcNum_      : 複写元色番号(instance 変数)
//    dstNum_      : 複写先色番号(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
   active:(BOOL)act
      src:(unsigned char)s
      dst:(unsigned char)d
{
//    DPRINT((@"[PoCoControllerPictureColorPaster init]\n"));

    // super class を初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo];

    // 自身を初期化
    if (self != nil) {
        self->active_ = act;
        self->srcNum_ = s;
        self->dstNum_ = d;
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
//    DPRINT((@"[PoCoControllerPictureColorPaster dealloc]\n"));

    // 資源の解放
    [self->colorBuffer_ release];
    self->colorBuffer_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    picture_ : 編集対象画像(基底 instance 変数)
//    active_  : 通知の有無(instance 変数)
//    srcNum_  : 複写元色番号(instance 変数)
//    dstNum_  : 複写先色番号(instance 変数)
//
//  Return
//    function     : 編集正否
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(BOOL)execute
{
    BOOL  result;
    PoCoPalette *plt = [self->picture_ palette];

    result = NO;
    if (self->srcNum_ == self->dstNum_) {
        goto EXIT;
    }

    // 取り消しの生成
    [self createUndo];

    // パレットの複写
    [[plt palette:self->dstNum_] setRed:[[plt palette:self->srcNum_] red]
                               setGreen:[[plt palette:self->srcNum_] green]
                                setBlue:[[plt palette:self->srcNum_] blue]];
    [[plt palette:self->dstNum_] setMask:[[plt palette:self->srcNum_] isMask]];
    [[plt palette:self->dstNum_] setDropper:[[plt palette:self->srcNum_] noDropper]];
    [[plt palette:self->dstNum_] setTrans:[[plt palette:self->srcNum_] isTrans]];

    // 処理完了
    result = YES;

    // 色保持情報を初期化
    [self->colorBuffer_ reset:nil];

    // 編集を通知
    if (self->active_) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoChangePalette
                          object:nil];
    }

EXIT:
    return result;
}


//
// 取り消しの生成
//
//  Call
//    undoManager_ : 取り消し情報(基底 instance 変数)
//    factory_     : 編集部の生成部(基底 instance 変数)
//    active_      : 通知の有無(instance 変数)
//    dstNum_      : 複写先色番号(instance 変数)
//
//  Return
//    None
//
-(void)createUndo
{
    PoCoColor *col = [[self->picture_ palette] palette:self->dstNum_];
    NSString *name;

    name = [[NSBundle mainBundle] localizedStringForKey:@"PalettePaste"
                                                  value:@"paste palette"
                                                  table:nil];

    if (self->active_) {
        [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
            createPaletteSingleSetter:YES
                                  num:self->dstNum_
                                  red:[col red]
                                green:[col green]
                                 blue:[col blue]
                               isMask:[col isMask]
                               noDrop:[col noDropper]
                              isTrans:[col isTrans]
                                 name:name];
    } else {
        [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
                   createPaletteSingleSetter:YES
                                         num:self->dstNum_
                                         red:[col red]
                                       green:[col green]
                                        blue:[col blue]
                                      isMask:[col isMask]
                                      noDrop:[col noDropper]
                                     isTrans:[col isTrans]
                                        name:name];
    }

    return;
}

@end
