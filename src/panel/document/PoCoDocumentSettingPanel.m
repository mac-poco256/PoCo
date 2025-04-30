//
//	Pelistina on Cocoa - PoCo -
//	ドキュメント設定パネル
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoDocumentSettingPanel.h"

#import "PoCoMyDocument.h"
#import "PoCoPicture.h"
#import "PoCoPalette.h"

// ============================================================================
@implementation PoCoDocumentSettingPanel

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
    DPRINT((@"[PoCoDocumentSettingPanel initWithDoc:]\n"));

    // super class の初期化
    self = [super initWithWindowNibName:@"PoCoDocumentSettingPanel"];

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
    DPRINT((@"[PoCoDocuemntSettingPanel dealloc]\n"));

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
//    h_unit_     : pHYs(水平)(outlet)
//    v_unit_     : pHYs(垂直)(outlet)
//    bkgdCheck_  : bKGD(使用)(outlet)
//    bkgdIndex_  : bKGD(番号)(outlet)
//    iccp_       : iCCP(outlet)
//    gamma_      : gAMA(outlet)
//    chromakey1_ : cHRM(outlet)
//    chromakey2_ : cHRM(outlet)
//    chromakey3_ : cHRM(outlet)
//    chromakey4_ : cHRM(outlet)
//    chromakey5_ : cHRM(outlet)
//    chromakey6_ : cHRM(outlet)
//    chromakey7_ : cHRM(outlet)
//    chromakey8_ : cHRM(outlet)
//    srgb_       : sRGB(outlet)
//
-(void)startWindow
{
    PoCoPicture *picture;
    BOOL state;
    const unsigned int *chrm;
    unsigned int bkgd;

    // PoCoPicture を取得
    picture = [self->document_ picture];

    // 解像度
    [self->h_unit_ setIntValue:[picture h_unit]];
    [self->v_unit_ setIntValue:[picture v_unit]];

    // bKGD
    [self->bkgdCheck_ setState:(([picture bkgdColor:&(bkgd)]) ? 1 : 0)];
    [self->bkgdIndex_ setIntValue:bkgd];
    [self useBKGD:self->bkgdCheck_];
    [self editBKGD:self->bkgdIndex_];

    // gAMA
    [self->gamma_ setIntValue:[picture gamma]];

    // chromakey
    chrm = [picture chromakey];
    [self->chromakey1_ setIntValue:chrm[0]];
    [self->chromakey2_ setIntValue:chrm[1]];
    [self->chromakey3_ setIntValue:chrm[2]];
    [self->chromakey4_ setIntValue:chrm[3]];
    [self->chromakey5_ setIntValue:chrm[4]];
    [self->chromakey6_ setIntValue:chrm[5]];
    [self->chromakey7_ setIntValue:chrm[6]];
    [self->chromakey8_ setIntValue:chrm[7]];

    // sRGB
    [self->srgb_ setIntValue:[picture srgb]];

    // iCCP
    if ([picture isUseICCP]) {
        [self->iccp_ setState:1];
        state = NO;
    } else {
        [self->iccp_ setState:0];
        state = YES;
    }
    [self->gamma_ setEnabled:state];
    [self->chromakey1_ setEnabled:state];
    [self->chromakey2_ setEnabled:state];
    [self->chromakey3_ setEnabled:state];
    [self->chromakey4_ setEnabled:state];
    [self->chromakey5_ setEnabled:state];
    [self->chromakey6_ setEnabled:state];
    [self->chromakey7_ setEnabled:state];
    [self->chromakey8_ setEnabled:state];
    [self->srgb_ setEnabled:state];

    // modal session 開始
    [NSApp runModalForWindow:[self window]];

    return;
}


//
// bKGD 切り替え
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    bkgdIndex_ : bKGD(番号)(outlet)
//    bkgdInfo_  : bKGD(情報)(outlet)
//
-(IBAction)useBKGD:(id)sender
{
    BOOL state = ([self->bkgdCheck_ state] != 0);

    [self->bkgdIndex_ setEnabled:state];
    [self->bkgdInfo_ setEnabled:state];

    return;
}


//
// bKGD 入力
//
//  Call
//    sender     : 操作対象(api 変数)
//    document_  : 編集対象(instance 変数)
//    bkgdIndex_ : bKGD(番号)(outlet)
//
//  Return
//    bkgdInfo_ : bKGD(情報)(outlet)
//
-(IBAction)editBKGD:(id)sender
{
    PoCoPicture *picture;
    PoCoColor *col;
    unsigned int idx;

    // PoCoPicture を取得
    picture = [self->document_ picture];

    // bKGD
    idx = [self->bkgdIndex_ intValue];

    // 内容を設定
    col = [[picture palette] palette:idx];
    [self->bkgdInfo_ setStringValue:[NSString stringWithFormat:@"0x%02x-0x%02x-0x%02x",
                                        [col red],
                                        [col green],
                                        [col blue]]];

    return;
}


//
// iCCP 切り替え
//
//  Call
//    sender : 操作対象(api 変数)
//
//  Return
//    iccp_       : iCCP(outlet)
//    gamma_      : gAMA(outlet)
//    chromakey1_ : cHRM(outlet)
//    chromakey2_ : cHRM(outlet)
//    chromakey3_ : cHRM(outlet)
//    chromakey4_ : cHRM(outlet)
//    chromakey5_ : cHRM(outlet)
//    chromakey6_ : cHRM(outlet)
//    chromakey7_ : cHRM(outlet)
//    chromakey8_ : cHRM(outlet)
//    srgb_       : sRGB(outlet)
//
-(IBAction)useICCP:(id)sender
{
    BOOL state = ([self->iccp_ state] == 0);

    [self->gamma_ setEnabled:state];
    [self->chromakey1_ setEnabled:state];
    [self->chromakey2_ setEnabled:state];
    [self->chromakey3_ setEnabled:state];
    [self->chromakey4_ setEnabled:state];
    [self->chromakey5_ setEnabled:state];
    [self->chromakey6_ setEnabled:state];
    [self->chromakey7_ setEnabled:state];
    [self->chromakey8_ setEnabled:state];
    [self->srgb_ setEnabled:state];

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
-(IBAction)cancel:(id)sender
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
//    sender      : 操作対象(api 変数)
//    document_   : 編集対象(instance 変数)
//    h_unit_     : pHYs(水平)(outlet)
//    v_unit_     : pHYs(垂直)(outlet)
//    bkgdCheck_  : bKGD(使用)(outlet)
//    iccp_       : iCCP(outlet)
//    gamma_      : gAMA(outlet)
//    chromakey1_ : cHRM(outlet)
//    chromakey2_ : cHRM(outlet)
//    chromakey3_ : cHRM(outlet)
//    chromakey4_ : cHRM(outlet)
//    chromakey5_ : cHRM(outlet)
//    chromakey6_ : cHRM(outlet)
//    chromakey7_ : cHRM(outlet)
//    chromakey8_ : cHRM(outlet)
//    srgb_       : sRGB(outlet)
//
//  Return
//    None
//
-(IBAction)ok:(id)sender
{
    PoCoPicture *picture;
    unsigned int chrm[8];
    unsigned int bkgd;

    // PoCoPicture を取得
    picture = [self->document_ picture];

    // 解像度
    [picture setHUnit:[self->h_unit_ intValue]
            withVUnit:[self->v_unit_ intValue]];

    // bKGD
    bkgd = [self->bkgdIndex_ intValue];
    [picture setBKGD:([self->bkgdCheck_ state] != 0) withIndex:bkgd];

    // iCCP
    [picture setUseICCP:([self->iccp_ state] != 0)];

    // gAMA
    [picture setGamma:[self->gamma_ intValue]];

    // cHRM
    chrm[0] = [self->chromakey1_ intValue];
    chrm[1] = [self->chromakey2_ intValue];
    chrm[2] = [self->chromakey3_ intValue];
    chrm[3] = [self->chromakey4_ intValue];
    chrm[4] = [self->chromakey5_ intValue];
    chrm[5] = [self->chromakey6_ intValue];
    chrm[6] = [self->chromakey7_ intValue];
    chrm[7] = [self->chromakey8_ intValue];
    [picture setChromakey:chrm];

    // sRGB
    [picture setSrgb:[self->srgb_ intValue]];

    // 閉じる
    [self cancel:sender];               // cancel の実装で閉じる

    return;
}

@end
