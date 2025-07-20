//
// PoCoMonochromePatternView.m
// implementation of PoCoMonochromePatternView class.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoMonochromePatternView.h"

#import "PoCoMonochromePattern.h"
#import "PoCoPenStyle.h"
#import "PoCoTilePattern.h"

// 内部定数
static  unsigned int SEL_SIZE = 18;     // 1要素の大きさ(dot 単位)(枠含む)
static  unsigned int H_MAX = 8;         // 水平要素数(個数)

// ============================================================================
@implementation PoCoMonochromePatternView

// ----------------------------------------------------------------------------
// instance - public.

//
// initialize
//
//  Call
//    frameRect : 矩形領域(api 変数)
//    pat       : 登録パターン郡
//
//  Return
//    function : 実体
//    pattern_ : パターン群(instance変数)
//
-(id)initWithFrame:(NSRect)frameRect
        setPattern:(id)pat
{
    DPRINT((@"[PoCoMonochromePatternView initWithFrame: setPattern:]\n"));

    // super class の初期化
    self = [super initWithFrame:frameRect];

    // 自身の初期化
    if (self != nil) {
        self->pattern_ = pat;
        [self->pattern_ retain];
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
//    pattern_ : パターン群(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoMonochromePatternView dealloc]\n"));

    // 資源の解放
    [self->pattern_ release];
    self->pattern_ = nil;

    // super class の解放
    [super dealloc];

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
// パターンを更新
//  基底では何もしない
//
//  Call
//    pat : 設定パターン
//
//  Return
//    None
//
-(void)updatePattern:(PoCoMonochromePattern *)pat
{
    return;
}


//
// 1パターン分の描画
//
//  Call
//    num      : 番号
//    sel      : YES : 選択中番号
//               NO  : 非選択中表示
//    pattern_ : パターン群(instance 変数)
//
//  Return
//    None
//
-(void)drawPattern:(int)num
          isSelect:(BOOL)sel
{
    NSRect r;
    NSBitmapImageRep *img;
    PoCoMonochromePattern *pat;

    pat = [self->pattern_ pattern:num];
    if (pat != nil) {
        // 枠の描画
        r = [self numToRect:num];
        if (sel) {
           [[NSColor whiteColor] set];
        } else {
           [[NSColor blackColor] set];
        }
        [NSBezierPath fillRect:r];
        (r.origin.x)++;
        (r.origin.y)++;
        (r.size.width)--;
        (r.size.height)--;
        if (sel) {
           [[NSColor blackColor] set];
        } else {
           [[NSColor whiteColor] set];
        }
        [NSBezierPath fillRect:r];
        (r.size.width)--;
        (r.size.height)--;

        // 内容の描画
        img = [pat getImage];
        if (img != nil) {
            [img drawAtPoint:r.origin];
            [img release];
        }
    }

    return;
}


//
// 要素番号から矩形領域へ変換
//
//  Call
//    num : 要素番号
//
//  Return
//    function : 矩形領域
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
// 座標から要素番号へ変換
//
//  Call
//    pos : 座標
//
//  Return
//    function : 要素番号
//
-(unsigned int)pointToNum:(NSPoint)pos
{
    return ((int)(pos.x) / SEL_SIZE) + (((int)(pos.y) / SEL_SIZE) * H_MAX);
}


// ----------------------------------------------------------------------------
// instance - public - change the selected pattern.

//
// 次の選択肢へ
//  基底では何もしない
//
//  Call
//    None
//
//  Return
//    None
//
-(void)nextSelection
{
    return;
}


//
// 前の選択肢へ
//  基底では何もしない
//
//  Call
//    None
//
//  Return
//    None
//
-(void)prevSelection
{
    return;
}


// ----------------------------------------------------------------------------
// instance - public - revert pattern.

//
// revert all patterns.
//
//  Call:
//    none.
//
//  Return:
//    none.
//
- (void)revertAllPatterns
{
    // do nothing.
    ;

    return;
}


//
// revert pattern at index.
//
//  Call:
//    none.
//
//  Return:
//    none.
//
- (void)revertPattern
{
    // do nothing.
    ;

    return;
}

@end
