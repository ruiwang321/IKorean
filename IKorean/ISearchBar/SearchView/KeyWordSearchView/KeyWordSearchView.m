//
//  KeyWordSearchView.m
//  IKorean
//
//  Created by ruiwang on 16/9/14.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "KeyWordSearchView.h"
#import "SearchCell.h"
@interface KeyWordSearchView()
<
UITableViewDelegate,
UITableViewDataSource
>
{
    UITableView                 * m_tableView;
    NSMutableArray              * m_arrayOfKeyWordSearchCellModels;
    NSDictionary                * m_titleNormalAttributes;
    CGSize                        m_titleBoundsSize;
    NSStringDrawingOptions        m_titleOption;
}

@property (nonatomic,assign) CGFloat keyWordSearchViewWidth;
@property (nonatomic,assign) CGFloat keyWordSearchViewHeight;
@property (nonatomic,copy)void (^selectBlock )(NSInteger ,NSString * );
@property (nonatomic,copy)void (^startScrollBlock)();
@property (nonatomic,copy)KeyWordSearchViewReloadFinishBlock reloadBlock;
@end

@implementation KeyWordSearchView

-(id)initWithFrame:(CGRect)frame
selectHotSearchCellBlock:(void (^)(NSInteger ,NSString * ))selectBlock
  startScrollBlock:(void (^)())startScrollBlock
 reloadFinishBlock:(KeyWordSearchViewReloadFinishBlock)reloadFinishBlock
{
    if (self=[super initWithFrame:frame])
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        _keyWordSearchViewWidth=CGRectGetWidth(frame);
        _keyWordSearchViewHeight=CGRectGetHeight(frame);
        self.selectBlock=selectBlock;
        self.startScrollBlock=startScrollBlock;
        self.reloadBlock=reloadFinishBlock;
        m_arrayOfKeyWordSearchCellModels=[[NSMutableArray alloc] init];
    }
    return self;
}

-(void)reloadWithKeyWord:(NSString *)keyWord
{
    __weak typeof(self) wself=self;
    [MYNetworking GET:urlOfKeyWordSearch
                            parameters:@{@"keyword":keyWord}
                              progress:nil
                               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                   [wself addOrUpdateTableViewWithResponseData:responseObject keyWord:keyWord];
                                   wself.reloadBlock();
                               }
                               failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                   [wself addOrUpdateTableViewWithResponseData:nil keyWord:keyWord];
                                   wself.reloadBlock();
                               }];
}

-(void)addOrUpdateTableViewWithResponseData:(id)responseData keyWord:(NSString *)keyWord
{
    if (m_tableView==nil)
    {
        m_tableView=[[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
        [m_tableView setDelegate:self];
        [m_tableView setDataSource:self];
        [m_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:m_tableView];
        
        //段落样式
        NSMutableParagraphStyle * titleParagraphStyle=[[NSMutableParagraphStyle alloc]init];
        titleParagraphStyle.alignment = NSTextAlignmentJustified;
        titleParagraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        titleParagraphStyle.lineSpacing=4;
        
        //格式
        m_titleNormalAttributes=[[NSDictionary alloc] initWithObjectsAndKeys:
                           [UIFont fontWithName:HYQiHei_55Pound size:15],NSFontAttributeName,
                           [UIColor colorWithRed:149.0f/255.0f green:149.0f/255.0f blue:149.0f/255.0f alpha:1],NSForegroundColorAttributeName,
                           titleParagraphStyle,NSParagraphStyleAttributeName ,
                           nil];
        
        //最大区域
        m_titleBoundsSize=CGSizeMake(_keyWordSearchViewWidth-2*[SearchCell titleLabelMinX], 10000);
        
        //绘制方式
        m_titleOption = NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
    }
    [m_arrayOfKeyWordSearchCellModels removeAllObjects];
    if (responseData&&(1==[responseData[@"code"]integerValue]))
    {
        NSArray * searchDataArray=responseData[@"data"];
        NSInteger keyWordLength = keyWord.length;
        NSString * keyWordChar = nil;
        UIColor * colorForTitleKeyWord=[ICEAppHelper shareInstance].appPublicColor;

        for (NSString *titleStr in searchDataArray)
        {
            //原始字符串
            NSString * titleString=titleStr;
            
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
                keyWordChar=[keyWord substringWithRange:NSMakeRange(keyWordCharIndex, 1)];
                
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
            
            CGSize titleSize = [titleAttributedString boundingRectWithSize:m_titleBoundsSize
                                                                   options:m_titleOption
                                                                   context:nil].size;
            
            
            SearchCellModel * model =[[SearchCellModel alloc] init];
            model.title=titleAttributedString;
            model.cellHeight=titleSize.height+10+10;
            
            [m_arrayOfKeyWordSearchCellModels addObject:model];

        }
    }
    [m_tableView reloadData];
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
    return [m_arrayOfKeyWordSearchCellModels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"KeyWordSearchCell";
    SearchCellModel * model=m_arrayOfKeyWordSearchCellModels[indexPath.row];
    SearchCell *  cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[SearchCell alloc]initWithStyle:UITableViewCellStyleDefault
                                reuseIdentifier:CellIdentifier
                                      cellWidth:_keyWordSearchViewWidth
                                     cellHeight:model.cellHeight];
    }
    [cell updateCellWithCellModel:model];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchCellModel * model = m_arrayOfKeyWordSearchCellModels[indexPath.row];
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
