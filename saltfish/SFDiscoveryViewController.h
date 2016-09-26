//
//  SFDiscoveryViewController.h
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFClassificationTableViewCell.h"
#import "SFTabBarViewController.h"
#import "TopicTableViewCell.h"
#import "SFLoginAndSignup.h"
#import "SFLoginAndSignupViewController.h"
#import "SFThirdLoginViewController.h"

@interface SFDiscoveryViewController : SFTabBarViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, SFClassificationTableViewCellDelegate, TopicTableViewCellDelegate, SFLoginAndSignupDelegate>
@property (nonatomic, strong) UITableView *oneTableView;  // tableview
@property (nonatomic, strong) NSArray *classificationData;  // 分类数据
@property (nonatomic, strong) NSMutableArray *latestTopicsData;  // 最新话题数据
@property (nonatomic, strong) NSString *uid;  // 登录用户id
@property (nonatomic, strong) NSString *userType;  // 账户类型

@property (nonatomic, weak) UIActivityIndicatorView *loadingFlower;  // 小菊花
// 全局变量 屏幕长宽
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
@end
