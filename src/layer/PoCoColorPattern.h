//
//	Pelistina on Cocoa - PoCo -
//	カラーパターン
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Foundation/Foundation.h>

// 参照 class の宣言
@class PoCoBitmap;
@class PoCoPalette;
@class PoCoPNGDecoder;

// ----------------------------------------------------------------------------
@interface PoCoColorPattern : NSObject
{
    PoCoBitmap *pattern_;               // パターン実体
}

// initialize
-(id)init;
-(id)initWidth:(int)w
    initHeight:(int)h
  defaultColor:(unsigned char)c;
-(id)initWithBitmap:(PoCoBitmap *)bitmap; // 指定イニシャライザ

// deallocate
-(void)dealloc;

// パターンの更新
-(void)setPattern:(PoCoBitmap *)pat;

// 見本の取得
-(NSImageRep *)preview:(PoCoRect *)r
               palette:(PoCoPalette *)palette;

// パターン画像の取得
-(PoCoBitmap *)pixelmap:(PoCoRect *)r;

// ファイル操作系
-(NSData *)createFileData;                  // 保存
-(BOOL)loadCPATChunk:(PoCoPNGDecoder *)png; // 読み込み

@end
