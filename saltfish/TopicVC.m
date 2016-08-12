//
//  TopicVC.m
//  saltfish
//
//  Created by alfred on 16/6/19.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "TopicVC.h"
#import <AFNetworking/AFNetworking.h>
#import <Accelerate/Accelerate.h>
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "colorManager.h"
#import "urlManager.h"
#import "toastView.h"
#import "SFArticleTableViewCell.h"
#import "TopicCell.h"
#import "detailVC.h"
#import "SFLoginAndSignup.h"
#import "SFLoginViewController.h"


@interface TopicVC ()
// 私有变量
@property (nonatomic) float backgroundImageHeight;
@property (nonatomic) NSString *isFollowing;
@property (nonatomic) NSString *isPushOn;
@end

@implementation TopicVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"test";
        self.view.backgroundColor = [UIColor grayColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _backgroundImageHeight = 64+70;
}

- (void)viewWillAppear:(BOOL)animated {
    // 设置状态栏颜色的强力方法
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // 获取登录账户id
    NSUserDefaults *sf = [NSUserDefaults standardUserDefaults];
    if ([sf objectForKey:@"loginInfo"]) {
        _uid = [[sf objectForKey:@"loginInfo"] objectForKey:@"uid"];
    } else {
        _uid = @"";
    }
    
    if (_articleData) {
        return;
    }
    
    // 初始化站位数据
    _topicData = [[NSDictionary alloc] initWithObjectsAndKeys:
                _topic, @"title",
                @"         ", @"introduction",
                @"no", @"isFollowing",
                @"no", @"isPushOn",
                  nil];
    _isFollowing = @"no";
    _isPushOn = @"no";
    
    NSArray *dd = @[];
    _articleData = [dd mutableCopy];
    
    [self createUIParts];
    [self connectForTopicCell:_oneTableView];
    [self connectForArticleCell:_oneTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - 构建 UI 零件
- (void)createUIParts
{
    /* 整个顶部滑动动效分三部分：背景图(中层）、tableView（下层）、头像图片（上层）*/
        
    // 创建 TableView
    [self createTableView];

    
    /* 创建背景图 */
    _backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _backgroundImageHeight)];
    _backgroundView.backgroundColor = [UIColor brownColor];
//    _backgroundView.alpha = 0.5;
    // uiimageview居中裁剪
    _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundView.clipsToBounds  = YES;
    // 需要AFNetwork（异步加载）
    [_backgroundView sd_setImageWithURL:[NSURL URLWithString:_portraitURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSLog(@"%@", imageURL);
        UIImage *imgBlur = [self boxblurImage:image withBlurNumber:(CGFloat)0.60f];
        [_backgroundView setImage:imgBlur];
    }];
    
    [self.view addSubview:_backgroundView];
    
    
    /* 创建头像图片 */
    _portraitView = [[UIImageView alloc] initWithFrame:CGRectMake(_screenWidth/2.0-42, 92, 84, 84)];
    _portraitView.backgroundColor = [UIColor brownColor];
    // uiimageview居中裁剪
    _portraitView.contentMode = UIViewContentModeScaleAspectFill;
    _portraitView.clipsToBounds  = YES;
    // 需要AFNetwork（延后处理）
    [_portraitView sd_setImageWithURL:[NSURL URLWithString:_portraitURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    [self.view addSubview:_portraitView];
    
    
    /*=================================================================*/
    // 导航栏和返回按钮
    // back button pic
    UIImage *oneImage = [UIImage imageNamed:@"back2.png"]; // 使用ImageView通过name找到图片
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
    [self.view addSubview:backView];
    
    // title
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_screenWidth-200)/2, 20, 200, 44)];
    _titleLabel.text = _topic;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 16.0];
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.hidden = YES;
    [self.view addSubview:_titleLabel];
}



#pragma mark - TableView 滚动事件
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"滚动事件发生");
    NSLog(@"tableview偏移：%f",scrollView.contentOffset.y);
    
    /* 背景图控制 */
    float hh = -scrollView.contentOffset.y + 64;
    NSLog(@"%f",hh);
    
    // 当背景图高度最小为64，不能更小了
    if (hh <= 64.0) {
        _backgroundView.frame = CGRectMake(0, 0, _screenWidth, 64.0);
        _titleLabel.hidden = NO;
        //取消偏移 （底部的44px是给MJRefresh的上拉加载留出的）
        _oneTableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0); // 设置距离顶部的一段偏移，继承自scrollview
    }
    else {
        // 背景图的高度随着tableview的cntentoffset变化
        _backgroundView.frame = CGRectMake(0, 0, _screenWidth, hh);
        _titleLabel.hidden = YES;
        //恢复偏移
        _oneTableView.contentInset = UIEdgeInsetsMake(-20+90, 0, 0, 0); // 设置距离顶部的一段偏移，继承自scrollview
    }
    
    /* 头像控制 */
    float yy = -scrollView.contentOffset.y + (64-58);
    // 150是背景图height，92是头像y
    
    // 修改头像高度
    _portraitView.frame = CGRectMake((_screenWidth-84)/2.0, yy, 84, 84);
    // 修改头像透明度
    if (yy <= 74.0) {
        _portraitView.alpha = (yy-10)/(80.0-10);
    }
    else {
        _portraitView.alpha = 1;
    }
}



#pragma mark - 高斯模糊
- (UIImage *)boxblurImage:(UIImage *)image withBlurNumber:(CGFloat)blur
{
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 240);
    boxSize = boxSize - (boxSize % 2) + 1;
    CGImageRef img = image.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    //从CGImage中获取数据
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    //设置从CGImage获取对象的属性
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    if(pixelBuffer == NULL){
        NSLog(@"No pixelbuffer");
    }
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate( outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    //clean up CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    return returnImage;
}



#pragma mark - 创建 TableView
- (void)createTableView
{
    /* 创建tableView */
    static NSString *CellWithIdentifier = @"articleCell";
    _oneTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, _screenWidth, _screenHeight-64)];
    _oneTableView.backgroundColor = [colorManager lightGrayBackground];
    [_oneTableView setDelegate:self];
    [_oneTableView setDataSource:self];
    
    [_oneTableView registerClass:[SFArticleTableViewCell class] forCellReuseIdentifier:CellWithIdentifier];
    _oneTableView.separatorStyle = UITableViewCellSeparatorStyleNone; // 去掉分割线
    _oneTableView.contentInset = UIEdgeInsetsMake(-20+90, 0, 0, 0); // 设置距离顶部的一段偏移，继承自scrollview
    // 响应点击状态栏的事件
    _oneTableView.scrollsToTop = YES;
    [self.view addSubview:_oneTableView];
    
    // 上拉刷新 MJRefresh
//    _oneTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        // 结束加载更多
//        // [tableView.mj_footer endRefreshing];
//        // [tableView.mj_footer endRefreshingWithNoMoreData];
//        [self connectForMoreArticleCell:_oneTableView];
//    }];
}



#pragma mark - TableView 代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_articleData count] + 1;
}

// 填充cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TopicCellWithIdentifier = @"topicCell+";
    TopicCell *oneTopicCell = [tableView dequeueReusableCellWithIdentifier:TopicCellWithIdentifier];
    
    static NSString *ArticleCellWithIdentifier = @"articleCell+";
    SFArticleTableViewCell *oneArticleCell = [tableView dequeueReusableCellWithIdentifier:ArticleCellWithIdentifier];
    
    NSUInteger row = [indexPath row];
    
    if (row == 0) {
        // 第一个cell
        if (oneTopicCell == nil) {
            oneTopicCell = [[TopicCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TopicCellWithIdentifier];
            // 定义代理
            oneTopicCell.delegate = self;
        }
        _introduction = [_topicData objectForKey:@"introduction"];
        _topic = [_topicData objectForKey:@"title"];
        [oneTopicCell rewriteTopic:_topic];
        [oneTopicCell rewriteIntroduction:_introduction followStatus:_isFollowing pushStatus:_isPushOn];
        
        // 取消选中的背景色
        oneTopicCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return oneTopicCell;
    }
    else {
        if (oneArticleCell == nil) {
            oneArticleCell = [[SFArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ArticleCellWithIdentifier];
        }
        [oneArticleCell rewriteTopics: _topic forIndex:row - 1];
        [oneArticleCell rewriteTopicImageURL:_portraitURL forIndex:row - 1];
        [oneArticleCell rewriteTitle:[[_articleData objectAtIndex:row-1] objectForKey:@"title"]];
        [oneArticleCell rewriteHotScore:[[_articleData objectAtIndex:row-1] objectForKey:@"hotScore"]];
        [oneArticleCell rewriteDate:[[_articleData objectAtIndex:row-1] objectForKey:@"date"]];
        [oneArticleCell rewritePicURL:[[_articleData objectAtIndex:row-1] objectForKey:@"picURL"]];
        
        // 取消选中的背景色
        oneArticleCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return oneArticleCell;
    }
}

// 改变 cell 高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    if (row == 0) {
        TopicCell *cell = (TopicCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.cellHeight;
    }
    else {
        CGFloat height = 145;
        return height;
    }
}


// tableView 点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    if (row == 0) {
        return;
    }
    
    // 进入article详情页
    detailVC *detailPage = [[detailVC alloc] init];
    detailPage.articleID = [[_articleData objectAtIndex:row-1] objectForKey:@"_id"];
    [self.navigationController pushViewController:detailPage animated:YES];
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}





#pragma mark - 网络请求

/** 请求第一个cell的数据 **/
- (void)connectForTopicCell:(UITableView *)tableView
{
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/topic/topic_info"];
    
    NSDictionary *parameters = @{
                                 @"uid": _uid,
                                 @"title": _topic
                                 };
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        NSLog(@"errcode：%@", errcode);
        
        if ([errcode isEqualToString:@"err"]) {
            return;
        }
        
        // 更新第一个cell的数据
        _topicData = data;
        data = nil;
        
        // 更新isFollowing状态
        _isFollowing = [_topicData objectForKey:@"isFollowing"];
        _isPushOn = [_topicData objectForKey:@"isPushOn"];
        
        // 刷新tableview
        [tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


/* 请求文章cell数据 */
- (void)connectForArticleCell:(UITableView *)tableView
{
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/topic/articles"];
    
    NSDictionary *parameters = @{
                                 @"topic":_topic
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
            return;
        }
        
        // 更新数据
        _articleData = [data mutableCopy];
        data = nil;
        
        // 刷新tableview
        [tableView reloadData];
        
        // 添加上拉刷新 MJRefresh
        _oneTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            // 结束加载更多
            // [tableView.mj_footer endRefreshing];
            // [tableView.mj_footer endRefreshingWithNoMoreData];
            [self connectForMoreArticleCell:_oneTableView];
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (void)connectForMoreArticleCell:(UITableView *)tableView
{
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/topic/articles"];
    
    // 取得当前最后一个cell的数据id
    NSString *lastID = [[_articleData lastObject] objectForKey:@"_id"];
    NSDictionary *parameters = @{
                                 @"type":@"loadmore",
                                 @"last_id":lastID,
                                 @"topic": _topic
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
        
        // 追加数据
        [_articleData addObjectsFromArray:data];
        data = nil;
        
        // 刷新tableview
        [tableView reloadData];
        
        [tableView.mj_footer endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [tableView.mj_footer endRefreshing];
    }];
}


/** follow or unfollow 请求 **/
- (void)connectForFollow
{
    NSLog(@"请求 follow 开始");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/topic/follow"];
    
    if ([_isFollowing isEqualToString:@"yes"]) {
        urlString = [host stringByAppendingString:@"/topic/unfollow"];
    }
    
    NSDictionary *parameters = @{
                                 @"uid": _uid,
                                 @"topic": _topic,
                                 @"portrait": _portraitURL,
                                 @"introduction": _introduction,
                                 @"is_push_on": _isPushOn
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
            [toastView showToastWith:@"操作失败，服务器错误" isErr:NO duration:2.0 superView:self.view];  // toast提示
            return;
        }
        NSLog(@"关注状态改为%@",[data objectForKey:@"isFollowing"]);
        
        _isFollowing = [data objectForKey:@"isFollowing"];
        
        // 刷新特定的cell
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        [_oneTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationFade];
        
        // toast提示
        if ([_isFollowing isEqualToString:@"yes"]) {  // 如果是关注成功
            [toastView showToastWith:@"关注成功 bingo！" isErr:YES duration:2.0 superView:self.view];
        } else {  // 如果是取消关注成功
            [toastView showToastWith:@"已取消关注" isErr:YES duration:2.0 superView:self.view];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [toastView showToastWith:@"操作失败，请检查网络" isErr:NO duration:2.0 superView:self.view];  // toast提示
    }];
}


/** push开关 请求 **/
- (void)connectForPushSwitch
{
    NSLog(@"请求 push开关 开始");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/topic/push"];
    NSDictionary *parameters = @{
                                 @"uid": _uid,
                                 @"topic": _topic,
                                 @"portrait": _portraitURL,
                                 @"introduction": _introduction,
                                 @"is_push_on": _isPushOn
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}





#pragma mark - IBAction
- (void)clickBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - TopicCell 的代理方法

- (void)clickFollowButton
{
//    if ([_isFollowing isEqualToString:@"yes"]) {
//        _isFollowing = @"no";
//    }
//    else if ([_isFollowing isEqualToString:@"no"]) {
//        _isFollowing = @"yes";
//    }
//    else {
//        _isFollowing = @"no";
//    }
    if (_uid && ![_uid isEqualToString:@""]) {
        [self connectForFollow];  // 发起 follow 请求
    } else {
        [self chooseLoginWayWith:@"登录后方可关注此话题"];
    }
    
    
    // 刷新特定的一个cell
//    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
//    [_oneTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationFade];
    
    //    [UIView animateWithDuration:0.3 animations:^{   // uiview 动画（无需实例化）单例
    //
    //    }];
}

- (void)changePushSwitch
{
    if ([_isPushOn isEqualToString:@"yes"]) {
        _isPushOn = @"no";
    }
    else if ([_isPushOn isEqualToString:@"no"]) {
        _isPushOn = @"yes";
    }
    else {
        _isPushOn = @"no";
    }
    NSLog(@"push开关：%@", _isPushOn);
    
    [self connectForPushSwitch];
    
}



#pragma mark - 选择登录方式 UIActionSheet
- (void)chooseLoginWayWith:(NSString *)title
{
    NSLog(@"选择登录方式");
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: @"微博帐号登录",nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"新浪微博登录");
        SFLoginViewController *loginPage = [[SFLoginViewController alloc] init];
        [self.navigationController presentViewController:loginPage animated:YES completion:^{
            return;
        }];
//        SFLoginAndSignup *Login = [[SFLoginAndSignup alloc] init];
//        [Login requestForWeiboAuthorize];
//        [Login waitForWeiboAuthorizeResult];
    }
}


@end
