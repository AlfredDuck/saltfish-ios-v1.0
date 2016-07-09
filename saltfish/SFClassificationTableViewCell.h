//
//  SFClassificationTableViewCell.h
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFClassificationTableViewCellDelegate <NSObject>
@required
- (void)clickClassification:(NSString *)classification;
@end


@interface SFClassificationTableViewCell : UITableViewCell
// 标题
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) UILabel *titleLabel;
// cell 高度
@property (nonatomic) unsigned long cellHeight;
// 底部分割线
@property (nonatomic, copy) UIView *partLine;
// 下一个模块的title
@property (nonatomic, copy) UIView *titleForNextPart;
// 记录已经生成图片矩阵，避免重复生成
@property (nonatomic) BOOL hasPics;
// 代理
@property (nonatomic, assign) id <SFClassificationTableViewCellDelegate>delegate;

//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;

- (void)rewritePics:(NSArray *)newArr;
@end
