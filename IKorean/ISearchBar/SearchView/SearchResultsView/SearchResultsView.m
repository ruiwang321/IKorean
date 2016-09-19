//
//  SearchResultsView.m
//  IKorean
//
//  Created by ruiwang on 16/9/14.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "SearchResultsView.h"
#import "SearchResultCell.h"
@interface SearchResultsView()
<
UITableViewDelegate,
UITableViewDataSource
>
{
    NSMutableString             * m_keyWord;
    ICEPullTableView            * m_tableView;
    NSMutableArray              * m_arrayOfSearchResultCellModels;
    NSDictionary                * m_titleNormalAttributes;
    NSDictionary                * m_subTitleAttributes;
    CGSize                        m_titleBoundsSize;
    NSStringDrawingOptions        m_titleOption;
    CGFloat                       m_titleWidth;
    NSInteger                     page;
}

@property (nonatomic,assign) CGFloat searchResultViewWidth;
@property (nonatomic,assign) CGFloat searchResultViewHeight;
@property (nonatomic,copy)void (^selectBlock )(NSInteger ,NSString * );
@property (nonatomic,copy)void (^startScrollBlock)();

@end

@implementation SearchResultsView

-(id)initWithFrame:(CGRect)frame
selectHotSearchCellBlock:(void (^)(NSInteger ,NSString * ))selectBlock
  startScrollBlock:(void (^)())startScrollBlock
{
    if (self=[super initWithFrame:frame])
    {
        [self setBackgroundColor:[UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1]];
       
        _searchResultViewWidth=CGRectGetWidth(frame);
        _searchResultViewHeight=CGRectGetHeight(frame);
        m_keyWord=[[NSMutableString alloc] initWithString:@""];
        self.selectBlock=selectBlock;
        self.startScrollBlock=startScrollBlock;
        page = 1;
    }
    return self;
}

-(void)reloadWithKeyWord:(NSString *)keyWord
{
    if (keyWord&&[keyWord length])
    {
        [m_keyWord setString:keyWord];
        [self sendGetSearchResultDataRequestWithPullTableViewType:ICEPullTableViewRefresh];
    }
}

- (NSInteger)getLastIDWithPullTableViewType:(ICEPullTableViewOperationTypeOptions)operationType
{
    NSInteger lastItemID=0;
    if(ICEPullTableViewLoadMore==operationType)
    {
        SearchResultCellModel * model =[m_arrayOfSearchResultCellModels lastObject];
        if (model)
        {
            lastItemID=model.movieID;
        }
    }
    return lastItemID;
}

- (void)addNewDataWithNewDatas:(NSArray *)searchDataArray
{
    if (m_arrayOfSearchResultCellModels==nil)
    {
        m_arrayOfSearchResultCellModels=[[NSMutableArray alloc] init];
        
        //段落样式
        NSMutableParagraphStyle * titleParagraphStyle=[[NSMutableParagraphStyle alloc]init];
        titleParagraphStyle.alignment = NSTextAlignmentJustified;
        titleParagraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        titleParagraphStyle.lineSpacing=4;
        titleParagraphStyle.paragraphSpacing=4;
        
        //格式
        m_titleNormalAttributes=[[NSDictionary alloc] initWithObjectsAndKeys:
                                 [UIFont fontWithName:HYQiHei_55Pound size:15],NSFontAttributeName,
                                 [UIColor colorWithRed:149.0f/255.0f green:149.0f/255.0f blue:149.0f/255.0f alpha:1],NSForegroundColorAttributeName,
                                 titleParagraphStyle,NSParagraphStyleAttributeName ,
                                 nil];
        
        m_subTitleAttributes=[[NSDictionary alloc] initWithObjectsAndKeys:
                              [UIFont fontWithName:HYQiHei_50Pound size:12],NSFontAttributeName,
                              [UIColor colorWithRed:159.0f/255.0f green:159.0f/255.0f blue:159.0f/255.0f alpha:1],NSForegroundColorAttributeName,
                              titleParagraphStyle,NSParagraphStyleAttributeName ,
                              nil];
        //最大区域
        CGPoint titleLabelOrigin=[SearchResultCell titleLabelOrigin];
        m_titleBoundsSize=CGSizeMake(_searchResultViewWidth-titleLabelOrigin.x-[SearchResultCell titleLabelPaddingToRight], 10000);
        
        //绘制方式
        m_titleOption = NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
        
    }
    
    NSInteger keyWordLength = m_keyWord.length;
    NSString * keyWordChar = nil;
    UIColor * colorForTitleKeyWord=[ICEAppHelper shareInstance].appPublicColor;
    
    for (NSDictionary * dic in searchDataArray)
    {
        //原始字符串
        NSString * titleString=dic[@"title"];
        
        //格式字符串
        NSMutableAttributedString * titleAttributedString=[[NSMutableAttributedString alloc]initWithString:titleString
                                                                                                attributes:m_titleNormalAttributes];
        //原始字符串长度
        NSInteger titleLength=[titleString length];
        
        //原始字符串当前的字符
        NSString * titleChar = nil;
        
        for (NSInteger keyWordCharIndex=0; keyWordCharIndex<keyWordLength; keyWordCharIndex++)
        {
            //关键字当前的字符
            keyWordChar=[m_keyWord substringWithRange:NSMakeRange(keyWordCharIndex, 1)];
            
            for(NSInteger titleIndex = 0; titleIndex < titleLength; titleIndex++)
            {
                NSRange range = NSMakeRange(titleIndex, 1);
                
                titleChar = [titleString substringWithRange:range];
                
                if ([titleChar caseInsensitiveCompare:keyWordChar]== NSOrderedSame)
                {
                    [titleAttributedString addAttribute:NSForegroundColorAttributeName
                                                  value:colorForTitleKeyWord
                                                  range:range];
                }
            }
        }
        
        //类型
        NSString * typeString=dic[@"type_string"];
        if ([typeString length])
        {
            NSString * string=[NSString stringWithFormat:@"%@类型:%@",(titleLength?@"\n":@""),typeString];
            NSAttributedString * attributedString=[[NSAttributedString alloc] initWithString:string
                                                                                  attributes:m_subTitleAttributes];
            [titleAttributedString appendAttributedString:attributedString];
        }
        
        //评分
        NSString * gradeString=[NSString stringWithFormat:@"%@",dic[@"grade"]] ;
        if ([gradeString length])
        {
            NSString * string=[NSString stringWithFormat:@"%@评分:%@",(titleLength?@"\n":@""),gradeString];
            NSAttributedString * attributedString=[[NSAttributedString alloc] initWithString:string
                                                                                  attributes:m_subTitleAttributes];
            [titleAttributedString appendAttributedString:attributedString];
        }
        
        SearchResultCellModel * model =[[SearchResultCellModel alloc] init];
        model.movieID=[dic[@"id"] integerValue];
        model.title=titleString;
        model.img=dic[@"img"];
        model.titleAttributedString=titleAttributedString;

        [m_arrayOfSearchResultCellModels addObject:model];
    }
}

-(void)sendGetSearchResultDataRequestWithPullTableViewType:(ICEPullTableViewOperationTypeOptions)operationType
{
    if (operationType == ICEPullTableViewLoadMore) {
        page++;
    }else if (operationType == ICEPullTableViewRefresh) {
        page = 1;
    }
    __weak typeof(self) wself=self;
    NSDictionary * parameters=@{
                                @"keyword"  :m_keyWord,
                                @"page"     :@(page)
                                };
    [MYNetworking GET:urlOfSearchResults
                           parameters:parameters
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  [wself addOrReloadTableViewWithResponseData:responseObject
                                                        withPullTableViewType:operationType];
                              }
                              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                  [wself addOrReloadTableViewWithResponseData:nil
                                                        withPullTableViewType:operationType];
                              }];
}

- (void)addOrReloadTableViewWithResponseData:(id)responseData
                       withPullTableViewType:(ICEPullTableViewOperationTypeOptions)operationType
{
    ICEPullTableViewOperationResultOptions  operationResult = ICEPullTableViewOperationSuccess;
    if (responseData&&1==[responseData[@"code"] integerValue]&&[responseData[@"data"] count]>0)
    {
        if(ICEPullTableViewRefresh==operationType)
        {
            [m_arrayOfSearchResultCellModels removeAllObjects];
        }
        [self addNewDataWithNewDatas:responseData[@"data"]];
    }
    else if(1==[responseData[@"code"] integerValue]&&[responseData[@"data"] count]==0)
    {
        //暂无更多
        if(ICEPullTableViewRefresh==operationType)
        {
            [m_arrayOfSearchResultCellModels removeAllObjects];
        }
        operationResult=ICEPullTableViewOperationNoMore;
    }
    else
    {
        //失败
        operationResult=ICEPullTableViewOperationFailed;
    }
    
    if (m_tableView==nil)
    {
        __weak typeof(self) wself=self;
        m_tableView=[[ICEPullTableView alloc]initWithFrame:self.bounds
                                            isNeedLoadMore:YES
                                             tableViewName:nil
                                       refreshTimeInterval:0];
        m_tableView.tableViewOperationStartBlock=^(ICEPullTableViewOperationTypeOptions operationType){
            [wself sendGetSearchResultDataRequestWithPullTableViewType:operationType];
        };
        m_tableView.scrollViewOperationStartBlock=^(ScrollViewOperationTypeOptions operationType,CGFloat offsetY)
        {
            if (ScrollViewWillBeginDragging==operationType)
            {
                wself.startScrollBlock();
            }
        };
        [m_tableView setDelegate:self];
        [m_tableView setDataSource:self];
        [m_tableView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:m_tableView];
    }
    
    [m_tableView reloadData];
    [m_tableView tableOperationCompleteWithOperationType:operationType andOperationResult:operationResult];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_arrayOfSearchResultCellModels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchResultCell";
    SearchResultCell *  cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[SearchResultCell alloc]initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier
                                            cellWidth:_searchResultViewWidth
                                           cellHeight:[SearchResultCell cellHiehgt]];
    }
    [cell updateCellWithCellModel:m_arrayOfSearchResultCellModels[indexPath.row]];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SearchResultCell cellHiehgt];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchResultCell *  cell=(SearchResultCell *)[tableView cellForRowAtIndexPath:indexPath];
    SearchResultCellModel * model=cell.model;
    if (_selectBlock) {
        _selectBlock(model.movieID,model.title);
    }
}
@end
