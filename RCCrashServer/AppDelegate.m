//
//  AppDelegate.m
//  RCCrashServer
//
//  Created by Ray on 2019/1/10.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "AppDelegate.h"
#import "RCCrashServer.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [RCCrashServer rc_registerCrasherEnable:YES];
    
    return YES;
}


@end
