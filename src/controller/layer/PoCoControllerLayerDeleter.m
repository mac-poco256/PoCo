//
//	Pelistina on Cocoa - PoCo -
//	レイヤー削除部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerLayerDeleter.h"

#import "PoCoControllerFactory.h"
#import "PoCoControllerLayerInserter.h"

// ============================================================================
@implementation PoCoControllerLayerDeleter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    act  : 通知の有無
//    idx  : 削除対象レイヤー番号
//
//  Return
//    function : 実体
//    active_  : 通知の有無(instance 変数)
//    index_   : 削除対象レイヤー番号(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   active:(BOOL)act
  atIndex:(int)idx
{
    DPRINT((@"[PoCoControllerLayerDeleter init]\n"));

    // super class を初期化
    self = [super initPict:pict withInfo:info withUndo:undo];

    // 自身を初期化
    if (self != nil) {
        self->index_ = idx;
        self->active_ = act;
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
    DPRINT((@"[PoCoControllerLayerDeleter dealloc]\n"));

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
//    index_   : 削除対象レイヤー番号(instance 変数)
//
//  Return
//    function : 編集正否
//
-(BOOL)execute
{
    BOOL  result;
    const int cnt = (int)([[self->picture_ layer] count]);

    DPRINT((@"[PoCoControllerLayerDeleter execute]\n"));

    result = NO;

    // レイヤー番号が負の場合は最上位レイヤーを対象にする
    self->index_ = ((self->index_ < 0) ? (cnt - 1) : self->index_);

    if ((self->index_ < 0) || (self->index_ >= cnt) || (cnt == 1)) {
        // 不正番号か、単一レイヤーの場合は削除不可
        ;
    } else {
        [self createUndo];
        [self->picture_ deleteLayer:self->index_];
        result = YES;

        // 編集を通知する
        if (self->active_) {
            [[NSNotificationCenter defaultCenter]
                postNotificationName:PoCoEditLayer
                              object:[NSNumber numberWithBool:YES]];
        }
    }

    return result;
}


//
// 取り消しの生成
//
//  Call
//    undoManager_ : 取り消し情報(基底 instance 変数)
//    factory_     : 編集部の生成部(基底 instance 変数)
//    picture_     : 編集対象画像(基底 instance 変数)
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
            createLayerInserter:YES
                          layer:[[self->picture_ layer:self->index_] copy]
                          index:self->index_];
    } else {
        [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
            createLayerInserterPassive:YES
                                 layer:[[self->picture_ layer:self->index_] copy]
                                 index:self->index_];
    }
    [super setUndoName:[[NSBundle mainBundle]
                           localizedStringForKey:@"LayerDelete"
                                           value:@"delete layer"
                                           table:nil]];

    return;
}

@end
