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
#import "SFArticleTableViewCell.h"
#import "detailVC.h"
#import "TopicVC.h"
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
    titleLabel.text = @"轻闻";
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
    NSDictionary *d4 = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"004墙绘，顾名思义就是在墙上作画。 如果可以",@"title",
                        @"http://f10.topitme.com/l/201102/13/12975663235538.jpg", @"url",
                        nil];
    NSDictionary *d5 = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"005大概没几个插画师能抵得住",@"title",
                        @"http://f10.topitme.com/l/201102/13/12975659369227.jpg", @"url",
                        nil];
    
    NSDictionary *t1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"#台湾肯定音乐祭#",@"title",
                        @"http://f10.topitme.com/m/201102/13/12975675911220.jpg", @"url",
                        nil];
    NSDictionary *t2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"#Sunshine#",@"title",
                        @"http://f10.topitme.com/t/201012/19/12927225068850.jpg", @"url",
                        nil];
    NSDictionary *t3 = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"#吴亦凡艹粉#",@"title",
                        @"http://f10.topitme.com/l/201102/13/12975659369227.jpg", @"url",
                        nil];
    
    _data = @[d1,d2,d3,d4,d5];
    _data2 = @[t1,t2,t3];
    
    /* 创建 TableView */
    [self createBasedTableView];
    /* 创建焦点图 */
    //[self createHotArticles];

}



#pragma mark - 创建 热门话题
- (void)createHotTopics
{
    
}


#pragma mark - 创建焦点图(热门文章）(在cell中实现了，这里的代码用不到了，但是不要删除）
- (void)createHotArticles
{
    /* ============= 焦点图 ScrollView ============== */
    
    _basedScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, _screenWidth, 170)];
    _basedScrollView.backgroundColor = [UIColor grayColor];
    _basedScrollView.delegate = self;
    
    //这个属性很重要，它可以决定是横向还是纵向滚动，一般来说也是其中的 View 的总宽度，和总的高度
    //这里同时考虑到每个 View 间的空隙，所以宽度是 200x3＋5＋10＋10＋5＝630
    //高度上与 ScrollView 相同，只在横向扩展，所以只要在横向上滚动
    _basedScrollView.contentSize = CGSizeMake(_screenWidth*3, 170);
    //用它指定 ScrollView 中内容的当前位置，即相对于 ScrollView 的左上顶点的偏移
    _basedScrollView.contentOffset = CGPointMake(0, 0);
    //按页滚动，总是一次一个宽度，或一个高度单位的滚动
    _basedScrollView.pagingEnabled = YES;
    //隐藏滚动条
    _basedScrollView.showsVerticalScrollIndicator = FALSE;
    _basedScrollView.showsHorizontalScrollIndicator = FALSE;
    // 是否边缘反弹
    _basedScrollView.bounces = YES;
    // 不响应点击状态栏的事件（留给uitableview用）
    _basedScrollView.scrollsToTop = NO;
    
    [self.view addSubview:_basedScrollView];
    
    
    /* 循环创建轮播的图片 */
    for (int i=0; i<3; i++) {
        
        UIImageView *picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_screenWidth*i, 0, _screenWidth, 170)];
        picImageView.backgroundColor = [UIColor grayColor];
        
        // uiimageview居中裁剪
        picImageView.contentMode = UIViewContentModeScaleAspectFill;
        picImageView.clipsToBounds  = YES;
        // 需要AFNetwork
        [picImageView sd_setImageWithURL:[NSURL URLWithString:[[_data objectAtIndex:i] objectForKey:@"url"]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        
        // 遮黑
        UIView *halfBlack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 170)];
        halfBlack.backgroundColor  = [UIColor blackColor];
        halfBlack.alpha = 0.22;
        [picImageView addSubview:halfBlack];
        
        // 文本
        UILabel *picLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 0, _screenWidth-54*2, 170)];
        picLabel.text = [[_data objectAtIndex:i] objectForKey:@"title"];
        picLabel.textColor  = [UIColor whiteColor];
        picLabel.font = [UIFont fontWithName:@"Helvetica" size: 18.0f];
        picLabel.numberOfLines = 2;
        picLabel.textAlignment = UITextAlignmentCenter;
        // 文字阴影
        picLabel.layer.shadowOpacity = 0.8;
        picLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        picLabel.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        picLabel.layer.shadowRadius = 1.0;
        [picImageView addSubview:picLabel];
        
        [_basedScrollView addSubview:picImageView];
    }

}



#pragma mark - 创建 TableView
- (void)createBasedTableView
{
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
    
    // 这个碉堡了，要珍藏！！
    // _oneTableView.mj_header.ignoredScrollViewContentInsetTop = 100.0;
    
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
    static NSString *articleCellWithIdentifier = @"articleCell+";
    SFArticleTableViewCell *oneArticleCell = [tableView dequeueReusableCellWithIdentifier:articleCellWithIdentifier];
    
    static NSString *hotCellWithIdentifier = @"hotCell+";
    SFHotTableViewCell *oneHotCell = [tableView dequeueReusableCellWithIdentifier:hotCellWithIdentifier];
    
    NSUInteger row = [indexPath row];
    if (row == 0) {
        if (oneHotCell == nil) {
            oneHotCell = [[SFHotTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:hotCellWithIdentifier];
            oneHotCell.delegate = self;
        }
        [oneHotCell rewriteHotArticles:_data];
        [oneHotCell rewriteHotTopics:_data2];
        [oneHotCell rewriteCellHeight];
        oneHotCell.selectionStyle = UITableViewCellSelectionStyleNone;  // 取消选中的背景色
        return oneHotCell;
    }
    else {
        if (oneArticleCell == nil) {
            oneArticleCell = [[SFArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:articleCellWithIdentifier];
        }
        [oneArticleCell rewriteTitle:@"哈格兹的相册-那天阳光很好可惜我只带了一卷彩卷\n"];
        [oneArticleCell rewriteHotScore:@"评论23  点赞876"];
        [oneArticleCell rewriteTopics:@"#胶片摄影#"];
        [oneArticleCell rewritePicURL:@"https://img3.doubanio.com/view/photo/photo/public/p2246653686.jpg"];
        [oneArticleCell rewriteTopicImageURL:@"https://img3.doubanio.com/view/photo/thumb/public/p2308564994.jpg"];
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
        SFHotTableViewCell *cell = (SFHotTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.cellHeight;
    }
    else {
        return 145;
    }
}


// tableView 点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    if (row >= 1) {
        detailVC *detailPage = [[detailVC alloc] init];
        detailPage.articleID = @"ddddd";
        [self.navigationController pushViewController:detailPage animated:YES];
        //开启iOS7的滑动返回效果
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
    }

    // 返回时是非选中状态
    // [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




#pragma mark - ScrollView 代理

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_basedScrollView]) {
        NSLog(@"少时诵诗书");
        NSLog(@"ScrollView 减速停止");
        NSLog(@"ScrollView偏移：%f", scrollView.contentOffset.x);
    }
    NSLog(@"ggg");
}



#pragma mark - HotCell（第一个cell） 的代理

- (void)clickHotArticle:(NSString *)articleID
{
    detailVC *detailPage = [[detailVC alloc] init];
    detailPage.articleID = @"ddddd";
    [self.navigationController pushViewController:detailPage animated:YES];
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)clickHotTopic:(NSString *)topic
{
    TopicVC *topicPage = [[TopicVC alloc] init];
    [self.navigationController pushViewController:topicPage animated:YES];
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}




@end
