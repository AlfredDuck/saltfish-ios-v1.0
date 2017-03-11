//
//  SFLoginViewController.m
//  saltfish
//
//  Created by alfred on 16/8/6.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFThirdLoginViewController.h"
#import "colorManager.h"
#import "WeiboSDK.h"
#import "AFNetworking.h"
#import "urlManager.h"

@interface SFThirdLoginViewController ()
@end

@implementation SFThirdLoginViewController

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
    [self createUIParts];
}

- (void)viewWillAppear:(BOOL)animated {
    // 设置状态栏颜色的强力方法
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    // 发起微博登录流程
    [self requestForWeiboAuthorize];
    [self waitForWeiboAuthorizeResult];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    // uiviewcontroller 释放前会调用
    [[NSNotificationCenter defaultCenter] removeObserver:self];  // 注销观察者
}



#pragma mark - 构建UI
- (void)createUIParts
{
    /* 关闭按钮 */
    UIImage *oneImage = [UIImage imageNamed:@"close.png"]; // 使用ImageView通过name找到图片
    UIImageView *oneImageView = [[UIImageView alloc] initWithImage:oneImage]; // 把oneImage添加到oneImageView上
    oneImageView.frame = CGRectMake(14.5, 14.5, 15, 15); // 设置图片位置和大小
    // [oneImageView setContentMode:UIViewContentModeCenter];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [backView addSubview:oneImageView];
    // 为UIView添加点击事件
    // 一定要先将userInteractionEnabled置为YES，这样才能响应单击事件
    backView.userInteractionEnabled = YES; // 设置图片可以交互
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCloseButton)]; // 设置手势
    [backView addGestureRecognizer:singleTap]; // 给图片添加手势
    [self.view addSubview:backView];
    
    /* 小菊花 */
    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake((_screenWidth-200)/2.0, (_screenHeight-60)/2.0, 200, 44+16)];
    // 菊花
    UIActivityIndicatorView *loadingFlower = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingFlower.frame = CGRectMake((200-44)/2.0, 0, 44, 44);
    [loadingFlower startAnimating];
    //[_loadingFlower stopAnimating];
    // loading 文案
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, 200, 16)];
    loadingLabel.text = @"正在登录...";
    loadingLabel.textColor = [colorManager secondTextColor];
    loadingLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    
    [loadingView addSubview:loadingLabel];
    [loadingView addSubview:loadingFlower];
    [self.view addSubview:loadingView];
}



#pragma mark - IBAction
- (void)clickCloseButton {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"退出登录页面");
    }];
}



#pragma mark - 新浪微博授权请求
- (void)requestForWeiboAuthorize
{
    WBAuthorizeRequest *authorReq = [[WBAuthorizeRequest alloc] init];
    authorReq.redirectURI = @"https://api.weibo.com/oauth2/default.html";
    authorReq.scope = @"";
    authorReq.shouldShowWebViewForAuthIfCannotSSO = YES;
    [WeiboSDK sendRequest:authorReq];
}


#pragma mark - 登录授权成功后，获取用户信息
/** 注册观察者 **/
- (void)waitForWeiboAuthorizeResult
{
    // 新浪微博授权成功
    [[NSNotificationCenter defaultCenter] addObserverForName:@"weiboAuthorizeSuccess" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"%@", note.name);
        NSLog(@"%@", note.object);
        
        [self requestForUserInfoWithToken:[note.object objectForKey:@"token"] uid:[note.object objectForKey:@"uid"]];
        // 打印授权信息
        [self printAuthWith:note.object];
    }];
    
    // 新浪微博授权失败
    [[NSNotificationCenter defaultCenter] addObserverForName:@"weiboAuthorizeFalse" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"%@",note.name);
    }];
}


/** 调用微博的用户信息接口 **/
- (void)requestForUserInfoWithToken:(NSString *)token uid:(NSString *)uid
{
    NSString *url = @"https://api.weibo.com/2/users/show.json";
    NSDictionary *param = @{@"access_token":token,
                            @"uid":uid
                            };
    // 请求用户信息
    [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:param queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
        NSLog(@"%@", result);
        NSString *nickname = [result objectForKey:@"name"];
        NSString *portrait = [result objectForKey:@"avatar_large"];
        NSLog(@"用户昵称：%@,%@", nickname, portrait);
        
        NSDictionary *user = @{
                               @"uid":uid,
                               @"nickname":[result objectForKey:@"name"],
                               @"portrait":[result objectForKey:@"avatar_large"]
                               };
        
        // 登录注册
        [self connectForloginOrSignup:user];
        
    }];
}


#pragma mark - 到 轻闻server 登录或注册
- (void)connectForloginOrSignup:(NSDictionary *)userInformation
{
    NSLog(@"登录或注册请求");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/user/weibo_login"];
    
    NSDictionary *parameters = @{
                                 @"uid":[userInformation objectForKey:@"uid"],
                                 @"nickname": [userInformation objectForKey:@"nickname"],
                                 @"portrait_url": [userInformation objectForKey:@"portrait"]
                                 };
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        NSLog(@"errcode：%@", errcode);
        NSLog(@"在轻闻server登录成功的data:%@", data);
        
        if ([errcode isEqualToString:@"err"]) {  // 请求出错
            NSLog(@"在轻闻server登录时出错");
        }
        // 新浪微博登录成功后,账号储存在本地
        [self weiboLoginSuccess:data];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


#pragma mark - 新浪微博登录成功后,账号储存在本地
- (void)weiboLoginSuccess:(NSDictionary *)data
{
    // 不论server下发的有什么内容，本地只按照某种标准格式储存
    NSDictionary *userData = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [data objectForKey:@"userType"], @"userType",  // 账户类型：邮箱、微博、微信等
                              [data objectForKey:@"nickname"] ,@"nickname",  // 昵称
                              [data objectForKey:@"weiboID"], @"uid",  // 用户id（此处是微博）
                              [data objectForKey:@"portraitURL"], @"portrait",  // 头像url
                              nil];
    
    // 账号信息记录到本地
    NSUserDefaults *sfUserDefault = [NSUserDefaults standardUserDefaults];
    [sfUserDefault setObject:userData forKey:@"loginInfo"];
    // 检查所有 nsuserdefault
    //    NSArray *allkey = [[sfUserDefault dictionaryRepresentation] allKeys];
    //    NSLog(@"全部keys：%@", allkey);
    
    // 调用代理方法，通知登录成功
    // [self.delegate weiboLoginSuccess];
    
    // 显示登录结果
    [self showLoginResult];
    
    // 延迟一段时间后执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 退出登录页面
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@"登录成功后退出登录页面");
        }];
    });

}



#pragma mark - 登陆成功的提示
/** 显示登录结果 **/
- (void)showLoginResult
{
    UIView *oneView = [[UIView alloc] initWithFrame:CGRectMake((_screenWidth-200)/2.0, (_screenHeight-60)/2.0, 200, 60)];
    oneView.backgroundColor = [UIColor grayColor];
    
    UILabel *oneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    oneLabel.text = @"登录成功\nWelcome!";
    oneLabel.textColor = [UIColor whiteColor];
    oneLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    oneLabel.numberOfLines = 2;
    oneLabel.textAlignment = NSTextAlignmentCenter;
    
    [oneView addSubview:oneLabel];
    [self.view addSubview:oneView];
}



#pragma mark - 打印授权信息：token
- (void)printAuthWith:(NSDictionary *)info
{
    if ([urlManager printToken]) {
        // 打印开关开启
        NSString *oneToken = [info objectForKey:@"token"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"打印token" message:oneToken delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alert show];
    }
}



@end
