//
//	Pelistina on Cocoa - PoCo -
//	パレット補助属性切り替え部
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoControllerPaletteAttributeSetter.h"

#import "PoCoPalette.h"
#import "PoCoControllerFactory.h"
#import "PoCoControllerPaletteElementSetter.h"
#import "PoCoColorBuffer.h"

// ============================================================================
@implementation PoCoControllerPaletteAttributeSetter

// ---------------------------------------------------------- instance - public
//
// initialize(単一色用)
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    buf  : 色保持情報
//    num  : 設定色番号
//    s    : 設定内容
//    m    : 上塗り禁止を対象にするか
//    d    : 吸い取り禁止を対象にするか
//    t    : 透過を対象にするか
//
//  Return
//    function      : 実体
//    startNum_     : 設定色番号始点(instance 変数)
//    endNum_       : 設定色番号終点(instance 変数)
//    setType_      : 単一色の場合の設定内容(instance 変数)
//    maskTable_    : 上塗り禁止の設定内容(instance 変数)
//    dropperTable_ : 吸い取り禁止の設定内容(instance 変数)
//    transTable_   : 透過の設定内容(instance 変数)
//    colorBuffer_  : 色保持情報(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
  withNum:(int)num
  setType:(BOOL)s
     mask:(BOOL)m
  dropper:(BOOL)d
    trans:(BOOL)t
{
//    DPRINT((@"[PoCoControllerPaletteAttributeSetter init]\n"));

    // super class を初期化
    self = [super initPict:pict
                 withInfo:info
                 withUndo:undo];

    // 自身を初期化
    if (self != nil) {
        self->startNum_ = num;
        self->endNum_ = -1;
        self->setType_ = s;
        self->maskTable_ = (const BOOL *)((m) ? self : NULL);
        self->dropperTable_ = (const BOOL *)((d) ? self : NULL);
        self->transTable_ = (const BOOL *)((t) ? self : NULL);
        self->colorBuffer_ = buf;
        [self->colorBuffer_ retain];
    }

    return self;
}


//
// initialize(一括用)
//
//  Call
//    pict : 編集対象画像
//    info : 編集情報
//    undo : 取り消し情報
//    buf  : 色保持情報
//    s    : 設定色番号始点
//    e    : 設定色番号終点
//    m    : 上塗り禁止の設定内容
//    d    : 吸い取り禁止の設定内容
//    t    : 透過の設定内容
//
//  Return
//    function      : 実体
//    startNum_     : 設定色番号始点(instance 変数)
//    endNum_       : 設定色番号終点(instance 変数)
//    setType_      : 単一色の場合の設定内容(instance 変数)
//    maskTable_    : 上塗り禁止の設定内容(instance 変数)
//    dropperTable_ : 吸い取り禁止の設定内容(instance 変数)
//    transTable_   : 透過の設定内容(instance 変数)
//    colorBuffer_  : 色保持情報(instance 変数)
//
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   buffer:(PoCoColorBuffer *)buf
withStart:(int)s
  withEnd:(int)e
     mask:(const BOOL *)m
  dropper:(const BOOL *)d
    trans:(const BOOL *)t
{
//    DPRINT((@"[PoCoControllerPaletteAttributeSetter init]\n"));

    // super class を初期化
    self = [super initPict:pict
                 withInfo:info
                 withUndo:undo];

    // 自身を初期化
    if (self != nil) {
        self->startNum_ = s;
        self->endNum_ = e;
        self->maskTable_ = m;
        self->dropperTable_ = d;
        self->transTable_ = t;
        self->colorBuffer_ = buf;
        [self->colorBuffer_ retain];
    }

    return self;
}


//
// deallocate
//
//  Call
//    None
//
//  Return
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoControllerPaletteAttributeSetter dealloc]\n"));

    // 資源を解放
    [self->colorBuffer_ release];
    self->colorBuffer_ = nil;

    // super class を解放
    [super dealloc];

    return;
}


//
// 編集実行
//
//  Call
//    undoManager_  : 取り消し情報(基底 instance 変数)
//    factory_      : 編集部の生成部(基底 instance 変数)
//    picture_      : 編集対象画像(基底 instance 変数)
//    startNum_     : 設定色番号始点(instance 変数)
//    endNum_       : 設定色番号終点(instance 変数)
//    setType_      : 単一色の場合の設定内容(instance 変数)
//    maskTable_    : 上塗り禁止の設定内容(instance 変数)
//    dropperTable_ : 吸い取り禁止の設定内容(instance 変数)
//    transTable_   : 透過の設定内容(instance 変数)
//
//  Return
//    function     : 編集正否
//    colorBuffer_ : 色保持情報(instance 変数)
//
-(BOOL)execute
{
    BOOL  result;
    int l;
    int note;
    PoCoColor *col;
    PoCoPalette *plt;

    result = NO;

    if (self->endNum_ < 0) {
        // 単一色
        col = [[self->picture_ palette] palette:self->startNum_];
        note = (self->startNum_ & 0x0000ffff);
        if ((self->maskTable_ != NULL) && ([col isMask] != self->setType_)) {
            [col setMask:self->setType_];
            result = YES;
            note |= 0x00010000;
        }
        if ((self->dropperTable_ != NULL) && ([col noDropper] != self->setType_)) {
            [col setDropper:self->setType_];
            result = YES;
            note |= 0x00020000;
        }
        if ((self->transTable_ != NULL) && ([col isTrans] != self->setType_)) {
            [col setTrans:self->setType_];
            result = YES;
            note |= 0x00040000;
        }

        // 取り消しの生成
        if (result) {
            [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
                createPaletteAttributeSetter:YES
                                         num:self->startNum_
                                     setType:((self->setType_) ? NO : YES)
                                        mask:(self->maskTable_ != nil)
                                     dropper:(self->dropperTable_ != nil)
                                       trans:(self->transTable_ != nil)];
        }
    } else {
        // 一括
        note = 0x0000ffff;
        plt = [[self->picture_ palette] copy];
        for (l = self->startNum_; l < self->endNum_; (l)++) {
            col = [[self->picture_ palette] palette:l];
            if ([col isMask] != self->maskTable_[l]) {
                [col setMask:self->maskTable_[l]];
                result = YES;
                note |= 0x00010000;
            }
            if ([col noDropper] != self->dropperTable_[l]) {
                [col setDropper:self->dropperTable_[l]];
                result = YES;
                note |= 0x00020000;
            }
            if ([col isTrans] != self->transTable_[l]) {
                [col setTrans:self->transTable_[l]];
                result = YES;
                note |= 0x00040000;
            }
        }
        if (result) {
            [[self->undoManager_ prepareWithInvocationTarget:self->factory_]
                createPaletteElementSetter:YES
                                   palette:plt];
        } else {
            [plt release];
        }
    }

    // 編集された
    if (result) {
        // 取り消し名称の設定
        [super setUndoName:[[NSBundle mainBundle]
                              localizedStringForKey:@"PaletteAttributeSet"
                                              value:@"set palette attribute"
                                              table:nil]];

        // パレットの属性更新を通知
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoChangePaletteAttr
                          object:[NSNumber numberWithInt:note]];

        // 色保持情報を初期化
        [self->colorBuffer_ reset:nil];
    }

    return result;
}

@end
