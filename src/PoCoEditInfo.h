//
//	Pelistina on Cocoa - PoCo -
//	編集情報管理部
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import <Foundation/Foundation.h>

// ----------------------------------------------------------------------------
@interface PoCoEditInfo : NSObject {
    PoCoSelColor *selColor_;            // 選択中の色
    PoCoSelColor *oldColor_;            // 以前の色

    PoCoColorMode colorMode_;           // 色演算モード
    BOOL lockPalette_;                  // パレット固定

    unsigned int penNumber_;            // ペン先選択番号
    unsigned int penSize_;              // 筆圧比例時のペン先大きさ(dot 単位)
    unsigned int tileNumber_;           // タイルパターン選択番号
    unsigned int density_;              // 濃度上限値(0.1% 単位)
    unsigned int pressure_;             // ポインタプレス時の筆圧(0.1% 単位)

    PoCoPoint *pdPos_;                  // PD 位置(実寸)
    PoCoPoint *lastPos_;                // 最終 PD 位置(実寸)
    PoCoRect *pictureRect_;             // 画像サイズ(実寸)
    PoCoRect *viewRect_;                // 表示範囲(実寸)
    PoCoRect *pdRect_;                  // PD 範囲(実寸)
    PoCoRect *selRect_;                 // 選択範囲(実寸)

    PoCoDrawModeType  drawModeType_;    // 描画機能系
    BOOL continuationType_;             // 連続/不連続
    BOOL flipType_;                     // 濃度反転
    PoCoPointModeType pointModeType_;   // 形状指定
    PoCoPenStyleType  penStyleType_;    // ペン先指定(描画)
    BOOL enableUndo_;                   // 取り消し可否(取り消し抑制)
    BOOL enableEraser_;                 // 消しゴム有効可否
    BOOL eraserType_;                   // 消しゴム指定
    int undoMaxLevel_;                  // 取り消し最大数
    BOOL enableLiveResize_;             // LiveResize可否
    BOOL enableColorBuffer_;            // 色保持情報可否
    PoCoProportionalType sizePropType_; // サイズの筆圧比例設定
    PoCoProportionalType densityPropType_;  // 濃度の筆圧比例設定
    PoCoAtomizerSkipType atomizerSkip_; // 霧吹きの移動方法
    BOOL atomizerType_;                 // 霧吹きの種類
    BOOL selectionFill_;                // 選択領域塗りつぶし表示
    BOOL liveEditSelection_;            // 選択範囲の編集を随時表示
    BOOL withHandleSelection_;          // 選択範囲のハンドル有無
    BOOL saveDocWindowPos_;             // 主ウィンドウ位置保存
    BOOL holdSubWindowPos_;             // 補助ウィンドウ位置固定
    BOOL noOpenNewDocPanel_;            // 新規ドキュメントパネルを開かない
    PoCoScrollerType showScrollerView_; // view で scroller を表示
    PoCoMainViewSupplement *supplement_;// 主ウィンドウの表示修飾
    unsigned int previewQuality_;       // プレビューの品質
    unsigned int previewSize_;          // プレビューの大きさ
    BOOL grayToAlpha_;                  // Grascale を不透明度とする
    PoCoInterpolationGuideView interGuide_; // 補間曲線のガイドライン表示
    PoCoCurveWithPointsType interType_; // 補間曲線の種類
    unsigned int interFreq_;            // 補間曲線の補間頻度
    int colorRange_;                    // 色範囲
    BOOL syncSubView_;                  // 表示ウィンドウとの同期
    BOOL syncPalette_;                  // 選択色との同期
}

// 初期設定
+(void)initialize;

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// 選択中の色
-(PoCoSelColor *)selColor;
-(PoCoSelColor *)oldColor;
-(BOOL)useUnderPattern;
-(void)setSelColor:(int)num;
-(void)setSelPattern:(int)num;
-(void)toggleUseUnderPattern;

// 色演算モード
-(PoCoColorMode)colorMode;
-(void)setColorMode:(PoCoColorMode)mode;
-(BOOL)lockPalette;
-(void)setLockPalette:(BOOL)type;

// ペン先
-(unsigned int)penNumber;
-(unsigned int)penSize;
-(void)setPenNumber:(unsigned int)num;
-(void)setPenSize:(unsigned int)size;

// タイルパターン/濃度
-(unsigned int)tileNumber;
-(unsigned int)density;
-(void)setTileNumber:(unsigned int)num;
-(void)setDensity:(unsigned int)val;

// 筆圧関連
-(unsigned int)pressure;
-(void)setPressure:(unsigned int)press;

// 表示位置関連
-(PoCoRect *)pictureRect;
-(PoCoRect *)pictureView;
-(void)setPictureRect:(PoCoRect *)r;
-(void)setPictureView:(PoCoRect *)r;

// PD 指示位置関連
-(PoCoPoint *)pdPos;
-(PoCoRect *)pdRect;
-(PoCoPoint *)lastPos;
-(void)setPDPos:(PoCoPoint *)p;
-(void)setPDRect:(PoCoRect *)r;
-(void)setLastPos:(PoCoPoint *)p;

// 選択範囲関連
-(PoCoRect *)selRect;
-(void)setSelRect:(PoCoRect *)r;

// 表示修飾関連
-(PoCoMainViewSupplement *)supplement;
-(void)setBackgroundColor:(unsigned int)col;
-(void)setPattern:(BOOL)flag;
-(void)setGridStep:(unsigned int)step;

// 補間曲線関連
-(PoCoInterpolationGuideView)interGuide;
-(PoCoCurveWithPointsType)interType;
-(unsigned int)interFreq;
-(void)setInterGuide:(PoCoInterpolationGuideView)type;
-(void)setInterType:(PoCoCurveWithPointsType)type;
-(void)setInterFreq:(unsigned int)val;

// 編集機能関連
-(PoCoDrawModeType)drawModeType;
-(BOOL)continuationType;
-(BOOL)flipType;
-(PoCoPointModeType)pointModeType;
-(PoCoPenStyleType)penStyleType;
-(BOOL)enableUndo;
-(BOOL)enableEraser;
-(BOOL)eraserType;
-(int)undoMaxLevel;
-(BOOL)enableLiveResize;
-(BOOL)enableColorBuffer;
-(PoCoProportionalType)sizePropType;
-(PoCoProportionalType)densityPropType;
-(PoCoAtomizerSkipType)atomizerSkip;
-(BOOL)atomizerType;
-(BOOL)selectionFill;
-(BOOL)liveEditSelection;
-(BOOL)useHandle;
-(BOOL)saveDocWindowPos;
-(BOOL)holdSubWindowPos;
-(BOOL)noOpenNewDocPanel;
-(PoCoScrollerType)showScrollerView;
-(unsigned int)previewQuality;
-(unsigned int)previewSize;
-(BOOL)grayToAlpha;
-(int)colorRange;
-(BOOL)syncSubView;
-(BOOL)syncPalette;
-(void)setDrawModeType:(PoCoDrawModeType)type;
-(void)setContinuationType:(BOOL)type;
-(void)setFlipType:(BOOL)type;
-(void)setPointModeType:(PoCoPointModeType)type;
-(void)setPenStyleType:(PoCoPenStyleType)type;
-(void)setEnableUndo:(BOOL)type;
-(void)setEnableEraser:(BOOL)type;
-(void)setEraserType:(BOOL)type;
-(void)setUndoMaxLevel:(int)type;
-(void)setEnableLiveResize:(BOOL)type;
-(void)setEnableColorBuffer:(BOOL)type;
-(void)setSizePropType:(PoCoProportionalType)type;
-(void)setDensityPropType:(PoCoProportionalType)type;
-(void)setAtomizerSkip:(PoCoAtomizerSkipType)type;
-(void)setAtomizerType:(BOOL)type;
-(void)setSelectionFill:(BOOL)type;
-(void)setLiveEditSelection:(BOOL)type;
-(void)setUseHandle:(BOOL)type;
-(void)setSaveDocWindowPos:(BOOL)type;
-(void)setHoldSubWindowPos:(BOOL)type;
-(void)setNoOpenNewDocPanel:(BOOL)type;
-(void)setShowScrollerView:(PoCoScrollerType)type;
-(void)setPreviewQuality:(unsigned int)val;
-(void)setPreviewSize:(unsigned int)val;
-(void)setGrayToAlpha:(BOOL)flag;
-(void)setColorRange:(int)val;
-(void)setSyncSubView:(BOOL)flag;
-(void)setSyncPalette:(BOOL)flag;

@end
