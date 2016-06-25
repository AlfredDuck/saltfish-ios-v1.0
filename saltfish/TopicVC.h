//
//  TopicVC.h
//  saltfish
//
//  Created by alfred on 16/6/19.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicCell.h"

@interface TopicVC : UIViewController <UITableViewDataSource, UITableViewDelegate, TopicCellDelegate>
//
@property (nonatomic, strong)UIImageView *backgroundView;
@property (nonatomic, strong)UIImageView *portraitView;
@property (nonatomic, strong)UILabel *titleLabel;
// 全局变量 屏幕长宽
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
@end
