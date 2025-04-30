//
//	Pelistina on Cocoa - PoCo -
//	サイズ変数パネル
//
//	Copyright (C) 2005-2019 KAENRYUU Koutoku.
//

#import "PoCoCanvasResizePanel.h"

#import "PoCoAppController.h"
#import "PoCoMyDocument.h"
#import "PoCoLayer.h"
#import "PoCoPicture.h"
#import "PoCoControllerFactory.h"

// 内部変数
static NSString *DEFAULT_FITTING = @"PoCoCanvasResizeDefaultFitting";

// ============================================================================
@implementation PoCoCanvasResizePanel

// ------------------------------------------------------------- class - public
//
// 初期設定
//
//  Call
//    None
//
//  Return
//    None
//
+(void)initialize
{
    NSMutableDictionary *dic;
  
    dic = [NSMutableDictionary dictionary];

    // 各初期値を設定
    [dic setObject:[NSNumber numberWithBool:YES] forKey:DEFAULT_FITTING];

    // default を設定
    [[NSUserDefaults standardUserDefaults] registerDefaults:dic];

    return;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    doc : 編集対象
//
//  Return
//    function  : 実体
//    document_ : 編集対象(instance 変数)
//
-(id)initWithDoc:(MyDocument *)doc
{
    DPRINT((@"[PoCoCanvasResizePanel initWithDoc:]\n"));

    // super class の初期化
    self = [super initWithWindowNibName:@"PoCoCanvasResizePanel"];

    // 自身の初期化
    if (self != nil) {
        self->document_ = doc;
        [self->document_ retain];
    }

    return self;
}


//
// deallocate
//
//  Call
//    None
//
//  Return
//    document_ : 編集対象(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoCanvasResizePanel dealloc]\n"));

    // 資源の解放
    [self->document_ release];
    self->document_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 開始
//
//  Call
//    document_ : 編集対象(instance 変数)
//
//  Return
//    fit_    : 変倍(outlet)
//    width_  : 幅(outlet)
//    height_ : 高さ(outlet)
//
-(void)startWindow
{
    PoCoRect *r;

    r = [[self->document_ picture] bitmapPoCoRect];

    [self->fit_ setState:[[NSUserDefaults standardUserDefaults]
                             boolForKey:DEFAULT_FITTING]]; // 変倍
    [self->width_ setIntValue:[r width]];      // 幅
    [self->height_ setIntValue:[r height]];    // 高さ

    // modal session 開始
    [NSApp runModalForWindow:[self window]];

    [r release];

    return;
}


//
// 取り消し
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    None
//
-(IBAction)cancel:(id)sender;
{
    // 閉じる
    [[self window] close];

    // modal session 終了
    [NSApp stopModal];

    return;
}


//
// 設定
//
//  Call
//    sender    : 操作対象(api 変数)
//    fit_      : 変倍(outlet)
//    width_    : 幅(outlet)
//    height_   : 高さ(outlet)
//    document_ : 編集対象(instance 変数)
//
//  Return
//    None
//
-(IBAction)ok:(id)sender
{
    // 編集状態解除
    [self->document_ cancelEdit];

    // 実行
    [[(PoCoAppController *)([NSApp delegate]) factory] createCanvasResizer:YES
                                              isFit:([self->fit_ state] != 0)
                                              width:[self->width_ intValue]
                                             height:[self->height_ intValue]];

    // 変倍の設定を記憶
    [[NSUserDefaults standardUserDefaults]
        setBool:([self->fit_ state] != 0)
         forKey:DEFAULT_FITTING];

    // 閉じる
    [self cancel:sender];               // cancel の実装で閉じる

    return;
}

@end
