//
//  FeedbackViewController.m
//  IKorean
//
//  Created by ruiwang on 16/9/23.
//  Copyright © 2016年 ruiwang. All rights reserved.
//

#import "FeedbackViewController.h"
#import "FeedbackOptionItem.h"

@interface FeedbackViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIAlertViewDelegate, UITextFieldDelegate> {
    NSInteger selectId;
}

@property (nonatomic, strong) UITextView *suggestTextView;
@property (nonatomic, strong) UITextField *contactTF;
@property (nonatomic, strong) NSMutableArray *feedbackOptionsArr;
@property (nonatomic, strong) UIScrollView *mainScrollView;

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"反馈";
    [self setLeftButtonWithImageName:@"back@2x" action:@selector(backAction)];
    
    [self getFeedbackOptionsData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getFeedbackOptionsData {
    [MYNetworking GET:urlOfFeedbackOptions parameters:nil progress:nil success:^(NSURLSessionDataTask *tesk, id responseObject) {
        [self createUIWithData:(id)responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)createUIWithData:(id)responseObject {
    
    UILabel *titleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 13)];
    titleLabel1.text = @"我遇到的问题";
    titleLabel1.textColor = [UIColor colorWithRed:162/255.0f green:162/255.0f blue:162/255.0f alpha:1];
    titleLabel1.font = [UIFont fontWithName:HYQiHei_55Pound size:13];
    [self.mainScrollView addSubview:titleLabel1];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel1.frame)+8, self.screenWidth, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1];
    [self.mainScrollView addSubview:lineView];
    
    UILabel *titleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lineView.frame)+8, self.screenWidth-20, 34)];
    titleLabel2.text = @"为了更好的解决您反馈的问题,请尽量在出现问题的网络环境下进行反馈:";
    titleLabel2.font = [UIFont fontWithName:HYQiHei_55Pound size:13];
    titleLabel2.textColor = [UIColor colorWithRed:93/255.0f green:93/255.0f blue:93/255.0f alpha:1];
    titleLabel2.numberOfLines = 2;
    [self.mainScrollView addSubview:titleLabel2];
    
    
    [self.feedbackOptionsArr addObjectsFromArray:responseObject[@"data"]];
    selectId = [[self.feedbackOptionsArr firstObject][@"id"] integerValue];  // 默认选第一个
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
    flowlayout.itemSize = CGSizeMake(self.screenWidth/2, 30);
    flowlayout.minimumLineSpacing = 0;
    flowlayout.minimumInteritemSpacing = 0;
    flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    UICollectionView *optionsList = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel2.frame), self.screenWidth, ((self.feedbackOptionsArr.count+1)/2)*30) collectionViewLayout:flowlayout];
    optionsList.backgroundColor = [UIColor whiteColor];
    [optionsList registerNib:[UINib nibWithNibName:@"FeedbackOptionItem" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"optionItem"];
    optionsList.delegate = self;
    optionsList.dataSource = self;
    [self.mainScrollView addSubview:optionsList];
    
    UILabel *titleLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(optionsList.frame)+10, 200, 13)];
    titleLabel3.text = @"请详细写下您的建议和感想吧:";
    titleLabel3.font = [UIFont fontWithName:HYQiHei_55Pound size:13];
    titleLabel3.textColor = [UIColor colorWithRed:93/255.0f green:93/255.0f blue:93/255.0f alpha:1];
    [self.mainScrollView addSubview:titleLabel3];
    
    _suggestTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(titleLabel3.frame)+8, self.screenWidth-20, 85)];
    _suggestTextView.backgroundColor = [UIColor colorWithRed:246/255.0f green:246/255.0f blue:246/255.0f alpha:1];
    [self.mainScrollView addSubview:_suggestTextView];
    
    UILabel *titleLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_suggestTextView.frame)+14, 200, 13)];
    titleLabel4.text = @"您的联系方式(选填):";
    titleLabel4.textColor = [UIColor colorWithRed:93/255.0f green:93/255.0f blue:93/255.0f alpha:1];
    titleLabel4.font = [UIFont fontWithName:HYQiHei_55Pound size:13];
    [self.mainScrollView addSubview:titleLabel4];
    
    _contactTF = [[UITextField alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(titleLabel4.frame)+8, self.screenWidth-20, 40)];
    _contactTF.backgroundColor = [UIColor colorWithRed:246/255.0f green:246/255.0f blue:246/255.0f alpha:1];
    _contactTF.font = [UIFont fontWithName:HYQiHei_55Pound size:13];
    _contactTF.delegate = self;
    NSString *plStr = @"邮箱、手机或QQ";
    NSMutableAttributedString *placeholderStr = [[NSMutableAttributedString alloc] initWithString:plStr];
    [placeholderStr addAttribute:NSStrokeColorAttributeName
                        value:[UIColor redColor]
                           range:NSMakeRange(0, plStr.length)];
    [placeholderStr addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:HYQiHei_55Pound size:13]
                           range:NSMakeRange(0, plStr.length)];
    _contactTF.attributedPlaceholder = placeholderStr;
    [self.mainScrollView addSubview:_contactTF];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    submitBtn.frame = CGRectMake(10, CGRectGetMaxY(_contactTF.frame)+15, self.screenWidth-20, 44);
    submitBtn.backgroundColor = APPColor;
    [submitBtn addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:submitBtn];
    
    
    
    self.mainScrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(submitBtn.frame)+100);
}

- (void)submitAction {
    [_contactTF resignFirstResponder];
    [_suggestTextView resignFirstResponder];

    if ([_suggestTextView.text isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"亲,给些建议吧" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认", nil] show];
    }else {
        // 条件满足 上传反馈
        NSDictionary *params = @{
                                 @"opt"         :@(selectId),
                                 @"content"     :_suggestTextView.text,
                                 @"contact"     :_contactTF.text
                                 };
        [MYNetworking POST:urlOfFeedbackSubmit parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"收到了，感谢亲的支持！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
                alertView.tag =100;
                [alertView show];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }

}

#pragma mark 响应事件
-(void)keyboardWillShow:(NSNotification *)note{

    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    
    _mainScrollView.contentOffset = CGPointMake(0, 165);
    
    [UIView commitAnimations];
    
    
    
}
- (void)keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    
    _mainScrollView.contentOffset = CGPointMake(0, 0);
    
    [UIView commitAnimations];
    
     
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionDelegate datasource 
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.feedbackOptionsArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FeedbackOptionItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:@"optionItem" forIndexPath:indexPath];
    item.titleLabel.text = self.feedbackOptionsArr[indexPath.row][@"title"];
    item.selImageView.highlighted = ([self.feedbackOptionsArr[indexPath.row][@"id"] integerValue] == selectId);
    return item;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    selectId = [self.feedbackOptionsArr[indexPath.row][@"id"] integerValue];
    [collectionView reloadData];
}

#pragma mark - alertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - textField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - getter

- (NSMutableArray *)feedbackOptionsArr {
    if (_feedbackOptionsArr == nil) {
        _feedbackOptionsArr = [NSMutableArray array];
    }
    return _feedbackOptionsArr;
}

- (UIScrollView *)mainScrollView {
    if (_mainScrollView == nil) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.navigationBarHeight, self.screenWidth, self.screenHeight)];
        _mainScrollView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_mainScrollView];
    }
    return _mainScrollView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_contactTF resignFirstResponder];
    [_suggestTextView resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
