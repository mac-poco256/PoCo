//
//	Pelistina on Cocoa - PoCo -
//	編集状態管理
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class の宣言
@class PoCoEditInfo;

// ----------------------------------------------------------------------------
@interface PoCoEditState : NSObject
{
    PoCoPoint *point_[3];               // 座標の管理
    PoCoEditInfo *editInfo_;            // 編集情報
    int count_;                         // 編集回数
    BOOL isEdit_;                       // 編集状態
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// 状態遷移
-(void)beginEditMode;                   // 編集開始
-(void)endEditMode;                     // 編集終了
-(void)countUpEdit;                     // 編集回数
-(int)count;                            // 編集回数取得
-(BOOL)isEdit;                          // 編集状態

// 座標の管理
-(PoCoPoint *)firstPoint;               // 取得(開始点)
-(PoCoPoint *)secondPoint;              // 取得(終点 or 中間点)
-(PoCoPoint *)thirdPoint;               // 取得(終点)
-(void)setFirstPoint:(PoCoPoint *)p;    // 設定(開始点)
-(void)setSecondPoint:(PoCoPoint *)p;   // 設定(終点 or 中間点)
-(void)setThirdPoint:(PoCoPoint *)p;    // 設定(終点)
-(void)clearFirstPoint;                 // 消去(開始点)
-(void)clearSecondPoint;                // 消去(終点 or 中間点)
-(void)clearThirdPoint;                 // 消去(終点)
-(BOOL)isFirstPoint;                    // 点の設定状態遷移(開始点)
-(BOOL)isSecondPoint;                   // 点の設定状態遷移(終点 or 中間点)
-(BOOL)isThirdPoint;                    // 点の設定状態遷移(終点)
-(BOOL)hasFirstPoint;                   // 点の所持(開始点)
-(BOOL)hasSecondPoint;                  // 点の所持(終点 or 中間点)
-(BOOL)hasThirdPoint;                   // 点の所持(終点)
-(BOOL)isPointHold;                     // 起点固定
-(BOOL)isPointMove;                     // 起点移動
-(BOOL)isIdenticalShape;                // 形状固定
-(void)moveX:(int)x                     // 点の移動
       moveY:(int)y;

@end
