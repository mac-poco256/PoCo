//
//	Pelistina on Cocoa - PoCo -
//	サイズ変更
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerPictureCanvasResizer.h"

#import "PoCoEditInfo.h"
#import "PoCoLayer.h"

#import "PoCoControllerFactory.h"
#import "PoCoControllerLayerInserter.h"
#import "PoCoControllerLayerDeleter.h"

#import "PoCoEditResizeBitmap.h"

// ============================================================================
@implementation PoCoControllerPictureCanvasResizer

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    f              : 変倍
//    w              : 幅
//    h              : 高さ
//
//  Return
//    isFit_  : 変倍(instance 変数)
//    width_  : 幅(instance 変数)
//    height_ : 高さ(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
    isFit:(BOOL)f
    width:(int)w
   height:(int)h
{
    DPRINT((@"[PoCoControllerPictureCanvasResizer init]\n"));

    // super class の初期化
    self = [super initPict:pict withInfo:info withUndo:undo];

    // 自身の初期化
    if (self != nil) {
        self->isFit_ = f;
        self->width_ = w;
        self->height_ = h;
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
    DPRINT((@"[PoCoControllerPictureCanvasResizer dealloc]\n"));

    // 資源の解放
    ;

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    picture_     : 編集対象画像(基底 instance 変数)
//    undoManager_ : 取り消し情報(基底 instance 変数) 
//    factory_     : 編集部の生成部(基底 instance 変数)
//    editInfo_    : 編集情報(基底 instance 変数)
//    isFit_       : 変倍(instance 変数)
//    width_       : 幅(instance 変数)
//    height_      : 高さ(instance 変数)
//
//  Return
//    function : 編集正否
//
-(BOOL)execute
{
    BOOL result;
    int index;
    PoCoBitmap *bmp;
    PoCoRect *r;
    PoCoLayerBase *oldLayer;            // 変形前
    PoCoBitmapLayer *newLayer;          // 変形後
    PoCoEditResizeBitmap *edit;
    const int layerNum = (int)([[self->picture_ layer] count]);

    DPRINT((@"[PoCoControllerPictureCanvasResizer execute]\n"));

    result = NO;
    newLayer = nil;

    // サイズが同じなら何もしない
    if (([[[self->picture_ layer:0] bitmap] width] == self->width_) &&
        ([[[self->picture_ layer:0] bitmap] height] == self->height_)) {
        goto EXIT;
    }

    // 無編集通知部を登録
    [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
        createResizeNoEditter:YES
                         name:nil];

    // 変形画像を生成(変形後のレイヤーを追加していく)
    for (index = 0; index < layerNum; (index)++) {
        oldLayer = [self->picture_ layer:index];
        if (oldLayer != nil) {
            // 変形先の bitmap を生成
            newLayer = [[PoCoBitmapLayer alloc]
                           initWidth:self->width_
                          initHeight:self->height_
                        defaultColor:[[self->editInfo_ selColor] num]];

            // 属性を複写
            if ([oldLayer drawLock]) {          // 描画抑制
                [newLayer setDrawLock];
            }
            if (!([oldLayer isDisplay])) {      // 表示
                [newLayer clearIsDisplay];
            }
            [newLayer setName:[oldLayer name]]; // 名称

            // 変形画像を生成
            if (self->isFit_) {
                // 変倍
                edit = [[PoCoEditResizeBitmap alloc] initDst:[newLayer bitmap]
                                                     withSrc:[oldLayer bitmap]];
                [edit executeResize];
                [edit release];
            } else {
                // clip
                r = [self->picture_ bitmapPoCoRect];
                bmp = [[oldLayer bitmap] getBitmap:r];
                [[newLayer bitmap] setBitmap:[bmp pixelmap]
                                    withRect:r];
                [r release];
                [bmp release];
            }

            // 変形後の layer を追加
            [self->factory_ createLayerInserterPassive:YES
                                                 layer:newLayer
                                                 index:-1];
            [newLayer release];
        }
    }

    // 変形前画像を破棄(変形前のレイヤーを削除)
    for (index = (layerNum - 1); index >= 0; (index)--) {
        [self->factory_ createLayerDeleterPassive:YES
                                            index:index];
    }

    // 取り消し名称の設定
    [super setUndoName:[[NSBundle mainBundle]
                           localizedStringForKey:@"CanvasResize"
                                           value:@"canvas resize"
                                           table:nil]];

    // 編集を通知
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoCanvasResize
                      object:nil];

    // 正常終了
    result = YES;

EXIT:
    return result;
}

@end
