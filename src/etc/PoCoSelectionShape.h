//
// PoCoSelectionShape.h
// declare interface of implementation for selection shape features.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import <Foundation/Foundation.h>

// ハンドル種別
typedef enum _pocoHandleType {
    PoCoHandleType_center = 0,          // 重心
    PoCoHandleType_corner_lt = 1,       // 左上
    PoCoHandleType_edge_t = 2,          // 上底
    PoCoHandleType_corner_rt = 3,       // 右上
    PoCoHandleType_edge_r = 4,          // 右辺
    PoCoHandleType_corner_rb = 5,       // 右下
    PoCoHandleType_edge_b = 6,          // 下底
    PoCoHandleType_corner_lb = 7,       // 左下
    PoCoHandleType_edge_l = 8,          // 左辺

    PoCoHandleType_effective = 9,       // 9点

    PoCoHandleType_in_rect = 10,        // 矩形領域内
    PoCoHandleType_out_rect = 11,       // 矩形領域外
    PoCoHandleType_in_shape = 12,       // 任意領域内
    PoCoHandleType_out_shape = 13,      // 任意領域外

    PoCoHandleType_unknown = 14         // 不定(形状が成立していない)
} PoCoHandleType;


// 修飾方法
typedef enum _pocoModifierType {
    PoCoModifierType_move_hori,           // 水平移動
    PoCoModifierType_move_vert,           // 垂直移動
    PoCoModifierType_resize_hori,         // 水平変形
    PoCoModifierType_resize_vert,         // 垂直変形
    PoCoModifierType_resize_similer_hori, // 相似変形(水平変量)
    PoCoModifierType_resize_similer_vert, // 相似変形(垂直変量)
    PoCoModifierType_rotate,              // 角度

    PoCoModifierType_none                 // 無し
} PoCoModifierType;


// 参照クラスの宣言
@class MyDocument;
@class PoCoEditInfo;
@class PoCoBitmap;
@class PoCoCalcRotation;

// ----------------------------------------------------------------------------
@interface PoCoSelectionShape : NSObject
{
    // 変形前
    NSMutableArray *originalPoints_;    // 支点座標群(変形前)
    PoCoRect *originalRect_;            // 外接長方形(変形前)
    PoCoRect *originalHandle_[9];       // ハンドル(変形前)
    PoCoBitmap *originalShape_;         // 形状(変形前)
    PoCoBitmap *originalImage_;         // 画像(変形前)

    // 変形後
    NSMutableArray *resultPoints_;      // 支点座標群(変形後)
    PoCoRect *resultRect_;              // 外接長方形(変形後)
    PoCoRect *resultHandle_[9];         // ハンドル(変形後)
    PoCoBitmap *resultShape_;           // 形状(変形後)
    PoCoBitmap *resultImage_;           // 画像(変形後)

    // 変形情報
    PoCoHandleType handle_;             // 変形時のハンドル種別
    PoCoPoint *point_;                  // 制御点(開始点)
    PoCoCalcRotation *rotate_;          // 回転関数
    PoCoModifierType modify_;           // 変形の修飾
}

// handle 種別判定
+(BOOL)isCorner:(PoCoHandleType)type;
+(BOOL)isEdge:(PoCoHandleType)type;
+(BOOL)isInner:(PoCoHandleType)type;
+(BOOL)isOuter:(PoCoHandleType)type;

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// 変形前の形状を忘れる
-(void)clearOriginal;

// 変形前の支点を登録(nil で登録終了)
-(void)addPoint:(PoCoPoint *)p;

// 変形前の画像を登録
-(void)setImage:(PoCoBitmap *)bmp;

// 変形後の形状を変形前の形状に複写
-(void)copyResultToOriginal;

// 補助情報
-(PoCoHandleType)controlHandle;
-(PoCoPoint *)controlPoint;
-(PoCoCalcRotation *)calcRotater;
-(BOOL)isCornerHandle;
-(BOOL)isEdgeHandle;
-(BOOL)isInnerHandle;
-(BOOL)isOuterHandle;

// 変形前形状取得
-(NSMutableArray *)originalPoints;
-(PoCoRect *)originalRect;
-(PoCoRect *)originalHandle:(PoCoHandleType)type;
-(PoCoBitmap *)originalShape;
-(PoCoBitmap *)originalImage;
-(PoCoHandleType)originalHitTest:(PoCoPoint *)p
                       handleGap:(int)gap
                       withShape:(BOOL)shape;
-(BOOL)isSameStyleOriginalRectShape;

// 変形後形状取得
-(NSMutableArray *)resultPoints;
-(PoCoRect *)resultRect;
-(PoCoRect *)resultHandle:(PoCoHandleType)type;
-(PoCoBitmap *)resultShape;
-(PoCoBitmap *)resultImage;
-(PoCoHandleType)resultHitTest:(PoCoPoint *)p
                     handleGap:(int)gap
                     withShape:(BOOL)shape;
-(BOOL)isSameStyleResultRectShape;

// 変形
-(BOOL)startTrans:(PoCoPoint *)p        // 開始
        handleGap:(int)gap
        withShape:(BOOL)shape;
-(void)runningTrans:(PoCoPoint *)p      // 変形中
          withEvent:(NSEvent *)evt
  isLiveUpdateShape:(BOOL)liveShape
 isLiveUpdateResult:(BOOL)liveResult;
-(void)endTrans;                        // 終了

// その他の加工
-(void)delete:(MyDocument *)doc         // 削除
 withEditInfo:(PoCoEditInfo *)info;
-(void)flip:(BOOL)hori;                 // 反転
-(void)autoGrad:(MyDocument *)doc       // 自動グラデーション
        penSize:(int)size
     isAdjacent:(BOOL)adj
         matrix:(const BOOL *)mtx
   withSizePair:(NSDictionary *)sizePair;
-(void)colorReplace:(MyDocument *)doc   // 色置換
             matrix:(const unsigned char *)mtx;
-(void)texture:(MyDocument *)doc        // テクスチャ
  withEditInfo:(PoCoEditInfo *)info
    baseColors:(NSArray *)base
gradientColors:(NSArray *)grad;


// 塗り選択
-(void)seedNew:(PoCoPoint *)p           // 新規
        bitmap:(PoCoBitmap *)bmp
      isBorder:(BOOL)border
    colorRange:(int)range;
-(void)seedJoin:(PoCoPoint *)p          // 結合
         bitmap:(PoCoBitmap *)bmp
       isBorder:(BOOL)border
     colorRange:(int)range;
-(void)seedSeparate:(PoCoPoint *)p      // 分離
             bitmap:(PoCoBitmap *)bmp
           isBorder:(BOOL)border
         colorRange:(int)range;

@end
