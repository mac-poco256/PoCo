//
// PoCoNewDocumentColorSelectView.m
// implementation of PoCoNewDocumentColorSelectView class.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//


#import "PoCoNewDocumentColorSelectView.h"

#import "PoCoPalette.h"

// 内部定数
static  unsigned int SEL_SIZE = 8;      // 1要素の大きさ(dot 単位)(枠含む)
static  unsigned int H_MAX = 16;        // 水平要素数(個数)
  
// ============================================================================
@implementation PoCoNewDocumentColorSelectView

// ----------------------------------------------------------------------------
// instance - private.

//
// 正規化された座標へ変換
//
//  Call
//    p  : 実座標(画面上)
//    rb : YES : 右下
//         NO  : 左上
//
//  Return
//    function : パレット平面位置
//
-(PoCoPoint *)toNormalPos:(PoCoPoint *)p
            isRightBottom:(BOOL)rb
{
    PoCoPoint *np;

    np = [[PoCoPoint alloc] initX:([p x] / SEL_SIZE)
                            initY:([p y] / SEL_SIZE)];
    if (rb) {
        [np moveX:-1 moveY:-1];
    }

    return np;
}


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
// 1要素分の描画
//
//  Call
//    num      : 色番号
//    sel      : YES : 選択状態
//               NO  : 非選択状態
//    palette_ : 色見本(instance 変数)
//
//  Return
//    None
//
-(void)drawColor:(int)num isSelect:(BOOL)sel
{
    NSRect  r;
    PoCoColor *col;

    col = [self->palette_ palette:num];
    if (col != nil) {
        // 座標を算出
        r = [self numToRect:num];

        // 選択中なら枠をつける
        if (sel) {
            [[NSColor whiteColor] set];
            [NSBezierPath fillRect:r];
            (r.origin.x)++;
            (r.origin.y)++;
            (r.size.width)--;
            (r.size.height)--;
            [[NSColor blackColor] set];
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


// ----------------------------------------------------------------------------
// instance - public.

//
// initialize
//
//  Call
//    frameRect : 矩形領域
//
//  Return
//    function : 実体
//    palette_ : 色見本(instance 変数)
//
-(id)initWithFrame:(NSRect)frameRect
{
    DPRINT((@"[PoCoNewDocumentColorSelectView initWithFrame]\n"));

    // super class の初期化
    self = [super initWithFrame:frameRect];

    // 自身の初期化
    if (self != nil) {
        self->palette_ = [[PoCoPalette alloc] init];
        if (self->palette_ == nil) {
            DPRINT((@"can't alloc PoCoPalette\n"));
            [self release];
            self = nil;
        }
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
//    palette_ : 色見本(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoNewDocumentColorSelectView dealloc]\n"));

    // 資源を解放
    [self->palette_ release];
    self->palette_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// awake from nib.
//
//  Call:
//    none.
//
//  Return:
//    none.
//
- (void)awakeFromNib
{
    // forwarded to super class.
    [super awakeFromNib];

    // set property.
    [self setClipsToBounds:YES];
    
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
// 表示要求
//
//  Call
//    rect    : 要求領域(api 変数)
//    selnum_ : 選択番号(instance 変数)
//
//  Return
//    None
//
-(void)drawRect:(NSRect)rect
{
    int i;
    int x;
    int y;
    PoCoRect *r;
    PoCoPoint *lt;
    PoCoPoint *rb;

    // 範囲の算出
    r = [[PoCoRect alloc] initNSRect:rect];
    lt = [self toNormalPos:[r  lefttop]
             isRightBottom:NO];
    rb = [self toNormalPos:[r rightbot]
             isRightBottom:YES];
    if ((r == nil) || (lt == nil) || (rb == nil)) {
        ;
    } else {
        // 表示
        if (([lt x] == [rb x]) && ([lt y] == [rb y])) {
            i = (([lt y] * H_MAX) + [lt x]);
            [self drawColor:i
                   isSelect:(i == self->selnum_)];
        } else if ([lt x] == [rb x]) {
            i = (([lt y] * H_MAX) + [lt x]);
            for (y = [lt y]; y <= [rb y]; (y)++, i += H_MAX) {
                [self drawColor:i
                       isSelect:(i == self->selnum_)];
            }
        } else if ([lt y] == [rb y]) {
            i = (([lt y] * H_MAX) + [lt x]);
            for (x = [lt x]; x <= [rb x]; (x)++, (i)++) {
                [self drawColor:i
                       isSelect:(i == self->selnum_)];
            }
        } else {
            for (y = [lt y]; y <= [rb y]; (y)++) {
                i = ((y * H_MAX) + [lt x]);
                for (x = [lt x]; x <= [rb x]; (x)++, (i)++) {
                    [self drawColor:i
                           isSelect:(i == self->selnum_)];
                }
            }
        }
    }
    [lt release];
    [rb release];
    [r release];

    return;
}


//
// 選択番号の設定
//
//  Call
//    num : 選択番号
//
//  Return
//    selnum_ : 選択番号(instance 変数)
//
-(void)setSelnum:(unsigned char)num
{
    self->selnum_ = num;

    return;
}


//
// 選択番号の取得
//
//  Call
//    selnum_ : 選択番号(instance 変数)
//
//  Return
//    function : 選択番号
//
-(unsigned char)selnum
{
    return self->selnum_;
}


// ----------------------------------------------------------------------------
// instance - public - event handlers (especially pointing device).

//
// ボタンダウン処理
//
//  Call
//    evt     : 発生イベント(api 変数)
//    selnum_ : 選択番号(instance 変数)
//
//  Return
//    selnum_ : 選択番号(instance 変数)
//
-(void)mouseDown:(NSEvent *)evt
{
    NSPoint p;
    const int old = self->selnum_;

    p = [self convertPoint:[evt locationInWindow]
                  fromView:nil];
    if ([self mouse:p inRect:[self bounds]]) {
        // 選択番号を取得
        self->selnum_ = (((int)(p.x) / SEL_SIZE) + (((int)(p.y) / SEL_SIZE) * H_MAX));
        if (old != self->selnum_) {
            [self setNeedsDisplayInRect:[self numToRect:old]];
            [self setNeedsDisplayInRect:[self numToRect:self->selnum_]];
        }
    }

    return;
}


//
// ドラッグ処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    None
//
-(void)mouseDragged:(NSEvent *)evt
{
    // mouse down と同じにする
    [self mouseDown:evt];

    return;
}

@end
