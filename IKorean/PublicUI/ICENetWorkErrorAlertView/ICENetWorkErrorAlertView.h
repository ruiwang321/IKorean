//
//  ICENetWorkErrorAlertView.h
//  ICinema
//
//  Created by yunlongwang on 16/8/14.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ICENetWorkErrorAlertView : UIView

-(id)initWithFrame:(CGRect)frame
    alertImageName:(NSString*)imageName
netWorkErrorAlertBlock:(void (^)())netWorkErrorAlertBlock;

@end
