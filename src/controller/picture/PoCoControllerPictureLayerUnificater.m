//
//	Pelistina on Cocoa - PoCo -
//	レイヤー統合
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerPictureLayerUnificater.h"

#import "PoCoLayer.h"
#import "PoCoPalette.h"

#import "PoCoControllerFactory.h"
#import "PoCoControllerLayerInserter.h"
#import "PoCoControllerLayerDeleter.h"

// ============================================================================
@implementation PoCoControllerPictureLayerUnificater

// ------------------------------------------------------------- class - public
//
// 統合画像の生成
//
//  Call
//    pict  : 編集対象画像
//    first : YES : 最初の層は常に描画
//            NO  : 最初の層でも不透過は描画しない
//
//  Return
//    function : 統合した画像
//
+(PoCoBitmapLayer *)createUnificatePicture:(PoCoPicture *)pict
                                   isFirst:(BOOL)first
{
    PoCoBitmapLayer *bmp;               // 新規画像レイヤー
    unsigned int x;                     // 水平走査用
    unsigned int y;                     // 垂直走査用
    unsigned int idx;                   // index-reg.(SI/DI 共通)
    unsigned int row;                   // row bytes
    unsigned char *src;                 // 走査中レイヤー参照用
    unsigned char *dst;                 // 新規画像レイヤー参照用
    NSEnumerator *iter;                 // 各レイヤー走査用(iterator)
    PoCoLayerBase *layer;               // レイヤー参照用
    PoCoPalette *palette;               // パレット
    const unsigned int width = [[[pict layer:0] bitmap] width];
    const unsigned int height = [[[pict layer:0] bitmap] height];

    DPRINT((@"[PoCoControllerPictureLayerUnificater createUnificatePicture]\n"));

    bmp = nil;

    // 新規画像レイヤーを準備
    bmp = [[PoCoBitmapLayer alloc] initWidth:width
                                  initHeight:height
                                defaultColor:0];
    if (bmp == nil) {
        DPRINT((@"can't alloc PoCoBitmapLayer.\n"));
        goto EXIT;
    }
    dst = [[bmp bitmap] pixelmap];

    // 統合した画像の生成
    palette = [pict palette];
    row = (width + (width & 1));
    iter = [[pict layer] objectEnumerator];
    layer = [iter nextObject];
    for ( ; layer != nil; layer = [iter nextObject]) {
        if ([layer isDisplay]) {
            src = [[layer bitmap] pixelmap];
            for (y = 0; y < height; (y)++) {
                idx = (y * row);
                for (x = 0; x < width; (x)++, (idx)++) {
                    if ((first) || (!([[palette palette:src[idx]] isTrans]))) {
                        dst[idx] = src[idx];
                    }
                }
            }
            first = NO;
        }
    }

EXIT:
    return bmp;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//
//  Return
//    function : 実体
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
{
    DPRINT((@"[PoCoControllerPictureLayerUnificater init]\n"));

    // super class を初期化
    self = [super initPict:pict withInfo:info withUndo:undo];

    // 自身を初期化
    if (self != nil) {
        // 何もしない
        ;
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
//    None
//
-(void)dealloc
{
    DPRINT((@"[PoCoControllerPictureLayerUnificater dealloc]\n"));

    // super class を解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    undoManager_ : 取り消し情報(基底 instance 変数)
//    picture_     : 編集対象画像(基底 instance 変数)
//    factory_     : 編集部の生成部(基底 instance 変数)
//
//  Return
//    function : 編集正否
//
-(BOOL)execute
{
    BOOL result;
    int l;                              // 削除の実行用
    PoCoBitmapLayer *bmp;               // 新規画像レイヤー

    result = NO;
    bmp = nil;

    // 1枚だけなら何もしない
    if ([[self->picture_ layer] count] <= 1) {
        goto EXIT;
    }

    // 統合画像を生成
    bmp = [PoCoControllerPictureLayerUnificater
              createUnificatePicture:self->picture_
                             isFirst:NO];
    if (bmp == nil) {
        DPRINT((@"can't create unificate picture.\n"));
        goto EXIT;
    }

    // 無編集通知部を登録
    [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
        createLayerNoEditter:YES
                        name:nil
                      update:YES];

    // レイヤーを挿入
    [self->factory_ createLayerInserterPassive:YES
                                         layer:bmp
                                         index:-1];

    // 統合されたレイヤーを削除
    l = 0;
    while (l < ([[self->picture_ layer] count] - 1)) {
        if ([[self->picture_ layer:l] isDisplay]) {
            [self->factory_ createLayerDeleterPassive:YES index:l];
        } else {
            (l)++;
        }
    }

    // 取り消し名称の設定
    [super setUndoName:[[NSBundle mainBundle]
                           localizedStringForKey:@"LayerUnificate"
                                           value:@"unificate layer"
                                           table:nil]]; 

    // 処理完了
    result = YES;

    // 編集を通知する
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoEditLayer
                      object:[NSNumber numberWithBool:YES]];

EXIT:
    [bmp release];
    return result;
}

@end
