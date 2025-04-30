//
//	Pelistina on Cocoa - PoCo -
//	カラーパターン登録
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerColorPatternSetter : PoCoControllerBase
{
    int num_;                           // 対象カラーパターン番号
    PoCoColorPattern *pattern_;         // パターン
}

// initialize(指定イニシャライザ)
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
      num:(int)n
  pattern:(PoCoColorPattern *)pat;

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
      num:(int)n
    layer:(int)idx
     rect:(PoCoRect *)r;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

// 取り消しの生成
-(void)createUndo:(PoCoColorPattern *)pat;

@end
