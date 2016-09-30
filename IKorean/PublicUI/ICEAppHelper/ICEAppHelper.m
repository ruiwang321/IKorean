//
//  ICEAppHelper.m
//  ICinema
//
//  Created by wangyunlong on 16/6/27.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEAppHelper.h"
#import "Reachability.h"
typedef enum
{
 ICEAppHelperRequestType_AuditStatus,
 ICEAppHelperRequestType_MyAD
}ICEAppHelperRequestType;

static ICEAppHelper * appHelper=nil;

@interface ICEAppHelper ()
{
    AFHTTPSessionManager * m_getAuitStatusManager;
}

@property (nonatomic,strong) Reachability * reachability;
@property (nonatomic,assign,readwrite) BOOL isNowAllowPlayVideo;
@property (nonatomic,assign,readwrite) BOOL isDisplayedPlayVideoNoWifiAlert;
@property (nonatomic,strong,readwrite) UIColor * appPublicColor;
@property (nonatomic,strong)UIColor * placeholderBackGroundColor;
@property (nonatomic,assign)NetworkStatus lastNetworkStatus;
@property (nonatomic,strong,readwrite) NSString * appName;
@property (nonatomic,strong,readwrite) MyImageADModel * contentImageADModel;
@property (nonatomic,strong,readwrite) MyTextADModel  * filterTextADModel;
@property (nonatomic,strong,readwrite) MyTextADModel  * searchTextADModel;

@end

@implementation ICEAppHelper
+(ICEAppHelper *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appHelper=[[ICEAppHelper alloc] init];
    });
    return appHelper;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kReachabilityChangedNotification object:nil];
    [_reachability stopNotifier];
    self.reachability=nil;
}

-(id)init
{
    if (self=[super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        m_getAuitStatusManager=[AFHTTPSessionManager shareInstance];
        self.placeholderBackGroundColor=[[UIColor alloc] initWithRed:212.0f/255.0f green:212.0f/255.0f blue:212.0f/255.0f alpha:1.0f];
        self.appPublicColor=[[UIColor alloc] initWithCGColor:APPColor.CGColor];
        self.reachability=[Reachability reachabilityForInternetConnection];
        self.isAllowPlayVideoNoWiFi=NO;//默认没有wifi不可以看视频
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString * appName=infoDictionary[@"CFBundleDisplayName"];
        self.appName=([self isStringIsEmpty:appName]?@"影视大全":appName);
    }
    return self;
}

-(void)setIsAllowPlayVideoNoWiFi:(BOOL)isAllowPlayVideoNoWiFi
{
    _isAllowPlayVideoNoWiFi=isAllowPlayVideoNoWiFi;
    _isDisplayedPlayVideoNoWifiAlert=isAllowPlayVideoNoWiFi;
    if (_isAllowPlayVideoNoWiFi)
    {
        //如果设置没有WIFI情况下可以看视频，停止网络状态监听，且只要程序不退出就一直可以播放视频(除非在设置页面修改)，无论在什么网络状态下
        [_reachability stopNotifier];
        _isNowAllowPlayVideo=YES;
    }
    else
    {
        //如果设置没有wifi情况下不可以看视频，打开网络状态监听
        [_reachability startNotifier];
        [self switchPlayVideoState];
    }
}

- (void)switchPlayVideoState
{
    NetworkStatus netStatus = [_reachability currentReachabilityStatus];
    if (netStatus==ReachableViaWiFi)
    {
        _isNowAllowPlayVideo=YES;
    }
    else
    {
        _isNowAllowPlayVideo=_isAllowPlayVideoNoWiFi;
    }
    if (netStatus!=_lastNetworkStatus)
    {
        _lastNetworkStatus=netStatus;
        if (!_isNowAllowPlayVideo&&!_isDisplayedPlayVideoNoWifiAlert)
        {
            //NSLog(@"不可以播放");
            [[NSNotificationCenter defaultCenter]postNotificationName:NotificationOfReachabilityChanged object:nil];
        }
        else
        {
            //NSLog(@"可以播放");
        }
    }
}

- (BOOL)isCurrentHaveShowedAlert
{
    BOOL isHave=NO;
    UIWindow* tempWindow=[[UIApplication sharedApplication] keyWindow];
    for (UIView * view in [tempWindow subviews])
    {
        if ([view isKindOfClass:[UIAlertView class]])
        {
            isHave=YES;
            break;
        }
    }
    return isHave;
}

- (void)reachabilityChanged
{
    [self switchPlayVideoState];
}

-(BOOL)isStringIsEmpty:(NSString *)InputStr
{
    BOOL isEmpty=YES;
    
    if (InputStr)
    {
        NSInteger countOfChar=[InputStr length];
        if (countOfChar)
        {
            NSInteger countOfReturnChar=0;
            NSInteger countOfSpaceChar=0;
            for (NSInteger Index=0;Index<countOfChar; Index++)
            {
                char ch=[InputStr characterAtIndex:Index];
                if (ch==' '||ch=='\xa0')
                {
                    countOfSpaceChar++;
                }
                if (ch=='\n'||ch=='\r')
                {
                    countOfReturnChar++;
                }
            }
            NSInteger countOfSpaceAndReturnChar=countOfReturnChar+countOfSpaceChar;
            if (countOfSpaceAndReturnChar<countOfChar)
            {
                isEmpty=NO;
            }
        }
    }
    return isEmpty;
}

-(BOOL)isPassAudit
{
    BOOL ispassAudit=NO;
    NSUserDefaults * userDefaults=[NSUserDefaults standardUserDefaults];
    NSNumber * numberOfIsPassAudit=[userDefaults objectForKey:KeyForCurrentAuditingVersion];
    if (numberOfIsPassAudit)
    {
        ispassAudit=[numberOfIsPassAudit boolValue];
    }
    return ispassAudit;
}

-(void)setAuditStautsWithisPassAudit:(BOOL)ispassAudit
{
    NSUserDefaults * userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[NSNumber numberWithBool:ispassAudit] forKey:KeyForCurrentAuditingVersion];
    [userDefaults synchronize];
}

-(void)analyticalDataWithResponseObject:(id)responseObject requestType:(ICEAppHelperRequestType)type
{
    if (responseObject&&[responseObject[@"code"] integerValue]==1)
    {
        NSDictionary * data=responseObject[@"data"];
        if (ICEAppHelperRequestType_AuditStatus==type)
        {
            BOOL isPassAudit=NO;
            if (data)
            {
                isPassAudit=[data[@"is_open"] boolValue];
            }
            [self setAuditStautsWithisPassAudit:isPassAudit];
        }
        else if (ICEAppHelperRequestType_MyAD==type)
        {
            NSDictionary * contentDic=data[@"content"];
            if (contentDic&&[[contentDic allKeys] count]) {
                if (_contentImageADModel==nil)
                {
                    self.contentImageADModel=[[MyImageADModel alloc] init];
                }
                [_contentImageADModel setValuesForKeysWithDictionary:contentDic];
                
                CGSize  screenSize=[[UIScreen mainScreen] bounds].size;
                CGFloat screenWidth=MIN(screenSize.width, screenSize.height);
                [_contentImageADModel setHeight:[_contentImageADModel height]/[_contentImageADModel width]*screenWidth];
                [_contentImageADModel setWidth:screenWidth];
            }
            
            NSDictionary *filterDic = data[@"filter"];
            if (filterDic&&[[filterDic allKeys] count]) {
                if (_filterTextADModel==nil)
                {
                    self.filterTextADModel=[[MyTextADModel alloc] init];
                }
                [_filterTextADModel setValuesForKeysWithDictionary:filterDic];
            }
            
            
            NSDictionary *searchDic = data[@"search"];
            if (searchDic&&[[searchDic allKeys] count]) {
                if (_searchTextADModel==nil)
                {
                    self.searchTextADModel=[[MyTextADModel alloc] init];
                }
                [_searchTextADModel setValuesForKeysWithDictionary:searchDic];
            }
            
            
            
        }
    }
}

-(void)asyncCheckAuditStatusWithCompletedBlock:(void (^)())completedBlock
{
    __weak typeof(self) wself=self;
    [MYNetworking GET:urlOfAuditStatus
                     parameters:nil
                       progress:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            [wself analyticalDataWithResponseObject:responseObject requestType:ICEAppHelperRequestType_AuditStatus];
                            completedBlock();
                        }
                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            completedBlock();
                        }];
}

-(void)asyncGetMyADWithCompletedBlock:(void (^)())completedBlock
{
    __weak typeof(self) wself=self;
    [m_getAuitStatusManager GET:urlOfGetMyAD
                     parameters:@{@"c":[[NSBundle mainBundle] bundleIdentifier]}
                       progress:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            [wself analyticalDataWithResponseObject:responseObject requestType:ICEAppHelperRequestType_MyAD];
                            completedBlock();
                        }
                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            completedBlock();
                        }];
}

-(UIView *)viewWithPlaceholderImageName:(NSString *)placeholderImageName
                              viewWidth:(CGFloat)viewWidth
                             viewHeight:(CGFloat)viewHeight
                           cornerRadius:(CGFloat)cornerRadius
{
    UIView * view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    [view setBackgroundColor:_placeholderBackGroundColor];
    if (cornerRadius)
    {
        [view.layer setCornerRadius:cornerRadius];
        [view.layer setMasksToBounds:YES];
    }
    UIImage * placeholderImage=IMAGENAME(placeholderImageName, @"png");
    if (placeholderImage)
    {
        //占位图片原始高
        CGFloat placeholderImageHeight=viewHeight/2;
        //占位图片原始宽
        CGFloat placeholderImageWidth=placeholderImage.size.width/placeholderImage.size.height*placeholderImageHeight;
        CGRect  placeholderImageViewFrame=CGRectMake(0, 0, placeholderImageWidth, placeholderImageHeight);
        UIImageView * placeholderImageView=[[UIImageView alloc] initWithFrame:placeholderImageViewFrame];
        [placeholderImageView setCenter:view.center];
        [placeholderImageView setImage:placeholderImage];
        [view addSubview:placeholderImageView];
    }
    
    return view;
}
@end
