//
//  SettingViewController.m
//  IKorean
//
//  Created by ruiwang on 16/9/13.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "SettingViewController.h"
#import "DetailSettingViewController.h"
#import "HistoryViewController.h"
#import "FavouriteViewController.h"

@interface SettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myNavigationBar.hidden = YES;
    
    [self createMainTableView];
}

- (void)createMainTableView {
    _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.rowHeight = 60;
    _mainTableView.sectionHeaderHeight = 0;
    _mainTableView.sectionFooterHeight = 10;
    _mainTableView.bounces = NO;
    _mainTableView.separatorInset = UIEdgeInsetsZero;
    _mainTableView.layoutMargins = UIEdgeInsetsZero;
    [self.view addSubview:_mainTableView];
    
    
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*428/750)];
    headerView.userInteractionEnabled = YES;
    headerView.image = IMAGENAME(@"headerBackground@2x", @"png");
    _mainTableView.tableHeaderView = headerView;
    
    // 返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 25, 32, 32);
    [backBtn setImage:IMAGENAME(@"settingBack@2x", @"png") forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:backBtn];
    
    //
    UIImageView *headerLogo = [[UIImageView alloc] initWithFrame:CGRectMake(60, 69, self.screenWidth-120, (self.screenWidth-120)*213/483)];
    headerLogo.image = IMAGENAME(@"headerLogo@2x", @"png");
    [headerView addSubview:headerLogo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableViewDelegate datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section? 1: 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.imageView.image = [UIImage imageNamed:@[@[@"我的收藏", @"播放历史", @"设置"], @[@"给个好评"]][indexPath.section][indexPath.row]];
    cell.textLabel.text = @[@[@"我的收藏", @"播放历史", @"设置"], @[@"给个好评"]][indexPath.section][indexPath.row];
    
    cell.textLabel.font = [UIFont fontWithName:HYQiHei_50Pound size:16];
    cell.accessoryType = indexPath.section? UITableViewCellAccessoryNone: UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // 我的收藏
            FavouriteViewController *favouriteVC = [[FavouriteViewController alloc] init];
            [self.navigationController pushViewController:favouriteVC animated:YES];
            
        }else if (indexPath.row == 1) {
            // 播放历史
            HistoryViewController *historyVC = [[HistoryViewController alloc] init];
            [self.navigationController pushViewController:historyVC animated:YES];
            
        }else if (indexPath.row == 2) {
            // 设置
            DetailSettingViewController *detailSettingVC = [[DetailSettingViewController alloc] init];
            detailSettingVC.title = @"设置";
            [self.navigationController pushViewController:detailSettingVC animated:YES];
        }
    }else {
        // 给个好评

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPStoreUrl]];

    }
}

#pragma mark 响应事件
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
