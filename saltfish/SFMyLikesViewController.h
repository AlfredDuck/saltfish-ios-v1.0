//
//  SFMyLikesViewController.h
//  saltfish
//
//  Created by alfred on 16/9/16.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFArticleCell.h"
#import "ESPictureBrowser.h"

@interface SFMyLikesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, SFArticleCellDelegate, ESPictureBrowserDelegate>
@property (nonatomic, strong) UITableView *oneTableView;  // tableview
@property (nonatomic, strong) NSMutableArray *articleData;  // tableview数据
@property (nonatomic, strong) NSString *uid;  // 用户登录账户
@property (nonatomic, strong) NSString *userType;  // 账户类型

@property (nonatomic, strong) UIView *loadingView;  // 页面第一次加载时显示的loading
@property (nonatomic, strong) UIActivityIndicatorView *loadingFlower;  // 小菊花
@property (nonatomic, strong) UILabel *emptyLabel;  // 页面为空的提示语
// 全局变量 屏幕长宽
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;

@end
