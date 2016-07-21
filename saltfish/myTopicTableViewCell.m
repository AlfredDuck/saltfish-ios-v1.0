//
//  myTopicTableViewCell.m
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "myTopicTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "colorManager.h"

@implementation myTopicTableViewCell

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
        _title = @"#三吉彩花#";
        _updateTime = @"最后更新 2016-09-08 23：09";
        _picURL = @"http://f4.topitme.com/4/11/e9/1135586544a53e9114m.jpg";
        self.tag = 999999;
        
        /* 图片(尺寸固定) */
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 12, 58, 58)];
        _picImageView.backgroundColor = [UIColor grayColor];
        // uiimageview居中裁剪
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
        _picImageView.clipsToBounds  = YES;
        // 需要AFNetwork
        [_picImageView sd_setImageWithURL:[NSURL URLWithString:_picURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [self.contentView addSubview:_picImageView];
        
        /* #话题# */
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(86, 17, _screenWidth-(58+11+16+11), 22)];
        _titleLabel.text = _title;
        _titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 15.0];
        _titleLabel.textColor = [colorManager mainTextColor];
        [self.contentView addSubview:_titleLabel];
        
        /* 更新时间 */
        _updateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(86, 44, _screenWidth-(58+11+16+11), 17)];
        _updateTimeLabel.text = _updateTime;
        _updateTimeLabel.font = [UIFont fontWithName:@"Helvetica" size: 12.0f];
        _updateTimeLabel.textColor = [colorManager secondTextColor];
        [self.contentView addSubview:_updateTimeLabel];
        
        /* 通知开启标记 */
        _notificationMark = [[UIImageView alloc] initWithFrame:CGRectMake(_screenWidth-17-19, 32, 17, 19)];
        [_notificationMark setImage:[UIImage imageNamed:@"notification.png"]];
        _notificationMark.tag = 110;
        // uiimageview居中裁剪
        _notificationMark.contentMode = UIViewContentModeScaleAspectFill;
        _notificationMark.clipsToBounds  = YES;
        [self.contentView addSubview:_notificationMark];
        
        
        /* 背景、分割线 */
        UIView *partLine = [[UIView alloc] initWithFrame:CGRectMake(0, 24+58-0.5, _screenWidth, 0.5)];
        partLine.backgroundColor = [colorManager lightGrayBackground];
        [self.contentView addSubview:partLine];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        
        // not usefull
        self.frame = CGRectMake(0, 0, 300, 300);
        NSLog(@"%f", self.frame.size.height);
        
    }
    return self;
}



#pragma mark - 重写 cell 中各个元素的数据
- (void)rewritePic:(NSString *)newPicURL
{
    _picURL = newPicURL;
    [_picImageView sd_setImageWithURL:[NSURL URLWithString:_picURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
}

- (void)rewriteTitle:(NSString *)newTitle
{
    _title = newTitle;
    _titleLabel.text = _title;
}

- (void)rewriteUpdateTime:(NSString *)newUpdateTime
{
    _updateTime = newUpdateTime;
    _updateTimeLabel.text = _updateTime;
}

- (void)rewriteNotification:(NSString *)isNotificationOn
{
    if ([isNotificationOn isEqualToString:@"yes"]) {
        [_notificationMark setImage:[UIImage imageNamed:@"notification.png"]];
    }
    else {
        [_notificationMark setImage:[UIImage imageNamed:@"nothing.png"]];
    }
}

#pragma mark - IBAction

@end
