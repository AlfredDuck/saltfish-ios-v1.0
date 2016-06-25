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
        _picURL = @"http://i10.topitme.com/l007/100079161401a5c7b0.jpg";
        self.tag = 999999;
        
        // 标题
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100+10+10, 10, _screenWidth-(100+30), 44)];
        _titleLabel.text = _title;
        _titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 16.0];
        _titleLabel.textColor = [colorManager mainTextColor];
        //_titleLabel.backgroundColor = [UIColor yellowColor];
        _titleLabel.numberOfLines = 2;
        [self.contentView addSubview:_titleLabel];
        
        // 热度
        _hotScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(100+10+10, 48, _screenWidth-(100+30), 30)];
        _hotScoreLabel.text = _hotScore;
        _hotScoreLabel.font = [UIFont fontWithName:@"Helvetica" size: 12.0f];
        _hotScoreLabel.textColor = [colorManager lightTextColor];
        [self.contentView addSubview:_hotScoreLabel];
        
        // 图片(尺寸固定)
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 100, 95)];
        _picImageView.backgroundColor = [UIColor grayColor];
        // uiimageview居中裁剪
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
        _picImageView.clipsToBounds  = YES;
        // 需要AFNetwork
        [_picImageView sd_setImageWithURL:[NSURL URLWithString:_picURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [self.contentView addSubview:_picImageView];
        
        // 背景、分割线
        UIView *partLine = [[UIView alloc] initWithFrame:CGRectMake(0, 95+20, _screenWidth, 4)];
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

- (void)rewriteHotDegree:(NSString *)newDegree
{
    _hotDegree = newDegree;
    //_hotDegree = [@"人气 " stringByAppendingString:newDegree];
    _hotDegreeLabel.text = _hotDegree;
}

- (void)rewritePicURL:(NSString *)newPicURL
{
    _picURL = newPicURL;
    [_picImageView sd_setImageWithURL:[NSURL URLWithString:_picURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
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
