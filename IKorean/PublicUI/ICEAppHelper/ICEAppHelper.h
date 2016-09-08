//
//  ICEAppHelper.h
//  ICinema
//
//  Created by wangyunlong on 16/6/27.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface ICEAppHelper : NSObject

@property (nonatomic,assign) BOOL isAllowPlayVideoNoWiFi;
@property (nonatomic,assign,readonly) BOOL isNowAllowPlayVideo;
@property (nonatomic,assign,readonly) BOOL isDisplayedPlayVideoNoWifiAlert;
@property (nonatomic,strong,readonly) UIColor * appPublicColor;
@property (nonatomic,strong,readonly) NSString * appName;

+(ICEAppHelper *)shareInstance;

-(BOOL)isStringIsEmpty:(NSString *)InputStr;

-(BOOL)isPassAudit;

-(void)asyncCheckAuditStatusWithCompletedBlock:(void (^)())completedBlock;

-(UIView *)viewWithPlaceholderImageName:(NSString *)placeholderImageName
                              viewWidth:(CGFloat)viewWidth
                             viewHeight:(CGFloat)viewHeight
                           cornerRadius:(CGFloat)cornerRadius;

@end
