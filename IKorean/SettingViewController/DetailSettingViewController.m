//
//  DetailSettingViewController.m
//  IKorean
//
//  Created by ruiwang on 16/9/19.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "DetailSettingViewController.h"

@interface DetailSettingViewController ()

@end

@implementation DetailSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    [self setLeftButtonWithImageName:@"back@2x" action:@selector(backAction)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
