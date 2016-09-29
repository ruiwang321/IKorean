//
//  MovieDetailUnitView.m
//  ICinema
//
//  Created by wangyunlong on 16/9/24.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "MovieDetailUnitView.h"
@implementation MovieDetailUnitViewModel

@end

@interface MovieDetailUnitView ()
@property (nonatomic,strong) UIScrollView * scrollView;
@property (nonatomic,strong) UILabel * videoInfoLabel;
@property (nonatomic,strong) NSDictionary * videoNameAttributes;
@property (nonatomic,strong) NSDictionary * videoInfoAttributes;
@property (nonatomic,strong) NSDictionary * videoGradeAttributes;
@property (nonatomic,strong) NSDictionary * videoShowTime_Director_Actor_AreaAttributes;
@property (nonatomic,assign) NSStringDrawingOptions videoInfoOption;
@property (nonatomic,assign) CGSize textBoundingRectSize;
@end

@implementation MovieDetailUnitView
-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame])
    {
        UIFont * videoTitleFont=[UIFont fontWithName:HYQiHei_55Pound size:16];
        UIFont * videoInfoFont=[UIFont fontWithName:HYQiHei_50Pound size:13];
        UIColor * videoTitleColor=[UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1];
        UIColor * videoInfoColor=[UIColor colorWithRed:138.0f/255.0f green:138.0f/255.0f blue:138.0f/255.0f alpha:1];
        UIColor * videoGradeColor=[UIColor colorWithRed:239.0f/255.0f green:137.0f/255.0f blue:50.0f/255.0f alpha:1];
        UIColor * videoShowTime_Director_Actor_AreaAttributesColor=[[ICEAppHelper shareInstance] appPublicColor];
        
        NSMutableParagraphStyle * videoNameParagraphStyle=[[NSMutableParagraphStyle alloc]init];
        [videoNameParagraphStyle setAlignment:NSTextAlignmentLeft];
        [videoNameParagraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
        [videoNameParagraphStyle setLineSpacing:5];
        [videoNameParagraphStyle setParagraphSpacing:15];
        
        NSMutableParagraphStyle * videoInfoParagraphStyle=[[NSMutableParagraphStyle alloc]init];
        [videoInfoParagraphStyle setAlignment:NSTextAlignmentJustified];
        [videoInfoParagraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
        [videoInfoParagraphStyle setLineSpacing:5];
        [videoInfoParagraphStyle setParagraphSpacing:8];
        
        self.videoNameAttributes=@{
                                   NSFontAttributeName:videoTitleFont,
                                   NSForegroundColorAttributeName:videoTitleColor,
                                   NSParagraphStyleAttributeName:videoNameParagraphStyle
                                   };
        

        self.videoInfoAttributes=@{
                                   NSFontAttributeName:videoInfoFont,
                                   NSForegroundColorAttributeName:videoInfoColor,
                                   NSParagraphStyleAttributeName:videoInfoParagraphStyle
                                   };
        
        self.videoGradeAttributes=@{
                                    NSFontAttributeName:videoInfoFont,
                                    NSForegroundColorAttributeName:videoGradeColor,
                                    NSParagraphStyleAttributeName:videoInfoParagraphStyle
                                    };
        
        self.videoShowTime_Director_Actor_AreaAttributes=@{
                                                           NSFontAttributeName:videoInfoFont,
                                                           NSForegroundColorAttributeName:videoShowTime_Director_Actor_AreaAttributesColor,
                                                           NSParagraphStyleAttributeName:videoInfoParagraphStyle
                                                           };
        
        _videoInfoOption=NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
        
        _textBoundingRectSize=CGSizeMake(CGRectGetWidth(frame)-20, 10000);
        
        self.scrollView=[[UIScrollView alloc] initWithFrame:self.bounds];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [self addSubview:_scrollView];
    }
    return self;
}

-(void)updateMovieDetailUnitViewWithModel:(MovieDetailUnitViewModel *)model
{
    if (model)
    {
        
        NSMutableAttributedString * videoInfoAttributedString=[[NSMutableAttributedString alloc] initWithString:[model videoName]
                                                                                                     attributes:_videoNameAttributes];
        
        [videoInfoAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n评分："
                                                                                          attributes:_videoInfoAttributes]];
        
        [videoInfoAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[model videoGrade]
                                                                                          attributes:_videoGradeAttributes]];
        
        [videoInfoAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n更新："
                                                                                          attributes:_videoInfoAttributes]];
        
        [videoInfoAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[model videoShowTime]
                                                                                          attributes:_videoShowTime_Director_Actor_AreaAttributes]];
        
        [videoInfoAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n类型："
                                                                                          attributes:_videoInfoAttributes]];
        
        [videoInfoAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[model videoDirector]
                                                                                          attributes:_videoShowTime_Director_Actor_AreaAttributes]];
        
        [videoInfoAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n主演："
                                                                                          attributes:_videoInfoAttributes]];
        
        [videoInfoAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[model videoActor]
                                                                                          attributes:_videoShowTime_Director_Actor_AreaAttributes]];
        
        [videoInfoAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[model videoArea]
                                                                                          attributes:_videoShowTime_Director_Actor_AreaAttributes]];
        
        [videoInfoAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n剧情简介：%@",[model videoIntroduction]]
                                                                                          attributes:_videoInfoAttributes]];

        CGSize videoInfoTextSize=[videoInfoAttributedString boundingRectWithSize:_textBoundingRectSize options:_videoInfoOption context:nil].size;
        
        if (_videoInfoLabel==nil)
        {
            CGFloat videoInfoLabelWidth=_textBoundingRectSize.width;
            CGFloat videoInfoLabelMinX=(CGRectGetWidth(self.frame)-videoInfoLabelWidth)/2;
            self.videoInfoLabel=[[UILabel alloc] initWithFrame:CGRectMake(videoInfoLabelMinX, 15, videoInfoLabelWidth, 0)];
            [_videoInfoLabel setNumberOfLines:0];
            [_scrollView addSubview:_videoInfoLabel];
        }
        CGRect videoInfoLabelFrame=[_videoInfoLabel frame];
        videoInfoLabelFrame.size.height=videoInfoTextSize.height;
        [_videoInfoLabel setFrame:videoInfoLabelFrame];
        [_videoInfoLabel setAttributedText:videoInfoAttributedString];
        
        [_scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.frame),CGRectGetMaxY(videoInfoLabelFrame)+10)];
    }
}

@end
