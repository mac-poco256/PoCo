//
//	Pelistina on Cocoa - PoCo -
//	タイルパターン初期値
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#include  <Cocoa/Cocoa.h>

// 広域型宣言
typedef struct {                        // パターン定義
    unsigned char dat[(TILE_PATTERN_SIZE + (TILE_PATTERN_SIZE & 1)) * TILE_PATTERN_SIZE];
} PoCoTilePatternDefaultType;


// 広域変数宣言
extern PoCoTilePatternDefaultType PoCoTilePatternDefault[];
