//
//  TopicTableViewCell.m
//  saltfish
//
//  Created by alfred on 16/7/1.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "TopicTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "YYWebImage.h"
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
        _title = @"##";
        _introduction = @"新宿御苑&佐助稻荷神社";
        _picURL = @"";
        self.tag = 999999;
        
        /* 图片(尺寸固定) */
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 12, 58, 58)];
        _picImageView.backgroundColor = [colorManager lightGrayBackground];
        // uiimageview居中裁剪
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
        _picImageView.clipsToBounds  = YES;
        _picImageView.layer.cornerRadius = 5;
        // 普通加载网络图片 yy库
        _picImageView.yy_imageURL = [NSURL URLWithString:_picURL];
        [self.contentView addSubview:_picImageView];
        
        /* #话题# */
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(86, 19, _screenWidth-(58+11+16+11), 22)];
        _titleLabel.text = _title;
        _titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 16.0];
        _titleLabel.textColor = [colorManager mainTextColor];
        [self.contentView addSubview:_titleLabel];
        
        /* 介绍 */
        _introductionLabel = [[UILabel alloc] initWithFrame:CGRectMake(86, 44, _screenWidth-(58+11+16+11+45+16), 17)];
        _introductionLabel.text = _introduction;
        _introductionLabel.font = [UIFont fontWithName:@"Helvetica" size: 12.0f];
        _introductionLabel.textColor = [colorManager lightTextColor];
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
- (void)rewritePic:(NSString *)newPicURL
{
    _picURL = newPicURL;
    // 普通加载网络图片 yy库
    _picImageView.yy_imageURL = [NSURL URLWithString:_picURL];
}

- (void)rewriteTitle:(NSString *)newTitle
{
    _title = newTitle;
    _titleLabel.text = _title;
}

- (void)rewriteintroduction:(NSString *)newIntroduction
{
    _introduction = newIntroduction;
    _introductionLabel.text = _introduction;
}

- (void)rewriteFollowButton:(NSString *)isFollowing forIndex:(int)index
{
    if ([isFollowing isEqualToString:@"yes"]) {
        [_followButton setImage:[UIImage imageNamed:@"unfollow_small.png"]];
    }
    else {
        [_followButton setImage:[UIImage imageNamed:@"follow_small.png"]];
    }
    
    // 给followbutton加tag,用于定位点击事件发生在哪个cell
    _followButton.tag = index + 1;
}



#pragma mark - IBAction
- (void)clickFollowButton:(UIGestureRecognizer *)sender
{
    NSLog(@"%@", sender);
    [self.delegate clickFollowButtonForIndex:sender.view.tag - 1];  // 调用代理
}


@end
