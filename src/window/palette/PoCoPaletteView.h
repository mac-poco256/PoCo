//
// PoCoPaletteView.h
// declare interface of palette list view on palette window.
// and this class manages some control items on palette window.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// ----------------------------------------------------------------------------
@interface PoCoPaletteView : NSView <NSWindowDelegate>
{
    NSDocumentController *docCntl_;
    IBOutlet id titleR_;
    IBOutlet id titleG_;
    IBOutlet id titleB_;
    IBOutlet id titleH_;
    IBOutlet id titleL_;
    IBOutlet id titleS_;
    IBOutlet id number_;
    IBOutlet id elementR_;
    IBOutlet id elementG_;
    IBOutlet id elementB_;
    IBOutlet id elementH_;
    IBOutlet id elementL_;
    IBOutlet id elementS_;
    IBOutlet id attributeMask_;
    IBOutlet id attributeDropper_;
    IBOutlet id attributeTransparent_;

    // 補助属性の位置(初期位置)
    NSRect attributesRect_[3];

    // 色詳細設定シート関連
    int selNumber_;
    NSColorPanel *infoSheet_;
    IBOutlet NSWindow *infoAccessory_;
    IBOutlet id accessoryView_;
    IBOutlet id accessoryMask_;
    IBOutlet id accessoryDropper_;
    IBOutlet id accessoryTransparent_;
}

// initialize
-(id)initWithFrame:(NSRect)frameRect;

// deallocate
-(void)dealloc;

// awake from nib.
- (void)awakeFromNib;

// observer
-(void)changePicture:(NSNotification *)note;  // 表示画像を切り替え
-(void)changeColor:(NSNotification *)note;    // 選択色の切り替え
-(void)changePalette:(NSNotification *)note;  // パレットを変更(編集)

// 表示要求
-(void)drawRect:(NSRect)rect;

// 座標系を反転
-(BOOL)isFlipped;

// 1色分の描画
-(void)drawColor:(int)num
        isSelect:(BOOL)sel;

// ウィンドウ拡縮
-(void)setDisclosed:(BOOL)state;

// マウスイベント処理
-(BOOL)acceptsFirstMouse:(NSEvent *)evt;
-(void)mouseDown:(NSEvent *)evt;        // ボタンダウンイベント
-(void)mouseDragged:(NSEvent *)evt;     // ドラッグ処理

// 色詳細設定シート関連
- (void)raiseColorInfoSheet;
- (IBAction)endColorInfoSheet:(id)sender;
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
- (void)colorInfoSheetDidEnd:(NSModalResponse)returnCode;
#else   // (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)
- (void)colorInfoSheetDidEnd:(NSWindow *)sheet
                  returnCode:(int)returnCode
                 contextInfo:(void *)contextInfo;
#endif  // (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_9)

// IBAction 系
-(IBAction)attributeMask:(id)sender;
-(IBAction)attributeDropper:(id)sender;
-(IBAction)attributeTransparent:(id)sender;

@end
