//
//  MyADView.m
//  ICinema
//
//  Created by wangyunlong on 16/9/27.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "MyADView.h"

@implementation MyImageADModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end

@implementation MyTextADModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end

@interface MyADView ()
@property (nonatomic,copy) NSString * url;
@end

@implementation MyADView

-(id)initWithFrame:(CGRect)frame imageADModel:(MyImageADModel *)imageADModel
{
    if (self=[super initWithFrame:frame])
    {
        CGFloat imageADWidth=[imageADModel width];
        CGFloat imageADHeight=[imageADModel height];
        NSString * imgURL=[imageADModel img];
        self.url=[imageADModel url];
        UIView  * placeholderView=[[ICEAppHelper shareInstance]viewWithPlaceholderImageName:@"adPlaceholder@2x"
                                                                                  viewWidth:imageADWidth
                                                                                 viewHeight:imageADHeight
                                                                               cornerRadius:0];
        [self addSubview:placeholderView];
        
        ICEButton * imageADButton=[ICEButton buttonWithType:UIButtonTypeCustom];
        [imageADButton setFrame:[placeholderView bounds]];
        [imageADButton sd_setImageWithURL:[NSURL URLWithString:imgURL] forState:UIControlStateNormal];
        [imageADButton addTarget:self action:@selector(touchAD) forControlEvents:UIControlEventTouchUpInside];
        [placeholderView addSubview:imageADButton];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame textADModel:(MyTextADModel *)textADModel
{
    if (self=[super initWithFrame:frame])
    {
        
    }
    return self;
}

-(void)touchAD
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_url]];
}
@end
