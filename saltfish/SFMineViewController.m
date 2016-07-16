//
//  SFMineViewController.m
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFMineViewController.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "urlManager.h"
#import "colorManager.h"
#import "SFMyFollowTopicViewController.h"
#import "SFPersonalViewController.h"
#import "WeiboSDK.h"


@interface SFMineViewController ()

@end

@implementation SFMineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"test";
        self.view.backgroundColor = [UIColor yellowColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    [self createUIParts];
    [super createTabBarWith:2];  // 调用父类方法，构建tabbar
    NSLog(@"%@",[super tabBarBackgroundView]);
    
    /* 注册 notificationCenter 观察者 */
    [self waitForWeiboAuthorizeResult];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    // uiviewcontroller 释放前会调用
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}





#pragma mark - 构建 UI 零件
- (void)createUIParts
{
    /* 顶部图片区域 */
    // 背景图片(图片内置)
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    backgroundImageView.backgroundColor = [UIColor whiteColor];
    int hh = 186;
    backgroundImageView.frame = CGRectMake(0, 0, _screenWidth, hh);
    // uiimageview居中裁剪
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.clipsToBounds  = YES;
    [self.view addSubview:backgroundImageView];
    
    /* 登录按钮 */
    [self createLoginButton];
    
    /* 昵称/说明文字 */
    [self createNickname];
    
    /* 头像和昵称 */
    //[self createPortrait];
    
    
    /* 下方 scrollview 区域 */
    UIScrollView *oneScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, hh, _screenWidth, _screenHeight-44-hh)];
    oneScrollView.backgroundColor = [colorManager lightGrayBackground];
    oneScrollView.contentSize = CGSizeMake(_screenWidth, _screenHeight-hh-44+1);
    [self.view addSubview:oneScrollView];
    
    
    /* 我的话题 */
    UIView *myTopicView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, _screenWidth, 44)];
    myTopicView.backgroundColor = [UIColor whiteColor];
    // icon图片
    UIImageView *myTopicIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"my_topic.png"]];
    myTopicIcon.frame = CGRectMake(12.5, 12, 19, 20);
    UIView *myTopicIconView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, 44, 44)];
    [myTopicIconView addSubview:myTopicIcon];
    [myTopicView addSubview:myTopicIconView];
    // label
    UILabel *myTopicLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, _screenWidth-55, 44)];
    myTopicLabel.text = @"我的话题";
    myTopicLabel.font = [UIFont fontWithName:@"Helvetica" size: 14.0];
    [myTopicView addSubview:myTopicLabel];
    
    myTopicView.userInteractionEnabled = YES; // 设置可以交互
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMyTopic)]; // 设置手势
    [myTopicView addGestureRecognizer:singleTap]; // 添加手势
    [oneScrollView addSubview: myTopicView];
    
    
    /* 去 AppStore 评价 */
    UIView *AppStoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 15+44, _screenWidth, 44)];
    AppStoreView.backgroundColor = [UIColor whiteColor];
    // 分割线
    UIView *partLine = [[UIView alloc] initWithFrame:CGRectMake(55, 0, _screenWidth-55, 0.5)];
    partLine.backgroundColor = [colorManager lightGrayBackground];
    [AppStoreView addSubview:partLine];
    // icon图片
    UIImageView *AppStoreIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_store.png"]];
    AppStoreIcon.frame = CGRectMake(12.5, 11.5, 19, 21);
    UIView *AppStoreIconView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, 44, 44)];
    [AppStoreIconView addSubview:AppStoreIcon];
    [AppStoreView addSubview:AppStoreIconView];
    // label
    UILabel *AppStoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, _screenWidth-55, 44)];
    AppStoreLabel.text = @"去 App Store 给一个⭐️⭐️⭐️⭐️⭐️评价吧";
    AppStoreLabel.font = [UIFont fontWithName:@"Helvetica" size: 14.0];
    [AppStoreView addSubview:AppStoreLabel];
    
    AppStoreView.userInteractionEnabled = YES; // 设置可以交互
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAppStore)]; // 设置手势
    [AppStoreView addGestureRecognizer:singleTap2]; // 添加手势
    [oneScrollView addSubview: AppStoreView];
    
    
    /* 吐槽区 */
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 15+44+44, _screenWidth, 44)];
    commentView.backgroundColor = [UIColor whiteColor];
    // 分割线
    UIView *partLine2 = [[UIView alloc] initWithFrame:CGRectMake(55, 0, _screenWidth-55, 0.5)];
    partLine2.backgroundColor = [colorManager lightGrayBackground];
    [commentView addSubview:partLine2];
    // icon图片
    UIImageView *commentIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"my_comment.png"]];
    commentIcon.frame = CGRectMake(11, 11.5, 22, 21);
    UIView *commentIconView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, 44, 44)];
    [commentIconView addSubview:commentIcon];
    [commentView addSubview:commentIconView];
    // label
    UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, _screenWidth-55, 44)];
    commentLabel.text = @"吐槽能量收集区";
    commentLabel.font = [UIFont fontWithName:@"Helvetica" size: 14.0];
    [commentView addSubview:commentLabel];
    
    commentView.userInteractionEnabled = YES; // 设置可以交互
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickComment)]; // 设置手势
    [commentView addGestureRecognizer:singleTap3]; // 添加手势
    [oneScrollView addSubview: commentView];
}



#pragma mark - 登录按钮
- (void)createLoginButton
{
    UIView *loginButtonBackground = [[UIView alloc] initWithFrame:CGRectMake((_screenWidth-74)/2.0, 53, 74, 74)];
    [self.view addSubview:loginButtonBackground];
    
    // 绘制透明圆形背景
    UIView *round = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 74, 74)];
    round.layer.masksToBounds = YES; //没这句话它圆不起来
    round.layer.cornerRadius = 37.0; //设置图片圆角的尺度
    round.backgroundColor = [UIColor whiteColor];
    round.alpha = 0.85;
    [loginButtonBackground addSubview:round];
    
    // 文本
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(13, 27, 49, 20)];
    title.textColor = [colorManager mainTextColor];
    title.text = @"登录";
    title.font = [UIFont fontWithName:@"Helvetica" size: 14.0];
    title.textAlignment = UITextAlignmentCenter;
    [loginButtonBackground addSubview:title];
    
    // 添加手势
    loginButtonBackground.userInteractionEnabled = YES; // 设置可以交互
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickLoginButton)]; // 设置手势
    [loginButtonBackground addGestureRecognizer:singleTap]; // 添加手势
}


#pragma mark - 昵称/说明文字
- (void)createNickname
{
    // 文字说明
    _nickname = [[UILabel alloc] initWithFrame:CGRectMake((_screenWidth-188)/2.0, 139, 188, 17)];
    _nickname.textColor = [UIColor whiteColor];
    _nickname.text = @"部分功能需登录后才能使用哦";
    _nickname.font = [UIFont fontWithName:@"Helvetica" size: 12.0];
    _nickname.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:_nickname];
}


#pragma mark - 头像
- (void)createPortrait
{
    UIView *portraitBackground = [[UIView alloc] initWithFrame:CGRectMake((_screenWidth-74)/2.0, 53, 74, 74)];
    [self.view addSubview:portraitBackground];
    
    // 绘制透明圆形背景
    UIView *round = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 74, 74)];
    round.layer.masksToBounds = YES; //没这句话它圆不起来
    round.layer.cornerRadius = 37.0; //设置图片圆角的尺度
    round.backgroundColor = [UIColor whiteColor];
    round.alpha = 0.55;
    [portraitBackground addSubview:round];
    
    // 绘制头像图片
    UIImageView *portraitImage = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 70, 70)];
    portraitImage.layer.masksToBounds = YES; //没这句话它圆不起来
    portraitImage.layer.cornerRadius = 35.0; //设置图片圆角的尺度
    portraitImage.backgroundColor = [UIColor grayColor];
    // uiimageview居中裁剪
    portraitImage.contentMode = UIViewContentModeScaleAspectFill;
    portraitImage.clipsToBounds  = YES;
    // 需要AFNetwork
    NSString *url = @"http://i10.topitme.com/l041/100414512045354e75.jpg";
    [portraitImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    [portraitBackground addSubview:portraitImage];
    
    // 添加手势
    portraitBackground.userInteractionEnabled = YES; // 设置可以交互
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPortrait)]; // 设置手势
    [portraitBackground addGestureRecognizer:singleTap]; // 添加手势
}





#pragma mark - IBAction
- (void)clickLoginButton
{
    [self chooseLoginWayWith:@"选择登录方式\n请先登录"];
}

- (void)clickPortrait
{
    SFPersonalViewController *personalPage = [[SFPersonalViewController alloc] init];
    [self.navigationController pushViewController:personalPage animated:YES];
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)clickMyTopic
{
    NSLog(@"click my topic");
    SFMyFollowTopicViewController *myTopicPV = [[SFMyFollowTopicViewController alloc] init];
    [self.navigationController pushViewController:myTopicPV animated:YES];
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)clickAppStore{}

- (void)clickComment{}




#pragma mark - 选择登录方式 UIActionSheet
- (void)chooseLoginWayWith:(NSString *)title
{
    NSLog(@"选择登录方式");
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"邮箱登录/注册", @"使用新浪微博帐号", @"测试获取用户信息",nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {

    }
    else if (buttonIndex == 1) {
        NSLog(@"新浪微博登录");
        [self loginWithWeibo];
    }
    else if (buttonIndex == 2) {
    }
}



#pragma mark - 新浪微博登录授权
- (void)loginWithWeibo
{
    WBAuthorizeRequest *authorReq = [[WBAuthorizeRequest alloc] init];
    authorReq.redirectURI = @"https://api.weibo.com/oauth2/default.html";
    authorReq.scope = @"";
    authorReq.shouldShowWebViewForAuthIfCannotSSO = YES;
    [WeiboSDK sendRequest:authorReq];
}



#pragma mark - 登录授权成功后，获取用户信息
/* 注册观察者 */
- (void)waitForWeiboAuthorizeResult
{
    // 新浪微博授权成功
    [[NSNotificationCenter defaultCenter] addObserverForName:@"weiboAuthorizeSuccess" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"%@", note.name);
        NSLog(@"%@", note.object);
        
        [self requestForUserInfoWithToken:[note.object objectForKey:@"token"] uid:[note.object objectForKey:@"uid"]];
        
    }];
    
    // 新浪微博授权失败
    [[NSNotificationCenter defaultCenter] addObserverForName:@"weiboAuthorizeFalse" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"%@",note.name);
    }];
}


/* 调用微博的用户信息接口 */
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


#pragma mark - 到server登录或注册
- (void)connectForloginOrSignup:(NSDictionary *)userInformation
{
    NSLog(@"登录或注册请求");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/index/weibo_login"];
    
    NSDictionary *parameters = @{
                                 @"uid":[userInformation objectForKey:@"uid"],
                                 @"nickname": [userInformation objectForKey:@"nickname"],
                                 @"portrait": [userInformation objectForKey:@"portrait"]
                                 };
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        NSLog(@"errcode：%@", errcode);
        NSLog(@"data:%@", data);
        
        // 登录成功后，重置UI
        [self weiboLoginSuccess:data];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}



#pragma mark - 新浪微博登录成功后...
- (void)weiboLoginSuccess:(NSDictionary *)userData
{
    // 账号信息记录到本地
    
    // 重置UI
    
}





@end








