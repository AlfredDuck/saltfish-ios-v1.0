//
//  bigPicTableViewCell.h
//  saltfish
//
//  Created by alfred on 15/12/13.
//  Copyright © 2015年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>


@interface bigPicTableViewCell : UITableViewCell
// 标题
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) UILabel *titleLabel;
// 图片
@property (nonatomic, copy) NSString *picURL;
@property (nonatomic, copy) UIImageView *picImageView;
//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
//
- (void)rewriteTitle:(NSString *)newTitle;
- (void)rewritePicURL:(NSString *)newPicURL;
@end
