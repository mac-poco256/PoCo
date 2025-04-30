//
//	Pelistina on Cocoa - PoCo -
//	パレット取り込み設定パネル
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class
@class MyDocument;
@class PoCoPalette;

// ----------------------------------------------------------------------------
@interface PoCoImportPalettePanel : NSWindowController
{
    MyDocument *document_;              // 編集対象
    PoCoPalette *targetPalette_;        // 取り込み対象パレット

    IBOutlet id selectView_;            // 色選択領域
}

// initialize
-(id)initWithDoc:(MyDocument *)doc
withTargetPalette:(PoCoPalette *)target;

// deallocate
-(void)dealloc;

// 開始
-(void)startWindow;

// IBAction 系
-(IBAction)noImport:(id)sender;         // 取り込まない
-(IBAction)doImport:(id)sender;         // 取り込み実行
-(IBAction)setDiff:(id)sender;          // 差分
-(IBAction)reverseSelect:(id)sender;    // 選択反転
-(IBAction)allSelect:(id)sender;        // すべて選択
-(IBAction)allClear:(id)sender;         // すべて非選択

@end
