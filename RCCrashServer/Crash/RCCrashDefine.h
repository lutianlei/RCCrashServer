//
//  RCCrashDefine.h
//  RCCrashServer
//
//  Created by Ray on 2019/1/12.
//  Copyright © 2019 Ray. All rights reserved.
//

#ifndef RCCrashDefine_h
#define RCCrashDefine_h


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#ifdef DEBUG
#define RCLog(fmt, ...) NSLog((fmt), ##__VA_ARGS__);
#else
#define RCLog(...);
#endif


#ifdef DEBUG
#define RCMethod(...) NSLog(@"%s", __func__);
#else
#define RCMethod(...);
#endif

#endif /* RCCrashDefine_h */
