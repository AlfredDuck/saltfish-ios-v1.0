//
//  SFMyFollowTopicViewController.m
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFMyFollowTopicViewController.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "urlManager.h"
#import "colorManager.h"
#import "myTopicTableViewCell.h"
#import "TopicVC.h"

@interface SFMyFollowTopicViewController ()

@end

@implementation SFMyFollowTopicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"test";
        self.view.backgroundColor = [colorManager lightGrayBackground];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    // 登录账户的uid
    NSUserDefaults *sfUserDefault = [NSUserDefaults standardUserDefaults];
    if ([sfUserDefault objectForKey:@"loginInfo"]) {
        _uid = [[sfUserDefault objectForKey:@"loginInfo"] objectForKey:@"uid"];
    }
    
    [self createUIParts];  // 创建ui
    [self connectForMyTopics];  // 初始请求
}

- (void)viewWillAppear:(BOOL)animated {
    // 设置状态栏颜色的强力方法
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - 构建 UI 零件
- (void)createUIParts
{
    /* title bar background */
    UIView *titleBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 64)];
    titleBarBackground.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:titleBarBackground];
    
    /* 分割线 */
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 64-0.5, _screenWidth, 0.5)];
    line.backgroundColor = [colorManager lightGrayLineColor];
    [titleBarBackground addSubview:line];
    
    /* title */
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_screenWidth-200)/2, 20, 200, 44)];
    titleLabel.text = @"我的话题";
    titleLabel.textColor = [colorManager mainTextColor];
    titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 16];
    titleLabel.textAlignment = UITextAlignmentCenter;
    [titleBarBackground addSubview:titleLabel];
    
    /* back button pic */
    UIImage *oneImage = [UIImage imageNamed:@"back_black.png"]; // 使用ImageView通过name找到图片
    UIImageView *oneImageView = [[UIImageView alloc] initWithImage:oneImage]; // 把oneImage添加到oneImageView上
    oneImageView.frame = CGRectMake(11, 13.2, 22, 17.6); // 设置图片位置和大小
    // [oneImageView setContentMode:UIViewContentModeCenter];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [backView addSubview:oneImageView];
    // 为UIView添加点击事件
    // 一定要先将userInteractionEnabled置为YES，这样才能响应单击事件
    backView.userInteractionEnabled = YES; // 设置图片可以交互
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBackButton)]; // 设置手势
    [backView addGestureRecognizer:singleTap]; // 给图片添加手势
    [titleBarBackground addSubview:backView];
    
    
    /** loadingView **/
    _loadingView = [[UIView alloc] initWithFrame:CGRectMake((_screenWidth-200)/2.0, (_screenHeight-60)/2.0, 200, 44+16)];
    // 菊花
    _loadingFlower = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingFlower.frame = CGRectMake((200-44)/2.0, 0, 44, 44);
    [_loadingFlower startAnimating];
    //[_loadingFlower stopAnimating];
    // loading 文案
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, 200, 16)];
    loadingLabel.text = @"正在加载...";
    loadingLabel.textColor = [colorManager secondTextColor];
    loadingLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    loadingLabel.textAlignment = UITextAlignmentCenter;
    
    [_loadingView addSubview:loadingLabel];
    [_loadingView addSubview:_loadingFlower];
    [titleBarBackground addSubview:_loadingView];

}



#pragma mark - 创建 TableView
- (void)createTableView
{
    /* 创建tableView */
    static NSString *CellWithIdentifier = @"commentCell";
    _oneTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, _screenWidth, _screenHeight-64)];
    _oneTableView.backgroundColor = [UIColor brownColor];
    [_oneTableView setDelegate:self];
    [_oneTableView setDataSource:self];
    
    [_oneTableView registerClass:[myTopicTableViewCell class] forCellReuseIdentifier:CellWithIdentifier];
    _oneTableView.backgroundColor = [colorManager lightGrayBackground];
    _oneTableView.separatorStyle = UITableViewCellSeparatorStyleNone; // 去掉分割线
    // _oneTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0); // 设置距离顶部的一段偏移，继承自scrollview
    // 响应点击状态栏的事件
    _oneTableView.scrollsToTop = YES;
    [self.view addSubview:_oneTableView];
    
    // 下拉刷新 MJRefresh
    //    _oneTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
    //        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //            // 结束刷新动作
    //            [_oneTableView.mj_header endRefreshing];
    //            NSLog(@"下拉刷新成功，结束刷新");
    //        });
    //
    //    }];
    
    // 上拉刷新 MJRefresh
//    _oneTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        // 结束加载更多
//        // [tableView.mj_footer endRefreshing];
//        // [tableView.mj_footer endRefreshingWithNoMoreData];
//        [self connectForMore];
//    }];
}




#pragma mark - IBAction
- (void)clickBackButton
{
    NSLog(@"back");
    [self.navigationController popViewControllerAnimated:YES];
}




#pragma mark - TableView 代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableViewData count];
}

// 填充cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TopicCellWithIdentifier = @"topicCell+";
    myTopicTableViewCell *oneTopicCell = [tableView dequeueReusableCellWithIdentifier:TopicCellWithIdentifier];
    
    NSUInteger row = [indexPath row];
    if (oneTopicCell == nil) {
        oneTopicCell = [[myTopicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TopicCellWithIdentifier];
    }
    
    [oneTopicCell rewriteTitle:[[_tableViewData objectAtIndex:row] objectForKey:@"title"]];
    [oneTopicCell rewriteUpdateTime:[[_tableViewData objectAtIndex:row] objectForKey:@"introduction"]];
    [oneTopicCell rewritePic:[[_tableViewData objectAtIndex:row] objectForKey:@"portrait"]];
    [oneTopicCell rewriteNotification:[[_tableViewData objectAtIndex:row] objectForKey:@"isPushOn"]];
    // 取消选中的背景色
    oneTopicCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return oneTopicCell;
    // 直接往cell addsubView的方法会在每次划出屏幕再划回来时 再加载一次subview，因此会重复加载很多subview
}

// 改变 cell 高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 58+24;
    return height;
}


// tableView 点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    TopicVC *topicPV = [[TopicVC alloc] init];
    topicPV.topic = [[_tableViewData objectAtIndex:row] objectForKey:@"title"];
    topicPV.portraitURL = [[_tableViewData objectAtIndex:row] objectForKey:@"portrait"];
    [self.navigationController pushViewController:topicPV animated:YES];
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}



#pragma mark - 网络连接
- (void)connectForMyTopics
{
    NSLog(@"请求开始");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/user/my_topics"];
    
    NSDictionary *parameters = @{@"uid": _uid};
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSArray *data = [responseObject objectForKey:@"data"];
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        NSLog(@"errcode：%@", errcode);
        
        if ([errcode isEqualToString:@"err"]) {
            return;
        }
        
        // 更新当前 tableview 的数据
        _tableViewData = [data mutableCopy];
        data = nil;
        
        // 创建 tableview
        [self createTableView];
        
        if ([_tableViewData count] >= 10) {
            // 上拉刷新 MJRefresh
            _oneTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                [self connectForMore];
            }];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (void)connectForMore
{
    NSLog(@"请求开始");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/user/my_topics"];
    
    NSDictionary *parameters = @{@"uid": _uid,
                                 @"last_id": [[_tableViewData lastObject] objectForKey:@"_id"],
                                 @"type": @"loadmore"
                                 };
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSArray *data = [responseObject objectForKey:@"data"];
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        NSLog(@"errcode：%@", errcode);
        
        if ([errcode isEqualToString:@"err"]) {
            [_oneTableView.mj_footer endRefreshing];
            return;
        }
        if ([data count] == 0) {
            [_oneTableView.mj_footer endRefreshingWithNoMoreData];
            return;
        }
        
        // 更新当前 tableview 的数据
        [_tableViewData addObjectsFromArray:data];
        data = nil;
        
        // 刷新 tableview
        [_oneTableView reloadData];
        
        [_oneTableView.mj_footer endRefreshing];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [_oneTableView.mj_footer endRefreshing];
    }];

}



@end
