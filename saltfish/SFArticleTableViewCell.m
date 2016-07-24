//
//  SFArticleTableViewCell.m
//  saltfish
//
//  Created by alfred on 16/7/8.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFArticleTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "TopicVC.h"
#import "colorManager.h"

@implementation SFArticleTableViewCell

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
        _title = @"曾经沧海难为水,除却巫山不是云\n";
        _hotScore = @"评论23 赞64";
        _topic = @"#吴亦凡艹粉#";
        _date = @"8月23日";
        _picURL = @"http://i10.topitme.com/l007/100079161401a5c7b0.jpg";
        self.tag = 999999;
        
        // 图片尺寸
        int ww = 84;
        int hh = 68;
        
        
        /* 话题头像 */
        _topicImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 15, 20, 20)];
        _topicImageView.backgroundColor = [UIColor grayColor];
        // uiimageview居中裁剪
        _topicImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topicImageView.clipsToBounds  = YES;
        _topicImageView.layer.cornerRadius = 10;
        // 需要AFNetwork
        [_topicImageView sd_setImageWithURL:[NSURL URLWithString:_picURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [self.contentView addSubview:_topicImageView];
        // 点击手势
        _topicImageView.userInteractionEnabled = YES; // 设置view可以交互
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTopicPortrait:)];   // 设置手势
        [_topicImageView addGestureRecognizer:singleTap]; // 给view添加手势
        
        
        /* 话题标题 */
        _topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(41, 17, 200, 17)];
        _topicLabel.text = _topic;
        _topicLabel.font = [UIFont fontWithName:@"Helvetica" size: 12.0];
        _topicLabel.textColor = [colorManager secondTextColor];
        // 点击手势
        _topicLabel.userInteractionEnabled = YES; // 设置view可以交互
        UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTopicOfArticle:)];   // 设置手势
        [_topicLabel addGestureRecognizer:singleTap2]; // 给view添加手势
        [self.contentView addSubview:_topicLabel];
        
        
        /* 日期 */
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(_screenWidth-100-14, 17, 100, 17)];
        _dateLabel.text = _date;
        _dateLabel.font = [UIFont fontWithName:@"Helvetica" size: 11.0];
        _dateLabel.textColor = [colorManager lightTextColor];
        _dateLabel.textAlignment = UITextAlignmentRight;
        [self.contentView addSubview:_dateLabel];
        
        
        /* 标题 */
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 51, _screenWidth-(ww+14+18+19), 36)];
        _titleLabel.text = _title;
        _titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 15.0];
        _titleLabel.textColor = [colorManager mainTextColor];
        _titleLabel.numberOfLines = 2;
        [self.contentView addSubview:_titleLabel];
        
        
        /* 图片(尺寸固定) */
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_screenWidth-ww-14, 51, ww, hh)];
        _picImageView.backgroundColor = [UIColor grayColor];
        // uiimageview居中裁剪
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
        _picImageView.clipsToBounds  = YES;
        // 需要AFNetwork
        [_picImageView sd_setImageWithURL:[NSURL URLWithString:_picURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [self.contentView addSubview:_picImageView];
        
        
        /* 热度 */
        _hotScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(19, 104, 240, 16)];
        _hotScoreLabel.text = _hotScore;
        _hotScoreLabel.font = [UIFont fontWithName:@"Helvetica" size: 11.0f];
        _hotScoreLabel.textColor = [colorManager lightTextColor];
        [self.contentView addSubview:_hotScoreLabel];
        
        
        /* 背景、分割线 */
        UIView *partLine = [[UIView alloc] initWithFrame:CGRectMake(0, 145-0.5, _screenWidth, 0.5)];
        partLine.backgroundColor = [colorManager lightGrayBackground];
        [self.contentView addSubview:partLine];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _array = [userDefaults arrayForKey:@"readList"];
        
        // not usefull
        self.frame = CGRectMake(0, 0, 300, 300);
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

- (void)rewriteHotScore:(NSString *)newScore
{
    _hotScore = newScore;
    _hotScoreLabel.text = _hotScore;
}

- (void)rewritePicURL:(NSString *)newPicURL
{
    _picURL = newPicURL;
    [_picImageView sd_setImageWithURL:[NSURL URLWithString:_picURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
}

- (void) rewriteTopics:(NSString *)newTopic
{
    _topic = newTopic;
    _topicLabel.text = _topic;
}

- (void) rewriteTopicImageURL:(NSString *)newTopicImageURL
{
    _topicImageURL = newTopicImageURL;
    [_topicImageView sd_setImageWithURL:[NSURL URLWithString:_topicImageURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
}

- (void) rewriteDate:(NSString *)newDate
{
    _date = newDate;
    _dateLabel.text = _date;
}

- (void)showAsBeenRead:(NSString *)articleID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _array = [userDefaults arrayForKey:@"readList"];
    if ([_array containsObject:articleID]) {
        NSLog(@"%@", _array);
        NSLog(@"%@", articleID);
        _titleLabel.textColor = [UIColor lightGrayColor];
    }
    else {
        _titleLabel.textColor = [colorManager mainTextColor];
    }
}





#pragma mark - IBAction

// 点击话题文字
- (void)clickTopicOfArticle:(UIGestureRecognizer *)sender
{
    //
    NSLog(@"点文字");
    NSLog(@"%@", sender.view.superview);
    NSLog(@"%@", _topic);
    
    // 调用代理方法
    [self.delegate clickTopic:_topic];
}

// 点击话题头像
- (void)clickTopicPortrait:(UIGestureRecognizer *)sender
{
    NSLog(@"点头像");
    NSLog(@"%@", _topic);
    // 调用代理方法
    [self.delegate clickTopic:_topic];
}


@end
