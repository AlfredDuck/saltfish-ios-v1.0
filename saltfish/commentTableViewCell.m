//
//  commentTableViewCell.m
//  saltfish
//
//  Created by alfred on 15/12/16.
//  Copyright © 2015年 Alfred. All rights reserved.
//

#import "commentTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "colorManager.h"

@implementation commentTableViewCell

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
        _nickname = @"梦遗大师";
        _comment = @"跟同学摄影的朋友们在金山海滩群拍，抢不到机位就用新入的小傻瓜机按了几张，1比3的比例，电影感极强，冲扫出来却很是喜欢";
        _createTime = @"2014-09-23";
        _picURL = @"";
        self.tag = 999999;
        
        // 昵称
        _nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 15, _screenWidth-50, 15)];
        _nicknameLabel.text = _nickname;
        _nicknameLabel.font = [UIFont fontWithName:@"Helvetica" size: 13];
        _nicknameLabel.textColor = [colorManager commentTextColor];
        [self.contentView addSubview:_nicknameLabel];
        
        // 评论内容
        _commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 41, _screenWidth-50, 30)];
        _commentLabel.text = _comment;
        _commentLabel.font = [UIFont fontWithName:@"Helvetica" size: 13];
        _commentLabel.textColor = [colorManager commentTextColor];
        [self.contentView addSubview:_commentLabel];
        
        // 创建时间
        _createTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, _screenWidth-50, 15)];
        _createTimeLabel.text = _createTime;
        _createTimeLabel.font = [UIFont fontWithName:@"Helvetica" size: 11];
        _createTimeLabel.textColor = [colorManager lightTextColor];
        [self.contentView addSubview:_createTimeLabel];
        
        // 头像(1.0是固定的默认头像)
//        _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 9, 26, 26)];
//        UIImage *oneImage = [UIImage imageNamed:@"portrait.png"]; // 使用ImageView通过name找到图片
//        [_picImageView setImage:oneImage];
//        [self.contentView addSubview:_picImageView];
        
        // 头像(2.0是用户自己的头像)
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 9, 26, 26)];
        _picImageView.backgroundColor = [UIColor grayColor];
        // uiimageview居中裁剪
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
        _picImageView.clipsToBounds  = YES;
        _picImageView.layer.cornerRadius = 13;
        [self.contentView addSubview:_picImageView];
        
        // 背景、分割线
        _partLine = [[UIView alloc] initWithFrame:CGRectMake(50, 0, _screenWidth, 0.5)];
        _partLine.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1];
        [self.contentView addSubview:_partLine];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        
        // not usefull
        self.frame = CGRectMake(0, 0, 300, 300);
        NSLog(@"%f", self.frame.size.height);
        
    }
    return self;
}



#pragma mark - 重写cell属性

- (void)rewritePortrait:(NSString *)newPortrait
{
    _picURL = newPortrait;
    // 需要SDWebImage
    [_picImageView sd_setImageWithURL:[NSURL URLWithString:_picURL] placeholderImage:[UIImage imageNamed:@"portrait.png"]];
}

- (void)rewriteNickname:(NSString *)newNickname
{
    _nickname = newNickname;
    _nicknameLabel.text = _nickname;
}

- (void)rewriteCreateTime:(NSString *)newCreateTime
{
    _createTime = newCreateTime;
    _createTimeLabel.text = _createTime;
}


- (void)rewriteComment:(NSString *)newComment
{
    _comment = newComment;
    //_commentLabel.text = _comment;
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:_comment];
    //设置行距
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 3;//行距
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    _commentLabel.attributedText = text;
    
    // ===================设置UIlabel文本折行====================
    NSString *str = _comment;
    CGSize maxSize = {_screenWidth-50-15, 5000};  // 设置文本区域最大宽高
    CGSize labelSize = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:13]
                       constrainedToSize:maxSize
                           lineBreakMode:_commentLabel.lineBreakMode];   // str是要显示的字符串
    _commentLabel.frame = CGRectMake(50,42,labelSize.width,labelSize.height/13*16);  // 因为行距增加了，所以要用参数修正height
    _commentLabel.numberOfLines = 0;  // 不可少Label属性之一
    //_postTextLabel.lineBreakMode = UILineBreakModeCharacterWrap;  // 不可少Label属性之二
    // ========================================================
    // 使用uitextview也可以，可以研究下。。。
    
    // 设置cellHeight (所有高度和间距加起来)
    _cellHeight = 42 + _commentLabel.frame.size.height + 10 + 15 +15;
    // 设置createTime的位置
    _createTimeLabel.frame = CGRectMake(50, 42+_commentLabel.frame.size.height+10, _screenWidth-60, 15);
    // 设置分割线的位置
    _partLine.frame = CGRectMake(50, _cellHeight-0.5, _screenWidth-50, 0.5);
}



@end
