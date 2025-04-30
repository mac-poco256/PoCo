//
//	Pelistina on Cocoa - PoCo -
//	新規画像設定パネル
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoNewDocumentPanel.h"

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"
#import "PoCoMyDocument.h"
#import "PoCoNewDocumentColorSelectView.h"

// 内部変数
static NSString *DEFAULT_WIDTH = @"PoCoNewDocumentDefaultWidth";
static NSString *DEFAULT_HEIGHT = @"PoCoNewDocumentDefaultHeight";
static NSString *DEFAULT_RESOLUTION = @"PoCoNewDocumentDefaultResolution";
static NSString *DEFAULT_COLOR = @"PoCoNewDocumentDefaultColor";

// ============================================================================
@implementation PoCoNewDocumentPanel

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
    [dic setObject:[NSNumber numberWithInt:640] forKey:DEFAULT_WIDTH];
    [dic setObject:[NSNumber numberWithInt:480] forKey:DEFAULT_HEIGHT];
    [dic setObject:[NSNumber numberWithInt:120] forKey:DEFAULT_RESOLUTION];
    [dic setObject:[NSNumber numberWithInt:0] forKey:DEFAULT_COLOR];

    // default を設定
    [[NSUserDefaults standardUserDefaults] registerDefaults:dic];

    return;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    function      : 実体
//    defaultColor_ : 初期色(instance 変数)
//
-(id)init
{
    DPRINT((@"[PoCoNewDocumentPanel init]\n"));

    // super class の初期化
    self = [super initWithWindowNibName:@"PoCoNewDocumentPanel"];

    // 自身の初期化
    if (self != nil) {
        self->defaultColor_ = (unsigned char)([[NSUserDefaults standardUserDefaults] integerForKey:DEFAULT_COLOR]);
    }

    return self;
}


//
// deallocate
//
//  Call
//   None
//
//  Return
//   None
//
-(void)dealloc
{
    DPRINT((@"[PoCoNewDocumentPanel dealloc]\n"));

    // super class の解放
    [super dealloc];

    return;
}


//
// ウィンドウ(パネル)が読み込まれた
//
//  Call
//    width_      : 幅(outlet)
//    height_     : 高さ(outlet)
//    resolution_ : 解像度(outlet)
//    colorView_  : 初期色(outlet)
//
//  Return
//    None
//
-(void)windowDidLoad
{
    NSUserDefaults *def;

    def = [NSUserDefaults standardUserDefaults];

    [self->width_ setIntValue:(int)([def integerForKey:DEFAULT_WIDTH])];
    [self->height_ setIntValue:(int)([def integerForKey:DEFAULT_HEIGHT])];
    [self->resolution_ setIntValue:(int)([def integerForKey:DEFAULT_RESOLUTION])];
    [self->colorView_ setSelnum:(unsigned char)([def integerForKey:DEFAULT_COLOR])];

    return;
}


//
// 開始
//  modal session を開始
//
//  Call
//    None
//
//  Return
//    noNextOpen_ : 次から開かない(outlet)
//
-(void)startWindow
{
    PoCoEditInfo *editInfo = [(PoCoAppController *)([NSApp delegate]) editInfo];

    // (空の場合に)新規ドキュメントを開かない
    [self->noNextOpen_ setState:([editInfo noOpenNewDocPanel]) ? 1 : 0];

    // modal session 開始
    [NSApp runModalForWindow:[self window]];

    return;
}


// -------------------------------------------- instance - public - IBAction 系
//
// 取り消し
//
//  Call
//    sender      : 操作対象(api 変数)
//    noNextOpen_ : 次から開かない(outlet)
//
//  Return
//    None
//
-(IBAction)cancelNewDocument:(id)sender
{
    PoCoEditInfo *editInfo = [(PoCoAppController *)([NSApp delegate]) editInfo];

    // (空の場合に)新規ドキュメントを開かない
    [editInfo setNoOpenNewDocPanel:([self->noNextOpen_ state] != 0)];

    // modal session 終了
    [NSApp stopModal];

    // 閉じる
    [[self window] close];

    return;
}


//
// 設定
//
//  Call
//    sender      : 操作対象(api 変数)
//    name_       : 名称(outlet)
//    width_      : 幅(outlet)
//    height_     : 高さ(outlet)
//    resolution_ : 解像度(outlet)
//    colorView_  : 初期色(outlet)
//
//  Return
//    defaultColor_ : 初期色(instance 変数)
//
-(IBAction)createNewDocument:(id)sender
{
    id newDoc;
    int w;
    int h;
    int r;
    NSString *nm;
    NSUserDefaults *def;

    // 値の取得
    w = [self->width_ intValue];
    h = [self->height_ intValue];
    r = [self->resolution_ intValue];
    if ((w <= 0) || (h <= 0) || (r <= 0)) {
        NSBeep();
        goto EXIT;
    }
    self->defaultColor_ = [self->colorView_ selnum];

    // 新規 document を生成
    newDoc = [[MyDocument alloc] initWidth:w
                                initHeight:h
                            initResolution:r
                              defaultColor:self->defaultColor_];
    if (newDoc == nil) {
        DPRINT((@"can't make new document.\n"));
    } else {
        [[NSDocumentController sharedDocumentController] addDocument:newDoc];
        [newDoc makeWindowControllers];
        [newDoc showWindows];
        if ([[self->name_ stringValue] length] > 0) {
            nm = [[NSString stringWithString:[self->name_ stringValue]]
              stringByAppendingPathExtension:@"poco"];
            [newDoc setFileURL:[NSURL URLWithString:nm]];
        }

        // DocumentController に引き渡したので忘れる
        [newDoc release];
    }

    // 設定値を初期値として記憶
    def = [NSUserDefaults standardUserDefaults];

    [def setInteger:w forKey:DEFAULT_WIDTH];
    [def setInteger:h forKey:DEFAULT_HEIGHT];
    [def setInteger:r forKey:DEFAULT_RESOLUTION];
    [def setInteger:self->defaultColor_ forKey:DEFAULT_COLOR];

    // パネルを閉じる
    [self cancelNewDocument:sender];    // cancel の実装で閉じる

EXIT:
    return;
}

@end
