//
//  EpisodeSortOptionsView.h
//  IKorean
//
//  Created by ruiwang on 16/9/18.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define heightOfFilterOptionsBar   36

typedef void (^SelectSomeFilterOptionBlock)(NSString * filterType,NSString * optionID);

@interface EpisodeSortOptionsView : UIView

-(id)initWithFrame:(CGRect)frame
              data:(NSArray *)data
selectSomeFilterOptionBlock:(SelectSomeFilterOptionBlock)selectSomeFilterOptionBlock;

@end
