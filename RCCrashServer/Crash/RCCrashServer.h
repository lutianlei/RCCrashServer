//
//  RCCrashServer.h
//  RCCrashServer
//
//  Created by Ray on 2019/1/10.
//  Copyright © 2019 Ray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCCrashServer : NSObject

+ (instancetype)sharedCrashServer;

+ (RCCrashServer *)rc_registerCrasherEnable:(BOOL)enable;

@end

NSArray *rc_fetchFileFolder(void);
NSArray *rc_fetchFiles(NSString *fileFloder);

NS_ASSUME_NONNULL_END
