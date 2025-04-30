//
//	Pelistina on Cocoa - PoCo -
//	エラーコード定義
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

// 共通マクロ
#define SYS_ERR(i)  (-(i))
#define DAT_ERR(i)  (-10000 + (-(i)))
#define HMI_ERR(i)  (-20000 + (-(i)))


// 共通型宣言
typedef int PoCoErr;                    // ERR 型このこと
                                        // == 0 : no err
                                        // <  0 : error code
typedef int PoCoWErr;                   // WERR 型のこと
                                        // >= 0 : no err/return value
                                        // <  0 : error code


// ----------------------------------------------------------------------------
enum PoCoErrorCode {
    // -1 から -9999 は基底に近い部分での障害
    ER_NOMEM = SYS_ERR(1),              // memory allocation error.
    ER_ZLIB = SYS_ERR(2),               // zlib error

    // -10000 から -19999 は data 管理上の障害
    ER_ADDLAYER = DAT_ERR(0),           // レイヤー追加失敗
    ER_LAYERINDEX = DAT_ERR(1),         // 不正レイヤー参照番号

    // -20000 から -29999 は hmi 上の障害(基本的に復旧可能なはず)

    // 異常なし
    ER_OK = 0
};
