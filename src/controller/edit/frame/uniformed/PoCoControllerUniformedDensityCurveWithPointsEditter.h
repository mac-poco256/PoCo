//
//	Pelistina on Cocoa - PoCo -
//	直線群(曲線) - 均一濃度
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import "PoCoControllerFrameEditterBase.h"

// ----------------------------------------------------------------------------
@interface PoCoControllerUniformedDensityCurveWithPointsEditter : PoCoControllerCurveWithPointsEditterBase
{
}

// initialize
-(id)init:(PoCoPicture *)pict
     info:(PoCoEditInfo *)info
     undo:(NSUndoManager *)undo
   eraser:(PoCoColorPattern *)eraser
   buffer:(PoCoColorBuffer *)buf
   points:(NSMutableArray *)points
     type:(PoCoCurveWithPointsType)type
     freq:(unsigned int)freq
    index:(int)idx;

// deallocate
-(void)dealloc;

// 編集実行
-(BOOL)execute;

@end
