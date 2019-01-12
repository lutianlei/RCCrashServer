//
//  RCCrashLogController.m
//  RCCrashServer
//
//  Created by Ray on 2019/1/11.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "RCCrashLogController.h"
#import "RCCrashLogCell.h"
#import "RCCrashServer.h"

static NSString *const kCellId = @"RCCrashLogCell";

@interface RCCrashLogController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *logList;

@end

@implementation RCCrashLogController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"猪猪猪crashlog说你呢";
    self.view.backgroundColor = [UIColor blackColor];
    [self rc_setNavBarRightItem];
    
    self.logList = rc_fetchFileFolder();
    [self.tableView reloadData];
}

- (void)rc_setNavBarRightItem{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"关闭" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 30, 30);
    [button addTarget:self action:@selector(rc_closeLogs:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
}


#pragma mark - action

- (void)rc_closeLogs:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -UITableViewDelegate,UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RCCrashLogCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    NSString *fileFolderPath = self.logList[indexPath.row];
    cell.filesPath = rc_fetchFiles(fileFolderPath);
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 180.f;
}

#pragma mark - init
- (UITableView *)tableView{
    if (!_tableView) {
        
        UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        table.estimatedRowHeight = 100.f;
        // register cell
        UINib *nib = [UINib nibWithNibName:kCellId bundle:nil];
        [table registerNib:nib forCellReuseIdentifier:kCellId];
        
        table.delegate = self;
        table.dataSource = self;
        [self.view addSubview:table];
        _tableView = table;
    }
    return _tableView;
}


@end
