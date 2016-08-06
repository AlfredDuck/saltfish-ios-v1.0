//
//  commentVC.m
//  saltfish
//
//  Created by alfred on 15/12/16.
//  Copyright © 2015年 Alfred. All rights reserved.
//

#import "commentVC.h"
#import "commentTableViewCell.h"
#import "AFNetworking.h"
#import "MJRefresh.h"
#import "colorManager.h"
#import "writeCommentVC.h"
#import "urlManager.h"
#import "toastView.h"
#import "SFLoginAndSignup.h"

@interface commentVC ()
@property (nonatomic) BOOL firstLoad;  //是否第一次加载（viewWillAppear多次调用的问题）
@end

@implementation commentVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"title";
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _firstLoad = YES;
    
    // 登录账户的uid
    NSUserDefaults *sfUserDefault = [NSUserDefaults standardUserDefaults];
    if ([sfUserDefault objectForKey:@"loginInfo"]) {
        _uid = [[sfUserDefault objectForKey:@"loginInfo"] objectForKey:@"uid"];
    } else {
        _uid = @"";
    }
    
    // 创建UI
    [self basedTitleBar];
    [self basedBottomBar];
    [self basedContentFatherView];

}

- (void)viewWillAppear:(BOOL)animated
{
    if (_firstLoad) {
        NSLog(@"评论页的articleID：%@", _articleID);
        // 加载数据，并显示
        [self connectForCommentsWith: _articleID];
    }
    _firstLoad = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - 自定义代理(writeCommentVC.h)
- (void)writeCommentSuccess
{
    NSLog(@"发送评论成功，来自前一页的代理问候");
    if (_commentTableView) {
        NSLog(@"tableview exist, refresh!");
        [self connectForRefreshWith: _articleID];
    } else {
        NSLog(@"tableview didnt exist, first load!");
        [self connectForCommentsWith:_articleID];
    }

    
}





#pragma mark - 创建 UI
// 创建顶部导航栏
- (void)basedTitleBar
{
    // title bar background
    UIView *titleBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 64)];
    titleBarBackground.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:titleBarBackground];
    
    // 分割线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 64-0.5, _screenWidth, 0.5)];
    line.backgroundColor = [colorManager lightGrayLineColor];
    [titleBarBackground addSubview:line];
    
    // title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_screenWidth-200)/2, 20, 200, 44)];
    titleLabel.text = @"全部评论";
    titleLabel.textColor = [colorManager mainTextColor];
    titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 16];
    titleLabel.textAlignment = UITextAlignmentCenter;
    [titleBarBackground addSubview:titleLabel];
    
    // back button pic
    UIImage *oneImage = [UIImage imageNamed:@"back.png"]; // 使用ImageView通过name找到图片
    UIImageView *oneImageView = [[UIImageView alloc] initWithImage:oneImage]; // 把oneImage添加到oneImageView上
    oneImageView.frame = CGRectMake(10, 14.5, 10, 15); // 设置图片位置和大小
    // [oneImageView setContentMode:UIViewContentModeCenter];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [backView addSubview:oneImageView];
    // 为UIView添加点击事件
    // 一定要先将userInteractionEnabled置为YES，这样才能响应单击事件
    backView.userInteractionEnabled = YES; // 设置图片可以交互
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBackButton)]; // 设置手势
    [backView addGestureRecognizer:singleTap]; // 给图片添加手势
    [self.view addSubview:backView];
    
}

// 底部写评论按钮
- (void)basedBottomBar
{
    // 底部条背景
    UIView *basedBottomBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, _screenHeight-44, _screenWidth, 44)];
    basedBottomBarBackground.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:basedBottomBarBackground];
    
    // 底部条分割线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 0.5)];
    line.backgroundColor = [colorManager lightGrayLineColor];
    [basedBottomBarBackground addSubview:line];
    
    // 评论按钮
    UIButton *writeCommentButton = [[UIButton alloc] initWithFrame:CGRectMake((_screenWidth-100)/2.0, 1, 100, 43)];
    [writeCommentButton setTitle:@"写评论" forState:UIControlStateNormal];
    writeCommentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    UIColor *buttonColor = [UIColor colorWithRed:74/255.0 green:144/255.0 blue:226/255.0 alpha:1];
    [writeCommentButton setTitleColor:buttonColor forState:UIControlStateNormal];
    writeCommentButton.backgroundColor = [UIColor whiteColor];
    writeCommentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    [writeCommentButton addTarget:self action:@selector(clickWriteCommentButton) forControlEvents:UIControlEventTouchUpInside];
    [basedBottomBarBackground addSubview:writeCommentButton];
}

// 内容区域的基础 super view
- (void)basedContentFatherView
{
    _contentFatherView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, _screenWidth, _screenHeight-64-44)];
    _contentFatherView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_contentFatherView];
}

/* 没有评论的提示文字 */
- (void)thereNoComment
{
    UILabel *noComment = [[UILabel alloc] initWithFrame:CGRectMake(_contentFatherView.frame.size.width/2.0 - 150, 25, 300, 20)];
    noComment.font = [UIFont fontWithName:@"Helvetica" size: 13];
    noComment.textAlignment = UITextAlignmentCenter;
    noComment.textColor = [colorManager lightTextColor];
    noComment.text = @"~你是第一个评论的哦~";
    [_contentFatherView addSubview:noComment];
    
}





#pragma mark - 网络请求
/* 第一次请求 */
- (void)connectForCommentsWith:(NSString *)articleID
{
    // loading 动画
    [self showLoadingOn:_contentFatherView];
    
    // 准备请求参数
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/comment"];
    NSDictionary *parameters = @{
                                 @"article_id": articleID,
                                 @"type": @"refresh"
                                 };

    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET callback
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        if ([errcode isEqualToString:@"err"]) {
            NSLog(@"没有人评论");
            [self hideLoadingOn:_contentFatherView];
            [self thereNoComment];
            return;
        }
        NSArray *data = [responseObject objectForKey:@"data"];
        
        // 注入数据到 TableViewDataSource
        _commentDataSource = [data mutableCopy];
        // 初始化 TableView
        [self basedTableView];
        
        // 如果数据少于 20 ，则直接显示 la fin
        if ([data count] < 20) {
            [_commentTableView.mj_footer endRefreshingWithNoMoreData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"请求失败or超时");
        [self showReloadButtonOn:_contentFatherView];
    }];
}


/* 下拉刷新请求 */
- (void)connectForRefreshWith:(NSString *)articleID
{
    // 准备请求参数
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/comment"];
    NSDictionary *parameters = @{
                                 @"article_id": articleID,
                                 @"type": @"refresh"
                                 };
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSArray *data = [responseObject objectForKey:@"data"];
        
        // 注入数据到 TableViewDataSource
        _commentDataSource = [data mutableCopy];
        
        // 刷新 TableView 的显示
        [_commentTableView reloadData];
        
        // 结束下拉刷新动作
        [_commentTableView.mj_header endRefreshing];
        
        // 从写评论返回时，滚回列表顶部
        _commentTableView.contentOffset = CGPointMake(0, 0);
        
        // 重置 la fin 状态
        [_commentTableView.mj_footer resetNoMoreData];
        
        // 如果数据少于 10 ，则直接显示 la fin （对比上面的看是不是有点懵...）
        if ([data count] < 5) {
            [_commentTableView.mj_footer endRefreshingWithNoMoreData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        // 结束下拉刷新动作
        [_commentTableView.mj_header endRefreshing];
    }];
}


/* 上拉加载更多请求 */
- (void)connectForLoadMoreWith:(NSString *)articleID
{
    // 准备请求参数
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/comment"];
    
    NSString *lastid = [[_commentDataSource lastObject] objectForKey:@"_id"];
    NSDictionary *parameters = @{
                                 @"article_id": articleID,
                                 @"type": @"loadmore",
                                 @"last_id": lastid
                                 };
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        if ([errcode isEqualToString:@"err"]) {
            NSLog(@"没有更多comment了");
            // 结束上拉加载更多
            [_commentTableView.mj_footer endRefreshingWithNoMoreData];
            return;
        }
        NSArray *addData = [responseObject objectForKey:@"data"];
        
        // 更新 TableViewDataSource
        [_commentDataSource addObjectsFromArray:addData];
        // 刷新 TableView 的显示
        [_commentTableView reloadData];
        
        // 结束上拉加载更多
        [_commentTableView.mj_footer endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        // 结束上拉加载更多
        [_commentTableView.mj_footer endRefreshing];
    }];
}







#pragma mark - loading 动画

/* 显示loading */
- (void)showLoadingOn:(UIView *)boardView
{
    if (boardView.tag) {
        NSLog(@"tag:%ld", (long)boardView.tag);
    }
    
    // 清空 boardView 的所有子view
    for (UIView *sub in boardView.subviews){
        [sub removeFromSuperview];
    }
    
    // 小菊花
    _loadingFlower = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingFlower.frame = CGRectMake(boardView.frame.size.width/2-25, boardView.frame.size.height/2-25, 50, 50);
    [_loadingFlower startAnimating];
    //[_loadingFlower stopAnimating];
    [boardView addSubview:_loadingFlower];
    
    // 加载中...
    _loadingTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(boardView.frame.size.width/2.0 - 100, boardView.frame.size.height/2+ 18, 200, 20)];
    _loadingTextLabel.font = [UIFont fontWithName:@"Helvetica" size: 13];
    _loadingTextLabel.textAlignment = UITextAlignmentCenter;
    _loadingTextLabel.textColor = [colorManager lightTextColor];
    _loadingTextLabel.text = @"奴婢正在加载...";
    [boardView addSubview:_loadingTextLabel];
    
    // n秒未加载成功，则
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    });
}

/* 隐藏loading */
- (void)hideLoadingOn:(UIView *)boardView
{
    // 清空 boardView 的所有子view
    for (UIView *sub in boardView.subviews){
        [sub removeFromSuperview];
    }
}

/* 显示重新加载button */
- (void)showReloadButtonOn:(UIView *)boardView
{
    // 清空 boardView 的所有子view
    for (UIView *sub in boardView.subviews){
        [sub removeFromSuperview];
    }
    
    // 重新加载按钮
    _reloadButton = [[UIButton alloc] initWithFrame:CGRectMake(boardView.frame.size.width/2.0 - 100, boardView.frame.size.height/2+ 18, 200, 20)];
    [_reloadButton setTitle:@"重新加载" forState:UIControlStateNormal];
    _reloadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [_reloadButton setTitleColor:[colorManager lightTextColor] forState:UIControlStateNormal];
    _reloadButton.backgroundColor = [UIColor whiteColor];
    _reloadButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    [_reloadButton addTarget:self action:@selector(clickReloadButtonOn:) forControlEvents:UIControlEventTouchUpInside];
    [boardView addSubview:_reloadButton];
}







#pragma mark - 创建 tableView

// 创建列表 tableview
- (void)basedTableView
{
    static NSString *CellWithIdentifier = @"commentCell";

    _commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight-64-44)];
    [_commentTableView setDelegate:self];
    [_commentTableView setDataSource:self];

    [_commentTableView registerClass:[commentTableViewCell class] forCellReuseIdentifier:CellWithIdentifier];
    _commentTableView.backgroundColor = [UIColor whiteColor];
    _commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone; // 去掉分割线
    //_contentListTableView.contentInset = UIEdgeInsetsMake(14, 0, 0, 0); // 设置距离顶部的一段偏移，继承自scrollview
    // 响应点击状态栏的事件
    _commentTableView.scrollsToTop = YES;
    
    // 下拉刷新 MJRefresh
    _commentTableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //            // 结束刷新
        //            [contentTableView.mj_header endRefreshing];
        //        });
        [self connectForRefreshWith: _articleID];
    }];
    
    // 上拉加载更多
    _commentTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self connectForLoadMoreWith: _articleID];
    }];
    
    [_contentFatherView addSubview:_commentTableView];
}






#pragma mark - TableView 代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%lu", (unsigned long)[_commentDataSource count]);
    return [_commentDataSource count];
}

// 填充cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellWithIdentifier= @"commentCell";
    commentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    
    NSUInteger row = [indexPath row];
    if (cell == nil) {
        cell = [[commentTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellWithIdentifier];
    }
    // 让cell显示数据
    [cell rewriteNickname:[[_commentDataSource objectAtIndex:row] objectForKey:@"nickname"]];
    [cell rewriteCreateTime:[[_commentDataSource objectAtIndex:row] objectForKey:@"createTime"]];
    [cell rewriteComment:[[_commentDataSource objectAtIndex:row] objectForKey:@"text"]];
    
    // 计算并存储cell高度，用来修改cell高度
    for (int i=0; i<=row; i++) {
        if (i == row) {
            [_cellHeightArray replaceObjectAtIndex:row withObject:[NSNumber numberWithFloat:cell.cellHeight]];
            NSLog(@"cellheight:%f", cell.cellHeight);
        }
    }
    // 取消选中的背景色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // 直接往cell addsubView的方法会在每次划出屏幕再划回来时 再加载一次subview，因此会重复加载很多subview
    return cell;
}

// 改变 cell 高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    // 根据cell设置高度
//    NSUInteger row = [indexPath row];
//    NSNumber *h = [_cellHeightArray objectAtIndex:row];
//    NSLog(@";;;;;;;;;;%@", h);
//    return h.floatValue;
    
    NSUInteger row = [indexPath row];

    // ===================设置UIlabel文本折行====================
    NSString *str = [[_commentDataSource objectAtIndex:row] objectForKey:@"text"];
    CGSize maxSize = {_screenWidth-50-15, 5000};  // 设置文本区域最大宽高
    CGSize labelSize = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:13]
                       constrainedToSize:maxSize
                           lineBreakMode:[[UILabel alloc] init].lineBreakMode];   // str是要显示的字符串
    //_commentLabel.frame = CGRectMake(50,42,labelSize.width,labelSize.height/13*16);  // 因为行距增加了，所以要用参数修正height
    // _commentLabel.numberOfLines = 0;  // 不可少Label属性之一
    //_postTextLabel.lineBreakMode = UILineBreakModeCharacterWrap;  // 不可少Label属性之二
    // ========================================================
    // 使用uitextview也可以，可以研究下。。。
    
    // 设置cellHeight (所有高度和间距加起来)
    CGFloat height = 42 + labelSize.height/13*16 + 10 + 15 +15;
    return height;

}




#pragma mark - IBAction

- (void)clickBackButton {
    NSLog(@"返回");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickWriteCommentButton
{
    NSLog(@"点击写评论button");
    NSLog(@"uid是：%@", _uid);
    if (_uid && ![_uid isEqualToString:@""]) {
        writeCommentVC *writeCommentPage = [[writeCommentVC alloc] init];
        writeCommentPage.delegate = self;
        writeCommentPage.pageTitle = @"写评论";
        writeCommentPage.articleID = _articleID;
        [self presentViewController:writeCommentPage animated:YES completion:nil];
    } else {
        [self chooseLoginWayWith:@"登录后方可评论"];
    }
}

- (void)clickReloadButtonOn:(id)sender
{
    NSLog(@"点击重新加载请求");
    [self connectForCommentsWith: _articleID];
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
        SFLoginAndSignup *Login = [[SFLoginAndSignup alloc] init];
        [Login requestForWeiboAuthorize];
        [Login waitForWeiboAuthorizeResult];
    }
}



@end
