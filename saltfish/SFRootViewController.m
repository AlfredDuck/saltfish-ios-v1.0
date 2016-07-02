//
//  SFRootViewController.m
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFRootViewController.h"
#import "SFHomeViewController.h"
#import "SFDiscoveryViewController.h"
#import "SFMineViewController.h"

@interface SFRootViewController ()

@end

@implementation SFRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"test";
        self.view.backgroundColor = [UIColor whiteColor];
        //隐藏系统提供的tabbar
        [self.tabBar setHidden:YES];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    [self createFirstLevelPages];
    [self createTabBar];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 创建 First Level 页面

- (void)createFirstLevelPages
{
    // 创建若干个VC
    SFHomeViewController *homeVC = [[SFHomeViewController alloc]init];
//    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:110];
//    homeVC.tabBarItem = item1;
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    homeNav.navigationBar.hidden = YES;
    
    SFDiscoveryViewController *discoveryVC = [[SFDiscoveryViewController alloc]init];
//    UITabBarItem *item2 = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:120];
//    discoveryVC.tabBarItem = item2;
    UINavigationController *discoveryNav = [[UINavigationController alloc] initWithRootViewController:discoveryVC];
    discoveryNav.navigationBar.hidden = YES;
    
    SFMineViewController *mineVC = [[SFMineViewController alloc]init];
//    UITabBarItem *item3 = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:130];
//    mineVC.tabBarItem = item3;
    UINavigationController *mineNav = [[UINavigationController alloc] initWithRootViewController:mineVC];
    mineNav.navigationBar.hidden = YES;
    
    // 将这几个VC放入数组
    NSArray *viewControllers = @[homeNav, discoveryNav, mineNav];
    
    //数组添加到tabBarController
    //   UITabBarController *tabBarController = [[UITabBarController alloc] init];
    //tabBarController.viewControllers  = viewControllers;
    [self setViewControllers:viewControllers animated:YES];
    
}


#pragma mark - 创建底部 tabBar
- (void)createTabBar
{
    /* tabbar 背景 */
    _tabBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, _screenHeight-44, _screenWidth, 44)];
    _tabBarBackgroundView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_tabBarBackgroundView];
    
    
    /* 三个底部tab */
    // first tab
    UIView *tabView01 = [[UIView alloc] init];
    tabView01.backgroundColor  = [UIColor brownColor];
    tabView01.tag = 1;   // 添加tag
    tabView01.frame = CGRectMake(0, 0, ceil(_screenWidth/3.0), 44);  // 这里要取整
    tabView01.userInteractionEnabled = YES; // 设置view可以交互
    UITapGestureRecognizer *singleTap01 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTab:)];   // 设置手势
    [tabView01 addGestureRecognizer:singleTap01]; // 给view添加手势
    [_tabBarBackgroundView addSubview:tabView01];
    
    // second tab
    UIView *tabView02 = [[UIView alloc] init];
    tabView02.backgroundColor  = [UIColor brownColor];
    tabView02.tag = 2;  // 添加tag
    tabView02.frame = CGRectMake(ceil(_screenWidth/3.0), 0, ceil(_screenWidth/3.0), 44);  // 这里要取整
    tabView02.userInteractionEnabled = YES; // 设置view可以交互
    UITapGestureRecognizer *singleTap02 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTab:)];   // 设置手势
    [tabView02 addGestureRecognizer:singleTap02]; // 给view添加手势
    [_tabBarBackgroundView addSubview:tabView02];
    
    // third tab
    UIView *tabView03 = [[UIView alloc] init];
    tabView03.backgroundColor  = [UIColor brownColor];
    tabView03.tag = 3;   // 添加tag
    tabView03.frame = CGRectMake(ceil(_screenWidth/3.0)*2, 0, ceil(_screenWidth/3.0), 44);  // 这里要取整
    tabView03.userInteractionEnabled = YES; // 设置view可以交互
    UITapGestureRecognizer *singleTap03 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTab:)];   // 设置手势
    [tabView03 addGestureRecognizer:singleTap03]; // 给view添加手势
    [_tabBarBackgroundView addSubview:tabView03];
    
}



#pragma mark - IBAction
- (void)clickTab:(UIGestureRecognizer *)sender
{
    NSLog(@"%ld", sender.view.tag);
    self.selectedIndex = sender.view.tag - 1;
    
}



@end
