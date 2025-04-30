//
//	Pelistina on Cocoa - PoCo -
//	編集部生成部
//
//	Copyright (C) 2005-2019 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 参照 class の宣言
@class PoCoBitmap;
@class PoCoLayerBase;
@class PoCoPalette;
@class PoCoColorPattern;
@class PoCoCalcRotation;

// ----------------------------------------------------------------------------
@interface PoCoControllerFactory : NSObject
{
}

// initialze
-(id)init;

// deallocate
-(void)dealloc;

// レイヤー構造更新無編集通知
-(id)createLayerNoEditter:(BOOL)exec
                     name:(NSString *)name
                   update:(BOOL)update;

// パレット更新無編集通知
-(id)createPaletteNoEditter:(BOOL)exec
                       name:(NSString *)name
                      index:(int)index;

// 画像サイズ変更無編集通知
-(id)createResizeNoEditter:(BOOL)exec
                      name:(NSString *)name;

// 切り抜き無編集通知
-(id)createClipNoEditter:(BOOL)exec
                    name:(NSString *)name;

// パレット加算
-(id)createPaletteIncrementer:(BOOL)exec
                          num:(int)n
                          red:(BOOL)r
                        green:(BOOL)g
                         blue:(BOOL)b
                         step:(unsigned int)step;

// パレット減算
-(id)createPaletteDecrementer:(BOOL)exec
                          num:(int)n
                          red:(BOOL)r
                        green:(BOOL)g
                         blue:(BOOL)b
                         step:(unsigned int)step;

// パレット補助属性設定
-(id)createPaletteAttributeSetter:(BOOL)exec
                              num:(int)n
                          setType:(BOOL)s
                             mask:(BOOL)m
                          dropper:(BOOL)d
                            trans:(BOOL)t;
-(id)createPaletteAttributeSetter:(BOOL)exec
                            start:(int)s
                              end:(int)e
                             mask:(const BOOL *)m
                          dropper:(const BOOL *)d
                            trans:(const BOOL *)t;

// パレットグラデーション生成
-(id)createPaletteGradationMaker:(BOOL)exec
                           start:(int)s
                             end:(int)e;

// パレット要素設定
-(id)createPaletteElementSetter:(BOOL)exec
                        palette:(PoCoPalette *)palette;

// 単一パレット設定
-(id)createPaletteSingleSetter:(BOOL)exec
                           num:(int)num
                           red:(unsigned char)red
                         green:(unsigned char)green
                          blue:(unsigned char)blue
                        isMask:(BOOL)mask
                        noDrop:(BOOL)drop
                       isTrans:(BOOL)trans
                          name:(NSString *)name;

// パレット取り込み(ペーストボードから複写)
-(id)createPaletteImporter:(BOOL)exec
             targetPalette:(PoCoPalette *)target
                 withFlags:(const BOOL *)flags;

// パレット入れ替え(色交換)
-(id)createPictureColorExchanger:(BOOL)exec
                             src:(int)s
                             dst:(int)d;
-(id)createPictureColorExchangerPassive:(BOOL)exec
                                    src:(int)s
                                    dst:(int)d;

// パレット複写(色複写)
-(id)createPictureColorPaster:(BOOL)exec
                             src:(int)s
                             dst:(int)d;
-(id)createPictureColorPasterPassive:(BOOL)exec
                                    src:(int)s
                                    dst:(int)d;

// 画像レイヤー追加
-(id)createLayerBitmapAdder:(BOOL)exec
                      color:(unsigned char)c;

// 文字列レイヤー追加
-(id)createLayerStringAdder:(BOOL)exec
                      color:(unsigned char)c;

// レイヤー削除
-(id)createLayerDeleter:(BOOL)exec
                  index:(int)index;
-(id)createLayerDeleterPassive:(BOOL)exec
                         index:(int)index;

// レイヤー挿入
-(id)createLayerInserter:(BOOL)exec
                   layer:(PoCoLayerBase *)layer
                   index:(int)index;
-(id)createLayerInserterPassive:(BOOL)exec
                          layer:(PoCoLayerBase *)layer
                          index:(int)index;

// レイヤー移動
-(id)createLayerMover:(BOOL)exec
                  src:(int)src
               target:(int)dst
                 copy:(BOOL)copy;

// レイヤー表示設定
-(id)createLayerDisplaySetter:(BOOL)exec
                         disp:(BOOL)disp
                        index:(int)index;

// レイヤー描画抑止設定
-(id)createLayerLockSetter:(BOOL)exec
                      lock:(BOOL)lock
                     index:(int)index;

// レイヤー名称設定
-(id)createLayerNameSetter:(BOOL)exec
                      name:(NSString *)name
                     index:(int)index;

// レイヤー統合
-(id)createPictureLayerUnificater:(BOOL)exec;

// サイズ変更
-(id)createCanvasResizer:(BOOL)exec
                   isFit:(BOOL)fit
                   width:(int)width
                  height:(int)height;

// 切り抜き
-(id)createImageClipper:(BOOL)exec
                   rect:(PoCoRect *)rect;

// 画像置換
-(id)createPictureBitmapReplacer:(BOOL)exec
                           layer:(int)index
                            rect:(PoCoRect *)rect
                          bitmap:(PoCoBitmap *)bitmap
                            name:(NSString *)name;

// カラーパターン設定
-(id)createColorPatternSetter:(BOOL)exec
                          num:(int)num
                        layer:(int)index
                         rect:(PoCoRect *)rect;
-(id)createColorPatternSetter:(BOOL)exec
                          num:(int)num
                      pattern:(PoCoColorPattern *)pat;

// 自由曲線
-(id)createNormalFreeLineEditter:(BOOL)exec
                           layer:(int)index
                           start:(PoCoPoint *)start
                             end:(PoCoPoint *)end
                        undoName:(NSString *)name;
-(id)createUniformedDensityFreeLineEditter:(BOOL)exec
                                     layer:(int)index
                                     start:(PoCoPoint *)start
                                       end:(PoCoPoint *)end
                                  undoName:(NSString *)name;
-(id)createDensityFreeLineEditter:(BOOL)exec
                            layer:(int)index
                            start:(PoCoPoint *)start
                              end:(PoCoPoint *)end
                         undoName:(NSString *)name;
-(id)createAtomizerFreeLineEditter:(BOOL)exec
                             layer:(int)index
                             start:(PoCoPoint *)start
                               end:(PoCoPoint *)end
                          undoName:(NSString *)name;
-(id)createGradationFreeLineEditter:(BOOL)exec
                              layer:(int)index
                              start:(PoCoPoint *)start
                                end:(PoCoPoint *)end
                           undoName:(NSString *)name;
-(id)createRandomFreeLineEditter:(BOOL)exec
                           layer:(int)index
                           start:(PoCoPoint *)start
                             end:(PoCoPoint *)end
                        undoName:(NSString *)name;
-(id)createWaterDropFreeLineEditter:(BOOL)exec
                              layer:(int)index
                              start:(PoCoPoint *)start
                                end:(PoCoPoint *)end
                           undoName:(NSString *)name;

// 直線
-(id)createInvertLineEditter:(BOOL)exec
                       layer:(int)index
                       start:(PoCoPoint *)start
                         end:(PoCoPoint *)end;

// 直線群
-(id)createInvertPolylineEditter:(BOOL)exec
                           layer:(int)index
                            poly:(NSMutableArray *)points;
-(id)createInvertPolygonEditter:(BOOL)exec
                          layer:(int)index
                           poly:(NSMutableArray *)points;

// 直線群(曲線)
-(id)createInvertCurveWithPointsEditter:(BOOL)exec
                                  layer:(int)index
                                 points:(NSMutableArray *)points
                                   type:(PoCoCurveWithPointsType)type
                                   freq:(unsigned int)freq;
-(id)createNormalCurveWithPointsEditter:(BOOL)exec
                                  layer:(int)index
                                 points:(NSMutableArray *)points
                                   type:(PoCoCurveWithPointsType)type
                                   freq:(unsigned int)freq;
-(id)createUniformedDensityCurveWithPointsEditter:(BOOL)exec
                                            layer:(int)index
                                           points:(NSMutableArray *)points
                                             type:(PoCoCurveWithPointsType)type
                                             freq:(unsigned int)freq;
-(id)createDensityCurveWithPointsEditter:(BOOL)exec
                                   layer:(int)index
                                  points:(NSMutableArray *)points
                                    type:(PoCoCurveWithPointsType)type
                                    freq:(unsigned int)freq;
-(id)createAtomizerCurveWithPointsEditter:(BOOL)exec
                                    layer:(int)index
                                   points:(NSMutableArray *)points
                                     type:(PoCoCurveWithPointsType)type
                                     freq:(unsigned int)freq;
-(id)createGradationCurveWithPointsEditter:(BOOL)exec
                                     layer:(int)index
                                    points:(NSMutableArray *)points
                                      type:(PoCoCurveWithPointsType)type
                                      freq:(unsigned int)freq;
-(id)createRandomCurveWithPointsEditter:(BOOL)exec
                                  layer:(int)index
                                 points:(NSMutableArray *)points
                                   type:(PoCoCurveWithPointsType)type
                                   freq:(unsigned int)freq;
-(id)createWaterDropCurveWithPointsEditter:(BOOL)exec
                                     layer:(int)index
                                    points:(NSMutableArray *)points
                                      type:(PoCoCurveWithPointsType)type
                                      freq:(unsigned int)freq;

// 矩形枠
-(id)createInvertBoxEditter:(BOOL)exec
                      layer:(int)index
                      start:(PoCoPoint *)start
                        end:(PoCoPoint *)end
                orientation:(PoCoPoint *)ort;
-(id)createNormalBoxEditter:(BOOL)exec
                      layer:(int)index
                      start:(PoCoPoint *)start
                        end:(PoCoPoint *)end
                orientation:(PoCoPoint *)ort;
-(id)createUniformedDensityBoxEditter:(BOOL)exec
                                layer:(int)index
                                start:(PoCoPoint *)start
                                  end:(PoCoPoint *)end
                          orientation:(PoCoPoint *)ort;
-(id)createDensityBoxEditter:(BOOL)exec
                       layer:(int)index
                       start:(PoCoPoint *)start
                         end:(PoCoPoint *)end
                 orientation:(PoCoPoint *)ort;
-(id)createAtomizerBoxEditter:(BOOL)exec
                        layer:(int)index
                        start:(PoCoPoint *)start
                          end:(PoCoPoint *)end
                  orientation:(PoCoPoint *)ort;
-(id)createGradationBoxEditter:(BOOL)exec
                         layer:(int)index
                         start:(PoCoPoint *)start
                           end:(PoCoPoint *)end
                   orientation:(PoCoPoint *)ort;
-(id)createRandomBoxEditter:(BOOL)exec
                      layer:(int)index
                      start:(PoCoPoint *)start
                        end:(PoCoPoint *)end
                orientation:(PoCoPoint *)ort;
-(id)createWaterDropBoxEditter:(BOOL)exec
                         layer:(int)index
                         start:(PoCoPoint *)start
                           end:(PoCoPoint *)end
                   orientation:(PoCoPoint *)ort;

// 円/楕円
-(id)createInvertEllipseEditter:(BOOL)exec
                          layer:(int)index
                          start:(PoCoPoint *)start
                            end:(PoCoPoint *)end
                    orientation:(PoCoPoint *)ort;
-(id)createNormalEllipseEditter:(BOOL)exec
                          layer:(int)index
                          start:(PoCoPoint *)start
                            end:(PoCoPoint *)end
                    orientation:(PoCoPoint *)ort;
-(id)createUniformedDensityEllipseEditter:(BOOL)exec
                                    layer:(int)index
                                    start:(PoCoPoint *)start
                                      end:(PoCoPoint *)end
                              orientation:(PoCoPoint *)ort;
-(id)createDensityEllipseEditter:(BOOL)exec
                           layer:(int)index
                           start:(PoCoPoint *)start
                             end:(PoCoPoint *)end
                     orientation:(PoCoPoint *)ort;
-(id)createAtomizerEllipseEditter:(BOOL)exec
                            layer:(int)index
                            start:(PoCoPoint *)start
                              end:(PoCoPoint *)end
                      orientation:(PoCoPoint *)ort;
-(id)createGradationEllipseEditter:(BOOL)exec
                             layer:(int)index
                             start:(PoCoPoint *)start
                               end:(PoCoPoint *)end
                       orientation:(PoCoPoint *)ort;
-(id)createRandomEllipseEditter:(BOOL)exec
                          layer:(int)index
                          start:(PoCoPoint *)start
                            end:(PoCoPoint *)end
                    orientation:(PoCoPoint *)ort;
-(id)createWaterDropEllipseEditter:(BOOL)exec
                             layer:(int)index
                             start:(PoCoPoint *)start
                               end:(PoCoPoint *)end
                       orientation:(PoCoPoint *)ort;

// 平行四辺形
-(id)createInvertParallelogramEditter:(BOOL)exec
                                layer:(int)index
                                first:(PoCoPoint *)first
                               second:(PoCoPoint *)second
                                third:(PoCoPoint *)third;
-(id)createNormalParallelogramEditter:(BOOL)exec
                                layer:(int)index
                                first:(PoCoPoint *)first
                               second:(PoCoPoint *)second
                                third:(PoCoPoint *)third;
-(id)createUniformedDensityParallelogramEditter:(BOOL)exec
                                          layer:(int)index
                                          first:(PoCoPoint *)first
                                         second:(PoCoPoint *)second
                                          third:(PoCoPoint *)third;
-(id)createDensityParallelogramEditter:(BOOL)exec
                                 layer:(int)index
                                 first:(PoCoPoint *)first
                                second:(PoCoPoint *)second
                                 third:(PoCoPoint *)third;
-(id)createAtomizerParallelogramEditter:(BOOL)exec
                                  layer:(int)index
                                  first:(PoCoPoint *)first
                                 second:(PoCoPoint *)second
                                  third:(PoCoPoint *)third;
-(id)createGradationParallelogramEditter:(BOOL)exec
                                   layer:(int)index
                                   first:(PoCoPoint *)first
                                  second:(PoCoPoint *)second
                                   third:(PoCoPoint *)third;
-(id)createRandomParallelogramEditter:(BOOL)exec
                                layer:(int)index
                                first:(PoCoPoint *)first
                               second:(PoCoPoint *)second
                                third:(PoCoPoint *)third;
-(id)createWaterDropParallelogramEditter:(BOOL)exec
                                   layer:(int)index
                                   first:(PoCoPoint *)first
                                  second:(PoCoPoint *)second
                                   third:(PoCoPoint *)third;

// 塗りつぶし矩形枠
-(id)createNormalBoxFillEditter:(BOOL)exec
                          layer:(int)index
                          start:(PoCoPoint *)start
                            end:(PoCoPoint *)end
                    orientation:(PoCoPoint *)ort;
-(id)createUniformedDensityBoxFillEditter:(BOOL)exec
                                    layer:(int)index
                                    start:(PoCoPoint *)start
                                      end:(PoCoPoint *)end
                              orientation:(PoCoPoint *)ort;
-(id)createDensityBoxFillEditter:(BOOL)exec
                           layer:(int)index
                           start:(PoCoPoint *)start
                             end:(PoCoPoint *)end
                     orientation:(PoCoPoint *)ort;
-(id)createAtomizerBoxFillEditter:(BOOL)exec
                            layer:(int)index
                            start:(PoCoPoint *)start
                              end:(PoCoPoint *)end
                      orientation:(PoCoPoint *)ort;
-(id)createGradationBoxFillEditter:(BOOL)exec
                             layer:(int)index
                             start:(PoCoPoint *)start
                               end:(PoCoPoint *)end
                       orientation:(PoCoPoint *)ort;
-(id)createRandomBoxFillEditter:(BOOL)exec
                          layer:(int)index
                          start:(PoCoPoint *)start
                            end:(PoCoPoint *)end
                    orientation:(PoCoPoint *)ort;
-(id)createWaterDropBoxFillEditter:(BOOL)exec
                             layer:(int)index
                             start:(PoCoPoint *)start
                               end:(PoCoPoint *)end
                       orientation:(PoCoPoint *)ort;

// 塗りつぶし円/楕円
-(id)createNormalEllipseFillEditter:(BOOL)exec
                              layer:(int)index
                              start:(PoCoPoint *)start
                                end:(PoCoPoint *)end
                        orientation:(PoCoPoint *)ort;
-(id)createUniformedDensityEllipseFillEditter:(BOOL)exec
                                        layer:(int)index
                                        start:(PoCoPoint *)start
                                          end:(PoCoPoint *)end
                                  orientation:(PoCoPoint *)ort;
-(id)createDensityEllipseFillEditter:(BOOL)exec
                               layer:(int)index
                               start:(PoCoPoint *)start
                                 end:(PoCoPoint *)end
                         orientation:(PoCoPoint *)ort;
-(id)createAtomizerEllipseFillEditter:(BOOL)exec
                                layer:(int)index
                                start:(PoCoPoint *)start
                                  end:(PoCoPoint *)end
                          orientation:(PoCoPoint *)ort;
-(id)createGradationEllipseFillEditter:(BOOL)exec
                                 layer:(int)index
                                 start:(PoCoPoint *)start
                                   end:(PoCoPoint *)end
                           orientation:(PoCoPoint *)ort;
-(id)createRandomEllipseFillEditter:(BOOL)exec
                              layer:(int)index
                              start:(PoCoPoint *)start
                                end:(PoCoPoint *)end
                        orientation:(PoCoPoint *)ort;
-(id)createWaterDropEllipseFillEditter:(BOOL)exec
                                 layer:(int)index
                                 start:(PoCoPoint *)start
                                   end:(PoCoPoint *)end
                           orientation:(PoCoPoint *)ort;

// 塗りつぶし平行四辺形
-(id)createNormalParallelogramFillEditter:(BOOL)exec
                                    layer:(int)index
                                    first:(PoCoPoint *)first
                                   second:(PoCoPoint *)second
                                    third:(PoCoPoint *)third;
-(id)createUniformedDensityParallelogramFillEditter:(BOOL)exec
                                              layer:(int)index
                                              first:(PoCoPoint *)first
                                             second:(PoCoPoint *)second
                                              third:(PoCoPoint *)third;
-(id)createDensityParallelogramFillEditter:(BOOL)exec
                                     layer:(int)index
                                     first:(PoCoPoint *)first
                                    second:(PoCoPoint *)second
                                     third:(PoCoPoint *)third;
-(id)createAtomizerParallelogramFillEditter:(BOOL)exec
                                      layer:(int)index
                                      first:(PoCoPoint *)first
                                     second:(PoCoPoint *)second
                                      third:(PoCoPoint *)third;
-(id)createGradationParallelogramFillEditter:(BOOL)exec
                                       layer:(int)index
                                       first:(PoCoPoint *)first
                                      second:(PoCoPoint *)second
                                       third:(PoCoPoint *)third;
-(id)createRandomParallelogramFillEditter:(BOOL)exec
                                    layer:(int)index
                                    first:(PoCoPoint *)first
                                   second:(PoCoPoint *)second
                                    third:(PoCoPoint *)third;
-(id)createWaterDropParallelogramFillEditter:(BOOL)exec
                                       layer:(int)index
                                       first:(PoCoPoint *)first
                                      second:(PoCoPoint *)second
                                       third:(PoCoPoint *)third;

// 筆圧比例自由曲線
-(id)createNormalProportionalFreeLineEditter:(BOOL)exec
                                       layer:(int)index
                                       start:(PoCoPoint *)start
                                         end:(PoCoPoint *)end
                                    undoName:(NSString *)name;
-(id)createUniformedDensityProportionalFreeLineEditter:(BOOL)exec
                                                 layer:(int)index
                                                 start:(PoCoPoint *)start
                                                   end:(PoCoPoint *)end
                                              undoName:(NSString *)name;
-(id)createDensityProportionalFreeLineEditter:(BOOL)exec
                                        layer:(int)index
                                        start:(PoCoPoint *)start
                                          end:(PoCoPoint *)end
                                      undoName:(NSString *)name;
-(id)createAtomizerProportionalFreeLineEditter:(BOOL)exec
                                         layer:(int)index
                                         start:(PoCoPoint *)start
                                           end:(PoCoPoint *)end
                                      undoName:(NSString *)name;
-(id)createGradationProportionalFreeLineEditter:(BOOL)exec
                                          layer:(int)index
                                          start:(PoCoPoint *)start
                                            end:(PoCoPoint *)end
                                       undoName:(NSString *)name;
-(id)createRandomProportionalFreeLineEditter:(BOOL)exec
                                       layer:(int)index
                                       start:(PoCoPoint *)start
                                         end:(PoCoPoint *)end
                                    undoName:(NSString *)name;
-(id)createWaterDropProportionalFreeLineEditter:(BOOL)exec
                                          layer:(int)index
                                          start:(PoCoPoint *)start
                                            end:(PoCoPoint *)end
                                       undoName:(NSString *)name;

// 塗りつぶし
-(id)createInvertRegionFillEditter:(BOOL)exec
                             layer:(int)index
                              rect:(PoCoRect *)r
                              mask:(PoCoBitmap *)mask;
-(id)createInvertRegionBorderEditter:(BOOL)exec
                               layer:(int)index
                                rect:(PoCoRect *)r
                                mask:(PoCoBitmap *)mask;
-(id)createNormalPaintEditter:(BOOL)exec
                        layer:(int)index
                          pos:(PoCoPoint *)pos;

// 画像貼り付け
-(id)createNormalPasteImageEditter:(BOOL)exec
                             layer:(int)index
                              rect:(PoCoRect *)r
                            bitmap:(PoCoBitmap *)bmp
                            region:(PoCoBitmap *)mask
                          prevRect:(PoCoRect *)pr
                        prevBitmap:(PoCoBitmap *)pbmp
                           undoName:(NSString *)name;

@end
