//
//  SearchView.m
//  IKorean
//
//  Created by ruiwang on 16/9/14.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "SearchView.h"
#import "HotSearchView.h"
#import "KeyWordSearchView.h"
#import "SearchResultsView.h"
@interface SearchView ()
<
UITextFieldDelegate
>
{
    UITextField * m_searchTextField;
    KeyWordSearchView * m_keyWordSearchView;
    SearchResultsView * m_searchResultsView;
    HotSearchView * m_hotSearchView;
}

@property (nonatomic, copy) BackAction backAction;
@property (nonatomic,assign) BOOL isCanSearchByKeyWord;
//输入中文时会连续掉用两次delegate。用isCanSearchByKeyWord这个标志位防止重复掉用
@property (nonatomic,assign) CGFloat searchViewWidth;
@property (nonatomic,assign) CGFloat searchViewHeight;
@property (nonatomic,assign) CGFloat searchBarHeight;
@end

@implementation SearchView

-(id)initWithFrame:(CGRect)frame
  selectMovieBlock:(void (^)(NSInteger ,NSString * ))selectBlock
        backAction:(BackAction)backAction
{
    if (self=[super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        _searchViewWidth=CGRectGetWidth(frame);
        _searchViewHeight=CGRectGetHeight(frame);
        _searchBarHeight=64;
        _isCanSearchByKeyWord=TRUE;
        
        _backAction = backAction;
        //添加搜索栏
        [self addSearchBar];
        
        //添加热门搜索
        __weak typeof(self) wself = self;
        __weak typeof(m_searchTextField) wTF = m_searchTextField;
        [self addHotSearchViewWithSelectBlock:^(NSInteger id, NSString *title) {
            [wself addOrReloadSearchResultsViewWithSelectBlock:nil
                                                      keyWord:title];
             wTF.text = title;
            [wself showKeyBoard:NO];
        }];
        //添加关键字搜索
        [self addOrReloadKeyWordSearchViewWithSelectBlock:^(NSInteger id, NSString *title   ) {
            [wself addOrReloadSearchResultsViewWithSelectBlock:nil
                                                       keyWord:title];
            wTF.text = title;
            [wself showKeyBoard:NO];
        } keyWord:nil];
        //添加搜索结果
        [self addOrReloadSearchResultsViewWithSelectBlock:selectBlock
                                                  keyWord:nil];
    }
    return self;
}

-(void)addSearchBar
{
    CGRect searchBarFrame=CGRectMake(0, 0, _searchViewWidth, _searchBarHeight);
    UIView * searchBar=[[UIView alloc]initWithFrame:searchBarFrame];
    [searchBar setBackgroundColor:[ICEAppHelper shareInstance].appPublicColor];
    [self addSubview:searchBar];
    
    //取消按钮
    CGFloat controlMinY=20;
    CGRect cancelButtonFrame=CGRectMake(_searchViewWidth-48, controlMinY, 48, _searchBarHeight-controlMinY);
    ICEButton * cancelButton=[ICEButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:cancelButtonFrame];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:15]];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(removeSearchView) forControlEvents:UIControlEventTouchUpInside];
    [searchBar addSubview:cancelButton];
    
    //搜索框背景
    CGFloat textFieldBackGroundMinX=10;
    CGFloat textFieldBackGroundWidth=CGRectGetMinX(cancelButtonFrame)-textFieldBackGroundMinX;
    CGFloat textFieldBackGroundHeight=25;
    CGFloat textFieldBackGroundMinY=controlMinY+(_searchBarHeight-controlMinY-textFieldBackGroundHeight)/2;
    CGRect textFieldBackGroundFrame=CGRectMake(10, textFieldBackGroundMinY, textFieldBackGroundWidth, textFieldBackGroundHeight);
    UIView * textFieldBackGround=[[UIView alloc] initWithFrame:textFieldBackGroundFrame];
    [textFieldBackGround setBackgroundColor:[UIColor whiteColor]];
    [textFieldBackGround.layer setMasksToBounds:YES];
    [textFieldBackGround.layer setCornerRadius:textFieldBackGroundHeight/2];;
    [searchBar addSubview:textFieldBackGround];
    
    //图片
    UIImage * searchIconImage =IMAGENAME(@"searchIcon@2x", @"png");
    CGFloat searchIconImageWidth=searchIconImage.size.width;
    CGFloat searchIconImageHeight=searchIconImage.size.height;
    CGRect searchIconFrame=CGRectMake(10, (textFieldBackGroundHeight-searchIconImageHeight)/2, searchIconImageWidth, searchIconImageHeight);
    UIImageView * searchIconImageView=[[UIImageView alloc] initWithFrame:searchIconFrame];
    [searchIconImageView setImage:searchIconImage];
    [textFieldBackGround addSubview:searchIconImageView];
    
    //输入框
    CGFloat textFieldMinX=CGRectGetMaxX(searchIconFrame)+6;
    CGFloat textFieldWidth=textFieldBackGroundWidth-textFieldMinX;
    CGRect textFieldFrame=CGRectMake(textFieldMinX, 0.5, textFieldWidth, textFieldBackGroundHeight);
    m_searchTextField=[[UITextField alloc] initWithFrame:textFieldFrame];
    [m_searchTextField setDelegate:self];
    [m_searchTextField setText:@""];
    [m_searchTextField setPlaceholder:@"请输入影片名称"];
    [m_searchTextField setFont:[UIFont fontWithName:HYQiHei_50Pound size:13]];
    [m_searchTextField setTextAlignment:NSTextAlignmentLeft];
    [m_searchTextField setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1]];
    [m_searchTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [m_searchTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [m_searchTextField setReturnKeyType:UIReturnKeySearch];
    [m_searchTextField setEnablesReturnKeyAutomatically:YES];
    [m_searchTextField addTarget:self action:@selector(textFieldDidBeginEdit:) forControlEvents:UIControlEventEditingDidBegin];
    [m_searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [textFieldBackGround addSubview:m_searchTextField];
    [m_searchTextField becomeFirstResponder];

}

-(void)addHotSearchViewWithSelectBlock:(void (^)(NSInteger ,NSString * ))block
{
    __weak typeof(self) wself=self;
    CGRect hotSearchViewFrame=CGRectMake(0, _searchBarHeight, _searchViewWidth, _searchViewHeight-_searchBarHeight);
    m_hotSearchView=[[HotSearchView alloc] initWithFrame:hotSearchViewFrame
                                              selectHotSearchCellBlock:block
                                                      startScrollBlock:^{
                                                          [wself showKeyBoard:NO];
                                                      }];
    [self addSubview:m_hotSearchView];
}

-(void)addOrReloadKeyWordSearchViewWithSelectBlock:(void (^)(NSInteger ,NSString * ))block
                                           keyWord:(NSString *)keyWord
{
    if (m_keyWordSearchView==nil)
    {
        __weak typeof(self) wself=self;
        CGRect keyWordSearchViewFrame=CGRectMake(0, _searchBarHeight, _searchViewWidth, _searchViewHeight-_searchBarHeight);
        m_keyWordSearchView=[[KeyWordSearchView alloc] initWithFrame:keyWordSearchViewFrame
                                            selectHotSearchCellBlock:block
                                                    startScrollBlock:^{
                                                        [wself showKeyBoard:NO];
                                                    }
                                                   reloadFinishBlock:^{
                                                        wself.isCanSearchByKeyWord=TRUE;
                                                   }];
        [self addSubview:m_keyWordSearchView];
    }
        
    if (keyWord&&[keyWord length]&&_isCanSearchByKeyWord)
    {
        _isCanSearchByKeyWord=FALSE;
        [m_keyWordSearchView reloadWithKeyWord:keyWord];
        [m_keyWordSearchView setHidden:NO];
        [m_searchResultsView setHidden:YES];
    }
    else if(keyWord==nil||![keyWord length])
    {
        [m_keyWordSearchView setHidden:YES];
    }
}

-(void)addOrReloadSearchResultsViewWithSelectBlock:(void (^)(NSInteger ,NSString * ))block
                                           keyWord:(NSString *)keyWord
{
    if (keyWord) {
        [[TVDataHelper shareInstance] addSearchHistoryKeyword:keyWord]; // 保存搜索记录到数据库
        [m_hotSearchView updateSearchHistoryDataNeedLoadMore:NO]; // 刷新搜索记录View
    }
    if (m_searchResultsView==nil)
    {
        __weak typeof(self) wself=self;
        CGRect searchResultsViewFrame=CGRectMake(0, _searchBarHeight, _searchViewWidth, _searchViewHeight-_searchBarHeight);
        m_searchResultsView=[[SearchResultsView alloc]initWithFrame:searchResultsViewFrame
                                           selectHotSearchCellBlock:block
                                                   startScrollBlock:^{
                                                       [wself showKeyBoard:NO];
                                                   }];
        [self addSubview:m_searchResultsView];
    }
    if (keyWord&&[keyWord length])
    {
        [m_searchResultsView reloadWithKeyWord:keyWord];
        [m_searchResultsView setHidden:NO];
    }
    else
    {
        [m_searchResultsView setHidden:YES];
    }
}

-(void)removeSearchView
{
    [self showKeyBoard:NO];
    if (_backAction) {
        _backAction();
    }
}

-(void)showKeyBoard:(BOOL)isShow
{
    if (isShow)
    {
        [m_searchTextField becomeFirstResponder];
    }
    else
    {
        [m_searchTextField resignFirstResponder];
    }
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEdit:(UITextField *)textField
{
    [self addOrReloadKeyWordSearchViewWithSelectBlock:nil
                                              keyWord:textField.text];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    [self addOrReloadKeyWordSearchViewWithSelectBlock:nil
                                              keyWord:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self addOrReloadSearchResultsViewWithSelectBlock:nil
                                              keyWord:textField.text];
    [self showKeyBoard:NO];
    return YES;
}
@end
