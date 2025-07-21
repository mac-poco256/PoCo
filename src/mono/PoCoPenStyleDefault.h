//
// PoCoPenStyleDefault.h
// declare the default pen styles.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#include  <Cocoa/Cocoa.h>

// define global types.
typedef struct {                        // the defult pen style.
    unsigned char dat[(PEN_STYLE_SIZE + (PEN_STYLE_SIZE & 1)) * PEN_STYLE_SIZE];
} PoCoPenStyleDefaultType;


// declare global variable.
extern PoCoPenStyleDefaultType PoCoPenStyleDefault[];
