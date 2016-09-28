//
//  MovieCorrelationUnitView.m
//  ICinema
//
//  Created by wangyunlong on 16/9/24.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "MovieCorrelationUnitView.h"
#import "MovieItemTableViewCell.h"
@interface MovieCorrelationUnitView ()
<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic,strong)NSMutableArray * tableViewArray;
@property (nonatomic,copy)MovieItemAction selectBlock;
@property (nonatomic,assign)CGFloat cellWidth;
@property (nonatomic,assign)CGFloat cellHeight;

@end

@implementation MovieCorrelationUnitView

-(id)initWithFrame:(CGRect)frame
        recommends:(NSArray *)recommends
       selectBlock:(MovieItemAction)selectBlock
{
    if (self=[super initWithFrame:frame])
    {
        MovieItemLayoutHelper * helper=[MovieItemLayoutHelper shareInstance];
        _cellWidth=CGRectGetWidth(frame);
        _cellHeight=[helper movieItemHStyleHeight];
        self.selectBlock=selectBlock;
        self.tableViewArray=[[NSMutableArray alloc] init];
 
        NSInteger itemCountInRow=[helper itemCountInRow];
        NSInteger origDataCount=[recommends count];
        for (NSInteger Index=0;Index<origDataCount;Index++)
        {
            NSDictionary * dic=recommends[Index];
            MovieItemModel * model=[[MovieItemModel alloc] init];
            [model setValuesForKeysWithDictionary:dic];
            NSMutableArray * lastRowData=[_tableViewArray lastObject];
            if (lastRowData==nil||
                [lastRowData count]>=itemCountInRow)
            {
                lastRowData=[[NSMutableArray alloc] initWithCapacity:itemCountInRow];
                [lastRowData addObject:model];
                [_tableViewArray addObject:lastRowData];
            }
            else
            {
                [lastRowData addObject:model];
            }
        }
        
        UIView * paddingView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, _cellWidth, [helper movieItemPaddingToTop])];
        UITableView * tableView=[[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [tableView setDelegate:self];
        [tableView setDataSource:self];
        [tableView setTableHeaderView:paddingView];
        [tableView setShowsHorizontalScrollIndicator:NO];
        [tableView setShowsVerticalScrollIndicator:NO];
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:tableView];
    }
    return self;
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableViewArray count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row]==[_tableViewArray count])
    {
        static NSString *CellIdentifier = @"MovieDetailImageADCell";
        ICETableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell==nil)
        {
            MyImageADModel * imageADModel=[[ICEAppHelper shareInstance] contentImageADModel];
            
            cell=[[ ICETableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier
                                                cellWidth:_cellWidth
                                               cellHeight:[imageADModel height]];
            
            MyADView * myADView=[[MyADView alloc] initWithFrame:[cell bounds] imageADModel:imageADModel];
            [cell addSubview:myADView];
        }
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"MovieCorrelationTableViewCell";
        MovieItemTableViewCell *  cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[MovieItemTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:CellIdentifier
                                                      cellWidth:_cellWidth
                                                     cellHeight:_cellHeight];
            [cell setSelectBlock:_selectBlock];
        }
        [cell updateXNWCellWithDicOfData:_tableViewArray[indexPath.row]];
        return cell;
    }
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row]==[_tableViewArray count])
    {
        return [[[ICEAppHelper shareInstance] contentImageADModel] height];
    }
    return _cellHeight;
}

@end
