//
//	Pelistina on Cocoa - PoCo -
//	選択色表示部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoPaletteSelectColorView.h"

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"
#import "PoCoMyDocument.h"
#import "PoCoPicture.h"
#import "PoCoPalette.h"

// ============================================================================
@implementation PoCoPaletteSelectColorView

// --------------------------------------------------------- instance - private
//
// observer を登録
//
//  Call
//    None
//
//  Return
//    None
//
-(void)registerObserver
{
    NSNotificationCenter *nc;

    nc = [NSNotificationCenter defaultCenter];
    if (nc != nil) {
        // 編集対象変更を受信
        [nc addObserver:self
               selector:@selector(updateView:)
                   name:PoCoChangePicture
                 object:nil];

        // 選択色変更を受信
        [nc addObserver:self
               selector:@selector(updateView:)
                   name:PoCoChangeColor
                 object:nil];

        // パレット変更を受信
        [nc addObserver:self
               selector:@selector(updateView:)
                   name:PoCoChangePalette
                 object:nil];
    }

    return;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    frameRect : 矩形領域(api 変数)
//
//  Return
//    function : 実体
//    docCntl_ : document controller(instance 変数)
//
-(id)initWithFrame:(NSRect)frameRect
{
    // super class の初期化
    self = [super initWithFrame:frameRect];

    // 自身の初期化
    if (self != nil) {
        // observer を登録
        [self registerObserver];

        // document controller を取得
        self->docCntl_ = [NSDocumentController sharedDocumentController];
        [self->docCntl_ retain];
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
//    docCntl_ : document controller(instance 変数)
//
-(void)dealloc
{
    // observer の登録を解除
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // 資源を解放
    [self->docCntl_ release];
    self->docCntl_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 表示更新
//  通知によるもの
//
//  Call
//    note : 通知内容
//
//  Return
//    None
//
-(void)updateView:(NSNotification *)note
{
    // 単純に全再描画
    [self setNeedsDisplay:YES];

    return;
}


//
// 再描画要求
//
//  Call
//    rect     : 表示領域(api 変数)
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)drawRect:(NSRect)rect
{
    NSRect r = [self bounds];
    PoCoSelColor *scol;
    PoCoColor *col;

    // 枠を描画(座標系は Cocoa の標準のまま)
    [[NSColor blackColor] set];
    [NSBezierPath fillRect:r];
    (r.origin.x)++;
    (r.size.width)--;
    (r.size.height)--;
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:r];
    (r.origin.y)++;
    (r.size.width)--;
    (r.size.height)--;

    // 選択色を描画
    scol = [[(PoCoAppController *)([NSApp delegate]) editInfo] selColor];
    if (([scol isUnder]) || ([scol isPattern])) {
        [[NSColor windowBackgroundColor] set];
    } else {
        col = [[[[self->docCntl_ currentDocument] picture] palette] palette:[scol num]];
        [[NSColor colorWithCalibratedRed:[col floatRed]
                                   green:[col floatGreen]
                                    blue:[col floatBlue]
                                   alpha:(float)(1.0)] set];
    }
    [NSBezierPath fillRect:r];

    return;
}


// ----------------------------------------- instance - public - イベント処理系
//
// ボタンダウンイベントの受け入れ可否
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    function : 可否
//
-(BOOL)acceptsFirstMouse:(NSEvent *)evt
{
    // 種別判定は無視
    ;

    return YES;
}


//
// ボタンダウン処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    None
//
-(void)mouseDown:(NSEvent *)evt
{
    // 設定を反転
    [[(PoCoAppController *)([NSApp delegate]) editInfo] toggleUseUnderPattern];

    // 切り替えを通知(自身も受け取る)
    [[NSNotificationCenter defaultCenter] postNotificationName:PoCoChangeColor
                                                        object:nil];

    return;
}

@end
