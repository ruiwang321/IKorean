//
//  JPushModel.h
//  ICinema
//
//  Created by wangyunlong on 16/8/5.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPushModel : NSObject
@property (nonatomic,assign) NSInteger movieID;
@property (nonatomic,copy)   NSString * movieTitle;
@property (nonatomic,assign) BOOL isReceivePushInBackGround;
@end
