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

@interface SFDiscoveryViewController : SFTabBarViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, SFClassificationTableViewCellDelegate>
@property (nonatomic, strong) UITableView *oneTableView;  // tableview
@property (nonatomic, strong) NSArray *classificationData;  // 分类s
@property (nonatomic, strong) NSArray *latestTopicsData;  // 最新话题s

@property (nonatomic, strong) UIActivityIndicatorView *loadingFlower;  // 小菊花
// 全局变量 屏幕长宽
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
@end
