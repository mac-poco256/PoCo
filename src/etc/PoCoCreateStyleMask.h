//
//	Pelistina on Cocoa - PoCo -
//	形状マスク生成
//
//	Copyright (C) 2005-2017 KAENRYUU Koutoku.
//

#import <Foundation/Foundation.h>

// 参照 class
@class PoCoBitmap;

// ----------------------------------------------------------------------------
@interface PoCoCreateStyleMask : NSObject
{
    PoCoBitmap *styleMask_;             // 形状マスク
}

// initialize
-(id)init;

// deallocate
-(void)dealloc;

// 取得
-(PoCoBitmap *)mask;

// 生成
-(BOOL)box:(PoCoPoint *)startPos
       end:(PoCoPoint *)endPos
orientation:(PoCoPoint *)ort
isDiagonal:(BOOL)diagonal;
-(BOOL)ellipse:(PoCoPoint *)startPos
           end:(PoCoPoint *)endPos
   orientation:(PoCoPoint *)ort;
-(BOOL)parallelogram:(PoCoPoint *)firstPos
              second:(PoCoPoint *)secondPos
               third:(PoCoPoint *)thirdPos
              fourth:(PoCoPoint *)fourthPos;
-(BOOL)polygon:(NSMutableArray *)points;
-(BOOL)paint:(PoCoPoint *)p
 imageBitmap:(PoCoBitmap *)imageBitmap
   imageRect:(PoCoRect *)imageRect
    isBorder:(BOOL)border
  colorRange:(int)range
  resultRect:(PoCoRect *)resultRect;
-(BOOL)paintJoin:(PoCoPoint *)p
     imageBitmap:(PoCoBitmap *)imageBitmap
       imageRect:(PoCoRect *)imageRect
     styleBitmap:(PoCoBitmap *)styleBitmap
       styleRect:(PoCoRect *)styleRect
        isBorder:(BOOL)border
      colorRange:(int)range
      resultRect:(PoCoRect *)resultRect;
-(BOOL)paintSeparate:(PoCoPoint *)p
         imageBitmap:(PoCoBitmap *)imageBitmap
           imageRect:(PoCoRect *)imageRect
         styleBitmap:(PoCoBitmap *)styleBitmap
           styleRect:(PoCoRect *)styleRect
            isBorder:(BOOL)border
          colorRange:(int)range
          resultRect:(PoCoRect *)resultRect;

@end
