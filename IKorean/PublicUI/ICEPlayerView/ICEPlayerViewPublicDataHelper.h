//
//  ICEPlayerViewPublicDataHelper.h
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/13.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICEPlayerViewPublicDataHelper : NSObject
@property (nonatomic,strong,readonly) UIColor * playerViewPublicColor;
@property (nonatomic,strong,readonly) UIColor * playerViewControlColor;
@property (nonatomic,strong,readonly) UIColor * playerViewBorderColor;
@property (nonatomic,strong,readonly) UIColor * collectionViewCellColor;
+(ICEPlayerViewPublicDataHelper *)shareInstance;
@end
