//
//  ICEPlayerEpisodeModel.h
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/2.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICEPlayerEpisodeModel : NSObject
@property (nonatomic,copy) NSString * videoID;
@property (nonatomic,copy) NSString * title;
@property (nonatomic,copy) NSString * url;
@property (nonatomic,assign) NSTimeInterval lastPlaySeconds;
@end
