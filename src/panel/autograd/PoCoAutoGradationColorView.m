//
//	Pelistina on Cocoa - PoCo -
//	自動グラデーション対象色設定領域
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoAutoGradationColorView.h"

#import "PoCoAppController.h"
#import "PoCoMyDocument.h"
#import "PoCoPicture.h"
#import "PoCoPalette.h"

#import "PoCoAutoGradationPanel.h"

// 内部定数
static  unsigned int SEL_SIZE = 8;      // 1要素の大きさ(dot 単位)(枠含む)
static  unsigned int H_MAX = 16;        // 水平要素数(個数)

// ============================================================================
@implementation PoCoAutoGradationColorView

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


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    frameRect : 矩形領域(api 変数)
//     
//  Return
//    function  : 実体
//    isOn_[]   : 設定内容(instance 変数)
//    setValue_ : 設定値(instance 変数)
//    docCntl_  : document controller(instance 変数)
//
-(id)initWithFrame:(NSRect)frameRect;
{
    int l;

    DPRINT((@"[PoCoAutoGrdationColorView initWithFrame]\n"));

    // super class の初期化
    self = [super initWithFrame:frameRect];

    // 自身の初期化
    if (self != nil) {
        for (l = 0; l < COLOR_MAX; l++) {
            self->isOn_[l] = NO;
        }
        self->setValue_ = NO;

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
    DPRINT((@"[PoCoAutoGrdationColorView dealloc]\n"));

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
//    rect    : 表示領域(api 変数)
//    isOn_[] : 設定内容(instance 変数)
//
//  Return
//    None
//
-(void)drawRect:(NSRect)rect
{
    int l;

    DPRINT((@"[PoCoAutoGrdationColorView drawRect]\n"));

    for (l = 0; l < COLOR_MAX; (l)++) {
        if (NSIntersectsRect(rect, [self numToRect:l])) {
            [self drawColor:l
                   isSelect:self->isOn_[l]];
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
// 取得(すべて)
//
//  Call
//    isOn_[] : 設定内容(instance 変数)
//
//  Return
//    function : 内容
//
-(const BOOL *)matrix
{
    return (const BOOL *)(&(self->isOn_[0]));
}


//
// 取得(個別)
//
//  Call
//    index   : 対象
//    isOn_[] : 設定内容(instance 変数)
//
//  Return
//    function : 内容
//
-(BOOL)attribute:(int)index
{
    return self->isOn_[index];
}


//
// 設定
//
//  Call
//    on    : 設定値
//    index : 設定対象
//
//  Return
//    isOn_[] : 設定内容(instance 変数)
//
-(void)setAttribute:(BOOL)on
            atIndex:(int)index
{
    self->isOn_[index] = on;

    return;
}


//
// 1色分の描画
//
//  Call
//    num      : 番号
//    sel      : YES : 選択中表示
//               NO  : 非選択中表示
//    docCntl_ : document controller(instance 変数)
//
//  Return
//    None
//
-(void)drawColor:(int)num
        isSelect:(BOOL)sel
{
    NSRect  r;
    const PoCoPalette *plt = [[[self->docCntl_ currentDocument] picture] palette];
    const PoCoColor *col = [plt palette:num];

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


//
// 連続性を検証
//
//  Call
//    isOn_[] : 設定内容(instance 変数)
//
//  Return
//    function : 判定結果
//
-(BOOL)verifyContinuous
{
    BOOL result;
    BOOL noAttach;
    BOOL isStart;
    int l;

    result = YES;
    noAttach = YES;
    isStart = NO;

    if ([self verifySelectExist]) {
        // 先頭から順番に穴がないかを検証
        for (l = 0; l < COLOR_MAX; (l)++) {
            if (noAttach) {
                // 未到達(先頭を探している)
                if (self->isOn_[l]) {
                    // 先頭に達した
                    noAttach = NO;
                    isStart = YES;
                }
            } else if (isStart) {
                // 先頭には達している(末尾を探している)
                if (self->isOn_[l]) {
                    // 連続している
                    ;
                } else {
                    // 末尾に達した(はず)
                    noAttach = NO;
                    isStart = NO;
                }
            } else {
                // 末尾には達している(はず)(穴を探している)
                if (self->isOn_[l]) {
                    // 穴になっていたので連続していない
                    result = NO;
                    break;
                }
            }
        }
    } else {
        // そもそも2つ以上を選択していない
        result = NO;
    }

    return result;
}


//
// 選択の有無を検証
//  2つ以上なければ偽とする
//
//  Call
//    isOn_[] : 設定内容(instance 変数)
//
//  Return
//    function : 判定結果
//
-(BOOL)verifySelectExist
{
    int num;
    int l;

    num = 0;

    // 先頭から順番に穴がないかを検証
    for (l = 0; l < COLOR_MAX; (l)++) {
        // 選択しているものを数え上げる
        if (self->isOn_[l]) {
            (num)++;
        }
    }

    return (num >= 2);
}


// ----------------------------------------- instance - public - イベント処理系
//
// ボタンダウン処理
//
//  Call
//    evt     : 発生イベント(api 変数)
//    isOn_[] : 設定内容(instance 変数)
//
//  Return
//    setValue_ : 設定値(instance 変数)
//
-(void)mouseDown:(NSEvent *)evt
{
    int num;
    const NSPoint p = [PoCoPoint corrNSPoint:[self convertPoint:[evt locationInWindow] fromView:nil]];

    if ([self mouse:p inRect:[self bounds]]) {
        // 選択番号を取得
        num = ((int)(p.x) / SEL_SIZE) + (((int)(p.y) / SEL_SIZE) * H_MAX);

        // 設定値を判定
        self->setValue_ = ((self->isOn_[num]) ? NO : YES);

        // ドラッグ処理と同じにする
        [self mouseDragged:evt];
    }

    return;
}


//
// ドラッグ処理
//
//  Call
//    evt       : 発生イベント(api 変数)
//    setValue_ : 設定値(instance 変数)
//
//  Return
//    isOn_[] : 設定内容(instance 変数)
//
-(void)mouseDragged:(NSEvent *)evt
{
    int num;
    const NSPoint p = [PoCoPoint corrNSPoint:[self convertPoint:[evt locationInWindow] fromView:nil]];

    if ([self mouse:p inRect:[self bounds]]) {
        // 選択番号を取得
        num = ((int)(p.x) / SEL_SIZE) + (((int)(p.y) / SEL_SIZE) * H_MAX);

        // 値を反映
        if (self->setValue_ != self->isOn_[num]) {
            self->isOn_[num] = self->setValue_;

            // 再描画
            [self setNeedsDisplayInRect:[self numToRect:num]];

            // 妥当性評価(panel 側に投げる)
            [[[self window] windowController] verifySetting];
        }
    }

    return;
}

@end
