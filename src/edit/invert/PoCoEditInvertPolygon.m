//
//	Pelistina on Cocoa - PoCo -
//	編集系ライブラリ - 反転 - 閉じた直線群(塗りつぶし)
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import "PoCoEditInvertPolygon.h"
#import "PoCoEditInvertDrawLine.h"

// ============================================================================
@implementation PoCoEditInvertPolygon

// --------------------------------------------------------- instance - private
//
// 枠線部分の描画
//
//  Call
//    points_   : 支点群(instance 変数)
//    drawRect_ : 描画領域(instance 変数)
//
//  Return
//    None
//
-(void)drawFrame
{
    PoCoEditInvertDrawLine *frame;
    NSEnumerator *iter;
    PoCoPoint *s;
    PoCoPoint *p;

    frame = [[PoCoEditInvertDrawLine alloc] initWithBitmap:self->bitmap_
                                                isZeroOnly:YES];
    iter = [self->points_ objectEnumerator];
    s = [iter nextObject];
    for (p = s; p != nil; p = [iter nextObject]) {
        [frame addPoint:p];
    }
    [frame addPoint:s];
    [frame executeDraw];
    [frame release];

    return;
}


//
// 閉じた部分の描画
//
//  Call
//    points_   : 支点群(instance 変数)
//    drawRect_ : 描画領域(instance 変数)
//    zeroOnly_ : 0x00 のみを反転対象とする(基底 instance 変数)
//
//  Return
//    bitmap_ : 描画対象 bitmap(基底 instance 変数)
//
-(void)drawFill
{
    int i;
    int j;
    PoCoPoint *p1;
    PoCoPoint *p2;
    int y;
    int cnt;
    int *pt;
    int row;
    unsigned char *pixmap;
    unsigned char *dp;
    unsigned char *ep;

    // 交点の領域確保
    pt = (int *)(malloc([self->points_ count] * sizeof(int)));
    if (pt == NULL) {
        goto EXIT;
    }

    // 走査
    row = ([self->bitmap_ width] + ([self->bitmap_ width] & 0x01));
    pixmap = [self->bitmap_ pixelmap];
    for (y = 0; y < [self->drawRect_ height]; (y)++) {
        cnt = 0;

        // 垂直軸の交差を探す
        j = (int)([self->points_ count] - 1);
        for (i = 0; i < [self->points_ count]; (i)++) {
            p1 = [self->points_ objectAtIndex:i];
            p2 = [self->points_ objectAtIndex:j];
            if ((([p1 y] < y) && ([p2 y] >= y)) ||
                (([p2 y] < y) && ([p1 y] >= y))) {
                pt[cnt] = (int)(((float)([p1 x]) + (float)(y - [p1 y]) / (float)([p2 y] - [p1 y]) * (float)([p2 x] - [p1 x])) + 0.5);
                (cnt)++;
            }
            j = i;
        }

        // 水平軸でソート 
        i = 0;
        while (i < (cnt - 1)) {
            if (pt[i] > pt[i + 1]) {
                pt[i    ] ^= pt[i + 1];
                pt[i + 1] ^= pt[i    ];
                pt[i    ] ^= pt[i + 1];
                if (i != 0) {
                    (i)--;
                }
            } else {
               (i)++;
            }
        }

        // 塗り
        for (i = 0; i < cnt; i += 2) {
            if (pt[i] >= [self->drawRect_ width]) {
                break;
            } else if (pt[i + 1] > 0) {
                ep = (pixmap + MIN(pt[i + 1], [self->drawRect_ width]));
                for (dp = (pixmap + MAX(pt[i], 0)); dp < ep; (dp)++) {
                    if ((!(self->zeroOnly_)) || (*(dp) == 0x00)) {
                        *(dp) ^= 0xff;
                    }
                }
            }
        }

        // 次へ
        pixmap += row;
    }
    free(pt);

EXIT:
    return;
}


// ---------------------------------------------------------- instance - public
//
// initialize
//
//  Call
//    bmp : 描画対象 bitmap
//    pts : 支点群(instance 変数)
//    dr  : 描画領域(instance 変数)
//    z   : 0x00 のみを反転対象とする
//
//  Return
//    function  : 実体
//    points_   : 支点群(instance 変数)
//    drawRect_ : 描画領域(instance 変数)
//
-(id)initWithBitmap:(PoCoBitmap *)bmp
         withPoints:(NSArray *)pts
       withDrawRect:(PoCoRect *)dr
         isZeroOnly:(BOOL)z
{
//    DPRINT((@"[PoCoEditInvertPolygon initWithBitmap]\n"));

    // super class の初期化
    self = [super initWithBitmap:bmp
                      isZeroOnly:z];

    // 自身の初期化
    if (self != nil) {
        self->points_ = pts;
        self->drawRect_ = dr;
        [self->points_ retain];
        [self->drawRect_ retain];
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
//    points_   : 支点群(instance 変数)
//    drawRect_ : 描画領域(instance 変数)
//
-(void)dealloc
{
//    DPRINT((@"[PoCoEditInvertPolygon dealloc]\n"));

    // 資源の解放
    [self->points_ release];
    [self->drawRect_ release];
    self->points_ = nil;
    self->drawRect_ = nil;

    // super class の解放
    [super dealloc];

    return;
}


//
// 実行
//
//  Call
//    None
//
//  Return
//    None
//
-(void)executeDraw
{
    // 枠線部分の描画
    [self drawFrame];

    // 閉じた部分の描画
    [self drawFill];

#if 0
{
    int x;
    int y;
    unsigned char *p;

    printf("----------------\n");
    printf("width : %d, height: %d\n", [self->bitmap_ width], [self->bitmap_ height]);
    for (y = 0; y < [self->bitmap_ height]; (y)++) {
        p  = [self->bitmap_ pixelmap];
        p += (y * ([self->bitmap_ width] + ([self->bitmap_ width] & 0x01)));
        for (x = 0; x < [self->bitmap_ width]; (x)++) {
            printf("%c", ((*(p) != 0x00) ? '1' : '0'));
            (p)++;
        }
        printf("\n");
    }
}
#endif  // 0

    return;
}

@end
