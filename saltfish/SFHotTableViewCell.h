//
//  SFHotTableViewCell.h
//  saltfish
//
//  Created by alfred on 16/7/3.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFHotTableViewCellDelegate <NSObject>
@required
- (void)clickHotArticle:(NSString *)articleID;
- (void)clickHotTopic:(NSString *)topic pic:(NSString *)picURL;
@end


@interface SFHotTableViewCell : UITableViewCell <UIScrollViewDelegate>

@property (nonatomic, strong) NSTimer *timer;  // 定时器
@property (nonatomic, copy) UIScrollView *basedScrollView;  // 焦点图scrollview
@property (nonatomic, copy) NSArray *hotArticleData;  // 焦点图数据
@property (nonatomic, copy) UIView *direction;  // 焦点图定位点

@property (nonatomic) BOOL hasHotArticles;  // 焦点图已被创建的标记
@property (nonatomic) unsigned long hotArticleHeight;  // 焦点图高度

@property (nonatomic, copy) NSArray *hotTopicData;  // 热门话题数据
// 热门话题pic数组
@property (nonatomic, copy) NSMutableArray *hotTopicPicArr;
// 热门话题label数组
@property (nonatomic, copy) NSMutableArray *hotTopicLabelArr;

@property (nonatomic) unsigned long cellHeight;  // cell高度

@property (nonatomic, copy) UIView *partLine;  // 分割线
//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
// 代理
@property (nonatomic, assign) id <SFHotTableViewCellDelegate>delegate;
//
- (void)rewriteHotArticles:(NSArray *)newArr;
- (void)rewriteHotTopics:(NSArray *)newArr;
- (void)rewriteCellHeight;
@end
