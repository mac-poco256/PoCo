//
//	Pelistina on Cocoa - PoCo -
//	main
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#import "PoCoUtil.h"

// ----------------------------------------------------------------------------
//
// main
//
//  Call
//    argc : 引数個数(api Variable)
//    argv : 引数(api Variable)
//
//  Return
//    function : application 実行 code
//
int main(int argc, char *argv[])
{
    // 乱数初期化
    [PoCoUtil startUp];

    // 実行
    return NSApplicationMain(argc, (const char **)(argv));
}
