//
//	Pelistina on Cocoa - PoCo -
//	パレット入れ替え設定領域
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//
// 交換/複写で共通の class を使用
//

#import <Cocoa/Cocoa.h>

// ----------------------------------------------------------------------------
@interface PoCoPaletteExchangePair : NSObject
{
    int src_;                           // 交換元色番号
    int dst_;                           // 交換先色番号
}

// initialize
-(id)initWithSrc:(int)s
         withDst:(int)d;

// deallocate
-(void)dealloc;

// 取得
-(int)src;
-(int)dst;

// 表記文字列の取得
-(NSString *)srcString;
-(NSString *)dstString;

@end


// ----------------------------------------------------------------------------
@interface PoCoPaletteExchangeView : NSView
{
    int leftNum_;                       // 主ボタンでの設定値
    int rightNum_;                      // 右ボタンでの設定値

    NSMutableArray *exchangeTable_;     // 交換データ群

    NSDocumentController *docCntl_;

    IBOutlet id addButton_;
    IBOutlet id colorList_;
}

// initialize
-(id)initWithFrame:(NSRect)frameRect;

// deallocate
-(void)dealloc;

// 表示要求
-(void)drawRect:(NSRect)rect;

// 座標系を反転
-(BOOL)isFlipped;

// 設定を初期化
-(void)setUp;

// 一覧表の取得
-(NSMutableArray *)exchangeTable;

// 1色分の描画
-(void)drawColor:(int)num
        isSelect:(BOOL)sel
          isDown:(BOOL)down;

// 追加
-(IBAction)addColor:(id)sender;

// データソースメソッド(for colorList)
-(int)numberOfRowsInTableView:(NSTableView *)table;
-(id)tableView:(NSTableView *)table
objectValueForTableColumn:(NSTableColumn *)column
                      row:(int)row;
-(void)tableView:(NSTableView *)table
  setObjectValue:(id)object
  forTableColumn:(NSTableColumn *)column
             row:(int)row;

// ボタンダウン処理
-(void)mouseDown:(NSEvent *)evt;
-(void)mouseDragged:(NSEvent *)evt;
-(void)rightMouseDown:(NSEvent *)evt;
-(void)rightMouseDragged:(NSEvent *)evt;

@end
