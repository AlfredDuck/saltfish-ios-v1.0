//
//  picBasedTableViewCell.m
//  saltfish
//
//  Created by alfred on 16/3/18.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "picBasedTableViewCell.h"
#import <AFNetworking/AFNetworking.h>
#import "UIImageView+WebCache.h"
#import "colorManager.h"

// 最新的SDWebImage用法 http://www.tuicool.com/articles/INfUJv

@implementation picBasedTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - custom cells

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _screenHeight = [UIScreen mainScreen].bounds.size.height;
        _screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        // 一些初始化的值
        _title = @"曾经沧海难为水，除却巫山不是云霓裳佳人顾盼倾城山外山";
        _picURL = @"http://letsfilm.org/wp-content/uploads/2015/09/0000228.jpg";
        self.tag = 999999;
        
        /* 图片(尺寸固定) */
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 240)];
        _picImageView.backgroundColor = [UIColor brownColor];
        // uiimageview居中裁剪
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
        _picImageView.clipsToBounds = YES;
        // 需要AFNetwork
        [_picImageView sd_setImageWithURL:[NSURL URLWithString:_picURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [self.contentView addSubview:_picImageView];
        
        /* 黑色透明层 */
        UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 240)];
        blackView.backgroundColor = [UIColor blackColor];
        blackView.alpha = 0.7;
        [self.contentView addSubview:blackView];
        
        /* 标题 */
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 240-60, _screenWidth-20, 60)];
        _titleLabel.text = _title;
        _titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size: 20];
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
        // 文字阴影
        _titleLabel.shadowColor = [UIColor blackColor];
        _titleLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        _titleLabel.textColor = [UIColor whiteColor];
        
        [self.contentView addSubview:_titleLabel];
        
        /* cell背景色 */
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        // not usefull
        self.frame = CGRectMake(0, 0, 500, 300);
        NSLog(@"%f", self.frame.size.height);
    }
    return self;
}


@end
