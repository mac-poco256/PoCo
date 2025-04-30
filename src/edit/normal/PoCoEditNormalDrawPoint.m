//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 標準 - 点の描画
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditNormalDrawPoint.h"

// ============================================================================
@implementation PoCoEditNormalDrawPoint

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp  : 描画対象 bitmap
//    plt  : 使用パレット
//    pen  : 使用ペン先
//    tile : 使用タイルパターン
//    pat  : 使用カラーパターン
//
//  Return
//    function : 実体
//    points_   : 点(instance 変数)
//
-(id)initWithPattern:(PoCoBitmap *)bmp
             palette:(PoCoPalette *)plt
                 pen:(PoCoMonochromePattern *)pen
                tile:(PoCoMonochromePattern *)tile
             pattern:(PoCoColorPattern *)pat
{
//    DPRINT((@"[PoCoEditNormalDrawPoint initWithPattern]\n"));

    // super class の初期化
    self = [super initWithPattern:bmp
                          palette:plt
                              pen:pen
                             tile:tile
                          pattern:pat];

    // 自身の初期化
    if (self != nil) {
        // 点の保持部の生成
        self->points_ = [[NSMutableArray alloc] init];
        if (self->points_ == nil) {
            DPRINT((@"can't alloc NSMutableArray\n"));
            [self release];
            self = nil;
        }
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
//    points_ : 点(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoEditNormalDrawPoint dealloc]\n"));

    // 資源の解放
    [self->points_ removeAllObjects];
    [self->points_ release];
    self->points_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 点の登録
//
//  Call
//    p : 登録する点
//
//  Return
//    points_ : 点(instance 変数)
//
-(void)addPoint:(PoCoPoint *)p
{
    PoCoPoint *tmp;

    tmp = [[PoCoPoint alloc] initX:[p x] initY:[p y]];
    [self->points_ addObject:tmp];
    [tmp release];

    return;
}


//
// 実行
//
//  Call
//    points_ : 点(instance 変数)
//
//  Return
//    None
//
-(void)executeDraw
{
    NSEnumerator *iter;
    PoCoPoint *p;

    iter = [self->points_ objectEnumerator];
    for (p = [iter nextObject]; p != nil; p = [iter nextObject]) {
        [super drawPoint:p];
    }

    return;
}

@end
