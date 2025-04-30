//
//	Pelistina on Cocoa - PoCo -
//	2値パターン編集領域
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoMonochromePatternEditView.h"

#import "PoCoMonochromePattern.h"
#import "PoCoMonochromePatternSampleView.h"

// 内部定数
static unsigned int PIX_SIZE = 8;       // 1pixel の占める領域(dot 単位)

// ============================================================================
@implementation PoCoMonochromePatternEditView

// --------------------------------------------------------- instance - private
//
// 正規化された座標へ変換
//
//  Call
//    p  : 実座標(画面上)
//    rb : YES : 右下
//         NO  : 左上
//
//  Return
//    function : パターン内座標
//
-(PoCoPoint *)toNormalPos:(PoCoPoint *)p
            isRightBottom:(BOOL)rb
{
    PoCoPoint *np = [[PoCoPoint alloc] initX:([p x] / PIX_SIZE)
                                       initY:([p y] / PIX_SIZE)];

    if (rb) {
        [np moveX:-1 moveY:-1];
    }

    return np;
}


//
// 実座標へ変換
//
//  Call
//    x : パターン内X軸
//    y : パターン内Y軸
//
//  Return
//    r : 領域
//
-(NSRect)toRealRectX:(unsigned int)x
               withY:(unsigned int)y
{
    NSRect r;

    r.origin.x = (float)(x * PIX_SIZE);
    r.origin.y = (float)(y * PIX_SIZE);
    r.size.width = (float)(PIX_SIZE);
    r.size.height = (float)(PIX_SIZE);

    return r;
}


//
// 1点分の表示
//
//  Call
//    pat : 対象パターン情報
//    rb  : pat の rowbytes
//    x   : パターン内X軸
//    y   : パターン内Y軸
//
//  Return
//    None
//
-(void)drawPoint:(const unsigned char *)pat
        rowBytes:(unsigned int)rb
             atX:(unsigned int)x
             atY:(unsigned int)y
{
    if (pat[y * rb + x] != 0) {
        [[NSColor whiteColor] set];
    } else {
        [[NSColor blackColor] set];
    }
    [NSBezierPath fillRect:[self toRealRectX:x withY:y]];

    return;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    frame : 矩形領域(api 変数)
//
//  Return
//    function : 実体
//    isSet_   : マスクを設定するか否か(instance 変数)
//    pattern_ : 編集対象パターン(instance 変数)
//
-(id)initWithFrame:(NSRect)frame
{
    DPRINT((@"[PoCoMonochromePatternEditView initWithFrame]\n"));

    // super class の初期化
    self = [super initWithFrame:frame];

    // 自身の初期化
    if (self != nil) {
        self->isSet_ = NO;
        self->pattern_ = nil;

        // 編集対象のパターン(複製先)を準備
        self->pattern_ = [[PoCoMonochromePattern alloc] init];
        if (self->pattern_ == nil) {
            DPRINT((@"can't alloc PoCoMonochromePattern\n"));
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
//    pattern_ : 編集対象パターン(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoMonochromePatternEditView dealloc]\n"));

    // 資源の解放
    [self->pattern_ release];
    self->pattern_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// パターンを取得
//
//  Call
//    pattern_ : 編集対象パターン(instance 変数)
//
//  Return
//    function : パターン
//
-(PoCoMonochromePattern *)pattern
{
    return self->pattern_;
}


//
// パターンを設定
//
//  Call
//    pat         : パターン
//    sampleView_ : サンプル表示領域(outlet)
//
//  Return
//    pattern_ : 編集対象パターン(instance 変数)
//
-(void)setPattern:(PoCoMonochromePattern *)pat
{
    DPRINT((@"[PoCoMonochromePatternEditView setPattern]\n"));

    [self->pattern_ setPattern:[pat pattern]
                         width:[pat width]
                        height:[pat height]];
    [self setNeedsDisplay:YES];

    // 見本側の設定
    [self->sampleView_ setPattern:self->pattern_];
    [self->sampleView_ setNeedsDisplay:YES];

    return;
}


//
// 表示要求
//
//  Call
//    rect    : 再描画領域(api 変数)
//    pattern : 編集対象パターン(instance 変数)
//
//  Return
//    None
//
-(void)drawRect:(NSRect)rect
{
    unsigned int x;
    unsigned int y;
    PoCoRect *r;
    PoCoPoint *lt;
    PoCoPoint *rb;
    const unsigned char *pat = [self->pattern_ pattern];
    const unsigned int rbyte = ([self->pattern_ width] + ([self->pattern_ width] & 1));

    // 範囲の算出
    r = [[PoCoRect alloc] initNSRect:rect];
    lt = [self toNormalPos:[r  lefttop]
             isRightBottom:NO];
    rb = [self toNormalPos:[r rightbot]
             isRightBottom:YES];
    if ((r == nil) || (lt == nil) || (rb == nil)) {
        ;
    } else {
        if (([lt x] == [rb x]) && ([lt y] == [rb y])) {
            [self drawPoint:pat
                   rowBytes:rbyte
                        atX:[lt x]
                        atY:[lt y]];
        } else if ([lt x] == [rb x]) {
            for (y = [lt y]; y <= [rb y]; (y)++) {
                [self drawPoint:pat
                       rowBytes:rbyte
                            atX:[lt x]
                            atY:y];
            }
        } else if ([lt y] == [rb y]) {
            for (x = [lt x]; x <= [rb x]; (x)++) {
                [self drawPoint:pat
                       rowBytes:rbyte
                            atX:x
                            atY:[lt y]];
            }
        } else {
            for (y = [lt y]; y <= [rb y]; (y)++) {
                for (x = [lt x]; x <= [rb x]; (x)++) {
                    [self drawPoint:pat
                           rowBytes:rbyte
                                atX:x
                                atY:y];
                }
            }
        }
    }
    [r release];
    [lt release];
    [rb release];

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


// --------------------------------- instance - public - マウスイベント処理関連
//
// ボタンダウン処理
//
//  Call
//    evt      : 発生イベント(api 変数)
//    pattern_ : 編集対象パターン(instance 変数)
//
//  Return
//    isSet_ : マスクを設定するか否か(instance 変数)
//
-(void)mouseDown:(NSEvent *)evt
{
    NSPoint p = [self convertPoint:[evt locationInWindow] fromView:nil];
    PoCoPoint *tp;
    PoCoPoint *dp;
    const unsigned char *pat = [self->pattern_ pattern];
    const unsigned int rb = ([self->pattern_ width] + ([self->pattern_ width] & 1));

    if ([self mouse:p inRect:[self bounds]]) {
        tp = [[PoCoPoint alloc] initNSPoint:p];
        dp = [self toNormalPos:tp
                 isRightBottom:NO];
        self->isSet_ = ((pat[[dp y] * rb + [dp x]] != 0x00) ? NO : YES);
        [tp release];
        [dp release];

        // ドラッグ処理にまわす
        [self mouseDragged:evt];
    }

    return;
}


//
// ドラッグ処理
//  直接 pattern の内容を操作する
//
//  Call
//    evt         : 発生イベント(api 変数)
//    isSet_      : マスクを設定するか否か(instance 変数)
//    sampleView_ : サンプル表示領域(outlet)
//
//  Return
//    pattern_ : 編集対象パターン(instance 変数)
//
-(void)mouseDragged:(NSEvent *)evt
{
    NSPoint p = [self convertPoint:[evt locationInWindow] fromView:nil];
    PoCoPoint *tp;
    PoCoPoint *dp;
    unsigned char *pat = (unsigned char *)([self->pattern_ pattern]);
    const unsigned int rb = ([self->pattern_ width] + ([self->pattern_ width] & 1));

    if ([self mouse:p inRect:[self bounds]]) {
        tp = [[PoCoPoint alloc] initNSPoint:p];
        dp = [self toNormalPos:tp
                 isRightBottom:NO];
        pat[[dp y] * rb + [dp x]] = ((self->isSet_) ? 0x01 : 0x00);
        [self setNeedsDisplayInRect:[self toRealRectX:[dp x] withY:[dp y]]];
        [self->sampleView_ setNeedsDisplay:YES];
        [tp release];
        [dp release];
    }

    return;
}

@end
