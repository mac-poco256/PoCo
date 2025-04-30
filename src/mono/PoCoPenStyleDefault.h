//
//	Pelistina on Cocoa - PoCo -
//	ペン先初期値
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#include  <Cocoa/Cocoa.h>

// 広域型宣言
typedef struct {                        // パターン定義
    unsigned char dat[(PEN_STYLE_SIZE + (PEN_STYLE_SIZE & 1)) * PEN_STYLE_SIZE];
} PoCoPenStyleDefaultType;


// 広域変数宣言
extern PoCoPenStyleDefaultType PoCoPenStyleDefault[];
