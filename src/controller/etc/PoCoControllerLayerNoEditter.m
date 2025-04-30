//
//	Pelistina on Cocoa - PoCo -
//	レイヤー構造更新単純通知部(無編集)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerLayerNoEditter.h"

#import "PoCoControllerFactory.h"

// ============================================================================
@implementation PoCoControllerLayerNoEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    nm   : 取り消し名称
//    upd  : レイヤー構造の変化か
//
//  Return
//    function     : 実体
//    name_        : 取り消し名称(instance 変数)
//    update_      : レイヤー構造の変化か(instance 変数)
//    deallocPost_ : dealloc で通知(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
     name:(NSString *)nm
   update:(BOOL)upd;
{
    DPRINT((@"[PoCoControllerLayerNoEditter init]\n"));

    // super class を初期化
    self = [super initPict:pict withInfo:info withUndo:undo];

    // 自身を初期化
    if (self != nil) {
        self->deallocPost_ = NO;
        self->name_ = nm;
        self->update_ = upd;
        [self->name_ retain];
    }

    return self;
}


//
// deallocate
//
//  Call
//    deallocPost_ : dealloc で通知(instance 変数)
//
//  Return
//    name_ : 取り消し名称(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoControllerLayerNoEditter dealloc]\n"));

    if (self->deallocPost_) {
        [self postNote];
    }

    // 資源の解放
    [self->name_ release];
    self->name_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    factory_     : 編集部の生成部(基底 instance 変数)
//    undoManager_ : 取り消し情報(基底 instance 変数)
//    name_        : 取り消し名称(instance変数)
//    update_      : レイヤー構造の変化か(instance変数)
//
//  Return
//    function     : 編集正否
//    deallocPost_ : dealloc で通知(instance 変数)
//
-(BOOL)execute
{
    DPRINT((@"[PoCoControllerLayerNoEditter execute]\n"));

    // 通知
    if ([self->undoManager_ isUndoing]) {
        self->deallocPost_ = NO;
        [self postNote];
    } else {
        self->deallocPost_ = YES;
    }

    // 取り消しの再登録
    [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
        createLayerNoEditter:YES
                        name:self->name_
                      update:self->update_];

    // 取り消し名称の設定
    [super setUndoName:self->name_];

    return YES;
}


//
// 通知の送信
//
//  Call
//    update_ : レイヤー構造の変化か(instance 変数)
//
//  Return
//    None
//
-(void)postNote
{
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoEditLayer
                      object:[NSNumber numberWithBool:self->update_]];

    return;
}

@end
