//
//  TopicCell.h
//  saltfish
//
//  Created by alfred on 16/6/25.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TopicCellDelegate <NSObject>
@required
- (void)changeTopicCellHeight;
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
// 分割线
@property (nonatomic, copy) UIView *partLine;
//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;

- (void)rewriteIntroduction:(NSString *)newIntroduction followStatus:(BOOL)isFollowing;

// 定义代理
@property (nonatomic, assign) id <TopicCellDelegate> delegate;


@end
