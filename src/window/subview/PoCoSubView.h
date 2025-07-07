//
// PoCoSubView.h
// declare interface of the view on the sub-view window.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class
@class PoCoPicture;

// ----------------------------------------------------------------------------
@interface PoCoSubView : NSView
{
    IBOutlet NSSlider *slider_;         // 倍率の slider

    int zfactNum_;                      // 表示倍率の選択番号
    NSRect orgRect_;                    // 表示画像の実寸領域
    PoCoPoint *lastPoint_;              // 最終 PD 位置

    NSDocumentController *docCntl_;
}

#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
// responsive scroll
+(BOOL)isCompatibleWithResponsiveScrolling;
#endif  // MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9

// initialize
-(id)initWithFrame:(NSRect)frameRect;

// deallocate
-(void)dealloc;

// awake from nib.
- (void)awakeFromNib;

// observer
-(void)changePicture:(NSNotification *)note;      // 表示画像を切り替え
-(void)editLayer:(NSNotification *)note;          // レイヤー構造の変更を受信
-(void)changePaletteElm:(NSNotification *)note;   // パレット要素変更通知
-(void)changePaletteAttr:(NSNotification *)note;  // パレット属性更新通知
-(void)editPicture:(NSNotification *)note;        // 画像編集
-(void)execDrawing:(NSNotification *)note;        // 編集通知

// View に拡大率を反映した領域を設定
-(void)updateFrame:(BOOL)sendRedraw;

// 座標系を反転
-(BOOL)isFlipped;

// イベント処理系
-(BOOL)acceptsFirstMouse:(NSEvent *)evt;
-(void)mouseDown:(NSEvent *)evt;
-(void)mouseDragged:(NSEvent *)evt;
-(void)scrollWheel:(NSEvent *)evt;
-(void)magnifyWithEvent:(NSEvent *)evt;

// 倍率の slider の実行結果の取得
-(IBAction)zoomFactor:(id)sender;

@end
