//
//  ClassificationVC.h
//  saltfish
//
//  Created by alfred on 16/7/1.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicTableViewCell.h"

@interface ClassificationVC : UIViewController <UITableViewDelegate, UITableViewDataSource, TopicTableViewCellDelegate>
@property (nonatomic, strong) NSString *pageTitle;  // 页面标题
@property (nonatomic, strong) UILabel *titleLabel;  //
@property (nonatomic, strong) UITableView *oneTableView;  // tableview
@property (nonatomic, strong) NSMutableArray *tableViewData;  // tableview数据
@property (nonatomic, strong) NSString *uid;  // 登录账户id

// 全局变量 屏幕长宽
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
@end
