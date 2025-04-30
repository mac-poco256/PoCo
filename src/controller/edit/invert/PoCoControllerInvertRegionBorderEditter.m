//
//	Pelistina on Cocoa - PoCo -
//	任意領域境界 - 反転
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerInvertRegionBorderEditter.h"

#import "PoCoEditInvertRegionBorder.h"

// ============================================================================
@implementation PoCoControllerInvertRegionBorderEditter

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    pict : 編集対象画像
//    mask : 形状マスク
//    r    : 描画範囲
//    idx  : 対象レイヤー番号
//
//  Return
//    function : 実体
//    mask_    : 形状マスク(instance 変数)
//    rect_    : 描画範囲(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     mask:(PoCoBitmap *)mask
     rect:(PoCoRect *)r
    index:(int)idx
{
//    DPRINT((@"[PoCoControllerInvertRegionBorderEditter init]\n"));

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
        self->rect_ = [[PoCoRect alloc] initLeft:[r left]
                                         initTop:[r top]
                                       initRight:[r right]
                                      initBottom:[r bottom]];
        self->mask_ = mask;
        [self->mask_ retain];
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
//    mask_ : 形状マスク(instance 変数)
//    rect_ : 描画範囲(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerInvertRegionBorderEditter dealloc]\n"));

    // 資源の解放
    [self->mask_ release];
    [self->rect_ release];
    self->mask_ = nil;
    self->rect_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    layer_ : 対象レイヤー(基底 instance 変数)
//    mask_  : 形状マスク(instance 変数)
//    rect_  : 描画範囲(instance 変数)
//
//  Return
//    function : 編集可否
//
-(BOOL)execute
{
    PoCoEditInvertRegionBorder *edit;

    // 描画実行
    edit = [[PoCoEditInvertRegionBorder alloc] initWithBitmap:[self->layer_ bitmap]
                                             withMaskBitmap:self->mask_
                                               withDrawRect:self->rect_
                                                 isZeroOnly:NO];
    [edit executeDraw];

    // 描画実行を通知
    [self->rect_ expand:PEN_STYLE_SIZE];
    [super correctRect:self->rect_];
    [super postNotifyNoEdit:self->rect_];

    // 正常終了
    [edit release];

    return YES;                         // 常時 YES
}

@end
