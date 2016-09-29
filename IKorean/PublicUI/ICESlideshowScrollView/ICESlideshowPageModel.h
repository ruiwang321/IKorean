//
//  ICESlideshowPageModel.h
//  ICinema
//
//  Created by wangyunlong on 16/6/12.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICESlideshowPageModel : NSObject
@property (nonatomic,copy) NSString * img;
@property (nonatomic,assign) NSInteger video_id;
@property (nonatomic,copy) NSString * title;
@property (nonatomic,assign) NSInteger type;
@property (nonatomic,copy) NSString * link;
@property (nonatomic,copy) NSString * video;
@end
