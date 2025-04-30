//
//	Pelistina on Cocoa - PoCo -
//	色置換設定領域
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// ----------------------------------------------------------------------------
@interface PoCoColorReplaceColorView : NSView
{
    int leftNum_;                       // 主ボタンでの設定値
    int rightNum_;                      // 右ボタンでの設定値

    NSDocumentController *docCntl_;
}

// initialize
-(id)initWithFrame:(NSRect)frameRect;

// deallocate
-(void)dealloc;

// 表示要求
-(void)drawRect:(NSRect)rect;

// 座標系を反転
-(BOOL)isFlipped;

// 1色分の描画
-(void)drawColor:(int)num
        isSelect:(BOOL)sel
          isDown:(BOOL)down;

// 選択内容
-(int)leftNum;
-(int)rightNum;

// ボタンダウン処理
-(void)mouseDown:(NSEvent *)evt;
-(void)mouseDragged:(NSEvent *)evt;
-(void)rightMouseDown:(NSEvent *)evt;
-(void)rightMouseDragged:(NSEvent *)evt;

@end
