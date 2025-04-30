//
//	Pelistina on Cocoa - PoCo -
//	色保持
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoColorBuffer.h"

#import "PoCoPalette.h"

// ===================================================== PoCoColorBufferElement 

// ------------------------------------------------------------------ interface
@interface PoCoColorBufferElement : NSObject
{
    unsigned char index_;               // 色番号
    unsigned char r_;                   // 色要素(赤)
    unsigned char g_;                   // 色要素(緑)
    unsigned char b_;                   // 色要素(青)
}

// initialize
-(id)init:(unsigned char)index
  withRed:(unsigned char)r
withGreen:(unsigned char)g
 withBlue:(unsigned char)b;

// deallocate
-(void)dealloc;

// property(get)
-(unsigned char)index;
-(NSString *)name;

// property(set)
-(void)setIndex:(unsigned char)index;

@end


// ------------------------------------------------------------------ implement
@implementation PoCoColorBufferElement

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    index : 色番号
//    r     : 色要素(赤)
//    g     : 色要素(緑)
//    b     : 色要素(青)
//
//  Return
//    index_ : 色番号(instance 変数)
//    r_     : 色要素(赤)(instance 変数)
//    g_     : 色要素(緑)(instance 変数)
//    b_     : 色要素(青)(instance 変数)
//
-(id)init:(unsigned char)index
  withRed:(unsigned char)r
withGreen:(unsigned char)g
 withBlue:(unsigned char)b
{
    // super class へ回送
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->index_ = index;
        self->r_ = r;
        self->g_ = g;
        self->b_ = b;
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
    // super class へ回送
    [super dealloc];

    return;
}


//
// 色番号取得
//
//  Call
//    index_ : 色番号(instance 変数)
//
//  Return
//    function : 色番号
//
-(unsigned char)index
{
    return self->index_;
}


//
// 色名称取得
//
//  Call
//    r_ : 色要素(赤)(instance 変数)
//    g_ : 色要素(緑)(instance 変数)
//    b_ : 色要素(青)(instance 変数)
//
//  Return
//    function : 文字列
//
-(NSString *)name
{
    return [NSString stringWithFormat:@"rgb:%02x%02x%02x", self->r_, self->g_, self->b_];
}


//
// 色番号設定
//
//  Call
//    index : 色番号
//
//  Return
//    index_ : 色番号(instance 変数)
//
-(void)setIndex:(unsigned char)index
{
    self->index_ = index;
}
@end




// =================================================== PoCoColorOnceCalcElement 

// ------------------------------------------------------------------ interface
@interface PoCoColorOnceCalcElement : NSObject
{
    PoCoColorMode colMode_;             // 色演算モード
    int density1_;                      // 濃度(0.1%単位)(塗装色(i1)用)
    int density2_;                      // 濃度(0.1%単位)(塗装色(i2)用)
    unsigned char index1_;              // 色1(描画先色番号)
    unsigned char index2_;              // 色2(塗装色番号)
    unsigned char result_;              // 演算結果の色番号
}

// class method
+(NSString *)createName:(PoCoColorMode)colMode
           withDensity1:(int)d1
           withDensity2:(int)d2
             withColor1:(unsigned char)i1
             withColor2:(unsigned char)i2;

// initialize
-(id)init:(PoCoColorMode)colMode
withDensity1:(int)d1
withDensity2:(int)d2
  withColor1:(unsigned char)i1
  withColor2:(unsigned char)i2
  withResult:(unsigned char)ch;

// deallocate
-(void)dealloc;

// property(get)
-(unsigned char)index;
-(NSString *)name;

@end


// ------------------------------------------------------------------ implement
@implementation PoCoColorOnceCalcElement

// ------------------------------------------------------------- class - public
//
// 色名称取得
//
//  Call
//    colMode : 色演算モード
//    d1      : 濃度(0.1%単位)(塗装色(i1)用)
//    d2      : 濃度(0.1%単位)(塗装色(i2)用)
//    i1      : 色1(描画先色番号)
//    i2      : 色2(塗装色番号)
//
//  Return
//    function : 文字列
//
+(NSString *)createName:(PoCoColorMode)colMode
           withDensity1:(int)d1
           withDensity2:(int)d2
             withColor1:(unsigned char)i1
             withColor2:(unsigned char)i2
{
    return [NSString stringWithFormat:@"once:%d%04d%04d%02d%02d", (int)(colMode), d1, d2, i1, i2];
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    colMode : 色演算モード
//    d1      : 濃度(0.1%単位)(塗装色(i1)用)
//    d2      : 濃度(0.1%単位)(塗装色(i2)用)
//    i1      : 色1(描画先色番号)
//    i2      : 色2(塗装色番号)
//    ch      : 演算結果の色番号
//
//  Return
//    colMode_  : 色演算モード(instance 変数)
//    density1_ : 濃度(0.1%単位)(塗装色(i1)用)(instance 変数)
//    density2_ : 濃度(0.1%単位)(塗装色(i2)用)(instance 変数)
//    index1_   : 色1(描画先色番号)(instance 変数)
//    index2_   : 色2(塗装色番号)(instance 変数)
//    result_   : 演算結果の色番号(instance 変数)
//
-(id)init:(PoCoColorMode)colMode
withDensity1:(int)d1
withDensity2:(int)d2
  withColor1:(unsigned char)i1
  withColor2:(unsigned char)i2
  withResult:(unsigned char)ch
{
    // super class へ回送
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->colMode_ = colMode;
        self->density1_ = d1;
        self->density2_ = d2;
        self->index1_ = i1;
        self->index2_ = i2;
        self->result_ = ch;
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
    // super class へ回送
    [super dealloc];

    return;
}


//
// 色番号取得
//
//  Call
//    result_ : 演算結果の色番号(instance 変数)
//
//  Return
//    function : 色番号
//
-(unsigned char)index
{
    return self->result_;
}


//
// 色名称取得
//
//  Call
//    colMode_  : 色演算モード(instance 変数)
//    density1_ : 濃度(0.1%単位)(塗装色(i1)用)(instance 変数)
//    density2_ : 濃度(0.1%単位)(塗装色(i2)用)(instance 変数)
//    index1_   : 色1(描画先色番号)(instance 変数)
//    index2_   : 色2(塗装色番号)(instance 変数)
//
//  Return
//    function : 文字列
//
-(NSString *)name
{
    return [PoCoColorOnceCalcElement createName:self->colMode_
                                   withDensity1:self->density1_
                                   withDensity2:self->density2_
                                     withColor1:self->index1_
                                     withColor2:self->index2_];
}

@end




// ============================================================================
@implementation PoCoColorBuffer


// ------------------------------------------------------------- class - public
//
// 検索
//
//  Call
//    palette : パレット(nil 不可)
//    r       : 対象色(赤)
//    g       : 対象色(緑)
//    b       : 対象色(青)
//
//  Return
//    function : 色番号
//
+(unsigned char)find:(PoCoPalette *)palette
             withRed:(unsigned char)r
           withGreen:(unsigned char)g
            withBlue:(unsigned char)b
{
    unsigned char index;
    int l;
    PoCoColor *col;
    int diff;                           // 候補色の色距離
    int cdiff;                          // 選択色の色距離

    diff = INT_MAX;
    index = 0;

    for (l = 0; l < COLOR_MAX; (l)++) {
        col = [palette palette:l];
        if ([col noDropper]) {
            // 使用禁止
            ; 
        } else {
            cdiff =   abs(r - [col red])
                    + abs(g - [col green])
                    + abs(b - [col blue]);
            if (cdiff == 0) {
                // 完全一致
                index = (unsigned char)(l);
                break;
            } else if (cdiff < diff) {
                // 候補として記憶
                index = (unsigned char)(l);
                diff = cdiff;
            }
        }
    }

    return index;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    buffer_ : 保持領域(instance 変数)
//
-(id)init
{
    // super class へ回送
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        self->buffer_ = [[NSMutableDictionary alloc] init];
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
//    buffer_ : 保持領域(instance 変数)
//
-(void)dealloc
{
    // 資源の解放
    [self->buffer_ release];
    self->buffer_ = nil;

    // super class へ回送
    [super dealloc];

    return;
}


//
// 初期化
//
//  Call
//    palette : パレット
//              == nil : 保持領域を再構築しない(忘れるだけ)
//              != nil : 保持領域を再構築する(使用可能な色だけ抽出)
//
//  Return
//    buffer_ : 保持領域(instance 変数)
//
-(void)reset:(PoCoPalette *)palette
{
    // すべて忘れる
    [self->buffer_ removeAllObjects];

    // 再構築
    if (palette != nil) {
        [self create:palette isAlways:YES];
    }

    return;
}


//
// 構築
//
//  Call
//    palette : パレット
//    always  : 常に構築するか
//              YES : 構築する
//              NO  : 1つでも保持内容があれば構築しない
//
//  Return
//    buffer_ : 保持領域(instance 変数)
//
-(void)create:(PoCoPalette *)palette
     isAlways:(BOOL)always
{
    int l;
    PoCoColor *col;
    PoCoColorBufferElement *elm;

    // 構築
    if ((always) || ([self->buffer_ count] == 0)) {
        for (l = 0; l < COLOR_MAX; (l)++) {
            col = [palette palette:l];
            if ([col noDropper]) {
                // 使用禁止色は除外
                ;
            } else {
                // 色要素を生成
                elm = [[PoCoColorBufferElement alloc] init:(unsigned char)(l)
                                                   withRed:[col red]
                                                 withGreen:[col green]
                                                  withBlue:[col blue]];

                // 保持領域に登録
                [self->buffer_ setValue:elm
                                 forKey:[elm name]];
                [elm release];
            }
        }
    }

    return;
}


//
// 検索
//
//  Call
//    palette : パレット(nil 不可)
//    r       : 対象色(赤)
//    g       : 対象色(緑)
//    b       : 対象色(青)
//    buffer_ : 保持領域(instance 変数)
//
//  Return
//    function : 色番号
//    buffer_  : 保持領域(instance 変数)
//
-(unsigned char)findWithBuffer:(PoCoPalette *)palette
                       withRed:(unsigned char)r
                     withGreen:(unsigned char)g
                      withBlue:(unsigned char)b
{
    unsigned char index;
    PoCoColorBufferElement *elm;
    PoCoColorBufferElement *tmp;

    // 色要素を生成
    elm = [[PoCoColorBufferElement alloc] init:0
                                       withRed:r
                                     withGreen:g
                                      withBlue:b];

    // 保持領域に問い合わせ
    tmp = [self->buffer_ valueForKey:[elm name]];
    if (tmp != nil) {
        index = [tmp index];
    } else {
        // なければ近い色を探して保持領域に追加
        index = [PoCoColorBuffer find:palette
                              withRed:r
                            withGreen:g
                             withBlue:b];
        [elm setIndex:index];
        [self->buffer_ setValue:elm
                         forKey:[elm name]];
    }

    [elm release];
    return index;
}


//
// 以前の演算結果を探す
//
//  Call
//    colMode : 色演算モード
//    d1      : 濃度(0.1%単位)(塗装色(i1)用)
//    d2      : 濃度(0.1%単位)(塗装色(i2)用)
//    i1      : 色1(描画先色番号)
//    i2      : 色2(塗装色番号)
//    buffer_ : 保持領域(instance 変数)
//
//  Return
//    function : 検索結果
//               <  0 : 見つからなかった
//               >= 0 : 見つけた色番号
//
-(int)findOnceCalc:(PoCoColorMode)colMode
      withDensity1:(int)d1
      withDensity2:(int)d2
        withColor1:(unsigned char)i1
        withColor2:(unsigned char)i2
{
    PoCoColorOnceCalcElement *tmp;

    tmp = [self->buffer_ valueForKey:[PoCoColorOnceCalcElement
                                         createName:colMode
                                       withDensity1:d1
                                       withDensity2:d2
                                         withColor1:i1
                                         withColor2:i2]];

    return ((tmp != nil) ? [tmp index] : -1);
}


//
// 以前の演算結果に追加
//
//  Call
//    colMode : 色演算モード
//    d1      : 濃度(0.1%単位)(塗装色(i1)用)
//    d2      : 濃度(0.1%単位)(塗装色(i2)用)
//    i1      : 色1(描画先色番号)
//    i2      : 色2(塗装色番号)
//    ch      : 演算結果の色番号
//
//  Return
//    buffer_ : 保持領域(instance 変数)
//
-(void)addOnceCalc:(PoCoColorMode)colMode
      withDensity1:(int)d1
      withDensity2:(int)d2
        withColor1:(unsigned char)i1
        withColor2:(unsigned char)i2
        withResult:(unsigned char)ch
{
    PoCoColorOnceCalcElement *elm;

    elm = [[PoCoColorOnceCalcElement alloc] init:colMode
                                    withDensity1:d1
                                    withDensity2:d2
                                      withColor1:i1
                                      withColor2:i2
                                      withResult:ch];
    [self->buffer_ setValue:elm
                     forKey:[elm name]];
    [elm release];

    return;
}

@end
