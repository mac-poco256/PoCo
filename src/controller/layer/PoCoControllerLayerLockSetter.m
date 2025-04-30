//
//	Pelistina on Cocoa - PoCo -
//	レイヤー描画抑止設定部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerLayerLockSetter.h"

#import "PoCoLayer.h"
#import "PoCoControllerFactory.h"

// ============================================================================
@implementation PoCoControllerLayerLockSetter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    idx  : 対象レイヤー番号
//    lock : 設定内容
//
//  Return
//    function  : 実体
//    index_    : 対象レイヤー番号(instance 変数)
//    drawLock_ : 設定内容(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
 drawLock:(BOOL)lock
  atIndex:(int)idx
{
    DPRINT((@"[PoCoControllerLayerLockSetter init]\n"));

    // super class を初期化
    self = [super initPict:pict withInfo:info withUndo:undo];

    // 自身を初期化
    if (self != nil) {
        self->index_ = idx;
        self->drawLock_ = lock;
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
    DPRINT((@"[PoCoControllerLayerLockSetter dealloc]\n"));

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
//    index_       : 対象レイヤー番号(instance 変数)
//    drawLock_    : 設定内容(instance 変数)
//
//  Return
//    function : 編集正否
//
-(BOOL)execute
{
    if (self->drawLock_) {
        [[self->picture_ layer:self->index_] setDrawLock];
    } else {
        [[self->picture_ layer:self->index_] clearDrawLock];
    }

    // 取り消しの生成
    [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
        createLayerLockSetter:YES
                         lock:((self->drawLock_) ? NO : YES)
                        index:self->index_];
    [super setUndoName:[[NSBundle mainBundle]
                           localizedStringForKey:@"LayerDrawLockSet"
                                           value:@"set layer drawlock"
                                           table:nil]]; 

    // 編集を通知する
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoEditLayer
                      object:[NSNumber numberWithBool:NO]];

    return YES;
}

@end
