//
// PoCoLayerTableColumn.h
// declare interface of each table column classes.
// these classes are to declare width of each table column.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// ----------------------------------------------------------------------------
@interface PoCoLayerTableColumnDisplay : NSTableColumn
{
}

// declare width.
- (CGFloat)width;
- (CGFloat)minWidth;
- (CGFloat)maxWidth;

@end


// ----------------------------------------------------------------------------
@interface PoCoLayerTableColumnDrawLock : NSTableColumn
{
}

// declare width.
- (CGFloat)width;
- (CGFloat)minWidth;
- (CGFloat)maxWidth;

@end


// ----------------------------------------------------------------------------
@interface PoCoLayerTableColumnPreview : NSTableColumn
{
}

// declare width.
- (CGFloat)width;
- (CGFloat)minWidth;
- (CGFloat)maxWidth;

@end


// ----------------------------------------------------------------------------
@interface PoCoLayerTableColumnName : NSTableColumn
{
}

// declare width.
- (CGFloat)width;
- (CGFloat)minWidth;
- (CGFloat)maxWidth;

@end
