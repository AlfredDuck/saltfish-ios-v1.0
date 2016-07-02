//
//  SFDiscoveryViewController.m
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFDiscoveryViewController.h"
#import "colorManager.h"
#import "SFClassificationTableViewCell.h"
#import "TopicTableViewCell.h"
#import "TopicVC.h"
#import "MJRefresh.h"


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
    
    [self createUIParts];
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
    
    
    /* 创建tableView */
    static NSString *CellWithIdentifier = @"commentCell";
    _oneTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, _screenWidth, _screenHeight-64)];
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
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             // 结束刷新动作
             [_oneTableView.mj_header endRefreshing];
             NSLog(@"下拉刷新成功，结束刷新");
         });

    }];
    
    // 上拉刷新 MJRefresh
    _oneTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        // 结束加载更多
        // [tableView.mj_footer endRefreshing];
        [_oneTableView.mj_footer endRefreshingWithNoMoreData];
    }];
    
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
    return 20;
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
        }
        [oneClassificationCell rewritePics:@[@"旅行",@"娱乐八卦",@"Sunshine",@"电影",@"黑客帝国",@"科技圈",@"洛丽塔",@"肉体女生"]];
        oneClassificationCell.selectionStyle = UITableViewCellSelectionStyleNone;  // 取消选中的背景色
        return oneClassificationCell;
        
    } else {
        if (oneTopicCell == nil) {
            oneTopicCell = [[TopicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TopicCellWithIdentifier];
        }
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
    
    TopicVC *topicPV = [[TopicVC alloc] init];
    [self.navigationController pushViewController:topicPV animated:YES];
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}





@end
