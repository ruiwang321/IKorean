//
//  HotSearchView.m
//  IKorean
//
//  Created by ruiwang on 16/9/14.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "HotSearchView.h"
#import "SearchCell.h"
@interface HotSearchView()
<
UITableViewDelegate,
UITableViewDataSource
>
{
    ICEButton              * m_reloadRequestButton;
    UITableView            * m_tableView;
    NSMutableArray         * m_arrayOfSearchCellModel;
    NSDictionary           * m_titleAttributes;
    CGSize                   m_titleBoundsSize;
    NSStringDrawingOptions   m_titleOption;
}

@property (nonatomic,strong) UITableView *mainTableView;
@property (nonatomic,assign) CGFloat hotSearchViewWidth;
@property (nonatomic,assign) CGFloat hotSearchViewHeight;
@property (nonatomic,assign) CGFloat titleBarHeight;
@property (nonatomic,copy)void (^selectBlock )(NSInteger ,NSString * );
@property (nonatomic,copy)void (^startScrollBlock)();

@end

@implementation HotSearchView

-(id)initWithFrame:(CGRect)frame
selectHotSearchCellBlock:(void (^)(NSInteger ,NSString * ))selectBlock
  startScrollBlock:(void (^)())startScrollBlock
{
    if (self=[super initWithFrame:frame])
    {
        self.selectBlock=selectBlock;
        self.startScrollBlock=startScrollBlock;
        
        m_arrayOfSearchCellModel=[[NSMutableArray alloc] init];
        _hotSearchViewWidth=CGRectGetWidth(frame);
        _hotSearchViewHeight=CGRectGetHeight(frame);
        _titleBarHeight=26;
        
        CGRect titleBarFrame=CGRectMake(0, 0, _hotSearchViewWidth, _titleBarHeight);
        UIView * titleBar=[[UIView alloc] initWithFrame:titleBarFrame];
        [titleBar setBackgroundColor:[UIColor colorWithRed:225.0f/255.0f green:225.0f/255.0f blue:225.0f/255.0f alpha:1]];
        [self addSubview:titleBar];
        
        CGRect colorViewFrame=CGRectMake(0, 0, 2.5, _titleBarHeight);
        UIView * colorView=[[UIView alloc] initWithFrame:colorViewFrame];
        [colorView setBackgroundColor:[ICEAppHelper shareInstance].appPublicColor];
        [titleBar addSubview:colorView];
        
        CGRect titleLabelFrame=CGRectMake(CGRectGetMaxX(colorViewFrame)+8, 0, 130, _titleBarHeight);
        UILabel * titleLabel=[[UILabel alloc] initWithFrame:titleLabelFrame];
        [titleLabel setText:@"热门搜索"];
        [titleLabel setFont:[UIFont fontWithName:HYQiHei_65Pound size:15]];
        [titleLabel setTextColor:[UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1]];
        [titleBar addSubview:titleLabel];
        
        CGRect reloadRequestButtonFrame=CGRectMake(0, _titleBarHeight, _hotSearchViewWidth,40);
        m_reloadRequestButton=[ICEButton buttonWithType:UIButtonTypeCustom];
        [m_reloadRequestButton setFrame:reloadRequestButtonFrame];
        [m_reloadRequestButton.titleLabel setFont:[UIFont fontWithName:HYQiHei_55Pound size:15]];
        [m_reloadRequestButton setTitleColor:[ICEAppHelper shareInstance].appPublicColor forState:UIControlStateNormal];
        [m_reloadRequestButton setTitle:@"数据获取失败，请点击重试" forState:UIControlStateNormal];
        [m_reloadRequestButton addTarget:self action:@selector(sendGetHotSearchDataRequest) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:m_reloadRequestButton];
        [m_reloadRequestButton setHidden:YES];
        
        [self sendGetHotSearchDataRequest];
        
        [self createMainTableView];
    }
    return self;
}

- (void)createMainTableView {
    _mainTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    [self addSubview:_mainTableView];
}

-(void)sendGetHotSearchDataRequest
{
    __weak typeof(self) wself=self;
    [MYNetworking GET:urlOfHotSearch
                        parameters:nil
                          progress:nil
                           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                               [wself addOrUpdateTableViewWithResponseData:responseObject];
                           }
                           failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                               [wself addOrUpdateTableViewWithResponseData:nil];
                           }];
}

-(void)addOrUpdateTableViewWithResponseData:(id)responseData
{
    if (m_tableView==nil)
    {
        CGRect tabelViewFrame=CGRectMake(0, _titleBarHeight, _hotSearchViewWidth, _hotSearchViewHeight-_titleBarHeight);
        m_tableView=[[UITableView alloc]initWithFrame:tabelViewFrame style:UITableViewStylePlain];
        [m_tableView setDelegate:self];
        [m_tableView setDataSource:self];
        [m_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:m_tableView];
        
        NSMutableParagraphStyle * titleParagraphStyle=[[NSMutableParagraphStyle alloc]init];
        titleParagraphStyle.alignment = NSTextAlignmentJustified;
        titleParagraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        titleParagraphStyle.lineSpacing=4;

        m_titleAttributes=[[NSDictionary alloc] initWithObjectsAndKeys:
                           [UIFont fontWithName:HYQiHei_55Pound size:15],NSFontAttributeName,
                           [UIColor colorWithRed:149.0f/255.0f green:149.0f/255.0f blue:149.0f/255.0f alpha:1],NSForegroundColorAttributeName,
                           titleParagraphStyle,NSParagraphStyleAttributeName ,
                           nil];
        
        m_titleBoundsSize=CGSizeMake(_hotSearchViewWidth-2*[SearchCell titleLabelMinX], 10000);
        
        m_titleOption = NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
    }
    if (responseData&&(1==[responseData[@"code"] integerValue]))
    {
        [m_arrayOfSearchCellModel removeAllObjects];
        
        NSArray * hotSearchDatas=responseData[@"data"];
        
        for (NSString * titleStr in hotSearchDatas)
        {
            NSAttributedString * title=[[NSAttributedString alloc] initWithString:titleStr
                                                                       attributes:m_titleAttributes];
            
            CGSize titleSize = [title boundingRectWithSize:m_titleBoundsSize
                                                   options:m_titleOption
                                                   context:nil].size;
            
            
            SearchCellModel * model =[[SearchCellModel alloc] init];
            model.title=title;
            model.cellHeight=titleSize.height+10+10;
            
            [m_arrayOfSearchCellModel addObject:model];
        }
        
        [m_reloadRequestButton setHidden:YES];
        [m_tableView setHidden:NO];
        [m_tableView reloadData];
    }
    else
    {
        [m_reloadRequestButton setHidden:NO];
        [m_tableView setHidden:YES];
    }
}

#pragma mark UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_startScrollBlock) {
        _startScrollBlock();
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_arrayOfSearchCellModel count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"HotSearchCell";
    SearchCellModel * model=m_arrayOfSearchCellModel[indexPath.row];
    SearchCell *  cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[SearchCell alloc]initWithStyle:UITableViewCellStyleDefault
                                reuseIdentifier:CellIdentifier
                                      cellWidth:_hotSearchViewWidth
                                     cellHeight:model.cellHeight];
    }
    [cell updateCellWithCellModel:model];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchCellModel * model = m_arrayOfSearchCellModel[indexPath.row];
    return model.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchCell *  cell=(SearchCell *)[tableView cellForRowAtIndexPath:indexPath];
    SearchCellModel * model=cell.model;
    if (_selectBlock) {
        _selectBlock(model.movieID,model.title.string);
    }
}
@end
