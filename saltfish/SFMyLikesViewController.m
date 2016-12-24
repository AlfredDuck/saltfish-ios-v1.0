//
//  SFMyLikesViewController.m
//  saltfish
//
//  Created by alfred on 16/9/16.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFMyLikesViewController.h"
#import "colorManager.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "urlManager.h"
#import "MJPhotoBrowser.h"  // MJ图片浏览器
#import "MJPhoto.h"  // MJ图片浏览器
#import "SFShareManager.h"
#import "SFArticleCell.h"
#import "TopicVC.h"
#import "commentVC.h"
#import "detailVC.h"


@interface SFMyLikesViewController ()
@property (nonatomic) NSString *shareArticleID;  // 将要分享的article的id
@end


@implementation SFMyLikesViewController

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
    
    [self createUIParts];  // 创建ui
    [self connectForArticle];
}

- (void)viewWillAppear:(BOOL)animated
{
    // 设置状态栏颜色的强力方法
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 构建UI
/** 构建UI */
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
    titleLabel.text = @"我喜欢的";
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
    
    
    /** 为空提示语 **/
    _emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake((_screenWidth-200)/2, 84, 200, 30)];
    _emptyLabel.text = @"- 没有你喜欢过的内容 -";
    _emptyLabel.textColor = [colorManager secondTextColor];
    _emptyLabel.font = [UIFont fontWithName:@"Helvetica" size: 12];
    _emptyLabel.textAlignment = UITextAlignmentCenter;
    _emptyLabel.hidden = YES;
    [titleBarBackground addSubview:_emptyLabel];
    
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
    static NSString *CellWithIdentifier = @"articleCell";
    _oneTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, _screenWidth, _screenHeight-64)];
    _oneTableView.backgroundColor = [UIColor brownColor];
    [_oneTableView setDelegate:self];
    [_oneTableView setDataSource:self];
    
    [_oneTableView registerClass:[SFArticleCell class] forCellReuseIdentifier:CellWithIdentifier];
    _oneTableView.backgroundColor = [colorManager lightGrayBackground];
    _oneTableView.separatorStyle = UITableViewCellSeparatorStyleNone; // 去掉分割线
    _oneTableView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0); // 设置距离顶部的一段偏移，继承自scrollview
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
    _oneTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        // 结束加载更多
        // [tableView.mj_footer endRefreshing];
        // [tableView.mj_footer endRefreshingWithNoMoreData];
        [self connectForMore];
    }];
}






#pragma mark - TableView 代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_articleData count];
}


// 填充cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *articleCellWithIdentifier = @"articleCell+";
    SFArticleCell *oneArticleCell = [tableView dequeueReusableCellWithIdentifier:articleCellWithIdentifier];
    
    NSUInteger row = [indexPath row];
    if (oneArticleCell == nil) {
        oneArticleCell = [[SFArticleCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:articleCellWithIdentifier];
        oneArticleCell.delegate = self;
    }
    // 判断是否含链接
    BOOL isShow;
    if ([NSNull null] == [[_articleData objectAtIndex:row] objectForKey:@"originalLink"]) {
        isShow = NO;
    } else {
        isShow = YES;
    }
    // 字符串转数字
    NSString *shareNumStr = [[_articleData objectAtIndex:row] objectForKey:@"shareNum"];
    unsigned long shareNum = [shareNumStr intValue];
    NSString *commentNumStr = [[_articleData objectAtIndex:row] objectForKey:@"commentNum"];
    unsigned long commentNum = [commentNumStr intValue];
    NSString *likeNumStr = [[_articleData objectAtIndex:row] objectForKey:@"likeNum"];
    unsigned long likeNum = [likeNumStr intValue];
    
    [oneArticleCell rewriteLinkMark:isShow];
    [oneArticleCell rewriteTopic:[[_articleData objectAtIndex:row] objectForKey:@"topic"] withIndex:row];
    [oneArticleCell rewritePortrait:[[_articleData objectAtIndex:row] objectForKey:@"topicImageURL"] withIndex:row];
    [oneArticleCell rewriteDate:[[_articleData objectAtIndex:row] objectForKey:@"date"]];
    [oneArticleCell rewriteShareNum:shareNum withIndex:row];
    [oneArticleCell rewriteCommentNum:commentNum withIndex:row];
    [oneArticleCell rewriteLikeNum:likeNum withIndex:row];
    [oneArticleCell rewriteLikeStatus:[[_articleData objectAtIndex:row] objectForKey:@"likeStatus"]];
    [oneArticleCell rewriteTitle:[[_articleData objectAtIndex:row] objectForKey:@"title"] withLink:isShow];
    [oneArticleCell rewritePicURL:[[_articleData objectAtIndex:row] objectForKey:@"picSmall"] withIndex:row];
    // 取消选中的背景色
    oneArticleCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return oneArticleCell;
}


// 改变 cell 高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFArticleCell *cell = (SFArticleCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.cellHeight;
}


// tableView 点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    // 检查是否有链接
    if ([NSNull null] == [[_articleData objectAtIndex:row] objectForKey:@"originalLink"]) {
        NSLog(@"没有外链");
        // 左右抖动一下
        [self shake:[tableView cellForRowAtIndexPath:indexPath].contentView];
        return;
    }
    
    detailVC *detailPage = [[detailVC alloc] init];
    detailPage.articleID = [[_articleData objectAtIndex:row] objectForKey:@"_id"];
    detailPage.originalLink = [[_articleData objectAtIndex:row] objectForKey:@"originalLink"];
    [self.navigationController pushViewController:detailPage animated:YES];
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}









#pragma mark - SFArticleCell 代理
/** 点击topics */
- (void)clickTopicForIndex:(unsigned long)index
{
    NSLog(@"i was called");
    // 通过index获得话题内容
    NSString *topic = [[_articleData objectAtIndex:index] objectForKey:@"topic"];
    NSString *portrait = [[_articleData objectAtIndex:index] objectForKey:@"topicImageURL"];
    
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
- (void)clickPicsForIndex:(unsigned long)index withView:(UIView *)view
{
    unsigned long indexTable = index/100 - 1;  // 取百位
    unsigned long indexPic = index%100;  // 取个位
    NSArray *arr = [[_articleData objectAtIndex:indexTable] objectForKey:@"picBig"];
    [self checkBigPhotos: arr forIndex:indexPic withView:view];
}


/** 点击分享 */
- (void)clickShareIconForIndex:(unsigned long)index
{
    _shareArticleID = [[_articleData objectAtIndex:index] objectForKey:@"_id"];
    UIActionSheet *shareSheet = [[UIActionSheet alloc] initWithTitle:@"分享到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信好友", @"微信朋友圈", @"新浪微博", nil];
    shareSheet.tag = 110;
    [shareSheet showInView:self.view];
}


/** 点击评论 */
- (void)clickCommentIconForIndex:(unsigned long)index
{
    NSLog(@"点击评论icon");
    commentVC *commentPage = [[commentVC alloc] init];
    commentPage.articleID = [[_articleData objectAtIndex:index] objectForKey:@"_id"];
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
    NSString *articleID = [[_articleData objectAtIndex:index] objectForKey:@"_id"];
    [self connectForLikeWith: articleID cellIndex:index];  // 发起like请求
}













#pragma mark - 网络请求

/** 初始化请求article列表 */
- (void)connectForArticle
{
    NSLog(@"请求开始");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/user/my_likes"];
    
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
        
        if ([errcode isEqualToString:@"err"]) {
            return;
        } else if (0 == [data count]){
            _loadingView.hidden = YES;
            _emptyLabel.hidden = NO;
            return;
        }
        
        // 更新当前 tableview 的数据
        _articleData = [data mutableCopy];
        data = nil;
        
        // 创建 tableview
        [self createTableView];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}



/** 请求更多article */
- (void)connectForMore
{
    NSLog(@"开始请求 more articles");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/user/my_likes"];
    
    // 取得当前最后一个cell的id
    NSString *lastID = [[_articleData lastObject] objectForKey:@"likeID"];
    
    NSDictionary *parameters = @{@"uid": _uid,
                                 @"user_type": _userType,
                                 @"last_id": lastID,
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
        
        // 更新 followedArticleData 数据
        [_articleData addObjectsFromArray:data];
        data = nil;
        
        // 刷新当前 tableview 的数据
        [_oneTableView reloadData];
        
        [_oneTableView.mj_footer endRefreshing];  // 结束上拉加载更多
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [_oneTableView.mj_footer endRefreshing];  // 结束上拉加载更多
    }];
}



/** 喜欢一个article请求 **/
- (void)connectForLikeWith:(NSString *)articleID cellIndex:(unsigned long)index
{
    NSLog(@"请求喜欢一个article");
    
    // 要添加or取消一个喜欢
    NSString *isCancel = [[_articleData objectAtIndex:index] objectForKey:@"likeStatus"];
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
        NSLog(@"%@", [[_articleData objectAtIndex:index] objectForKey:@"title"]);
        NSMutableDictionary *cellData = [[_articleData objectAtIndex:index] mutableCopy];
        [cellData setValue:[data objectForKey:@"status"] forKey:@"likeStatus"];
        [cellData setValue:[data objectForKey:@"likeNum"] forKey:@"likeNum"];
        [_articleData replaceObjectAtIndex:index withObject:cellData];
        
        // 2.刷新特定cell
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
        [_oneTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}











#pragma mark - IBAction
/** 点击返回按钮 */
- (void)clickBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
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
        NSLog(@"need login?");
    }
}








#pragma mark - 图片浏览器
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


@end
