//
//	Pelistina on Cocoa - PoCo -
//	レイヤー名称設定部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerLayerNameSetter.h"

#import "PoCoLayer.h"
#import "PoCoControllerFactory.h"

// ============================================================================
@implementation PoCoControllerLayerNameSetter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    idx  : 対象レイヤー番号
//    nm   : 設定内容
//
//  Return
//    function : 実体
//    index_   : 対象レイヤー番号(instance 変数)
//    name_    : 設定内容(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
     name:(NSString *)nm
  atIndex:(int)idx
{
    DPRINT((@"[PoCoControllerLayerNameSetter init]\n"));

    // super class を初期化
    self = [super initPict:pict withInfo:info withUndo:undo];

    // 自身を初期化
    if (self != nil) {
        self->index_ = idx;
        self->name_ = nm;
        [self->name_ retain];
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
//    name_ : 設定内容(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoControllerLayerNameSetter dealloc]\n"));

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
//    picture_     : 編集対象画像(基底 instance 変数)
//    undoManager_ : 取り消し情報(基底 instance 変数)
//    factory_     : 編集部の生成部(基底 instance 変数)
//    index_       : 対象レイヤー番号(instance 変数)
//    name_        : 設定内容(instance 変数)
//
//  Return
//    function : 編集正否
//
-(BOOL)execute
{
    PoCoLayerBase *layer;
    NSString *old;

    layer = [self->picture_ layer:self->index_];
    old = [layer name];
    [layer setName:self->name_];

    // 取り消しの生成
    [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
        createLayerNameSetter:YES
                         name:old
                        index:self->index_];
    [super setUndoName:[[NSBundle mainBundle]
                           localizedStringForKey:@"LayerNameSet"
                                           value:@"set layer name"
                                           table:nil]]; 

    // 編集を通知する
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoEditLayer
                      object:[NSNumber numberWithBool:NO]];

    return YES;
}

@end
