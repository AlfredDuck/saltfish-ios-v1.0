//
//  bigPicTableViewCell.m
//  saltfish
//
//  Created by alfred on 15/12/13.
//  Copyright © 2015年 Alfred. All rights reserved.
//

#import "bigPicTableViewCell.h"
#import <AFNetworking/AFNetworking.h>
#import "UIImageView+WebCache.h"
#import "colorManager.h"

// 最新的SDWebImage用法 http://www.tuicool.com/articles/INfUJv

@implementation bigPicTableViewCell

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
        /*
        CGRect nameLabelRect = CGRectMake(0, 5, 70, 15);
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameLabelRect];
        nameLabel.text = @"Name:";
        nameLabel.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview: nameLabel];
        */

        _screenHeight = [UIScreen mainScreen].bounds.size.height;
        _screenWidth = [UIScreen mainScreen].bounds.size.width;

        // 一些初始化的值
        _title = @"曾经沧海难为水，除却巫山不是云霓裳佳人顾盼倾城山外山";
        _picURL = @"http://letsfilm.org/wp-content/uploads/2015/09/0000228.jpg";
        self.tag = 999999;

        // 图片(尺寸固定)
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 244)];
        _picImageView.backgroundColor = [UIColor brownColor];
        // uiimageview居中裁剪
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
        _picImageView.clipsToBounds  = YES;
        // 需要AFNetwork（延后处理）
        [_picImageView sd_setImageWithURL:[NSURL URLWithString:_picURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [self.contentView addSubview:_picImageView];

        // 遮黑
        UIView *blackBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 244-64, _screenWidth, 64)];
//        blackBackground.backgroundColor = [UIColor blackColor];
//        blackBackground.alpha = 0.6;
        // 遮黑的渐变图片
        UIImage *blackImage = [UIImage imageNamed:@"black_bottom2.png"]; // 使用ImageView通过name找到图片
        UIImageView *oneImageView = [[UIImageView alloc] initWithImage:blackImage]; // 把oneImage添加到oneImageView上
        oneImageView.frame = CGRectMake(0, 0, _screenWidth, 64); // 设置图片位置和大小
        [blackBackground addSubview:oneImageView];
        [self.contentView addSubview:blackBackground];

        // 标题
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 244-64+4, _screenWidth-20, 60)];
        _titleLabel.text = _title;
        _titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size: 20];
        _titleLabel.numberOfLines = 2;
        // 文字阴影
        _titleLabel.shadowColor = [UIColor blackColor];
        _titleLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        _titleLabel.textColor = [UIColor whiteColor];

        [self.contentView addSubview:_titleLabel];

        // 背景、分割线
        self.contentView.backgroundColor = [UIColor whiteColor];

        // not usefull
        self.frame = CGRectMake(0, 0, 500, 300);
        NSLog(@"%f", self.frame.size.height);
    }
    return self;
}



#pragma mark - 重写 cell 中各个元素的数据

- (void)rewriteTitle:(NSString *)newTitle
{
    _title = newTitle;
    _titleLabel.text = _title;
}

- (void)rewritePicURL:(NSString *)newPicURL
{
    _picURL = newPicURL;
    [_picImageView sd_setImageWithURL:[NSURL URLWithString:_picURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
}

@end
