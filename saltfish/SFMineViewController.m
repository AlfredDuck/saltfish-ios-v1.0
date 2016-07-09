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

- (void)clickAppStore
{
    
}

- (void)clickComment
{
    
}




@end
