//
//  SFHomeViewController.m
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFHomeViewController.h"
#import "colorManager.h"
#import "UIImageView+WebCache.h"
#import "SFHotTableViewCell.h"
#import "articleCell.h"
#import "MJRefresh.h"


@interface SFHomeViewController ()

@end

@implementation SFHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"test";
        self.view.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.hidden = YES;
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
    titleLabel.text = @"咸鱼腥闻";
    titleLabel.textColor = [colorManager mainTextColor];
    titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 15];
    titleLabel.textAlignment = UITextAlignmentCenter;
    [titleBarBackground addSubview:titleLabel];
    
    
    // 焦点图数据（临时）
    NSDictionary *d1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"001三吉彩花又特么来中国捞钱了",@"title",
                        @"http://fc.topitme.com/c/a7/18/11398941169b318a7cl.jpg", @"url",
                        nil];
    NSDictionary *d2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"002国风灯具所承载的东方韵味总是让人感到内心的平实。在酷暑难耐的夜晚",@"title",
                        @"http://i10.topitme.com/l044/10044083580cb1e8f4.jpg", @"url",
                        nil];
    NSDictionary *d3 = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"003《权力的游戏》一季终，以后周一的期待又少了一个。 第六季大结局可以说把整季燃到了最高点",@"title",
                        @"http://f7.topitme.com/7/a4/75/115044609142d75a47l.jpg", @"url",
                        nil];
    
    NSArray *data = @[d1,d2,d3];
    
    
    /* 创建 tableview */
    static NSString *CellWithIdentifier = @"commentCell";
    _oneTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, _screenWidth, _screenHeight-64)];
    _oneTableView.backgroundColor = [UIColor brownColor];
    [_oneTableView setDelegate:self];
    [_oneTableView setDataSource:self];
    
    [_oneTableView registerClass:[SFHotTableViewCell class] forCellReuseIdentifier:CellWithIdentifier];
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
    static NSString *hotCellWithIdentifier = @"hotCell+";
    SFHotTableViewCell *oneHotCell = [tableView dequeueReusableCellWithIdentifier:hotCellWithIdentifier];
    
    static NSString *articleCellWithIdentifier = @"articleCell+";
    articleCell *oneArticleCell = [tableView dequeueReusableCellWithIdentifier:articleCellWithIdentifier];
    
    NSUInteger row = [indexPath row];
    
    if (row == 0) {  // tableview 第一行
        if (oneHotCell == nil) {
            oneHotCell = [[SFHotTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:hotCellWithIdentifier];
        }
        oneHotCell.selectionStyle = UITableViewCellSelectionStyleNone;  // 取消选中的背景色
        return oneHotCell;
        
    } else {
        if (oneArticleCell == nil) {
            oneArticleCell = [[articleCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:articleCellWithIdentifier];
        }
        oneArticleCell.selectionStyle = UITableViewCellSelectionStyleNone;  // 取消选中的背景色
        return oneArticleCell;
    }
    
    // 直接往cell addsubView的方法会在每次划出屏幕再划回来时 再加载一次subview，因此会重复加载很多subview
}

// 改变 cell 高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    if (row == 0) {
//        SFClassificationTableViewCell *cell = (SFClassificationTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
//        return cell.cellHeight;
        return 170;
    }
    
    CGFloat height = 58+24;
    return height;
}


// tableView 点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
//    TopicVC *topicPV = [[TopicVC alloc] init];
//    [self.navigationController pushViewController:topicPV animated:YES];
//    //开启iOS7的滑动返回效果
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
//    }
}





@end
