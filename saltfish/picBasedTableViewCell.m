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
        
        // cell height
        float imgHeight = 180.0f;
        
        // 一些初始化的值
        _title = @"曾经沧海难为水，除却巫山不是云霓裳佳人顾盼倾城山外山";
        _picURL = @"http://letsfilm.org/wp-content/uploads/2015/09/0000228.jpg";
        _date = @"5小时前";
        _authorAndHotScore = @"电影天堂 · 45人气";
        _portraitURL = @"http://letsfilm.org/wp-content/uploads/2016/02/1-21.jpg";
        self.tag = 999999;
        
        /* 图片(尺寸固定) */
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, imgHeight)];
        _picImageView.backgroundColor = [UIColor brownColor];
        // uiimageview居中裁剪
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
        _picImageView.clipsToBounds = YES;
        // 需要AFNetwork
        [_picImageView sd_setImageWithURL:[NSURL URLWithString:_picURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [self.contentView addSubview:_picImageView];
        
        /* 黑色透明层 */
        UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, imgHeight)];
        blackView.backgroundColor = [UIColor blackColor];
        blackView.alpha = 0.63;
        [self.contentView addSubview:blackView];
        
        /* 标题 */
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (imgHeight-60)/2, _screenWidth-30, 60)];
        _titleLabel.text = _title;
        _titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 16];
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
        // 文字阴影
        _titleLabel.shadowColor = [UIColor blackColor];
        _titleLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        _titleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_titleLabel];
        
        /* 日期 */
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, imgHeight-32, _screenWidth-30, 32)];
        _dateLabel.text = _date;
        _dateLabel.font = [UIFont fontWithName:@"Helvetica" size: 11];
        _dateLabel.textAlignment = UITextAlignmentCenter;
        _dateLabel.numberOfLines = 2;
        // 文字阴影
        _dateLabel.shadowColor = [UIColor blackColor];
        _dateLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        _dateLabel.textColor = [UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1];
        [self.contentView addSubview:_dateLabel];
        
        /* 白色背景 */
        UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, imgHeight, _screenWidth, 40)];
        whiteView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:whiteView];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 40-0.5, _screenWidth, 0.5)];
        lineView.backgroundColor = [UIColor colorWithRed:207/255.0 green:215/255.0 blue:217/255.0 alpha:1];
        [whiteView addSubview:lineView];
        
        /* 作者 & 热度得分 */
        UIView *containView = [[UIView alloc] init];
        containView.frame = CGRectMake(100, 10, _screenWidth, 20);
        [whiteView addSubview:containView];
        
        _authorAndHotScoreLabel = [[UILabel alloc] init];
        _authorAndHotScoreLabel.text = _authorAndHotScore;
        _authorAndHotScoreLabel.font = [UIFont fontWithName:@"Helvetica" size: 11];
        _authorAndHotScoreLabel.textColor = [UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1];
        _authorAndHotScoreLabel.frame = CGRectMake(25, 0, 200, 20);
        [containView addSubview:_authorAndHotScoreLabel];
        
        /* 作者头像 */
        _portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _portraitImageView.backgroundColor = [UIColor brownColor];
        // uiimageview居中裁剪
        _portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
        _portraitImageView.clipsToBounds = YES;
        _portraitImageView.layer.masksToBounds = YES; //没这句话它圆不起来
        _portraitImageView.layer.cornerRadius = 10.0; //设置图片圆角的尺度
        // 需要AFNetwork
        [_portraitImageView sd_setImageWithURL:[NSURL URLWithString:_portraitURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [containView addSubview: _portraitImageView];
        
        // 计算 author 一行的 frame
        unsigned long authorWidth = (unsigned long)_authorAndHotScore.length * 11 - 5*4;
        _authorAndHotScoreLabel.frame = CGRectMake(25, 0, authorWidth, 20);
        unsigned long containWidth = authorWidth + 25;
        containView.frame = CGRectMake((_screenWidth - containWidth)/2.0, 10, containWidth, 20);
        
        /* cell背景色 */
        self.contentView.backgroundColor = [UIColor colorWithRed:228/255.0 green:233/255.0 blue:234/255.0 alpha:1];
        
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

- (void)rewriteDate:(NSString *)newDate
{
    _date = newDate;
    _dateLabel.text = _date;
}

- (void)rewritePortraitURL:(NSString *)newPortraitURL
{
    _portraitURL = newPortraitURL;
    [_portraitImageView sd_setImageWithURL:[NSURL URLWithString:_portraitURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
}





@end
