//
// PoCoTilePatternDefault.h
// declare the default tile patterns.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#include  <Cocoa/Cocoa.h>

// define global types.
typedef struct {                        // the default tile pattern.
    unsigned char dat[(TILE_PATTERN_SIZE + (TILE_PATTERN_SIZE & 1)) * TILE_PATTERN_SIZE];
} PoCoTilePatternDefaultType;


// declare global variable.
extern PoCoTilePatternDefaultType PoCoTilePatternDefault[];
