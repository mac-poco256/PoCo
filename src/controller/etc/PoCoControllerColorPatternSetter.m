//
//	Pelistina on Cocoa - PoCo -
//	カラーパターン登録
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerColorPatternSetter.h"

#import "PoCoLayer.h"
#import "PoCoColorPattern.h"
#import "PoCoControllerFactory.h"

// ============================================================================
@implementation PoCoControllerColorPatternSetter

// ---------------------------------------------------------- instance - public
//
// initialize(指定イニシャライザ)
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    n    : 対象カラーパターン番号
//    pat  : パターン
//
//  Return
//    num_     : 対象カラーパターン番号(instance 変数)
//    pattern_ : パターン(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
      num:(int)n
  pattern:(PoCoColorPattern *)pat
{
    DPRINT((@"[PoCoControllerColorPatternSetter init]\n"));

    // super class を初期化
    self = [super initPict:pict withInfo:info withUndo:undo];

    // 自身を初期化
    if (self != nil) {
        self->num_ = n;
        self->pattern_ = pat;
        [self->pattern_ retain];
    }

    return self;
}

//
// initialize
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    n    : 対象カラーパターン番号
//    idx  : 取得レイヤー番号
//    r    : 取得矩形枠
//
//  Return
//    function : 実体
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
      num:(int)n
    layer:(int)idx
     rect:(PoCoRect *)r
{
    id obj;
    PoCoColorPattern *pat;
    PoCoBitmap *bmp;

    bmp = [[[pict layer:idx] bitmap] getBitmap:r];
    pat = [[PoCoColorPattern alloc] initWithBitmap:bmp];
    obj = [self init:pict
                 info:info
                 undo:undo
                  num:n
              pattern:pat];
    [pat release];
    [bmp release];

    return obj;
}


//
// deallocate
//
//  Call
//    None
//
//  Return
//    pattern_ : パターン(instance 変数)
//
-(void)dealloc
{
    DPRINT((@"[PoCoControllerColorPatternSetter dealloc]\n"));

    // 資源の解放
    [self->pattern_ release];
    self->pattern_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    picture_  : 編集対象画像(基底 instance 変数)
//    editInfo_ : 編集情報(基底 instance 変数)
//    num_      : 対象カラーパターン番号(instance 変数)
//    pattern_  : パターン(instance 変数)
//
//  Return
//    function : 編集正否
//
-(BOOL)execute
{
    BOOL result;
    PoCoColorPattern *undoPat;

    DPRINT((@"[PoCoControllerColorPatternSetter execute]\n"));

    result = NO;

    // 以前のパターン取得
    undoPat = [self->picture_ colpat:self->num_];
    if (undoPat != nil) {
        // 取り消しの生成
        if ([self->editInfo_ enableUndo]) {
            [self createUndo:undoPat];
        }

        // パターンを登録
        [self->picture_ setColpat:self->num_
                          pattern:self->pattern_];

        // パターン登録を通知
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoColorPatternSet
                          object:[NSNumber numberWithInt:self->num_]];

        // 正常終了
        result = YES;
    }

    return result;
}


//
// 取り消しの生成
//
//  Call
//    pat          : パターン
//    undoManager_ : 取り消し情報(基底 instance 変数)
//    factory_     : 編集部の生成部(基底 instance 変数)
//    num_         : 対象パターン番号(instance 変数)
//
//  Return
//    None
//
-(void)createUndo:(PoCoColorPattern *)pat
{
    [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
        createColorPatternSetter:YES
                             num:self->num_
                         pattern:pat];

    [super setUndoName:[[NSBundle mainBundle]
                           localizedStringForKey:@"ColorPatternSet"
                                           value:@"set color pattern"
                                           table:nil]];

    return;
}

@end
