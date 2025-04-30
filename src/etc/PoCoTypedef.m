//
//	Pelistina on Cocoa - PoCo -
//	PoCo 共通定義
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoTypedef.h"

// ============================================================================
@implementation PoCoPoint

// ------------------------------------------------------------- class - public
//
// NSPoint の座標補正
//
//  Call
//    p : 補正する値
//
//  Return
//    function : 補正後の値
//
+(NSPoint)corrNSPoint:(NSPoint)p
{
    p.x -= 1.0;
    p.y -= 2.0;

    return p;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function : 実体
//
-(id)init
{
    return [self initX:0
                 initY:0];
}


//
// initialize(指定イニシャライザ)
//  座標の初期化つき
//
//  Call
//    px : X座標値
//    py : Y座標値
//
//  Return
//    function : 実体
//    x_       : X座標値(instance 変数)
//    y_       : Y座標値(instance 変数)
//
-(id)initX:(int)px
     initY:(int)py
{
//     DPRINT((@"[PoCoPoint initX:%d initY:%d]\n", px, py));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->x_ = px;
	self->y_ = py;
    }

    return self;
}


//
// initialize
//  NSPoint から生成
//
//  Call
//    p : 設定したい内容
//
//  Return
//    function : 実体
//
-(id)initNSPoint:(NSPoint)p
{
    return [self initX:(int)(floor(p.x))
                 initY:(int)(floor(p.y))];
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
//    DPRINT((@"[PoCoPoint dealloc]"));

    // super class を解放
    [super dealloc];

    return;
}


//
// 値の取得(X)
//
//  Call
//    x_ : X座標値(instance 変数)
//
//  Return
//    function : X座標値
//
-(int)x
{
    return self->x_;
}


//
// 値の取得(Y)
//
//  Call
//    y_ : Y座標値(instance 変数)
//
//  Return
//    function : Y座標値
//
-(int)y
{
    return self->y_;
}


//
// 値の設定(同時)
//
//  Call
//    px : X座標値
//    py : Y座標値
//
//  Return
//    x_ : X座標値(instance 変数)
//    y_ : Y座標値(instance 変数)
//
-(void)setX:(int)px
       setY:(int)py
{
    self->x_ = px;
    self->y_ = py;

    return;
}


//
// 値の設定(X)
//
//  Call
//    px : X座標値
//
//  Return
//    x_ : X座標値(instance 変数)
//
-(void)setX:(int)px
{
    self->x_ = px;

    return;
}


//
// 値の設定(Y)
//
//  Call
//    py : Y座標値
//
//  Return
//    y_ : Y座標値(instance 変数)
//
-(void)setY:(int)py
{
    self->y_ = py;

    return;
}


//
// 値の更新(同時)
//
//  Call
//    sx : X軸移動量
//    sy : Y軸移動量
//
//  Return
//    x_ : X座標値(instance 変数)
//    y_ : Y座標値(instance 変数)
//
-(void)moveX:(int)sx
       moveY:(int)sy
{
    self->x_ += sx;
    self->y_ += sy;

    return;
}


//
// 値の更新(X)
//
//  Call
//    sx : X軸移動量
//
//  Return
//    x_ : X座標値(instance 変数)
//    y_ : Y座標値(instance 変数)
//
-(void)moveX:(int)sx
{
    self->x_ += sx;

    return;
}


//
// 値の更新(Y)
//
//  Call
//    sy : Y軸移動量
//
//  Return
//    y_ : Y座標値(instance 変数)
//
-(void)moveY:(int)sy
{
    self->y_ += sy;

    return;
}


//
// 同値の確認
//
//  Call
//    p  : 確認相手
//    x_ : X座標値(instance 変数)
//    y_ : Y座標値(instance 変数)
//
//  Return
//    function : 正否
//
-(BOOL)isEqualPos:(PoCoPoint *)p
{
    return ((self->x_ == [p x]) && (self->y_ == [p y]));
}

@end




// ============================================================================
@implementation PoCoRect

// ------------------------------------------------------------- class - public
//
// PoCoRect から変換
//  天地反転はしない
//  (Cocoa の定義ではなく、PoCo の定義従い、左上原点として変換する)
//
//  Call
//    r : 変換元
//
//  Return
//    function : 変換結果
//
+(NSRect)toNSRect:(PoCoRect *)r
{
    NSRect nr;

    nr.origin.x = [r left];
    nr.origin.y = [r top];
    nr.size.width = [r width];
    nr.size.height = [r height];

    return nr;
}


//
// 拡張
//
//  Call
//    r   : 矩形枠
//    gap : 幅
//
//  Return
//    function : 矩形枠(引数と同じ)
//
+(PoCoRect *)expandRect:(PoCoRect *)r
                withGap:(int)gap
{
    [r   setLeft:([r   left] - gap)];
    [r    setTop:([r    top] - gap)];
    [r  setRight:([r  right] + gap)];
    [r setBottom:([r bottom] + gap)];

    return r;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function : 実体
//
-(id)init
{
    return [self initLeft:0
                  initTop:0
                initRight:0
               initBottom:0];
}


//
// initialize(指定イニシャライザ)
//
//  Call
//    left   : 左
//    top    : 上
//    right  : 右
//    bottom : 下
//
//  Return
//    function  : 実体
//    lefttop_  : 左上(instance 変数)
//    rightbot_ : 右上(instance 変数)
//
-(id)initLeft:(int)left
      initTop:(int)top
    initRight:(int)right
   initBottom:(int)bottom
{
//    DPRINT((@"[PoCoRect initLeft:%d initTop:%d initRight:%d initBottom:%d]\n", left, top, right, bottom));

    // super class を初期化
    self = [super init];

    // 自身を初期化
    if (self != nil) {
        self->lefttop_ = nil;
        self->rightbot_ = nil;

        // lefttop_ を生成
        self->lefttop_ = [[PoCoPoint alloc] initX:left
                                            initY:top];
        if (self->lefttop_ == nil) {
            [self release];
            self = nil;
            goto EXIT;
        }

        // rightbot_ を生成
        self->rightbot_ = [[PoCoPoint alloc] initX:right
                                             initY:bottom];
        if (self->rightbot_ == nil) {
            [self release];
            self = nil;
            goto EXIT;
        }
    }

EXIT:
    return self;
}


//
// initialize
//  NSRect から生成
//
//  Call
//    r : 設定したい値
//
//  Return
//    function : 実体
//
-(id)initNSRect:(NSRect)r
{
    return [self initLeft:(int)(floor(r.origin.x))
                  initTop:(int)(floor(r.origin.y))
                initRight:(int)(floor(r.origin.x + r.size.width))
               initBottom:(int)(floor(r.origin.y + r.size.height))];
}


//
// initialize
//  PoCoRect から生成
//
//  Call
//    r : 設定したい値
//
//  Return
//    function : 実体
//
-(id)initPoCoRect:(PoCoRect *)r
{
    return [self initLeft:[r left]
                  initTop:[r top]
                initRight:[r right]
               initBottom:[r bottom]];
}


//
// deallocate
//
//  Call
//    None
//
//  Return
//    lefttop_  : 左上(instance 変数)
//    rightbot_ : 右上(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoRect dealloc]\n"));

    // 各座標を解放
    [self->lefttop_ release];
    [self->rightbot_ release];
    self->lefttop_ = nil;
    self->rightbot_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// 値の取得(left)
//
//  Call
//    lefttop_ : 左上(instance 変数)
//
//  Return
//    function : 座標値
//
-(int)left
{
    return [self->lefttop_ x];
}


//
// 値の取得(top)
//
//  Call
//    lefttop_ : 左上(instance 変数)
//
//  Return
//    function : 座標値
//
-(int)top
{
    return [self->lefttop_ y];
}


//
// 値の取得(right)
//
//  Call
//    rightbot_ : 右下(instance 変数)
//
//  Return
//    function : 座標値
//
-(int)right
{
    return [self->rightbot_ x];
}


//
// 値の取得(bottom)
//
//  Call
//    rightbot_ : 右下(instance 変数)
//
//  Return
//    function : 座標値
//
-(int)bottom
{
    return [self->rightbot_ y];
}


//
// 値の取得(左上)
//
//  Call
//    lefttop_ : 左上(instance 変数)
//
//  Return
//    function : 左上
//
-(PoCoPoint *)lefttop
{
    return self->lefttop_;
}


//
// 値の取得(右下)
//
//  Call
//    rightbot_ : 右下(instance 変数)
//
//  Return
//    function : 右下
//
-(PoCoPoint *)rightbot
{
    return self->rightbot_;
}


//
// 値の取得(幅)
//
//  Call
//    lefttop_  : 左上(instance 変数)
//    rightbot_ : 右下(instance 変数)
//
//  Return
//    function : 値
//
-(int)width
{
    return ([self->rightbot_ x] - [self->lefttop_ x]);
}


//
// 値の取得(高さ)
//
//  Call
//    lefttop_  : 左上(instance 変数)
//    rightbot_ : 右下(instance 変数)
//
//  Return
//    function : 値
//
-(int)height
{
    return ([self->rightbot_ y] - [self->lefttop_ y]);
}


//
// 空の判定
//
//  Call
//    lefttop_  : 左上(instance 変数)
//    rightbot_ : 右下(instance 変数)
//
//  Return
//    function : YES : 空
//               NO  : 有効
//
-(BOOL)empty
{
    return (([self->lefttop_ x] >= [self->rightbot_ x]) ||
            ([self->lefttop_ y] >= [self->rightbot_ y]));
}


//
// NSRect で取得
//
//  Call
//    None
//
//  Return
//    function : 変換結果
//
-(NSRect)toNSRect
{
    return [PoCoRect toNSRect:self];
}


//
// 値の設定(左)
//
//  Call
//    left : 左
//
//  Return
//    lefttop_ : 左上(instance 変数)
//
-(void)setLeft:(int)left
{
    [self->lefttop_ setX:left];

    return;
}


//
// 値の設定(上)
//
//  Call
//    top : 上
//
//  Return
//    lefttop_ : 左上(instance 変数)
//
-(void)setTop:(int)top
{
    [self->lefttop_ setY:top];

    return;
}


//
// 値の設定(右)
//
//  Call
//    right : 右
//
//  Return
//    rightbot_ : 右下(instance 変数)
//
-(void)setRight:(int)right
{
    [self->rightbot_ setX:right];

    return;
}


//
// 値の設定(下)
//
//  Call
//    bottom : 下
//
//  Return
//    rightbot_ : 右下(instance 変数)
//
-(void)setBottom:(int)bottom
{
    [self->rightbot_ setY:bottom];

    return;
}


//
// 値の設定(左上)
//
//  Call
//    left : 左
//    top  : 上
//
//  Return
//    lefttop_ : 左上(instance 変数)
//
-(void)setLeft:(int)left
        setTop:(int)top
{
    [self->lefttop_ setX:left
                    setY:top];

    return;
}


//
// 値の設定(右下)
//
//  Call
//    right  : 右
//    bottom : 下
//
//  Return
//    rightbot_ : 右下(instance 変数)
//
-(void)setRight:(int)right
      setBottom:(int)bottom
{
    [self->rightbot_ setX:right
                     setY:bottom];

    return;
}


//
// 移動(水平移動)
//
//  Call
//    x : 水平移動量(dot 単位)
//
//  Return
//    None
//
-(void)shiftX:(int)x
{
    [self  setLeft:([self  left] + x)];
    [self setRight:([self right] + x)];

    return;
}


//
// 移動(垂直移動)
//
//  Call
//    y : 垂直移動量(dot 単位)
//
//  Return
//    None
//
-(void)shiftY:(int)y
{
    [self    setTop:([self    top] + y)];
    [self setBottom:([self bottom] + y)];

    return;
}


//
// 移動(水平/垂直同時)
//
//  Call
//    x : 水平移動量(dot 単位)
//    y : 垂直移動量(dot 単位)
//
//  Return
//    None
//
-(void)shiftX:(int)x
       shiftY:(int)y
{
    [self shiftX:x];
    [self shiftY:y];

    return;
}


//
// 同値の確認
//
//  Call
//    r         : 確認相手
//    lefttop_  : 左上(instance 変数)
//    rightbot_ : 右下(instance 変数)
//
//  Return
//    function : 正否
//
-(BOOL)isEqualRect:(PoCoRect *)r
{
    return (([self->lefttop_  isEqualPos:[r  lefttop]]) &&
            ([self->rightbot_ isEqualPos:[r rightbot]]));
}


//
// 点の包含の確認
//
//  Call
//    p         : 確認相手
//    lefttop_  : 左上(instance 変数)
//    rightbot_ : 右下(instance 変数)
//
//  Return
//    function : 正否
//
-(BOOL)isPointInRect:(PoCoPoint *)p
{
    return (([p x] >= [self->lefttop_ x]) && ([p y] >= [self->lefttop_ y]) &&
            ([p x] < [self->rightbot_ x]) && ([p y] < [self->rightbot_ y]));
}


//
// 拡張
//
//  Call
//    gap : 幅
//
//  Return
//    None
//
-(void)expand:(int)gap
{
    [PoCoRect expandRect:self
                 withGap:gap];

    return;
}

@end




// ============================================================================
@implementation PoCoSelColor

// ---------------------------------------------------------- instance - public
//
// initialize
//  色番号のみ初期設定する
//
//  Call
//    num : 初期番号(色番号)
//
//  Return
//    function    : 実体
//    isColor_    : 色番号かパターン番号か(instance 変数)
//    isUnder_    : 背面レイヤーを使用するか(instance 変数)
//    colorNum_   : 選択している色番号(instance 変数)
//    patternNum_ : 選択しているパターン番号(instance 変数)
//
-(id)initWithColorNum:(int)num
{
    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->isColor_ = YES;
        self->isUnder_ = NO;
        self->colorNum_ = num;
        self->patternNum_ = 0;
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
    // super class を解放
    [super dealloc];

    return;
}


//
// 色番号か
//
//  Call
//    isColor_ : 色番号かパターン番号か(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)isColor
{
    return self->isColor_;
}


//
// パターン番号か
//
//  Call
//    isColor_ : 色番号かパターン番号か(instance 変数)
//
//  Return
//    function : 設定内容
//
-(BOOL)isPattern
{
    return ((self->isColor_) ? NO : YES);
}


//
// 背面レイヤーを使用するか
//
//  Call
//    isUnder_ : 背面レイヤーを使用するか(instance 変数)
//
//  Return
//    function : 設定内容
//
//
-(BOOL)isUnder
{
    return self->isUnder_;
}


//
// 設定番号の取得
//
//  Call
//    isColor_    : 色番号かパターン番号か(instance 変数)
//    colorNum_   : 選択している色番号(instance 変数)
//    patternNum_ : 選択しているパターン番号(instance 変数)
//
//  Return
//    function : 番号
//
-(unsigned int)num
{
    return ((self->isColor_) ? self->colorNum_ : self->patternNum_);
}


//
// 色番号を設定
//
//  Call
//    num : 設定番号
//
//  Return
//    isColor_  : 色番号かパターン番号か(instance 変数)
//    isUnder_  : 背面レイヤーを使用するか(instance 変数)
//    colorNum_ : 選択している色番号(instance 変数)
//
-(void)setColor:(int)num
{
    self->isColor_ = YES;
    self->isUnder_ = NO;
    self->colorNum_ = num;

    return;
}


//
// パターン番号を設定
//
//  Call
//    num : 設定番号
//
//  Return
//    isColor_    : 色番号かパターン番号か(instance 変数)
//    isUnder_    : 背面レイヤーを使用するか(instance 変数)
//    patternNum_ : 選択しているパターン番号(instance 変数)
//
-(void)setPattern:(int)num
{
    self->isColor_ = NO;
    self->isUnder_ = NO;
    self->patternNum_ = num;

    return;
}


//
// 背面レイヤーの使用の切り替え
//
//  Call
//    isUnder_ : 背面レイヤーを使用するか(instance 変数)
//
//  Return
//    isUnder_ : 背面レイヤーを使用するか(instance 変数)
//
-(void)toggleUnder
{
    self->isUnder_ = ((self->isUnder_) ? NO : YES);

    return;
}

@end




// ============================================================================
@implementation PoCoEditPictureNotification

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    r   : 再描画領域
//    idx : 対象レイヤー番号
//
//  Return
//    function : 実体
//    rect_    : 再描画領域(instance 変数)
//    index_   : 対象レイヤー番号(instance 変数)
//
-(id)initWithRect:(PoCoRect *)r
          atIndex:(int)idx
{
//    DPRINT((@"[PoCoEditPictureNotification initWithRect: atIndex:]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->rect_ = r;
        self->index_ = idx;
        [self->rect_ retain];
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
//    rect_ : 再描画領域(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoEditPictureNotification dealloc]\n"));

    // 資源の解放
    [self->rect_ release];
    self->rect_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 再描画領域の取得
//
//  Call
//    rect_ : 再描画領域(instance 変数)
//
//  Return
//    function : 再描画領域
//
-(PoCoRect *)rect
{
    return self->rect_;
}


//
// 対象レイヤー番号の取得
//
//  Call
//    index_ : 対象レイヤー番号(instance 変数)
//
//  Return
//    function : 対象レイヤー番号
//
-(int)index
{
    return self->index_;
}

@end




// ============================================================================
@implementation PoCoMainViewSupplement

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    color_   : 色(0xffRRGGBB)(instance 変数)
//    pattern_ : 背景の種類(instance 変数)
//               YES: パターン
//               NO:  単色
//    step_    : 実線のステップ数(instance 変数)
//
-(id)init
{
//    DPRINT((@"[PoCoMainViewSupplement init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->color_ = 0xffffffff;
        self->pattern_ = NO;
        self->step_ = 0;
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
//    DPRINT((@"[PoCoMainViewSupplement dealloc]\n"));

    // 資源の解放
    ;

    // super class の解放
    [super dealloc];

    return;
}


//
// 背景色取得
//
//  Call
//    color_ : 色(0xffRRGGBB)(instance 変数)
//
//  Return
//    function : 設定値
//
-(unsigned int)backgroundColor
{
    return self->color_;
}


//
// 背景種類取得
//
//  Call
//    pattern_ : 背景の種類(instance 変数)
//
//  Return
//    function : 設定値
//
-(BOOL)isPattern
{
    return self->pattern_;
}


//
// 背景色設定
//
//  Call
//    col : 設定値
//
//  Return
//    color_ : 色(0xffRRGGBB)(instance 変数)
//
-(void)setBackgroundColor:(unsigned int)col
{
    self->color_ = col;

    return;
}


//
// 背景種類設定
//
//  Call
//    flag : 設定値
//
//  Return
//    pattern_ : 背景の種類(instance 変数)
//
-(void)setPattern:(BOOL)flag
{
    self->pattern_ = flag;

    return;
}


//
// ピクセルグリッド実線ステップ取得
//
//  Call
//    step_ : 実線のステップ数(instance 変数)
//
//  Return
//    function : 設定値
//
-(unsigned int)gridStep
{
    return self->step_;
}


//
// ピクセルグリッド実線ステップ設定
//
//  Call
//    step : 設定値
//
//  Return
//    step_ : 実線のステップ数(instance 変数)
//
-(void)setGridStep:(unsigned int)step
{
    self->step_ = step;

    return;
}

@end




// ============================================================================
@implementation PoCoGradationPairInfo

// ------------------------------------------------------------- class - public
//
// 文字列化
//
//  Call
//    first  : 上位色番号
//    second : 下位色番号
//
//  Return
//    function : 文字列
//
+(NSString *)pairString:(unsigned int)first
             withSecond:(unsigned int)second
{
    return [NSString stringWithFormat:@"%03d%03d", first, second];
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    first  : 上位色番号
//    second : 下位色番号
//    size   : 大きさ
//
//  Return
//    function : 実体
//    first_   : 上位色番号(instance 変数)
//    second_  : 下位色番号(instance 変数)
//    size_    : 大きさ(instance 変数)
//
-(id)initWithFirst:(unsigned int)first
        withSecond:(unsigned int)second
          withSize:(int)size
{
    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->first_ = first;
        self->second_ = second;
        self->size_ = size;
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
    // 資源の解放
    ;

    // super class の解放
    [super dealloc];

    return;
}


//
// 名称を取得
//
//  Call
//    first_  : 上位色番号(instance 変数)
//    second_ : 下位色番号(instance 変数)
//
//  Return
//    function : 文字列
//
-(NSString *)name
{
    return [PoCoGradationPairInfo pairString:self->first_
                                  withSecond:self->second_];
}


//
// 上位色番号を取得
//
//  Call
//    first_ : 上位色番号(instance 変数)
//
//  Return
//    function : 設定値 
//
-(unsigned int)first
{
    return self->first_;
}


//
// 下位色番号を取得
//
//  Call
//    second_ : 下位色番号(instance 変数)
//
//  Return
//    function : 設定値 
//
-(unsigned int)second
{
    return self->second_;
}


//
// 大きさを取得
//
//  Call
//    size_ : 大きさ(instance 変数)
//
//  Return
//    function : 設定値 
//
-(int)size
{
    return self->size_;
}


//
// 大きさを取得(slider 用)
//
//  Call
//    size_ : 大きさ(instance 変数)
//
//  Return
//    function : 設定値 
//
-(int)sizeForSlider
{
    return (self->size_ / 8);
}


//
// 上位色番号を設定
//
//  Call
//    val : 設定値 
//
//  Return
//    first_ : 上位色番号(instance 変数)
//
-(void)setFirst:(unsigned int)val
{
    self->first_ = val;

    return;
}


//
// 下位色番号を設定
//
//  Call
//    val : 設定値 
//
//  Return
//    second_ : 下位色番号(instance 変数)
//
-(void)setSecond:(unsigned int)val
{
    self->second_ = val;

    return;
}


//
// 大きさを設定
//
//  Call
//    val : 設定値 
//
//  Return
//    size_ : 大きさ(instance 変数)
//
-(void)setSize:(int)val
{
    self->size_ = val;

    return;
}

@end




// ============================================================================
@implementation PoCoBaseGradientPair

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    b  : base color
//    cl : colors of replacing
//
//  Return
//    base_   : base color(instance value)
//    colors_ : colors of replacing(instance value)
//
-(id)init:(unsigned int)b
   colors:(NSArray *)cl
{
    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->base_ = b;
        self->colors_ = cl;
        [self->colors_ retain];
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
//    colors_ : colors of replacing(instance value)
//
-(void)dealloc
{
    // 資源の解放
    [self->colors_ release];
    self->colors_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// base color を取得
//
//  Call
//    base_ : base color(instance value)
//
//  Return
//    function : base color
//
-(unsigned int)base
{
    return self->base_;
}


//
// colors を取得
//
//  Call
//    colors_ : colors of replacing(instance value)
//
//  Return
//    function : colors of replacing
//
-(NSArray *)colors
{
    return self->colors_;
}

@end
