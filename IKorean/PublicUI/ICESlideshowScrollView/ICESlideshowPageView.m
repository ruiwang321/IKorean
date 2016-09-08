//
//  ICESlideshowPageView.m
//  GreatCar
//
//  Created by wangyunlong on 16/1/27.
//  Copyright © 2016年 yunlongwang. All rights reserved.
//

#import "ICESlideshowPageView.h"
@interface ICESlideshowPageView ()

@property (nonatomic,strong) UIImageView * imageView;
@property (nonatomic,strong,readwrite) ICESlideshowPageModel * pageModel;

@end

@implementation ICESlideshowPageView

-(id)initWithFrame:(CGRect)frame placeholderImageName:(NSString *)imageName
{
    if (self=[super initWithFrame:frame])
    {
        [self setUserInteractionEnabled:YES];
        [self setBackgroundColor:[UIColor colorWithRed:212.0f/255.0f green:212.0f/255.0f blue:212.0f/255.0f alpha:1.0f]];
        
        CGFloat pageViewWidth=CGRectGetWidth(frame);
        CGFloat pageViewHeight=CGRectGetHeight(frame);
        
        //占位图片
        UIImage * placeholderImage=IMAGENAME(imageName, @"png");
        CGFloat placeholderImageWidth=placeholderImage.size.width;
        CGFloat placeholderImageHeight=placeholderImage.size.height;
        CGRect  placeholderImageViewFrame=CGRectMake((pageViewWidth-placeholderImageWidth)/2,
                                                     (pageViewHeight-placeholderImageHeight)/2,
                                                     placeholderImageWidth,
                                                     placeholderImageHeight);
        UIImageView * imageViewOfDefault=[[UIImageView alloc] initWithImage:placeholderImage];
        [imageViewOfDefault setUserInteractionEnabled:YES];
        [imageViewOfDefault setFrame:placeholderImageViewFrame];
        [self addSubview:imageViewOfDefault];
        
        //page
        self.imageView=[[UIImageView alloc] initWithFrame:self.bounds];
        [_imageView setUserInteractionEnabled:YES];
        [self addSubview:_imageView];
        
        //点击事件
        UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(selectSomeSlideshow:)];
        singleTap.numberOfTouchesRequired = 1;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        [self setExclusiveTouch:YES];//禁止多重点击
    }
    return self;
}

-(void)setSlideshowPageWithPageModel:(ICESlideshowPageModel *)pageModel
{
    self.pageModel=pageModel;
    
    if (_pageModel)
    {
        [_imageView sd_setImageWithURL:[NSURL URLWithString:_pageModel.img]];
    }
    else
    {
        [_imageView sd_setImageWithURL:[NSURL URLWithString:@""]];
    }
}

-(void)selectSomeSlideshow:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if(tapGestureRecognizer.numberOfTapsRequired == 1)
    {
        if (_selectPageBlock&&_pageModel)
        {
            _selectPageBlock(_pageModel);
        }
    }
}
@end
