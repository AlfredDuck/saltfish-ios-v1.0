//
//  SFCustomerFeedbackViewController.m
//  saltfish
//
//  Created by alfred on 16/7/17.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFCustomerFeedbackViewController.h"
#import "toastView.h"
#import "colorManager.h"
#import "urlManager.h"
#import "AFNetworking.h"

@interface SFCustomerFeedbackViewController ()

@end

@implementation SFCustomerFeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"title";
        self.view.backgroundColor = [colorManager lightGrayBackground];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    // 设置状态栏颜色的强力方法
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    // 创建 UI
    [self basedTitleBar];
    [self basedWriteText];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_screenWidth-200)/2, 20, 200, 44)];
    titleLabel.text = _pageTitle;
    titleLabel.textColor = [colorManager mainTextColor];
    titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 16];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleBarBackground addSubview:titleLabel];
    
    // 返回按钮
    UIImage *oneImage = [UIImage imageNamed:@"close.png"]; // 使用ImageView通过name找到图片
    UIImageView *oneImageView = [[UIImageView alloc] initWithImage:oneImage]; // 把oneImage添加到oneImageView上
    oneImageView.frame = CGRectMake(14.5, 14.5, 15, 15); // 设置图片位置和大小
    // [oneImageView setContentMode:UIViewContentModeCenter];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [backView addSubview:oneImageView];
    // 为UIView添加点击事件
    // 一定要先将userInteractionEnabled置为YES，这样才能响应单击事件
    backView.userInteractionEnabled = YES; // 设置图片可以交互
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBackButton)]; // 设置手势
    [backView addGestureRecognizer:singleTap]; // 给图片添加手势
    [titleBarBackground addSubview:backView];
    
    // “发送” 按钮
    _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(_screenWidth - 48, 20, 48, 43)];
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    _sendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    UIColor *buttonColor = [UIColor colorWithRed:74/255.0 green:144/255.0 blue:226/255.0 alpha:1];
    [_sendButton setTitleColor:buttonColor forState:UIControlStateNormal];
    _sendButton.backgroundColor = [UIColor whiteColor];
    _sendButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    [_sendButton addTarget:self action:@selector(clickSendButton) forControlEvents:UIControlEventTouchUpInside];
    [titleBarBackground addSubview:_sendButton];
}


// 创建输入文本区域
- (void)basedWriteText
{
    // 评论输入框
    UIView *commentBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 64+15, _screenWidth, 118)];
    commentBackground.backgroundColor = [UIColor whiteColor];
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 0.5)];
    UIView *line4 = [[UIView alloc] initWithFrame:CGRectMake(0, 118-0.5, _screenWidth, 0.5)];
    line3.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1];
    line4.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1];
    [commentBackground addSubview:line3];
    [commentBackground addSubview:line4];
    
    [self.view addSubview:commentBackground];
    
    _contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(7, 5, _screenWidth-7, 118-10)];
    // _contentTextView.backgroundColor = [UIColor yellowColor];
    // _contentTextView.text = @"在那個蒸氣時代裡，一切都以蒸氣為動力。煙霧瀰漫的帝都，怪盜、怪人橫行肆虐";
    _contentTextView.textColor = [colorManager mainTextColor];
    _contentTextView.font = [UIFont fontWithName:@"Helvetica" size:14];
    _contentTextView.delegate = self;
    [commentBackground addSubview:_contentTextView];
    
    // 自定义 UITextView 的 placeholder
    _placeholder = [[UILabel alloc] initWithFrame:CGRectMake(13,1,_screenWidth-20,40)];
    _placeholder.text = @"希望添加哪些话题？或有什么建议？";
    _placeholder.textColor = [UIColor lightGrayColor];
    _placeholder.font = [UIFont fontWithName:@"Helvetica" size: 14];
    [commentBackground addSubview:_placeholder];
    
}

/* 发送按钮的两种状态 */
- (void)readyToSend
{
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    UIColor *buttonColor = [UIColor colorWithRed:74/255.0 green:144/255.0 blue:226/255.0 alpha:1];
    [_sendButton setTitleColor:buttonColor forState:UIControlStateNormal];
    _sendButton.frame = CGRectMake(_screenWidth - 48, 20, 48, 43);
}

- (void)sending
{
    [_sendButton setTitle:@"发送中..." forState:UIControlStateNormal];
    UIColor *buttonColor = [colorManager lightTextColor];
    [_sendButton setTitleColor:buttonColor forState:UIControlStateNormal];
    _sendButton.frame = CGRectMake(_screenWidth - 60, 20, 60, 43);
    
}





#pragma mark - UITextView 代理方法
// 内容发生改变
- (void)textViewDidChange:(UITextView *)textView
{
    _placeholder.hidden = YES;
}

// 隐藏键盘(点击空白处)
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"隐藏键盘");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}








#pragma mark - IBAction

- (void)clickBackButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clickSendButton
{
    NSLog(@"点击发送按钮");
    
    // 关闭键盘
    [_contentTextView resignFirstResponder];
    
    // 检查是否“发送中...”状态
    if ([_sendButton.titleLabel.text isEqualToString:@"发送中..."]) {
        NSLog(@"正在发送，请勿重复点击");
        return;
    }
    
    // 检查输入是否为空
    if ([_contentTextView.text isEqualToString:@""]) {
        NSLog(@"请输入评论内容");
        return;
    }
    
    // 显示“发送中...”状态
    [_sendButton setTitle:@"发送中..." forState:UIControlStateNormal];
    UIColor *buttonColor = [colorManager lightTextColor];
    [_sendButton setTitleColor:buttonColor forState:UIControlStateNormal];
    _sendButton.frame = CGRectMake(_screenWidth - 60, 20, 60, 43);
    
    // 发起网络请求
    [self connectForWriteComment:_contentTextView.text];
}






#pragma mark - 网络请求
- (void)connectForWriteComment:(NSString *)comment
{
    NSLog(@"start write comment request !");

    // 准备请求参数
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/user/customer_feedback"];
    
    // 读取设备的uuid
    NSString *uuid = @"";
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:@"uuid"]) {
        uuid = [userDefault objectForKey:@"uuid"];
    }
    // 读取本地的uid
    NSString *uid = @"";
    NSString *userType = @"";
    if ([[userDefault dictionaryForKey:@"loginInfo"] objectForKey:@"uid"]) {
        uid = [[userDefault dictionaryForKey:@"loginInfo"] objectForKey:@"uid"];
        userType = [[userDefault dictionaryForKey:@"loginInfo"] objectForKey:@"userType"];
    }
    
    
    //NSDictionary *parameters = @{
//                                 @"content": comment,
//                                 @"uid": uid,
//                                 @"user_type": userType,
//                                 @"device_type": @"ios",
//                                 @"device_id": uuid
//                                 };
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 comment,@"content",
                                 uid,@"uid",
                                 userType,@"user_type",
                                 @"ios",@"device_type",
                                 uuid,@"device_id",
                                 nil];
    NSLog(@"会不会执行到这里");
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // NSLog(@"JSON: %@", responseObject); // AF 已将json转为字典
        
        // 请求成功
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        if ([errcode isEqualToString:@"err"]) {
            NSLog(@"写入评论出错");
            return;
        }
        NSLog(@"请求状态：%@", errcode);
        
        // 返回上一页
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate sendFeedbackSuccess];
        }];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self readyToSend];
        [toastView showToastWith:@"发送失败，请重试" isErr:NO duration:3.0 superView:self.view];
    }];
}

@end
