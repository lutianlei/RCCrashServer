//
//  RCCrashLogCell.m
//  RCCrashServer
//
//  Created by Ray on 2019/1/11.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "RCCrashLogCell.h"
#import "RCImageScaner.h"
#import "RCCrashDefine.h"

@interface RCCrashLogCell ()

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *crashImagePath;
@property (nonatomic, strong) NSDictionary *exceptions;
@property (nonatomic, strong) NSDictionary *appInfo;

@property (weak, nonatomic) IBOutlet UILabel *date_label;
@property (weak, nonatomic) IBOutlet UILabel *crashReason_label;
@property (weak, nonatomic) IBOutlet UIImageView *crash_imageView;
@property (weak, nonatomic) IBOutlet UILabel *version_label;
@property (weak, nonatomic) IBOutlet UILabel *bundleID_label;


@end

@implementation RCCrashLogCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rc_scanCrashImage:)];
    self.crash_imageView.userInteractionEnabled = YES;
    [self.crash_imageView addGestureRecognizer:tap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFilesPath:(NSArray *)filesPath{
    _filesPath = filesPath;
    for (NSString *fileName in filesPath) {
        if ([fileName containsString:@".jpeg"]) {
            self.crashImagePath = fileName;
        }else{
            self.filePath = fileName;
        }
    }
    
    self.date_label.text = nil;
    self.crashReason_label.text = nil;
    self.crash_imageView.image = nil;
    
    
    NSData *crashInfoData = [NSData dataWithContentsOfFile:self.filePath];
    NSString *receiveStr = [[NSString alloc]initWithData:crashInfoData encoding:NSUTF8StringEncoding];
    NSData *data = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];

    NSDictionary *exceptions = info[@"AppCrashInfo"];
    NSDictionary *appInfo = info[@"AppInfos"];
    NSString *date = info[@"CrashDate"];

    self.exceptions = exceptions;
    self.appInfo = appInfo;
    
    self.date_label.text = date;
    self.crashReason_label.text = exceptions[@"reason"];
    self.version_label.text = [NSString stringWithFormat:@"版本号:%@",appInfo[@"CFBundleShortVersionString"]];
    self.bundleID_label.text = [NSString stringWithFormat:@"包名:%@",appInfo[@"CFBundleIdentifier"]];

    
    UIImage *image = [UIImage imageWithContentsOfFile:self.crashImagePath];
    self.crash_imageView.image = image;
}

- (void)rc_scanCrashImage:(UITapGestureRecognizer *)gesture{
    UIImage *crashImage = nil;
    if ([gesture.view isKindOfClass:[UIImageView class]]) {
        crashImage = ((UIImageView *)gesture.view).image;
    }
    
    [RCImageScaner rc_scan:(UIImageView *)gesture.view];
}

- (IBAction)rc_sacnDetails:(id)sender{
    
    NSArray *arr = self.exceptions[@"callStackSymbols"];//得到当前调用栈信息
    NSString *reason = self.exceptions[@"reason"];//非常重要，就是崩溃的原因
    NSString *name = self.exceptions[@"name"];//异常类型

    NSString *details = [NSString stringWithFormat:@"exception type : \n %@ \n crash reason :\n %@ \n call stack info :",name,reason];
    for (NSString *string in arr) {
        details = [details stringByAppendingString:[NSString stringWithFormat:@"\n %@",string]];
    }
    [self rc_alertTitle:@"Infomation" message:details];
    
}

- (IBAction)rc_scanAppInfomation:(id)sender{
    __block NSString *details = nil;
    [self.appInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (details.length != 0) {
            details = [details stringByAppendingString:[NSString stringWithFormat:@"\n%@:%@",key,obj]];
        }else{
            details = [NSString stringWithFormat:@"%@:%@",key,obj];
        }
    }];
    
    if (details) {
        [self rc_alertTitle:@"-AppInfo-" message:details];
    }
    
}

- (void)rc_alertTitle:(nullable NSString *)title message:(nullable NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"CLOSE" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:action];
    UIViewController *presentVC = [[UIApplication sharedApplication] keyWindow].rootViewController;
    while (presentVC.presentedViewController) {
        presentVC = presentVC.presentedViewController;
    }
    [presentVC presentViewController:alertController animated:YES completion:nil];

}

@end
