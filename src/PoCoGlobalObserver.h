//
//	Pelistina on Cocoa - PoCo -
//	広域通知受信部
//
//	Copyright (C) 2005-2019 KAENRYUU Koutoku.
//
// 編集に伴う通知の受け取りと currentDocument への分配が目的
//

#import <Foundation/Foundation.h>

// ----------------------------------------------------------------------------
@interface PoCoGlobalObserver : NSObject
{
    NSDocumentController *docCntl_;     // document controller
    NSNotificationCenter *notes_;       // notification center
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// 各 observer
-(void)changePicture:(NSNotification *)note;      // 編集対象変更通知
-(void)changeColor:(NSNotification *)note;        // 選択色変更通知
-(void)changePalette:(NSNotification *)note;      // パレット更新通知
-(void)changePaletteAttr:(NSNotification *)note;  // パレット属性更新通知
-(void)editLayer:(NSNotification *)note;          // レイヤー構造の編集
-(void)resizeCanvas:(NSNotification *)note;       // 画像サイズ変更
-(void)clipImage:(NSNotification *)note;          // 切り抜き
-(void)editPicture:(NSNotification *)note;        // 画像の編集
-(void)redrawPicture:(NSNotification *)note;      // 再描画の発行
-(void)editInfoChangePos:(NSNotification *)note;  // 座標情報の更新
-(void)changeDrawTool:(NSNotification *)note;     // 描画機能変更通知
-(void)redrawHandle:(NSNotification *)note;       // ハンドル再描画
-(void)changeSelLayer:(NSNotification *)note;     // 選択レイヤー変更通知
-(void)spaceKeyEvent:(NSNotification *)note;      // スペースキーイベント通知
-(void)dclickOnSubView:(NSNotification *)note;    // 表示ウィンドウダブルクリック通知

@end
