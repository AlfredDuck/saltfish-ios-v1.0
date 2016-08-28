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
- (void)clickPicsForIndex:(unsigned long)index;
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

@property (nonatomic) unsigned long textHeight;
@property (nonatomic) unsigned long cellHeight;  // cell高度
@property (nonatomic, copy) UIView *partLine;  // 分割线
//
@property (nonatomic, copy) NSArray *array;

@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
// 公共方法
- (void)rewriteLinkMark:(BOOL)isShow;
- (void)rewriteWithTopic:(NSString *)newTopic withDate:(NSString *)date;
- (void)rewriteTitle:(NSString *)newTitle;
- (void)rewritePicURL:(NSArray *)newPicArr withIndex:(unsigned long)index;
- (void)rewritePostTime:(NSString *)newPostTime;
//
@property (nonatomic, assign) id <SFArticleCellDelegate> delegate;

@end
