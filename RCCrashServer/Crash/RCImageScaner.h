//
//  RCImageScaner.h
//  RCCrashServer
//
//  Created by Ray on 2019/1/12.
//  Copyright © 2019 Ray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCImageScaner : NSObject

+ (void)rc_scan:(UIImageView *)imageView;

@end

NS_ASSUME_NONNULL_END
