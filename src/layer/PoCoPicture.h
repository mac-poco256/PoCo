//
//	Pelistina on Cocoa - PoCo -
//	画像定義
//
//	Copyright (C) 2005-2018 KAENRYUU Koutoku.
//

#import <Foundation/Foundation.h>

// 参照 class
@class PoCoPalette;
@class PoCoLayerBase;
@class PoCoColorPattern;
@class PoCoBuffer;

// ----------------------------------------------------------------------------
@interface PoCoPicture : NSObject
{
    PoCoPalette *palette_;              // パレット
    NSMutableArray *layer_;             // レイヤー(0:最下層)
    PoCoColorPattern *colpat_[COLOR_PATTERN_NUM]; // カラーパターン
    PoCoBuffer *viewBuffer_;            // 表示用の作業バッファ

    wchar_t paletteTable_[COLOR_MAX];   // パレット値テーブル
    BOOL transTable_[COLOR_MAX];        // 透過指定テーブル(実際とは反転)
    wchar_t shadowPaletteTable_[COLOR_MAX]; // パレット値テーブル(shadow copy)
    BOOL shadowTransTable_[COLOR_MAX];  // 透過指定テーブル(shadow copy)

    int h_unit_;                        // 水平用紙解像度(表記は TAD 準拠)
    int v_unit_;                        // 垂直用紙解像度(表記は TAD 準拠)

    BOOL isUseBKGD_;                    // 背景色使用
    unsigned int bkgdColor_;            // 色要素(パレット番号)

    BOOL isUseICCP_;                    // YES : iCCP CHUNK    NO : other
    unsigned int gamma_;                // gAMA CHUNK
    unsigned int chromakey_[8];         // cHRM CHUNK
    unsigned int srgb_;                 // sRGB CHUNK
}

// ペーストボードから取り込み
+(BOOL)pastePBoardData:(NSData *)data
             withRange:(NSRange *)range
           resultLayer:(PoCoLayerBase **)lyr
         resultPalette:(PoCoPalette *)plt;

// initialize
-(id)init:(int)dpi;

// deallocate
-(void)dealloc;

// レイヤーの管理
-(PoCoErr)addLayer:(int)index           // 追加(画像)
             width:(int)w
            height:(int)h
             color:(unsigned char)c;
-(PoCoErr)addStringLayer:(int)index     // 追加(文字列)
             color:(unsigned char)c;
-(void)deleteLayer:(int)index;          // 削除
-(NSMutableArray *)layer;               // 参照(全取得)
-(id)layer:(int)index;                  // 参照(単一取得)
-(void)insertLayer:(int)index           // 挿入
             layer:(PoCoLayerBase *)lyr;
-(void)updateLayerPreview:(int)index;   // 見本更新

// 画像サイズの取得
-(NSRect)bitmapRect;
-(PoCoRect *)bitmapPoCoRect;

// 主ウィンドウの表示用画像の取得
-(NSBitmapImageRep *)getMainImage:(PoCoRect *)rect
                        withScale:(int)scale
                   withSupplement:(PoCoMainViewSupplement *)supplement;

// 特定点の色を取得
-(int)pointColor:(PoCoPoint *)p
         atIndex:(int)index;

// パレットの管理
-(PoCoPalette *)palette;                // 取得
-(void)didUpdatePalette;                // パレット更新通知
-(void)pushPaletteTable;                // 表示参照用テーブルを退避
-(void)popPaletteTable;                 // 表示参照用テーブルを進出

// カラーパターンの管理
-(PoCoColorPattern *)colpat:(int)index; // 取得
-(void)setColpat:(int)index             // 更新
         pattern:(PoCoColorPattern *)pat;

// 補助情報
-(int)h_unit;                           // pHYs 取得(水平解像度)
-(int)v_unit;                           // pHYs 取得(垂直解像度)
-(BOOL)bkgdColor:(unsigned int *)idx;   // bKGD CHUNK 取得
-(BOOL)isUseICCP;                       // iCCP 使用取得
-(unsigned int)gamma;                   // gAMA CHUNK 取得
-(const unsigned int *)chromakey;       // cHRM CHUNK 取得
-(unsigned int)srgb;                    // sRGB CHUNK 取得
-(void)setHUnit:(int)h                  // pHYs CHUNK 設定
      withVUnit:(int)v;
-(void)setBKGD:(BOOL)flg                // bKGD CHUNK 設定
     withIndex:(unsigned int)idx;
-(void)setUseICCP:(BOOL)flag;          // iCCP 使用設定
-(void)setGamma:(unsigned int)val;     // gAMA CHUNK 設定
-(void)setChromakey:(const unsigned int *)val;  // cHRM CHUNK 設定
-(void)setSrgb:(unsigned int)val;      // sRGB CHUNK 設定

// ファイル操作系
-(NSData *)createFileData:(BOOL)toAlpha;// 保存
-(BOOL)loadFileData:(NSData *)data      // 読み込み
          withRange:(NSRange *)range;

// ペーストボードへ貼り付け
-(NSData *)createPBoardData:(PoCoRect *)r
                    atIndex:(int)index
                    toAlpha:(BOOL)toAlpha;

@end
