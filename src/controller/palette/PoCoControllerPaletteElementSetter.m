//
//	Pelistina on Cocoa - PoCo -
//	パレット要素設定部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerPaletteElementSetter.h"

#import "PoCoPalette.h"
#import "PoCoControllerFactory.h"
#import "PoCoColorBuffer.h"

// ============================================================================
@implementation PoCoControllerPaletteElementSetter

// ---------------------------------------------------------- instance - public
//
// 初期化
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    buf  : 色保持情報
//    pal  : 設定内容
//
//  Return
//    function     : 実体
//    palette_     : 設定内容(instance 変数)
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
  palette:(PoCoPalette *)pal
{
    DPRINT((@"PoCoControllerPaletteElementSetter init]\n"));

    // super class の初期化
    self = [super initPict:pict withInfo:info withUndo:undo];

    // 自身の初期化
    if (self != nil) {
        self->palette_ = pal;
        self->colorBuffer_ = buf;
        [self->palette_ retain];
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
//    palette_ : 設定内容(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"PoCoControllerPaletteElementSetter dealloc]\n"));

    // 資源の解放
    [self->palette_ release];
    [self->colorBuffer_ release];
    self->palette_ = nil;
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
//    palette_ : 設定内容(instance 変数)
//
//  Return
//    function     : 編集可否
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(BOOL)execute
{
    int l;
    PoCoColor *src;
    PoCoColor *dst;

    // 取り消しの生成
    [self createUndo];

    // 内容を順次設定
    for (l = 0; l < COLOR_MAX; l++) {
        src = [self->palette_ palette:l];
        dst = [[self->picture_ palette] palette:l];
        [dst setRed:[src red]
           setGreen:[src green]
            setBlue:[src blue]];
        [dst setTrans:[src isTrans]];
        [dst setDropper:[src noDropper]];
        [dst setMask:[src isMask]];
    }

    // パレットの更新を通知
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoChangePalette
                      object:nil];

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
//
//  Return
//    None
//
-(void)createUndo
{
    [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
        createPaletteElementSetter:YES
                           palette:[[self->picture_ palette] copy]];
    [super setUndoName:[[NSBundle mainBundle]
                           localizedStringForKey:@"PaletteElementSet"
                                           value:@"edit palette"
                                           table:nil]];

    return;
}

@end
