//
//	Pelistina on Cocoa - PoCo -
//	debug 用宣言
//
//	Copyright (C) 2005-2015 KAENRYUU Koutoku.
//

#import <Cocoa/Cocoa.h>

#if DEBUG_MODE
#define DPRINT(arg)     (void)(NSLog(@"%s:%d ", __FILE__, __LINE__), NSLog arg)
#else   // DEBUG_MODE
#define DPRINT(arg)     (void)0           
#endif  // DEBUG_MODE

#define TIME_START    {NSDate *__t_date = [NSDate date];
#define TIME_END(arg) NSLog(@"%@: %f[ms]", arg, ([[NSDate date] timeIntervalSinceDate:__t_date] * 1000.0));}
