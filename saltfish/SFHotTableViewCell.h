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
// 分割线
@property (nonatomic, copy) UIView *partLine;
// 定时器
@property (nonatomic, strong) NSTimer *timer;
// 焦点图已被创建的标记
@property (nonatomic) BOOL hasHotArticles;
//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
//
- (void)rewriteHotArticles:(NSArray *)newArr;
- (void)rewriteHotTopics:(NSArray *)newArr;
@end
