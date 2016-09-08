//
//  UIImage+ColorImage.m
//  ICinema
//
//  Created by wangyunlong on 16/8/25.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "UIImage+ColorImage.h"

@implementation UIImage (ColorImage)
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
