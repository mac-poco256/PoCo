//
//	Pelistina on Cocoa - PoCo -
//	広域通知受信部
//
//	Copyright (C) 2005-2019 KAENRYUU Koutoku.
//

#import "PoCoGlobalObserver.h"

#import "PoCoMyDocument.h"

// ============================================================================
@implementation PoCoGlobalObserver

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    None
//
//  Return
//    fucntion : 実体
//    docCntl_ : document controller(instance 変数)
//    notes_   : notification center(instance 変数)
//
-(id)init
{
    DPRINT((@"[PoCoGlobalObserver init]\n"));

    // super class の初期化
    self = [super init];

    // 自身の初期化
    if (self != nil) {
        // observer を登録
        self->docCntl_ = [NSDocumentController sharedDocumentController];
        self->notes_ = [NSNotificationCenter defaultCenter];

        // 編集対象変更通知
        [self->notes_ addObserver:self
                         selector:@selector(changePicture:)
                             name:PoCoChangePicture
                           object:nil];

        // 選択色変更通知
        [self->notes_ addObserver:self
                         selector:@selector(changeColor:)
                             name:PoCoChangeColor
                           object:nil];

        // パレット更新通知
        [self->notes_ addObserver:self
                         selector:@selector(changePalette:)
                             name:PoCoChangePalette
                           object:nil];

        // パレット属性更新通知
        [self->notes_ addObserver:self
                         selector:@selector(changePaletteAttr:)
                             name:PoCoChangePaletteAttr
                           object:nil];

        // レイヤー構造の編集
        [self->notes_ addObserver:self
                         selector:@selector(editLayer:)
                             name:PoCoEditLayer
                           object:nil];

        // 画像サイズ変更通知
        [self->notes_ addObserver:self
                         selector:@selector(resizeCanvas:)
                             name:PoCoCanvasResize
                           object:nil];

        // 切り抜き通知
        [self->notes_ addObserver:self
                         selector:@selector(clipImage:)
                             name:PoCoImageClip
                           object:nil];

        // 画像の編集
        [self->notes_ addObserver:self
                         selector:@selector(editPicture:)
                             name:PoCoEditPicture
                           object:nil];

        // 再描画の発行
        [self->notes_ addObserver:self
                         selector:@selector(redrawPicture:)
                             name:PoCoRedrawPicture
                           object:nil];

        // 座標情報の更新
        [self->notes_ addObserver:self
                         selector:@selector(editInfoChangePos:)
                             name:PoCoEditInfoChangePos
                           object:nil];

        // 描画機能変更通知
        [self->notes_ addObserver:self
                         selector:@selector(changeDrawTool:)
                             name:PoCoChangeDrawTool
                           object:nil];

        // ハンドル再描画
        [self->notes_ addObserver:self
                         selector:@selector(redrawHandle:)
                             name:PoCoRedrawGuideLine
                           object:nil];

        // 選択レイヤー変更通知
        [self->notes_ addObserver:self
                         selector:@selector(changeSelLayer:)
                             name:PoCoSelLayerChange
                           object:nil];

        // スペースキーイベント通知
        [self->notes_ addObserver:self
                         selector:@selector(spaceKeyEvent:)
                             name:PoCoSpaceKeyEvent
                           object:nil];

        // 表示ウィンドウダブルクリック通知
        [self->notes_ addObserver:self
                         selector:@selector(dclickOnSubView:)
                             name:PoCoDClickOnSubView
                           object:nil];
    }

    return self;
}


//
// deallocate
//
//  Call
//    notes_ : notification center(instance 変数)
//
//  Return
//    None
//
-(void)dealloc
{
    DPRINT((@"[PoCoGlobalObserver dealloc]\n"));

    // observer の登録を解除
    [self->notes_ removeObserver:self];

    // super class の解放
    [super dealloc];

    return;
}


// -------------------------------------------- instance - public - 各 observer
//
// 編集対象変更通知
//  主ウィンドウがこの通知を使用して他ウィンドウに変更を指示することもある
//  ので、GlobalObserver では通知を無視すること
//  (この通知を主ウィンドウに回想する必要もない)
//
//  Call
//    note : 通知内容
//
//  Return
//    None
//
-(void)changePicture:(NSNotification *)note
{
    // 何もしない
    ;

    return;
}


//
// 選択色変更通知
//
//  Call
//    note : 通知内容
//
//  Return
//    None
//
-(void)changeColor:(NSNotification *)note
{
    // 何もしない
    ;

    return;
}


//
// パレット更新通知
//
//  Call
//    note     : 通知内容
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)changePalette:(NSNotification *)note
{
    // パレットの変更を通達
    [[self->docCntl_ currentDocument] didUpdatePalette];

    // 更新済みに切り替える
    [[self->docCntl_ currentDocument] setUpdateState:NSChangeDone];

    return;
}


//
// パレット属性更新通知
//
//  Call
//    note     : 通知内容
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)changePaletteAttr:(NSNotification *)note
{
    int i;

    // 主ウィンドウの再描画
    if ([note object] == nil) {
        [[self->docCntl_ currentDocument] didUpdatePicture:nil];
    } else {
        i = [[note object] intValue];
        if (i & 0x00040000) {
            [[self->docCntl_ currentDocument] didUpdatePicture:nil];
        }
    }

    // 更新済みに切り替える
    [[self->docCntl_ currentDocument] setUpdateState:NSChangeDone];

    return;
}


//
// レイヤー構造の編集
//
//  Call
//    note     : 通知内容
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)editLayer:(NSNotification *)note
{
    // 主ウィンドウの再描画
    if ([[note object] boolValue]) {
        [[self->docCntl_ currentDocument] didUpdatePicture:nil];
    }

    // 更新済みに切り替える
    [[self->docCntl_ currentDocument] setUpdateState:NSChangeDone];

    return;
}


//
// 画像サイズ変更
//
//  Call
//    note     : 通知内容
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)resizeCanvas:(NSNotification *)note
{
    // サイズ変更を通達
    [[self->docCntl_ currentDocument] didLayerResize];

    // 更新済みに切り替える
    [[self->docCntl_ currentDocument] setUpdateState:NSChangeDone];

    return;
}


//
// 切り抜き変更
//
//  Call
//    note     : 通知内容
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)clipImage:(NSNotification *)note
{
    // サイズ変更を通達
    [[self->docCntl_ currentDocument] didLayerResize];

    // 更新済みに切り替える
    [[self->docCntl_ currentDocument] setUpdateState:NSChangeDone];

    return;
}


//
// 画像の編集
//
//  Call
//    note     : 通知内容
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)editPicture:(NSNotification *)note
{
    PoCoEditPictureNotification *obj;

    obj = [note object];

    // 主ウィンドウの再描画
    if (obj != nil) {
        [[self->docCntl_ currentDocument] didUpdatePicture:[obj rect]];
    } else {
        [[self->docCntl_ currentDocument] didUpdatePicture:nil];
    }

    // 更新済みに切り替える
    [[self->docCntl_ currentDocument] setUpdateState:NSChangeDone];

    return;
}


//
// 再描画の発行
//
//  Call
//    note     : 通知内容
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)redrawPicture:(NSNotification *)note
{
    PoCoEditPictureNotification *obj;

    obj = [note object];

    // 主ウィンドウの再描画
    if (obj != nil) {
        [[self->docCntl_ currentDocument] didUpdatePicture:[obj rect]];
    } else {
        [[self->docCntl_ currentDocument] didUpdatePicture:nil];
    }

    return;
}


//
// 座標情報の更新
//
//  Call
//    note : 通知内容
//
//  Return
//    None
//
-(void)editInfoChangePos:(NSNotification *)note
{
    // 何もしない
    ;

    return;
}


//
// 描画機能変更通知
//
//  Call
//    note     : 通知内容
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)changeDrawTool:(NSNotification *)note
{
    // 描画機能変更を通知する
    [[self->docCntl_ currentDocument] didChangeDrawTool];

    return;
}


//
// ハンドル再描画
//
//  Call
//    note     : 通知内容
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)redrawHandle:(NSNotification *)note
{
    // ハンドル再描画
    [[self->docCntl_ currentDocument] drawGuideLine];

    return;
}


//
// 選択レイヤー変更通知
//
//  Call
//    note     : 通知内容
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)changeSelLayer:(NSNotification *)note
{
    // 編集状態解除
    [[self->docCntl_ currentDocument] cancelEdit];

    return;
}


//
// スペースキーイベント通知
//
//  Call
//    note     : 通知内容
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)spaceKeyEvent:(NSNotification *)note
{
    [[self->docCntl_ currentDocument] spaceKeyEvent:[[note object] boolValue]];

    return;
}


//
// 表示ウィンドウダブルクリック通知
//
//  Call
//    note     : 通知内容
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)dclickOnSubView:(NSNotification *)note
{
    [[self->docCntl_ currentDocument] dclickOnSubView:[note object]];

    return;
}

@end
