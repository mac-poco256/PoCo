//
//	Pelistina on Cocoa - PoCo -
//	共通定数宣言
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 色数
#define COLOR_MAX 256

// ハンドルのアキ
#define HANDLE_GAP 4

// 色演算モード
typedef enum _pocoColorMixingMode {
    PoCoColorMode_RGB,                  // RGB 系
    PoCoColorMode_HLS                   // HLS 系
} PoCoColorMode;

// レイヤー種別番号
typedef enum _pocoLayerType {
    PoCoLayerType_Base,                 // 基底
    PoCoLayerType_Bitmap,               // 画像
    PoCoLayerType_String,               // 文字列
    PoCoLayerType_Figure,               // 図形(未実装)
    PoCoLayerType_File                  // ファイル(未実装)
} PoCoLayerType;

// scroller 種別
typedef enum _pocoScrollerType {
    PoCoScrollerType_default,           // OS の設定に依存
    PoCoScrollerType_always,            // 常時
    PoCoScrollerType_overlay            // 適宜
} PoCoScrollerType;

// パターン個数
#define PEN_STYLE_NUM     16            // ペン先
#define TILE_PATTERN_NUM  16            // タイルパターン
#define COLOR_PATTERN_NUM 16            // カラーパターン

// パターンの大きさ(原則として正方形)
#define PEN_STYLE_SIZE    16
#define TILE_PATTERN_SIZE 16

// 霧吹き
#define ATOMIZER_SIZE      128
#define ATOMIZER_TBL_ROW   (16 * 8)
#define ATOMIZER_TBL_LINE  (16 * 8)
#define ATOMIZER_TBL_CORR  4
#define ATOMIZER_TBL_ROW1  (ATOMIZER_TBL_ROW  + ATOMIZER_TBL_CORR)
#define ATOMIZER_TBL_LINE1 (ATOMIZER_TBL_LINE + ATOMIZER_TBL_CORR)

// 座標更新通知種別
typedef enum _pocoEditInfoPosition {
    PoCoEditInfoPos_pictureRect = 0x00000001, // 画像サイズ変更
    PoCoEditInfoPos_viewRect    = 0x00000002, // 表示範囲変更
    PoCoEditInfoPos_pdPos       = 0x00000004, // PD 位置移動
    PoCoEditInfoPos_pdRect      = 0x00000008, // 編集範囲変動
    PoCoEditInfoPos_selRect     = 0x00000010  // 選択範囲変更
} PoCoEditInfoPos;

// 自動グラデーション走査状態
typedef enum _pocoAutoGradState {
    PoCoAutoGrad_NoneAttach,            // そもそも未達(始点を探している)
    PoCoAutoGrad_StartAttached,         // 始点に達した(中点を探している)
    PoCoAutoGrad_MiddleAttached         // 中点に達した(終点を探している)
} PoCoAutoGradState;

// 補間曲線のガイドライン表示
typedef enum _pocoInterpolationGuideView {
   PoCoInterpolationGuideView_Line,     // 直線のみ
   PoCoInterpolationGuideView_Curve,    // 曲線のみ
   PoCoInterpolationGuideView_CurveLine // 直線・曲線両方
} PoCoInterpolationGuideView;

// 補間曲線の種類
typedef enum _pocoCurveWithPointsType {
    PoCoCurveWithPoints_Lagrange,       // Lagrange interpolation
    PoCoCurveWithPoints_Spline          // Spline interpolation
} PoCoCurveWithPointsType;

// 編集機能関連
typedef enum _pocoDrawingMode {             // 描画機能系
    PoCoDrawModeType_FreeLine,              // 自由曲線
    PoCoDrawModeType_Line,                  // 直線
    PoCoDrawModeType_Box,                   // 矩形枠
    PoCoDrawModeType_Ellipse,               // 円/楕円
    PoCoDrawModeType_Parallelogram,         // 平行四辺形
    PoCoDrawModeType_BoxFill,               // 塗りつぶし矩形枠
    PoCoDrawModeType_EllipseFill,           // 塗りつぶし円/楕円
    PoCoDrawModeType_ParallelogramFill,     // 塗りつぶし平行四辺形
    PoCoDrawModeType_Paint,                 // 塗りつぶし
    PoCoDrawModeType_ProportionalFreeLine,  // 筆圧比例自由曲線
    PoCoDrawModeType_Selection,             // 選択
    PoCoDrawModeType_DragMove,              // ずりずり

    PoCoDrawModeType_MAX
} PoCoDrawModeType;
typedef enum _pocoPointMovingMode {     // 形状指定
    PoCoPointModeType_PointHold,        // 起点固定
    PoCoPointModeType_PointMove,        // 起点移動
    PoCoPointModeType_IdenticalShape,   // 形状固定

    PoCoPointModeType_MAX
} PoCoPointModeType;
typedef enum _pocoPenStyleType {        // ペン先指定
    PoCoPenStyleType_Normal,            // 通常
    PoCoPenStyleType_Atomizer,          // 霧吹き
    PoCoPenStyleType_Random,            // 拡散
    PoCoPenStyleType_Density,           // 濃度拡散
    PoCoPenStyleType_Gradation,         // グラデーション
    PoCoPenStyleType_UniformedDensity,  // 単一濃度
    PoCoPenStyleType_WaterDrop,         // ぼかし

    PoCoPenStyleType_MAX
} PoCoPenStyleType;
typedef enum _pocoProportionalType {    // 筆圧比例指定
    PoCoProportionalType_Relation,      // 筆圧比例
    PoCoProportionalType_Hold,          // 筆圧固定
    PoCoProportionalType_Pattern,       // パターン使用

    PoCoProportionalType_MAX
} PoCoProportionalType;
typedef enum _pocoAtomizerPatternSkip { // 霧吹きの移動方法
    PoCoAtomizerSkipType_Always,        // 常に移動する
    PoCoAtomizerSkipType_Binary,        // 偶数ないし奇数に固定する
    PoCoAtomizerSkipType_Pattern,       // パターンを維持する

    PoCoAtomizerSkipType_MAX
} PoCoAtomizerSkipType;
