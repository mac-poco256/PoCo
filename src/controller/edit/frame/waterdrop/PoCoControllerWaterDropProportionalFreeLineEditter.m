//
//	Pelistina on Cocoa - PoCo -
//	筆圧比例自由曲線 - ぼかし
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerWaterDropProportionalFreeLineEditter.h"

#import "PoCoEditWaterDropFactory.h"
#import "PoCoEditWaterDropDrawLineBase.h"

// ============================================================================
@implementation PoCoControllerWaterDropProportionalFreeLineEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    buf  : 色保持情報
//    s    : 描画始点(中心点)
//    e    : 描画終点(中心点)
//    idx  : 対象レイヤー番号
//    p    : 筆圧比例
//    name : 取り消し名称
//
//  Return
//    function  : 実体
//    undoName_ : 取り消し名称(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
    start:(PoCoPoint *)s
      end:(PoCoPoint *)e
    index:(int)idx
     prop:(BOOL)p
 undoName:(NSString *)name
{
//    DPRINT((@"[PoCoControllerWaterDropProportionalFreeLineEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:nil
                withBuffer:buf
                   withPen:nil
                  withTile:nil
                 withStart:s
                   withEnd:e
                    isProp:p
                   atIndex:idx];

    // 自身の初期化
    if (self != nil) {
        self->undoName_ = name;
        [self->undoName_ retain];
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
//    undoName_ : 取り消し名称(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerWaterDropProportionalFreeLineEditter dealloc]\n"));

    // 資源の解放
    [self->undoName_ release];
    self->undoName_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    picture_     : 編集対象画像(基底 instance 変数)
//    editInfo_    : 編集情報(基底 instance 変数)
//    colorBuffer_ : 色保持情報(基底 instance 変数)
//    layer_       : 対象レイヤー(基底 instance 変数)
//    undoName_    : 取り消し名称(instance 変数)
//
//  Return
//    function : 編集可否
//
-(BOOL)execute
{
    BOOL result;
    PoCoEditWaterDropDrawLineBase *edit;

    result = NO;
    edit = nil;

    // 編集開始
    if ([super startEdit:(PEN_STYLE_SIZE >> 1)
            withUndoCorr:(PEN_STYLE_SIZE >> 1)]) {
        // 編集系を生成
        edit = [PoCoEditWaterDropDrawLineFactory
                    create:[self->layer_ bitmap]
                   colMode:[self->editInfo_ colorMode]
                   palette:[self->picture_ palette]
                    buffer:self->colorBuffer_
                   penSize:[super selectPenSize]];

        // 編集実行
        [super drawFrame:edit];

        // 編集終了
        [super endEdit:self->undoName_];

        // 編集系を解放
        [edit release];

        // 正常終了
        result = YES;
    }

    return result;
}

@end
