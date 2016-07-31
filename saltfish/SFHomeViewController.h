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

@property (nonatomic, strong) UIScrollView *basedScrollView;  // 用不到了的
@property (nonatomic, strong) NSArray *data;  // 用不到了

@property (nonatomic, strong) UITableView *oneTableView;  // tableview
@property (nonatomic, strong) NSArray *hotArticleData;  // 热门文章数据
@property (nonatomic, strong) NSArray *hotTopicData;  // 热门话题数据
@property (nonatomic, strong) NSMutableArray *followedArticlesData;  // 关注话题的最新文章
@property (nonatomic, strong) NSString *uid;  // 登录账户id

@property (nonatomic, strong) UIActivityIndicatorView *loadingFlower;  // 小菊花

@property (nonatomic) NSInteger screenWidth;  // 全局变量 屏幕长宽
@property (nonatomic) NSInteger screenHeight;  // 全局变量 屏幕长宽

@end
