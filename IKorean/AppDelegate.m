//
//  AppDelegate.m
//  IKorean
//
//  Created by ruiwang on 16/9/8.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "AppDelegate.h"
#import "ICEAppGuideView.h"
#import "MainTabBarController.h"
#import "HomeViewController.h"
#import "AdSpreadScreenManager.h"
#import "AdSpreadScreenManagerDelegate.h"
#import "AdViewConfigStore.h"
#import <AdSupport/AdSupport.h>
#import "JsPlayer.h"

@interface AppDelegate ()
<
AdSpreadScreenManagerDelegate
>

@property (strong, nonatomic) JPushModel * jPushModel;
@property (strong, nonatomic) AdSpreadScreenManager * spreadScreenManager;
@property (assign, nonatomic) BOOL isAppInBackGround;

@end

@implementation AppDelegate

- (void)initJPushWithOptions:(NSDictionary *)launchingOption
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    }
    else
    {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    [JPUSHService setupWithOption:launchingOption
                           appKey:JPushKey
                          channel:JPushChannel
                 apsForProduction:IsProduction];
    
    _isAppInBackGround=YES;
    NSDictionary  * userInfo = [launchingOption objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    [self setJPushModelWithUserInfo:userInfo];
}

- (void)setJPushModelWithUserInfo:(NSDictionary *)userInfo
{
    if (userInfo)
    {
        if (self.jPushModel==nil)
        {
            self.jPushModel=[[JPushModel alloc] init];
        }
        _jPushModel.movieTitle=userInfo[@"title"];
        _jPushModel.movieID=[userInfo[@"id"] integerValue];
        _jPushModel.isReceivePushInBackGround=_isAppInBackGround;
        
        [JPUSHService handleRemoteNotification:userInfo];
        
        if ([ICEAppGuideView isDisplayedAppGuideView])
        {
            if (_jPushModel.isReceivePushInBackGround)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationOfPush object:self userInfo:@{@"data":_jPushModel}];
            }
            else  if ([[userInfo allKeys]containsObject:@"aps"])
            {
                NSDictionary * apsDic=userInfo[@"aps"];
                NSString * alert=apsDic[@"alert"];
                if (alert)
                {
                    UIAlertView * alertView=[[UIAlertView alloc] initWithTitle:@"提示"
                                                                       message:alert
                                                                      delegate:self
                                                             cancelButtonTitle:@"点击查看"
                                                             otherButtonTitles:@"忽略",nil];
                    [alertView show];
                }
            }
        }
    }
}

- (void)umengTrack
{
    [MobClick setLogEnabled:NO];
    UMConfigInstance.appKey = UMAppKey;
    [MobClick startWithConfigure:UMConfigInstance];
}

- (void)adDataInit
{
    AdViewConfigStore *cfg = [AdViewConfigStore sharedStore];
    [cfg requestConfig:@[ADViewKey] sdkType:AdViewSDKType_Banner];
    [cfg requestConfig:@[ADViewKey] sdkType:AdViewSDKType_Instl];
    [cfg requestConfig:@[ADViewKey] sdkType:AdViewSDKType_SpreadScreen];
}

- (void)addSpreadScreenAD
{
    self.spreadScreenManager = [AdSpreadScreenManager managerWithAdSpreadScreenKey:ADViewKey
                                                                      WithDelegate:self];
    [self.spreadScreenManager requestAdSpreadScreenView:self.window.rootViewController];
}

- (void)addAppGuideView
{
    ICEAppGuideView * appGuideView=[[ICEAppGuideView alloc] init];
    [self.window addSubview:appGuideView];
}

- (void)enterApp
{
    ICESlideBackNavigationController * rootNC=[[ICESlideBackNavigationController alloc] initWithRootViewController:[[HomeViewController alloc] initWithJPushModel:_jPushModel]];
    [self.window setRootViewController:rootNC];
    if (![ICEAppGuideView isDisplayedAppGuideView]){
        [self addAppGuideView];
    }
    else {
        [self addSpreadScreenAD];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [ICESlideBackNavigationController clearAllSnapshot];
    [self initJPushWithOptions:launchOptions];
    [self adDataInit];
    [self umengTrack];
    __weak typeof(self) wself=self;
    ICEStartViewController * startVC=[[ICEStartViewController alloc] init];
    startVC.loadingDataCompletedBlock=^{
        /**********************测试***************************/
        
        [JsPlayer sharedInstance];
        
        /**********************测试***************************/
        
        [wself enterApp];
    };
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:startVC];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self setJPushModelWithUserInfo:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self setJPushModelWithUserInfo:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    _isAppInBackGround=YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    _isAppInBackGround=NO;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

#pragma mark -UIAlertViewDelegateMethods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationOfPush object:self userInfo:@{@"data":_jPushModel}];
    }
}
#pragma mark AdSpreadScreenManagerDelegate
/**
 * 信息回调
 */
- (void)adSpreadScreenManager:(AdSpreadScreenManager*)manager didGetEvent:(SpreadScreenEventType)eType error:(NSError*)error{
    
}

/**
 * 取得配置的回调通知
 */
- (void)adSpreadScreenDidReceiveConfig:(AdSpreadScreenManager*)manager
{
    
}

/**
 * 配置全部无效或为空的通知
 */
- (void)adSpreadScreenReceivedNotificationAdsAreOff:(AdSpreadScreenManager*)manager
{
    
}

- (AdSpreadScreenShowPosition)adSpreadScreenShowPosition
{
    return AdSpreadScreenShowPositionTop;
}

- (UIWindow *)adSpreadScreenWindow {
    return self.window;
}

//- (NSString *)adSpreadScreenLogoImgName {
//    return @"adLogo@2x.png";
//}

- (UIColor *)adSpreadScreenBackgroundColor {
    return [UIColor whiteColor];
}
@end
