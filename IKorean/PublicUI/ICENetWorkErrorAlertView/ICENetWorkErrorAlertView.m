//
//  ICENetWorkErrorAlertView.m
//  ICinema
//
//  Created by yunlongwang on 16/8/14.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICENetWorkErrorAlertView.h"
@interface ICENetWorkErrorAlertView()

@property (nonatomic,copy) void (^netWorkErrorAlertBlock)();

@end

@implementation ICENetWorkErrorAlertView

-(id)initWithFrame:(CGRect)frame
    alertImageName:(NSString*)imageName
netWorkErrorAlertBlock:(void (^)())netWorkErrorAlertBlock
{
    if (self=[super initWithFrame:frame])
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        self.netWorkErrorAlertBlock=netWorkErrorAlertBlock;
        CGFloat alertViewWidth=CGRectGetWidth(frame);
        CGFloat alertViewHeight=CGRectGetHeight(frame);
        
        UIImage * netWorkErrorImage=IMAGENAME(imageName, @"png");
        CGFloat netWorkErrorImageWidth=netWorkErrorImage.size.width;
        CGFloat netWorkErrorImageHeight=netWorkErrorImage.size.height;
        CGRect  netWorkErrorImageViewFrame=CGRectMake((alertViewWidth-netWorkErrorImageWidth)/2,
                                                      (alertViewHeight-netWorkErrorImageHeight)/2,
                                                      netWorkErrorImageWidth,
                                                      netWorkErrorImageHeight);
        UIImageView * netWorkErrorImageView=[[UIImageView alloc] initWithFrame:netWorkErrorImageViewFrame];
        [netWorkErrorImageView setImage:netWorkErrorImage];
        [self addSubview:netWorkErrorImageView];
        
        //点击事件
        UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(touchNetWorkErrorAlertView:)];
        singleTap.numberOfTouchesRequired = 1;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        [self setExclusiveTouch:YES];//禁止多重点击
    }
    return self;
}

-(void)touchNetWorkErrorAlertView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if(tapGestureRecognizer.numberOfTapsRequired == 1)
    {
        if (_netWorkErrorAlertBlock) {
            _netWorkErrorAlertBlock();
        }
    }
}

@end
