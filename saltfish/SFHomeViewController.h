//
//  SFHomeViewController.h
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFHomeViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
// tableview
@property (nonatomic, strong) UITableView *oneTableView;
//
@property (nonatomic, strong) UIScrollView *basedScrollView;
//
@property (nonatomic, strong) NSArray *data;
// 全局变量 屏幕长宽
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
@end
