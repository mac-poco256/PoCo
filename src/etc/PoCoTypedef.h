//
//	Pelistina on Cocoa - PoCo -
//	PoCo 共通定義
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import <Foundation/Foundation.h>

// -------------------------------------------------------------- endian 変換用
// 16 bit 値の入れ替え
#define PoCoSwapUH(i) ((((i) & 0xff00) >> 8) | (((i) & 0x00ff) << 8))

// 32 bit 値の入れ替え 
#define PoCoSwapUW(i) ((((i) & 0xff000000) >> 24) | \
                       (((i) & 0x00ff0000) >>  8) | \
                       (((i) & 0x0000ff00) <<  8) | \
                       (((i) & 0x000000ff) << 24))


// ----------------------------------------------------------------- 角度計算用
#define PoCoPI    (double)(3.14159265358979)
#define PoCoDivPI ((double)(180.0) / PoCoPI)
#define PoCoMulPI (PoCoPI / (double)(180.0))


// ----------------------------------------------------------------------------
@interface PoCoPoint : NSObject
{
    int x_;
    int y_;
}

// NSPoint の座標補正
+(NSPoint)corrNSPoint:(NSPoint)p;

// initialize
-(id)init;
-(id)initX:(int)px                      // 指定イニシャライザ
     initY:(int)py;
-(id)initNSPoint:(NSPoint)p;

// deallocate
-(void)dealloc;

// 参照
-(int)x;
-(int)y;

// 設定
-(void)setX:(int)px
       setY:(int)py;
-(void)setX:(int)px;
-(void)setY:(int)py;

// 更新
-(void)moveX:(int)sx
       moveY:(int)sy;
-(void)moveX:(int)sx;
-(void)moveY:(int)sy;

// 確認
-(BOOL)isEqualPos:(PoCoPoint *)p;

@end


// ----------------------------------------------------------------------------
// half-open property
// 原点は左上を (0,0) とし、右下方向に延びる
@interface PoCoRect : NSObject
{
    PoCoPoint *lefttop_;
    PoCoPoint *rightbot_;
}

// PoCoRect から変換
+(NSRect)toNSRect:(PoCoRect *)r;

// 拡張
+(PoCoRect *)expandRect:(PoCoRect *)r
                withGap:(int)gap;

// initialize
-(id)init;
-(id)initLeft:(int)left                 // 指定イニシャライザ
      initTop:(int)top
    initRight:(int)right
   initBottom:(int)bottom;
-(id)initNSRect:(NSRect)r;
-(id)initPoCoRect:(PoCoRect *)r;

// deallocate
-(void)dealloc;

// 参照
-(int)left;
-(int)top;
-(int)right;
-(int)bottom;
-(PoCoPoint *)lefttop;
-(PoCoPoint *)rightbot;
-(int)width;
-(int)height;
-(BOOL)empty;
-(NSRect)toNSRect;

// 設定
-(void)setLeft:(int)left;
-(void)setTop:(int)top;
-(void)setRight:(int)right;
-(void)setBottom:(int)bottom;
-(void)setLeft:(int)left
        setTop:(int)top;
-(void)setRight:(int)right
      setBottom:(int)bottom;

// 移動
-(void)shiftX:(int)x;
-(void)shiftY:(int)y;
-(void)shiftX:(int)x
       shiftY:(int)y;

// 確認
-(BOOL)isEqualRect:(PoCoRect *)r;
-(BOOL)isPointInRect:(PoCoPoint *)p;

// 拡張
-(void)expand:(int)gap;

@end


// ----------------------------------------------------------------------------
@interface PoCoSelColor : NSObject
{
    BOOL isColor_;                      // YES : 色    NO : パターン
    BOOL isUnder_;                      // YES : 背面を使用
    int colorNum_;                      // 選択している色番号
    int patternNum_;                    // 選択しているパターン番号
}

// initialize
-(id)initWithColorNum:(int)num;

// deallocate
-(void)dealloc;

// 参照
-(BOOL)isColor;
-(BOOL)isPattern;                       // isColor を反転した結果を返す
-(BOOL)isUnder;
-(unsigned int)num;

// 設定
-(void)setColor:(int)num;
-(void)setPattern:(int)num;
-(void)toggleUnder;

@end


// ----------------------------------------------------------------------------
@interface PoCoEditPictureNotification : NSObject
{
    PoCoRect *rect_;                    // 再描画領域
    int index_;                         // 対象レイヤー番号
}

// initialize
-(id)initWithRect:(PoCoRect *)r
          atIndex:(int)idx;

// deallocate
-(void)dealloc;

// 参照
-(PoCoRect *)rect;
-(int)index;

@end


// ----------------------------------------------------------------------------
@interface PoCoMainViewSupplement : NSObject
{
    // 背景
    unsigned int color_;                // 色(0xffRRGGBB)
    BOOL pattern_;                      // YES: パターン、NO: 単色

    // 枠線
    unsigned int  step_;                // 実線のステップ数(0: 枠線無し)
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// 背景系
-(unsigned int)backgroundColor;
-(BOOL)isPattern;
-(void)setBackgroundColor:(unsigned int)col;
-(void)setPattern:(BOOL)flag;

// 枠線系
-(unsigned int)gridStep;
-(void)setGridStep:(unsigned int)step;

@end


// ----------------------------------------------------------------------------
@interface PoCoGradationPairInfo : NSObject
{
    unsigned int first_;                // 上位色番号
    unsigned int second_;               // 下位色番号
    int size_;                          // 大きさ
}

// 文字列化
+(NSString *)pairString:(unsigned int)first
             withSecond:(unsigned int)second;

// initialize
-(id)initWithFirst:(unsigned int)first
        withSecond:(unsigned int)second
          withSize:(int)size;

// deallocate
-(void)dealloc;

// 参照
-(NSString *)name;
-(unsigned int)first;
-(unsigned int)second;
-(int)size;
-(int)sizeForSlider;

// 設定
-(void)setFirst:(unsigned int)val;
-(void)setSecond:(unsigned int)val;
-(void)setSize:(int)val;

@end


// ----------------------------------------------------------------------------
@interface PoCoBaseGradientPair : NSObject
{
    unsigned int base_;                 // base color
    NSArray *colors_;                   // colors of replacing
}

// initialize
-(id)init:(unsigned int)b
   colors:(NSArray *)cl;

// deallocate
-(void)dealloc;

// 取得
-(unsigned int)base;
-(NSArray *)colors;

@end
