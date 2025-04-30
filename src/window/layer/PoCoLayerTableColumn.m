//
//	Pelistina on Cocoa - PoCo -
//	レイヤー一覧テーブルカラム
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import "PoCoLayerTableColumn.h"

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"

// ============================================================================
@implementation PoCoLayerTableColumnDisplay

// ------------------------------------------------- instance - public - 大きさ
//
// 幅
//
//  Call
//    None
//
//  Return
//    function : 値
//
-(CGFloat)width
{
    return (CGFloat)(28);
}


//
// 最小幅
//
//  Call
//    None
//
//  Return
//    function : 値
//
-(CGFloat)minWidth
{
    return [self width];
}


//
// 最大幅
//
//  Call
//    None
//
//  Return
//    function : 値
//
-(CGFloat)maxWidth
{
    return [self width];
}

@end




// ============================================================================
@implementation PoCoLayerTableColumnDrawLock

// ------------------------------------------------- instance - public - 大きさ
//
// 幅
//
//  Call
//    None
//
//  Return
//    function : 値
//
-(CGFloat)width
{
    return (CGFloat)(28);
}


//
// 最小幅
//
//  Call
//    None
//
//  Return
//    function : 値
//
-(CGFloat)minWidth
{
    return [self width];
}


//
// 最大幅
//
//  Call
//    None
//
//  Return
//    function : 値
//
-(CGFloat)maxWidth
{
    return [self width];
}

@end




// ============================================================================
@implementation PoCoLayerTableColumnPreview

// ------------------------------------------------- instance - public - 大きさ
//
// 幅
//
//  Call
//    None
//
//  Return
//    function : 値
//
-(CGFloat)width
{
    CGFloat w;

    w = (CGFloat)([[(PoCoAppController *)([NSApp delegate]) editInfo] previewSize] + 2);
    if (w < (CGFloat)(62)) {
        w = (CGFloat)(62);
    }

    return w;
}


//
// 最小幅
//
//  Call
//    None
//
//  Return
//    function : 値
//
-(CGFloat)minWidth
{
    return [self width];
}


//
// 最大幅
//
//  Call
//    None
//
//  Return
//    function : 値
//
-(CGFloat)maxWidth
{
    return [self width];
}

@end




// ============================================================================
@implementation PoCoLayerTableColumnName

// ------------------------------------------------- instance - public - 大きさ
//
// 幅
//
//  Call
//    None
//
//  Return
//    function : 値
//
-(CGFloat)width
{
    CGFloat w;

    w  = [[[self tableView] window] frame].size.width;
    w -= (CGFloat)(27);
    w -= [[[[self tableView] tableColumns] objectAtIndex:0] width];
    w -= [[[[self tableView] tableColumns] objectAtIndex:1] width];
#if 0   // 種別は表示していないので
    w -= [[[[self tableView] tableColumns] objectAtIndex:2] width];
#endif  // 0
    w -= [[[[self tableView] tableColumns] objectAtIndex:3] width];

    return w;
}


//
// 最小幅
//
//  Call
//    None
//
//  Return
//    function : 値
//
-(CGFloat)minWidth
{
    return [self width];
}


//
// 最大幅
//
//  Call
//    None
//
//  Return
//    function : 値
//
-(CGFloat)maxWidth
{
    return [self width];
}

@end
