//
//  ICENavigationController.m
//  ICinema
//
//  Created by wangyunlong on 16/6/12.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICENavigationController.h"

@interface ICENavigationController ()

@end

@implementation ICENavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationBar setHidden:YES];
}

-(BOOL)shouldAutorotate{
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];;
}
@end
