//
//  RCImageScaner.m
//  RCCrashServer
//
//  Created by Ray on 2019/1/12.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "RCImageScaner.h"
#import "RCCrashDefine.h"

@interface RCImageScaner ()

@property (nonatomic, strong) UIImageView *scanImageView;
@property (nonatomic, strong) UIImageView *originalImageView;

@end

@implementation RCImageScaner

+ (void)rc_scan:(UIImageView *)imageView{
    
    RCImageScaner *scaner = [self defaultScaner];
    scaner.originalImageView = imageView;
    [scaner rc_createScanImageView];
    [scaner rc_show];
}

+ (instancetype)defaultScaner{
    static RCImageScaner *scaner;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scaner = [self new];
    });
    return scaner;
}

- (void)rc_createScanImageView{
    UIImageView *scanImageView = [[UIImageView alloc] initWithImage:self.originalImageView.image];
    scanImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rc_closeScan:)];
    [scanImageView addGestureRecognizer:tap];
    self.scanImageView = scanImageView;

}

- (CGRect)rc_convertRect{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect rect = [self.originalImageView convertRect:self.originalImageView.bounds toView:window];
    return rect;
}

- (void)rc_show{
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.scanImageView.frame = [self rc_convertRect];
    [window addSubview:self.scanImageView];
    [UIView animateWithDuration:0.4 animations:^{
        self.scanImageView.frame = [UIScreen mainScreen].bounds;
    } completion:nil];

}

- (void)rc_closeScan:(UITapGestureRecognizer *)gesture{
    RCMethod(@"%s",__func__);
    [UIView animateWithDuration:0.4 animations:^{
        self.scanImageView.frame = [self rc_convertRect];
    } completion:^(BOOL finished) {
        [self.scanImageView removeFromSuperview];
        self.scanImageView = nil;
    }];
}


@end
