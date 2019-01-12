//
//  RCCrashServer.m
//  RCCrashServer
//
//  Created by Ray on 2019/1/10.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "RCCrashServer.h"
#import "RCCrashDefine.h"

static NSString *const kCrashFoldernName = @"CrashInfo";
static NSString *const kCrashFileFoldernName = @"CrashFileInfo";

static NSString *const kCacheInfoKeyAppInfos = @"AppInfos";
static NSString *const kCacheInfoKeyDate = @"CrashDate";
static NSString *const kCacheInfoKeyCrashInfo = @"AppCrashInfo";

@interface RCCrashServer ()

@end

static RCCrashServer *crashServer;

@implementation RCCrashServer

+ (instancetype)sharedCrashServer{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        crashServer = [self new];
    });
    return crashServer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


+ (RCCrashServer *)rc_registerCrasherEnable:(BOOL)enable{
    RCCrashServer *crasher = [[RCCrashServer alloc] init];
    if (enable) {
        NSSetUncaughtExceptionHandler(&rc_uncaughtExceptionHandler);
    }
    return crasher;
}

void rc_uncaughtExceptionHandler(NSException *exception){
    
    NSArray *arr = [exception callStackSymbols];//得到当前调用栈信息
    NSString *reason = [exception reason];//非常重要，就是崩溃的原因
    NSString *name = [exception name];//异常类型
    
    NSMutableDictionary *crashDic = [NSMutableDictionary dictionary];
    [crashDic setObject:arr forKey:@"callStackSymbols"];
    [crashDic setObject:reason forKey:@"reason"];
    [crashDic setObject:name forKey:@"name"];
    
    rc_storeInfo([crashDic copy], rc_getImageWithFullScreenshot());
    RCLog(@"exception type : %@ \n crash reason : %@ \n call stack info : %@", name, reason, arr);

}

void rc_storeInfo(NSDictionary *exceptions, UIImage *crashImage){
    NSMutableDictionary *cacheDic = [NSMutableDictionary dictionary];
    [cacheDic setObject:rc_appInfo() forKey:kCacheInfoKeyAppInfos];
    [cacheDic setObject:rc_localDate() forKey:kCacheInfoKeyDate];
    [cacheDic setObject:exceptions forKey:kCacheInfoKeyCrashInfo];
    
    NSData *cacheData = [NSJSONSerialization dataWithJSONObject:[cacheDic copy] options:NSJSONWritingPrettyPrinted error:nil];
    NSString *crashFilePath = rc_crashFilePath();
    [cacheData writeToFile:crashFilePath atomically:YES];
    
    NSString *crashImageFilePath = [NSString stringWithFormat:@"%@.jpeg",crashFilePath];
    BOOL rs = [UIImageJPEGRepresentation(crashImage, 0.8) writeToFile:crashImageFilePath atomically:YES];
    if (!rs) {
        RCLog(@"图片存储失败");
    }
}

NSArray *rc_fetchFileFolder(){
    
    NSString *floderPath = rc_crashFolderPath();
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *array = [manager contentsOfDirectoryAtPath:rc_crashFolderPath() error:nil];
    NSMutableArray *files = [NSMutableArray array];
    
    // 取得目录下所有文件列表
    array = [array sortedArrayUsingComparator:^(NSString *firFile, NSString *secFile) {  // 将文件列表排序
        NSString *firPath = [floderPath stringByAppendingPathComponent:firFile];  // 获取前一个文件完整路径
        NSString *secPath = [floderPath stringByAppendingPathComponent:secFile];  // 获取后一个文件完整路径
        NSDictionary *firFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:firPath error:nil];  // 获取前一个文件信息
        NSDictionary *secFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:secPath error:nil];  // 获取后一个文件信息
        id firData = [firFileInfo objectForKey:NSFileCreationDate];  // 获取前一个文件创建时间
        id secData = [secFileInfo objectForKey:NSFileCreationDate];  // 获取后一个文件创建时间
        
        return [secData compare:firData];  // 降序
        
    }];
    
    
    for (NSString *fileName in array) {
        if ([fileName isEqualToString:@".DS_Store"]) {
            continue;
        }
        [files addObject:[rc_crashFolderPath() stringByAppendingPathComponent:fileName]];

    }
    RCLog(@"%lu",[files count]);
    return [files copy];
}
NSArray *rc_fetchFiles(NSString *fileFloder){
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *array = [manager contentsOfDirectoryAtPath:fileFloder error:nil];
    NSMutableArray *files = [NSMutableArray array];
    
    for (NSString *fileName in array) {
        if ([fileName isEqualToString:@".DS_Store"]) {
            continue;
        }
        [files addObject:[fileFloder stringByAppendingPathComponent:fileName]];
        
    }
    RCLog(@"%lu",[files count]);
    return [files copy];
}


NSString *rc_crashFolderPath(){
    NSString *kCrashFolderPrefix = [rc_appInfo() objectForKey:@"CFBundleIdentifier"];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *folderPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",kCrashFolderPrefix,kCrashFoldernName]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:folderPath]) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return folderPath;
}
NSString *rc_crashFileFolderPath(){
    NSString *folderPath = [rc_crashFolderPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"crashFileFolder_%@",rc_localDate()]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:folderPath]) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return folderPath;
}
NSString *rc_crashFilePath(){
    NSString *filePath = [rc_crashFileFolderPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"crashInfo_%@",rc_localDate()]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:[@"~~~~~~~~~~~程序异常日志~~~~~~~~~~~\n\n" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }
    return filePath;
}

NSString *rc_localDate(){
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date dateByAddingTimeInterval: interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:localeDate];
    return strDate;
}

NSDictionary *rc_appInfo(){
    return [[NSBundle mainBundle] infoDictionary];
}
//截屏~
UIImage *rc_getImageWithFullScreenshot(void){
    BOOL ignoreOrientation = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0");
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGSize imageSize = CGSizeZero;
    
    if (UIInterfaceOrientationIsPortrait(orientation) || ignoreOrientation)
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        
        // Correct for the screen orientation
        if(!ignoreOrientation)
        {
            if(orientation == UIInterfaceOrientationLandscapeLeft)
            {
                CGContextRotateCTM(context, (CGFloat)M_PI_2);
                CGContextTranslateCTM(context, 0, -imageSize.width);
            }
            else if(orientation == UIInterfaceOrientationLandscapeRight)
            {
                CGContextRotateCTM(context, (CGFloat)-M_PI_2);
                CGContextTranslateCTM(context, -imageSize.height, 0);
            }
            else if(orientation == UIInterfaceOrientationPortraitUpsideDown)
            {
                CGContextRotateCTM(context, (CGFloat)M_PI);
                CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
            }
        }
        
        if([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO];
        else
            [window.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
