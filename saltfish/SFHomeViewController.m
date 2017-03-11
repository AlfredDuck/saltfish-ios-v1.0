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
@property (nonatomic, strong) NSString *articleListStatus;  // 页面三种状态: unknown, empty, full
@property (nonatomic) NSString *shareArticleID;  // 将要分享的article的id
/** 以下用于图片浏览器 */
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
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleBarBackground addSubview:titleLabel];
    
    // loading 菊花
    _loadingFlower = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingFlower.frame = CGRectMake(0, 20, 44, 44);
    //[_loadingFlower startAnimating];
    //[_loadingFlower stopAnimating];
    [titleBarBackground addSubview:_loadingFlower];
    
    /* 创建 TableView */
    [self createBasedTableView];
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
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [_notificationView addSubview:titleLabel];
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
    _oneTableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0); // 设置距离顶部的一段偏移，继承自scrollview
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
        [self connectForHot:_oneTableView withRefresh:YES];
//        [self connectForFollowedArticles:_oneTableView];
    }];
    
    // 上拉刷新 MJRefresh (等到页面有数据后再使用)
//    _oneTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        [self connectForMoreFollowedArticles:_oneTableView];
//    }];
    
    // 这个碉堡了，要珍藏！！
    _oneTableView.mj_header.ignoredScrollViewContentInsetTop = 8;
    
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
        return 0;
    }
    else if ([_articleListStatus isEqualToString:@"empty"]) {
        return 1;
    }
    else if ([_articleListStatus isEqualToString:@"full"]){
        return [_followedArticlesData count];
    }
    else {
        return 0;
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

    // 如果返回数据是空，则显示 emptyCell
    if ([_articleListStatus isEqualToString:@"empty"]) {
        NSLog(@"是空的");
        oneEmptyCell = [[SFEmptyCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:emptyCellWithIdentifier];
        oneEmptyCell.delegate = self;
        oneEmptyCell.selectionStyle = UITableViewCellSelectionStyleNone;  // 取消选中的背景色
        return oneEmptyCell;
    }
        
    // 如果返回不为空，则...
    // 根据数据类型，选择渲染哪种cell
    if ([_followedArticlesData[row][@"data_type"] isEqualToString:@"article"]) {
        if (oneArticleCell == nil) {  // 这里if的条件如果用yes，代表不使用复用池
            oneArticleCell = [[SFArticleCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:articleCellWithIdentifier];
            oneArticleCell.delegate = self;
        }
        // 判断是否含链接
        BOOL isShow;
        if ([NSNull null] == [[_followedArticlesData objectAtIndex:row] objectForKey:@"originalLink"]) {
            isShow = NO;
        } else {
            isShow = YES;
        }
        // 字符串转数字
        NSString *shareNumStr = _followedArticlesData[row][@"shareNum"];
        unsigned long shareNum = [shareNumStr intValue];
        NSString *commentNumStr = _followedArticlesData[row][@"commentNum"];
        unsigned long commentNum = [commentNumStr intValue];
        NSString *likeNumStr = _followedArticlesData[row][@"likeNum"];
        unsigned long likeNum = [likeNumStr intValue];
        
        [oneArticleCell rewriteLinkMark:isShow];
        [oneArticleCell rewriteTopic:_followedArticlesData[row][@"topic"] withIndex:row];
        [oneArticleCell rewritePortrait:_followedArticlesData[row][@"topicImageURL"] withIndex:row];
        [oneArticleCell rewriteDate:_followedArticlesData[row][@"date"]];
        [oneArticleCell rewriteShareNum:shareNum withIndex:row];
        [oneArticleCell rewriteCommentNum:commentNum withIndex:row];
        [oneArticleCell rewriteLikeNum:likeNum withIndex:row];
        [oneArticleCell rewriteAdWithIndex:row];
        [oneArticleCell rewriteLikeStatus:_followedArticlesData[row][@"likeStatus"]];
        [oneArticleCell rewriteTitle:_followedArticlesData[row][@"title"] withLink:isShow];
        [oneArticleCell rewritePicURL:_followedArticlesData[row][@"picSmall"] withIndex:row];
        
        oneArticleCell.selectionStyle = UITableViewCellSelectionStyleNone;  // 取消选中的背景色
        return oneArticleCell;
    } else {
        if (oneHotCell == nil) {
            oneHotCell = [[SFHotTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:hotCellWithIdentifier];
            oneHotCell.delegate = self;
        }
        [oneHotCell rewriteHotTopics:_followedArticlesData[row][@"data"]];
        [oneHotCell rewriteCellHeight];
        oneHotCell.selectionStyle = UITableViewCellSelectionStyleNone;  // 取消选中的背景色
        return oneHotCell;
    }
    // 直接往cell addsubView的方法会在每次划出屏幕再划回来时 再加载一次subview，因此会重复加载很多subview
}



// 改变 cell 高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    // 区分 articleCell 和 emptyCell
    if ([_articleListStatus isEqualToString:@"empty"]) {
        return 100;
    } else if ([_followedArticlesData[row][@"data_type"] isEqualToString:@"article"]) {
        SFArticleCell *cell = (SFArticleCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.cellHeight;
    } else {
        SFHotTableViewCell *cell = (SFHotTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.cellHeight;
    }
}


// tableView 点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    if ([_articleListStatus isEqualToString:@"empty"] ||
        [_followedArticlesData[row][@"data_type"] isEqualToString:@"topic"]) {
        return;
    } else {
        // 检查是否有链接
        if ([NSNull null] == [[_followedArticlesData objectAtIndex:row] objectForKey:@"originalLink"]) {
            NSLog(@"没有外链");
            // 左右抖动一下
            [self shake:[tableView cellForRowAtIndexPath:indexPath].contentView];
            return;
        }
        
        detailVC *detailPage = [[detailVC alloc] init];
        detailPage.articleID = _followedArticlesData[row][@"_id"];
        detailPage.originalLink = _followedArticlesData[row][@"originalLink"];
        [self.navigationController pushViewController:detailPage animated:YES];
        //开启iOS7的滑动返回效果
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
    }

    // 返回时是非选中状态
    // [tableView deselectRowAtIndexPath:indexPath animated:YES];
}





#pragma mark - 混合数据
/*
 * 将 文章cell 和 推荐话题cell 混合显示前，需要将数据做混合
 *
 */
- (NSArray *)combineDataWithArticles:(NSArray *)articles
{
    NSMutableArray *partArr = [NSMutableArray new];
    
    for (int i=0; i<articles.count; i++) {
        NSMutableDictionary *articleDic = [articles[i] mutableCopy];
        [articleDic setObject:@"article" forKey:@"data_type"];
        [partArr addObject: articleDic];
        
        if (i==4 || i==14) {  // 在每页的第5和15位置插入
            NSMutableDictionary *topicDic = [NSMutableDictionary new];
            [topicDic setObject:@"topic" forKey:@"data_type"];
            if (i==4) {  // 第一个位置取前三个数据
                NSArray *sub = [_hotTopicData subarrayWithRange:NSMakeRange(0,3)];
                [topicDic setObject:sub forKey:@"data"];
            } else if (i==14) {  // 第二个位置取后三个数据
                NSArray *sub = [_hotTopicData subarrayWithRange:NSMakeRange(3,3)];
                [topicDic setObject:sub forKey:@"data"];
            }
            [partArr addObject: topicDic];
        }
    }
    return partArr;
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
- (void)connectForHot:(UITableView *)tableView withRefresh:(BOOL)isRefresh
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

        // 更新 hotTopicData 数据
        _hotTopicData = [[data objectForKey:@"hotTopics"] copy];
        
        
        //
        if (isRefresh) {
            [self connectForFollowedArticles:_oneTableView];
        } else {
            [self connectForMoreFollowedArticles:_oneTableView];
        }
        
        // 刷新特定的cell
//        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
//        [_oneTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        
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
                [self connectForHot:_oneTableView withRefresh:NO];
//                [self connectForMoreFollowedArticles:_oneTableView];
            }];
        }
        
        // 更新 followedArticleData 数据
        NSArray *d = [self combineDataWithArticles:data];
        _followedArticlesData = [d mutableCopy];
        
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
        NSArray *d = [self combineDataWithArticles:data];
        [_followedArticlesData addObjectsFromArray:d];
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
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
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
