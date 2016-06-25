//
//  articleCell.h
//  saltfish
//
//  Created by alfred on 16/6/25.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface articleCell : UITableViewCell
// 标题
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) UILabel *titleLabel;
// 热度
@property (nonatomic, copy) NSString *hotScore;
@property (nonatomic, copy) UILabel *hotScoreLabel;
// 标签
@property (nonatomic, copy) NSString *hotDegree;
@property (nonatomic, copy) UILabel *hotDegreeLabel;
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
- (void)showAsBeenRead: (NSString *)aritlceID;

@end
