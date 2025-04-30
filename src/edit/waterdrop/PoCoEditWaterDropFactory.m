//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - ぼかし - 生成部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditWaterDropFactory.h"

#import "PoCoLayer.h"
#import "PoCoPalette.h"
#import "PoCoColorBuffer.h"

#import "PoCoEditWaterDropDrawLine01.h"
#import "PoCoEditWaterDropDrawLine02.h"
#import "PoCoEditWaterDropDrawLine03.h"
#import "PoCoEditWaterDropDrawLine04.h"
#import "PoCoEditWaterDropDrawLine05.h"
#import "PoCoEditWaterDropDrawLine06.h"
#import "PoCoEditWaterDropDrawLine07.h"
#import "PoCoEditWaterDropDrawLine08.h"
#import "PoCoEditWaterDropDrawLine09.h"
#import "PoCoEditWaterDropDrawLine10.h"
#import "PoCoEditWaterDropDrawLine11.h"
#import "PoCoEditWaterDropDrawLine12.h"
#import "PoCoEditWaterDropDrawLine13.h"
#import "PoCoEditWaterDropDrawLine14.h"
#import "PoCoEditWaterDropDrawLine15.h"
#import "PoCoEditWaterDropDrawLine16.h"

// ============================================================================
@implementation PoCoEditWaterDropDrawLineFactory

// ------------------------------------------------------------- class - public
//
// 生成
//
//  Call
//    bmp   : 描画対象 bitmap
//    cmode : 色演算モード
//    plt   : 使用パレット
//    buf   : 色保持情報
//    size  : ペン先サイズ(dot 単位)
//
//  Return
//    function : 実体
//
+(id)create:(PoCoBitmap *)bmp
    colMode:(PoCoColorMode)cmode
    palette:(PoCoPalette *)plt
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
            edit = [[PoCoEditWaterDropDrawLine01 alloc] init:bmp
                                                     colMode:cmode
                                                     palette:plt
                                                      buffer:buf];
            break;
        case 2:
            edit = [[PoCoEditWaterDropDrawLine02 alloc] init:bmp
                                                     colMode:cmode
                                                     palette:plt
                                                      buffer:buf];
            break;
        case 3:
            edit = [[PoCoEditWaterDropDrawLine03 alloc] init:bmp
                                                     colMode:cmode
                                                     palette:plt
                                                      buffer:buf];
            break;
        case 4:
            edit = [[PoCoEditWaterDropDrawLine04 alloc] init:bmp
                                                     colMode:cmode
                                                     palette:plt
                                                      buffer:buf];
            break;
        case 5:
            edit = [[PoCoEditWaterDropDrawLine05 alloc] init:bmp
                                                     colMode:cmode
                                                     palette:plt
                                                      buffer:buf];
            break;
        case 6:
            edit = [[PoCoEditWaterDropDrawLine06 alloc] init:bmp
                                                     colMode:cmode
                                                     palette:plt
                                                      buffer:buf];
            break;
        case 7:
            edit = [[PoCoEditWaterDropDrawLine07 alloc] init:bmp
                                                     colMode:cmode
                                                     palette:plt
                                                      buffer:buf];
            break;
        case 8:
            edit = [[PoCoEditWaterDropDrawLine08 alloc] init:bmp
                                                     colMode:cmode
                                                     palette:plt
                                                      buffer:buf];
            break;
        case 9:
            edit = [[PoCoEditWaterDropDrawLine09 alloc] init:bmp
                                                     colMode:cmode
                                                     palette:plt
                                                      buffer:buf];
            break;
        case 10:
            edit = [[PoCoEditWaterDropDrawLine10 alloc] init:bmp
                                                     colMode:cmode
                                                     palette:plt
                                                      buffer:buf];
            break;
        case 11:
            edit = [[PoCoEditWaterDropDrawLine11 alloc] init:bmp
                                                     colMode:cmode
                                                     palette:plt
                                                      buffer:buf];
            break;
        case 12:
            edit = [[PoCoEditWaterDropDrawLine12 alloc] init:bmp
                                                     colMode:cmode
                                                     palette:plt
                                                      buffer:buf];
            break;
        case 13:
            edit = [[PoCoEditWaterDropDrawLine13 alloc] init:bmp
                                                     colMode:cmode
                                                     palette:plt
                                                      buffer:buf];
            break;
        case 14:
            edit = [[PoCoEditWaterDropDrawLine14 alloc] init:bmp
                                                     colMode:cmode
                                                     palette:plt
                                                      buffer:buf];
            break;
        case 15:
            edit = [[PoCoEditWaterDropDrawLine15 alloc] init:bmp
                                                     colMode:cmode
                                                     palette:plt
                                                      buffer:buf];
            break;
        case 16:
            edit = [[PoCoEditWaterDropDrawLine16 alloc] init:bmp
                                                     colMode:cmode
                                                     palette:plt
                                                      buffer:buf];
            break;
    }

    return edit;
}

@end
