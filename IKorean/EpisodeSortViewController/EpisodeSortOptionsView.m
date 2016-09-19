//
//  EpisodeSortOptionsView.m
//  IKorean
//
//  Created by ruiwang on 16/9/18.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "EpisodeSortOptionsView.h"

////////////////////FilterOptionsItemModel///////////////
@interface FilterOptionsItemModel:NSObject

@property (nonatomic,copy) NSString * filterOptionID;
@property (nonatomic,copy) NSAttributedString * normalTitle;
@property (nonatomic,copy) NSAttributedString * selectTitle;

@end

@implementation FilterOptionsItemModel

@end

////////////////////FilterOptionsItem///////////////
@interface FilterOptionsItem:ICEButton
@property (nonatomic,strong) FilterOptionsItemModel * model;
@end

@implementation FilterOptionsItem
@end

////////////////////FilterOptionsBar////////////////
@interface FilterOptionsBar:UIView
{
    CALayer * m_selectItemShadowLayer;
    FilterOptionsItem * m_lastSelectItem;
}
@property (nonatomic,copy) SelectSomeFilterOptionBlock selectBlock;

@property (nonatomic,copy) NSString * type;

-(id)initWithFrame:(CGRect)frame
        filterType:(NSString *)filterType
              data:(NSArray *)datas
    selectedItemID:(NSString *)selectedItemID;

@end

@implementation FilterOptionsBar

-(id)initWithFrame:(CGRect)frame
        filterType:(NSString *)filterType
              data:(NSArray *)datas
    selectedItemID:(NSString *)selectedItemID
{
    if (self=[super initWithFrame:frame])
    {
        self.type=filterType;
        
        CGFloat filterOptionsBarWidth=CGRectGetWidth(frame);
        CGFloat filterOptionsBarHeight=CGRectGetHeight(frame);
        
        //滚动条
        CGRect scrollViewFrame=CGRectMake(6, 0, filterOptionsBarWidth-6-15, filterOptionsBarHeight);
        UIScrollView * scrollView=[[UIScrollView alloc] initWithFrame:scrollViewFrame];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:scrollView];
        
        NSInteger countOfItem=[datas count];
        CGFloat itemPadding=13;
        CGFloat itemHeight=24;
        CGFloat itemMinY=(filterOptionsBarHeight-itemHeight)/2;
        CGFloat lastItemMaxX=4;
        
        CGSize textBoundSize=CGSizeMake(1000, 100);
        
        NSDictionary * normalTitleAttributes=@{
                                               NSFontAttributeName:[UIFont fontWithName:HYQiHei_65Pound size:14],
                                               NSForegroundColorAttributeName:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1],
                                               };
        NSDictionary * selectTitleAttributes=@{
                                               NSFontAttributeName:[UIFont fontWithName:HYQiHei_65Pound size:14],
                                               NSForegroundColorAttributeName:[UIColor whiteColor],
                                               };
        
        NSStringDrawingOptions option = NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
        
        for (NSInteger Index=0; Index<countOfItem; Index++)
        {
            NSDictionary * dicOfItemData=datas[Index];
            NSString * filterOptionID=dicOfItemData[@"id"];
            NSString * titleString=dicOfItemData[@"title"];
            NSAttributedString * normalTitle=[[NSAttributedString alloc] initWithString:titleString
                                                                             attributes:normalTitleAttributes];
            
            NSAttributedString * selectTitle=[[NSAttributedString alloc]initWithString:titleString
                                                                            attributes:selectTitleAttributes];
            
            CGSize sizeOfTitle=[normalTitle boundingRectWithSize:textBoundSize
                                                         options:option
                                                         context:nil].size;
            CGFloat itemWidth=sizeOfTitle.width+20;
            
            CGRect frameOfItem=CGRectMake(lastItemMaxX+(Index?itemPadding:0),
                                          itemMinY,
                                          itemWidth,
                                          itemHeight);
            FilterOptionsItemModel * model=[[FilterOptionsItemModel alloc] init];
            model.filterOptionID=filterOptionID;
            model.normalTitle=normalTitle;
            model.selectTitle=selectTitle;
            
            FilterOptionsItem * item=[FilterOptionsItem buttonWithType:UIButtonTypeCustom];
            [item setModel:model];
            [item setFrame:frameOfItem];
            [item setAttributedTitle:normalTitle forState:UIControlStateNormal];
            [item addTarget:self action:@selector(selectSomeItem:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:item];
            
            lastItemMaxX=CGRectGetMaxX(frameOfItem);
            
            if (filterOptionID.integerValue == selectedItemID.integerValue)
            {
                [self selectSomeItem:item];
            }
        }
        
        CGSize contentSize=scrollView.contentSize;
        contentSize.width=lastItemMaxX+4;
        [scrollView setContentSize:contentSize];
        
        //添加表示更多的箭头
        if (contentSize.width>CGRectGetWidth(scrollViewFrame))
        {
            UIImage * imageOfArrow=IMAGENAME(@"arrow@2x", @"png");
            CGFloat arrowImageWidth=imageOfArrow.size.width;
            CGFloat arrowImageHeight=imageOfArrow.size.height;
            CGFloat arrowImageMinX=CGRectGetMaxX(scrollViewFrame)+1;
            CGFloat arrowImageMinY=(filterOptionsBarHeight-arrowImageHeight)/2;
            CGRect arrowImageFrame=CGRectMake(arrowImageMinX, arrowImageMinY, arrowImageWidth, arrowImageHeight);
            UIImageView * imageViewOfArrow=[[UIImageView alloc] initWithFrame:arrowImageFrame];
            [imageViewOfArrow setImage:imageOfArrow];
            [self addSubview:imageViewOfArrow];
        }
    }
    return self;
}

-(void)selectSomeItem:(FilterOptionsItem * )item
{
    if (m_lastSelectItem!=item)
    {
        [m_lastSelectItem setAttributedTitle:m_lastSelectItem.model.normalTitle forState:UIControlStateNormal];
        m_lastSelectItem=item;
        [m_lastSelectItem setAttributedTitle:m_lastSelectItem.model.selectTitle forState:UIControlStateNormal];
        
        if (m_selectItemShadowLayer==nil)
        {
            m_selectItemShadowLayer=[CALayer layer];
            [m_selectItemShadowLayer setBackgroundColor:[ICEAppHelper shareInstance].appPublicColor.CGColor];
            [m_selectItemShadowLayer setShadowColor:[ICEAppHelper shareInstance].appPublicColor.CGColor];
            [m_selectItemShadowLayer setCornerRadius:4];
            [m_selectItemShadowLayer setShadowOffset:CGSizeMake(0, 0.5)];
            [m_selectItemShadowLayer setShadowOpacity:0.8];
        }
        
        else if (_selectBlock)
        {
            _selectBlock(self.type,m_lastSelectItem.model.filterOptionID);
        }
        [m_lastSelectItem.superview.layer insertSublayer:m_selectItemShadowLayer below:m_lastSelectItem.layer];
        m_selectItemShadowLayer.frame=m_lastSelectItem.frame;
    }
}
@end

/////////////////////FilterOptionsView///////////////
@implementation EpisodeSortOptionsView

-(id)initWithFrame:(CGRect)frame
              data:(NSArray *)data
selectSomeFilterOptionBlock:(SelectSomeFilterOptionBlock)selectSomeFilterOptionBlock
{
    if (self=[super initWithFrame:frame])
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        NSInteger countOfBar = [data count]-1; // 减一是因为在最后加上了选中itemID参数
        CGRect frameOfBar=CGRectMake(0, 0, CGRectGetWidth(frame), heightOfFilterOptionsBar);
        
        for (NSInteger Index=0;Index<countOfBar;Index++)
        {
            NSDictionary * dicOfBarData=data[Index];
            CGRect frame=frameOfBar;
            frame.origin=CGPointMake(0, Index*heightOfFilterOptionsBar);
            //塞选条件总类型
            NSString * filterType=[[dicOfBarData allKeys] firstObject];
            //数据
            NSArray *  arrayOfOptionsDatas=dicOfBarData[filterType];
            //选中item id
            NSString *selectedItemID = data.lastObject[@"selected"][filterType];
            FilterOptionsBar * bar=[[FilterOptionsBar alloc] initWithFrame:frame
                                                                filterType:filterType
                                                                      data:arrayOfOptionsDatas
                                                            selectedItemID:selectedItemID];
            bar.selectBlock=selectSomeFilterOptionBlock;
            [self addSubview:bar];
        }
        
        //灰色阴影
        CAGradientLayer *shadow = [CAGradientLayer layer];//渐变
        [shadow setFrame:CGRectMake(0.0f, CGRectGetHeight(frame), CGRectGetWidth(frame), 2.5f)];
        [shadow setStartPoint:CGPointMake(0.5, 0.0)];
        [shadow setEndPoint:CGPointMake(0.5, 1)];
        [shadow setColors:[NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.2f] CGColor], (id)[[UIColor clearColor] CGColor], nil]];
        [self.layer addSublayer:shadow];
    }
    return self;
}
@end

