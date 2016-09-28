//
//  ICEPlayerEpisodesTableView.m
//  TestVFLProject
//
//  Created by wangyunlong on 16/9/13.
//  Copyright © 2016年 wangyunlong. All rights reserved.
//

#import "ICEPlayerEpisodesTableView.h"
#import "ICEPlayerEpisodeTableViewCell.h"
#define CellHeight  52
@interface ICEPlayerEpisodesTableView ()
<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) NSArray * episodeModels;
@property (nonatomic,assign) CGFloat episodesTableViewWidth;
@end

@implementation ICEPlayerEpisodesTableView
-(void)dealloc
{
    self.episodeModels=nil;
}

-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        _episodesTableViewWidth=CGRectGetWidth(frame);
    }
    return self;
}

-(void)updateWithModels:(NSArray *)models
{
    self.episodeModels=models;
    if (_tableView==nil)
    {
        self.tableView=[[UITableView alloc] initWithFrame:self.bounds];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:_tableView];
    }
    if (_episodeModels)
    {
        [_tableView reloadData];
    }
}

-(void)playEpisode
{
    [_tableView reloadData];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_episodeModels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=@"ICEPlayerEpisodeTableViewCell";
    ICEPlayerEpisodeTableViewCell *  cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[ICEPlayerEpisodeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:CellIdentifier
                                                         cellWidth:_episodesTableViewWidth
                                                        cellHeight:CellHeight];
    }
    [cell updateCellWithModel:_episodeModels[indexPath.row]];
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger Index=[indexPath row];
    if (Index<[_episodeModels count])
    {
        ICEPlayerEpisodeModel * model=_episodeModels[Index];
        if (_selectEpisodeBlock&&model)
        {
            _selectEpisodeBlock(model);
        }
    }
}
@end
