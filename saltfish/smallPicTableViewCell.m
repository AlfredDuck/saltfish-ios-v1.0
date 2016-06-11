//
//  smallPicTableViewCell.m
//  saltfish
//
//  Created by alfred on 15/12/13.
//  Copyright © 2015年 Alfred. All rights reserved.
//

#import "smallPicTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "colorManager.h"

@implementation smallPicTableViewCell

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
        
        //  图片长宽
        float imgW = _screenWidth/4.0;  // 80px
        float imgH = imgW*3/4;   // 60px
        
        int imgWidth = ceil(imgW);  // 对布局参数取整，避免文字模糊
        int imgHeight = ceil(imgH);

        // 一些初始化的值
        _title = @"曾经沧海难为水，除却巫山不是风雨云。怎么你还不来啊";
        _hotDegree = @"人气 45";
        _picURL = @"";
        self.tag = 999999;

        // 标题
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8+imgWidth+14, 12, _screenWidth-(8+imgWidth+14+8), 38)];
        _titleLabel.text = _title;
        _titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size: 16];
        _titleLabel.textColor = [colorManager mainTextColor];
        //_titleLabel.backgroundColor = [UIColor yellowColor];
        _titleLabel.numberOfLines = 2;
        [self.contentView addSubview:_titleLabel];

        // 热度
        _hotDegreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(8+imgWidth+14, 48, _screenWidth-(8+imgWidth+14+8), 30)];
        _hotDegreeLabel.text = _hotDegree;
        _hotDegreeLabel.font = [UIFont fontWithName:@"Helvetica" size: 12.0f];
        _hotDegreeLabel.textColor = [colorManager lightTextColor];
        [self.contentView addSubview:_hotDegreeLabel];

        // 图片(尺寸固定)
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 12, imgWidth, imgHeight)];
        _picImageView.backgroundColor = [UIColor grayColor];
        // uiimageview居中裁剪
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
        _picImageView.clipsToBounds  = YES;
        // 需要AFNetwork
        [_picImageView sd_setImageWithURL:[NSURL URLWithString:_picURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [self.contentView addSubview:_picImageView];

        // 背景、分割线
        UIView *partLine = [[UIView alloc] initWithFrame:CGRectMake(0, imgHeight+12+12, _screenWidth, 4)];
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
