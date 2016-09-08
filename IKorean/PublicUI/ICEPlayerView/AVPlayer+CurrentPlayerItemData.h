//
//  AVPlayer+CurrentPlayerItemData.h
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/3.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVPlayer (CurrentPlayerItemData)

-(NSTimeInterval)currentItemTotalSeconds;

-(NSTimeInterval)currentItemCurrentSeconds;

-(NSTimeInterval)currentItemLoadSeconds;

-(BOOL)currentItemIsValid;
@end
