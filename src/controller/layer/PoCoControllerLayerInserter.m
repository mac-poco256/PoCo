//
//	Pelistina on Cocoa - PoCo -
//	レイヤー挿入部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerLayerInserter.h"

#import "PoCoLayer.h"
#import "PoCoControllerFactory.h"
#import "PoCoControllerLayerDeleter.h"

// ============================================================================
@implementation PoCoControllerLayerInserter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    act  : 通知の有無
//    lyr  : 挿入レイヤー
//    idx  : 挿入位置
//
//  Return
//    function : 実体
//    active_  : 通知の有無(instance 変数)
//    index_   : 挿入位置(instance 変数)
//    layer_   : 挿入レイヤー(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   active:(BOOL)act
    layer:(PoCoLayerBase *)lyr
  atIndex:(int)idx
{
    DPRINT((@"[PoCoControllerLayerInserter init]\n"));

    // super class を初期化
    self = [super initPict:pict withInfo:info withUndo:undo];

    // 自身を初期化
    if (self != nil) {
        self->active_ = act;
        self->index_ = idx;
        self->layer_ = lyr;
        [self->layer_ retain];
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
//    layer_ : 挿入レイヤー(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoControllerLayerInserter dealloc]\n"));

    // 資源の解放
    [self->layer_ release];
    self->layer_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    picture_ : 編集対象画像(基底 instance 変数)
//    active_  : 通知の有無(instance 変数)
//    index_   : 挿入位置(instance 変数)
//    layer_   : 挿入レイヤー(instance 変数)
//
//  Return
//    function : 編集正否
//
-(BOOL)execute
{
    DPRINT((@"[PoCoControllerLayerInserter execute]\n"));

    self->index_ = ((self->index_ < 0) ? (int)([[self->picture_ layer] count]) : self->index_);

    [self->picture_ insertLayer:self->index_ layer:self->layer_];

    // 取り消しを生成
    [self createUndo];

    // 編集を通知する
    if (self->active_) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoEditLayer
                          object:[NSNumber numberWithBool:YES]];
    }

    return YES;
}


//
// 取り消しの生成
//
//  Call
//    undoManager_ : 取り消し情報(基底 instance 変数)
//    factory_     : 編集部の生成部(基底 instance 変数)
//    active_      : 通知の有無(instance変数)
//    index_       : 削除対象レイヤー番号(instance変数)
//
//  Return
//    None
//
-(void)createUndo
{
    if (self->active_) {
        [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
            createLayerDeleter:YES
                         index:self->index_];
    } else {
        [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
            createLayerDeleterPassive:YES
                                index:self->index_];
    }
    [super setUndoName:[[NSBundle mainBundle]
                           localizedStringForKey:@"LayerInsert"
                                           value:@"insert layer"
                                           table:nil]];

    return;
}

@end
