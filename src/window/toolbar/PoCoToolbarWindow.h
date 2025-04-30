//
//	Pelistina on Cocoa - PoCo -
//	ツールバーウィンドウ管理部
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class の宣言
@class PoCoEditInfo;

// ----------------------------------------------------------------------------
@interface PoCoToolbarWindow : NSWindowController
{
    PoCoEditInfo *info_;                // 編集情報

    // 描画機能系
    id drawMode_[PoCoDrawModeType_MAX];
    IBOutlet id freeLine_;              // 自由曲線
    IBOutlet id line_;                  // 直線
    IBOutlet id box_;                   // 矩形枠
    IBOutlet id ellipse_;               // 円/楕円
    IBOutlet id parallelogram_;         // 平行四辺形
    IBOutlet id boxFill_;               // 塗りつぶし矩形枠
    IBOutlet id ellipseFill_;           // 塗りつぶし円/楕円
    IBOutlet id parallelogramFill_;     // 塗りつぶし平行四辺形
    IBOutlet id paint_;                 // 塗りつぶし
    IBOutlet id propotionalFreeLine_;   // 筆圧比例自由曲線
    IBOutlet id selection_;             // 選択
    IBOutlet id drogMove_;              // ずりずり

    // ペン先指定系
    id penStyle_[PoCoPenStyleType_MAX];
    IBOutlet id normal_;                // 通常
    IBOutlet id atomizer_;              // 霧吹き
    IBOutlet id random_;                // 拡散
    IBOutlet id density_;               // 濃度
    IBOutlet id gradation_;             // グラデーション
    IBOutlet id uniformedDensity_;      // 単一濃度
    IBOutlet id waterDrop_;             // ぼかし

    // 補助属性系
    IBOutlet id continuation_;          // 連続
    IBOutlet id flip_;                  // 濃度反転
    IBOutlet id handle_;                // ハンドル有無

    // 形状指定系
    id pointMode_[PoCoPointModeType_MAX];
    IBOutlet id pointHold_;             // 起点固定
    IBOutlet id pointMove_;             // 起点移動
    IBOutlet id identicalShape_;        // 形状固定

    // 筆圧比例系
    id penSizeProp_[PoCoProportionalType_MAX];
    id densityProp_[PoCoProportionalType_MAX];
    IBOutlet id sizeRelation_;          // 筆圧比例(サイズ)
    IBOutlet id sizeHold_;              // 筆圧固定(サイズ)
    IBOutlet id sizeWithPattern_;       // パターンを使用(サイズ)
    IBOutlet id densityRelation_;       // 筆圧比例(濃度)
    IBOutlet id densityHold_;           // 筆圧固定(濃度)
    IBOutlet id densityWithPattern_;    // パターンを使用(濃度)

    // 霧吹き系
    id atomizerSkip_[PoCoAtomizerSkipType_MAX];
    IBOutlet id normalTone_;            // 通常
    IBOutlet id halfTone_;              // 半値
    IBOutlet id skipAlways_;            // 常に移動
    IBOutlet id skipBinary_;            // 偶数ないし奇数
    IBOutlet id skipHold_;              // 維持

    // icon
    NSImage *continueImage_;            // 連続
    NSImage *discreteImage_;            // 非連続
    NSImage *handleImage_;              // ハンドルあり
    NSImage *nohandleImage_;            // ハンドルなし
    NSImage *selectImage_;              // 矩形選択
    NSImage *anyselectImage_;           // 任意領域選択
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// nib が読み込まれた
-(void)awakeFromNib;

// ウィンドウが読み込まれた
-(void)windowDidLoad;

// ウィンドウが閉じられる
-(void)windowWillClose:(NSNotification *)note;

// 取り消し情報の引き渡し
-(NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender;

// 描画機能を切り替え(番号指定)
-(void)setDrawModeAtType:(PoCoDrawModeType)type;

// IBAction 系
-(IBAction)drawMode:(id)sender;         // 描画機能系
-(IBAction)penStyle:(id)sender;         // ペン先指定
-(IBAction)continuation:(id)sender;     // 連続
-(IBAction)flip:(id)sender;             // 反転
-(IBAction)pointMode:(id)sender;        // 形状指定
-(IBAction)handle:(id)sender;           // ハンドル有無
-(IBAction)penSize:(id)sender;          // 筆圧比例(サイズ)
-(IBAction)density:(id)sender;          // 筆圧比例(濃度)
-(IBAction)normalTone:(id)sender;       // 通常霧吹き
-(IBAction)halfTone:(id)sender;         // 半値霧吹き
-(IBAction)atomizerSkip:(id)sender;     // 霧吹き移動

// イベントの取得
-(void)keyDown:(NSEvent *)evt;            // キーダウン処理
-(void)keyUp:(NSEvent *)evt;              // キーリリース処理

@end
