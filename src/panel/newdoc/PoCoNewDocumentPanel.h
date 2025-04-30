//
//	Pelistina on Cocoa - PoCo -
//	新規画像設定パネル
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// ----------------------------------------------------------------------------
@interface PoCoNewDocumentPanel : NSWindowController
{
    unsigned char defaultColor_;        // 初期色

    IBOutlet NSTextField *name_;        // 名称
    IBOutlet NSTextField *width_;       // 幅
    IBOutlet NSTextField *height_;      // 高さ
    IBOutlet NSTextField *resolution_;  // 解像度
    IBOutlet NSButton *noNextOpen_;     // 次から開かない
    IBOutlet id colorView_;             // 初期色
    IBOutlet NSButton *cancel_;         // 取り消し
    IBOutlet NSButton *ok_;             // 設定
}

// 初期設定
+(void)initialize;

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// ウィンドウが読み込まれた
-(void)windowDidLoad;

// 開始
-(void)startWindow;

// IBAction 系
-(IBAction)cancelNewDocument:(id)sender;
-(IBAction)createNewDocument:(id)sender;

@end
