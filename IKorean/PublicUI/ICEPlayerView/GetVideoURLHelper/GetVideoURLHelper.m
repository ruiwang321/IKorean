//
//  GetVideoURLHelper.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/6.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "GetVideoURLHelper.h"
static GetVideoURLHelper * getVideoURLHelper=nil;

@interface GetVideoURLHelper()
<
UIWebViewDelegate
>

@end

@implementation GetVideoURLHelper
+(GetVideoURLHelper *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        getVideoURLHelper=[[GetVideoURLHelper alloc]init];
    });
    return getVideoURLHelper;
}

-(void)getVideoURLWithVideoID:(NSString *)videoID
{
    
}

@end
