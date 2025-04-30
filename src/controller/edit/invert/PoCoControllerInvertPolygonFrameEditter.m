//
//	Pelistina on Cocoa - PoCo -
//	直線群(閉路) - 反転
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerInvertPolygonFrameEditter.h"

#import "PoCoEditInvertDrawLine.h"

// ============================================================================
@implementation PoCoControllerInvertPolygonFrameEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    p    : 支点群
//    idx  : 対象レイヤー番号
//
//  Return
//    function : 実体
//    points_  : 支点群(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     poly:(NSMutableArray *)p
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerInvertPolygonFrameEditter init]\n"));

    // super class の初期化
    self = [super initPict:pict
                  withInfo:nil
                  withUndo:nil
                withEraser:nil
                withBuffer:nil
                   withPen:nil
                  withTile:nil
                   atIndex:idx];

    // 自身の初期化
    if (self != nil) {
        self->points_ = p;
        [self->points_ retain];
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
//    points_ : 支点群(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerInvertPolygonFrameEditter dealloc]\n"));

    // 資源の解放
    [self->points_ release];
    self->points_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    layer_  : 対象レイヤー(基底 instance 変数)
//    points_ : 支点群(instance 変数)
//
//  Return
//    function : 編集可否
//
-(BOOL)execute
{
    PoCoEditInvertDrawLine *edit;
    PoCoRect *r;
    NSEnumerator *iter;
    PoCoPoint *p;

    r = [[PoCoRect alloc] initLeft:INT_MAX
                           initTop:INT_MAX
                         initRight:INT_MIN
                        initBottom:INT_MIN];

    // 描画実行
    edit = [[PoCoEditInvertDrawLine alloc] initWithBitmap:[self->layer_ bitmap]
                                               isZeroOnly:NO];
    if (edit != nil) {
        iter = [self->points_ objectEnumerator];
        for (p = [iter nextObject]; p != nil; p = [iter nextObject]) {
            [edit addPoint:p];

            // 再描画範囲算出
            if (([p x] - (PEN_STYLE_SIZE >> 1)) < [r left]) {
                [r setLeft:([p x] - (PEN_STYLE_SIZE >> 1))];
            }
            if (([p y] - (PEN_STYLE_SIZE >> 1)) < [r top]) {
                [r setTop:([p y] - (PEN_STYLE_SIZE >> 1))];
            }
            if (([p x] + (PEN_STYLE_SIZE >> 1)) > [r right]) {
                [r setRight:([p x] + (PEN_STYLE_SIZE >> 1))];
            }
            if (([p y] + (PEN_STYLE_SIZE >> 1)) > [r bottom]) {
                [r setBottom:([p y] + (PEN_STYLE_SIZE >> 1))];
            }
        }
        [edit addPoint:[[self->points_ objectEnumerator] nextObject]];
        [edit executeDraw];
    }
    [super correctRect:r];

    // 描画実行を通知
    [r expand:(PEN_STYLE_SIZE >> 1)];
    [super correctRect:r];
    [super postNotifyNoEdit:r];

    // 正常終了
    [edit release];
    [r release];

    return YES;                         // 常時 YES
}

@end
