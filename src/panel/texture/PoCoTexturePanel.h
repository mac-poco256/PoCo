//
//	Pelistina on Cocoa - PoCo -
//	テクスチャ設定パネル
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class
@class MyDocument;
@class PoCoEditInfo;

// ----------------------------------------------------------------------------
@interface PoCoTexturePanel : NSWindowController
{
    MyDocument *document_;              // 編集対象
    PoCoEditInfo *editInfo_;            // 編集情報
    BOOL isOk_;                         // 実行するか

    NSMutableArray *base_;              // texture の基本色(NSArray<int>)
    NSMutableArray *gradient_;          // 濃淡色(NSArray<int, NSArray<int> >)

    IBOutlet id baseView_;              // texture の基本色選択領域
    IBOutlet id gradientView_;          // 濃淡色選択領域
    IBOutlet id replaceView_;           // 置換色選択領域
    IBOutlet id horiRangeEdit_;         // 水平範囲(濃淡色の範囲用)
    IBOutlet id vertRangeEdit_;         // 垂直範囲(基本色の範囲用)
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
-(NSArray *)base;
-(NSArray *)gradient;

// IBAction 系
-(IBAction)cancel:(id)sender;           // 取り消し
-(IBAction)ok:(id)sender;               // 設定
-(IBAction)horiRangeEdit:(id)sender;    // 水平範囲
-(IBAction)vertRangeEdit:(id)sender;    // 垂直範囲

@end
