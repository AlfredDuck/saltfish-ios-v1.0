//
//  TechTestViewController.m
//  saltfish
//
//  Created by alfred on 16/6/16.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "TechTestViewController.h"

@interface TechTestViewController ()

@end

@implementation TechTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"tech test";
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    [self createScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 创建一个scrollview
- (void)createScrollView
{
    // 创建一个 ScrollView
    UIScrollView *oneScrollView = [[UIScrollView alloc] init];
    oneScrollView.frame = CGRectMake((_screenWidth-200)/2.0, 100, 200, 200);
    oneScrollView.backgroundColor  = [UIColor yellowColor];
    [self.view addSubview:oneScrollView];
    
    // 创建一个 Tableview
    
}


@end









