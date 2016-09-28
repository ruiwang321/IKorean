//
//  ICEErrorStateAlertView.m
//  ICinema
//
//  Created by wangyunlong on 16/9/24.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEErrorStateAlertView.h"
@interface ICEErrorStateAlertView ()
@property (nonatomic,copy) void (^clickBlock)();
@end

@implementation ICEErrorStateAlertView

-(id)initWithFrame:(CGRect)frame
    alertImageName:(NSString*)imageName
           message:(NSString *)message
        clickBlock:(void (^)())clickBlock
{
    if (self=[super initWithFrame:frame])
    {
        self.clickBlock=clickBlock;
        CGFloat alertViewWidth=CGRectGetWidth(frame);
        CGFloat alertViewHeight=CGRectGetHeight(frame);
        
        CGFloat messageLabelHeight=17;
        CGFloat vPadding=25;
        
        UIImage * errorImage=IMAGENAME(imageName, @"png");
        CGFloat errorImageWidth=errorImage.size.width;
        CGFloat errorImageHeight=errorImage.size.height;
        CGFloat errorImageMinY=(alertViewHeight-errorImageHeight-vPadding-messageLabelHeight)/2;
        CGRect  errorImageViewFrame=CGRectMake((alertViewWidth-errorImageWidth)/2,
                                               errorImageMinY,
                                               errorImageWidth,
                                               errorImageHeight);
        
        UIImageView * errorImageView=[[UIImageView alloc] initWithFrame:errorImageViewFrame];
        [errorImageView setImage:errorImage];
        [self addSubview:errorImageView];
        
        CGRect  messageLabelFrame=CGRectMake(0, CGRectGetMaxY(errorImageViewFrame)+vPadding, alertViewWidth, messageLabelHeight);
        UILabel *  messageLabel=[[UILabel alloc] initWithFrame:messageLabelFrame];
        [messageLabel setText:message];
        [messageLabel setTextAlignment:NSTextAlignmentCenter];
        [messageLabel setTextColor:[UIColor colorWithRed:138.0f/255.0f green:138.0f/255.0f blue:138.0f/255.0f alpha:1]];
        [messageLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:messageLabelHeight]];
        [self addSubview:messageLabel];
        
        //点击事件
        UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleSingleTap:)];
        [singleTap setNumberOfTapsRequired:1];
        [singleTap setNumberOfTouchesRequired:1];
        [self addGestureRecognizer:singleTap];
        [self setExclusiveTouch:YES];//禁止多重点击
    }
    return self;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.numberOfTapsRequired==1)
    {
        if (_clickBlock) {
            _clickBlock();
        }
    }
}

@end
