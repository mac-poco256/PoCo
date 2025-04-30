//
//	Pelistina on Cocoa - PoCo -
//	色置換設定パネル
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class
@class MyDocument;
@class PoCoEditInfo;

// ----------------------------------------------------------------------------
@interface PoCoColorReplacePanel : NSWindowController
{
    MyDocument *document_;              // 編集対象
    PoCoEditInfo *editInfo_;            // 編集情報
    BOOL isOk_;                         // 実行するか

    NSMutableArray *replaceTable_;      // 置換データ群
    unsigned char matrix_[COLOR_MAX];   // 置換表

    IBOutlet id selectView_;            // 色選択領域
    IBOutlet id addButton_;
    IBOutlet id colorList_;
    IBOutlet id rangeEdit_;
}

// initialize
-(id)initWithDoc:(MyDocument *)doc
    withEditInfo:(PoCoEditInfo *)info;

// deallocate
-(void)dealloc;

// 開始
-(void)startWindow;

// 結果
-(BOOL)isOk;
-(const unsigned char *)matrix;

// データソースメソッド(for colorList)
-(int)numberOfRowsInTableView:(NSTableView *)table;
-(id)tableView:(NSTableView *)table
objectValueForTableColumn:(NSTableColumn *)column
                      row:(int)row;
-(void)tableView:(NSTableView *)table
  setObjectValue:(id)object
  forTableColumn:(NSTableColumn *)column
             row:(int)row;

// IBAction 系
-(IBAction)addColor:(id)sender;         // 追加
-(IBAction)cancel:(id)sender;           // 取り消し
-(IBAction)ok:(id)sender;               // 設定
-(IBAction)rangeEdit:(id)sender;        // 範囲

@end
