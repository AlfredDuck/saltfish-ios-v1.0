//
//  SFClassificationTableViewCell.h
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFClassificationTableViewCell : UITableViewCell
// 标题
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) UILabel *titleLabel;
// cell 高度
@property (nonatomic) unsigned long cellHeight;
// 底部分割线
@property (nonatomic, copy) UIView *partLine;
// 记录已经生成图片矩阵，避免重复生成
@property (nonatomic) BOOL hasPics;

//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;

- (void)rewritePics:(NSArray *)newArr;
@end
