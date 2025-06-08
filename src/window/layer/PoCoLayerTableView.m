//
// PoCoLayerTableView.m
// implementation of PoCoLayerTableView class.
//
// Copyright (C) 2005-2025 KAENRYUU Koutoku.
//

#import "PoCoLayerTableView.h"

#import <Carbon/Carbon.h>

#import "PoCoAppController.h"
#import "PoCoEditInfo.h"
#import "PoCoLayerOperate.h"

#import "PoCoMyDocument.h"
#import "PoCoView.h"

// ============================================================================
@implementation PoCoLayerTableView

// --------------------------------------------------------- instance - private
//
// 再描画の発行
//
//  Call
//    row : 対象行
//
//  Return
//    None
//
-(void)setRedraw:(int)row
{
    NSRect r;

    r = [self rectOfRow:MIN([self numberOfRows] - 1, row)];
    r.origin.y -= 2.0;
    r.size.height += 2.0;
    [self setNeedsDisplayInRect:r];

    return;
}


// ---------------------------------------------------------- instance - public
//
// awake from nib.
//
//  Call:
//    none.
//
//  Return:
//    none.
//
- (void)awakeFromNib
{
    // forwaed to super class.
    [super awakeFromNib];
    
    // override style.
    [self setStyle:NSTableViewStylePlain];
    
    return;
}


//
// 表示要求
//
//  Call
//    rect : 要求領域(api 変数)
//
//  Return
//    None
//
-(void)drawRect:(NSRect)rect
{
    NSRect r;
    PoCoLayerOperate *oprt = (PoCoLayerOperate *)([self delegate]);
    const int row = [oprt targetRowInTableView:self];

    // 通常の描画を実行
    [super drawRect:rect];

    // 移動時の表示
    if (row >= 0) {
        r = [self rectOfRow:MIN([self numberOfRows] - 1, row)];
        if (NSIntersectsRect(r, rect)) {
            [[NSColor blackColor] set];
            [NSBezierPath setDefaultLineWidth:(float)(2.0)];
            if (row >= [self numberOfRows]) {
                r.origin.y += r.size.height;
            }
            [NSBezierPath strokeLineFromPoint:r.origin
                                      toPoint:NSMakePoint(r.origin.x + r.size.width, r.origin.y)];
        }
    }

    return;
}


//
// 高さ
//
//  Call
//    None
//
//  Return
//    function : 高さ
//
-(CGFloat)rowHeight
{
    // 常にレイヤープレビューの大きさ + 2 とする
    return (CGFloat)([[(PoCoAppController *)([NSApp delegate]) editInfo] previewSize] + 2);
}


//
// メニューを更新
//
//  Call
//    menu : menu(api 変数)
//
//  Return
//    function : 可否
//
-(BOOL)validateMenuItem:(NSMenuItem *)menu
{
    BOOL result;

    if ([menu action] == @selector(selectAll:)) {
        result = ((PoCoView *)([(MyDocument *)([[NSDocumentController sharedDocumentController] currentDocument]) view]) != nil);
    } else {
        result = [super validateMenuItem:menu];
    }

    return result;
}


//   
// 全選択
//
//  Call
//    sender : メニュー項目へのインスタンス(api 変数)
//
//  Return
//    None
//
-(IBAction)selectAll:(id)sender
{
    [(PoCoView *)([(MyDocument *)([[NSDocumentController sharedDocumentController] currentDocument]) view]) selectAll:sender];

    return;
}


// ----------------------------------------- instance - public - イベント処理系
//
// ボタンダウン処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    isMoving_    : 移動操作中か(instance 変数)
//    isRightDown_ : 副ボタン押し下(instance 変数)
//    startRow_    : 移動開始行(instance 変数)
//
-(void)mouseDown:(NSEvent *)evt
{
    int row;
    int clm;
    NSPoint p;
    PoCoLayerOperate *oprt = (PoCoLayerOperate *)([self delegate]);

    p = [PoCoPoint corrNSPoint:[self convertPoint:[evt locationInWindow] fromView:nil]];
    clm = (int)([self columnAtPoint:p]);
    if ((clm < 2) || (clm == 4)) {
        self->isMoving_ = NO;
    } else {
        self->isMoving_ = YES;
    }
    self->isRightDown_ = NO;

    if (self->isMoving_) {
        row = (int)([self rowAtPoint:p]);
        if (row >= 0) {
            if ([[self delegate] tableView:self shouldSelectRow:row]) {
                [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row]
                  byExtendingSelection:NO];
            }
            self->startRow_ = row;
        }
        [oprt tableView:self setTargetRow:-1];
    } else {
        [super mouseDown:evt];
    }

    return;
}


//
// ドラッグ処理
//
//  Call
//    evt       : 発生イベント(api 変数)
//    isMoving_ : 移動操作中か(instance 変数)
//
//  Return
//    None
//
-(void)mouseDragged:(NSEvent *)evt
{
    int row;
    NSRect  r;
    NSPoint p;
    PoCoLayerOperate *oprt = (PoCoLayerOperate *)([self delegate]);
    const int old = [oprt targetRowInTableView:self];

    if (self->isMoving_) {
        [[self superview] autoscroll:evt];

        // 目標位置の算出
        p = [PoCoPoint corrNSPoint:[self convertPoint:[evt locationInWindow] fromView:nil]];
        if ([self mouse:p inRect:[self bounds]]) {
            row = (int)([self rowAtPoint:p]);
            if (row < 0) {
                row = (int)([self numberOfRows]);
            } else {
                r = [self rectOfRow:row];
                if (p.y > (r.origin.y + (r.size.height / 2))) {
                    row++;
                }
            }

            // 目標の表示要求を発行
            if (row != old) {
                [oprt tableView:self setTargetRow:row];
                [self setRedraw:old];
                [self setRedraw:row];
            }
        }
    } else {
        [super mouseDragged:evt];
    }

    return;
}


//
// ボタンリリース処理
//
//  Call
//    evt          : 発生イベント(api 変数)
//    isMoving_    : 移動操作中か(instance 変数)
//    startRow_    : 移動開始行(instance 変数)
//    isRightDown_ : 副ボタン押し下(instance 変数)
//
//  Return
//    isMoving_ : 移動操作中か(instance 変数)
//
-(void)mouseUp:(NSEvent *)evt
{
    PoCoLayerOperate *oprt = (PoCoLayerOperate *)([self delegate]);
    const int targetRow = [oprt targetRowInTableView:self];
    const BOOL isCopy = ((self->isRightDown_) ||
                         (([evt modifierFlags] & NSControlKeyMask) != 0));

    if (self->isMoving_) {
        [oprt tableView:self setTargetRow:-1];
        if (targetRow < 0) {
            [self setNeedsDisplay:YES];
        } else if ((isCopy) || (self->startRow_ != targetRow)) {
            [oprt tableView:self
                  moveToRow:targetRow
                     isCopy:isCopy];
        } else {
            [self setNeedsDisplay:YES];
        }
    } else {
        [super mouseUp:evt];
    }
    self->isMoving_ = NO;

    return;
}


//
// 副ボタンダウン処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    isRightDown_ : 副ボタン押し下(instance 変数)
//
-(void)rightMouseDown:(NSEvent *)evt
{
    self->isRightDown_ = YES;

    return;
}


//
// 副ボタンリリース処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    isRightDown_ : 副ボタン押し下(instance 変数)
//
-(void)rightMouseUp:(NSEvent *)evt
{
    self->isRightDown_ = NO;

    return;
}


//
// キーダウン処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    None
//
-(void)keyDown:(NSEvent *)evt
{
    // スペースキーイベント(keyDown)を通知
    if ([evt keyCode] == kVK_Space) {
        if (!([evt isARepeat])) {
            [[NSNotificationCenter defaultCenter]
                postNotificationName:PoCoSpaceKeyEvent
                              object:[NSNumber numberWithBool:YES]];
        }
    } else {
        // super class へ回送
        [super keyDown:evt];
    }

    return;
}


//
// キーリリース処理
//
//  Call
//    evt : 発生イベント(api 変数)
//
//  Return
//    None
//
-(void)keyUp:(NSEvent *)evt
{
    // スペースキーイベント(keyUp)を通知
    if ([evt keyCode] == kVK_Space) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PoCoSpaceKeyEvent
                          object:[NSNumber numberWithBool:NO]];
    } else {
        // super class へ回送
        [super keyUp:evt];
    }

    return;
}

@end
