//
//	Pelistina on Cocoa - PoCo -
//	サイズ変数パネル
//
//	Copyright (C) 2005-2019 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class
@class MyDocument;

// ----------------------------------------------------------------------------
@interface PoCoCanvasResizePanel : NSWindowController
{
    MyDocument *document_;              // 編集対象

    IBOutlet NSButton *fit_;            // 変倍
    IBOutlet NSTextField *width_;       // 幅
    IBOutlet NSTextField *height_;      // 高さ
}

// 初期設定
+(void)initialize;

// initialize
-(id)initWithDoc:(MyDocument *)doc;

// deallocate
-(void)dealloc;

// 開始
-(void)startWindow;

// IBAction 系
-(IBAction)cancel:(id)sender;
-(IBAction)ok:(id)sender;

@end
