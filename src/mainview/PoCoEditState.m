//
//	Pelistina on Cocoa - PoCo -
//	編集状態管理
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditState.h"

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"

// ============================================================================
@implementation PoCoEditState

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function  : 実体
//    point_[]  : 座標の管理(instance 変数)
//    editInfo_ : 編集情報(instance 変数)
//    count_    : 編集回数(instance 変数)
//    isEdit_   : 編集状態(instance 変数)
//
-(id)init
{
    DPRINT((@"[PoCoEditState init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->point_[0] = nil;
        self->point_[1] = nil;
        self->point_[2] = nil;
        self->count_ = 0;
        self->isEdit_ = NO;

        // 編集情報の取得
        self->editInfo_ = [(PoCoAppController *)([NSApp delegate]) editInfo];
        [self->editInfo_ retain];
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
//    point_[]  : 座標の管理(instance 変数)
//    editInfo_ : 編集情報(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoEditState dealloc]\n"));

    // 資源の解放
    [self->point_[0] release];
    [self->point_[1] release];
    [self->point_[2] release];
    [self->editInfo_ release];
    self->point_[0] = nil;
    self->point_[1] = nil;
    self->point_[2] = nil;
    self->editInfo_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集開始
//
//  Call
//    None
//
//  Return
//    point_[] : 座標の管理(instance 変数)
//    count_   : 編集回数(instance 変数)
//    isEdit_  : 編集状態(instance 変数)
//
-(void)beginEditMode
{
    // 以前の点は残さない
    [self clearFirstPoint];
    [self clearSecondPoint];
    [self clearThirdPoint];

    // 編集開始
    self->count_ = 0;
    self->isEdit_ = YES;

    return;
}


//
// 編集終了
//
//  Call
//    None
//
//  Return
//    isEdit_ : 編集状態(instance 変数)
//
-(void)endEditMode
{
    self->isEdit_ = NO;

    // 各座標を解放する
    [self clearFirstPoint];
    [self clearSecondPoint];
    [self clearThirdPoint];

    return;
}


//
// 編集回数
//
//  Call
//    None
//
//  Return
//    count_ : 編集回数(instance 変数)
//
-(void)countUpEdit
{
    if (self->count_ < __INT_MAX__) {
        (self->count_)++;
    }

    return;
}


//
// 取得(編集回数)
//
//  Call
//    count_ : 編集回数(instance 変数)
//
//  Return
//    function : 編集回数
//
-(int)count
{
    return self->count_;
}


//
// 編集状態
//
//  Call
//    isEdit_ : 編集状態(instance 変数)
//
//  Return
//    function : 編集状態
//
-(BOOL)isEdit
{
    return self->isEdit_;
}


// ----------------------------------------- instance - public - 座標の管理関連
//
// 1点目の取得
//  普通は編集始点
//
//  Call
//    point_[] : 座標の管理(instance 変数)
//
//  Return
//    function : 座標
//
-(PoCoPoint *)firstPoint
{
    return self->point_[0];
}


//
// 2点目の取得
//  平行四辺形系では中継点
//  他は普通は終点
//
//  Call
//    point_[] : 座標の管理(instance 変数)
//
//  Return
//    function : 座標
//
-(PoCoPoint *)secondPoint
{
    return self->point_[1];
}


//
// 3点目の取得
//  平行四辺形の終点
//
//  Call
//    point_[] : 座標の管理(instance 変数)
//
//  Return
//    function : 座標
//
-(PoCoPoint *)thirdPoint
{
    return self->point_[2];
}


//
// 1点目の設定
//
//  Call
//    p         : == nil : 編集情報中の座標を保持
//                != nil : 指示された座標を保持
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    point_[] : 座標の管理(instance 変数)
//
-(void)setFirstPoint:(PoCoPoint *)p
{
    // nil の場合は編集情報より取得
    if (p == nil) {
        p = [self->editInfo_ pdPos];
    }

    // 以前の分を解放
    [self clearFirstPoint];

    // 座標を複製
    self->point_[0] = [[PoCoPoint alloc] initX:[p x]
                                         initY:[p y]];

    return;
}


//
// 2点目の設定
//
//  Call
//    p         : == nil : 編集情報中の座標を保持
//                != nil : 指示された座標を保持
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    point_[] : 座標の管理(instance 変数)
//
-(void)setSecondPoint:(PoCoPoint *)p
{
    // nil の場合は編集情報より取得
    if (p == nil) {
        p = [self->editInfo_ pdPos];
    }

    // 以前の分を解放
    [self clearSecondPoint];

    // 座標を複製
    self->point_[1] = [[PoCoPoint alloc] initX:[p x]
                                         initY:[p y]];

    return;
}


//
// 3点目の設定
//
//  Call
//    p         : == nil : 編集情報中の座標を保持
//                != nil : 指示された座標を保持
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    point_[] : 座標の管理(instance 変数)
//
-(void)setThirdPoint:(PoCoPoint *)p
{
    // nil の場合は編集情報より取得
    if (p == nil) {
        p = [self->editInfo_ pdPos];
    }

    // 以前の分を解放
    [self clearThirdPoint];

    // 座標を複製
    self->point_[2] = [[PoCoPoint alloc] initX:[p x]
                                         initY:[p y]];

    return;
}


//
// 1点目の消去
//
//  Call
//    None
//
//  Return
//    point_[] : 座標の管理(instance 変数)
//
-(void)clearFirstPoint
{
    [self->point_[0] release];
    self->point_[0] = nil;

    return;
}


//
// 2点目の消去
//
//  Call
//    None
//
//  Return
//    point_[] : 座標の管理(instance 変数)
//
-(void)clearSecondPoint
{
    [self->point_[1] release];
    self->point_[1] = nil;

    return;
}


//
// 3点目の消去
//
//  Call
//    None
//
//  Return
//    point_[] : 座標の管理(instance 変数)
//
-(void)clearThirdPoint
{
    [self->point_[2] release];
    self->point_[2] = nil;

    return;
}


//
// 1点目を設定すべきか
//
//  Call
//    point_[] : 座標の管理(instance 変数)
//
//  Return
//    function : 可否
//
-(BOOL)isFirstPoint
{
    return (self->point_[0] == nil);
}


//
// 2点目を設定すべきか
//
//  Call
//    point_[] : 座標の管理(instance 変数)
//
//  Return
//    function : 可否
//
-(BOOL)isSecondPoint
{
    return (self->point_[0] != nil);
}


//
// 3点目を設定すべきか
//
//  Call
//    point_[] : 座標の管理(instance 変数)
//
//  Return
//    function : 可否
//
-(BOOL)isThirdPoint
{
    return (self->point_[1] != nil);
}


//
// 1点目を持っているか
//
//  Call
//    point_[] : 座標の管理(instance 変数)
//
//  Return
//    function : 可否
//
-(BOOL)hasFirstPoint
{
    return (self->point_[0] != nil);
}


//
// 2点目を持っているか
//
//  Call
//    point_[] : 座標の管理(instance 変数)
//
//  Return
//    function : 可否
//
-(BOOL)hasSecondPoint
{
    return (self->point_[1] != nil);
}


//
// 3点目を持っているか
//
//  Call
//    point_[] : 座標の管理(instance 変数)
//
//  Return
//    function : 可否
//
-(BOOL)hasThirdPoint
{
    return (self->point_[2] != nil);
}


//
// 起点固定
//  編集の進行に合わせた値を返す
//
//  Call
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    function : 正否
//
-(BOOL)isPointHold
{
    return ([self->editInfo_ pointModeType] == PoCoPointModeType_PointHold);
}


//
// 起点移動
//  編集の進行に合わせた値を返す
//
//  Call
//    editInfo_ : 編集情報(instance 変数)
//
//  Return
//    function : 正否
//
-(BOOL)isPointMove
{
    return ([self->editInfo_ pointModeType] == PoCoPointModeType_PointMove);
}


//
// 形状固定
//  編集の進行に合わせた値を返す
//
//  Call
//    editInfo_ : 編集情報(instance 変数)
//    count_    : 編集回数(instance 変数)
//
//  Return
//    function : 正否
//
-(BOOL)isIdenticalShape
{
    return (
        ([self->editInfo_ pointModeType] == PoCoPointModeType_IdenticalShape)
        &&
        (self->count_ > 0)
    );
}


//
// 点の移動
//
//  Call
//    x : 水平変量
//    y : 垂直変量
//
//  Return
//    point_[] : 座標の管理(instance 変数)
//
-(void)moveX:(int)x
       moveY:(int)y
{
    [self->point_[0] moveX:x
                     moveY:y];
    [self->point_[1] moveX:x
                     moveY:y];
    [self->point_[2] moveX:x
                     moveY:y];

    return;
}

@end
