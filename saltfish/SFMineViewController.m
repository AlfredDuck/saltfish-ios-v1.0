//
//  SFMineViewController.m
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFMineViewController.h"
#import "colorManager.h"
#import "SFMyFollowTopicViewController.h"

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

// 修改状态栏色值
// 在你自己的UIViewController里重写此方法，返回你需要的值(UIStatusBarStyleDefault 或者 UIStatusBarStyleLightContent)；
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
    // return  UIStatusBarStyleDefault;
}

- (UIViewController *)childViewControllerForStatusBarStyle{
    return self.navigationController.topViewController;
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
    /* 顶部图片区域 */
    // 背景图片(图片内置)
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"000010-11.jpg"]];
    backgroundImageView.backgroundColor = [UIColor whiteColor];
    int hh = ceil(_screenWidth*200/320.0);
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
    UIImageView *myTopicIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    myTopicIcon.frame = CGRectMake(0, 0, 44, 44);
    
    // label
    UILabel *myTopicLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 200, 44)];
    myTopicLabel.text = @"我的话题⭐️";
    myTopicLabel.font = [UIFont fontWithName:@"Helvetica" size: 15.0];
    [myTopicView addSubview:myTopicLabel];
    
    myTopicView.userInteractionEnabled = YES; // 设置可以交互
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMyTopic)]; // 设置手势
    [myTopicView addGestureRecognizer:singleTap]; // 添加手势
    
    [oneScrollView addSubview: myTopicView];
    
    /* 去 AppStore 评价 */
    UIView *AppStoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 15+44, _screenWidth, 44)];
    AppStoreView.backgroundColor = [UIColor whiteColor];
    [oneScrollView addSubview: AppStoreView];
    
    /* 吐槽区 */
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 15+44+44, _screenWidth, 44)];
    commentView.backgroundColor = [UIColor whiteColor];
    [oneScrollView addSubview: commentView];
}



#pragma mark - IBAction
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




@end
