//
//	Pelistina on Cocoa - PoCo -
//	レイヤー移動/複製部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerLayerMover.h"

#import "PoCoLayer.h"
#import "PoCoControllerFactory.h"
#import "PoCoControllerLayerNoEditter.h"
#import "PoCoControllerLayerInserter.h"
#import "PoCoControllerLayerDeleter.h"

// ============================================================================
@implementation PoCoControllerLayerMover

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    s    : 移動元
//    d    : 移動先
//    copy : 移動/複製の指定
//
//  Return
//    function : 実体
//    src_     : 移動元(instance 変数)
//    dst_     : 移動先(instance 変数)
//    isCopy_  : 移動/複製の指定(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
fromIndex:(int)s
  toIndex:(int)d
   isCopy:(BOOL)copy
{
    DPRINT((@"[PoCoControllerLayerMover init]\n"));

    // super class を初期化
    self = [super initPict:pict withInfo:info withUndo:undo];

    // 自身を初期化
    if (self != nil) {
        self->src_ = s;
        self->dst_ = d;
        self->isCopy_ = copy;
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
    DPRINT((@"[PoCoControllerLayerMover dealloc]\n"));

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    picture_ : 編集対象画像(基底 instance 変数)
//    factory_ : 編集部の生成部(基底 instance 変数)
//    src_     : 移動元(instance 変数)
//    dst_     : 移動先(instance 変数)
//    isCopy_  : 移動/複製の指定(instance 変数)
//
//  Return
//    function : 編集正否
//
-(BOOL)execute
{
    BOOL  result;
    id  cntl;
    int  target;
    PoCoLayerBase *layer;

    DPRINT((@"[PoCoControllerLayerMover execute]\n"));

    result = NO;

    // 挿入目標を算出
    target = self->dst_;
    if (self->isCopy_) {
        layer = [[self->picture_ layer:self->src_] copy];
        cntl = [self->factory_ createLayerInserter:NO
                                             layer:layer
                                             index:target];
        if ([cntl execute]) {
            result = YES;
            [self->undoManager_ setActionName:[[NSBundle mainBundle]
                                                  localizedStringForKey:@"LayerCopy"
                                                                  value:@"copy layer"
                                                                  table:nil]];
        }
        [cntl release];
        [layer release];
    } else {
        if (self->src_ == self->dst_) {
            goto EXIT;
        } else if (self->src_ > self->dst_) {
            ;
        } else if ((self->src_ + 1) == self->dst_) {
            goto EXIT;
        }

        // 無編集通知部を登録
        [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
            createLayerNoEditter:YES
                            name:nil
                          update:YES];

        // 複製を挿入
        layer = [[self->picture_ layer:self->src_] copy];
        cntl = [self->factory_ createLayerInserterPassive:NO
                                                    layer:layer
                                                    index:target];
        if ([cntl execute]) {
            result = YES;
            [cntl release];

            // 移動元を削除
            cntl = [self->factory_ createLayerDeleterPassive:NO
                                                       index:((self->src_ < self->dst_) ? self->src_ : (self->src_ + 1))];
            [cntl execute];
            [self->undoManager_ setActionName:[[NSBundle mainBundle]
                                                  localizedStringForKey:@"LayerMove"
                                                                  value:@"move layer"
                                                                  table:nil]];

            // 編集を通知する
            [[NSNotificationCenter defaultCenter]
                postNotificationName:PoCoEditLayer
                              object:[NSNumber numberWithBool:YES]];
        }
        [cntl release];
        [layer release];
    }

EXIT:
    return result;
}

@end
