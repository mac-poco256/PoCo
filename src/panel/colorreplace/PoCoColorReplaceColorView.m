//
//	Pelistina on Cocoa - PoCo -
//	色置換設定領域
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoColorReplaceColorView.h"

#import "PoCoAppController.h"
#import "PoCoMyDocument.h"
#import "PoCoPicture.h"
#import "PoCoPalette.h"

// 内部定数
static  unsigned int SEL_SIZE = 8;      // 1要素の大きさ(dot 単位)(枠含む)
static  unsigned int H_MAX = 16;        // 水平要素数(個数)

// ============================================================================
@implementation PoCoColorReplaceColorView

// --------------------------------------------------------- instance - private
//
// 色番号から矩形領域変換
//
//  Call
//    num : 色番号
//
//  Return
//    function : 対象矩形領域
//
-(NSRect)numToRect:(int)num
{
    NSRect r;

    r.origin.x = (float)((num % H_MAX) * SEL_SIZE);
    r.origin.y = (float)((num / H_MAX) * SEL_SIZE);
    r.size.width = (float)(SEL_SIZE);
    r.size.height = (float)(SEL_SIZE);

    return r;
}


//
// 選択の更新
//
//  Call
//    num : 選択番号
//    evt : 取得イベント
//
//  Return
//    function : 選択番号
//
-(int)selColor:(int)num
         event:(NSEvent *)evt
{
    const int oldNum = num;
    const NSPoint p = [PoCoPoint corrNSPoint:[self convertPoint:[evt locationInWindow] fromView:nil]];

    if ([self mouse:p inRect:[self bounds]]) {
        // 選択番号を取得
        num = ((int)(p.x) / SEL_SIZE) + (((int)(p.y) / SEL_SIZE) * H_MAX);

        // 切り替えた場合は再描画を発行
        if (oldNum != num) {
            [self setNeedsDisplayInRect:[self numToRect:oldNum]];
            [self setNeedsDisplayInRect:[self numToRect:num]];
        }
    }

    return num;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//   
//  Call
//    frameRect : 矩形領域(api 変数)
//     
//  Return
//    function  : 実体
//    leftNum_  : 主ボタンでの設定値(instance変数)
//    rightNum_ : 右ボタンでの設定値(instance変数)
//    docCntl_  : document controller(instance変数)
//
-(id)initWithFrame:(NSRect)frameRect;
{
    DPRINT((@"[PoCoColorReplaceColorView initWithFrame]\n"));

    // super class の初期化
    self = [super initWithFrame:frameRect];

    // 自身の初期化
    if (self != nil) {
        self->leftNum_ = 0;
        self->rightNum_ = 0;
        self->docCntl_ = nil;

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
//    docCntl_ : document controller(instance変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoColorReplaceColorView dealloc]\n"));

    // 資源を解放
    [self->docCntl_ release];
    self->docCntl_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// 表示要求
//
//  Call
//    rect      : 表示領域(api 変数)
//    leftNum_  : 主ボタンでの設定値(instance 変数)
//    rightNum_ : 右ボタンでの設定値(instance 変数)
//
//  Return
//    None
//
-(void)drawRect:(NSRect)rect
{
    int l;

    DPRINT((@"[PoCoColorReplaceColorView drawRect]\n"));

    for (l = 0; l < COLOR_MAX; (l)++) {
        if (NSIntersectsRect(rect, [self numToRect:l])) {
            [self drawColor:l
                   isSelect:((l == self->leftNum_) || (l == self->rightNum_))
                     isDown:(l == self->rightNum_)];
        }
    }

    return;
}


//
// 座標系を反転
//
//  Call
//    None
//
//  Return  
//    function : YES
// 
-(BOOL)isFlipped
{
    return YES;
}


//
// 1色分の描画
//
//  Call
//    num      : 番号
//    sel      : YES : 選択中表示
//               NO  : 非選択中表示
//    down     : YES : 下がり表示
//               NO  : 上がり表示
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)drawColor:(int)num
        isSelect:(BOOL)sel
          isDown:(BOOL)down
{
    NSRect  r;
    const PoCoPalette *plt = [[[self->docCntl_ currentDocument] picture] palette];
    const PoCoColor *col = [plt palette:num];

    if (col != nil) {
        // 座標を算出
        r = [self numToRect:num];

        // 選択中なら枠をつける
        if (sel) {
            if (down) {
                [[NSColor blackColor] set];
            } else {
                [[NSColor whiteColor] set];
            }
            [NSBezierPath fillRect:r];
            (r.origin.x)++;
            (r.origin.y)++;
            (r.size.width)--;
            (r.size.height)--;
            if (down) {
                [[NSColor whiteColor] set];
            } else {
                [[NSColor blackColor] set];
            }
            [NSBezierPath fillRect:r];
            (r.size.width)--;
            (r.size.height)--;
        }

        // 色を描画
        [[NSColor colorWithCalibratedRed:[col floatRed]
                                   green:[col floatGreen]
                                    blue:[col floatBlue]
                                   alpha:(float)(1.0)] set];
        [NSBezierPath fillRect:r];
    }

    return;
}


// ----------------------------------------------- instance - public - 選択内容
//
// 主ボタンでの設定値
//
//  Call
//    leftNum_ : 主ボタンでの設定値(instance変数)
//
//  Return
//    function : 設定内容
//
-(int)leftNum
{
    return self->leftNum_;
}


//
// 右ボタンでの設定値
//
//  Call
//    rightNum_ : 右ボタンでの設定値(instance変数)
//
//  Return
//    function : 設定内容
//
-(int)rightNum
{
    return self->rightNum_;
}


// ----------------------------------------- instance - public - イベント処理系
//
// ボタンダウン処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    leftNum_ : 主ボタンでの設定値(instance 変数)
//
-(void)mouseDown:(NSEvent *)evt
{
    self->leftNum_ = [self selColor:self->leftNum_
                              event:evt];

    return;
}


//
// ドラッグ処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    leftNum_ : 主ボタンでの設定値(instance 変数)
//
-(void)mouseDragged:(NSEvent *)evt
{
    self->leftNum_ = [self selColor:self->leftNum_
                              event:evt];

    return;
}


//
// 右ボタンダウン処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    rightNum_ : 右ボタンでの設定値(instance 変数)
//
-(void)rightMouseDown:(NSEvent *)evt
{
    self->rightNum_ = [self selColor:self->rightNum_
                               event:evt];

    return;
}


//
// 右ボタンドラッグ処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    rightNum_ : 右ボタンでの設定値(instance 変数)
//
-(void)rightMouseDragged:(NSEvent *)evt
{
    self->rightNum_ = [self selColor:self->rightNum_
                               event:evt];

    return;
}

@end
