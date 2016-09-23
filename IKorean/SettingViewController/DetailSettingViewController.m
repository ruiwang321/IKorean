//
//  DetailSettingViewController.m
//  IKorean
//
//  Created by ruiwang on 16/9/19.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "DetailSettingViewController.h"
#import "FeedbackViewController.h"

@interface DetailSettingViewController ()

@property (nonatomic,strong)UILabel  * cacheLabel;
@property (nonatomic,strong)UISwitch   * wifiSwitch;
@end

@implementation DetailSettingViewController
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSString *)getCacheSize
{
    unsigned long long imageChaheSize = [[SDImageCache sharedImageCache] getSize];
    float totalSize=imageChaheSize/1024.0f/1024.0f;
    NSString * stringOfCache=[NSString stringWithFormat:@"%.1fM",totalSize];
    return stringOfCache;
}

-(void)clearCache
{
    unsigned long long imageChaheSize = [[SDImageCache sharedImageCache] getSize];
    if (imageChaheSize>0)
    {
        [self startLoading];
        __weak typeof(self) wself=self;
        [[SDImageCache sharedImageCache]clearMemory];
        [[SDImageCache sharedImageCache]clearDiskOnCompletion:^
         {
             [wself stopLoading];
             [wself.cacheLabel setText:@"0.0M"];
         }];
    }
}

- (void)switchChange
{
    ICEAppHelper * helper=[ICEAppHelper shareInstance];
    helper.isAllowPlayVideoNoWiFi=!helper.isAllowPlayVideoNoWiFi;
}

- (void)feedBack
{
    FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] init];
    [self.navigationController pushViewController:feedbackVC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"设置"];
    [self setLeftButtonWithImageName:@"back@2x" action:@selector(backAction)];
    
    NSArray * arrayOfData=@[
                            @{@"title":@"清理图片缓存",@"subtitle":@"清理缓存，释放空间"},
                            @{@"title":@"使用2G/3G/4G网络提醒",@"subtitle":@"非WIFI环境流量提醒"},
                            @{@"title":@"帮助反馈"}
                            ];
    
    //行数
    NSInteger rowCount=[arrayOfData count];
    //标题行原始frame
    CGRect    titleRowOriginFrame=CGRectMake(0, 0, self.screenWidth, 42);
    //标题Label原始frame
    CGRect    titleLabelOriginFrame=CGRectMake(10, 0, 160, CGRectGetHeight(titleRowOriginFrame));
    //子标题原始frame
    CGRect    subTitleRowOriginFrame=CGRectMake(0, 0, self.screenWidth, 27);
    //子标题label原始frame
    CGRect    subTitleLabelOriginFrame=CGRectMake(10, 0, 150, CGRectGetHeight(subTitleRowOriginFrame));
    //标题行颜色
    UIColor * titleRowColor=[UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1];
    //标题文字颜色
    UIColor * titleColor=[UIColor colorWithRed:114.0f/255.0f green:114.0f/255.0f blue:114.0f/255.0f alpha:1];
    //标题字体
    UIFont  * titleFont=[UIFont fontWithName:HYQiHei_50Pound size:15];
    //子标题文字颜色
    UIColor * subTitleColor=[UIColor colorWithRed:152.0f/255.0f green:152.0f/255.0f blue:152.0f/255.0f alpha:1];
    //子标题字体
    UIFont  * subTitleFont=[UIFont fontWithName:HYQiHei_50Pound size:12];
    
    //最后一个视图的MaxY
    CGFloat   lastViewMaxY=0;
    
    //滚动图
    CGRect scrollViewFrame=CGRectMake(0, self.navigationBarHeight, self.screenWidth, self.screenHeight-self.navigationBarHeight);
    UIScrollView * scrollView=[[UIScrollView alloc] initWithFrame:scrollViewFrame];
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:scrollView];
    
    for (NSInteger Index=0;Index<rowCount;Index++)
    {
        NSDictionary * rowData=arrayOfData[Index];
        
        NSString * title=rowData[@"title"];
        
        //标题行
        CGRect titleRowFrame=titleRowOriginFrame;
        titleRowFrame.origin.y=lastViewMaxY;
        UIView * titleRow=[[UIView alloc] initWithFrame:titleRowFrame];
        [titleRow setBackgroundColor:titleRowColor];
        [scrollView addSubview:titleRow];
        
        //标题
        UILabel * titleLabel=[[UILabel alloc] initWithFrame:titleLabelOriginFrame];
        [titleLabel setText:title];
        [titleLabel setFont:titleFont];
        [titleLabel setTextColor:titleColor];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        [titleRow addSubview:titleLabel];
        
        lastViewMaxY=CGRectGetMaxY(titleRowFrame);
        if ([[rowData allKeys]containsObject:@"subtitle"])
        {
            //子标题
            NSString * subTitle=rowData[@"subtitle"];
            
            CGRect subTitleRowFrame=subTitleRowOriginFrame;
            subTitleRowFrame.origin.y=lastViewMaxY;
            UIView * subTitleRow=[[UIView alloc] initWithFrame:subTitleRowFrame];
            [scrollView addSubview:subTitleRow];
            
            UILabel * subTitleLbale=[[UILabel alloc] initWithFrame:subTitleLabelOriginFrame];
            [subTitleLbale setText:subTitle];
            [subTitleLbale setFont:subTitleFont];
            [subTitleLbale setTextColor:subTitleColor];
            [subTitleLbale setTextAlignment:NSTextAlignmentLeft];
            [subTitleRow addSubview:subTitleLbale];
            lastViewMaxY=CGRectGetMaxY(subTitleRowFrame);
        }
        
        if (Index==0)
        {
            self.cacheLabel=[[UILabel alloc] initWithFrame:CGRectMake(self.screenWidth-65-10, 0, 65, CGRectGetHeight(titleRowFrame))];
            [_cacheLabel setText:[self getCacheSize]];
            [_cacheLabel setTextColor:[UIColor colorWithRed:138.0f/255.0f green:138.0f/255.0f blue:138.0f/255.0f alpha:1]];
            [_cacheLabel setFont:[UIFont fontWithName:HYQiHei_50Pound size:14]];
            [_cacheLabel setTextAlignment:NSTextAlignmentRight];
            [titleRow addSubview:_cacheLabel];
            
            ICEButton * button=[ICEButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:titleRow.bounds];
            [button addTarget:self action:@selector(clearCache) forControlEvents:UIControlEventTouchUpInside];
            [titleRow addSubview:button];
        }
        else if(Index==1)
        {
            self.wifiSwitch=[[UISwitch alloc] initWithFrame:CGRectMake(self.screenWidth-10-50, (CGRectGetHeight(titleRowFrame)-31)/2.0f, 50, 31)];
            [_wifiSwitch setOn:![ICEAppHelper shareInstance].isAllowPlayVideoNoWiFi];
            [_wifiSwitch addTarget:self action:@selector(switchChange) forControlEvents:UIControlEventValueChanged];
            [_wifiSwitch setOnTintColor:APPColor];
            [titleRow addSubview:_wifiSwitch];
        }
        else if(Index==2)
        {
            UIImage * arrowImage=IMAGENAME(@"moreRightArrow@2x", @"png");
            CGFloat arrowImageWidth=arrowImage.size.width;
            CGFloat arrowImageHeight=arrowImage.size.height;
            
            CGRect  arrowImageViewFrame=CGRectMake(self.screenWidth-10-arrowImageWidth,
                                                   (CGRectGetHeight(titleRowFrame)-arrowImageHeight)/2,
                                                   arrowImageWidth,
                                                   arrowImageHeight);
            
            UIImageView * arrowImageView=[[UIImageView alloc] initWithFrame:arrowImageViewFrame];
            [arrowImageView setImage:arrowImage];
            [titleRow addSubview:arrowImageView];
            
            ICEButton * button=[ICEButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:titleRow.bounds];
            [button addTarget:self action:@selector(feedBack) forControlEvents:UIControlEventTouchUpInside];
            [titleRow addSubview:button];
        }
    }
    
    [scrollView setContentSize:CGSizeMake(self.screenWidth, lastViewMaxY)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
