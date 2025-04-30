//
//	Pelistina on Cocoa - PoCo -
//	選択中レイヤー情報
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// ----------------------------------------------------------------------------
@interface PoCoSelLayer : NSObject
{
    int sel_;                           // 選択番号(編集対象)
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// 選択番号(直接の編集対象)
-(int)sel;
-(void)setSel:(int)s;

@end
