//
//  DateListItem.m
//  IKorean
//
//  Created by ruiwang on 16/9/14.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "DateListItem.h"

static NSInteger const oneDay = 86400;
@interface DateListItem ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom;

@end

@implementation DateListItem

- (void)showDate:(NSDate *)date withIsSelected:(BOOL)selected {
    
    [self layoutIfNeeded];
    _containerView.layer.cornerRadius = _containerView.bounds.size.width/2.0f;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM月dd";
    _dateLabel.text = [formatter stringFromDate:date];
    NSArray *weekday = [NSArray arrayWithObjects: [NSNull null], @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    
    NSString *weekStr = [weekday objectAtIndex:components.weekday];
    
    if (selected) {
        _containerView.backgroundColor = APPColor;
        _containerView.transform = CGAffineTransformMakeScale(0.7, 0.7);
        _weekLabel.textColor = [UIColor whiteColor];
        _dateLabel.textColor = [UIColor whiteColor];
        if (date.timeIntervalSinceNow<oneDay && date.timeIntervalSinceNow>=0) {
            _weekLabel.text = @"今天";
        }else {
            _weekLabel.text = weekStr;
        }
    }else {
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.transform = CGAffineTransformMakeScale(1, 1);
        if (date.timeIntervalSinceNow<oneDay && date.timeIntervalSinceNow>=0) {
            _weekLabel.text = @"今天";
            _weekLabel.textColor = APPColor;
            _dateLabel.textColor = APPColor;
        }else {
            _weekLabel.text = weekStr;
            _weekLabel.textColor = [UIColor colorWithRed:106/255.0f green:106/255.0f blue:106/255.0f alpha:1];
            _dateLabel.textColor = [UIColor colorWithRed:160/255.0f green:160/255.0f blue:160/255.0f alpha:1];
        }
    }
    
}



- (void)awakeFromNib {
    [super awakeFromNib];

}

@end
