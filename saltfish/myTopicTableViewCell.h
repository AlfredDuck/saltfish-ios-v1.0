//
//  myTopicTableViewCell.h
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myTopicTableViewCell : UITableViewCell
// 图片
@property (nonatomic, copy) NSString *picURL;
@property (nonatomic, copy) UIImageView *picImageView;
// 标题
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) UILabel *titleLabel;
// 更新时间
@property (nonatomic, copy) NSString *updateTime;
@property (nonatomic, copy) UILabel *updateTimeLabel;
// 通知开启的标志
@property (nonatomic, copy) UIImageView *notificationMark;
// 分割线
@property (nonatomic, copy) UIView *partLine;
//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
@end
