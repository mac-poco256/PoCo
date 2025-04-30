//
//	Pelistina on Cocoa - PoCo -
//	レイヤー表示設定部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerLayerDisplaySetter.h"

#import "PoCoLayer.h"
#import "PoCoControllerFactory.h"

// ============================================================================
@implementation PoCoControllerLayerDisplaySetter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    idx  : 対象レイヤー番号
//    disp : 設定内容
//
//  Return
//    function   : 実体
//    index_     : 対象レイヤー番号(instance 変数)
//    isDisplay_ : 設定内容(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
isDisplay:(BOOL)disp
  atIndex:(int)idx
{
    DPRINT((@"[PoCoControllerLayerDisplaySetter init]\n"));

    // super class を初期化
    self = [super initPict:pict withInfo:info withUndo:undo];

    // 自身を初期化
    if (self != nil) {
        self->index_ = idx;
        self->isDisplay_ = disp;
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
    DPRINT((@"[PoCoControllerLayerDisplaySetter dealloc]\n"));

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
//    isDisplay_   : 設定内容(instance 変数)
//
//  Return
//    function : 編集正否
//
-(BOOL)execute
{
    if (self->isDisplay_) {
        [[self->picture_ layer:self->index_] setIsDisplay];
    } else {
        [[self->picture_ layer:self->index_] clearIsDisplay];
    }

    // 取り消しの生成
    [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
        createLayerDisplaySetter:YES
                            disp:((self->isDisplay_) ? NO : YES)
                            index:self->index_];
    [super setUndoName:[[NSBundle mainBundle]
                           localizedStringForKey:@"LayerDisplaySet"
                                           value:@"set layer display"
                                           table:nil]]; 

    // 編集を通知する
    [[NSNotificationCenter defaultCenter]
        postNotificationName:PoCoEditLayer
                      object:[NSNumber numberWithBool:YES]];

    return YES;
}

@end
