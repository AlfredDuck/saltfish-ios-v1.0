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
- (void)clickRecommendTopicWith:(unsigned long)index;  // 点击相关推荐话题
- (void)clickRecommendFollowWith:(unsigned long)index;  // 点击相关推荐follow按钮
@end

@interface TopicCell : UITableViewCell

@property (nonatomic, copy) NSString *title;  // 标题
@property (nonatomic, copy) UILabel *titleLabel;

@property (nonatomic, copy) NSString *introduction;  // 简介
@property (nonatomic, copy) UILabel *introductionLabel;

@property (nonatomic, copy) UIImageView *followButton;  // 关注按钮
@property (nonatomic, copy) UIView *pushSettingView;  // 推送开关
@property (nonatomic, copy) UISwitch *pushSwitch;

@property (nonatomic, copy) UIView *recommendView;  // 相关推荐

@property (nonatomic, copy) UIView *partLine;  // 分割线
@property (nonatomic) unsigned long cellHeight;  // cell高度

@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;

- (void)rewriteTopic:(NSString *)newTopic;
- (void)rewriteIntroduction:(NSString *)newIntroduction followStatus:(NSString *)isFollowing pushStatus:(NSString *)isPushOn;
- (void)rewriteRecommendWith:(NSMutableArray *)RecommendArray followStatus:(NSString *)isFollowing;

@property (nonatomic, assign) id <TopicCellDelegate> delegate;  // 定义代理

@end
