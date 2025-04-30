//
//	Pelistina on Cocoa - PoCo -
//	回転関数
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import <Foundation/Foundation.h>

// ----------------------------------------------------------------------------
@interface PoCoCalcRotation : NSObject
{
    PoCoPoint *control_;                // 制御点
    BOOL vert_;                         // つかむ点の性質は垂直か
    BOOL greater_;                      // つかむ点の性質は大きい座標か
    double sin_;                        // 回転角の sin
    double cos_;                        // 回転角の cos
    double prevSin_;                    // 以前の sin
    double prevCos_;                    // 以前の cos
}

// initialize
-(id)initWithControlPoint:(PoCoPoint *)p
        isVerticalControl:(BOOL)v
         isGreaterControl:(BOOL)g;

// deallocate
-(void)dealloc;

// 制御点を移動
-(BOOL)moveControlPoint:(PoCoPoint *)p
              isCorrect:(BOOL)corr;

// 演算
-(void)calcPoint:(PoCoPoint *)p;
#if 0   // 使わなくした
-(void)recalcPoint:(PoCoPoint *)p;
#endif  // 0
-(void)recalcPointHori:(double *)x
               andVert:(double *)y;

// 取得
-(void)diffInt:(long long *)d;

@end


// ----------------------------------------------------------------------------
@interface PoCoCalcRotationForBox : NSObject
{
    PoCoPoint *centerPos_;              // 中心点
    PoCoPoint *ortPos_;                 // 方向点
    PoCoPoint *leftTop_;                // 左上(名目上)
    PoCoPoint *rightTop_;               // 右上(名目上)
    PoCoPoint *leftBottom_;             // 左下(名目上)
    PoCoPoint *rightBottom_;            // 右下(名目上)

    double cos_;
    double sin_;
}

// initialize
-(id)initWithStartPos:(PoCoPoint *)spos
           withEndPos:(PoCoPoint *)epos
          ifAnyOrient:(PoCoPoint *)opos;

// deallocate
-(void)dealloc;

// 演算実行
-(void)calc:(BOOL)diagonal;

// 座標を取得
-(PoCoPoint *)leftTop;
-(PoCoPoint *)rightTop;
-(PoCoPoint *)leftBottom;
-(PoCoPoint *)rightBottom;

@end


// ----------------------------------------------------------------------------
@interface PoCoCalcRotationForEllipse : NSObject
{
    double rotation_;                   // 回転角
    double cos_;                        // self->rotation_ の cos
    double sin_;                        // self->rotation_ の sin
    BOOL exec_;                         // 回転可能か
}

// initialize
-(id)initWithCenterPos:(PoCoPoint *)cpos
            withEndPos:(PoCoPoint *)epos
           ifAnyOrient:(PoCoPoint *)opos;

// deallocate
-(void)dealloc;

// 回転可能か
-(BOOL)isExec;

// 水平座標
-(int)calcXAxis:(int)rot
     horiLength:(int)h
     vertLength:(int)v;

// 垂直座標
-(int)calcYAxis:(int)rot
     horiLength:(int)h
     vertLength:(int)v;

@end
