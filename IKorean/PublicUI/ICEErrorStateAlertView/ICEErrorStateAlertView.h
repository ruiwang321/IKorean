//
//  ICEErrorStateAlertView.h
//  ICinema
//
//  Created by wangyunlong on 16/9/24.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICEErrorStateAlertView : UIView
-(id)initWithFrame:(CGRect)frame
    alertImageName:(NSString*)imageName
           message:(NSString *)message
        clickBlock:(void (^)())clickBlock;
@end
