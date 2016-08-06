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
#import "SFCustomerFeedbackViewController.h"
#import "SFLoginAndSignup.h"
#import "SFLoginViewController.h"
#import "toastView.h"


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
}

- (void)viewWillAppear:(BOOL)animated {
    // 设置状态栏颜色的强力方法
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    /* 根据登录状态来创建头部ui */
    if (_loginButtonBackground) {
        [_loginButtonBackground removeFromSuperview];
    }
    if (_portraitBackground) {
        [_portraitBackground removeFromSuperview];
    }
    
    NSUserDefaults *sfUserDefault = [NSUserDefaults standardUserDefaults];
    if ([sfUserDefault dictionaryForKey:@"loginInfo"]) {
        // 当前是登录状态
        NSString *nickname = [[sfUserDefault dictionaryForKey:@"loginInfo"] objectForKey:@"nickname"];
        _nickname.text = nickname;
        [self createPortrait];
    }
    else {
        // 当前未登录
        _nickname.text = @"部分功能需登录后才能使用哦";
        [self createLoginButton];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    myTopicLabel.text = @"我关注的话题";
    myTopicLabel.font = [UIFont fontWithName:@"Helvetica" size: 15.0];
    myTopicLabel.textColor = [colorManager mainTextColor];
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
    AppStoreLabel.text = @"去 App Store 给个5星评价吧";
    AppStoreLabel.font = [UIFont fontWithName:@"Helvetica" size: 15.0];
    AppStoreLabel.textColor = [colorManager mainTextColor];
    [AppStoreView addSubview:AppStoreLabel];
    
    AppStoreView.userInteractionEnabled = YES; // 设置可以交互
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAppStore)]; // 设置手势
    [AppStoreView addGestureRecognizer:singleTap2]; // 添加手势
    [oneScrollView addSubview: AppStoreView];
    
    
    /* 吐槽区 */
    UIView *customerFeedbackView = [[UIView alloc] initWithFrame:CGRectMake(0, 15+44+44, _screenWidth, 44)];
    customerFeedbackView.backgroundColor = [UIColor whiteColor];
    // 分割线
    UIView *partLine2 = [[UIView alloc] initWithFrame:CGRectMake(55, 0, _screenWidth-55, 0.5)];
    partLine2.backgroundColor = [colorManager lightGrayBackground];
    [customerFeedbackView addSubview:partLine2];
    // icon图片
    UIImageView *commentIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"my_comment.png"]];
    commentIcon.frame = CGRectMake(11, 11.5, 22, 21);
    UIView *commentIconView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, 44, 44)];
    [commentIconView addSubview:commentIcon];
    [customerFeedbackView addSubview:commentIconView];
    // label
    UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, _screenWidth-55, 44)];
    commentLabel.text = @"吐槽能量收集区";
    commentLabel.font = [UIFont fontWithName:@"Helvetica" size: 15.0];
    commentLabel.textColor = [colorManager mainTextColor];
    [customerFeedbackView addSubview:commentLabel];
    
    customerFeedbackView.userInteractionEnabled = YES; // 设置可以交互
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCustomerFeedback)]; // 设置手势
    [customerFeedbackView addGestureRecognizer:singleTap3]; // 添加手势
    [oneScrollView addSubview: customerFeedbackView];
    
    [self createNickname:@""];
}



#pragma mark - 登录按钮
- (void)createLoginButton
{
    _loginButtonBackground = [[UIView alloc] initWithFrame:CGRectMake((_screenWidth-74)/2.0, 53, 74, 74)];
    [self.view addSubview:_loginButtonBackground];
    
    // 绘制透明圆形背景
    UIView *round = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 74, 74)];
    round.layer.masksToBounds = YES; //没这句话它圆不起来
    round.layer.cornerRadius = 37.0; //设置图片圆角的尺度
    round.backgroundColor = [UIColor whiteColor];
    round.alpha = 0.85;
    [_loginButtonBackground addSubview:round];
    
    // 文本
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(13, 27, 49, 20)];
    title.textColor = [colorManager mainTextColor];
    title.text = @"登录";
    title.font = [UIFont fontWithName:@"Helvetica" size: 14.0];
    title.textAlignment = UITextAlignmentCenter;
    [_loginButtonBackground addSubview:title];
    
    // 添加手势
    _loginButtonBackground.userInteractionEnabled = YES; // 设置可以交互
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickLoginButton)]; // 设置手势
    [_loginButtonBackground addGestureRecognizer:singleTap]; // 添加手势
}


#pragma mark - 昵称/说明文字
- (void)createNickname:(NSString *)text
{
    // 文字说明
    _nickname = [[UILabel alloc] initWithFrame:CGRectMake((_screenWidth-188)/2.0, 139, 188, 17)];
    _nickname.textColor = [UIColor whiteColor];
    _nickname.text = text;
    _nickname.font = [UIFont fontWithName:@"Helvetica" size: 12.0];
    _nickname.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:_nickname];
}


#pragma mark - 头像
- (void)createPortrait
{
    _portraitBackground = [[UIView alloc] initWithFrame:CGRectMake((_screenWidth-74)/2.0, 53, 74, 74)];
    [self.view addSubview:_portraitBackground];
    
    // 绘制透明圆形背景
    UIView *round = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 74, 74)];
    round.layer.masksToBounds = YES; //没这句话它圆不起来
    round.layer.cornerRadius = 37.0; //设置图片圆角的尺度
    round.backgroundColor = [UIColor whiteColor];
    round.alpha = 0.55;
    [_portraitBackground addSubview:round];
    
    // 绘制头像图片
    UIImageView *portraitImage = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 70, 70)];
    portraitImage.layer.masksToBounds = YES; //没这句话它圆不起来
    portraitImage.layer.cornerRadius = 35.0; //设置图片圆角的尺度
    portraitImage.backgroundColor = [UIColor grayColor];
    // uiimageview居中裁剪
    portraitImage.contentMode = UIViewContentModeScaleAspectFill;
    portraitImage.clipsToBounds  = YES;
    // 从网络获取图片
    NSString *url = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"loginInfo"] objectForKey:@"portrait"];
    [portraitImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    [_portraitBackground addSubview:portraitImage];
    
    // 添加手势
    _portraitBackground.userInteractionEnabled = YES; // 设置可以交互
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPortrait)]; // 设置手势
    [_portraitBackground addGestureRecognizer:singleTap]; // 添加手势
}





#pragma mark - IBAction
- (void)clickLoginButton
{
    [self chooseLoginWayWith:@"Welcome!\n请选择登录方式"];
}

- (void)clickPortrait
{
    SFPersonalViewController *personalPage = [[SFPersonalViewController alloc] init];
    [self.navigationController pushViewController:personalPage animated:YES];
    personalPage.delegate = self;
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)clickMyTopic
{
    NSLog(@"click my topic");
    NSUserDefaults *sfUserDefault = [NSUserDefaults standardUserDefaults];
    if ([sfUserDefault dictionaryForKey:@"loginInfo"]) {
        // 当前是登录状态
        SFMyFollowTopicViewController *myTopicPV = [[SFMyFollowTopicViewController alloc] init];
        [self.navigationController pushViewController:myTopicPV animated:YES];
        //开启iOS7的滑动返回效果
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
    }
    else {
        // 未登录状态
        [self chooseLoginWayWith:@"请先登录"];
    }
}

- (void)clickAppStore
{
    // 去appstore评论
//    https://itunes.apple.com/us/app/xian-yu-xing-wen-hao-wan-you/id1084092765?mt=8
    NSString *iTunesLink = @"https://itunes.apple.com/us/app/xian-yu-xing-wen-hao-wan-you/id1084092765?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

- (void)clickCustomerFeedback
{
    NSLog(@"click my topic");
    NSUserDefaults *sfUserDefault = [NSUserDefaults standardUserDefaults];
    if ([sfUserDefault dictionaryForKey:@"loginInfo"]) {
        // 当前是登录状态
        SFCustomerFeedbackViewController *customerFeedbackPage = [[SFCustomerFeedbackViewController alloc] init];
        customerFeedbackPage.pageTitle = @"吐槽区";
        customerFeedbackPage.delegate = self;
        [self.navigationController presentViewController:customerFeedbackPage animated:YES completion:^{
            NSLog(@"开启吐槽页面");
        }];
    }
    else {
        // 未登录状态
        [self chooseLoginWayWith:@"登录后再来吐槽吧"];
    }
}





#pragma mark - 选择登录方式 UIActionSheet
- (void)chooseLoginWayWith:(NSString *)title
{
    NSLog(@"选择登录方式");
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: @"微博帐号登录", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"新浪微博登录");
        // 开启登录中间页
        SFLoginViewController *loginPage = [[SFLoginViewController alloc] init];
        [self.navigationController presentViewController:loginPage animated:YES completion:^{
            NSLog(@"开启登录页面");
        }];
//        SFLoginAndSignup *login = [[SFLoginAndSignup alloc] init];
//        [login requestForWeiboAuthorize];
//        [login waitForWeiboAuthorizeResult];
//        login.delegate = self;
    }
}


//#pragma mark - SFLogin&Signup 代理
//- (void)weiboLoginSuccess
//{
//    NSLog(@"我登录成功了，你知道吗？");
//    /* 显示昵称 */
//    NSUserDefaults *sfUserDefault = [NSUserDefaults standardUserDefaults];
//    NSDictionary *userData = [sfUserDefault dictionaryForKey:@"loginInfo"];
//    NSLog(@"%@", userData);
//    _nickname.text = [userData objectForKey:@"nickname"];
//    
//    /* 隐藏登录按钮 */
//    [_loginButtonBackground removeFromSuperview];
//    
//    /* 创建头像 */
//    [self createPortrait];
//}



//#pragma mark - SFPersonalViewController 代理
//- (void)signout
//{
//    _nickname.text = @"部分功能需登录后才能使用哦";
//    
//    /* 隐藏头像 */
//    [_portraitBackground removeFromSuperview];
//    
//    /* 创建登录按钮 */
//    [self createLoginButton];
//    
//}



#pragma mark - SFCutomerFeedback 代理
- (void)sendFeedbackSuccess
{
    [toastView showToastWith:@"已收到你的吐槽[BINGO!]" isErr:YES duration:3.0 superView:self.view];
}


@end








