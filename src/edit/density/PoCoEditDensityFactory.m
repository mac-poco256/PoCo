//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 濃度 - 生成部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditDensityFactory.h"

#import "PoCoLayer.h"
#import "PoCoPalette.h"
#import "PoCoColorPattern.h"
#import "PoCoColorBuffer.h"

#import "PoCoEditDensityDrawLine01.h"
#import "PoCoEditDensityDrawLine02.h"
#import "PoCoEditDensityDrawLine03.h"
#import "PoCoEditDensityDrawLine04.h"
#import "PoCoEditDensityDrawLine05.h"
#import "PoCoEditDensityDrawLine06.h"
#import "PoCoEditDensityDrawLine07.h"
#import "PoCoEditDensityDrawLine08.h"
#import "PoCoEditDensityDrawLine09.h"
#import "PoCoEditDensityDrawLine10.h"
#import "PoCoEditDensityDrawLine11.h"
#import "PoCoEditDensityDrawLine12.h"
#import "PoCoEditDensityDrawLine13.h"
#import "PoCoEditDensityDrawLine14.h"
#import "PoCoEditDensityDrawLine15.h"
#import "PoCoEditDensityDrawLine16.h"

// ============================================================================
@implementation PoCoEditDensityDrawLineFactory

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
            edit = [[PoCoEditDensityDrawLine01 alloc] init:bmp
                                                   colMode:cmode
                                                   palette:plt
                                                   pattern:pat
                                                    buffer:buf];
            break;
        case 2:
            edit = [[PoCoEditDensityDrawLine02 alloc] init:bmp
                                                   colMode:cmode
                                                   palette:plt
                                                   pattern:pat
                                                    buffer:buf];
            break;
        case 3:
            edit = [[PoCoEditDensityDrawLine03 alloc] init:bmp
                                                   colMode:cmode
                                                   palette:plt
                                                   pattern:pat
                                                    buffer:buf];
            break;
        case 4:
            edit = [[PoCoEditDensityDrawLine04 alloc] init:bmp
                                                   colMode:cmode
                                                   palette:plt
                                                   pattern:pat
                                                    buffer:buf];
            break;
        case 5:
            edit = [[PoCoEditDensityDrawLine05 alloc] init:bmp
                                                   colMode:cmode
                                                   palette:plt
                                                   pattern:pat
                                                    buffer:buf];
            break;
        case 6:
            edit = [[PoCoEditDensityDrawLine06 alloc] init:bmp
                                                   colMode:cmode
                                                   palette:plt
                                                   pattern:pat
                                                    buffer:buf];
            break;
        case 7:
            edit = [[PoCoEditDensityDrawLine07 alloc] init:bmp
                                                   colMode:cmode
                                                   palette:plt
                                                   pattern:pat
                                                    buffer:buf];
            break;
        case 8:
            edit = [[PoCoEditDensityDrawLine08 alloc] init:bmp
                                                   colMode:cmode
                                                   palette:plt
                                                   pattern:pat
                                                    buffer:buf];
            break;
        case 9:
            edit = [[PoCoEditDensityDrawLine09 alloc] init:bmp
                                                   colMode:cmode
                                                   palette:plt
                                                   pattern:pat
                                                    buffer:buf];
            break;
        case 10:
            edit = [[PoCoEditDensityDrawLine10 alloc] init:bmp
                                                   colMode:cmode
                                                   palette:plt
                                                   pattern:pat
                                                    buffer:buf];
            break;
        case 11:
            edit = [[PoCoEditDensityDrawLine11 alloc] init:bmp
                                                   colMode:cmode
                                                   palette:plt
                                                   pattern:pat
                                                    buffer:buf];
            break;
        case 12:
            edit = [[PoCoEditDensityDrawLine12 alloc] init:bmp
                                                   colMode:cmode
                                                   palette:plt
                                                   pattern:pat
                                                    buffer:buf];
            break;
        case 13:
            edit = [[PoCoEditDensityDrawLine13 alloc] init:bmp
                                                   colMode:cmode
                                                   palette:plt
                                                   pattern:pat
                                                    buffer:buf];
            break;
        case 14:
            edit = [[PoCoEditDensityDrawLine14 alloc] init:bmp
                                                   colMode:cmode
                                                   palette:plt
                                                   pattern:pat
                                                    buffer:buf];
            break;
        case 15:
            edit = [[PoCoEditDensityDrawLine15 alloc] init:bmp
                                                   colMode:cmode
                                                   palette:plt
                                                   pattern:pat
                                                    buffer:buf];
            break;
        case 16:
            edit = [[PoCoEditDensityDrawLine16 alloc] init:bmp
                                                   colMode:cmode
                                                   palette:plt
                                                   pattern:pat
                                                    buffer:buf];
            break;
    }

    return edit;
}

@end
