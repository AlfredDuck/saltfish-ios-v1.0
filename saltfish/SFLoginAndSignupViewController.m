//
//  SFLoginAndSignupViewController.m
//  saltfish
//
//  Created by alfred on 16/9/20.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFLoginAndSignupViewController.h"
#import "AFNetworking.h"
#import "urlManager.h"
#import "colorManager.h"
#import "toastView.h"


@interface SFLoginAndSignupViewController ()
@end

@implementation SFLoginAndSignupViewController

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


- (void)viewDidLoad
{
    [super viewDidLoad];
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    [self createUIParts];
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
    /* 关闭按钮 */
    UIImage *oneImage = [UIImage imageNamed:@"close.png"]; // 使用ImageView通过name找到图片
    UIImageView *oneImageView = [[UIImageView alloc] initWithImage:oneImage]; // 把oneImage添加到oneImageView上
    oneImageView.frame = CGRectMake(14.5, 14.5, 15, 15); // 设置图片位置和大小
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [backView addSubview:oneImageView];
    // 为UIView添加点击事件
    backView.userInteractionEnabled = YES; // 设置图片可以交互
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCloseButton)]; // 设置手势
    [backView addGestureRecognizer:singleTap]; // 给图片添加手势
    [self.view addSubview:backView];
    
    
    
    /* 切换控件 */
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"登录",@"注册新帐号",nil];
    //初始化UISegmentedControl
    UISegmentedControl *segControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    segControl.frame = CGRectMake(45.0, 60, _screenWidth-90, 26.0);
    segControl.selectedSegmentIndex = 0;  //设置默认选择项索引
    segControl.tintColor = [colorManager blueButtonColor];
    [self.view addSubview: segControl];
    [segControl addTarget:self action:@selector(changeSegmentWith:) forControlEvents:UIControlEventValueChanged];  // 点击事件
    
    
    /* ------ 登录/注册组件 ------ */
    unsigned long hh = 103;
    /* 邮箱输入框 */
    UIView *mailView = [[UIView alloc] initWithFrame:CGRectMake(45, hh, _screenWidth-90, 40)];
    mailView.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
    mailView.layer.masksToBounds = YES;  // 没这句话它圆不起来
    mailView.layer.cornerRadius = 5.0;  // 设置图片圆角的尺度
    [self.view addSubview: mailView];
    
    _mailTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, _screenWidth-120, 40)];
    _mailTextField.placeholder = @"邮箱";
    _mailTextField.textColor = [colorManager mainTextColor];
    _mailTextField.font = [UIFont fontWithName:@"Helvetica" size:14];
    [_mailTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"]; // 改placeholder颜色
    [mailView addSubview: _mailTextField];
    
    /* 密码输入框 */
    UIView *passwordView = [[UIView alloc] initWithFrame:CGRectMake(45, hh+44+8, _screenWidth-90, 40)];
    passwordView.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
    passwordView.layer.masksToBounds = YES;  // 没这句话它圆不起来
    passwordView.layer.cornerRadius = 5.0;  // 设置图片圆角的尺度
    [self.view addSubview: passwordView];
    
    _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, _screenWidth-120, 40)];
    _passwordTextField.placeholder = @"密码";
    _passwordTextField.textColor = [colorManager mainTextColor];
    _passwordTextField.font = [UIFont fontWithName:@"Helvetica" size:14];
    _passwordTextField.secureTextEntry = YES;  // 密码模式
    [_passwordTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"]; // 改placeholder颜色
    [passwordView addSubview: _passwordTextField];
    
    /* 昵称输入框 */
    _nicknameView = [[UIView alloc] initWithFrame:CGRectMake(45, hh+(44+8)*2, _screenWidth-90, 40)];
    _nicknameView.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
    _nicknameView.layer.masksToBounds = YES;  // 没这句话它圆不起来
    _nicknameView.layer.cornerRadius = 5.0;  // 设置图片圆角的尺度
    [self.view addSubview: _nicknameView];
    _nicknameView.hidden = YES;
    
    _nicknameTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, _screenWidth-120, 40)];
    _nicknameTextField.placeholder = @"昵称";
    _nicknameTextField.textColor = [colorManager mainTextColor];
    _nicknameTextField.font = [UIFont fontWithName:@"Helvetica" size:14];
    [_nicknameTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"]; // 改placeholder颜色
    [_nicknameView addSubview: _nicknameTextField];
    
    /* 登录按钮 */
    _loginButton = [[UIView alloc] initWithFrame:CGRectMake(45, hh+(44+8)+(44+12), _screenWidth-90, 40)];
    _loginButton.backgroundColor = [colorManager blueButtonColor];
    _loginButton.layer.masksToBounds = YES;  // 没这句话它圆不起来
    _loginButton.layer.cornerRadius = 5.0;  // 设置图片圆角的尺度
    
    _loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _screenWidth-90, 40)];
    _loginLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    _loginLabel.text = @"登录";
    _loginLabel.textColor = [UIColor whiteColor];
    _loginLabel.textAlignment = NSTextAlignmentCenter;
    [_loginButton addSubview: _loginLabel];
    // 为UIView添加点击事件
    _loginButton.userInteractionEnabled = YES; // 设置图片可以交互
    UITapGestureRecognizer *singleTapLogin = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickLoginButton)]; // 设置手势
    [_loginButton addGestureRecognizer:singleTapLogin]; // 给图片添加手势
    [self.view addSubview: _loginButton];
    
    
    /* 注册按钮 */
    _signupButton = [[UIView alloc] initWithFrame:CGRectMake(45, hh+(44+8)*2+(44+12), _screenWidth-90, 40)];
    _signupButton.backgroundColor = [colorManager blueButtonColor];
    _signupButton.layer.masksToBounds = YES;  // 没这句话它圆不起来
    _signupButton.layer.cornerRadius = 5.0;  // 设置图片圆角的尺度
    _signupButton.hidden = YES;
    
    _signupLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _screenWidth-90, 40)];
    _signupLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    _signupLabel.text = @"注册";
    _signupLabel.textColor = [UIColor whiteColor];
    _signupLabel.textAlignment = NSTextAlignmentCenter;
    [_signupButton addSubview: _signupLabel];
    // 为UIView添加点击事件
    _signupButton.userInteractionEnabled = YES; // 设置图片可以交互
    UITapGestureRecognizer *singleTapSignup = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSignupButton)]; // 设置手势
    [_signupButton addGestureRecognizer:singleTapSignup]; // 给图片添加手势
    [self.view addSubview:_signupButton];
    
}







#pragma mark - IBAction
/** 点击关闭按钮 */
- (void)clickCloseButton
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"已退出native登录注册页面");
    }];
}


/** 改变segment */
- (void)changeSegmentWith:(UIGestureRecognizer *)sender
{
    unsigned index = (unsigned)((UISegmentedControl *)sender).selectedSegmentIndex;
    if (index == 0) {
        _loginButton.hidden = NO;
        _signupButton.hidden = YES;
        _nicknameView.hidden = YES;
    } else if (index == 1) {
        _loginButton.hidden = YES;
        _signupButton.hidden = NO;
        _nicknameView.hidden = NO;
    }
}


/** 点击登录按钮 */
- (void)clickLoginButton
{
    if (![_loginLabel.text isEqualToString:@"登录"]) {
        return;
    }
    
    NSString *mail = _mailTextField.text;
    NSString *password = _passwordTextField.text;
    
    if ([mail isEqualToString:@""] || [password isEqualToString:@""]){
        NSLog(@"请填写邮箱和密码");
        return;
    }
    
    _loginButton.backgroundColor = [UIColor lightGrayColor];
    _loginLabel.text = @"登录中...";
    
    [self connectForLoginWithMail:mail andPassword:password];
}


/** 点击注册按钮 */
- (void)clickSignupButton
{
    if (![_signupLabel.text isEqualToString:@"注册"]) {
        return;
    }
    
    NSString *mail = _mailTextField.text;
    NSString *password = _passwordTextField.text;
    NSString *nickname = _nicknameTextField.text;
    
    if ([mail isEqualToString:@""] || [password isEqualToString:@""] || [nickname isEqualToString:@""]){
        NSLog(@"请填写邮箱和密码");
        return;
    }
    
    _signupButton.backgroundColor = [UIColor lightGrayColor];
    _signupLabel.text = @"注册中...";
    
    [self connectForSignupWithMail:mail andPassword:password andNickname:nickname];
}





#pragma mark - UITextView 代理方法
// 隐藏键盘(点击空白处)
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"隐藏键盘");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}






#pragma mark - 网络请求
/** 请求登录接口 */
- (void)connectForLoginWithMail:(NSString *)mail andPassword:(NSString *)password
{
    NSLog(@"登录请求");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/user/mail_login"];
    
    NSDictionary *parameters = @{
                                 @"mail": mail,
                                 @"password": password
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
            NSLog(@"登录时出错");
            _loginLabel.text = @"登录";
            _loginButton.backgroundColor = [colorManager blueButtonColor];
            [toastView showToastWith:@"服务器出错，请重试" isErr:NO duration:2.0 superView:self.view];
            return;
        }
        if ([[data objectForKey:@"status"] isEqualToString:@"fail"]) {  // 用户不存在，无法登陆
            NSLog(@"用户不存在，请先注册");
            _loginLabel.text = @"登录";
            _loginButton.backgroundColor = [colorManager blueButtonColor];
            [toastView showToastWith:@"邮箱或密码错误" isErr:NO duration:2.0 superView:self.view];
            return;
        }
        
        // 储存登录账户
        [self loginSuccessWith:data];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        _loginLabel.text = @"登录";
        _loginButton.backgroundColor = [colorManager blueButtonColor];
        [toastView showToastWith:@"网络有点问题" isErr:NO duration:2.0 superView:self.view];
    }];
}



/** 注册请求 */
- (void)connectForSignupWithMail:(NSString *)mail andPassword:(NSString *)password andNickname:(NSString *)nickname
{
    NSLog(@"注册请求");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/user/mail_signup"];
    
    NSDictionary *parameters = @{
                                 @"mail": mail,
                                 @"password": password,
                                 @"nickname": nickname
                                 };
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        NSLog(@"errcode：%@", errcode);
        NSLog(@"在轻闻server注册成功的data:%@", data);
        
        if ([errcode isEqualToString:@"err"]) {  // 请求出错
            NSLog(@"注册时出错");
            _signupLabel.text = @"注册";
            _signupButton.backgroundColor = [colorManager blueButtonColor];
            [toastView showToastWith:@"服务器出错，请重试" isErr:NO duration:2.0 superView:self.view];
            return;
        }
        if ([[data objectForKey:@"status"] isEqualToString:@"fail"]) {  // 用户已注册，无法完成注册
            NSLog(@"此用户已注册过");
            _signupLabel.text = @"注册";
            _signupButton.backgroundColor = [colorManager blueButtonColor];
            [toastView showToastWith:@"此邮箱已注册过，请直接登录" isErr:NO duration:2.0 superView:self.view];
            return;
        }
        
        // 储存登录账户
        [self loginSuccessWith:data];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        _signupLabel.text = @"注册";
        _signupButton.backgroundColor = [colorManager blueButtonColor];
        [toastView showToastWith:@"网络有点问题" isErr:NO duration:2.0 superView:self.view];
    }];
}






#pragma mark - 登录or注册成功后储存账号
/** 登录or注册成功后储存在本地 */
- (void)loginSuccessWith:(NSDictionary *)data
{
    // 不论server下发的有什么内容，本地只按照某种标准格式储存
    NSDictionary *userData = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [data objectForKey:@"userType"], @"userType",  // 账户类型：邮箱、微博、微信等
                              [data objectForKey:@"nickname"] ,@"nickname",  // 昵称
                              [data objectForKey:@"mail"], @"uid",  // 用户id（对邮箱用户来说就是邮箱号）
                              [data objectForKey:@"portraitURL"], @"portrait",  // 头像url
                              nil];
    // 账号信息记录到本地
    NSUserDefaults *sfUserDefault = [NSUserDefaults standardUserDefaults];
    [sfUserDefault setObject:userData forKey:@"loginInfo"];
    
    NSLog(@"登录成功：%@", userData);
    
    // 退出登录页面
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"退出登录页面");
    }];
}





@end
