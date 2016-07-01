//
//  articleCell.h
//  saltfish
//
//  Created by alfred on 16/6/25.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface articleCell : UITableViewCell <UIScrollViewDelegate>
// 标题
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) UILabel *titleLabel;
// 热度
@property (nonatomic, copy) NSString *hotScore;
@property (nonatomic, copy) UILabel *hotScoreLabel;
// 话题
@property (nonatomic, copy) UIScrollView *basedScrollView;
@property (nonatomic) BOOL hasTopics;
// 图片
@property (nonatomic, copy) NSString *picURL;
@property (nonatomic, copy) UIImageView *picImageView;
//
@property (nonatomic, copy) NSArray *array;

//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
//
- (void)rewriteTitle:(NSString *)newTitle;
- (void)rewriteHotScore:(NSString *)newHotScore;
- (void)rewritePicURL:(NSString *)newPicURL;
- (void)rewriteTopics:(NSArray *)newTopicArr;
- (void)showAsBeenRead: (NSString *)aritlceID;

@end
