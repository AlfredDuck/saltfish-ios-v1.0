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
#import "colorManager.h"

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
    _tabBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, _screenHeight-49, _screenWidth, 49)];
    _tabBarBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tabBarBackgroundView];
    
    /* 分割线 */
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 0.5)];
    line.backgroundColor = [colorManager lightGrayLineColor];
    [_tabBarBackgroundView addSubview:line];
    
    NSArray *tabText = @[@"动态",@"发现",@"我的"];
    
    /* 循环创建三个底部tab（置灰状态） */
    for (int i=0; i<3; i++) {
        UIView *tabView = [[UIView alloc] init];
        tabView.backgroundColor  = [UIColor whiteColor];
        tabView.tag = 1+i;
        tabView.frame = CGRectMake(ceil(_screenWidth/3.0)*i, 0.5, ceil(_screenWidth/3.0), 44);  // 这里要取整
        
        // 添加icon图
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake((ceil(_screenWidth/3.0)-30)/2.0, 6, 32, 25)];
        [tabView addSubview:iconView];
        UIImageView *icon = [[UIImageView alloc] init];
        // 每个tab的icon图尺寸不一样，需要单独写尺寸
        if (i==0) {
            icon.image = [UIImage imageNamed:@"home_tab.png"];
            icon.frame = CGRectMake(3.5, 1, 25, 23);
        } else if (i == 1) {
            icon.image = [UIImage imageNamed:@"discovery_tab.png"];
            icon.frame = CGRectMake(0.5, 0, 31, 25);
        } else if (i == 2 ) {
            icon.image = [UIImage imageNamed:@"mine_tab.png"];
            icon.frame = CGRectMake(6.5, 0, 19, 25);
        }

        [iconView addSubview: icon];
        
        // 添加tab文字
        UILabel *tabLabel = [[UILabel alloc] initWithFrame:CGRectMake((ceil(_screenWidth/3.0)-40)/2.0, 31, 40, 14)];
        tabLabel.text = [tabText objectAtIndex:i];
        tabLabel.font = [UIFont fontWithName:@"Helvetica" size:10.0];
        tabLabel.textColor = [colorManager tabTextColorGray];
        tabLabel.textAlignment = UITextAlignmentCenter;
        [tabView addSubview:tabLabel];
        
        // 设置手势
        tabView.userInteractionEnabled = YES; // 设置view可以交互
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTab:)];   // 设置手势
        [tabView addGestureRecognizer:singleTap]; // 给view添加手势
        [_tabBarBackgroundView addSubview:tabView];
    }
    
    
    /* 循环创建三个底部tab（选中状态） */
    for (int i=0; i<3; i++) {
        UIView *tabView = [[UIView alloc] init];
        tabView.backgroundColor  = [UIColor whiteColor];
        tabView.tag = i+4;  // 添加tag
        tabView.hidden = YES;
        tabView.frame = CGRectMake(ceil(_screenWidth/3.0)*i, 0.5, ceil(_screenWidth/3.0), 44);  // 这里要取整
        
        // 初始状态第一个tab是焦点状态
        if (i == 0) {
            tabView.hidden = NO;
        }
        
        // 添加icon图
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake((ceil(_screenWidth/3.0)-30)/2.0, 6, 32, 25)];
        [tabView addSubview:iconView];
        UIImageView *icon = [[UIImageView alloc] init];
        // 每个tab的icon图尺寸不一样，需要单独写尺寸
        if (i==0) {
            icon.image = [UIImage imageNamed:@"home_tab_focus.png"];
            icon.frame = CGRectMake(3.5, 1, 25, 23);
        } else if (i == 1) {
            icon.image = [UIImage imageNamed:@"discovery_tab_focus.png"];
            icon.frame = CGRectMake(0.5, 0, 31, 25);
        } else if (i == 2 ) {
            icon.image = [UIImage imageNamed:@"mine_tab_focus.png"];
            icon.frame = CGRectMake(6.5, 0, 19, 25);
        }
        
        [iconView addSubview: icon];
        
        // 添加tab文字
        UILabel *tabLabel = [[UILabel alloc] initWithFrame:CGRectMake((ceil(_screenWidth/3.0)-40)/2.0, 31, 40, 14)];
        tabLabel.text = [tabText objectAtIndex:i];
        tabLabel.font = [UIFont fontWithName:@"Helvetica" size:10.0];
        tabLabel.textColor = [colorManager tabTextColorBlack];
        tabLabel.textAlignment = UITextAlignmentCenter;
        [tabView addSubview:tabLabel];
        
        [_tabBarBackgroundView addSubview:tabView];
    }
    
    
}



#pragma mark - IBAction
- (void)clickTab:(UIGestureRecognizer *)sender
{
    NSLog(@"%ld", sender.view.tag);
    
    // 隐藏所有焦点icon
    for (UIView *item in [_tabBarBackgroundView subviews]) {
        if (item.tag > 3) {
            item.hidden = YES;
        }
    }
    
    // 显示对应的焦点icon
    UIView *ft = [_tabBarBackgroundView viewWithTag:sender.view.tag + 3];
    ft.hidden = NO;
    
    /* 移动tab焦点 */
    self.selectedIndex = sender.view.tag - 1;

}



@end
