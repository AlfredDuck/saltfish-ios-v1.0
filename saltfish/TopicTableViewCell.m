//
//  TopicTableViewCell.m
//  saltfish
//
//  Created by alfred on 16/7/1.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "TopicTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "colorManager.h"

@implementation TopicTableViewCell

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
        _introduction = @"新宿御苑&佐助稻荷神社";
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
        
        /* 介绍 */
        _introductionLabel = [[UILabel alloc] initWithFrame:CGRectMake(86, 44, _screenWidth-(58+11+16+11), 17)];
        _introductionLabel.text = _introduction;
        _introductionLabel.font = [UIFont fontWithName:@"Helvetica" size: 12.0f];
        _introductionLabel.textColor = [colorManager secondTextColor];
        [self.contentView addSubview:_introductionLabel];
        
        /* 关注按钮 */
        _followButton = [[UIImageView alloc] initWithFrame:CGRectMake(_screenWidth-45-16, 28, 45, 25)];
        [_followButton setImage:[UIImage imageNamed:@"follow_small.png"]];
        _followButton.tag = 110;
        // uiimageview居中裁剪
        _followButton.contentMode = UIViewContentModeScaleAspectFill;
        _followButton.clipsToBounds  = YES;
        // 添加点击事件
        _followButton.userInteractionEnabled = YES; // 设置可以交互
        UITapGestureRecognizer *singleTapOnNoteNumber = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFollowButton:)]; // 设置手势
        [_followButton addGestureRecognizer:singleTapOnNoteNumber]; // 添加手势
        [self.contentView addSubview:_followButton];
        
        
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


#pragma mark - IBAction
- (void)clickFollowButton:(UIGestureRecognizer *)sender
{
    NSLog(@"%@", sender);
}


@end
