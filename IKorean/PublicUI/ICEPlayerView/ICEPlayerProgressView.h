//
//  ICEPlayerProgressView.h
//  TestVFLProject
//
//  Created by wangyunlong on 16/8/25.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ICEPlayerProgressViewActionOptions) {
    PlayerProgressViewUpdateBegan,
    PlayerProgressViewGoForward,
    PlayerProgressViewGoReverse,
    PlayerProgressViewUpdateEnd
};

@interface ICEPlayerProgressView : UIView


-(id)initWithProgressViewWidth:(CGFloat)playerProgressViewWidth;

-(void)addToSuperViewAndaddConstraintsWithSuperView:(UIView *)superView;

-(void)reloadWithCurrentSeconds:(NSTimeInterval)currentSeconds
                   totalSeconds:(NSTimeInterval)totalSeconds;

-(void)updateProgressWithChangeSeconds:(NSTimeInterval)changeSeconds
                         actionOptions:(ICEPlayerProgressViewActionOptions)actionOptions
                        updatedSeconds:(NSTimeInterval *)updatedSeconds;

-(void)updateProgressWithDesiredSeconds:(NSTimeInterval)desiredSeconds
                          actionOptions:(ICEPlayerProgressViewActionOptions)actionOptions;

@end
