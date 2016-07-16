//
//  SFPersonalViewController.m
//  saltfish
//
//  Created by alfred on 16/7/16.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFPersonalViewController.h"
#import "colorManager.h"

@interface SFPersonalViewController ()

@end

@implementation SFPersonalViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    [self createUIParts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 构建 UI 零件
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
    titleLabel.text = @"啦啦啦";
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
    
    /* 创建注销按钮 */
    [self createSignoutButton];
}



#pragma mark - 创建注销按钮

- (void)createSignoutButton
{
    /* 注销按钮 */
    UIView *signoutBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 64+15, _screenWidth, 44)];
    signoutBackground.backgroundColor = [UIColor whiteColor];

    // label
    UILabel *labels = [[UILabel alloc] initWithFrame:CGRectMake((_screenWidth-200)/2.0, 0, 200, 44)];
    labels.text = @"退出登录 ( ^_^ )/";
    labels.textColor = [UIColor colorWithRed:231/255.0 green:114/255.0 blue:114/255.0 alpha:1.0];
    labels.font = [UIFont fontWithName:@"Helvetica" size: 14.0];
    labels.textAlignment = UITextAlignmentCenter;
    [signoutBackground addSubview:labels];
    
    signoutBackground.userInteractionEnabled = YES; // 设置可以交互
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSignout)]; // 设置手势
    [signoutBackground addGestureRecognizer:singleTap]; // 添加手势
    [self.view addSubview: signoutBackground];
}



#pragma mark - IBAction
- (void)clickBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickSignout
{
    NSLog(@"退出登录！");
    NSUserDefaults *sfUserDefault = [NSUserDefaults standardUserDefaults];
    [sfUserDefault removeObjectForKey:@"loginInfo"];
    
    // 调用代理
    [self.delegate signout];
    
    // 退出页面
    [self.navigationController popViewControllerAnimated:YES];
}


@end
