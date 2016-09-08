//
//  ICESlideshowPageView.h
//  GreatCar
//
//  Created by wangyunlong on 16/1/27.
//  Copyright © 2016年 yunlongwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICESlideshowPageModel.h"
typedef void (^SelectPageBlock)(ICESlideshowPageModel * pageModel);
@interface ICESlideshowPageView : UIView

@property (nonatomic,copy) SelectPageBlock selectPageBlock;
@property (nonatomic,strong,readonly) ICESlideshowPageModel * pageModel;

-(id)initWithFrame:(CGRect)frame placeholderImageName:(NSString *)imageName;

-(void)setSlideshowPageWithPageModel:(ICESlideshowPageModel *)pageModel;
@end
