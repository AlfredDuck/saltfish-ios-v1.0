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

@interface SFDiscoveryViewController : SFTabBarViewController <UITableViewDelegate, UITableViewDataSource, SFClassificationTableViewCellDelegate>
@property (nonatomic, strong) UITableView *oneTableView;  // tableview
@property (nonatomic, strong) NSArray *classificationData;  // 大分类数据
// 全局变量 屏幕长宽
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
@end
