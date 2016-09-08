//
//  MainTabBarController.m
//  IKorean
//
//  Created by ruiwang on 16/9/8.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "MainTabBarController.h"
#import "HomeViewController.h"
#import "SearchViewController.h"
#import "LeaderBoardViewController.h"
#import "MoreViewController.h"

@interface MainTabBarController ()

@end

@interface MainTabBarController ()
{
    JPushModel * m_model;
}
@end

@implementation MainTabBarController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NotificationOfPush object:nil];
}

- (id)initWithJPushModel:(JPushModel *)model
{
    if (self=[super init])
    {
        m_model=model;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(haveNotification:)
                                                     name:NotificationOfPush
                                                   object:nil];
    }
    return self;
}

-(void)receivePush:(JPushModel *)model
{
//    TVDetailViewController * tv=[[TVDetailViewController alloc]initWithID:model.movieID title:model.movieTitle];
//    [self.navigationController pushViewController:tv animated:!model.isReceivePushInBackGround];
}

-(void)haveNotification:(NSNotification *)notification
{
    NSDictionary * userInfo=[notification userInfo];
    if (userInfo)
    {
        JPushModel * model=userInfo[@"data"];
        if (model)
        {
            [self receivePush:model];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    HomeViewController * vc1=[[HomeViewController alloc] init];
    [vc1 setTabBarItemWithTitle:@"首页" normalImageName:@"home@2x" selectedImageName:@"home_Selected@2x"];
    
    SearchViewController * vc2=[[SearchViewController alloc] init];
    [vc2 setTabBarItemWithTitle:@"分类搜" normalImageName:@"search@2x" selectedImageName:@"search_Selected@2x"];
    
    LeaderBoardViewController * vc3=[[LeaderBoardViewController alloc]init];
    [vc3 setTabBarItemWithTitle:@"排行榜" normalImageName:@"leaderboard@2x" selectedImageName:@"leaderboard_Selected@2x"];
    
    MoreViewController * vc4=[[MoreViewController alloc] init];
    [vc4 setTabBarItemWithTitle:@"更多" normalImageName:@"more@2x" selectedImageName:@"more_Selected@2x"];
    
    if (ISPASSAUDIT)
    {
        [self setViewControllers:@[vc1,vc2,vc3,vc4]];
    }
    else
        [self setViewControllers:@[vc1,vc2,vc3,vc4]];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (m_model)
    {
        [self receivePush:m_model];
        m_model=nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
