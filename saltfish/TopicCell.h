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
// 标题
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) UILabel *titleLabel;
// 简介
@property (nonatomic, copy) NSString *introduction;
@property (nonatomic, copy) UILabel *introductionLabel;
// 关注按钮
@property (nonatomic, copy) UIImageView *followButton;
@property (nonatomic, copy) UIView *pushSettingView;
@property (nonatomic, copy) UISwitch *pushSwitch;
// 分割线
@property (nonatomic, copy) UIView *partLine;
//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;

- (void)rewriteIntroduction:(NSString *)newIntroduction followStatus:(BOOL)isFollowing;

// 定义代理
@property (nonatomic, assign) id <TopicCellDelegate> delegate;


@end
