//
//  SFArticleTableViewCell.h
//  saltfish
//
//  Created by alfred on 16/7/8.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFArticleTableViewCellDelegate <NSObject>
@required
- (void)clickTopic:(NSString *)topic;
@end

@interface SFArticleTableViewCell : UITableViewCell
// 标题
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) UILabel *titleLabel;
// 热度
@property (nonatomic, copy) NSString *hotScore;
@property (nonatomic, copy) UILabel *hotScoreLabel;
// 话题
@property (nonatomic, copy) NSString *topic;
@property (nonatomic, copy) UILabel *topicLabel;
// 日期
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) UILabel *dateLabel;
// 话题头像
@property (nonatomic, copy) NSString *topicImageURL;
@property (nonatomic, copy) UIImageView *topicImageView;
// cell高度
@property (nonatomic) unsigned long cellHeight;
// 图片
@property (nonatomic, copy) NSString *picURL;
@property (nonatomic, copy) UIImageView *picImageView;
//
@property (nonatomic, copy) NSArray *array;

//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;

// 代理
@property (nonatomic, assign) id <SFArticleTableViewCellDelegate>delegate;
//
- (void)rewriteTitle:(NSString *)newTitle;
- (void)rewriteHotScore:(NSString *)newHotScore;
- (void)rewritePicURL:(NSString *)newPicURL;
- (void)rewriteTopics:(NSString *)newTopic;
- (void)rewriteTopicImageURL:(NSString *)newTopicImageURL;
- (void)rewriteDate:(NSString *)newDate;
- (void)showAsBeenRead: (NSString *)aritlceID;


@end
