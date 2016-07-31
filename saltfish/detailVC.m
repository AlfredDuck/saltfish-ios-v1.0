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
#import "toastView.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "WeiboSDK.h"
#import "WeiboUser.h"
#import "WXApi.h"


@interface detailVC ()
@property (nonatomic) BOOL firstLoad;  //是否第一次加载（viewWillAppear多次调用的问题）
@end


@implementation detailVC

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
    
    // 创建UI
    [self basedBottomBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    // 设置状态栏颜色的强力方法
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    if (_firstLoad) {
        NSLog(@"详情页的articleID: %@", _articleID);
        // 记录为已读
        [self logAsRead];
        // 请求webview
        [self basedWebView];
        // 请求评论数
        [self connectForCommentNumWith:_articleID];
        // 请求分享信息
        [self connectForShareInfoWith:_articleID];
    }
    _firstLoad = NO;
    [self praiseButtonStatus];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.delegate refreshReadedStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}





#pragma mark - 创建 UI
- (void)basedBottomBar {
    // 状态栏底色
    UIView *statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 20)];
    statusBarBackground.backgroundColor = [UIColor whiteColor];
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

    
    // comment-button (pic)
    UIImage *commentImage = [UIImage imageNamed:@"comment_button.png"]; // 使用ImageView通过name找到图片
    UIImageView *commentImageView = [[UIImageView alloc] initWithImage:commentImage]; // 把oneImage添加到oneImageView上
    commentImageView.frame = CGRectMake(10.5, 11.5, 23, 21); // 设置图片位置和大小
    // [oneImageView setContentMode:UIViewContentModeCenter];
    _commentButtonView = [[UIView alloc] initWithFrame:CGRectMake(_screenWidth-54, 0, 44, 44)];
    [_commentButtonView addSubview:commentImageView];
    // 为UIView添加点击事件
    // 一定要先将userInteractionEnabled置为YES，这样才能响应单击事件
    _commentButtonView.userInteractionEnabled = YES; // 设置图片可以交互
    UITapGestureRecognizer *singleTapOnCommentButton = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCommentButton)]; // 设置手势
    [_commentButtonView addGestureRecognizer:singleTapOnCommentButton]; // 给图片添加手势
    [basedBottomBarBackground addSubview:_commentButtonView];
    
    
    // praise-button (pic)
    UIImage *praiseImage = [UIImage imageNamed:@"praise_button.png"]; // 使用ImageView通过name找到图片
    _praiseImageView = [[UIImageView alloc] initWithImage:praiseImage]; // 把oneImage添加到oneImageView上
    _praiseImageView.frame = CGRectMake(11.5, 11, 21, 22); // 设置图片位置和大小
    // [oneImageView setContentMode:UIViewContentModeCenter];
    _praiseButtonView = [[UIView alloc] initWithFrame:CGRectMake(_screenWidth-54*2, 0, 44, 44)];
    [_praiseButtonView addSubview:_praiseImageView];
    // 为UIView添加点击事件
    // 一定要先将userInteractionEnabled置为YES，这样才能响应单击事件
    _praiseButtonView.userInteractionEnabled = YES; // 设置图片可以交互
    UITapGestureRecognizer *singleTapOnPraiseButton = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPraiseButton)]; // 设置手势
    [_praiseButtonView addGestureRecognizer:singleTapOnPraiseButton]; // 给图片添加手势
    [basedBottomBarBackground addSubview:_praiseButtonView];
    _praiseButtonView.tag = 10;  // no praise

    
    // share-button (pic)
    UIImage *shareImage = [UIImage imageNamed:@"share_button.png"]; // 使用ImageView通过name找到图片
    UIImageView *shareImageView = [[UIImageView alloc] initWithImage:shareImage]; // 把oneImage添加到oneImageView上
    shareImageView.frame = CGRectMake(12, 13, 20, 18); // 设置图片位置和大小
    // [oneImageView setContentMode:UIViewContentModeCenter];
    _shareButtonView = [[UIView alloc] initWithFrame:CGRectMake(_screenWidth-54*3, 0, 44, 44)];
    [_shareButtonView addSubview:shareImageView];
    // 为UIView添加点击事件
    // 一定要先将userInteractionEnabled置为YES，这样才能响应单击事件
    _shareButtonView.userInteractionEnabled = YES; // 设置图片可以交互
    UITapGestureRecognizer *singleTapOnshareButton = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickShareButton)]; // 设置手势
    [_shareButtonView addGestureRecognizer:singleTapOnshareButton]; // 给图片添加手势
    [basedBottomBarBackground addSubview:_shareButtonView];
    
    // loading 菊花
    _loadingFlower = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingFlower.frame = CGRectMake(40, 0, 44, 44);
    //[_loadingFlower startAnimating];
    //[_loadingFlower stopAnimating];
    [basedBottomBarBackground addSubview:_loadingFlower];
    
}


/* 显示评论数 */
- (void)basedCommentNumLabelWith:(NSString *)numString
{
    if ([numString isEqualToString:@"0"]) {
        return;
    }
    _commentNumLabel = [[UILabel alloc] init];
    _commentNumLabel.text = numString;
    _commentNumLabel.font = [UIFont fontWithName:@"Helvetica" size: 10];
    _commentNumLabel.textColor = [UIColor whiteColor];
    _commentNumLabel.frame = CGRectMake(30, 4, 5*(unsigned long)numString.length+7, 13);
    _commentNumLabel.textAlignment = UITextAlignmentCenter;
    _commentNumLabel.backgroundColor = [colorManager red];
    [_commentButtonView addSubview:_commentNumLabel];
}

/* 显示赞的数量 */
- (void)basedPraiseNumLabelWith:(NSString *)numString
{
    if ([numString isEqualToString:@"0"]) {
        return;
    }
    _praiseNumLabel = [[UILabel alloc] init];
    _praiseNumLabel.text = numString;
    _praiseNumLabel.font = [UIFont fontWithName:@"Helvetica" size: 10];
    _praiseNumLabel.textColor = [UIColor whiteColor];
    _praiseNumLabel.frame = CGRectMake(30, 4, 5*(unsigned long)numString.length+7, 13);
    _praiseNumLabel.textAlignment = UITextAlignmentCenter;
    _praiseNumLabel.backgroundColor = [colorManager red];
    [_praiseButtonView addSubview:_praiseNumLabel];
}

/* 显示点赞按钮的状态 */
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
                //[_praiseButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                _praiseImageView.image = [UIImage imageNamed:@"praise_button_red.png"];
                _praiseButtonView.tag = 11;  // already praised
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


/* 拉取分享用的链接、标题、描述和图片等 */
- (void)connectForShareInfoWith:(NSString *)articleID
{
    NSLog(@"拉取分享信息");
    
    // 准备请求参数
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/article/share_info"];
    NSDictionary *parameters = @{@"article_id": articleID};
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET callback
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        if ([errcode isEqualToString:@"err"]) {
            NSLog(@"查询分享信息出错");
            return;
        }
        
        // 将分享信息保存在内存
        _shareInfo = [[NSDictionary alloc] init];
        _shareInfo = [[responseObject objectForKey:@"data"] copy];
        NSLog(@"shareInfo:%@", _shareInfo);
        NSLog(@"%@", [_shareInfo objectForKey:@"title"]);
        NSLog(@"%@", [_shareInfo objectForKey:@"description"]);
        NSLog(@"%@", [_shareInfo objectForKey:@"link"]);
        
        // 下载weixin分享用的图片，并保存在内存
        NSURL *weixinImageURL = [NSURL URLWithString:[_shareInfo objectForKey:@"pic_weixin"]];
        [[SDWebImageManager sharedManager] downloadImageWithURL:weixinImageURL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            // 下载进度block
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            // 下载完成block
            NSLog(@"下载微信分享用的图片：完成");
            _shareImageForWeixin = [image copy];
            NSLog(@"%@",_shareImageForWeixin);
        }];
        
        // 下载weibo分享用的图片，并保存在内存
        NSURL *weiboImageURL = [NSURL URLWithString:[_shareInfo objectForKey:@"pic_weibo"]];
        [[SDWebImageManager sharedManager] downloadImageWithURL:weiboImageURL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            // 下载进度block
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            // 下载完成block
            NSLog(@"下载weibo分享用的图片：完成");
            _shareImageForWeibo = [image copy];
            NSLog(@"%@",_shareImageForWeibo);
        }];
        
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
    [_loadingFlower startAnimating];
}

// 请求完成
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView.loading) {
        NSLog(@"继续请求中");
    }
    else {
        NSLog(@"webview 请求完成");
        [_loadingFlower stopAnimating];
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
        NSLog(@"Share to Weibo:%@", arr[1]);
        [self shareToWeibo];
        return false;
    }
    // share to weixin
    if ([arr[0] isEqualToString:@"saltfish-share-weixin"]) {
        NSLog(@"Share to Weibo:%@", arr[1]);
        [self shareToWeixinWithTimeLine:NO];
        return false;
    }
    // share to weixin-timeline
    if ([arr[0] isEqualToString:@"saltfish-share-weixin-timeline"]) {
        NSLog(@"Share to Weibo:%@", arr[1]);
        [self shareToWeixinWithTimeLine:YES];
        return false;
    }
    // copy link
    if ([arr[0] isEqualToString:@"saltfish-share-copy-link"]) {
        NSLog(@"Share to Weibo:%@", arr[1]);
        [self copyShareLink];
        return false;
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
    
    if (_praiseButtonView.tag == 11) {
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
    if (_praiseNumLabel.text) {
        int i = [_praiseNumLabel.text intValue] + 1;
        _praiseNumLabel.text = (NSString *)[NSString stringWithFormat:@"%ld", (long)i];
    } else {
        [self basedPraiseNumLabelWith:@"1"];
    }
   
    
    // change praise button status
    _praiseImageView.image = [UIImage imageNamed:@"praise_button_red.png"];
    _praiseButtonView.tag = 11;
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
//    [_praiseButton setTitleColor:[colorManager lightTextColor] forState:UIControlStateNormal];
    _praiseImageView.image = [UIImage imageNamed:@"praise_button.png"];
    _praiseButtonView.tag = 10;  // no praise
}



#pragma mark - UIActionSheet
- (void)clickShareButton {
    NSLog(@"点分享");
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"分享到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信好友", @"微信朋友圈", @"新浪微博", @"复制文章链接", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"微信好友");
        [self shareToWeixinWithTimeLine:NO];
    }else if (buttonIndex == 1) {
        NSLog(@"微信朋友圈");
        [self shareToWeixinWithTimeLine:YES];
    }else if(buttonIndex == 2) {
        NSLog(@"新浪微博");
        [self shareToWeibo];
    }else if(buttonIndex == 3) {
        NSLog(@"复制文章链接");
        [self copyShareLink];
    }
}

- (void)copyShareLink
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [_shareInfo objectForKey:@"link"];
    NSLog(@"复制成功");
    [toastView showToastWith:@"复制成功" duration:2.0 superView:self.view];
}



// 记录为已读
- (void)logAsRead
{
    NSLog(@"the article was read");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults arrayForKey:@"readList"]) {
        // already have a read list
        NSLog(@"already have a read list");
        NSMutableArray *marray = [[userDefaults arrayForKey:@"readList"] mutableCopy];
        // 检查是否重复
        if ([marray containsObject:_articleID]) {
            NSLog(@"重复访问，不记录为已读");
            return;
        }
        [marray addObject:_articleID];
        NSLog(@"%@", marray);
        [userDefaults setObject:[marray copy] forKey:@"readList"];
        
    } else {
        // didn't have a read list, then create one
        NSLog(@"didn't have a read list");
        NSMutableArray *marray = [[NSMutableArray alloc] init];
        [marray addObject:_articleID];
        NSLog(@"%@", marray);
        [userDefaults setObject:[marray copy] forKey:@"readList"];
    }
}





#pragma mark - 分享到微信
- (void)shareToWeixinWithTimeLine:(BOOL)isTimeLine
{
    // 判断是否安装微信
    if (![WXApi isWXAppInstalled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"还没有安装微信哦" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (![WXApi isWXAppSupportApi]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"你的微信版本太低，不支持分享哦" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // 构建消息体
    WXMediaMessage *message = [[WXMediaMessage alloc] init];
    message.title = (NSString *)[_shareInfo objectForKey:@"title"];
    message.description = (NSString *)[_shareInfo objectForKey:@"description"];
    // [message setThumbImage:[UIImage imageNamed:@"share_button.png"]];  // 微信原方法
    // 微信要求分享的图片不超过32k，否则会出现未知错误。目前后台不能压缩图片，那么就从后台传默认图片吧
    [message setThumbImage:_shareImageForWeixin];
    
    WXWebpageObject *webPageObject = [WXWebpageObject object];
    webPageObject.webpageUrl = (NSString *)[_shareInfo objectForKey:@"link"];
    message.mediaObject = webPageObject;
    
    // 发送消息
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.message = message;
    if (isTimeLine) {
        req.scene = WXSceneTimeline;
    } else {
        req.scene = WXSceneSession;
    }
    [WXApi sendReq:req];
}




#pragma mark - 分享到微博
// 分享到新浪微博
- (void)shareToWeibo
{
    // 判断是否安装了微博客户端
    if (![WeiboSDK isWeiboAppInstalled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"还没有安装新浪微博哦" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // 新浪微博授权
//    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
//    request.redirectURI = @"https://api.weibo.com/oauth2/default.html";
//    [WeiboSDK sendRequest: request];
    
    // 获取用户资料
//    [WBHttpRequest requestForUserProfile:@"3865613398" withAccessToken:@"2.008LimdBNBy6sD5321dc16e6qCZkkC" andOtherProperties:nil queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
//        // result 是一个 WeiboUser 类的实例
//        if (error) {
//            NSLog(@"%@",error);
//            return;
//        }
//        NSLog(@"%@", ((WeiboUser *)result).name);
//        NSLog(@"%@", ((WeiboUser *)result).location);
//        NSLog(@"%@", ((WeiboUser *)result).userDescription);
//        NSLog(@"%@", ((WeiboUser *)result).profileImageUrl);
//    }];
    
    // 发送消息到新浪微博(不需要 access token)
    [WBProvideMessageForWeiboResponse responseWithMessage:[self messageToShare]];
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self messageToShare]];
    request.userInfo = nil;  // 开发者自己定义的一些标识可以放在这里面
    [WeiboSDK sendRequest:request];
}


#pragma mark - 消息的封装
- (WBMessageObject *)messageToShare
{
    WBMessageObject *message = [WBMessageObject message];
    message.text = [_shareInfo objectForKey:@"text_weibo"];
    
    // 设置配图
    WBImageObject *image = [WBImageObject object];
    // image.imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_1" ofType:@"jpg"]]; // 微博的原方法
    
    NSData *imageData;
    if (UIImagePNGRepresentation(_shareImageForWeibo)) {
        imageData = UIImagePNGRepresentation(_shareImageForWeibo);
    } else if (UIImageJPEGRepresentation(_shareImageForWeibo, 1.0)){
        imageData = UIImageJPEGRepresentation(_shareImageForWeibo, 1.0);
    }
    image.imageData = imageData;
    message.imageObject = image;
    
    //下面注释的是发送图片和媒体文件
    //    if (self.imageSwitch.on)
    //    {
    //        WBImageObject *image = [WBImageObject object];
    //        image.imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_1" ofType:@"jpg"]];
    //        message.imageObject = image;
    //    }
    //
    //    if (self.mediaSwitch.on)
    //    {
    //        WBWebpageObject *webpage = [WBWebpageObject object];
    //        webpage.objectID = @"identifier1";
    //        webpage.title = @"分享网页标题";
    //        webpage.description = [NSString stringWithFormat:@"分享网页内容简介-%.0f", [[NSDate date] timeIntervalSince1970]];
    //        webpage.thumbnailData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_2" ofType:@"jpg"]];
    //        webpage.webpageUrl = @"http://sina.cn?a=1";
    //        message.mediaObject = webpage;
    //    }
    
    return message;
}



@end
