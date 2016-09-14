//
//  ISearchBar.m
//  ICinema
//
//  Created by yunlongwang on 16/8/20.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ISearchBar.h"
@interface ISearchBar ()

@property (nonatomic,strong) UIView * shadowEffectView;
@property (nonatomic,strong) UIView * colorTranslucentEffectView;
@property (nonatomic,strong) UIToolbar * blurEffectView;
@property (nonatomic,assign) ISearchBarStyle searchBarStyle;
@property (nonatomic,assign) CGFloat hideMinY;
@property (nonatomic,assign) CGFloat showMinY;
@property (nonatomic,assign) BOOL  searchIsShow;
@end

@implementation ISearchBar

-(id)initWithFrame:(CGRect)frame isNeedSpecialEfficacy:(BOOL)isNeedSpecialEfficacy
{
    if (self=[super initWithFrame:frame])
    {
        if (isNeedSpecialEfficacy)
        {
            _showMinY=CGRectGetMinY(frame);
            _hideMinY=_showMinY-CGRectGetHeight(frame);
            _searchIsShow=YES;
            _searchBarStyle=ISearchBarDefaultStyle;
            
            //渐变效果
            self.shadowEffectView=[[UIView alloc] initWithFrame:self.bounds];
            [self addSubview:_shadowEffectView];
            CAGradientLayer * shadowEffectLayer = [CAGradientLayer layer];//渐变
            [shadowEffectLayer setFrame:_shadowEffectView.bounds];
            [shadowEffectLayer setStartPoint:CGPointMake(0.5, 0.0)];
            [shadowEffectLayer setEndPoint:CGPointMake(0.5, 1)];
            [shadowEffectLayer setColors:[NSArray arrayWithObjects:(id)[ICEAppHelper shareInstance].appPublicColor.CGColor, (id)[[UIColor clearColor] CGColor], nil]];
            [_shadowEffectView.layer addSublayer:shadowEffectLayer];
            
            //半透明效果
            self.colorTranslucentEffectView=[[UIView alloc] initWithFrame:self.bounds];
            [_colorTranslucentEffectView setBackgroundColor:[ICEAppHelper shareInstance].appPublicColor];
            [self addSubview:_colorTranslucentEffectView];
            
            //毛玻璃效果
            self.blurEffectView=[[UIToolbar alloc] initWithFrame:self.bounds];
            _blurEffectView.barStyle = UIBarStyleBlackTranslucent;
            [self addSubview:_blurEffectView];
            
            
            [self updateSearchBarWithSearchBarStyle:ISearchBarShadowStyle alpha:0];
        }
        else
        {
            [self setBackgroundColor:[ICEAppHelper shareInstance].appPublicColor];
        }
        
        CGFloat searchBarWidth=CGRectGetWidth(frame);
        CGFloat searchBarHeight=CGRectGetHeight(frame);
        CGFloat controlBaseLine=20;
        CGFloat controlMaxHeight=searchBarHeight-controlBaseLine;
        
        //logo图片
        UIImage * logoImage=IMAGENAME(@"searchBarLogo@2x", @"png");
        CGFloat logoImageWidth=logoImage.size.width;
        CGFloat logoImageHeight=logoImage.size.height;
        CGFloat logoImageMinX=10;
        CGFloat logoImageMinY=controlBaseLine+(controlMaxHeight-logoImageHeight)/2;
        CGRect  logoImageViewFrame=CGRectMake(logoImageMinX, logoImageMinY, logoImageWidth, logoImageHeight);
        UIImageView * logoImageView=[[UIImageView alloc] initWithImage:logoImage];
        [logoImageView setFrame:logoImageViewFrame];
        [self addSubview:logoImageView];
        
        //名称
        NSString * appName=[ICEAppHelper shareInstance].appName;
        NSDictionary * appNameAttributes=@{NSFontAttributeName:[UIFont fontWithName:HYQiHei_65Pound size:17],
                                           NSForegroundColorAttributeName:[UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1]};
        NSAttributedString * appNameAttributedString=[[NSAttributedString alloc] initWithString:appName
                                                                                     attributes:appNameAttributes];
        CGSize appNameSize=[appNameAttributedString boundingRectWithSize:CGSizeMake(10000, controlMaxHeight)
                                                                 options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                                 context:nil].size;
        
        CGRect appNameLabelFrame=CGRectMake(CGRectGetMaxX(logoImageViewFrame)+6, controlBaseLine+2, appNameSize.width, controlMaxHeight-2);
        UILabel * appNameLabel=[[UILabel alloc] initWithFrame:appNameLabelFrame];
        [appNameLabel setAttributedText:appNameAttributedString];
        [self addSubview:appNameLabel];
        
        //设置按钮
        UIImage * settingButtonImage=IMAGENAME(@"searchBarSetting@2x", @"png");
        CGRect settingButtonFrame=CGRectMake(searchBarWidth-controlMaxHeight, controlBaseLine, controlMaxHeight, controlMaxHeight);
        ICEButton * settingButton=[ICEButton buttonWithType:UIButtonTypeCustom];
        [settingButton setFrame:settingButtonFrame];
        [settingButton addTarget:self action:@selector(settingAction) forControlEvents:UIControlEventTouchUpInside];
        [settingButton setImage:settingButtonImage forState:UIControlStateNormal];
        [self addSubview:settingButton];
        
        //历史记录按钮
        UIImage * historyButtonImage=IMAGENAME(@"searchBarHistory@2x", @"png");
        CGRect historyButtonFrame=CGRectMake(searchBarWidth-controlMaxHeight*2, controlBaseLine, controlMaxHeight, controlMaxHeight);
        ICEButton * historyButton=[ICEButton buttonWithType:UIButtonTypeCustom];
        [historyButton setFrame:historyButtonFrame];
        [historyButton addTarget:self action:@selector(historyAction) forControlEvents:UIControlEventTouchUpInside];
        [historyButton setImage:historyButtonImage forState:UIControlStateNormal];
        [self addSubview:historyButton];

        //搜索栏
        CGFloat searchButtonMinX=CGRectGetMaxX(appNameLabelFrame)+6;
        CGFloat searchButtonWidth=CGRectGetMinX(historyButtonFrame)-searchButtonMinX;
        CGFloat searchButtonHeight=25;
        CGFloat searchButtonMinY=controlBaseLine+(controlMaxHeight-searchButtonHeight)/2;
        CGRect  searchButtonFrame=CGRectMake(searchButtonMinX, searchButtonMinY, searchButtonWidth, searchButtonHeight);
        ICEButton * searchButton=[ICEButton buttonWithType:UIButtonTypeCustom];
        [searchButton setFrame:searchButtonFrame];
        [searchButton addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
        [searchButton setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.3]];
        [searchButton.layer setCornerRadius:searchButtonHeight/2];
        [searchButton.layer setMasksToBounds:YES];
        [self addSubview:searchButton];
        
        //搜索图片
        UIImage * searchImage=IMAGENAME(@"seachBarSearch@2x", @"png");
        CGFloat searchImageHeight=searchImage.size.height;
        CGFloat searchImageWidth=searchImage.size.width;
        NSDictionary * searchButtonTitleAttributes=@{
                                                     NSFontAttributeName:[UIFont fontWithName:HYQiHei_55Pound size:searchImageHeight],
                                                     NSForegroundColorAttributeName:[UIColor whiteColor]
                                                     };
        
        NSMutableAttributedString * searchButtonTitleAttriString=[[NSMutableAttributedString alloc] initWithString:@" 全网搜索"
                                                                                                        attributes:searchButtonTitleAttributes];
        NSTextAttachment * textAttachmentOfSearchImage = [[NSTextAttachment alloc] init];
        textAttachmentOfSearchImage.image = searchImage;
        textAttachmentOfSearchImage.bounds=CGRectMake(0, -3, searchImageWidth, searchImageHeight);
        
        [searchButtonTitleAttriString insertAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachmentOfSearchImage] atIndex:0];
        [searchButton setAttributedTitle:searchButtonTitleAttriString forState:UIControlStateNormal];
    }
    return self;
}

-(void)updateSearchBarWithSearchBarStyle:(ISearchBarStyle)searchBarStyle alpha:(CGFloat)alpha
{
    if(ISearchBarColorTranslucentStyle==searchBarStyle)
    {
        _searchBarStyle=searchBarStyle;
        [_shadowEffectView setAlpha:alpha];
        [_colorTranslucentEffectView setAlpha:1-alpha];
        [_blurEffectView setHidden:YES];
    }
    else  if (searchBarStyle!=_searchBarStyle)
    {
        _searchBarStyle=searchBarStyle;
        if (ISearchBarShadowStyle==searchBarStyle)
        {
            [_shadowEffectView setAlpha:1];
            [_colorTranslucentEffectView setAlpha:0];
            [_blurEffectView setHidden:YES];
        }
        else if(ISearchBarBlurStyle==searchBarStyle)
        {
            [_shadowEffectView setAlpha:0];
            [_colorTranslucentEffectView setAlpha:0];
            [_blurEffectView setHidden:NO];
        }
    }
}

-(void)settingAction {
    if (_selectSettingBlock) {
        _selectSettingBlock();
    }
}

-(void)historyAction
{
    if (_selectHistoryBlock) {
        _selectHistoryBlock();
    }
}

-(void)searchAction
{
    if (_selectSearchBlock) {
        _selectSearchBlock();
    }
}

-(void)isShowSearchBar:(BOOL)isShow
{
    BOOL isCanExecute=!(isShow==_searchIsShow);
    if (isCanExecute)
    {
        _searchIsShow=isShow;
        CGRect searchBarFrame=self.frame;
        searchBarFrame.origin.y=(isShow?_showMinY:_hideMinY);
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        self.frame=searchBarFrame;
        [UIView commitAnimations];
    }
}

@end
