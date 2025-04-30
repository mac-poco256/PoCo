//
//	Pelistina on Cocoa - PoCo -
//	ドキュメント設定パネル
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class
@class MyDocument;

// ----------------------------------------------------------------------------
@interface PoCoDocumentSettingPanel : NSWindowController
{
    MyDocument *document_;               // 編集対象

    IBOutlet NSTextField *h_unit_;      // pHYs(水平)
    IBOutlet NSTextField *v_unit_;      // pHYs(垂直)
    IBOutlet NSButton *bkgdCheck_;      // bKGD(使用)
    IBOutlet NSTextField *bkgdIndex_;   // bKGD(番号)
    IBOutlet NSTextField *bkgdInfo_;    // bKGD(情報)
    IBOutlet NSButton *iccp_;           // iCCP
    IBOutlet NSTextField *gamma_;       // gAMA
    IBOutlet NSTextField *chromakey1_;  // cHRM
    IBOutlet NSTextField *chromakey2_;  // cHRM
    IBOutlet NSTextField *chromakey3_;  // cHRM
    IBOutlet NSTextField *chromakey4_;  // cHRM
    IBOutlet NSTextField *chromakey5_;  // cHRM
    IBOutlet NSTextField *chromakey6_;  // cHRM
    IBOutlet NSTextField *chromakey7_;  // cHRM
    IBOutlet NSTextField *chromakey8_;  // cHRM
    IBOutlet NSTextField *srgb_;        // sRGB
}

// initialize
-(id)initWithDoc:(MyDocument *)doc;

// deallocate
-(void)dealloc;

// 開始
-(void)startWindow;

// IBAction 系
-(IBAction)useBKGD:(id)sender;
-(IBAction)editBKGD:(id)sender;
-(IBAction)useICCP:(id)sender;
-(IBAction)cancel:(id)sender;
-(IBAction)ok:(id)sender;

@end
