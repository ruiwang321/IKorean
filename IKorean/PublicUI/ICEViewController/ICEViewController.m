//
//  ICEViewController.m
//  ICinema
//
//  Created by wangyunlong on 16/6/7.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEViewController.h"
#import "ICELoadingView.h"
#import "ICENetWorkErrorAlertView.h"
/////////////////////TitleUnitView/////////////////////
@interface TitleUnitView:UIView

@property (nonatomic,strong) UILabel * firstTitleLabel;
@property (nonatomic,strong) UILabel * secondTitleLabel;
@property (nonatomic,assign) NSStringDrawingOptions titleOption;
@property (nonatomic,strong) NSDictionary * titleAttributes;
@property (nonatomic,assign) CGFloat labelPadding;
@property (nonatomic,assign) CGFloat titleUnitViewWidth;
@property (nonatomic,assign) CGFloat titleUnitViewHeight;
@property (nonatomic,assign) CGRect  titleBoundingSize;
@property (nonatomic,strong) NSTimer * timer;
@property (nonatomic,assign) NSTimeInterval timerTimeInterval;
@property (nonatomic,assign) BOOL isNeedScroll;

@end

@implementation TitleUnitView

-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame])
    {
        [self setClipsToBounds:YES];
        
        _labelPadding=20;
        _titleUnitViewWidth=CGRectGetWidth(frame);
        _titleUnitViewHeight=CGRectGetHeight(frame);
        _timerTimeInterval=0.03;
        _isNeedScroll=NO;
        NSMutableParagraphStyle * titleParagraphStyle=[[NSMutableParagraphStyle alloc]init];
        titleParagraphStyle.alignment = NSTextAlignmentCenter;
        
        self.titleAttributes=[[NSDictionary alloc] initWithObjectsAndKeys:
                              [UIFont fontWithName:HYQiHei_55Pound size:20],NSFontAttributeName,
                              [UIColor whiteColor],NSForegroundColorAttributeName,
                              titleParagraphStyle,NSParagraphStyleAttributeName, nil];
    
        _titleOption = NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
    }
    return self;
}

-(void)setTitle:(NSString *)title
{
    [self stopScrollWithIsDestroy:NO];
    
    if (title)
    {
        if (_firstTitleLabel==nil)
        {
            self.firstTitleLabel=[[UILabel alloc] init];
            [self addSubview:_firstTitleLabel];
        }
        
        NSAttributedString * titleAttributedString=[[NSAttributedString alloc] initWithString:title attributes:_titleAttributes];
        CGSize  titleSize=[titleAttributedString boundingRectWithSize:CGSizeMake(10000, _titleUnitViewHeight) options:_titleOption context:nil].size;
        CGFloat titleWidth=titleSize.width;
        if (titleWidth<=_titleUnitViewWidth)
        {
            _isNeedScroll=NO;
            
            CGRect firstTitleLabelFrame=self.bounds;
            [_firstTitleLabel setFrame:firstTitleLabelFrame];
            [_firstTitleLabel setAttributedText:titleAttributedString];
        }
        else
        {
            _isNeedScroll=YES;
            
            CGRect firstTitleLabelFrame=self.bounds;
            firstTitleLabelFrame.size.width=titleWidth;
            [_firstTitleLabel setFrame:firstTitleLabelFrame];
            [_firstTitleLabel setAttributedText:titleAttributedString];
            
            CGRect secondTitleLabelFrame=firstTitleLabelFrame;
            secondTitleLabelFrame.origin.x=CGRectGetMaxX(firstTitleLabelFrame)+_labelPadding;
            if (_secondTitleLabel==nil)
            {
                self.secondTitleLabel=[[UILabel alloc] init];
                [self addSubview:_secondTitleLabel];
            }
            [_secondTitleLabel setFrame:secondTitleLabelFrame];
            [_secondTitleLabel setAttributedText:titleAttributedString];
            
            //打开定时器
            [self startScroll];
        }
    }
}

-(void)startScroll
{
    if (_isNeedScroll)
    {
        if (_timer==nil)
        {
            self.timer=[NSTimer  timerWithTimeInterval:_timerTimeInterval
                                                target:self
                                              selector:@selector(scrollLabel)
                                              userInfo:nil
                                               repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_timer
                                         forMode:NSRunLoopCommonModes];
            [_timer fire];
        }
        else
        {
            [_timer setFireDate:[NSDate distantPast]];
        }
    }
    
}

-(void)stopScrollWithIsDestroy:(BOOL)isDestroy
{
    if (_timer&&[_timer isValid])
    {
        if (isDestroy)
        {
            [_timer invalidate];
            self.timer=nil;
        }
        else
        {
            [_timer setFireDate:[NSDate distantFuture]];
        }
    }
}

-(void)scrollLabel
{
    CGRect firstTitleLabelFrame=_firstTitleLabel.frame;
    CGRect secondTitleLabelFrame=_secondTitleLabel.frame;
    
    firstTitleLabelFrame.origin.x-=1;
    secondTitleLabelFrame.origin.x-=1;
    
    CGFloat firstLabelMaxX=CGRectGetMaxX(firstTitleLabelFrame);
    CGFloat secondLabelMaxX=CGRectGetMaxX(secondTitleLabelFrame);
    if (firstLabelMaxX<=0)
    {
        firstTitleLabelFrame.origin.x=secondLabelMaxX+_labelPadding;
    }
    
    if (secondLabelMaxX<=0)
    {
        secondTitleLabelFrame.origin.x=firstLabelMaxX+_labelPadding;
    }
    
    _firstTitleLabel.frame=firstTitleLabelFrame;
    _secondTitleLabel.frame=secondTitleLabelFrame;
}

@end

///////////////////ICEViewController/////////////////////
@interface ICEViewController ()

@property (nonatomic,strong,readwrite) ICETabBarItemModel * tabBarItemModel;
@property (nonatomic,assign,readwrite) CGFloat screenWidth;
@property (nonatomic,assign,readwrite) CGFloat screenHeight;
@property (nonatomic,assign) CGFloat statusBarHeight;
@property (nonatomic,assign) CGFloat systemNavigationBarHeight;
@property (nonatomic,assign,readwrite) CGFloat navigationBarHeight;
@property (nonatomic,strong,readwrite) UIView * myNavigationBar;
@property (nonatomic,strong) ICEButton * leftButton;
@property (nonatomic,strong) ICEButton * rightButton;
@property (nonatomic,assign) CGFloat buttonMaxX;
@property (nonatomic,assign) CGFloat buttonMinX;
@property (nonatomic,assign) CGFloat buttonMaxWidth;
@property (nonatomic,assign) CGFloat titleUnitViewMinX;
@property (nonatomic,strong) TitleUnitView  * titleUnitView;
@property (nonatomic,strong) ICELoadingView * loadingView;
@property (nonatomic,strong) ICENetWorkErrorAlertView * netWorkErrorAlertView;

@end

@implementation ICEViewController
-(id)init
{
    if (self=[super init])
    {
        CGSize screenSize=[[UIScreen mainScreen] bounds].size;
        _screenWidth=screenSize.width;
        _screenHeight=screenSize.height;
        _statusBarHeight=20;
        _systemNavigationBarHeight=44;
        _buttonMinX=7;
        _buttonMaxX=50;
        _buttonMaxWidth=_buttonMaxX-_buttonMinX;
        _titleUnitViewMinX=_buttonMaxX+5;
        _navigationBarHeight=_statusBarHeight+_systemNavigationBarHeight;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

-(void)setTabBarItemWithTitle:(NSString *)title
              normalImageName:(NSString *)normalImageName
            selectedImageName:(NSString *)selectedImageName
{
    if (_tabBarItemModel==nil)
    {
        self.tabBarItemModel=[[ICETabBarItemModel alloc] init];
    }
    _tabBarItemModel.title=title;
    _tabBarItemModel.normalStateImage=normalImageName;
    _tabBarItemModel.selectedStateImage=selectedImageName;
}

- (void)addNavigationBar
{
    CGRect navigationBarFrame=CGRectMake(0, 0, _screenWidth, _navigationBarHeight);
    self.myNavigationBar=[[UIView alloc] initWithFrame: navigationBarFrame];
    [_myNavigationBar setBackgroundColor:[ICEAppHelper shareInstance].appPublicColor];
    [self.view addSubview:_myNavigationBar];
    
    CGRect grayLineFrame=CGRectMake(0, _navigationBarHeight, _screenWidth, 1);
    UIView * grayLine=[[UIView alloc] initWithFrame:grayLineFrame];
    [grayLine setBackgroundColor:[UIColor colorWithRed:225.0f/255.0f green:225.0f/255.0f blue:225.0f/255.0f alpha:1.0f]];
    [_myNavigationBar addSubview:grayLine];
}

- (void)setTitle:(NSString *)title
{
    if (_myNavigationBar)
    {
        if (_titleUnitView==nil)
        {
            //标题
            CGRect titileUnitViewFrame=CGRectMake(_titleUnitViewMinX, _statusBarHeight, _screenWidth-2*_titleUnitViewMinX, _systemNavigationBarHeight);
            self.titleUnitView=[[TitleUnitView alloc] initWithFrame:titileUnitViewFrame];
            [_myNavigationBar addSubview:_titleUnitView];
        }
        if (title)
        {
            [_titleUnitView setTitle:title];
        }
    }
    else
    {
        [super setTitle:title];
    }
}

-(void)setLeftButtonWithImageName:(NSString *)imageName
                           action:(SEL)action
{
    if (_myNavigationBar)
    {
        if (_leftButton==nil)
        {
            //左侧button
            UIImage * leftButtonImage=IMAGENAME(imageName,@"png");
            CGFloat leftButtonImageWidth=leftButtonImage.size.width;
            CGRect  leftButtonFrame=CGRectMake(_buttonMinX,_statusBarHeight, _buttonMaxWidth, _systemNavigationBarHeight);
            CGFloat imagePaddingH=_buttonMaxWidth-leftButtonImageWidth;
            UIEdgeInsets imageEdgeInsets=UIEdgeInsetsMake(0, -imagePaddingH, 0,0);
            
            self.leftButton=[ICEButton buttonWithType:UIButtonTypeCustom];
            [_leftButton setFrame:leftButtonFrame];
            [_leftButton setImage:leftButtonImage forState:UIControlStateNormal];
            [_leftButton setImageEdgeInsets:imageEdgeInsets];
            [_myNavigationBar addSubview:_leftButton];

            if (action)
            {
                [_leftButton addTarget:self
                                action:action
                      forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

-(void)setRightButtonWithImageName:(NSString *)imageName
                            action:(SEL)action
{
    if (_myNavigationBar)
    {
        if (_rightButton==nil)
        {
            //右侧button
            UIImage * rightButtonImage=IMAGENAME(imageName,@"png");
            CGFloat rightButtonImageWidth=rightButtonImage.size.width;
            CGRect  rightButtonFrame=CGRectMake(_screenWidth-_buttonMinX-_buttonMaxWidth,
                                                _statusBarHeight,
                                                _buttonMaxWidth,
                                                _systemNavigationBarHeight);
            CGFloat imagePaddingH=_buttonMaxWidth-rightButtonImageWidth;
            UIEdgeInsets imageEdgeInsets=UIEdgeInsetsMake(0, imagePaddingH, 0,0);
            
            self.rightButton=[ICEButton buttonWithType:UIButtonTypeCustom];
            [_rightButton setFrame:rightButtonFrame];
            [_rightButton setImage:rightButtonImage forState:UIControlStateNormal];
            [_rightButton setImageEdgeInsets:imageEdgeInsets];
            [_myNavigationBar addSubview:_rightButton];

            if (action)
            {
                [_rightButton addTarget:self
                                 action:action
                       forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

-(void)showNetErrorAlert
{
    if (_netWorkErrorAlertView==nil)
    {
        __weak typeof(self) wself=self;
        CGRect netWorkErrorAlertViewFrame=CGRectMake(0, 0, _screenWidth, _screenHeight);
        self.netWorkErrorAlertView=[[ICENetWorkErrorAlertView alloc] initWithFrame:netWorkErrorAlertViewFrame
                                                                    alertImageName:@"bg_noNetwork@2x"
                                                            netWorkErrorAlertBlock:^{
                                                                [wself sendRequestAgain];
                                                            }];
        
        [self.view insertSubview:_netWorkErrorAlertView belowSubview:_myNavigationBar];
    }
    [_netWorkErrorAlertView setHidden:NO];
}

-(void)hideNetErrorAlert
{
    [_netWorkErrorAlertView setHidden:YES];
}

-(void)sendRequestAgain
{
    NSLog(@"子类应复写该方法");
}

-(void)startLoading
{
    if (_loadingView==nil)
    {
        self.loadingView=[[ICELoadingView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_loadingView];
    }
    [self.view bringSubviewToFront:_loadingView];
    [_loadingView startLoading];
}

-(void)stopLoading
{
    [_loadingView stopLoading];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1]];
    [self addNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_titleUnitView startScroll];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_loadingView destroyLoading];
    [_titleUnitView stopScrollWithIsDestroy:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)isSupportSlidePop {
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
