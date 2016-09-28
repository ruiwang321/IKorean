//
//  GetVideoURLHelper.h
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/6.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^GetVideoURLFinishBlock)(NSString * videoURLString);

@interface GetVideoURLHelper : NSObject

@property (nonatomic,copy) GetVideoURLFinishBlock getVideoURLFinishBlock;

+(GetVideoURLHelper *)shareInstance;

-(void)getVideoURLWithVideoID:(NSString *)videoID;

//-(void)stopLoad;

@end
