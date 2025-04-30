//
//	Pelistina on Cocoa - PoCo -
//	テクスチャ色設定領域
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoTextureColorView.h"

#import "PoCoAppController.h"
#import "PoCoMyDocument.h"
#import "PoCoPicture.h"
#import "PoCoPalette.h"

// 内部定数
static  unsigned int SEL_SIZE = 8;      // 1要素の大きさ(dot 単位)(枠含む)
static  unsigned int H_MAX = 16;        // 水平要素数(個数)

// ============================================================================
@implementation PoCoTextureColorView

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
    const NSPoint p = [PoCoPoint corrNSPoint:[self convertPoint:[evt locationInWindow] fromView:nil]];

    if ([self mouse:p inRect:[self bounds]]) {
        // 選択番号を取得
        num = ((int)(p.x) / SEL_SIZE) + (((int)(p.y) / SEL_SIZE) * H_MAX);
    }

    return num;
}


//
// 選択表示用行列を設定
//
//  Call
//    top_  : 先頭の選択色(instace 変数)
//    hori_ : 水平範囲(instace 変数)
//    vert_ : 垂直範囲(instace 変数)
//
//  Return
//    matrix_[] : 選択表示用(instance 変数)
//
-(void)setMartix
{
    int x;
    int y;
    int idx;

    memset(self->matrix_, 0x00, (COLOR_MAX * sizeof(BOOL)));

    for (y = 0; y < self->vert_; (y)++) {
        idx = (self->top_ + (y * 16));
        for (x = 0; x < self->hori_; (x)++) {
            if (idx < COLOR_MAX) {
                self->matrix_[idx] = YES;
                (idx)++;
            }
        }
    }

    // 再描画を発行しておく
    [self setNeedsDisplay:YES];

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
//    function  : 実体
//    top_      : 先頭の選択色(instace 変数)
//    hori_     : 水平範囲(instace 変数)
//    vert_     : 垂直範囲(instace 変数)
//    docCntl_  : document controller(instance 変数)
//    matrix_[] : 選択表示用(instance 変数)
//
-(id)initWithFrame:(NSRect)frameRect;
{
    DPRINT((@"[PoCoColorReplaceColorView initWithFrame]\n"));

    // super class の初期化
    self = [super initWithFrame:frameRect];

    // 自身の初期化
    if (self != nil) {
        self->top_ = 0;
        self->hori_ = 1;
        self->vert_ = 1;
        self->docCntl_ = nil;
        memset(self->matrix_, 0x00, (COLOR_MAX * sizeof(BOOL)));

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
//    top_      : 先頭の選択色(instace 変数)
//    matrix_[] : 選択表示用(instance 変数)
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
                   isSelect:self->matrix_[l]
                     isDown:(l != self->top_)];
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


// --------------------------------------------------- instance - public - 設定
//
// 水平範囲
//
//  Call
//    val : 設定内容
//
//  Return
//    hori_  : 水平範囲(instace 変数)
//
-(void)setHoriRange:(int)val
{
    self->hori_ = val;
    [self setMartix];

    return;
}


//
// 垂直範囲
//
//  Call
//    val : 設定内容
//
//  Return
//    vert_ : 垂直範囲(instace 変数)
//
-(void)setVertRange:(int)val
{
    self->vert_ = val;
    [self setMartix];

    return;
}


//
// 範囲(両方)
//
//  Call
//    h : 設定内容(水平)
//    v : 設定内容(垂直)
//
//  Return
//    hori_  : 水平範囲(instace 変数)
//    vert_ : 垂直範囲(instace 変数)
//
-(void)setHoriRange:(int)h
       andVertRange:(int)v
            
{
    self->hori_ = h;
    self->vert_ = v;
    [self setMartix];

    return;
}


// ----------------------------------------------- instance - public - 選択内容
//
// 先頭の選択色
//
//  Call
//    top_ : 主ボタンでの設定値(instance 変数)
//
//  Return
//    function : 設定内容
//
-(int)topIndex
{
    return self->top_;
}


// ----------------------------------------- instance - public - イベント処理系
//
// ボタンダウン処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    top_ : 先頭の選択色(instance 変数)
//
-(void)mouseDown:(NSEvent *)evt
{
    self->top_ = [self selColor:self->top_
                          event:evt];
    [self setMartix];

    return;
}

@end
