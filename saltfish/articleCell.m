//
//  articleCell.m
//  saltfish
//
//  Created by alfred on 16/6/25.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "articleCell.h"
#import "UIImageView+WebCache.h"
#import "colorManager.h"

@implementation articleCell

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
        _title = @"曾经沧海难为水，除却巫山不是风雨云。怎么你还不来啊";
        _hotScore = @"人气 45";
        _topic = @"#煎蛋#";
        _picURL = @"http://i10.topitme.com/l007/100079161401a5c7b0.jpg";
        self.tag = 999999;
        
        // 根据屏幕尺寸动态计算图片尺寸
        int ww = ceil(100*_screenWidth/375.0);
        int hh = ceil(84*_screenWidth/375.0);
        
        /* 图片(尺寸固定) */
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, ww, hh)];
        _picImageView.backgroundColor = [UIColor grayColor];
        // uiimageview居中裁剪
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
        _picImageView.clipsToBounds  = YES;
        // 需要AFNetwork
        [_picImageView sd_setImageWithURL:[NSURL URLWithString:_picURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [self.contentView addSubview:_picImageView];
        
        /* 标题 */
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(ww+18+14, 14, _screenWidth-(ww+14+18+12), 38)];
        _titleLabel.text = _title;
        _titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size: 15.0];
        _titleLabel.textColor = [colorManager mainTextColor];
        //_titleLabel.backgroundColor = [UIColor yellowColor];
        _titleLabel.numberOfLines = 2;
        [self.contentView addSubview:_titleLabel];
        
        /* 热度 */
        _hotScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(ww+18+14, 54, _screenWidth-(ww+14+18+12), 16)];
        _hotScoreLabel.text = _hotScore;
        _hotScoreLabel.font = [UIFont fontWithName:@"Helvetica" size: 11.0f];
        _hotScoreLabel.textColor = [colorManager lightTextColor];
        [self.contentView addSubview:_hotScoreLabel];
        
        
        /* 话题标签 */
        _topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(ww+18+14, 70, _screenWidth-(ww+14+18+12), 16)];
        _topicLabel.text = _topic;
        _topicLabel.font = [UIFont fontWithName:@"Helvetica" size: 11.0f];
        _topicLabel.textColor = [colorManager lightTextColor];
        [self.contentView addSubview:_topicLabel];
        
        
        /* 背景、分割线 */
        UIView *partLine = [[UIView alloc] initWithFrame:CGRectMake(0, hh+32-0.5, _screenWidth, 0.5)];
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
    
    // 计算cell高度
    _cellHeight = 84*_screenWidth/375.0 + 32;
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






@end



/* 废弃代码 */
/*
- (void)rewriteTopics:(NSArray *)newTopicArr
{
    // 对每个cell单独创建scrollview的方式有些费开销，看看有没有更好办法
    if (_hasTopics == YES) {
        return;
    }
    
    // 循环创建 ScrollView 的各个子视图
    unsigned long xForEachLabel = 0;
    for (int i=0; i<[newTopicArr count]; i++) {
        // 创建一个 UILable
        UILabel *topicLabel = [[UILabel alloc] init];
        // 设置 UILable 的字号(字号会用来计算label宽度）
        topicLabel.font = [UIFont fontWithName:@"Helvetica" size: 12.0];
        topicLabel.text = [newTopicArr objectAtIndex:i];
        topicLabel.textColor = [colorManager lightTextColor];
        //        topicLabel.backgroundColor = [UIColor greenColor];
        // 计算每个 label 的宽度
        CGFloat widthForEachLabel = ((NSString *)[newTopicArr objectAtIndex:i]).length * 12.0;
        NSLog(@"label宽度%f",widthForEachLabel);
        
        // 设置 UILabel 的 frame
        topicLabel.frame = CGRectMake(xForEachLabel, 0, widthForEachLabel, 30);
        [_basedScrollView addSubview:topicLabel];
        
        // 计算每个 label 的横轴位置(待下一个label使用）
        // xForEachLabel 是一个累计值，最终累计出来就是 contentSize 的宽度
        xForEachLabel = xForEachLabel + widthForEachLabel;  // 多加一个间距
    }
    
    _basedScrollView.contentSize = CGSizeMake(xForEachLabel, 30);
    _hasTopics = YES;
}

*/



