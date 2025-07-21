//
// PoCoAutoGradationPanel.h
// declare interface of auto gradient setting panel.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class
@class MyDocument;
@class PoCoEditInfo;
@class PoCoAutoGradationColorView;
@class PoCoBitmap;

// ----------------------------------------------------------------------------
@interface PoCoAutoGradationPanel : NSWindowController
{
    MyDocument *document_;              // 編集対象
    PoCoEditInfo *editInfo_;            // 編集情報
    PoCoBitmap *image_;                 // 対象画像(instance 変数)
    PoCoBitmap *shape_;                 // 形状(instance 変数)
    BOOL isOk_;                         // 実行するか
    NSMutableDictionary *sizePair_;     // 色と大きさの対群

    IBOutlet PoCoAutoGradationColorView *selectView_; // 色選択領域
    IBOutlet id adjacent_;              // 隣接
    IBOutlet id manual_;                // 手動
    IBOutlet id auto_;                  // 自動
    IBOutlet id pair_;                  // 対ごと
    IBOutlet id sizeSlider_;            // サイズ(手動用)
    IBOutlet id sizeDetail_;            // サイズ詳細(対ごと用)
    IBOutlet id exec_;                  // 実行

    // 個別詳細設定シート関連
    IBOutlet NSWindow *detailSheet_;
    IBOutlet id detailList_;
}

// 初期設定
+(void)initialize;

// initialize
-(id)initWithDoc:(MyDocument *)doc
    withEditInfo:(PoCoEditInfo *)info
       withImage:(PoCoBitmap *)image
       withShape:(PoCoBitmap *)shape;

// deallocate
-(void)dealloc;

// 開始
-(void)startWindow;

// 妥当性評価
-(void)verifySetting;

// 結果
-(BOOL)isOk;
-(int)penSize;
-(BOOL)isAdjacent;
-(const BOOL *)matrix;
-(NSDictionary *)sizePair;

// IBAction 系
-(IBAction)colorSelect:(id)sender;      // 色選択
-(IBAction)defaultSelect:(id)sender;    // 初期値に戻す
-(IBAction)reverseSelect:(id)sender;    // 選択反転
-(IBAction)allSelect:(id)sender;        // すべて選択
-(IBAction)allClear:(id)sender;         // すべて非選択
-(IBAction)adjacent:(id)sender;         // 隣接
-(IBAction)manual:(id)sender;           // 手動
-(IBAction)auto:(id)sender;             // 自動
-(IBAction)pair:(id)sender;             // 対ごと
#if 0   // raiseSizeDetailSheet: に移行する
-(IBAction)sizeDetail:(id)sender;       // 詳細(対ごと)
#endif  // 0
-(IBAction)sizeSlide:(id)sender;        // サイズ設定
-(IBAction)cancel:(id)sender;           // 取り消し
-(IBAction)ok:(id)sender;               // 設定

// 個別詳細設定シート関連
- (IBAction)raiseSizeDetailSheet:(id)sender;
- (IBAction)endSizeDetailSheet:(id)sender;
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
- (void)sizeDetailSheetDidEnd:(NSModalResponse)returnCode;
#else   // (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
- (void)sizeDetailSheetDidEnd:(NSWindow *)sheet
                   returnCode:(int)returnCode
                  contextInfo:(void *)contextInfo;
#endif  // (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)

@end
