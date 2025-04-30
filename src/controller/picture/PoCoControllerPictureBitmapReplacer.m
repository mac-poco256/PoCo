//
//	Pelistina on Cocoa - PoCo -
//	画像置換
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerPictureBitmapReplacer.h"

#import "PoCoLayer.h"
#import "PoCoControllerFactory.h"

// ============================================================================
@implementation PoCoControllerPictureBitmapReplacer

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    idx  : 対象レイヤー番号
//    r    : 置換領域
//    bmp  : 置換内容
//    name : 取り消し名称
//
//  Return
//    function  : 実体
//    index_    : 対象レイヤー番号(instance 変数)
//    rect_     : 置換領域(instance 変数)
//    bitmap_   : 置換内容(instance 変数)
//    undoName_ : 取り消し名称(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
    layer:(int)idx
     rect:(PoCoRect *)r
   bitmap:(PoCoBitmap *)bmp
     name:(NSString *)name
{
//    DPRINT((@"[PoCoControllerPictureBitmapReplacer init]\n"));

    // super class の初期化
    self = [super initPict:pict withInfo:info withUndo:undo];

    // 自身の初期化
    if (self != nil) {
        self->index_ = idx;
        self->rect_ = r;
        self->bitmap_ = bmp;
        self->undoName_ = name;
        [self->rect_ retain];
        [self->bitmap_ retain];
        [self->undoName_ retain];
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
//    rect_     : 置換領域(instance 変数)
//    bitmap_   : 置換内容(instance 変数)
//    undoName_ : 取り消し名称(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerPictureBitmapReplacer dealloc]\n"));

    // 資源の解放
    [self->rect_ release];
    [self->bitmap_ release];
    [self->undoName_ release];
    self->rect_ = nil;
    self->bitmap_ = nil;
    self->undoName_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    picture_     : 編集対象画像(基底 instance 変数）
//    undoManager_ : 取り消し情報(基底 instance 変数)
//    factory_     : 編集部の生成部(基底 instance 変数)
//    index_       : 対象レイヤー番号(instance 変数)
//    rect_        : 置換領域(instance 変数)
//    bitmap_      : 置換内容(instance 変数)
//    undoName_    : 取り消し名称(instance 変数)
//
//  Return
//    function : 編集正否
//
-(BOOL)execute
{
    BOOL  result;
    PoCoBitmap *bmp;
    PoCoLayerBase *layer;
    PoCoEditPictureNotification *note;

//    DPRINT((@"[PoCoControllerPictureBitmapReplacer execute]\n"));

    result = NO;
    bmp = nil;

    // 対象レイヤーの取得
    layer = [self->picture_ layer:self->index_];
    if (layer != nil) {
        // 元画像の取得
        bmp = [[layer bitmap] getBitmap:self->rect_];

        // 置換画像の設定
        [[layer bitmap] setBitmap:[self->bitmap_ pixelmap]
                         withRect:self->rect_];

        // 取り消しの生成
        if (bmp != nil) {
            [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
                createPictureBitmapReplacer:YES
                                      layer:self->index_
                                       rect:self->rect_
                                     bitmap:bmp
                                       name:self->undoName_];
            [super setUndoName:self->undoName_];
        }

        // 編集を通知
        result = YES;
        note = [[PoCoEditPictureNotification alloc] initWithRect:self->rect_
                                                         atIndex:self->index_];
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoEditPicture
                          object:note];
        [note release];
    }
    [bmp release];

    return result;
}

@end
