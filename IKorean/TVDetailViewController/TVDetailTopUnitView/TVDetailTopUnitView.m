//
//  TVDetailTopUnitView.m
//  ICinema
//
//  Created by wangyunlong on 16/6/21.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "TVDetailTopUnitView.h"

@implementation TVDetailTopUnitModel

@end

#define maxStarCount   5
#define playButtonToAdPadding 2
#define adViewToBottomPadding 2
@interface TVDetailTopUnitView ()
{
    UIImageView * m_favoritesImageView;
}

@property (nonatomic,strong)TVDetailTopUnitModel * model;

@end

@implementation TVDetailTopUnitView

-(id)initWithFrame:(CGRect)frame model:(TVDetailTopUnitModel *)model
{
    if (self=[super initWithFrame:frame])
    {
        self.model=model;
        [self setBackgroundColor:[UIColor whiteColor]];
        CGFloat topUnitViewWidth=CGRectGetWidth(frame);
        CGFloat topUnitViewheight=CGRectGetHeight(frame);
        //电影图片
        CGFloat videoImageWidth=100;
        CGFloat videoImageHeight=145;
        CGRect  videoImageViewFrame = CGRectMake(10, 10, videoImageWidth, videoImageHeight);
        UIView * placeholderView=[[ICEAppHelper shareInstance] viewWithPlaceholderImageName:@"publicPlaceholder@2x"
                                                                                  viewWidth:videoImageWidth
                                                                                 viewHeight:videoImageHeight
                                                                               cornerRadius:4];
        [placeholderView setFrame:videoImageViewFrame];
        [self addSubview:placeholderView];
        
        UIImageView * videoImageView=[[UIImageView alloc] initWithFrame:placeholderView.bounds];
        [videoImageView sd_setImageWithURL:[NSURL URLWithString:model.imgUrl]];
        [placeholderView addSubview:videoImageView];
        
        //星
        CGFloat firstStarMinX = CGRectGetMaxX(videoImageViewFrame)+15;
        CGFloat starMinY=15;
        CGFloat starPadding=7;
        UIImage * redStarImage=IMAGENAME(@"gradeStarLight@2x", @"png");
        UIImage * grayStarImage=IMAGENAME(@"gradeStarNormal@2x", @"png");
        CGFloat starImageWidth=redStarImage.size.width;
        CGFloat starImageHeight=redStarImage.size.height;
        CGRect  starBaseFrame=CGRectMake(0, starMinY, starImageWidth, starImageHeight);
        int redStarCount=(int)(model.grade/2);
        UIImageView * lastStar = nil;
        for (NSInteger Index=0; Index<maxStarCount; Index++)
        {
            CGRect starFrame=starBaseFrame;
            starFrame.origin.x=firstStarMinX+Index*(starImageWidth+starPadding);
            
            UIImage * starImage=Index<redStarCount?redStarImage:grayStarImage;
            UIImageView * starImageView=[[UIImageView alloc] initWithImage:starImage];
            [starImageView setFrame:starFrame];
            [self addSubview:starImageView];
            lastStar=starImageView;
        }
        
        //评分
        CGRect gradeLabelFrame=CGRectMake(CGRectGetMaxX(lastStar.frame)+starPadding, starMinY, 40, 15);
        UILabel * gradeLabel=[[UILabel alloc] initWithFrame:gradeLabelFrame];
        [gradeLabel setTextAlignment:NSTextAlignmentLeft];
        [gradeLabel setTextColor:[UIColor colorWithRed:93.0f/255.0f green:93.0f/255.0f blue:93.0f/255.0f alpha:1]];
        [gradeLabel setFont:[UIFont fontWithName:HYQiHei_50Pound size:15]];
        [gradeLabel setText:[NSString stringWithFormat:@"%.1f",model.grade]];
        [self addSubview:gradeLabel];
        
        //横幅广告
        CGRect bannerAdUnitViewFrame = CGRectMake(0, CGRectGetMaxY(videoImageViewFrame)+playButtonToAdPadding, topUnitViewWidth, 50);
        BannerAdUnitView * bannerAdUnitView=[[BannerAdUnitView alloc] initWithFrame:bannerAdUnitViewFrame];
        [self addSubview:bannerAdUnitView];
        
        //来源和类型
        ICEAppHelper * helper=[ICEAppHelper shareInstance];
        NSString * videoTypesString=[helper isStringIsEmpty:model.types]?@"未知":model.types;
        NSString * videoSourceString=[helper isStringIsEmpty:model.source]?@"网络":model.source;
        NSString * videoInfoString=[NSString stringWithFormat:@"来源：%@\n类型：%@",videoSourceString,videoTypesString];
        
        NSMutableParagraphStyle * videoInfoParagraphStyle=[[NSMutableParagraphStyle alloc]init];
        videoInfoParagraphStyle.alignment = NSTextAlignmentLeft;
        videoInfoParagraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        videoInfoParagraphStyle.lineSpacing=4;
        videoInfoParagraphStyle.paragraphSpacing=2;
        videoInfoParagraphStyle.headIndent=39;
        
        NSDictionary * videoInfoAttributes=@{
                                             NSFontAttributeName:[UIFont fontWithName:HYQiHei_55Pound size:13],
                                             NSForegroundColorAttributeName:[UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1],
                                             NSParagraphStyleAttributeName:videoInfoParagraphStyle
                                             };
        
        NSStringDrawingOptions option = NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
        
        NSAttributedString * videoInfoAttriString=[[NSAttributedString alloc] initWithString:videoInfoString
                                                                                  attributes:videoInfoAttributes];
        
        CGSize boundSize=CGSizeMake(topUnitViewWidth-10-firstStarMinX, 10000);
        
        CGSize videoTextSize=[videoInfoAttriString boundingRectWithSize:boundSize
                                                                options:option
                                                                context:nil].size;
        
        CGRect videoInfoLabelFrame=CGRectMake(firstStarMinX,
                                              CGRectGetMinY(bannerAdUnitViewFrame)-10-videoTextSize.height,
                                              videoTextSize.width,
                                              videoTextSize.height);
        
        UILabel * videoInfoLabel=[[UILabel alloc] initWithFrame:videoInfoLabelFrame];
        [videoInfoLabel setAttributedText:videoInfoAttriString];
        [videoInfoLabel setNumberOfLines:0];
        [self addSubview:videoInfoLabel];
        
        CGRect topUnitViewFrame=frame;
        topUnitViewFrame.size.height=CGRectGetMaxY(bannerAdUnitViewFrame)+adViewToBottomPadding;
        self.frame=topUnitViewFrame;
        
        
    }
    return self;
}


@end
