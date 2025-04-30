//
//	Pelistina on Cocoa - PoCo -
//	画像レイヤー追加部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerLayerBitmapAdder.h"

#import "PoCoControllerFactory.h"
#import "PoCoControllerLayerDeleter.h"

// ============================================================================
@implementation PoCoControllerLayerBitmapAdder

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    c    : 初期色
//
//  Return
//    function : 実体
//    color_   : 初期色(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
    color:(unsigned char)c
{
    DPRINT((@"[PoCoControllerLayerBitmapAdder init]\n"));

    // super class を初期化
    self = [super initPict:pict withInfo:info withUndo:undo];

    // 自身を初期化
    if (self != nil) {
        self->color_ = c;
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
    DPRINT((@"[PoCoControllerLayerBitmapAdder dealloc]\n"));

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    picture_ : 編集対象画像(基底 instance 変数)
//    color_   : 初期色(instance 変数)
//
//  Return
//    function : 編集正否
//
-(BOOL)execute
{
    BOOL  result;
    PoCoErr er;

    result = NO;

    // 常に最上位に追加する
    er = [self->picture_ addLayer:-1
                            width:-1
                           height:-1
                            color:self->color_];
    if (er < ER_OK) {
        DPRINT((@"can't create layer : %d", er));
    } else {
        result = YES;

        // 取り消しを生成
        [self createUndo];

        // 編集を通知する
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoEditLayer
                          object:[NSNumber numberWithBool:YES]];
    }

    return result;
}


//
// 取り消しを生成
//
//  Call
//    picture_     : 編集対象画像(基底 instance 変数)
//    undoManager_ : 取り消し情報(基底 instance 変数)
//    factory_     : 編集部の生成部(基底 instance 変数)
//
//  Return
//    None
//
-(void)createUndo
{
    [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
        createLayerDeleter:YES
                     index:((int)([[self->picture_ layer] count]) - 1)];
    [super setUndoName:[[NSBundle mainBundle]
                           localizedStringForKey:@"LayerCreateBitmap"
                                           value:@"create bitmap layer"
                                           table:nil]]; 

    return;
}

@end
