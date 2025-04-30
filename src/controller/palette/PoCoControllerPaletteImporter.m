//
//	Pelistina on Cocoa - PoCo -
//	パレット取り込み
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerPaletteImporter.h"

#import "PoCoPalette.h"
#import "PoCoControllerFactory.h"
#import "PoCoColorBuffer.h"

// ============================================================================
@implementation PoCoControllerPaletteImporter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict   : 編集対象画像
//    info   : 編集情報
//    undo   : 取り消し情報
//    buf    : 色保持情報
//    target : 設定内容
//    flags  : 設定対象
//
//  Return
//    function       : 実体
//    targetPalette_ : 設定内容(instance 変数)
//    targetFlags_[] : 設定対象(instance 変数)
//    colorBuffer_   : 色保持情報(instance 変数)
//
-(id)init:(PoCoPicture *)pict
         info:(PoCoEditInfo *)info
         undo:(NSUndoManager *)undo
       buffer:(PoCoColorBuffer *)buf
targetPalette:(PoCoPalette *)target
    withFlags:(const BOOL *)flags
{
    DPRINT((@"PoCoControllerPaletteImporter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo];

    // 自身の初期化
    if (self != nil) {
        self->targetPalette_ = target;
        memcpy(self->targetFlags_, flags, sizeof(BOOL) * COLOR_MAX);
        self->colorBuffer_ = buf;
        [self->targetPalette_ retain];
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
//    targetPalette_ : 設定内容(instance 変数)
//    colorBuffer_   : 色保持情報(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"PoCoControllerPaletteImporter dealloc]\n"));

    // 資源の解放
    [self->targetPalette_ release];
    [self->colorBuffer_ release];
    self->targetPalette_ = nil;
    self->colorBuffer_ = nil;

    // super class の解放
    [super dealloc];

    return;
}

//
// 編集実行
//
//  Call
//    picture_       : 編集対象画像(基底 instance 変数)
//    targetPalette_ : 設定内容(instance 変数)
//    targetFlags_[] : 設定対象(instance 変数)
//
//  Return
//    function     : 編集可否
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(BOOL)execute
{
    int l;
    PoCoColor *col;

    // 取り消しの生成
    [self createUndo];

    // パレットを更新
    for (l = 0; l < COLOR_MAX; (l)++) {
        if (self->targetFlags_[l]) {
            col = [self->targetPalette_ palette:l];
            [[[self->picture_ palette] palette:l] setRed:[col red]
                                               setGreen:[col green]
                                                setBlue:[col blue]];
        }
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
//    picture_       : 編集対象画像(基底instance変数)
//    undoManager_   : 取り消し情報(基底instance変数)
//    factory_       : 編集部の生成部(基底instance変数)
//    targetFlags_[] : 設定対象(instance 変数)
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
                           localizedStringForKey:@"PaletteImport"
                                           value:@"import palette"
                                           table:nil]];

    return;
}

@end
