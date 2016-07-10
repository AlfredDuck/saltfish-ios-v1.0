//
//  SFTabBarViewController.m
//  saltfish
//
//  Created by alfred on 16/7/10.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFTabBarViewController.h"
#import "colorManager.h"

@interface SFTabBarViewController ()
@end

@implementation SFTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _screenH = [UIScreen mainScreen].bounds.size.height;
    _screenW = [UIScreen mainScreen].bounds.size.width;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 创建底部 tabBar
- (void)createTabBarWith:(int)index
{
    /* tabbar 背景 */
    _tabBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, _screenH-49, _screenW, 49)];
    _tabBarBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tabBarBackgroundView];
    
    /* 分割线 */
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenW, 0.5)];
    line.backgroundColor = [colorManager lightGrayLineColor];
    [_tabBarBackgroundView addSubview:line];
    
    NSArray *tabText = @[@"动态",@"发现",@"我的"];
    
    /* 循环创建三个底部tab（置灰状态） */
    for (int i=0; i<3; i++) {
        UIView *tabView = [[UIView alloc] init];
        tabView.backgroundColor  = [UIColor whiteColor];
        tabView.tag = 1+i;
        tabView.frame = CGRectMake(ceil(_screenW/3.0)*i, 0.5, ceil(_screenW/3.0), 44);  // 这里要取整
        
        // 添加icon图
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake((ceil(_screenW/3.0)-30)/2.0, 6, 32, 25)];
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
        UILabel *tabLabel = [[UILabel alloc] initWithFrame:CGRectMake((ceil(_screenW/3.0)-40)/2.0, 31, 40, 14)];
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
        tabView.frame = CGRectMake(ceil(_screenW/3.0)*i, 0.5, ceil(_screenW/3.0), 44);  // 这里要取整
        
        // 初始状态第一个tab是焦点状态
        if (i == index) {
            tabView.hidden = NO;
        }
        
        // 添加icon图
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake((ceil(_screenW/3.0)-30)/2.0, 6, 32, 25)];
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
        UILabel *tabLabel = [[UILabel alloc] initWithFrame:CGRectMake((ceil(_screenW/3.0)-40)/2.0, 31, 40, 14)];
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
    
    /* 移动tab焦点 */
    // self.selectedIndex = sender.view.tag - 1;
    self.tabBarController.selectedIndex = sender.view.tag - 1;
}



@end
