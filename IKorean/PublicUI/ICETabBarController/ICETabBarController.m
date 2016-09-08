//
//  ICETabBarController.m
//  ICinema
//
//  Created by wangyunlong on 16/6/7.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICETabBarController.h"
#import "ICEViewController.h"
@implementation ICETabBarItemModel

@end
//////////////////////////////////////////////////
@class ICETabBarItem;
typedef  void (^TabBarItemSelectBlock)(ICETabBarItem * item);
@interface ICETabBarItem:UIView

@property (nonatomic,strong) UILabel * tabBarItemTitleLabel;
@property (nonatomic,strong) UIImageView * tabBarItemImageView;
@property (nonatomic,strong) UIColor * titleNormalColor;
@property (nonatomic,strong) UIColor * titleSelectedColor;
@property (nonatomic,copy) TabBarItemSelectBlock selectBlock;

-(id)initWithFrame:(CGRect)frame
         itemModel:(ICETabBarItemModel *)tabBarItemModel
       selectBlock:(TabBarItemSelectBlock)block;

-(void)isSelected:(BOOL)isSelected;
@end


@implementation ICETabBarItem

-(id)initWithFrame:(CGRect)frame
         itemModel:(ICETabBarItemModel *)tabBarItemModel
       selectBlock:(TabBarItemSelectBlock)block
{
    if (self=[super initWithFrame:frame])
    {
        self.selectBlock=block;
        self.titleNormalColor=[[UIColor alloc] initWithRed:117.0f/255.0f green:117.0f/255.0f blue:117.0f/255.0f alpha:1];
        self.titleSelectedColor=[[UIColor alloc] initWithRed:36.0f/255.0f green:175.0f/255.0f blue:255.0f/255.0f alpha:1];
        CGFloat tabBarItemWidth=CGRectGetWidth(frame);
        CGFloat tabBarItemHeight=CGRectGetHeight(frame);
        CGFloat tabBarItemTitleLabelHeight=12;
        CGFloat titleToBottomPadding=5;

        ICEButton * button=[ICEButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:self.bounds];
        [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        CGRect  tabBarItemTitleLabelFrame=CGRectMake(0,
                                                     tabBarItemHeight-titleToBottomPadding-tabBarItemTitleLabelHeight,
                                                     tabBarItemWidth,
                                                     tabBarItemTitleLabelHeight);
        self.tabBarItemTitleLabel=[[UILabel alloc] initWithFrame:tabBarItemTitleLabelFrame];

        [_tabBarItemTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [_tabBarItemTitleLabel setTextColor:_titleNormalColor];
        [_tabBarItemTitleLabel setText:tabBarItemModel.title];
        [_tabBarItemTitleLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:tabBarItemTitleLabelHeight]];
        [self addSubview:_tabBarItemTitleLabel];
        
        UIImage * tabBarItemNormalImage=IMAGENAME(tabBarItemModel.normalStateImage, @"png");
        UIImage * tabBarItemSelectedImage=IMAGENAME(tabBarItemModel.selectedStateImage, @"png");
        CGFloat tabBarItemImageWidth=tabBarItemNormalImage.size.width;
        CGFloat tabBarItemImageHeight=tabBarItemNormalImage.size.height;
        CGRect  tabBarItemImageFrame=CGRectMake((tabBarItemWidth-tabBarItemImageWidth)/2,
                                                CGRectGetMinY(tabBarItemTitleLabelFrame)-tabBarItemImageHeight,
                                                tabBarItemImageWidth,
                                                tabBarItemImageHeight);
        self.tabBarItemImageView=[[UIImageView alloc] initWithImage:tabBarItemNormalImage highlightedImage:tabBarItemSelectedImage];
        [_tabBarItemImageView setFrame:tabBarItemImageFrame];
        [self addSubview:_tabBarItemImageView];
        
    }
    return self;
}

-(void)isSelected:(BOOL)isSelected
{
    if (isSelected)
    {
        [_tabBarItemTitleLabel setTextColor:_titleSelectedColor];
        [_tabBarItemImageView setHighlighted:TRUE];
    }
    else
    {
        [_tabBarItemTitleLabel setTextColor:_titleNormalColor];
        [_tabBarItemImageView setHighlighted:FALSE];
    }
}

-(void)buttonAction
{
    _selectBlock(self);
}
@end
//////////////////////////////////////////////////////////
@interface ICETabBar ()

@property (nonatomic,assign) ICETabBarItem * currentSelectedItem;
@property (nonatomic,assign) CGFloat tabBarWidth;
@property (nonatomic,assign) CGFloat tabBarHeight;
@property (nonatomic,strong) NSMutableArray * tabBarItemsArray;
@property (nonatomic,copy) void (^SelectSomeItemBlock)(NSInteger selectIndex);

-(void)setSelectedIndex:(NSUInteger)selectedIndex;

@end

@implementation ICETabBar

-(void)dealloc
{
    self.currentSelectedItem=nil;
}

-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame])
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        _tabBarWidth=CGRectGetWidth(frame);
        _tabBarHeight=CGRectGetHeight(frame);
        self.tabBarItemsArray=[[NSMutableArray alloc] init];
        
        CGRect grayLineFrame=CGRectMake(0, -0.5, _tabBarWidth, 0.5);
        UIView * grayLineView = [[UIView alloc] initWithFrame:grayLineFrame];
        [grayLineView setBackgroundColor:[UIColor colorWithRed:212.0f/255.0f green:212.0f/255.0f blue:212.0f/255.0f alpha:1]];
        [self addSubview:grayLineView];
    }
    return self;
}

-(void)setTabBarWithItemModels:(NSArray *)itemModels
{
    for (ICETabBarItem * item in _tabBarItemsArray)
    {
        [item removeFromSuperview];
    }
    [_tabBarItemsArray removeAllObjects];
    
    __weak typeof(self) wself=self;
    TabBarItemSelectBlock block=^(ICETabBarItem * item)
    {
        NSInteger selectItemIndex=[wself.tabBarItemsArray indexOfObject:item];
        if (selectItemIndex!=NSNotFound)
        {
            if (wself.SelectSomeItemBlock) {
                wself.SelectSomeItemBlock(selectItemIndex);
            }
        }
    };
    
    NSInteger itemModelsCount=[itemModels count];
    CGFloat   tabBarItemWidth=_tabBarWidth/itemModelsCount;
    
    CGRect tabBarItemBaseFrame=CGRectMake(0, 0, tabBarItemWidth, _tabBarHeight);
    for (NSInteger Index=0; Index<itemModelsCount; Index++)
    {
        CGRect tabBarItemFrame=tabBarItemBaseFrame;
        tabBarItemFrame.origin.x=Index*tabBarItemWidth;

        ICETabBarItem * tabBarItem = [[ICETabBarItem alloc]initWithFrame:tabBarItemFrame
                                                               itemModel:itemModels[Index]
                                                             selectBlock:block];
        [self addSubview:tabBarItem];
        [_tabBarItemsArray addObject:tabBarItem];
    }
}

-(void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [_currentSelectedItem isSelected:FALSE];
    _currentSelectedItem=_tabBarItemsArray[selectedIndex];
    [_currentSelectedItem isSelected:TRUE];
}


@end
//////////////////////////////////////////////////////////
@interface ICETabBarController ()
@property (nonatomic,strong,readwrite) ICETabBar * myTabBar;
@end

@implementation ICETabBarController
- (void)addTabBarWithItemModels:(NSArray *)itemModels
{
    if (_myTabBar==nil)
    {
        [self.tabBar setHidden:YES];
        CGFloat tabBarWidth=CGRectGetWidth(self.view.frame);
        CGFloat tabBarHeight=55;
        CGFloat tabBarMinY=CGRectGetHeight(self.view.frame)-tabBarHeight;

        CGRect  tabBarFrame=CGRectMake(0, tabBarMinY, tabBarWidth, tabBarHeight);
        __weak typeof(self) wself=self;
        self.myTabBar=[[ICETabBar alloc] initWithFrame:tabBarFrame];
        _myTabBar.SelectSomeItemBlock=^(NSInteger selectIndex)
        {
            [wself setSelectedIndex:selectIndex];
            [wself mobEventSelectedIndex:selectIndex];
        };
        [self.view addSubview:_myTabBar];
    }
    [_myTabBar setTabBarWithItemModels:itemModels];
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers
{
    NSMutableArray * tabBarItemModelsArray=[NSMutableArray array];
    for (ICEViewController * vc in viewControllers) {
        [tabBarItemModelsArray addObject:vc.tabBarItemModel];
    }
    [self addTabBarWithItemModels:tabBarItemModelsArray];
    [super setViewControllers:viewControllers];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    [_myTabBar setSelectedIndex:selectedIndex];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)mobEventSelectedIndex:(NSInteger)selectIndex
{
    NSString * eventID=nil;
    if (0==selectIndex)
    {
        eventID=@"9";
    }
    else if (1==selectIndex)
    {
        eventID=@"10";
    }
    else if (2==selectIndex)
    {
        eventID=@"28";
    }
    else if (3==selectIndex)
    {
        eventID=@"29";
    }
    if (eventID)
    {
        [MobClick event:eventID];
    }
}
@end
