//
//	Pelistina on Cocoa - PoCo -
//	パレット更新単純通知部(無編集)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerPaletteNoEditter.h"

#import "PoCoControllerFactory.h"

// ============================================================================
@implementation PoCoControllerPaletteNoEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    nm   : 取り消し名称
//    idx  : 対象パレット番号
//
//  Return
//    function     : 実体
//    name_        : 取り消し名称(instance 変数)
//    index_       : 対象パレット番号(instance 変数)
//    deallocPost_ : dealloc で通知(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
     name:(NSString *)nm
    index:(int)idx;
{
    DPRINT((@"[PoCoControllerPaletteNoEditter init]\n"));

    // super class を初期化
    self = [super initPict:pict withInfo:info withUndo:undo];

    // 自身を初期化
    if (self != nil) {
        self->deallocPost_ = NO;
        self->name_ = nm;
        self->index_ = idx;
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
    DPRINT((@"[PoCoControllerPaletteNoEditter dealloc]\n"));

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
//    name_        : 取り消し名称(instance 変数)
//    index_       : 対象パレット番号(instance 変数)
//
//  Return
//    function     : 編集正否
//    deallocPost_ : dealloc で通知(instance 変数)
//
-(BOOL)execute
{
    DPRINT((@"[PoCoControllerPaletteNoEditter execute]\n"));

    // 通知
    if ([self->undoManager_ isUndoing]) {
        self->deallocPost_ = NO;
        [self postNote];
    } else {
        self->deallocPost_ = YES;
    }

    // 取り消しの再登録
    [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
        createPaletteNoEditter:YES
                          name:self->name_
                         index:self->index_];

    // 取り消し名称の設定
    [super setUndoName:self->name_];

    return YES;
}


//
// 通知の送信
//
//  Call
//    index_ : 対象パレット番号(instance 変数)
//
//  Return
//    None
//
-(void)postNote
{
    if ((self->index_ >= 0) && (self->index_ < COLOR_MAX)) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoChangePalette
                          object:[NSNumber numberWithInt:self->index_]];
    } else {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoChangePalette
                          object:nil];
    }

    return;
}

@end
