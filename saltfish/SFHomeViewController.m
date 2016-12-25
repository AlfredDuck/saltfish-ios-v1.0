//
//  SFHomeViewController.m
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFHomeViewController.h"
#import "AFNetworking.h"
#import "colorManager.h"
#import "UIImageView+WebCache.h"
#import "YYWebImage.h"
#import "saltFishLaunch.h"
#import "SFHotTableViewCell.h"
#import "SFArticleTableViewCell.h"
#import "SFShareManager.h"
#import "commentVC.h"
#import "detailVC.h"
#import "TopicVC.h"
#import "MJRefresh.h"
#import "urlManager.h"
#import "toastView.h"
#import "SFArticleCell.h"
#import "SFEmptyCell.h"
#import "MJPhotoBrowser.h"  // MJ图片浏览器，使用sdwebimage
#import "MJPhoto.h"  // MJ图片浏览器
//#import "YYPhotoBrowseView.h"  // YY图片浏览器，使用yywebimage
#import "ESPictureBrowser.h"  // ES图片浏览器，使用yywebimage



@interface SFHomeViewController ()
@property (nonatomic, strong) UIView *notificationView;
@property (nonatomic, strong) NSString *articleListStatus;  // 三种状态: unknown, empty, full
@property (nonatomic) NSString *shareArticleID;  // 将要分享的article的id
/**以下用于图片浏览器*/
@property (nonatomic, strong) UIView *currentPicFatherView;  // 当前点击图片的父试图
@property (nonatomic) unsigned long cellIndex;  // 当前点击图片所在的cell
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    // 登录账户的uid
    NSUserDefaults *sfUserDefault = [NSUserDefaults standardUserDefaults];
    if ([sfUserDefault objectForKey:@"loginInfo"]) {
        _uid = [[sfUserDefault objectForKey:@"loginInfo"] objectForKey:@"uid"];
        _userType = [[sfUserDefault objectForKey:@"loginInfo"] objectForKey:@"userType"];
    } else {
        _uid = @"";
        _userType = @"";
    }
    
    /* 构建页面元素 */
    [self createUIParts];
    [super createTabBarWith:0];  // 调用父类方法，构建tabbar
    _articleListStatus = @"unknown";
    
    /* 上传启动信息 */
    saltFishLaunch *launch = [[saltFishLaunch alloc] init];
    [launch basedUUID];  // 上传 uuid
    
    /* 调用 MJRefresh 初始化数据 */
    [_oneTableView.mj_header beginRefreshing];
    
    /* 收听广播 */
    [self waitForNewFollow];
}


- (void)viewWillAppear:(BOOL)animated
{
    // 设置状态栏颜色的强力方法
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    // 检查登录状态是否有变化
    NSUserDefaults *sfUserDefault = [NSUserDefaults standardUserDefaults];
    if ([sfUserDefault objectForKey:@"loginInfo"]) {  // 如果存在用户id
        if (![_uid isEqualToString:[[sfUserDefault objectForKey:@"loginInfo"] objectForKey:@"uid"]]) {  // 当前uid是否是用户id
            NSLog(@"登录状态发生了变化001");
            _uid = [[sfUserDefault objectForKey:@"loginInfo"] objectForKey:@"uid"];
            _userType = [[sfUserDefault objectForKey:@"loginInfo"] objectForKey:@"userType"];
            [_oneTableView.mj_header beginRefreshing];  // 重新拉取一下
        }
    } else {  // 如果不存在登录id
        if (![_uid isEqualToString: @""]) {  // 当前uid是否存在
            NSLog(@"登录状态发生了变化002");
            _uid = @"";
            _userType = @"";
            [_oneTableView.mj_header beginRefreshing];  // 重新拉取一下
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"内存报警...");
    
    // 清理SDWeb缓存
    [[SDImageCache sharedImageCache] clearMemory];  // 清理缓存SDWebImage
    // 清理YYImage缓存
    YYImageCache *cache = [YYWebImageManager sharedManager].cache;
    NSLog(@"YY缓存大小：%lu", (unsigned long)cache.diskCache.totalCost);  // 获取缓存大小
    NSLog(@"YY缓存大小：%lu", (unsigned long)cache.memoryCache.totalCost);  // 获取缓存大小
    [cache.memoryCache removeAllObjects];  // 清空缓存
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
    titleLabel.text = @"贩卖机";
    titleLabel.textColor = [colorManager mainTextColor];
    titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 17.5];
    titleLabel.textAlignment = UITextAlignmentCenter;
    [titleBarBackground addSubview:titleLabel];
    
    // loading 菊花
    _loadingFlower = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingFlower.frame = CGRectMake(0, 20, 44, 44);
    //[_loadingFlower startAnimating];
    //[_loadingFlower stopAnimating];
    [titleBarBackground addSubview:_loadingFlower];
    
    
    // 焦点图数据（临时）
    NSDictionary *d1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"",@"title",
                        @"", @"picURL",
                        nil];
    NSDictionary *d2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"",@"title",
                        @"", @"picURL",
                        nil];
    NSDictionary *d3 = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"",@"title",
                        @"", @"picURL",
                        nil];
    
    NSDictionary *t1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"##",@"title",
                        @"", @"picURL",
                        nil];
    NSDictionary *t2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"##",@"title",
                        @"", @"picURL",
                        nil];
    NSDictionary *t3 = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"##",@"title",
                        @"", @"picURL",
                        nil];
    
    _hotArticleData = @[d1,d2,d3];
    _hotTopicData = @[t1,t2,t3];
    NSArray *dd = @[];
    _followedArticlesData = [dd mutableCopy];
    
    /* 创建 TableView */
    [self createBasedTableView];
    /* 创建焦点图 */
    // [self createHotArticles];

}


#pragma mark - 创建广播条
/** 创建广播条 **/
- (void)createNotificationTap {
    /* 标题栏 */
    _notificationView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, _screenWidth, 34)];
    _notificationView.backgroundColor = [UIColor colorWithRed:132/255.0 green:211/255.0 blue:59/255.0 alpha:1];  // 正向的提示用绿色
    _notificationView.alpha = 0.96;
    [self.view addSubview:_notificationView];
    
    /* 分割线 */
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 34-0.5, _screenWidth, 0.5)];
//    line.backgroundColor = [colorManager lightGrayLineColor];
//    [_notificationView addSubview:line];
    
    /* text */
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_screenWidth-300)/2, 0, 300, 34)];
    titleLabel.text = @"关注了新话题，请刷新查看";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 14];
    titleLabel.textAlignment = UITextAlignmentCenter;
    [_notificationView addSubview:titleLabel];
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

        // 普通加载网络图片 yy库
        picImageView.yy_imageURL = [NSURL URLWithString:[[_data objectAtIndex:i] objectForKey:@"picURL"]];
        
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
    _oneTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, _screenWidth, _screenHeight-64-49)];
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
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            // 结束刷新动作
//            [_oneTableView.mj_header endRefreshing];
//            NSLog(@"下拉刷新成功，结束刷新");
//        });
        [self connectForHot:_oneTableView];
        [self connectForFollowedArticles:_oneTableView];
    }];
    
    // 上拉刷新 MJRefresh (等到页面有数据后再使用)
//    _oneTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        [self connectForMoreFollowedArticles:_oneTableView];
//    }];
    
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
    if ([_articleListStatus isEqualToString:@"unknown"]) {
        return 1;
    }
    else if ([_articleListStatus isEqualToString:@"empty"]) {
        return 2;
    }
    else if ([_articleListStatus isEqualToString:@"full"]){
        return [_followedArticlesData count] + 1;
    }
    else {
        return 1;
    }
}


// 填充cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *articleCellWithIdentifier = @"articleCell+";
    SFArticleCell *oneArticleCell = [tableView dequeueReusableCellWithIdentifier:articleCellWithIdentifier];
    static NSString *hotCellWithIdentifier = @"hotCell+";
    SFHotTableViewCell *oneHotCell = [tableView dequeueReusableCellWithIdentifier:hotCellWithIdentifier];
    static NSString *emptyCellWithIdentifier = @"emptyCell+";
    SFEmptyCell *oneEmptyCell = [tableView dequeueReusableCellWithIdentifier:emptyCellWithIdentifier];
    
    NSUInteger row = [indexPath row];
    if (row == 0) {
        if (oneHotCell == nil) {
            oneHotCell = [[SFHotTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:hotCellWithIdentifier];
            oneHotCell.delegate = self;
        }
        // [oneHotCell rewriteHotArticles:_hotArticleData];
        [oneHotCell rewriteHotTopics:_hotTopicData];
        [oneHotCell rewriteCellHeight];
        oneHotCell.selectionStyle = UITableViewCellSelectionStyleNone;  // 取消选中的背景色
        return oneHotCell;
    }
    else {
        // 如果返回数据是空，则显示 emptyCell
        if ([_articleListStatus isEqualToString:@"empty"]) {
            NSLog(@"是空的");
            oneEmptyCell = [[SFEmptyCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:emptyCellWithIdentifier];
            oneEmptyCell.delegate = self;
            oneEmptyCell.selectionStyle = UITableViewCellSelectionStyleNone;  // 取消选中的背景色
            return oneEmptyCell;
        }
            
        // 如果返回不为空，则...
        if (oneArticleCell == nil) {  // 这里if的条件如果用yes，代表不使用复用池
            oneArticleCell = [[SFArticleCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:articleCellWithIdentifier];
            oneArticleCell.delegate = self;
        }
        // 判断是否含链接
        BOOL isShow;
        if ([NSNull null] == [[_followedArticlesData objectAtIndex:row-1] objectForKey:@"originalLink"]) {
            isShow = NO;
        } else {
            isShow = YES;
        }
        // 字符串转数字
        NSString *shareNumStr = [[_followedArticlesData objectAtIndex:row-1] objectForKey:@"shareNum"];
        unsigned long shareNum = [shareNumStr intValue];
        NSString *commentNumStr = [[_followedArticlesData objectAtIndex:row-1] objectForKey:@"commentNum"];
        unsigned long commentNum = [commentNumStr intValue];
        NSString *likeNumStr = [[_followedArticlesData objectAtIndex:row-1] objectForKey:@"likeNum"];
        unsigned long likeNum = [likeNumStr intValue];
        
        [oneArticleCell rewriteLinkMark:isShow];
        [oneArticleCell rewriteTopic:[[_followedArticlesData objectAtIndex:row-1] objectForKey:@"topic"] withIndex:row-1];
        [oneArticleCell rewritePortrait:[[_followedArticlesData objectAtIndex:row-1] objectForKey:@"topicImageURL"] withIndex:row-1];
        [oneArticleCell rewriteDate:[[_followedArticlesData objectAtIndex:row-1] objectForKey:@"date"]];
        [oneArticleCell rewriteShareNum:shareNum withIndex:row-1];
        [oneArticleCell rewriteCommentNum:commentNum withIndex:row-1];
        [oneArticleCell rewriteLikeNum:likeNum withIndex:row-1];
        [oneArticleCell rewriteAdWithIndex:row-1];
        [oneArticleCell rewriteLikeStatus:[[_followedArticlesData objectAtIndex:row-1] objectForKey:@"likeStatus"]];
        [oneArticleCell rewriteTitle:[[_followedArticlesData objectAtIndex:row-1] objectForKey:@"title"] withLink:isShow];
        [oneArticleCell rewritePicURL:[[_followedArticlesData objectAtIndex:row-1] objectForKey:@"picSmall"] withIndex:row-1];

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
        // 区分 articleCell 和 emptyCell
        if ([_articleListStatus isEqualToString:@"empty"]) {
            return 100;
        } else {
            SFArticleCell *cell = (SFArticleCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
            return cell.cellHeight;
        }
    }
}


// tableView 点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    if (row == 1 && [_articleListStatus isEqualToString:@"empty"]) {
        return;
    }
    
    if (row >= 1) {
        // 检查是否有链接
        if ([NSNull null] == [[_followedArticlesData objectAtIndex:row-1] objectForKey:@"originalLink"]) {
            NSLog(@"没有外链");
            // 左右抖动一下
            [self shake:[tableView cellForRowAtIndexPath:indexPath].contentView];
            return;
        }
        
        detailVC *detailPage = [[detailVC alloc] init];
        detailPage.articleID = [[_followedArticlesData objectAtIndex:row-1] objectForKey:@"_id"];
        detailPage.originalLink = [[_followedArticlesData objectAtIndex:row-1] objectForKey:@"originalLink"];
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

- (void)clickHotArticle:(NSString *)articleID withOriginalLink:(NSString *)originalLink
{
    if (!articleID) {
        return;
    }
    
    detailVC *detailPage = [[detailVC alloc] init];
    detailPage.articleID = articleID;
    detailPage.originalLink = originalLink;
    [self.navigationController pushViewController:detailPage animated:YES];
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)clickHotTopic:(NSString *)topic pic:(NSString *)picURL
{
    NSLog(@"热门话题%@",topic);
    if (!topic) {
        return;
    }
    
    TopicVC *topicPage = [[TopicVC alloc] init];
    topicPage.topic = topic;
    topicPage.portraitURL = picURL;
    [self.navigationController pushViewController:topicPage animated:YES];
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    topicPage = nil;
}







#pragma mark - SFArticleCell 的代理
/** 点击topics */
 - (void)clickTopicForIndex:(unsigned long)index
{
    // 通过index获得话题内容
    NSString *topic = [[_followedArticlesData objectAtIndex:index] objectForKey:@"topic"];
    NSString *portrait = [[_followedArticlesData objectAtIndex:index] objectForKey:@"topicImageURL"];
    
    // 跳转话题页面
    TopicVC *topicPage = [[TopicVC alloc] init];
    topicPage.topic = topic;
    topicPage.portraitURL = portrait;
    [self.navigationController pushViewController:topicPage animated:YES];
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}


/** 点击配图 */
- (void)clickPicsForIndex:(unsigned long)index withCurrentView:(UIView *)view withFatherView:(UIView *)fatherView
{
    unsigned long indexTable = index/100 - 1;  // 取百位
    unsigned long indexPic = index%100;  // 取个位
    NSArray *arr = [[_followedArticlesData objectAtIndex:indexTable] objectForKey:@"picBig"];
    
    // 原图片浏览器
    // [self checkBigPhotos: arr forIndex:indexPic withView:view];
    
    _cellIndex = indexTable;
    _currentPicFatherView = fatherView;
    // 新图片浏览器
    ESPictureBrowser *espb = [[ESPictureBrowser alloc] init];
    espb.delegate = self;
    [espb showFromView:view picturesCount:arr.count currentPictureIndex:indexPic];
}


/** 点击分享 */
- (void)clickShareIconForIndex:(unsigned long)index
{
    _shareArticleID = [[_followedArticlesData objectAtIndex:index] objectForKey:@"_id"];
    UIActionSheet *shareSheet = [[UIActionSheet alloc] initWithTitle:@"分享到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信好友", @"微信朋友圈", @"新浪微博", nil];
    shareSheet.tag = 110;
    [shareSheet showInView:self.view];
}


/** 点击评论 */
- (void)clickCommentIconForIndex:(unsigned long)index
{
    NSLog(@"点击评论icon");
    commentVC *commentPage = [[commentVC alloc] init];
    commentPage.articleID = [[_followedArticlesData objectAtIndex:index] objectForKey:@"_id"];
    [self.navigationController pushViewController:commentPage animated:YES];
    
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}


/** 点击喜欢 */
- (void)clickLikeIconForIndex:(unsigned long)index
{
    // 发起喜欢的请求
    NSString *articleID = [[_followedArticlesData objectAtIndex:index] objectForKey:@"_id"];
    [self connectForLikeWith: articleID cellIndex:index];  // 发起like请求
}


/** 点击广告投诉 */
- (void)clickAdIconForIndex:(unsigned long)index
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"隐藏此文章？" message:@"小主三思啊" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定隐藏", nil];
    alert.tag = index + 1;
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    unsigned long index = (unsigned long)alertView.tag - 1;

    if (buttonIndex == 1) {
        NSLog(@"隐藏第%ld个", index);
        // 发起隐藏某文章的请求
        NSString *articleID = [[_followedArticlesData objectAtIndex:index] objectForKey:@"_id"];
        NSLog(@"%@", articleID);
        [self connectForHideWith:articleID];
    }
}






#pragma mark - EmptyCell 的代理
- (void)clickButton
{
    // 点击“随便逛逛”按钮，切换到发现tab
    self.tabBarController.selectedIndex = 1;
}










#pragma mark - 网络请求 - 热门文章&话题
/* 请求热门文章(焦点图)&热门话题 */
- (void)connectForHot:(UITableView *)tableView
{
    NSLog(@"请求焦点图开始");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/index/hots"];
    
    NSDictionary *parameters = @{};  // 参数为空
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        NSLog(@"errcode：%@", errcode);
        NSLog(@"data:%@", data);
        
        // 结束下啦刷新
        [tableView.mj_header endRefreshing];
        
        // 更新 hotArticleData 数据
        _hotArticleData = [[data objectForKey:@"hotArticles"] copy];
        // 更新 hotTopicData 数据
        _hotTopicData = [[data objectForKey:@"hotTopics"] copy];
        
        // 刷新特定的cell
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        [_oneTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [tableView.mj_header endRefreshing];
    }];
    
    NSLog(@"阻塞了吗？");
}










#pragma mark - 网络请求 - 我关注话题的最新文章
/* 初次拉取 */
- (void)connectForFollowedArticles:(UITableView *)tableView
{
    NSLog(@"请求followedArticles开始");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/index/followed_articles"];
    NSDictionary *parameters = @{@"uid": _uid,
                                 @"user_type": _userType
                                 };
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSArray *data = [responseObject objectForKey:@"data"];
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        NSLog(@"errcode：%@", errcode);
        NSLog(@"data:%@", data);
        
        if ([errcode isEqualToString:@"err"]) {
            [tableView.mj_header endRefreshing];  // 结束下拉刷新
            return;
        }
        
        // 结束下拉刷新
        [tableView.mj_header endRefreshing];
        
        if ([data count]==0) {  // 如果为空
            _articleListStatus = @"empty";
            tableView.mj_footer = nil;
        } else {
            _articleListStatus = @"full";
            // 上拉刷新 MJRefresh (等到页面有数据后再使用)
            tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                [self connectForMoreFollowedArticles:_oneTableView];
            }];
        }
        
        // 更新 followedArticleData 数据
        _followedArticlesData = [data mutableCopy];
        
        // 刷新当前 tableview 的数据
        [tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [tableView.mj_header endRefreshing];
    }];
}



/* 拉取更多 */
- (void)connectForMoreFollowedArticles:(UITableView *)tableView
{
    NSLog(@"请求 moreFollowedArticles开始");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/index/followed_articles"];
    
    // 取得当前最后一个cell的数据id
    NSString *lastID = [[_followedArticlesData lastObject] objectForKey:@"_id"];
    NSString *postTime = [[_followedArticlesData lastObject] objectForKey:@"postTime"];
    NSDictionary *parameters = @{@"last_id":lastID,
                                 @"type":@"loadmore",
                                 @"post_time":postTime,
                                 @"uid": _uid,
                                 @"user_type": _userType
                                 };

    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSArray *data = [responseObject objectForKey:@"data"];
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        NSLog(@"errcode：%@", errcode);
        NSLog(@"data:%@", data);
        
        if ([errcode isEqualToString:@"err"]) {
            [tableView.mj_footer endRefreshing];
            return;
        }
        if ([data count] == 0) {
            [tableView.mj_footer endRefreshingWithNoMoreData];
            return;
        }
        
        // 更新 followedArticleData 数据
        [_followedArticlesData addObjectsFromArray:data];
        data = nil;
        
        // 刷新当前 tableview 的数据
        [tableView reloadData];
        
        [tableView.mj_footer endRefreshing];  // 结束上拉加载更多
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [tableView.mj_footer endRefreshing];  // 结束上拉加载更多
    }];
}



/** 喜欢一个article请求 **/
- (void)connectForLikeWith:(NSString *)articleID cellIndex:(unsigned long)index
{
    NSLog(@"请求喜欢一个article");
    
    // 要添加or取消一个喜欢
    NSString *isCancel = [[_followedArticlesData objectAtIndex:index] objectForKey:@"likeStatus"];
    NSLog(@"%@", isCancel);
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/article/like"];
    NSDictionary *parameters = @{
                                 @"uid": _uid,
                                 @"user_type": _userType,
                                 @"article_id": articleID,
                                 @"is_cancel": isCancel
                                 };
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSLog(@"errcode：%@", errcode);
        NSLog(@"data: %@", data);
        
        // server错误判断
        if ([errcode isEqualToString:@"err"]) {
            NSLog(@"喜欢or取消一个article失败，请重试");
            return;
        }
        
        NSLog(@"喜欢or取消一个article成功");
        // 1.修改内存中的数据
        NSLog(@"%@", [[_followedArticlesData objectAtIndex:index] objectForKey:@"title"]);
        NSMutableDictionary *cellData = [[_followedArticlesData objectAtIndex:index] mutableCopy];
        [cellData setValue:[data objectForKey:@"status"] forKey:@"likeStatus"];
        [cellData setValue:[data objectForKey:@"likeNum"] forKey:@"likeNum"];
        [_followedArticlesData replaceObjectAtIndex:index withObject:cellData];
        
        // 2.刷新特定cell
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index + 1 inSection:0];
        [_oneTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


/** 隐藏一个article的请求 */
- (void)connectForHideWith:(NSString *)articleID
{
    NSLog(@"请求隐藏一个article");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/article/hide"];
    NSDictionary *parameters = @{@"article_id": articleID};
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSLog(@"errcode：%@", errcode);
        NSLog(@"data: %@", data);
        
        // server错误判断
        if ([errcode isEqualToString:@"err"]) {
            NSLog(@"隐藏一个article失败，请重试");
            return;
        }
        
        NSLog(@"隐藏一个article成功");
        [toastView showToastWith:@"隐藏成功" isErr:YES duration:2.0 superView:self.view];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}







#pragma mark - UIActionSheet 代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 110) {
        // 分享sheet
        SFShareManager *shareManager = [[SFShareManager alloc] init];
        
        if (buttonIndex == 0) {
            NSLog(@"微信好友");
            [shareManager connectForShareInfoWith:_shareArticleID toWhere:@"weixin"];
        }else if (buttonIndex == 1) {
            NSLog(@"微信朋友圈");
            [shareManager connectForShareInfoWith:_shareArticleID toWhere:@"weixin_timeline"];
        }else if(buttonIndex == 2) {
            NSLog(@"新浪微博");
            [shareManager connectForShareInfoWith:_shareArticleID toWhere:@"weibo"];
        }
    }
    
    else if (actionSheet.tag == 120) {
        // 登录sheet
        if (buttonIndex == 0) {
            NSLog(@"新浪微博登录");
            SFThirdLoginViewController *loginPage = [[SFThirdLoginViewController alloc] init];
            [self.navigationController presentViewController:loginPage animated:YES completion:^{
                return;
            }];
        }
    }
}









#pragma mark - 图片浏览器 基于SDWebImage
- (void)checkBigPhotos:(NSArray *)urls forIndex:(unsigned long)index withView:(UIView *)view
{
    //1.创建图片浏览器
    MJPhotoBrowser *brower = [[MJPhotoBrowser alloc] init];
    
    //2.告诉图片浏览器显示所有的图片
    NSMutableArray *photos = [NSMutableArray new];
    for (NSString *urlStr in urls) {
        //传递数据给浏览器
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:urlStr];
        // photo.srcImageView = (UIImageView *)view;
        [photos addObject:photo];
    }
    brower.photos = photos;
    
    //3.设置默认显示的图片索引
    brower.currentPhotoIndex = index;
    brower.showSaveBtn = 0;  // 0是禁用保存按钮，1是允许
    
    //4.显示浏览器
    [brower show];
}



#pragma mark - 图片浏览器 基于YYWebImage
/** ESPictureBrowser 代理 */
- (UIView *)pictureView:(ESPictureBrowser *)pictureBrowser viewForIndex:(NSInteger)index
{
    return _currentPicFatherView.subviews[index];
}

- (NSString *)pictureView:(ESPictureBrowser *)pictureBrowser highQualityUrlStringForIndex:(NSInteger)index
{
    return _followedArticlesData[_cellIndex][@"picBig"][index];
}






#pragma mark - 左右抖动
/**代码来自网络**/
- (void)shake:(UIView *)senderView
{
    CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    shake.fromValue = [NSNumber numberWithFloat:-5];
    shake.toValue = [NSNumber numberWithFloat:5];
    shake.duration = 0.08;//执行时间
    shake.autoreverses = YES; //是否重复
    shake.repeatCount = 2;//次数
    [senderView.layer addAnimation:shake forKey:@"shakeAnimation"];
}



#pragma mark - 注册观察者 - 是否有新的关注
/** 注册观察者 - 是否有新的关注 **/
- (void)waitForNewFollow
{
    // 收听到关注成功
    [[NSNotificationCenter defaultCenter] addObserverForName:@"followSuccess" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"%@", note.name);
        NSLog(@"%@", note.object);
        NSLog(@"收听到关注成功");
        // [self createNotificationTap];  // 显示广播条
    }];
}




@end
