//
//  MovieItem.m
//  IKorean
//
//  Created by ruiwang on 16/9/13.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "MovieItem.h"


@implementation MovieItemModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end

@interface MovieItem ()

@property (nonatomic, strong) UIImageView *movieImageView;
@property (nonatomic, strong) UIImageView *movieFlagView;
@property (nonatomic, strong) UILabel *updateInfoLabel;
@property (nonatomic, strong) UILabel *movieTitleLabel;

@end

@implementation MovieItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews {
    // 影片图片
    CGRect movieImageViewFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 30);
    _movieImageView = [[UIImageView alloc] initWithFrame:movieImageViewFrame];
    _movieImageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:_movieImageView];
    
    // 右上角标识图片
    CGRect movieFlagViewFrame = CGRectMake(0, 0, CGRectGetWidth(movieImageViewFrame)/3.0f, CGRectGetWidth(movieImageViewFrame)/3.0f);
    _movieFlagView = [[UIImageView alloc] initWithFrame:movieFlagViewFrame];
    [_movieImageView addSubview:_movieFlagView];
    
    // 更新信息
    CGRect updateInfoLabelFrame = CGRectMake(5, CGRectGetHeight(movieImageViewFrame)-5-12, CGRectGetWidth(movieImageViewFrame)-10, 14);
    _updateInfoLabel = [[UILabel alloc] initWithFrame:updateInfoLabelFrame];
    _updateInfoLabel.font = [UIFont fontWithName:HYQiHei_50Pound size:12];
    _updateInfoLabel.textColor = [UIColor whiteColor];
    [_movieImageView addSubview:_updateInfoLabel];
    
    //影片名称
    CGRect movieTitleLabelFrame = CGRectMake(0, CGRectGetMaxY(movieImageViewFrame), self.frame.size.width, self.frame.size.height - CGRectGetHeight(movieImageViewFrame));
    _movieTitleLabel = [[UILabel alloc] initWithFrame:movieTitleLabelFrame];
    _movieTitleLabel.font = [UIFont fontWithName:HYQiHei_50Pound size:14];
    _movieTitleLabel.textColor = [UIColor blackColor];
    [self addSubview: _movieTitleLabel];
    
//    _movieImageView.backgroundColor = [UIColor blueColor];
    _movieFlagView.image = [UIImage imageNamed:@"红色角标"];
//    _updateInfoLabel.backgroundColor = [UIColor blackColor];
//    _movieTitleLabel.backgroundColor = [UIColor greenColor];
    
    CAGradientLayer * shadowEffectLayer = [CAGradientLayer layer];//渐变
    [shadowEffectLayer setFrame:CGRectMake(0, CGRectGetMaxY(movieImageViewFrame) - 20, self.frame.size.width, 20)];
    [shadowEffectLayer setStartPoint:CGPointMake(0.5, 1)];
    [shadowEffectLayer setEndPoint:CGPointMake(0.5, 0.0)];
    [shadowEffectLayer setColors:[NSArray arrayWithObjects:(id)[UIColor blackColor].CGColor, (id)[[UIColor clearColor] CGColor], nil]];
    [_movieImageView.layer insertSublayer:shadowEffectLayer atIndex:0];
}

- (void)setItemModel:(MovieItemModel *)itemModel {
    _itemModel = itemModel;
    
    [_movieImageView sd_setImageWithURL:[NSURL URLWithString:itemModel.img] placeholderImage:[UIImage imageNamed:@"占位图"]];
    _movieTitleLabel.text = itemModel.title;
    if (itemModel.episode_update == itemModel.episode_count) {
        _updateInfoLabel.text = @"已完结";
    }else {
        _updateInfoLabel.text = [NSString stringWithFormat:@"更新至%ld集",itemModel.episode_update];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_movieItemAction) {
        _movieItemAction(_itemModel);
    }
    NSLog(@"vid:%ld",_itemModel.vid);
}

@end
