//
//  SFHotTableViewCell.h
//  saltfish
//
//  Created by alfred on 16/7/3.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFHotTableViewCell : UITableViewCell <UIScrollViewDelegate>
// 焦点图scrollview
@property (nonatomic, copy) UIScrollView *basedScrollView;
// 焦点图数据
@property (nonatomic, copy) NSArray *hotArticleData;
// 焦点图定位点
@property (nonatomic, copy) UIView *direction;
// 定时器
@property (nonatomic, strong) NSTimer *timer;
// 焦点图已被创建的标记
@property (nonatomic) BOOL hasHotArticles;
// 焦点图高度
@property (nonatomic) unsigned long hotArticleHeight;


// 热门话题pic数组
@property (nonatomic, copy) NSMutableArray *hotTopicPicArr;
// 热门话题label数组
@property (nonatomic, copy) NSMutableArray *hotTopicLabelArr;

@property (nonatomic) unsigned long cellHeight;
// 分割线
@property (nonatomic, copy) UIView *partLine;
//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
//
- (void)rewriteHotArticles:(NSArray *)newArr;
- (void)rewriteHotTopics:(NSArray *)newArr;
- (void)rewriteCellHeight;
@end
