//
//	Pelistina on Cocoa - PoCo -
//	筆圧比例自由曲線 - 通常
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerNormalProportionalFreeLineEditter.h"

#import "PoCoAppController.h"
#import "PoCoEditNormalDrawPoint.h"
#import "PoCoEditNormalDrawLine.h"

// ============================================================================
@implementation PoCoControllerNormalProportionalFreeLineEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict   : 編集対象画像
//    info   : 編集情報
//    undo   : 取り消し情報
//    eraser : 消しゴム用画像
//    pen    : ペン先
//    tile   : タイルパターン
//    s      : 描画始点(中心点)
//    e      : 描画終点(中心点)
//    idx    : 対象レイヤー番号
//    p      : 筆圧比例
//    name   : 取り消し名称
//
//  Return
//    function  : 実体
//    undoName_ : 取り消し名称(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   eraser:(PoCoColorPattern *)eraser
      pen:(PoCoPenStyle *)pen
     tile:(PoCoTilePattern *)tile
    start:(PoCoPoint *)s
      end:(PoCoPoint *)e
    index:(int)idx
     prop:(BOOL)p
 undoName:(NSString *)name
{
//    DPRINT((@"[PoCoControllerNormalProportionalFreeLineEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:info
                  withUndo:undo
                withEraser:eraser
                withBuffer:nil
                   withPen:pen
                  withTile:tile
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
//    DPRINT((@"[PoCoControllerNormalProportionalFreeLineEditter dealloc]\n"));

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
//    penStyle_    : ペン先(基底 instance 変数)
//    tilePattern_ : タイルパターン(基底 instance 変数)
//    colorBuffer_ : 色保持情報(基底 instance 変数)
//    layer_       : 対象レイヤー(基底 instance 変数)
//    drawPattern_ : 描画パターン(基底 instance 変数)
//    drawPen_     : 使用ペン先(基底 instance 変数)
//    drawTile_    : 使用タイルパターン(基底 instance 変数)
//    prop_        : 筆圧比例(基底 instance 変数)
//    undoName_    : 取り消し名称(instance 変数)
//
//  Return
//    function : 編集可否
//
-(BOOL)execute
{
    BOOL result;
    id edit;
    int pnum;                           // 算出したペン先の番号
    int tnum;                           // 算出した濃度の番号
    unsigned int press;                 // 筆圧
    PoCoMonochromePattern *pen;
    PoCoMonochromePattern *tile;

    result = NO;
    edit = nil;
    pen = nil;
    tile = nil;

    // 編集開始
    if ([super startEdit:(PEN_STYLE_SIZE >> 1)
            withUndoCorr:(PEN_STYLE_SIZE >> 1)]) {
        // ペン先太さの設定
        if (!(self->prop_) ||
             ([self->editInfo_ sizePropType] == PoCoProportionalType_Pattern)) {
            pen = self->drawPen_;
        } else {
            press = (([self->editInfo_ sizePropType] == PoCoProportionalType_Relation) ? [self->editInfo_ pressure] : 1000);
            pnum = MIN([self->editInfo_ penSize],
                       ((([self->editInfo_ penSize] * press) / 1000) + 1));
            pnum = (PEN_STYLE_NUM - pnum);
            pen = [[(PoCoAppController *)([NSApp delegate]) penSteadyStyle] pattern:pnum];
        }

        // 濃度の設定
        if (!(self->prop_) ||
            ([self->editInfo_ densityPropType] == PoCoProportionalType_Pattern)) {
            tile = self->drawTile_;
        } else {
            press = (([self->editInfo_ densityPropType] == PoCoProportionalType_Relation) ? [self->editInfo_ pressure] : 1000);
            tnum = MIN([self->editInfo_ density],
                       (([self->editInfo_ density] * press) / 1000));
            tnum = ((tnum * (TILE_PATTERN_NUM >> 1)) / 1000);
            tnum = ((tnum == 0) ? 0 : (tnum - 1));
            tnum += (([self->editInfo_ flipType]) ? (TILE_PATTERN_NUM >> 1) : 0);
            tile = [[(PoCoAppController *)([NSApp delegate]) tileSteadyPattern] pattern:tnum];
        }

        // 編集系を生成
        if (([self->editInfo_ continuationType]) &&
            (!([self->startPos_ isEqualPos:self->endPos_]))) {
            // 連続線分
            edit = [[PoCoEditNormalDrawLine alloc]
                       initWithPattern:[self->layer_ bitmap]
                               palette:[self->picture_ palette]
                                   pen:pen
                                  tile:tile
                               pattern:self->drawPattern_];
        } else {
            // 非連続線分
            edit = [[PoCoEditNormalDrawPoint alloc]
                       initWithPattern:[self->layer_ bitmap]
                               palette:[self->picture_ palette]
                                   pen:pen
                                  tile:tile
                               pattern:self->drawPattern_];
        }

        // 編集実行
        [super setCont];
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
