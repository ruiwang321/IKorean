//
//  MovieEpisodeModel.m
//  ICinema
//
//  Created by wangyunlong on 16/9/27.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "MovieEpisodeModel.h"

@implementation MovieEpisodeModel
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"])
    {
        self.videoID=[NSString stringWithFormat:@"%@",value];
    }
    else if([key isEqualToString:@"is_new"])
    {
        self.isNew=[value boolValue];
    }
}
@end
