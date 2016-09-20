//
//  ICESlideBackNavigationController.m
//  PlayerViewDemo
//
//  Created by wangyunlong on 16/9/20.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICESlideBackNavigationController.h"
#import <objc/message.h>
#import <objc/runtime.h>

#define ICESlideReturnNavigationControllerSnapshotPath                 @"/Library/Caches/PopSnapshots"
@interface ICESnapshotImageView:UIImageView
{
    NSMutableString * m_snapshotImagePath;
}

-(void)setSnapshotImagePath:(NSString *)snapshotImagePath;
-(NSString *)snapshotImagePath;
@end

@implementation ICESnapshotImageView
-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        m_snapshotImagePath=[[NSMutableString alloc] initWithString:@""];
    }
    return self;
}

-(void)setSnapshotImagePath:(NSString *)snapshotImagePath
{
    [m_snapshotImagePath setString:snapshotImagePath];
}

-(NSString *)snapshotImagePath
{
    return m_snapshotImagePath;
}

@end

@interface ICESlideBackNavigationController ()
<
UIGestureRecognizerDelegate
>
@property (nonatomic,assign) BOOL isSaveSnapshotEnd;
@property (nonatomic,assign) CGFloat navViewWidth;
@property (nonatomic,assign) CGFloat navViewHeight;
@property (nonatomic,assign) CGFloat navViewShowMinX;
@property (nonatomic,assign) CGFloat navViewHideMinX;
@property (nonatomic,assign) CGFloat snapshotImageViewShowMinX;
@property (nonatomic,assign) CGFloat snapshotImageViewHideMinX;
@property (nonatomic,assign) CGFloat snapshotImageViewDistanceToScreen;
@property (nonatomic,assign) CGFloat minTriggerPopDinstance;
@property (nonatomic,copy)   NSString * snapshotFolderPath;
@property (nonatomic,strong) dispatch_queue_t myqueue;
@property (nonatomic,strong) ICESnapshotImageView * snapshotImageView;
@property (nonatomic,assign) BOOL isTouchScreenNow;
@end

@implementation ICESlideBackNavigationController

+(void)clearAllSnapshot
{
    NSString * slideReturnNavigationControllerSnapshotPath=[NSHomeDirectory() stringByAppendingString:ICESlideReturnNavigationControllerSnapshotPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:slideReturnNavigationControllerSnapshotPath isDirectory:NULL])
    {
        [[NSFileManager defaultManager] removeItemAtPath:slideReturnNavigationControllerSnapshotPath error:nil];
    }
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    if (self=[super initWithRootViewController:rootViewController])
    {
        //隐藏系统的navigationBar
        [self.navigationBar setHidden:YES];
        //禁用ios7后自带的按住屏幕左侧边缘右滑返回
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
        {
            self.interactivePopGestureRecognizer.enabled = NO;
        }
        self.myqueue=dispatch_queue_create("com.wangyunlong.myqueue", DISPATCH_QUEUE_CONCURRENT);
        self.snapshotFolderPath=[NSHomeDirectory() stringByAppendingString:ICESlideReturnNavigationControllerSnapshotPath];
        _isSaveSnapshotEnd=NO;
        _isTouchScreenNow=NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect  navViewFrame=self.view.frame;
    CGFloat navViewOrigWidth=375;
    CGFloat minTriggerPopOrigDinstance=120;
    _navViewWidth=CGRectGetWidth(navViewFrame);
    _navViewHeight=CGRectGetHeight(navViewFrame);
    NSAssert(_navViewWidth<=_navViewHeight, @"滑动返回只支持竖屏，抱歉");
    _minTriggerPopDinstance=minTriggerPopOrigDinstance/navViewOrigWidth*_navViewWidth;
    _navViewHideMinX=_navViewWidth;
    _navViewShowMinX=0;
    _snapshotImageViewDistanceToScreen=_navViewWidth/4;
    _snapshotImageViewHideMinX=-_snapshotImageViewDistanceToScreen;
    _snapshotImageViewShowMinX=0;
    
    //快照
    CGRect snapshotImageViewFrame=navViewFrame;
    snapshotImageViewFrame.origin.x=_snapshotImageViewHideMinX;
    self.snapshotImageView=[[ICESnapshotImageView alloc] initWithFrame:snapshotImageViewFrame];
    [_snapshotImageView setHidden:YES];

    //左侧阴影
    CAGradientLayer * gradientLayer = [CAGradientLayer layer];
    [gradientLayer setFrame:CGRectMake(-10, 0, 10, _navViewHeight)];
    [gradientLayer setStartPoint:CGPointMake(1.0, 0.5)];
    [gradientLayer setEndPoint:CGPointMake(0, 0.5)];
    [gradientLayer setColors:@[(id)[[[UIColor blackColor]colorWithAlphaComponent:0.3] CGColor],
                               (id)[[UIColor clearColor] CGColor]]];
    [self.view.layer addSublayer:gradientLayer];
    
    //添加手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [panGestureRecognizer setDelegate:self];
    [panGestureRecognizer setMinimumNumberOfTouches:1];
    [panGestureRecognizer setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:panGestureRecognizer];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self.viewControllers count])
    {
        _isSaveSnapshotEnd=NO;
        __weak typeof(self) wself=self;
        UIWindow * snapshotWindow=[[UIApplication sharedApplication] keyWindow];
        UIImage  * snapshotImage=[self snapshotImageForViewController:snapshotWindow.rootViewController];
        NSString * snapshotImagePath=[self snapshotImagePathForViewController:viewController];
        dispatch_async(_myqueue, ^{
            [wself saveSnapshotImage:snapshotImage snapshotPath:snapshotImagePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself setIsSaveSnapshotEnd:YES];
            });
        });
    }
    [super pushViewController:viewController animated:animated];
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self removeSnapshotImageWithSnapshotPath:[self snapshotImagePathForViewController:self.topViewController]];
    return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSInteger count=[self.viewControllers count];
    if (count)
    {
        for (NSInteger Index=count-1; Index>=0; Index--)
        {
            UIViewController * vc=[self.viewControllers objectAtIndex:Index];
            if (vc==viewController) {
                break;
            }
            else
            {
                [self removeSnapshotImageWithSnapshotPath:[self snapshotImagePathForViewController:vc]];
            }
        }
    }
    return [super popToViewController:viewController animated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    for (UIViewController *vc in self.viewControllers)
    {
        [self removeSnapshotImageWithSnapshotPath:[self snapshotImagePathForViewController:vc]];
    }
    return [super popToRootViewControllerAnimated:animated];
}

- (BOOL)isNeedSlidePop
{
    BOOL isSupport=NO;
    if ([self.topViewController respondsToSelector:@selector(isSupportSlidePop)])
    {
        BOOL (* action)(id,SEL)=(BOOL (*)(id,SEL))objc_msgSend;
        isSupport=action(self.topViewController,@selector(isSupportSlidePop));
    }
    return isSupport;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (_isSaveSnapshotEnd&&[self.viewControllers count]>1&&[self isNeedSlidePop])
    {
        return YES;
    }
    return NO;
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (CGRectGetWidth(self.view.frame)==_navViewWidth)
    {
        if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
        {
            [self touchesBegan];
            _isTouchScreenNow=YES;
        }
        else if ([gestureRecognizer state] == UIGestureRecognizerStateChanged)
        {
            [self touchesMovedWithPanGesture:gestureRecognizer];
        }
        else if (gestureRecognizer.state == UIGestureRecognizerStateEnded||
                 gestureRecognizer.state == UIGestureRecognizerStateFailed||
                 gestureRecognizer.state == UIGestureRecognizerStateCancelled)
        {
            [self touchesEnded];
            _isTouchScreenNow=NO;
        }
    }
}

- (void)touchesBegan
{
    if (![self.view.superview.subviews containsObject:_snapshotImageView])
    {
        [self.view.superview insertSubview:_snapshotImageView belowSubview:self.view];
    }
    if ([_snapshotImageView isHidden])
    {
        [_snapshotImageView setHidden:NO];
        NSString * snapshotImagePath=[self snapshotImagePathForViewController:self.topViewController];
        if (![[_snapshotImageView snapshotImagePath] isEqualToString:snapshotImagePath])
        {
            [_snapshotImageView setSnapshotImagePath:snapshotImagePath];
            [_snapshotImageView setImage:[self getSnapshotImageWithSnapshotPath:snapshotImagePath]];
        }
    }
}

- (void)touchesMovedWithPanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint movePoint = [gestureRecognizer translationInView:self.view];
    CGFloat offsetX=movePoint.x;
    CGRect  navViewCurrentFrame=self.view.frame;
    CGFloat navViewCurrentMinX=CGRectGetMinX(navViewCurrentFrame)+offsetX;
    if (navViewCurrentMinX>=0&&navViewCurrentMinX<=_navViewWidth)
    {
        [gestureRecognizer setTranslation:CGPointZero inView:self.view];
        
        CGRect navViewFrame=navViewCurrentFrame;
        navViewFrame.origin.x=navViewCurrentMinX;
        [self.view setFrame:navViewFrame];
    
        CGRect snapshotImageViewFrame=_snapshotImageView.frame;
        snapshotImageViewFrame.origin.x+=offsetX/_navViewWidth*_snapshotImageViewDistanceToScreen;
        [_snapshotImageView setFrame:snapshotImageViewFrame];
    }
}

- (void)touchesEnded
{
    if ([self.viewControllers count]>1&&[self isNeedSlidePop])
    {
        if (CGRectGetMinX(self.view.frame) > _minTriggerPopDinstance)
        {
            CGRect navViewHideFrame=self.view.frame;
            navViewHideFrame.origin.x=_navViewHideMinX;
            CGRect snapshotImageViewShowFrame=_snapshotImageView.frame;
            snapshotImageViewShowFrame.origin.x=_snapshotImageViewShowMinX;
            [UIView animateWithDuration:0.3 animations:^{
                [self.view setFrame:navViewHideFrame];
                [_snapshotImageView setFrame:snapshotImageViewShowFrame];
            }completion:^(BOOL finished){
                [self popViewControllerAnimated:NO];
                [self resetSnapshotView];
            }];
        }
        else
        {
            CGRect navViewShowFrame=self.view.frame;
            navViewShowFrame.origin.x=_navViewShowMinX;
            CGRect snapshotImageViewHideFrame=_snapshotImageView.frame;
            snapshotImageViewHideFrame.origin.x=_snapshotImageViewHideMinX;
            [UIView animateWithDuration:0.3 animations:^{
                [self.view setFrame:navViewShowFrame];
                [_snapshotImageView setFrame:snapshotImageViewHideFrame];
            }completion:^(BOOL finished){
                [self resetSnapshotView];
            }];
        }
    }
}

- (void)resetSnapshotView
{
    CGRect navViewShowFrame=self.view.frame;
    navViewShowFrame.origin.x=_navViewShowMinX;
    [self.view setFrame:navViewShowFrame];
    CGRect snapshotImageViewHideFrame=_snapshotImageView.frame;
    snapshotImageViewHideFrame.origin.x=_snapshotImageViewHideMinX;
    [_snapshotImageView setFrame:snapshotImageViewHideFrame];
    [_snapshotImageView setHidden:YES];
}

- (NSString *)snapshotImagePathForViewController:(UIViewController *)viewController
{
    return [_snapshotFolderPath stringByAppendingFormat:@"/<%p>.png",viewController,nil];
}

- (UIImage *)snapshotImageForViewController:(UIViewController *)viewController
{
    UIView * view=viewController.view;
    CGSize viewSize = view.frame.size;
    UIGraphicsBeginImageContextWithOptions(viewSize, view.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)getSnapshotImageWithSnapshotPath:(NSString *)snapshotPath
{
    UIImage  * image = [UIImage imageWithContentsOfFile:snapshotPath];
    return image;
}

- (void)saveSnapshotImage:(UIImage *)image snapshotPath:(NSString *)snapshotPath
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:_snapshotFolderPath isDirectory:NULL])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:_snapshotFolderPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:snapshotPath atomically:YES];
}

- (void)removeSnapshotImageWithSnapshotPath:(NSString *)snapshotPath
{
    [[NSFileManager defaultManager] removeItemAtPath:snapshotPath error:nil];
}

-(BOOL)shouldAutorotate
{
    if (_isTouchScreenNow)
    {
        return NO;
    }
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];;
}

@end
