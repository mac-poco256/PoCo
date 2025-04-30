//
//	Pelistina on Cocoa - PoCo -
//	パレット詳細情報
//
//	Copyright (C) 2005-2019 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// ----------------------------------------------------------------------------
@interface PoCoPaletteInfoView : NSView
{
    int attrType_;                      // 属性系の操作対象(< 0 : なし)
    BOOL attrSet_;                      // 属性系の設定内容
    float beforeTop_;                   // 以前の表示原点(縦)
    NSDocumentController *docCntl_;

    IBOutlet id lock_;                  // 編集可否

    // icon
    NSImage *lockImage_;                // 編集不可
    NSImage *unlockImage_;              // 編集可
}

// initialize
-(id)initWithFrame:(NSRect)frameRect;

// deallocate
-(void)dealloc;

// 座標系を反転
-(BOOL)isFlipped;

// 要描画領域の clipping
-(BOOL)wantsDefaultClipping;

// 初期状態の設定
-(void)setFirstState;

// 表示要求
-(void)drawRect:(NSRect)rect;

// 1要素分の表示
-(void)drawColor:(int)num
        withBias:(float)bias
        isSelect:(BOOL)sel;

// observer
-(void)changePicture:(NSNotification *)note;      // 表示画像を切り替え
-(void)changeColor:(NSNotification *)note;        // 選択色の切り替え
-(void)changePalette:(NSNotification *)note;      // パレット変更
-(void)changePaletteAttr:(NSNotification *)note;  // パレット属性変更

// イベント処理系
-(BOOL)acceptsFirstMouse:(NSEvent *)evt;
-(void)mouseDown:(NSEvent *)evt;
-(void)mouseDragged:(NSEvent *)evt;
-(void)mouseUp:(NSEvent *)evt;
-(void)rightMouseDown:(NSEvent *)evt;
-(void)scrollWheel:(NSEvent *)evt;

// IBAction 系
-(IBAction)lockPalette:(id)sender;
-(IBAction)scrollUp:(id)sender;
-(IBAction)scrollDown:(id)sender;

@end
