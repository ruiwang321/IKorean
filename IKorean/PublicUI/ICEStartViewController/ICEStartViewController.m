//
//  ICEStartViewController.m
//  ICinema
//
//  Created by wangyunlong on 16/6/27.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEStartViewController.h"
@interface ICEStartViewController ()
@end

@implementation ICEStartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    CGFloat screenWidth=CGRectGetWidth(self.view.frame);
    CGFloat screenHeight=CGRectGetHeight(self.view.frame);
    NSString * stringOfDefaultImge=nil;
    if (screenWidth==320)
    {
        if (CGRectGetHeight(self.view.frame)==480)
        {
            stringOfDefaultImge=@"default@2x";
        }
        else
        {
            stringOfDefaultImge=@"default-568h@2x";
        }
    }
    else if(screenWidth==375)
    {
        stringOfDefaultImge=@"default-667h@2x";
    }
    else
    {
        stringOfDefaultImge=@"default-736h@3x";
    }
    
    //启动页
    UIImageView * defaultImageView=[[UIImageView alloc] initWithFrame:self.view.bounds];
    [defaultImageView setImage:IMAGENAME(stringOfDefaultImge, @"png")];
    [defaultImageView setUserInteractionEnabled:YES];
    [self.view addSubview:defaultImageView];
    
    //底部白色页
    CGFloat defaultScreenHeight=1334;
    CGFloat defaultBottomViewHeight=197;
    CGFloat bottomViewHeight=screenHeight*defaultBottomViewHeight/defaultScreenHeight;
    CGRect  bottomViewFrame=CGRectMake(0, screenHeight-bottomViewHeight, screenWidth, bottomViewHeight);
    UIView * bottomView=[[UIView alloc] initWithFrame:bottomViewFrame];
    [bottomView setBackgroundColor:AppStartBottomViewColor];
    [self.view addSubview:bottomView];
    
    //应用图标
    CGFloat defaultScreenWidth=750;
    CGFloat defaultAppLogoImageMinX=112;
    CGFloat defaultAppLogoImageMinY=50;
    CGFloat appLogoImageMinX=screenWidth*defaultAppLogoImageMinX/defaultScreenWidth;
    CGFloat appLogoImageMinY=defaultAppLogoImageMinY/defaultBottomViewHeight*bottomViewHeight;
    CGFloat appLogoImageWidth=bottomViewHeight-2*appLogoImageMinY;
    CGRect  appLogoImageViewFrame=CGRectMake(appLogoImageMinX, appLogoImageMinY, appLogoImageWidth, appLogoImageWidth);
    UIImageView * appLogoImageView=[[UIImageView alloc] initWithFrame:appLogoImageViewFrame];
    [appLogoImageView setImage:IMAGENAME(@"Icon-40@3x", @"png")];
    [appLogoImageView.layer setMasksToBounds:YES];
    [appLogoImageView.layer setCornerRadius:4];
    [bottomView addSubview:appLogoImageView];
    
    //应用宣传语
    CGFloat sloganLabelMinX=CGRectGetMaxX(appLogoImageViewFrame)+20;
    CGFloat sloganLabelWidth=screenWidth-sloganLabelMinX;
    CGRect  sloganLabelFrame=CGRectMake(sloganLabelMinX, 0, sloganLabelWidth, bottomViewHeight);
    UILabel * sloganLabel=[[UILabel alloc] initWithFrame:sloganLabelFrame];
    [sloganLabel setTextAlignment:NSTextAlignmentLeft];
    [sloganLabel setTextColor:AppSloganColor];
    [sloganLabel setFont:[UIFont fontWithName:HYQiHei_65Pound size:20]];
    [sloganLabel setText:AppSlogan];
    [bottomView addSubview:sloganLabel];
    
    //应用名称
    CGFloat titleLabelHeight=24;
    CGRect  titleLabelFrame=CGRectMake(0, CGRectGetMinY(bottomViewFrame)-70, screenWidth, titleLabelHeight);
    UILabel * titleLabel=[[UILabel alloc] initWithFrame:titleLabelFrame];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:AppStartViewNameColor];
    [titleLabel setFont:[UIFont fontWithName:HYQiHei_65Pound size:22]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:[ICEAppHelper shareInstance].appName];
    [self.view addSubview:titleLabel];
    
    __weak typeof(self) wself=self;
    dispatch_group_t downloadGroup = dispatch_group_create();
    
    dispatch_group_enter(downloadGroup);
    [[ICEAppHelper shareInstance]asyncCheckAuditStatusWithCompletedBlock:^{
        dispatch_group_leave(downloadGroup);
    }];
    dispatch_group_enter(downloadGroup);
    [[ICEAppHelper shareInstance]asyncGetMyADWithCompletedBlock:^{
        dispatch_group_leave(downloadGroup);
    }];
    dispatch_group_notify(downloadGroup, dispatch_get_main_queue(), ^{
        [wself performSelector:@selector(executeBlock) withObject:nil afterDelay:1];
    });
}

- (void)executeBlock
{
    if (_loadingDataCompletedBlock) {
        _loadingDataCompletedBlock();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
