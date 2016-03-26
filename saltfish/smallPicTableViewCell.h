//
//  smallPicTableViewCell.h
//  saltfish
//
//  Created by alfred on 15/12/13.
//  Copyright © 2015年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface smallPicTableViewCell : UITableViewCell
// 标题
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) UILabel *titleLabel;
@property (nonatomic, copy) UILabel *readedTitleLabel;
// 热度
@property (nonatomic, copy) NSString *hotDegree;
@property (nonatomic, copy) UILabel *hotDegreeLabel;
// 图片
@property (nonatomic, copy) NSString *picURL;
@property (nonatomic, copy) UIImageView *picImageView;
// 整体cell高度
@property (nonatomic) float cellHeight;
//
@property (nonatomic, copy) NSArray *array;
//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
//
- (void)rewriteTitle:(NSString *)newTitle;
- (void)rewriteHotDegree:(NSString *)newDegree;
- (void)rewritePicURL:(NSString *)newPicURL;
- (void)showAsBeenRead: (NSString *)aritlceID;

@end
