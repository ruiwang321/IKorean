//
//  ICEPlayerViewPublicDataHelper.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/13.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEPlayerViewPublicDataHelper.h"
static ICEPlayerViewPublicDataHelper * publicDataHelper=nil;

@interface ICEPlayerViewPublicDataHelper ()

@property (nonatomic,strong,readwrite) UIColor * playerViewPublicColor;
@property (nonatomic,strong,readwrite) UIColor * playerViewControlColor;
@property (nonatomic,strong,readwrite) UIColor * playerViewBorderColor;
@property (nonatomic,strong,readwrite) UIColor * collectionViewCellColor;

@end

@implementation ICEPlayerViewPublicDataHelper

+(ICEPlayerViewPublicDataHelper *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        publicDataHelper=[[ICEPlayerViewPublicDataHelper alloc] init];
    });
    return publicDataHelper;
}

-(id)init
{
    if (self=[super init])
    {
        self.playerViewPublicColor=[[UIColor alloc] initWithRed:30.0f/255.0f green:30.0f/255.0f blue:30.0f/255.0f alpha:0.9];
        self.playerViewControlColor=APPColor;
        self.playerViewBorderColor=[[UIColor alloc]initWithRed:70.0f/255.0f green:70.0f/255.0f blue:70.0f/255.0f alpha:1];
        self.collectionViewCellColor=[[UIColor alloc]initWithRed:10.0f/255.0f green:10.0f/255.0f blue:10.0f/255.0f alpha:0.9];
    }
    return self;
}

@end
