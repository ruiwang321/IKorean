//
//  ICEPlayerEpisodeCollectionViewCell.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/13.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEPlayerEpisodeCollectionViewCell.h"
@interface ICEPlayerEpisodeCollectionViewCell ()
@property (nonatomic,strong) UILabel * episodeNumberLabel;
@end

@implementation ICEPlayerEpisodeCollectionViewCell
-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame])
    {
        [self setBackgroundColor:[ICEPlayerViewPublicDataHelper shareInstance].collectionViewCellColor];
    }
    return self;
}

-(void)updateCellWithModel:(ICEPlayerEpisodeModel *)model
{
    if (model)
    {
        if (_episodeNumberLabel==nil)
        {
            self.episodeNumberLabel=[[ICELabel alloc] initWithFrame:self.bounds];
            [_episodeNumberLabel setTextAlignment:NSTextAlignmentCenter];
            [_episodeNumberLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:15]];
            [self addSubview:_episodeNumberLabel];
        }
        [_episodeNumberLabel setText:model.episodeNumber];
        if (model.isPlay)
        {
            [_episodeNumberLabel setTextColor:[ICEPlayerViewPublicDataHelper shareInstance].playerViewControlColor];
        }
        else
        {
            [_episodeNumberLabel setTextColor:[UIColor whiteColor]];
        }
    }
}
@end
