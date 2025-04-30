//
//	Pelistina on Cocoa - PoCo -
//	自動グラデーション色サイズ対群管理
//
//	Copyright (C) 2005-2016 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// ----------------------------------------------------------------------------
@interface PoCoAutoGradationSizePairOperate : NSObject
{
    NSMutableArray *pair_;
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// property(get)
-(NSArray *)sizeDetail;

// property(set)
-(void)setSizeDetail:(NSDictionary *)pair;

// delegate methods
-(BOOL)tableView:(NSTableView *)table
shouldEditTableColumn:(NSTableColumn *)column
                  row:(NSInteger)row;

// data source methods
-(int)numberOfRowsInTableView:(NSTableView *)table;
-(id)tableView:(NSTableView *)table
objectValueForTableColumn:(NSTableColumn *)column
                      row:(int)row;
-(void)tableView:(NSTableView *)table
  setObjectValue:(id)object
  forTableColumn:(NSTableColumn *)column
             row:(int)row;

@end
