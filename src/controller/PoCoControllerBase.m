//
//	Pelistina on Cocoa - PoCo -
//	編集部基底
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

#import "PoCoAppController.h"
#import "PoCoControllerFactory.h"

// ============================================================================
@implementation PoCoControllerBase

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
//    function     : 実体
//    picture_     : 編集対象画像(instance 変数)
//    editInfo_    : 編集情報(instance 変数)
//    undoManager_ : 取り消し情報(instance 変数)
//    factory_     : 編集部の生成部(instance 変数)
//
-(id)initPict:(PoCoPicture *)pict
     withInfo:(PoCoEditInfo *)info
     withUndo:(NSUndoManager *)undo
{
//    DPRINT((@"[PoCoControllerBase init]\n"));

    // super class を初期化
    self = [super init];

    // 自身を初期化
    if (self != nil) {
        self->picture_ = pict;
        self->editInfo_ = info;
        self->undoManager_ = undo;
        self->factory_ = [(PoCoAppController *)([NSApp delegate]) factory];

        // 各基底情報を retain
        [self->picture_ retain];
        [self->editInfo_ retain];
        [self->undoManager_ retain];
        [self->factory_ retain];
    }

    return self;
}


//
// deallocate
//
//  Call
//    picture_     : 編集対象画像(instance 変数)
//    editInfo_    : 編集情報(instance 変数）
//    undoManager_ : 取り消し情報(instance 変数)
//    factory_     : 編集部の生成部(instance 変数)
//
//  Return
//    picture_     : 編集対象画像(instance 変数)
//    editInfo_    : 編集情報(instance 変数）
//    undoManager_ : 取り消し情報(instance 変数)
//    factory_     : 編集部の生成部(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerBase dealloc]\n"));

    // 資源を解放
    [self->factory_ release];
    [self->undoManager_ release];
    [self->editInfo_ release];
    [self->picture_ release];
    self->picture_ = nil;
    self->editInfo_ = nil;
    self->undoManager_ = nil;
    self->factory_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// 取り消し名称の設定
//
//  Call
//    name         : 取り消し名称
//    undoManager_ : 取り消し情報(instance 変数)
//
//  Return
//    undoManager_ : 取り消し情報(instance 変数)
//
-(void)setUndoName:(NSString *)name
{
    if ([self->undoManager_ isUndoing]) {
        [self->undoManager_ setActionName:[self->undoManager_ undoActionName]];
    } else if ([undoManager_ isRedoing]) {
        [self->undoManager_ setActionName:[self->undoManager_ redoActionName]];
    } else {
        [self->undoManager_ setActionName:name];
    }

    return;
}


//
// 編集実行
//  編集操作が成功したら YES を返す
//  (再描画範囲の有無とは無関係)
//
//  Call
//    None
//
//  Return
//    function : 編集正否
//
-(BOOL)execute
{
    // default では何もしない
    ;

    // default では NO を返す
    return NO;
}


//
// 取り消し情報の生成
//
//  Call
//    undoManager_ : 取り消し情報(instance 変数)
//
//  Return
//    undoManager_ : 取り消し情報(instance 変数)
//
-(void)createUndo
{
    // default では何もしない
    ;

    return;
}

@end
