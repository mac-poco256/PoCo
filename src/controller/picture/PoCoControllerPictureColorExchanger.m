//
//	Pelistina on Cocoa - PoCo -
//	色交換
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerPictureColorExchanger.h"

#import "PoCoLayer.h"
#import "PoCoPalette.h"
#import "PoCoControllerFactory.h"
#import "PoCoColorBuffer.h"

// ============================================================================
@implementation PoCoControllerPictureColorExchanger

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
//    s    : 交換元色番号
//    d    : 交換先色番号
//
//  Return
//    function     : 実体
//    active_      : 通知の有無(instance 変数)
//    srcNum_      : 交換元色番号(instance 変数)
//    dstNum_      : 交換先色番号(instance 変数)
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
//    DPRINT((@"[PoCoControllerPictureColorExchanger init]\n"));

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
//    DPRINT((@"[PoCoControllerPictureColorExchanger dealloc]\n"));

    // 資源の解放
    [self->colorBuffer_ release];
    self->colorBuffer_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// 編集実行
//  layer の bitmap の内容を直接書き換える
//  (layer の差し替え/bitmap の差し替えではない)
//
//  Call
//    picture_ : 編集対象画像(基底 instance 変数)
//    active_  : 通知の有無(instance 変数)
//    srcNum_  : 交換元色番号(instance 変数)
//    dstNum_  : 交換先色番号(instance 変数)
//
//  Return
//    function     : 編集正否
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(BOOL)execute
{
    BOOL  result;
    int x;
    int y;
    int i;
    NSEnumerator *iter;
    PoCoLayerBase *layer;
    unsigned char *pixmap;
    PoCoColor *dcol;
    PoCoPalette *plt = [self->picture_ palette];
    const int xmax = (int)([self->picture_ bitmapRect].size.width);
    const int ymax = (int)([self->picture_ bitmapRect].size.height);
    const int rb = (xmax + (xmax & 1));

    result = NO;
    if (self->srcNum_ == self->dstNum_) {
        goto EXIT;
    }

    // 画像の更新
    iter = [[self->picture_ layer] objectEnumerator];
    layer = [iter nextObject];
    for ( ; layer != nil; layer = [iter nextObject]) {
        // 非編集対象の選別
        if ([layer layerType] != PoCoLayerType_Bitmap) {
            continue;
        } else if ([layer drawLock]) {
            continue;
        }

        // 逐次探索で置換
        pixmap = [[layer bitmap] pixelmap];
        for (y = 0; y < ymax; (y)++) {
            i = (y * rb);
            for (x = 0; x < xmax; (x)++, (i)++) {
                if (pixmap[i] == self->srcNum_) {
                    pixmap[i] = self->dstNum_;
                } else if (pixmap[i] == self->dstNum_) {
                    pixmap[i] = self->srcNum_;
                }
            }
        }
    }

    // パレットの交換
    dcol = [[plt palette:self->dstNum_] copy];
    [[plt palette:self->dstNum_] setRed:[[plt palette:self->srcNum_] red]
                               setGreen:[[plt palette:self->srcNum_] green]
                                setBlue:[[plt palette:self->srcNum_] blue]];
    [[plt palette:self->dstNum_] setMask:[[plt palette:self->srcNum_] isMask]];
    [[plt palette:self->dstNum_] setDropper:[[plt palette:self->srcNum_] noDropper]];
    [[plt palette:self->dstNum_] setTrans:[[plt palette:self->srcNum_] isTrans]];

    [[plt palette:self->srcNum_] setRed:[dcol red]
                               setGreen:[dcol green]
                                setBlue:[dcol blue]];
    [[plt palette:self->srcNum_] setMask:[dcol isMask]];
    [[plt palette:self->srcNum_] setDropper:[dcol noDropper]];
    [[plt palette:self->srcNum_] setTrans:[dcol isTrans]];
    [dcol release];

    // 処理完了
    result = YES;

    // 取り消しの生成
    [self createUndo];

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
//    srcNum_      : 交換元色番号(instance 変数)
//    dstNum_      : 交換先色番号(instance 変数)
//
//  Return
//    None
//
-(void)createUndo
{
    if (self->active_) {
        [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
            createPictureColorExchanger:YES
                                    src:self->srcNum_
                                    dst:self->dstNum_];
    } else {
        [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
            createPictureColorExchangerPassive:YES
                                           src:self->srcNum_
                                           dst:self->dstNum_];
    }

    [super setUndoName:[[NSBundle mainBundle]
                           localizedStringForKey:@"PaletteExchange"
                                           value:@"exchange palette"
                                           table:nil]];

    return;
}

@end
