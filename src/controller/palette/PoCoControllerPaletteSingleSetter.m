//
//	Pelistina on Cocoa - PoCo -
//	単一パレット要素設定部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerPaletteSingleSetter.h"

#import "PoCoPalette.h"
#import "PoCoControllerFactory.h"
#import "PoCoColorBuffer.h"

// ============================================================================
@implementation PoCoControllerPaletteSingleSetter

// ---------------------------------------------------------- instance - public
//
// 初期化
//
//  Call
//    pict  : 編集対象画像
//    info  : 編集情報
//    undo  : 取り消し情報
//    buf   : 色保持情報
//    num   : 対象色番号
//    r     : 赤
//    g     : 緑
//    b     : 青
//    mask  : 上塗り禁止
//    drop  : 吸い取り禁止
//    trans : 透明指定
//    name  : 取り消し名称
//
//  Return
//    function     : 実体
//    paletteNum_  : 対象色番号(instance 変数)
//    red_         : 赤(instance 変数)
//    green_       : 緑(instance 変数)
//    blue_        : 青(instance 変数)
//    isMask_      : 上書き禁止(instance 変数)
//    noDrop_      : 吸い取り禁止(instance 変数)
//    isTrans_     : 透明指定(instance 変数)
//    undoName_    : 取り消し名称(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
      num:(int)num
      red:(unsigned char)r
    green:(unsigned char)g
     blue:(unsigned char)b
   isMask:(BOOL)mask
   noDrop:(BOOL)drop
  isTrans:(BOOL)trans
     name:(NSString *)name
{
    DPRINT((@"PoCoControllerPaletteSingleSetter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo];

    // 自身の初期化
    if (self != nil) {
        self->paletteNum_ = num;
        self->red_ = r;
        self->green_ = g;
        self->blue_ = b;
        self->isMask_ = mask;
        self->noDrop_ = drop;
        self->isTrans_ = trans;
        self->undoName_ = name;
        self->colorBuffer_ = buf;
        [self->undoName_ retain];
        [self->colorBuffer_ retain];
    }

    return self;
}


//
// 解放
//
//  Call
//    None
//
//  Return
//    undoName_    : 取り消し名称(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"PoCoControllerPaletteSingleSetter dealloc]\n"));

    // 資源を解放
    [self->undoName_ release];
    [self->colorBuffer_ release];
    self->undoName_ = nil;
    self->colorBuffer_ = nil;

    // super class の解放
    [super dealloc];

    return;
}

//
// 編集実行
//
//  Call
//    picture_    : 編集対象画像(基底 instance 変数)
//    paletteNum_ : 対象色番号(instance 変数)
//    red_        : 赤(instance 変数)
//    green_      : 緑(instance 変数)
//    blue_       : 青(instance 変数)
//    isMask_     : 上書き禁止(instance 変数)
//    noDrop_     : 吸い取り禁止(instance 変数)
//    isTrans_    : 透明指定(instance 変数)
//
//  Return
//    function     : 編集可否
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(BOOL)execute
{
    PoCoColor *col = [[self->picture_ palette] palette:self->paletteNum_];

    // 取り消しの生成
    [self createUndo];

    // 内容を順次設定
    [col setRed:self->red_
       setGreen:self->green_
        setBlue:self->blue_];
    [col setMask:self->isMask_];
    [col setDropper:self->noDrop_];
    [col setTrans:self->isTrans_];

    // パレットの更新を通知
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoChangePalette
                      object:[NSNumber numberWithInt:self->paletteNum_]];

    // 色保持情報を初期化
    [self->colorBuffer_ reset:nil];

    return YES;
}


//
// 取り消しの生成
//
//  Call
//    picture_     : 編集対象画像(基底 instance 変数)
//    undoManager_ : 取り消し情報(基底 instance 変数)
//    factory_     : 編集部の生成部(基底 instance 変数)
//    paletteNum_  : 対象色番号(instance 変数)
//    red_         : 赤(instance 変数)
//    green_       : 緑(instance 変数)
//    blue_        : 青(instance 変数)
//    isMask_      : 上書き禁止(instance 変数)
//    noDrop_      : 吸い取り禁止(instance 変数)
//    isTrans_     : 透明指定(instance 変数)
//    undoName_    : 取り消し名称(instance 変数)
//
//  Return
//    None
//
-(void)createUndo
{
    PoCoColor *col = [[self->picture_ palette] palette:self->paletteNum_];

    [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
        createPaletteSingleSetter:YES
                              num:self->paletteNum_
                              red:[col red]
                            green:[col green]
                             blue:[col blue]
                           isMask:[col isMask]
                           noDrop:[col noDropper]
                          isTrans:[col isTrans]
                             name:self->undoName_];
    [super setUndoName:self->undoName_];

    return;
}

@end
