//
//	Pelistina on Cocoa - PoCo -
//	画像サイズ変更単純通知部(無編集)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerResizeNoEditter.h"

#import "PoCoControllerFactory.h"

// ============================================================================
@implementation PoCoControllerResizeNoEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    nm   : 取り消し名称
//
//  Return
//    function     : 実体
//    name_        : 取り消し名称(instance 変数)
//    deallocPost_ : dealloc で通知(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
     name:(NSString *)nm
{
    DPRINT((@"[PoCoControllerResizeNoEditter init]\n"));

    // super class を初期化
    self = [super initPict:pict withInfo:info withUndo:undo];

    // 自身を初期化
    if (self != nil) {
        self->deallocPost_ = NO;
        self->name_ = nm;
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
    DPRINT((@"[PoCoControllerResizeNoEditter dealloc]\n"));

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
//
//  Return
//    function     : 編集正否
//    deallocPost_ : dealloc で通知(instance 変数)
//
-(BOOL)execute
{
    DPRINT((@"[PoCoControllerResizeNoEditter execute]\n"));

    // 通知
    if ([self->undoManager_ isUndoing]) {
        self->deallocPost_ = NO;
        [self postNote];
    } else {
        self->deallocPost_ = YES;
    }

    // 取り消しの再登録
    [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
        createResizeNoEditter:YES
                         name:self->name_];

    // 取り消し名称の設定
    [super setUndoName:self->name_];

    return YES;
}


//
// 通知の送信
//
//  Call
//    None
//
//  Return
//    None
//
-(void)postNote
{
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoCanvasResize
                      object:nil];

    return;
}

@end
