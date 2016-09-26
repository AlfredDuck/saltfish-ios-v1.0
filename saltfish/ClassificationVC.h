//
//  ClassificationVC.h
//  saltfish
//
//  Created by alfred on 16/7/1.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicTableViewCell.h"
#import "SFThirdLoginViewController.h"

@interface ClassificationVC : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, TopicTableViewCellDelegate, SFThirdLoginViewControllerDelegate>
@property (nonatomic, strong) NSString *pageTitle;  // 页面标题
@property (nonatomic, strong) UILabel *titleLabel;  //
@property (nonatomic, strong) UITableView *oneTableView;  // tableview
@property (nonatomic, strong) NSMutableArray *tableViewData;  // tableview数据
@property (nonatomic, strong) NSString *uid;  // 登录账户id
@property (nonatomic, strong) NSString *userType;  // 账户类型

@property (nonatomic, strong) UIView *loadingView;  // 页面第一次加载时显示的loading
@property (nonatomic, strong) UIActivityIndicatorView *loadingFlower;  // 小菊花

// 全局变量 屏幕长宽
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
@end
