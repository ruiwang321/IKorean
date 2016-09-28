//
//  ICELoadingView.h
//  ICinema
//
//  Created by wangyunlong on 16/6/14.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICELoadingView : UIView

@property (nonatomic,copy) NSString * loadingViewImageName;

-(void)startLoading;

-(void)stopLoading;

-(void)destroyLoading;
@end
