//
// PoCoLayerOperate.h
// declare interface of delegate for layer list operation.
// this class is to manege and operate the layer list and link between UI and the edit controllers.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class の宣言
@class PoCoSelLayer;
@class PoCoEditInfo;

// ----------------------------------------------------------------------------
@interface PoCoLayerOperate : NSObject
{
    NSDocumentController *docCntl_;     // document controller
    PoCoSelLayer *selLayer_;            // 選択中レイヤー情報 
    int targetRow_;                     // 移動目標行
    PoCoEditInfo *info_;                // 編集情報
    int prevSelectRow_;                 // 以前の選択行

    IBOutlet id layerWindow_;

    IBOutlet id layerList_;             // 一覧

    IBOutlet NSButton *newBitmapLayerButton_;
    IBOutlet NSButton *newStringLayerButton_;
    IBOutlet NSButton *copyLayerButton_;
    IBOutlet NSButton *deleteLayerButton_;
    IBOutlet NSButton *unificateLayerButton_;
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// observer
-(void)changePicture:(NSNotification *)note;  // 表示画像を切り替え
-(void)changePalette:(NSNotification *)note;  // パレットを編集
-(void)editLayer:(NSNotification *)note;      // レイヤー構造の変更
-(void)editPicture:(NSNotification *)note;    // 画像編集
-(void)updatePreview:(NSNotification *)note;  // 見本更新(全更新)

// 各 IBAction
- (IBAction)newBitmapLayer:(id)sender;   // 画像レイヤー生成
- (IBAction)newStringLayer:(id)sender;   // 文字列レイヤー生成
- (IBAction)copyLayer:(id)sender;        // copy layer.
- (IBAction)deleteLayer:(id)sender;      // レイヤー削除
- (IBAction)unificateLayer:(id)sender;   // 表示レイヤー統合

// 一覧用デリゲート
-(BOOL)tableView:(NSTableView *)table
 shouldSelectRow:(int)row;
-(void)tableViewSelectionDidChange:(NSNotification *)note;
-(int)targetRowInTableView:(NSTableView *)table;  // 独自
-(void)tableView:(NSTableView *)table   // 独自
    setTargetRow:(int)row;

// 一覧用データソースメソッド
-(int)numberOfRowsInTableView:(NSTableView *)table;
-(id)tableView:(NSTableView *)table
objectValueForTableColumn:(NSTableColumn *)column
                      row:(int)row;
-(void)tableView:(NSTableView *)table
  setObjectValue:(id)object
  forTableColumn:(NSTableColumn *)column
             row:(int)row;
-(void)tableView:(NSTableView *)table   // 独自
       moveToRow:(int)row
          isCopy:(BOOL)copy;

@end
