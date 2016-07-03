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
// 分割线
@property (nonatomic, copy) UIView *partLine;
//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
//
- (void)rewriteHotArticles:(NSArray *)newArr;
- (void)rewriteHotTopics:(NSArray *)newArr;
@end
