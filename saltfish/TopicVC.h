//
//  TopicVC.h
//  saltfish
//
//  Created by alfred on 16/6/19.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicCell.h"
#import "SFArticleCell.h"
#import "ESPictureBrowser.h"

@interface TopicVC : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate,TopicCellDelegate, SFArticleCellDelegate, ESPictureBrowserDelegate>

// 头部数据
@property (nonatomic, strong) NSString *portraitURL;  // 头像url
@property (nonatomic, strong) NSString *topic;  // 话题名称
@property (nonatomic, strong) NSString *introduction;  // 话题简介

// tableview
@property (nonatomic, strong) UITableView *oneTableView;  // tableview
@property (nonatomic, strong) NSDictionary *topicData;  // 当前Topic数据
@property (nonatomic, strong) NSMutableArray *recommendData;  // 相关推荐数据
@property (nonatomic, strong) NSMutableArray *articleData;  // article数据

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *portraitView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSString *uid;  // 登录账号id
@property (nonatomic, strong) NSString *userType;  // 账户类型

// 全局变量 屏幕长宽
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
@end
