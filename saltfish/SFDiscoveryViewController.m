//
//  SFDiscoveryViewController.m
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFDiscoveryViewController.h"
#import "AFNetworking.h"
#import "urlManager.h"
#import "colorManager.h"
#import "SFClassificationTableViewCell.h"
#import "TopicTableViewCell.h"
#import "TopicVC.h"
#import "ClassificationVC.h"
#import "MJRefresh.h"
#import "SFLoginAndSignup.h"


@interface SFDiscoveryViewController ()

@end

@implementation SFDiscoveryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"test";
        self.view.backgroundColor = [UIColor redColor];
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
    
    [self createUIParts];
    [super createTabBarWith:1];  // 调用父类方法，构建tabbar
    
    // 调用 MJRefresh 初始化数据
    [_oneTableView.mj_header beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated {
    // 设置状态栏颜色的强力方法
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - 构建 UI 零件
- (void)createUIParts
{
    /* 标题栏 */
    UIView *titleBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 64)];
    titleBarBackground.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:titleBarBackground];
    
    /* 分割线 */
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 64-0.5, _screenWidth, 0.5)];
    line.backgroundColor = [colorManager lightGrayLineColor];
    [titleBarBackground addSubview:line];
    
    /* title */
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_screenWidth-200)/2, 20, 200, 44)];
    titleLabel.text = @"发现";
    titleLabel.textColor = [colorManager mainTextColor];
    titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 15];
    titleLabel.textAlignment = UITextAlignmentCenter;
    [titleBarBackground addSubview:titleLabel];
    
    // loading 菊花
    _loadingFlower = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingFlower.frame = CGRectMake(0, 20, 44, 44);
    //[_loadingFlower startAnimating];
    //[_loadingFlower stopAnimating];
    [titleBarBackground addSubview:_loadingFlower];
    
    
    /* 创建 tableview */
    [self createTableView];
    
}



#pragma mark - 初始化 tableview 数据

#pragma mark - 创建 tableview
- (void)createTableView
{
    
    /* 创建tableView */
    static NSString *CellWithIdentifier = @"commentCell";
    _oneTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, _screenWidth, _screenHeight-64-49)];
    _oneTableView.backgroundColor = [UIColor brownColor];
    [_oneTableView setDelegate:self];
    [_oneTableView setDataSource:self];
    
    [_oneTableView registerClass:[TopicTableViewCell class] forCellReuseIdentifier:CellWithIdentifier];
    _oneTableView.backgroundColor = [colorManager lightGrayBackground];
    _oneTableView.separatorStyle = UITableViewCellSeparatorStyleNone; // 去掉分割线
    // _oneTableView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0); // 设置距离顶部的一段偏移，继承自scrollview
    // 响应点击状态栏的事件
    _oneTableView.scrollsToTop = YES;
    [self.view addSubview:_oneTableView];
    
    // 下拉刷新 MJRefresh
    _oneTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            // 结束刷新动作
//            [_oneTableView.mj_header endRefreshing];
//            NSLog(@"下拉刷新成功，结束刷新");
//        });
        [self connectForLatestTopics:_oneTableView];
        [self connectForClassifications:_oneTableView];
        [_oneTableView.mj_footer endRefreshing];  // 下拉刷新时，重置一下 mj_footer 的状态
    }];
    
    // 上拉刷新 MJRefresh （等到页面数据加载后再使用）
//    _oneTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        // 结束加载更多
//        // [tableView.mj_footer endRefreshing];
//        // [_oneTableView.mj_footer endRefreshingWithNoMoreData];
//        [self connectForMoreTopics:_oneTableView];
//    }];
    
    // 禁用 mjRefresh
    // contentTableView.mj_footer = nil;
}




#pragma mark - TableView 代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_latestTopicsData count]+1;
}

// 填充cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ClassificationCellWithIdentifier = @"ClassificationCell+";
    SFClassificationTableViewCell *oneClassificationCell = [tableView dequeueReusableCellWithIdentifier:ClassificationCellWithIdentifier];
    
    static NSString *TopicCellWithIdentifier = @"topicCell+";
    TopicTableViewCell *oneTopicCell = [tableView dequeueReusableCellWithIdentifier:TopicCellWithIdentifier];
    
    NSUInteger row = [indexPath row];
    
    if (row == 0) {  // tableview 第一行
        if (oneClassificationCell == nil) {
            oneClassificationCell = [[SFClassificationTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ClassificationCellWithIdentifier];
            oneClassificationCell.delegate = self;   // 设置自定义的cell代理
        }
        [oneClassificationCell rewritePics: _classificationData];
        oneClassificationCell.selectionStyle = UITableViewCellSelectionStyleNone;  // 取消选中的背景色
        return oneClassificationCell;
        
    }
    else {
        if (oneTopicCell == nil) {
            oneTopicCell = [[TopicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TopicCellWithIdentifier];
            oneTopicCell.delegate = self;  // 设置代理
        }
        [oneTopicCell rewriteTitle:[[_latestTopicsData objectAtIndex:row-1] objectForKey:@"title"]];
        [oneTopicCell rewriteintroduction:[[_latestTopicsData objectAtIndex:row-1] objectForKey:@"introduction"]];
        [oneTopicCell rewritePic:[[_latestTopicsData objectAtIndex:row-1] objectForKey:@"portrait"]];
        [oneTopicCell rewriteFollowButton:[[_latestTopicsData objectAtIndex:row-1] objectForKey:@"isFollowing"] forIndex:(int)row-1];
        oneTopicCell.selectionStyle = UITableViewCellSelectionStyleNone;  // 取消选中的背景色
        return oneTopicCell;
    }

    // 直接往cell addsubView的方法会在每次划出屏幕再划回来时 再加载一次subview，因此会重复加载很多subview
}


// 改变 cell 高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    if (row == 0) {
        SFClassificationTableViewCell *cell = (SFClassificationTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.cellHeight;
    }
    
    CGFloat height = 58+24;
    return height;
}


// tableView 点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    if (row == 2) {
        [self chooseLoginWayWith:@"请先登录"];
        return;
    }
    
    if (row >= 1) {
        TopicVC *topicPV = [[TopicVC alloc] init];
        topicPV.topic = [[_latestTopicsData objectAtIndex:row-1] objectForKey:@"title"];
        topicPV.portraitURL = [[_latestTopicsData objectAtIndex:row-1] objectForKey:@"portrait"];
        [self.navigationController pushViewController:topicPV animated:YES];
        //开启iOS7的滑动返回效果
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
    }

}




#pragma mark - 自定义代理：Classification Cell
- (void)clickClassification:(NSString *)classification
{
    NSLog(@"我在点击：%@", classification);
    ClassificationVC *classPage = [[ClassificationVC alloc] init];
    classPage.pageTitle = classification;
    [self.navigationController pushViewController:classPage animated:YES];
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}


#pragma mark - 自定义代理：TopicTableViewCell
- (void)clickFollowButtonForIndex:(unsigned long)index
{
    NSLog(@"%lu",index);
    NSDictionary *topic = [_latestTopicsData objectAtIndex:index];
    NSLog(@"%@", topic);
    
    if (_uid) {
        [self connectForFollowOneTopic:topic uid:_uid cellIndex:(unsigned int)index];  // 发起关注Topic的请求
    } else {
        NSLog(@"请先登录");
    }
}




#pragma mark - 网络请求 - 请求分类
- (void)connectForClassifications:(UITableView *)tableView
{
    NSLog(@"请求classification开始");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/discover/all_classifications"];
    
    NSDictionary *parameters = @{};  // 参数为空
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSArray *data = [responseObject objectForKey:@"data"];
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        NSLog(@"errcode：%@", errcode);
        //NSLog(@"data:%@", data);
        
        [tableView.mj_header endRefreshing];  // 结束下拉刷新
        
        // 更新 Data 数据
        _classificationData = [data copy];
        data = nil;
        
        // 刷新当前 tableview 的数据
        [tableView reloadData];
        // 刷新特定的cell
        // NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        // [_oneTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [tableView.mj_header endRefreshing];
    }];
}



#pragma mark - 网络请求 - 请求最新话题
//（第一次拉取和下拉刷新）
- (void)connectForLatestTopics:(UITableView *)tableView
{
    NSLog(@"请求 latest topics 开始");
    
    // 准备请求参数
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/discover/latest_topics"];
    NSDictionary *parameters = @{@"uid": _uid};
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSArray *data = [responseObject objectForKey:@"data"];
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        NSLog(@"errcode：%@", errcode);
        //NSLog(@"data:%@", data);
        [_loadingFlower stopAnimating];
        
        [tableView.mj_header endRefreshing];  // 结束下拉刷新

        // 更新 Data 数据
        _latestTopicsData = [data mutableCopy];
        data = nil;
        
        // 刷新当前 tableview 的数据
        [tableView reloadData];
        
        // 上拉刷新 MJRefresh （等到页面数据加载后再使用）
        tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [self connectForMoreTopics:_oneTableView];
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [tableView.mj_header endRefreshing];
    }];
}


// 拉取最新话题 - 分页加载
- (void)connectForMoreTopics:(UITableView *)tableView
{
    // 准备请求参数
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/discover/latest_topics"];
    
    // 取得当前最后一个cell的数据id
    NSString *lastID = [[_latestTopicsData lastObject] objectForKey:@"_id"];
    NSDictionary *parameters = @{@"type":@"loadmore",
                                 @"last_id":lastID,
                                 @"uid": _uid
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
            [tableView.mj_footer endRefreshingWithNoMoreData];
            return;
        }
        
        // 更新 Data 数据
        [_latestTopicsData addObjectsFromArray:data];
        data = nil;
        
        // 刷新当前 tableview 的数据
        [tableView reloadData];
        
        [tableView.mj_footer endRefreshing];  // 结束上拉加载更多
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [tableView.mj_footer endRefreshing];
    }];
}


/** 发起关注 Topic 的请求 **/
- (void)connectForFollowOneTopic:(NSDictionary *)topic uid:(NSString *)uid cellIndex:(unsigned)index
{
    NSLog(@"请求 follow 开始");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/topic/follow"];
    
    if ([[topic objectForKey:@"isFollowing"] isEqualToString:@"yes"]) {
        urlString = [host stringByAppendingString:@"/topic/unfollow"];
    }
    
    NSDictionary *parameters = @{
                                 @"uid": uid,
                                 @"topic": [topic objectForKey:@"title"],
                                 @"portrait": [topic objectForKey:@"portrait"],
                                 @"introduction": [topic objectForKey:@"introduction"],
                                 @"is_push_on":@"yes"
                                 };
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        NSLog(@"errcode：%@", errcode);
        NSLog(@"data: %@", data);
        
        if ([errcode isEqualToString:@"err"]) {
            NSLog(@"操作失败，请重试");
            return;
        }
        NSLog(@"关注状态改为%@",[data objectForKey:@"isFollowing"]);
        
        // 刷新 followButton 的状态
        NSMutableDictionary *cellData = [[_latestTopicsData objectAtIndex:index] mutableCopy];
        [cellData setValue:[data objectForKey:@"isFollowing"] forKey:@"isFollowing"];
        [_latestTopicsData replaceObjectAtIndex:index withObject:cellData];
        // 刷新特定的cell
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index + 1 inSection:0];
        [_oneTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}






#pragma mark - 选择登录方式 UIActionSheet
- (void)chooseLoginWayWith:(NSString *)title
{
    NSLog(@"选择登录方式");
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: @"使用新浪微博帐号",nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"新浪微博登录");
        SFLoginAndSignup *Login = [[SFLoginAndSignup alloc] init];
        [Login requestForWeiboAuthorize];
        [Login waitForWeiboAuthorizeResult];
    }
}





@end
