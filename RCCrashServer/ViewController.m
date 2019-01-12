//
//  ViewController.m
//  RCCrashServer
//
//  Created by Ray on 2019/1/10.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "ViewController.h"
#import "RCCrashServer.h"
#import "RCCrashLogController.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *crashImgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

}

- (IBAction)click:(id)sender {
    
    NSArray *arr = @[@1,@2];
    NSNumber *rs = arr[3];
}

- (IBAction)checkCrashLogs:(id)sender{
    
    RCCrashLogController *crashVC = [RCCrashLogController new];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:crashVC];
    [self presentViewController:nav animated:YES completion:nil];
    
    
}


@end
