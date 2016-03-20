//
//  picBasedTableViewCell.h
//  saltfish
//
//  Created by alfred on 16/3/18.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface picBasedTableViewCell : UITableViewCell
// 标题
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) UILabel *titleLabel;
// 图片
@property (nonatomic, copy) NSString *picURL;
@property (nonatomic, copy) UIImageView *picImageView;
// 日期
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) UILabel *dateLabel;
// 作者 & 热度得分
@property (nonatomic, copy) NSString *authorAndHotScore;
@property (nonatomic, copy) UILabel *authorAndHotScoreLabel;
// 作者头像
@property (nonatomic, copy) NSString *portraitURL;
@property (nonatomic, copy) UIImageView *portraitImageView;
//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
//
- (void)rewriteTitle:(NSString *)newTitle;
- (void)rewritePicURL:(NSString *)newPicURL;
- (void)rewriteDate:(NSString *)newDate;
- (void)rewriteAuthorAndHotScore:(NSString *)newAuthorAndHotScore;
- (void)rewritePortraitURL:(NSString *)newPortraitURL;

@end
