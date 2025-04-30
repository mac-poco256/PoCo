//
//	Pelistina on Cocoa - PoCo -
//	切り抜き
//
//	Copyright (C) 2005-2019 KAENRYUU Koutoku.
//

#import "PoCoControllerPictureImageClipper.h"

#import "PoCoEditInfo.h"
#import "PoCoLayer.h"

#import "PoCoControllerFactory.h"
#import "PoCoControllerLayerInserter.h"
#import "PoCoControllerLayerDeleter.h"

// ============================================================================
@implementation PoCoControllerPictureImageClipper

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    r    : 矩形枠
//
//  Return
//    rect_ : 矩形枠(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
     rect:(PoCoRect *)r
{
    DPRINT((@"[PoCoControllerPictureImageClipper init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo];

    // 自身の初期化
    if (self != nil) {
        self->rect_ = r;
        [self->rect_ retain];
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
//    rect_ : 矩形枠(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoControllerPictureImageClipper dealloc]\n"));

    // 資源の解放
    [self->rect_ release];
    self->rect_ = nil;

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
//    rect_        : 矩形枠(instance 変数)
//
//  Return
//    function : 編集正否
//
-(BOOL)execute
{
    BOOL result;
    int index;
    PoCoRect *r;
    PoCoBitmap *bmp;
    PoCoLayerBase *oldLayer;            // 変形前
    PoCoBitmapLayer *newLayer;          // 変形後
    const int layerNum = (int)([[self->picture_ layer] count]);
    const int width = [self->rect_ width];
    const int height = [self->rect_ height];

    DPRINT((@"[PoCoControllerPictureImageClipper execute]\n"));

    result = NO;
    newLayer = nil;
    r = nil;

    // サイズが同じなら何もしない
    if (([self->rect_ left] == 0) &&
        ([self->rect_ top] == 0) &&
        (width == [[[self->picture_ layer:0] bitmap] width]) &&
        (height == [[[self->picture_ layer:0] bitmap] height])) {
        goto EXIT;
    }

    // 切り抜き後の矩形枠を生成
    r = [[PoCoRect alloc] initPoCoRect:self->rect_];
    [r shiftX:-([self->rect_ left])
       shiftY:-([self->rect_  top])];

    // 無編集通知部を登録
    [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
        createClipNoEditter:YES
                            name:nil];

    // 変形画像を生成(変形後のレイヤーを追加していく)
    for (index = 0; index < layerNum; (index)++) {
        oldLayer = [self->picture_ layer:index];
        if (oldLayer != nil) {
            // 変形先の bitmap を生成
            newLayer = [[PoCoBitmapLayer alloc]
                           initWidth:width
                          initHeight:height
                        defaultColor:[[self->editInfo_ selColor] num]];

            // 属性を複写
            if ([oldLayer drawLock]) {          // 描画抑制
                [newLayer setDrawLock];
            }
            if (!([oldLayer isDisplay])) {      // 表示
                [newLayer clearIsDisplay];
            }
            [newLayer setName:[oldLayer name]]; // 名称

            // 切り抜き画像を生成
            bmp = [[oldLayer bitmap] getBitmap:self->rect_];
            [[newLayer bitmap] setBitmap:[bmp pixelmap]
                                withRect:r];
            [bmp release];

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
                           localizedStringForKey:@"ImageClip"
                                           value:@"clip image"
                                           table:nil]];

    // 編集を通知
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoImageClip
                      object:nil];

    // 正常終了
    result = YES;

EXIT:
    [r release];
    return result;
}

@end
