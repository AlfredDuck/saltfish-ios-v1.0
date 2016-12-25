//
//  SFArticleCell.h
//  saltfish
//
//  Created by alfred on 16/6/25.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SFArticleCellDelegate <NSObject>
@required
- (void)clickTopicForIndex:(unsigned long)index;
- (void)clickPicsForIndex:(unsigned long)index withCurrentView:(UIView *)currentView withFatherView:(UIView *)fatherView;
- (void)clickShareIconForIndex:(unsigned long)index;
- (void)clickCommentIconForIndex:(unsigned long)index;
- (void)clickLikeIconForIndex:(unsigned long)index;
- (void)clickAdIconForIndex:(unsigned long)index;
@end

@interface SFArticleCell : UITableViewCell <UIScrollViewDelegate>
// 话题头像
@property (nonatomic, copy) NSString *portraitURL;
@property (nonatomic, copy) UIImageView *portraitImageView;
// 话题
@property (nonatomic, copy) NSString *topic;
@property (nonatomic, copy) UILabel *topicLabel;
// 日期
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) UILabel *dateLabel;
// 外链标志
@property (nonatomic, copy) UIImageView *linkMark;

// 标题
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) UILabel *titleLabel;
// 图片
@property (nonatomic) BOOL hasPics;  // 记录已经生成图片矩阵，避免重复生成
@property (nonatomic, copy) NSString *picURL;
@property (nonatomic, copy) UIImageView *picImageView;
@property (nonatomic, copy) UIView *holdView;  // 图片view的父view

// 用户操作
@property (nonatomic, copy) UIView *customerView;
@property (nonatomic, copy) UIView *shareView;
@property (nonatomic, copy) UILabel *shareLabel;
@property (nonatomic, copy) UIView *commentView;
@property (nonatomic, copy) UILabel *commentLabel;
@property (nonatomic, copy) UIView *likeView;
@property (nonatomic, copy) UILabel *likeLabel;
@property (nonatomic, copy) UIImageView *likeIconView;
@property (nonatomic, copy) UIView *adView;
@property (nonatomic, copy) UILabel *adLabel;

//
@property (nonatomic) unsigned long textHeight;
@property (nonatomic) unsigned long cellHeight;  // cell高度
@property (nonatomic, copy) UIView *partLine;  // 分割线
//
@property (nonatomic, copy) NSArray *array;

@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
// 公共方法
- (void)rewriteLinkMark:(BOOL)isShow;
- (void)rewriteTopic:(NSString *)newTopic withIndex:(unsigned long)index;
- (void)rewriteDate:(NSString *)newDate;
- (void)rewritePortrait:(NSString *)newPortrait withIndex:(unsigned long)index;
- (void)rewriteShareNum:(unsigned long)newShareNum withIndex:(unsigned long)index;
- (void)rewriteCommentNum:(unsigned long)newCommentNum withIndex:(unsigned long)index;
- (void)rewriteLikeNum:(unsigned long)newLikeNum withIndex:(unsigned long)index;
- (void)rewriteLikeStatus:(NSString *)newLikeStatus;
- (void)rewriteAdWithIndex:(unsigned long)index;
- (void)rewriteTitle:(NSString *)newTitle withLink:(BOOL)isShow;
- (void)rewritePicURL:(NSArray *)newPicArr withIndex:(unsigned long)index;
//
@property (nonatomic, assign) id <SFArticleCellDelegate> delegate;

@end
