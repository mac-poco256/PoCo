//
//	Pelistina on Cocoa - PoCo -
//	2値パターン見本表示領域
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import "PoCoMonochromePatternSampleView.h"

#import "PoCoMonochromePattern.h"

// ============================================================================
@implementation PoCoMonochromePatternSampleView

// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    frame : 矩形領域(api 変数)
//
//  Return
//    function : 実体
//    pattern_ : 表示対象パターン(instance 変数)
//
-(id)initWithFrame:(NSRect)frame
{
    // super class を初期化
    self = [super initWithFrame:frame];

    // 自身の初期化
    if (self != nil) {
        self->pattern_ = nil;
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
//    pattern_ : 表示対象パターン(instance 変数)
//
-(void)dealloc
{
    // 資源を解放
    [self->pattern_ release];
    self->pattern_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 表示パターンを設定
//
//  Call
//    pat : 設定パターン
//
//  Return
//    pattern_ : 表示対象パターン(instance 変数)
//
-(void)setPattern:(PoCoMonochromePattern *)pat
{
    // 以前の分を忘れる
    [self->pattern_ release];
    self->pattern_ = nil;

    // 差し替え
    self->pattern_ = pat;
    [self->pattern_ retain];

    return;
}


//
// 表示要求
//
//  Call
//    rect     : 表示領域(api 変数)
//    pattern_ : 表示対象パターン(instance 変数)
//
//  Return
//    None
//
-(void)drawRect:(NSRect)rect
{
    NSBitmapImageRep *img = [self->pattern_ getImage];

//    DPRINT((@"[PoCoMonochromePatternSampleView drawRect]\n"));

    // 順々に表示していくだけ
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
    [img drawAtPoint:NSMakePoint((float)( 0.0), (float)( 0.0))];
    [img drawAtPoint:NSMakePoint((float)(16.0), (float)( 0.0))];
    [img drawAtPoint:NSMakePoint((float)( 0.0), (float)(16.0))];
    [img drawAtPoint:NSMakePoint((float)(16.0), (float)(16.0))];

    [img release];

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

@end
