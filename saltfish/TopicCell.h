//
//  TopicCell.h
//  saltfish
//
//  Created by alfred on 16/6/25.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TopicCellDelegate <NSObject>
/*此处定义cell指向tableview所在页面的代理*/
@required
- (void)clickFollowButton;  // 点击关注按钮
- (void)changePushSwitch;   // 点击push开关
@end

@interface TopicCell : UITableViewCell

@property (nonatomic, copy) NSString *title;  // 标题
@property (nonatomic, copy) UILabel *titleLabel;

@property (nonatomic, copy) NSString *introduction;  // 简介
@property (nonatomic, copy) UILabel *introductionLabel;

@property (nonatomic, copy) UIImageView *followButton;  // 关注按钮
@property (nonatomic, copy) UIView *pushSettingView;
@property (nonatomic, copy) UISwitch *pushSwitch;

@property (nonatomic, copy) UIView *partLine;  // 分割线
@property (nonatomic) unsigned long cellHeight;  // cell高度

@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;

- (void)rewriteTopic:(NSString *)newTopic;
- (void)rewriteIntroduction:(NSString *)newIntroduction followStatus:(NSString *)isFollowing pushStatus:(NSString *)isPushOn;

@property (nonatomic, assign) id <TopicCellDelegate> delegate;  // 定义代理

@end
