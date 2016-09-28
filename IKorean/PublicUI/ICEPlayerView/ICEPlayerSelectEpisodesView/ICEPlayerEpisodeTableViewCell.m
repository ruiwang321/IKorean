//
//  ICEPlayerEpisodeTableViewCell.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/13.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEPlayerEpisodeTableViewCell.h"
#import "ICELabel.h"
@interface ICEPlayerEpisodeTableViewCell ()
@property (nonatomic,strong) ICELabel * titleLabel;
@end

@implementation ICEPlayerEpisodeTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier
         cellWidth:(CGFloat)cellWidth
        cellHeight:(CGFloat)cellHeight
{
    if (self=[super initWithStyle:style
                  reuseIdentifier:reuseIdentifier
                        cellWidth:cellWidth
                       cellHeight:cellHeight])
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

-(void)updateCellWithModel:(ICEPlayerEpisodeModel *)model
{
    if (model)
    {
        if (_titleLabel==nil)
        {
            CGFloat labelVPadding=6;
            CGFloat labelHPadding=10;
            CGRect  titleLabelFrame=CGRectMake(labelHPadding, labelVPadding, self.cellWidth-2*labelHPadding, self.cellHeight-2*labelVPadding);
            self.titleLabel=[[ICELabel alloc] initWithFrame:titleLabelFrame textInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
            [_titleLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:15]];
            [_titleLabel.layer setBorderWidth:1];
            [self addSubview:_titleLabel];
        }
        [_titleLabel setText:model.videoName];
        if (model.isPlay)
        {
            [_titleLabel setTextColor:[ICEPlayerViewPublicDataHelper shareInstance].playerViewControlColor];
            [_titleLabel.layer setBorderColor:_titleLabel.textColor.CGColor];
        }
        else
        {
            [_titleLabel setTextColor:[UIColor whiteColor]];
            [_titleLabel.layer setBorderColor:[ICEPlayerViewPublicDataHelper shareInstance].playerViewBorderColor.CGColor];
        }
    }
}
@end
