//
//	Pelistina on Cocoa - PoCo -
//	パレット取り込み設定パネル
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoImportPalettePanel.h"

#import "PoCoAppController.h"
#import "PoCoMyDocument.h"
#import "PoCoPicture.h"
#import "PoCoPalette.h"
#import "PoCoImportPaletteColorSelectView.h"
#import "PoCoControllerFactory.h"
#import "PoCoControllerPaletteImporter.h"

// ============================================================================
@implementation PoCoImportPalettePanel

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    doc    : 編集対象
//    target : 取り込み対象パレット
//
//  Return
//    document_      : 編集対象(instance 変数)
//    targetPalette_ : 取り込み対象パレット(instance 変数)
//
-(id)initWithDoc:(MyDocument *)doc
withTargetPalette:(PoCoPalette *)target
{
    DPRINT((@"[PoCoImportPalettePanel initWithDoc: withTargetPalette:]\n"));

    // super class を初期化
    self = [super initWithWindowNibName:@"PoCoImportPalettePanel"];

    // 自身の初期化
    if (self != nil) {
        self->document_ = doc;
        self->targetPalette_ = target;
        [self->document_ retain];
        [self->targetPalette_ retain];
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
//    document_      : 編集対象(instance 変数)
//    targetPalette_ : 取り込み対象パレット(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoImportPalettePanel dealloc]\n"));

    // 資源の解放
    [self->targetPalette_ release];
    [self->document_ release];
    self->targetPalette_ = nil;
    self->document_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 開始
//
//  Call
//    selectView_    : 色選択領域(outlet)
//    targetPalette_ : 取り込み対象パレット(instance 変数)
//
//  Return
//   None
//
-(void)startWindow
{
    // 対象パレットを設定
    [self->selectView_ setTarget:self->targetPalette_];

    // 初期値を設定
    [self setDiff:nil];                 // [差分] の結果を初期値にする

    // modal session 開始
    [NSApp runModalForWindow:[self window]];

    return;
}


// -------------------------------------------- instance - public - IBAction 系
//
// 取り込まない
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    None
//
-(IBAction)noImport:(id)sender
{
    // 閉じる
    [[self window] close];

    // modal session 終了
    [NSApp stopModal];

    return;
}


//
// 取り込み実行
//
//  Call
//    sender         : 操作対象(api 変数)
//    selectView_    : 色選択領域(outlet)
//    targetPalette_ : 取り込み対象パレット(instance 変数)
//
//  Return
//    None
//
-(IBAction)doImport:(id)sender
{
    // 設定
    [[(PoCoAppController *)([NSApp delegate]) factory] createPaletteImporter:YES
                                        targetPalette:targetPalette_
                                            withFlags:[self->selectView_ attributs]];

    // 閉じる
    [self noImport:sender];             // [取り込まない] の実装で閉じる

    return;
}


//
// 差分
//
//  Call
//    sender         : 操作対象(api 変数)
//    selectView_    : 色選択領域(outlet)
//    document_      : 編集対象(instance 変数)
//    targetPalette_ : 取り込み対象パレット(instance 変数)
//
//  Return
//    selectView_ : 色選択領域(outlet)
//
-(IBAction)setDiff:(id)sender
{
    int l;

    // 違っているものを対象にする
    for (l = 0; l < COLOR_MAX; l++) {
        if ([[[[self->document_ picture] palette] palette:l] isEqualColor:[self->targetPalette_ palette:l] checkAttr:NO]) {
            [self->selectView_ setAttribute:NO atIndex:l];
        } else {
            [self->selectView_ setAttribute:YES atIndex:l];
        }
    }

    // 再描画
    [self->selectView_ setNeedsDisplay:YES];

    return;
}


//
// 選択反転
//
//  Call
//    sender      : 操作対象(api 変数)
//    selectView_ : 色選択領域(outlet)
//
//  Return
//    selectView_ : 色選択領域(outlet)
//
-(IBAction)reverseSelect:(id)sender
{
    int l;

    // 設定値を反転する
    for (l = 0; l < COLOR_MAX; l++) {
        [self->selectView_ setAttribute:([self->selectView_ attribute:l] ? NO : YES)
                                atIndex:l];
    }

    // 再描画
    [self->selectView_ setNeedsDisplay:YES];

    return;
}


//
// すべて選択
//
//  Call
//    sender      : 操作対象(api 変数)
//    selectView_ : 色選択領域(outlet)
//
//  Return
//    selectView_ : 色選択領域(outlet)
//
-(IBAction)allSelect:(id)sender
{
    int l;

    // すべて YES に切り替える
    for (l = 0; l < COLOR_MAX; l++) {
        [self->selectView_ setAttribute:YES
                                atIndex:l];
    }

    // 再描画
    [self->selectView_ setNeedsDisplay:YES];

    return;
}


//
// すべて非選択
//
//  Call
//    sender      : 操作対象(api 変数)
//    selectView_ : 色選択領域(outlet)
//
//  Return
//    selectView_ : 色選択領域(outlet)
//
-(IBAction)allClear:(id)sender
{
    int l;

    // すべて NO に切り替える
    for (l = 0; l < COLOR_MAX; l++) {
        [self->selectView_ setAttribute:NO
                                atIndex:l];
    }

    // 再描画
    [self->selectView_ setNeedsDisplay:YES];

    return;
}

@end
