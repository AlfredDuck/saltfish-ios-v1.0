//
//  SFHomeViewController.h
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFHotTableViewCell.h"
#import "SFArticleTableViewCell.h"
#import "SFTabBarViewController.h"

@interface SFHomeViewController : SFTabBarViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, SFHotTableViewCellDelegate, SFArticleTableViewCellDelegate>

@property (nonatomic, strong) UITableView *oneTableView;  // tableview
@property (nonatomic, strong) UIScrollView *basedScrollView;  // 用不到了的
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSArray *data2;
@property (nonatomic, strong) NSArray *hotArticleData;
@property (nonatomic, strong) NSArray *hotTopicData;

@property (nonatomic) NSInteger screenWidth;  // 全局变量 屏幕长宽
@property (nonatomic) NSInteger screenHeight;  // 全局变量 屏幕长宽

@end
