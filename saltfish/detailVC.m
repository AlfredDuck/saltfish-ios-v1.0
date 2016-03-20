//
//  detailVC.m
//  saltfish
//
//  Created by alfred on 15/12/14.
//  Copyright © 2015年 Alfred. All rights reserved.
//

#import "detailVC.h"
#import "commentVC.h"
#import "colorManager.h"
#import "urlManager.h"
#import "AFNetworking.h"
#import "WeiboSDK.h"


@interface detailVC ()
@property (nonatomic) BOOL firstLoad;  //是否第一次加载（viewWillAppear多次调用的问题）
@end


@implementation detailVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"三分田";
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _firstLoad = YES;
    
    // 创建UI
    [self basedBottomBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_firstLoad) {
        NSLog(@"详情页的articleID: %@", _articleID);
        // 请求webview
        [self basedWebView];
        // 请求评论数
        [self connectForCommentNumWith:_articleID];
    }
    _firstLoad = NO;
    [self praiseButtonStatus];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}





#pragma mark - 创建 UI
- (void)basedBottomBar {
    // 状态栏底色
    UIView *statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 20)];
    statusBarBackground.backgroundColor = [UIColor whiteColor];
    statusBarBackground.alpha = 0.9;
    [self.view addSubview:statusBarBackground];
    
    // 状态栏分割线
    UIView *lineOfStatusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 19.5, _screenWidth, 0.5)];
    lineOfStatusBar.backgroundColor = [colorManager lightGrayLineColor];
    [statusBarBackground addSubview:lineOfStatusBar];
    
    // 底部条背景
    UIView *basedBottomBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, _screenHeight-44, _screenWidth, 44)];
    basedBottomBarBackground.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:basedBottomBarBackground];
    
    // 底部条分割线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 0.5)];
    line.backgroundColor = [colorManager lightGrayLineColor];
    [basedBottomBarBackground addSubview:line];
    
    // 返回按钮(pic)
    UIImage *oneImage = [UIImage imageNamed:@"back.png"]; // 使用ImageView通过name找到图片
    UIImageView *oneImageView = [[UIImageView alloc] initWithImage:oneImage]; // 把oneImage添加到oneImageView上
    oneImageView.frame = CGRectMake(10, 14.5, 10, 15); // 设置图片位置和大小
    // [oneImageView setContentMode:UIViewContentModeCenter];
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backView addSubview:oneImageView];
    // 为UIView添加点击事件
    // 一定要先将userInteractionEnabled置为YES，这样才能响应单击事件
    backView.userInteractionEnabled = YES; // 设置图片可以交互
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBackButton)]; // 设置手势
    [backView addGestureRecognizer:singleTap]; // 给图片添加手势
    [basedBottomBarBackground addSubview:backView];
    
    // 评论-按钮
    _commentButton = [[UIButton alloc] initWithFrame:CGRectMake(_screenWidth - 60, 1, 48, 43)];
    [_commentButton setTitle:@"评论" forState:UIControlStateNormal];
    _commentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [_commentButton setTitleColor:[colorManager lightTextColor] forState:UIControlStateNormal];
    _commentButton.backgroundColor = [UIColor whiteColor];
    _commentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    [_commentButton addTarget:self action:@selector(clickCommentButton) forControlEvents:UIControlEventTouchUpInside];
    [basedBottomBarBackground addSubview: _commentButton];
    
    // 赞-按钮
    _praiseButton = [[UIButton alloc] initWithFrame:CGRectMake(_screenWidth - 60*2, 1, 48, 43)];
    [_praiseButton setTitle:@"点赞" forState:UIControlStateNormal];
    _praiseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [_praiseButton setTitleColor:[colorManager lightTextColor] forState:UIControlStateNormal];
    _praiseButton.backgroundColor = [UIColor whiteColor];
    _praiseButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    [_praiseButton addTarget:self action:@selector(clickPraiseButton) forControlEvents:UIControlEventTouchUpInside];
    _praiseButton.tag = 10;  // no praise
    [basedBottomBarBackground addSubview: _praiseButton];
    
    // 分享-按钮
    _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(_screenWidth - 60*3, 1, 48, 43)];
    [_shareButton setTitle:@"分享" forState:UIControlStateNormal];
    _shareButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [_shareButton setTitleColor:[colorManager lightTextColor] forState:UIControlStateNormal];
    _shareButton.backgroundColor = [UIColor whiteColor];
    _shareButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    [_shareButton addTarget:self action:@selector(clickShareButton) forControlEvents:UIControlEventTouchUpInside];
    [basedBottomBarBackground addSubview: _shareButton];
    
}


// 显示评论数
- (void)basedCommentNumLabelWith:(NSString *)num
{
    _commentNumLabel = [[UILabel alloc] init];
    _commentNumLabel.text = num;
    _commentNumLabel.font = [UIFont fontWithName:@"Helvetica" size: 10];
    _commentNumLabel.textColor = [UIColor whiteColor];
    _commentNumLabel.frame = CGRectMake(30, 4, 5*(unsigned long)num.length+7, 13);
    _commentNumLabel.textAlignment = UITextAlignmentCenter;
    _commentNumLabel.backgroundColor = [colorManager red];
    [_commentButton addSubview:_commentNumLabel];
}

// 显示赞的数量
- (void)basedPraiseNumLabelWith:(NSString *)num
{
    _praiseNumLabel = [[UILabel alloc] init];
    _praiseNumLabel.text = num;
    _praiseNumLabel.font = [UIFont fontWithName:@"Helvetica" size: 10];
    _praiseNumLabel.textColor = [UIColor whiteColor];
    _praiseNumLabel.frame = CGRectMake(30, 4, 5*(unsigned long)num.length+7, 13);
    _praiseNumLabel.textAlignment = UITextAlignmentCenter;
    _praiseNumLabel.backgroundColor = [colorManager red];
    [_praiseButton addSubview:_praiseNumLabel];
}

// 显示点赞按钮的状态
- (void)praiseButtonStatus
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults arrayForKey:@"praiseList"]) {
        // have praiseList
        NSMutableArray *praiseList = [[userDefaults arrayForKey:@"praiseList"] mutableCopy];
        // check if the article already stored?
        NSString *thing;
        for (thing in praiseList) {
            if ([thing isEqualToString:_articleID]) {
                NSLog(@"I have praise this artilce");
                // change the color
                [_praiseButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                _praiseButton.tag = 11;  // already praised
                break;
            }
        }
    }
}

// 显示分享数







#pragma mark - 网络连接
/*（请求评论、赞、分享的数量）*/
- (void)connectForCommentNumWith:(NSString *)articleID
{
    // 准备请求参数
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/article/other"];
    NSDictionary *parameters = @{
                                 @"article_id": articleID
                                 };
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET callback
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        if ([errcode isEqualToString:@"err"]) {
            NSLog(@"查询出错");
            return;
        }
        NSString *commentNum = (NSString *)[responseObject objectForKey:@"commentNum"];
        NSString *praiseNum = (NSString *)[responseObject objectForKey:@"praiseNum"];
        [self basedCommentNumLabelWith:[NSString stringWithFormat:@"%@", commentNum]];
        [self basedPraiseNumLabelWith:[NSString stringWithFormat:@"%@", praiseNum]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}



/* 服务器点赞数量+1 */
- (void)connectForAddOnePraiseWith:(NSString *)articleID
{
    // 准备请求参数
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/article/praise"];
    NSDictionary *parameters = @{@"article_id": articleID};
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET callback
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        if ([errcode isEqualToString:@"err"]) {
            NSLog(@"查询或写入出错");
            return;
        }
        NSLog(@"praise + 1 , success");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}






#pragma mark - 创建 WebView
- (void)basedWebView
{
    NSLog(@"开始webview请求");
    
    // 创建 webview
    _webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, _screenWidth, _screenHeight-44-20)];
    _webview.backgroundColor = [UIColor whiteColor];
    
    // 请求参数
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/article?article_id="];
    NSString *finalURL = [urlString stringByAppendingString:_articleID];
    NSLog(@"%@", finalURL);

    
    // 发起请求
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:finalURL]];
    [self.view addSubview: _webview];
    _webview.delegate = self;
    [_webview loadRequest:request];
}





#pragma mark - webview 代理方法
// 请求开始
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"请求+1");
}

// 请求完成
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView.loading) {
        NSLog(@"继续请求中");
    }
    else {
        NSLog(@"webview 请求完成");
    }
}

// 请求出错
- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    NSLog(@"请求出错+1");
}


// 捕获网页请求
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = [[request URL] absoluteString];
    NSLog(@"捕获网页请求：%@", urlString);
    
    // 字符串分割成数组
    NSArray *arr = [urlString componentsSeparatedByString:@"://"];
    
    // anthor detail page
    if ([arr[0] isEqualToString:@"saltfish-app"]) {
        NSLog(@"要访问的文章id：%@", arr[1]);
        // 打开另一个详情页
        detailVC *detailPage = [[detailVC alloc] init];
        detailPage.articleID = arr[1];
        [self.navigationController pushViewController:detailPage animated:YES];
        // 开启iOS7的滑动返回效果
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
        
        return false;
        //执行本地代码，返回false不让网页读取网络资源
    }
    
    // share to weibo
    if ([arr[0] isEqualToString:@"saltfish-share-weibo"]) {
        NSLog(@"Share to Weibo");
    }
    
    return true;
    //如没有location对应的属性，则读取网络相关资源
}






#pragma mark - IBAction
- (void)clickBackButton {
    NSLog(@"返回");
    [self.navigationController popViewControllerAnimated:YES];
}




- (void)clickCommentButton {
    NSLog(@"进入评论页面");
    commentVC *commentPage = [[commentVC alloc] init];
    commentPage.articleID = _articleID;
    [self.navigationController pushViewController:commentPage animated:YES];
    
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}



// 点赞
-(void)clickPraiseButton {
    
    if (_praiseButton.tag == 11) {
        [self cancelPraiseButton];
        return;
    }
    
    NSLog(@"点赞");
    
    // 本地储存点赞的数据
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults arrayForKey:@"praiseList"]) {
        // already have praiseList
        NSMutableArray *praiseList = [[userDefaults arrayForKey:@"praiseList"] mutableCopy];
        NSLog(@"%@", praiseList);
        // check if the article already stored?
        // if artilceid stored, don't store again
        NSString *thing;
        for (thing in praiseList) {
            if ([thing isEqualToString:_articleID]) {
                return;
            }
        }
        // if artilceid no stored, store it
        [praiseList addObject:_articleID];
        [userDefaults setObject:[praiseList copy] forKey:@"praiseList"];
        
    } else {
        // no praiseList
        NSLog(@"no local praiseList");
        // create praiseList
        NSMutableArray *praiseList = [[NSMutableArray alloc] init];
        [praiseList addObject:_articleID];
        NSLog(@"%@", praiseList);
        [userDefaults setObject:[praiseList copy] forKey:@"praiseList"];
        NSLog(@"%@", [userDefaults arrayForKey:@"praiseList"]);
    }
    
    // 服务器点赞数+1
    [self connectForAddOnePraiseWith:_articleID];
    
    // client praise num + 1
    int i = [_praiseNumLabel.text intValue] + 1;
    _praiseNumLabel.text = (NSString *)[NSString stringWithFormat:@"%ld", (long)i];
    
    // change praise button status
    [_praiseButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    _praiseButton.tag = 11;
}

// 取消点赞
- (void)cancelPraiseButton
{
    NSLog(@"取消赞");
    
    // client praise num - 1
    int i = [_praiseNumLabel.text intValue];
    if (i > 0) {
        i = i - 1;
    } else {
        i = 0;
    }
    _praiseNumLabel.text = (NSString *)[NSString stringWithFormat:@"%ld", (long)i];
    
    // delete the local data
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *list = [[userDefaults arrayForKey:@"praiseList"] mutableCopy];
    [list removeObject:_articleID];
    [userDefaults setObject:[list copy] forKey:@"praiseList"];
    
    // set the praise button status
    [_praiseButton setTitleColor:[colorManager lightTextColor] forState:UIControlStateNormal];
    _praiseButton.tag = 10;  // no praise
}




- (void)clickShareButton {
    NSLog(@"点分享");
}



// share to weibo
- (void)shareToWeibo
{
    NSLog(@"weibo share test");
    //        WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    //        request.redirectURI = @"https://api.weibo.com/oauth2/default.html";
    //        [WeiboSDK sendRequest: request];
    
    [WBHttpRequest requestForShareAStatus:@"big short" contatinsAPicture:nil orPictureUrl:@"https://img1.doubanio.com/view/photo/photo/public/p2277484043.jpg" withAccessToken:@"2.008LimdBNBy6sD5321dc16e6qCZkkC" andOtherProperties:nil queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
        // callback code
        NSLog(@"share success?");
        NSLog(@"%@?%@", result, httpRequest.httpMethod);
        NSLog(@"%@?%@", httpRequest.url, httpRequest.params);
    }];
    return;
}





@end
