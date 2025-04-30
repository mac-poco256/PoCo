//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 均一濃度 - 生成部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditUniformedDensityFactory.h"

#import "PoCoLayer.h"
#import "PoCoPalette.h"
#import "PoCoColorPattern.h"
#import "PoCoColorBuffer.h"

#import "PoCoEditUniformedDensityDrawLine01.h"
#import "PoCoEditUniformedDensityDrawLine02.h"
#import "PoCoEditUniformedDensityDrawLine03.h"
#import "PoCoEditUniformedDensityDrawLine04.h"
#import "PoCoEditUniformedDensityDrawLine05.h"
#import "PoCoEditUniformedDensityDrawLine06.h"
#import "PoCoEditUniformedDensityDrawLine07.h"
#import "PoCoEditUniformedDensityDrawLine08.h"
#import "PoCoEditUniformedDensityDrawLine09.h"
#import "PoCoEditUniformedDensityDrawLine10.h"
#import "PoCoEditUniformedDensityDrawLine11.h"
#import "PoCoEditUniformedDensityDrawLine12.h"
#import "PoCoEditUniformedDensityDrawLine13.h"
#import "PoCoEditUniformedDensityDrawLine14.h"
#import "PoCoEditUniformedDensityDrawLine15.h"
#import "PoCoEditUniformedDensityDrawLine16.h"

// ============================================================================
@implementation PoCoEditUniformedDensityDrawLineFactory

// ------------------------------------------------------------- class - public
//
// 生成
//
//  Call
//    bmp   : 描画対象 bitmap
//    cmode : 色演算モード
//    plt   : 使用パレット
//    pat   : 使用カラーパターン
//    buf   : 色保持情報
//    size  : ペン先サイズ(dot 単位)
//
//  Return
//    function : 実体
//
+(id)create:(PoCoBitmap *)bmp
    colMode:(PoCoColorMode)cmode
    palette:(PoCoPalette *)plt
    pattern:(PoCoColorPattern *)pat
     buffer:(PoCoColorBuffer *)buf
    penSize:(int)size
{
    id edit;

    edit = nil;

    // ペン先サイズにあわせた editter を生成 
    switch (size) {
        case 0:
        case 1:
        default:
            // 不明、1以下は必ず 1dot にする
            edit = [[PoCoEditUniformedDensityDrawLine01 alloc] init:bmp
                                                            colMode:cmode
                                                            palette:plt
                                                            pattern:pat
                                                             buffer:buf];
            break;
        case 2:
            edit = [[PoCoEditUniformedDensityDrawLine02 alloc] init:bmp
                                                            colMode:cmode
                                                            palette:plt
                                                            pattern:pat
                                                             buffer:buf];
            break;
        case 3:
            edit = [[PoCoEditUniformedDensityDrawLine03 alloc] init:bmp
                                                            colMode:cmode
                                                            palette:plt
                                                            pattern:pat
                                                             buffer:buf];
            break;
        case 4:
            edit = [[PoCoEditUniformedDensityDrawLine04 alloc] init:bmp
                                                            colMode:cmode
                                                            palette:plt
                                                            pattern:pat
                                                             buffer:buf];
            break;
        case 5:
            edit = [[PoCoEditUniformedDensityDrawLine05 alloc] init:bmp
                                                            colMode:cmode
                                                            palette:plt
                                                            pattern:pat
                                                             buffer:buf];
            break;
        case 6:
            edit = [[PoCoEditUniformedDensityDrawLine06 alloc] init:bmp
                                                            colMode:cmode
                                                            palette:plt
                                                            pattern:pat
                                                             buffer:buf];
            break;
        case 7:
            edit = [[PoCoEditUniformedDensityDrawLine07 alloc] init:bmp
                                                            colMode:cmode
                                                            palette:plt
                                                            pattern:pat
                                                             buffer:buf];
            break;
        case 8:
            edit = [[PoCoEditUniformedDensityDrawLine08 alloc] init:bmp
                                                            colMode:cmode
                                                            palette:plt
                                                            pattern:pat
                                                             buffer:buf];
            break;
        case 9:
            edit = [[PoCoEditUniformedDensityDrawLine09 alloc] init:bmp
                                                            colMode:cmode
                                                            palette:plt
                                                            pattern:pat
                                                             buffer:buf];
            break;
        case 10:
            edit = [[PoCoEditUniformedDensityDrawLine10 alloc] init:bmp
                                                            colMode:cmode
                                                            palette:plt
                                                            pattern:pat
                                                             buffer:buf];
            break;
        case 11:
            edit = [[PoCoEditUniformedDensityDrawLine11 alloc] init:bmp
                                                            colMode:cmode
                                                            palette:plt
                                                            pattern:pat
                                                             buffer:buf];
            break;
        case 12:
            edit = [[PoCoEditUniformedDensityDrawLine12 alloc] init:bmp
                                                            colMode:cmode
                                                            palette:plt
                                                            pattern:pat
                                                             buffer:buf];
            break;
        case 13:
            edit = [[PoCoEditUniformedDensityDrawLine13 alloc] init:bmp
                                                            colMode:cmode
                                                            palette:plt
                                                            pattern:pat
                                                             buffer:buf];
            break;
        case 14:
            edit = [[PoCoEditUniformedDensityDrawLine14 alloc] init:bmp
                                                            colMode:cmode
                                                            palette:plt
                                                            pattern:pat
                                                             buffer:buf];
            break;
        case 15:
            edit = [[PoCoEditUniformedDensityDrawLine15 alloc] init:bmp
                                                            colMode:cmode
                                                            palette:plt
                                                            pattern:pat
                                                             buffer:buf];
            break;
        case 16:
            edit = [[PoCoEditUniformedDensityDrawLine16 alloc] init:bmp
                                                            colMode:cmode
                                                            palette:plt
                                                            pattern:pat
                                                             buffer:buf];
            break;
    }

    return edit;
}

@end
