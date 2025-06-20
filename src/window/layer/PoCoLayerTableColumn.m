//
// PoCoLayerTableColumn.h
// implementation of PoCoLayerTableColumnXXX class.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoLayerTableColumn.h"

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"

// ============================================================================
@implementation PoCoLayerTableColumnDisplay

// ----------------------------------------------------------------------------
// instance - public - declare width.

//
// width.
//
//  Call:
//    none.
//
//  Return:
//    function : value.
//
- (CGFloat)width
{
    return (CGFloat)(32);
}


//
// minumum width.
//
//  Call:
//    none.
//
//  Return:
//    function : value.
//
- (CGFloat)minWidth
{
    return [self width];
}


//
// maximum width.
//
//  Call:
//    none.
//
//  Return:
//    function : value.
//
- (CGFloat)maxWidth
{
    return [self width];
}

@end




// ============================================================================
@implementation PoCoLayerTableColumnDrawLock

// ----------------------------------------------------------------------------
// instance - public - declare width.

//
// width.
//
//  Call:
//    none.
//
//  Return:
//    function : value.
//
- (CGFloat)width
{
    return (CGFloat)(32);
}


//
// minumum width.
//
//  Call:
//    none.
//
//  Return:
//    function : value.
//
- (CGFloat)minWidth
{
    return [self width];
}


//
// maximum width.
//
//  Call:
//    none.
//
//  Return:
//    function : value.
//
- (CGFloat)maxWidth
{
    return [self width];
}

@end




// ============================================================================
@implementation PoCoLayerTableColumnPreview

// ----------------------------------------------------------------------------
// instance - public - declare width.

//
// width.
//
//  Call:
//    none.
//
//  Return:
//    function : value.
//
- (CGFloat)width
{
    CGFloat w;

    w = (CGFloat)([[(PoCoAppController *)([NSApp delegate]) editInfo] previewSize] + 2);
    if (w < (CGFloat)(66)) {
        w = (CGFloat)(66);
    }

    return w;
}


//
// minumum width.
//
//  Call:
//    none.
//
//  Return:
//    function : value.
//
- (CGFloat)minWidth
{
    return [self width];
}


//
// maximum width.
//
//  Call:
//    none.
//
//  Return:
//    function : value.
//
- (CGFloat)maxWidth
{
    return [self width];
}

@end




// ============================================================================
@implementation PoCoLayerTableColumnName

// ----------------------------------------------------------------------------
// instance - public - declare width.

//
// width.
//
//  Call:
//    none.
//
//  Return:
//    function : value.
//
- (CGFloat)width
{
    CGFloat w;

    w  = [[[self tableView] window] frame].size.width;
    w -= (CGFloat)(27);
    w -= [[[[self tableView] tableColumns] objectAtIndex:0] width];
    w -= [[[[self tableView] tableColumns] objectAtIndex:1] width];
#if 0   // because the type column is NOT visible, exclude from calculation.
    w -= [[[[self tableView] tableColumns] objectAtIndex:2] width];
#endif  // 0
    w -= [[[[self tableView] tableColumns] objectAtIndex:3] width];

    return w;
}


//
// minumum width.
//
//  Call:
//    none.
//
//  Return:
//    function : value.
//
- (CGFloat)minWidth
{
    return [self width];
}


//
// maximum width.
//
//  Call:
//    none.
//
//  Return:
//    function : value.
//
- (CGFloat)maxWidth
{
    return [self width];
}

@end
