//
//  TVDetailUnitView.m
//  ICinema
//
//  Created by wangyunlong on 16/6/24.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "TVDetailUnitView.h"

@implementation TVDetailUnitView

-(id)initWithFrame:(CGRect)frame
          director:(NSString *)director
             actor:(NSString *)actor
              area:(NSString *)area
          showtime:(NSString *)showtime
{
    if (self=[super initWithFrame:frame])
    {
        CGFloat selfWidth=CGRectGetWidth(frame);
        //蓝色竖条
        [self setBackgroundColor:[UIColor whiteColor]];
        CGRect frameOfBlueView=CGRectMake(0, 10, 2.5, 14);
        UIView * blueView=[[UIView alloc] initWithFrame:frameOfBlueView];
        [blueView setBackgroundColor:[ICEAppHelper shareInstance].appPublicColor];
        [self addSubview:blueView];
        
        //标题
        CGRect frameOfTitle=CGRectMake(CGRectGetMaxX(frameOfBlueView)+7, 10, 100, 14);
        UILabel * labelOfTitle=[[UILabel alloc] initWithFrame:frameOfTitle];
        [labelOfTitle setText:@"详情"];
        [labelOfTitle setFont:[UIFont fontWithName:HYQiHei_65Pound size:14]];
        [labelOfTitle setNumberOfLines:1];
        [labelOfTitle setTextColor:[UIColor colorWithRed:138.0f/255.0f green:138.0f/255.0f blue:138.0f/255.0f alpha:1]];
        [labelOfTitle setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:labelOfTitle];
        
        //详情
        CGFloat originXOfLabel=CGRectGetMinX(frameOfTitle);
        NSMutableParagraphStyle * paragraphStyleOfDetail=[[NSMutableParagraphStyle alloc]init];
        paragraphStyleOfDetail.alignment = NSTextAlignmentLeft;
        paragraphStyleOfDetail.lineBreakMode = NSLineBreakByCharWrapping;
        paragraphStyleOfDetail.lineSpacing=4;
        paragraphStyleOfDetail.paragraphSpacing=2;

        NSDictionary * dicOfInfoAttributes=@{NSFontAttributeName:[UIFont fontWithName:HYQiHei_50Pound size:13],
                                             NSForegroundColorAttributeName:labelOfTitle.textColor,
                                             NSParagraphStyleAttributeName:paragraphStyleOfDetail};
        
        ICEAppHelper * helper=[ICEAppHelper shareInstance];
        NSString * videoDetailString=[NSString stringWithFormat:@"主演：%@\n导演：%@\n制片国家／地区：%@\n上映日期：%@",
                                      (![helper isStringIsEmpty:director])?director:@"未知",
                                      (![helper isStringIsEmpty:actor])?actor:@"未知",
                                      (![helper isStringIsEmpty:area])?area:@"未知",
                                      (![helper isStringIsEmpty:showtime])?showtime:@"未知"];
        
        NSAttributedString * attributeString=[[NSAttributedString alloc] initWithString:videoDetailString
                                                                             attributes:dicOfInfoAttributes];
        
        CGSize sizeOfDetail=[attributeString boundingRectWithSize:CGSizeMake(selfWidth-2*originXOfLabel, 10000)
                                                          options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                          context:nil].size;
        CGRect frameOfDetailLabel=CGRectMake(originXOfLabel, CGRectGetMaxY(frameOfTitle)+10, sizeOfDetail.width, sizeOfDetail.height);
        UILabel * labelOfDetail=[[UILabel alloc] initWithFrame:frameOfDetailLabel];
        [labelOfDetail setNumberOfLines:0];
        [labelOfDetail setAttributedText:attributeString];
        [self addSubview:labelOfDetail];
        
        CGRect frameOfSelf=self.frame;
        frameOfSelf.size.height=CGRectGetMaxY(frameOfDetailLabel)+10;
        self.frame=frameOfSelf;
    }
    return self;
}

@end
