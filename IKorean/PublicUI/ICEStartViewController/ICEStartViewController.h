//
//  ICEStartViewController.h
//  ICinema
//
//  Created by wangyunlong on 16/6/27.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^LoadingDataCompletedBlock)();

@interface ICEStartViewController : UIViewController
@property (nonatomic,copy) LoadingDataCompletedBlock loadingDataCompletedBlock;
@end
