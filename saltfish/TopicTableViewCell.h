//
//  TopicTableViewCell.h
//  saltfish
//
//  Created by alfred on 16/7/1.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TopicTableViewCellDelegate <NSObject>
@required
- (void)clickFollowButtonForIndex:(unsigned long)index;
@end


@interface TopicTableViewCell : UITableViewCell
// 图片
@property (nonatomic, copy) NSString *picURL;
@property (nonatomic, copy) UIImageView *picImageView;
// 标题
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) UILabel *titleLabel;
// 简介
@property (nonatomic, copy) NSString *introduction;
@property (nonatomic, copy) UILabel *introductionLabel;
// 关注按钮
@property (nonatomic, copy) UIImageView *followButton;
// 分割线
@property (nonatomic, copy) UIView *partLine;
//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;

@property (nonatomic, assign) id <TopicTableViewCellDelegate> delegate;  // 代理

- (void)rewritePic:(NSString *)newPicURL;
- (void)rewriteTitle:(NSString *)newTitle;
- (void)rewriteintroduction:(NSString *)newIntroduction;
- (void)rewriteFollowButton:(NSString *)isFollowing forIndex:(int)index;

@end
