//
//	Pelistina on Cocoa - PoCo -
//	MyDocument(編集対象の管理の主幹部)
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class の宣言
@class PoCoLayerBase;
@class PoCoPalette;
@class PoCoPicture;
@class PoCoSelLayer;
@class PoCoView;
@class PoCoColorPattern;
@class PoCoColorBuffer;

// ----------------------------------------------------------------------------
@interface MyDocument : NSDocument
{
    PoCoPicture *picture_;              // 画像情報
    PoCoSelLayer *selLayer_;            // 選択中レイヤー情報
    PoCoColorPattern *eraser_;          // 消しゴム用画像
    PoCoColorBuffer *colorBuffer_;      // 色保持
    IBOutlet PoCoView *view_;           // 表示領域
    IBOutlet NSScrollView *scroller_;   // scroller
}

// ペーストボードから貼り付け実行
+(BOOL)readPngFromPasteboard:(NSPasteboard *)pb
                 resultLayer:(PoCoLayerBase **)lyr
               resultPalette:(PoCoPalette *)plt;

// initialize
-(id)init;
-(id)initWidth:(int)w                   // 指定イニシャライザ
    initHeight:(int)h
initResolution:(int)r
  defaultColor:(unsigned char)c;

// deallocate
-(void)dealloc;

// 参照
-(PoCoPicture *)picture;
-(PoCoSelLayer *)selLayer;
-(PoCoColorBuffer *)colorBuffer;
-(PoCoView *)view;

// 消しゴム用画像
-(void)setEraser;
-(void)clearEraser;
-(PoCoColorPattern *)eraser;

// ウィンドウ切り替え
-(void)windowDidBecomeMain:(NSNotification *)note;

// 取り消し情報の引き渡し
-(NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender;

// 更新通知
-(void)setUpdateState:(NSDocumentChangeType)type;

// パレット更新通知
-(void)didUpdatePalette;

// 画像更新通知
-(void)didUpdatePicture:(PoCoRect *)r;

// 描画機能変更通知
-(void)didChangeDrawTool;

// レイヤーサイズ変更通知 
-(void)didLayerResize;

// 表示ウィンドウダブルクリック通知
-(void)dclickOnSubView:(PoCoPoint *)p;

// ガイドライン表示
-(void)drawGuideLine;

// 編集状態解除
-(void)cancelEdit;

// スペースキーイベント
-(void)spaceKeyEvent:(BOOL)isPress;

// 定義 nib file
-(NSString *)windowNibName;

// nib 読み込み後処理
-(void)windowControllerDidLoadNib:(NSWindowController *)aController;

// 保存の実行
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)
-(NSData *)dataOfType:(NSString *)aType
                error:(NSError **)outError;
#else   // (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)
-(NSData *)dataRepresentationOfType:(NSString *)aType;
#endif  // (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)

// 読み込みの実行
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)
-(BOOL)readFromData:(NSData *)data
             ofType:(NSString *)aType
              error:(NSError **)outError;
#else   // (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)
-(BOOL)loadDataRepresentation:(NSData *)data
                       ofType:(NSString *)aType;
#endif  // (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)

// ペーストボードへ貼り付け実行
-(void)writePngToPasteboard:(NSPasteboard *)pb
                   withRect:(PoCoRect *)r
                    atIndex:(int)index;

@end
