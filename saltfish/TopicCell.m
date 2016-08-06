//
//  TopicCell.m
//  saltfish
//
//  Created by alfred on 16/6/25.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "TopicCell.h"
#import "UIImageView+WebCache.h"
#import "colorManager.h"

@implementation TopicCell

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
        _title = @"#佐佐木希#";
        _introduction = @"脉动总装线是把总装分为几个工位，在不同工位组装不同部件和零配件，然后逐步";
        self.tag = 999998;
        
        /* 主题 */
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, _screenWidth-40, 20)];
        _titleLabel.text = _title;
        _titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size: 16.5];
        _titleLabel.textColor = [colorManager mainTextColor];
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
        [self.contentView addSubview:_titleLabel];
        
        /* 简介 */
        _introductionLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 68, _screenWidth-50*2, 30)];
        _introductionLabel.text = _introduction;
        _introductionLabel.font = [UIFont fontWithName:@"Helvetica" size: 13.0f];
        _introductionLabel.textColor = [colorManager secondTextColor];
        _introductionLabel.textAlignment = UITextAlignmentCenter;
        [self.contentView addSubview:_introductionLabel];
        
        
        /* 关注按钮 */
        _followButton = [[UIImageView alloc] initWithFrame:CGRectMake((_screenWidth-75)/2.0, 100, 75, 35)];
        [_followButton setImage:[UIImage imageNamed:@"follow.png"]];
        _followButton.tag = 110;
        // uiimageview居中裁剪
        _followButton.contentMode = UIViewContentModeScaleAspectFill;
        _followButton.clipsToBounds  = YES;
        // 添加点击事件
        _followButton.userInteractionEnabled = YES; // 设置可以交互
        UITapGestureRecognizer *singleTapOnNoteNumber = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickFollowButton:)]; // 设置手势
        [_followButton addGestureRecognizer:singleTapOnNoteNumber]; // 添加手势
        [self.contentView addSubview:_followButton];
        
        
        /* 推送开关 */
        _pushSettingView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, _screenWidth, 44)];
        _pushSettingView.backgroundColor  = [UIColor colorWithRed:(244/255.0) green:(246/255.0) blue:(247/255.0) alpha:1];
        
        UILabel *pushLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 200, 44)];
        pushLabel.text = @"此主题有更新时提醒我";
        pushLabel.font = [UIFont fontWithName:@"Helvetica" size: 14.0];
        pushLabel.textColor = [colorManager secondTextColor];
        [_pushSettingView addSubview: pushLabel];
        
        _pushSwitch = [[UISwitch alloc]init];
        _pushSwitch.frame=CGRectMake(_screenWidth-64, 7, 0,0);   // switch大小固定，不用设置size
        //设置ON一边的背景颜色，默认是绿色
        _pushSwitch.onTintColor = [UIColor colorWithRed:(47/255.0) green:(175/255.0) blue:(239/255.0) alpha:1];
        [_pushSwitch setOn:NO animated:YES];
        [_pushSwitch addTarget:self action:@selector(clickSwitch:) forControlEvents:UIControlEventAllTouchEvents];
        [_pushSettingView addSubview:_pushSwitch];
        
        [self.contentView addSubview:_pushSettingView];
        
        
        /* 背景、分割线 */
        _partLine = [[UIView alloc] initWithFrame:CGRectMake(0, 190, _screenWidth, 12)];
        _partLine.backgroundColor = [colorManager lightGrayBackground];
        [self.contentView addSubview:_partLine];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        // not usefull
        self.frame = CGRectMake(0, 0, 300, 300);
        NSLog(@"%f", self.frame.size.height);
        
    }
    return self;
}



#pragma mark - 重写 cell 中各个元素的数据

- (void)rewriteTopic:(NSString *)newTopic
{
    _title = newTopic;
    _titleLabel.text = _title;
}


- (void)rewriteIntroduction:(NSString *)newIntroduction followStatus:(NSString *)isFollowing pushStatus:(NSString *)isPushOn
{
    _introduction = newIntroduction;
    
    // ==================设置行距===================
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:_introduction];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 3;//行距
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    _introductionLabel.attributedText = text;
    _introductionLabel.textAlignment = UITextAlignmentCenter;
    
    // ===================设置uilabel文本折行====================
    NSString *str = _introduction;
    CGSize maxSize = {_screenWidth-50*2, 5000};  // 设置文本区域最大宽高(两边各留15px)
    CGSize labelSize = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:13]
                       constrainedToSize:maxSize
                           lineBreakMode:_introductionLabel.lineBreakMode];   // str是要显示的字符串
    CGFloat newHeight = labelSize.height*16/13.0;
    _introductionLabel.frame = CGRectMake(50, 68, labelSize.width, newHeight);  // 动态修改label高度,且需要根据行距作调整
    _introductionLabel.numberOfLines = 0;  // 不可少Label属性之一
    //_postTextLabel.lineBreakMode = UILineBreakModeCharacterWrap;  // 不可少Label属性之二
    
    // ===================调整“关注”按钮的位置=================
    _followButton.frame  = CGRectMake((_screenWidth-75)/2.0, 68+newHeight+18, 75, 35);
    _pushSettingView.frame = CGRectMake(0, 68+newHeight+18+35+18, _screenWidth, 44);
    
    // ===================调整分割线位置====================
    if ([isFollowing isEqualToString:@"no"]) {
        // 代表没有关注
        [_followButton setImage:[UIImage imageNamed:@"follow.png"]];
        _pushSettingView.alpha = 0;
        _partLine.frame = CGRectMake(0, 68+newHeight+18+35+18, _screenWidth, 12);
    } else {
        // 已经关注
        [_followButton setImage:[UIImage imageNamed:@"unfollow.png"]];
        _pushSettingView.alpha = 1;
        _partLine.frame = CGRectMake(0, 68+newHeight+18+35+18+44, _screenWidth, 12);
        
        // push开关状态
        if ([isPushOn isEqualToString:@"yes"]) {
            [_pushSwitch setOn:YES];
        } else {
            [_pushSwitch setOn:NO];
        }
    }
    
    // 设置cell高度
    _cellHeight = _partLine.frame.origin.y + _partLine.frame.size.height;
    
}





#pragma mark - IBAction

- (void)clickFollowButton:(UIGestureRecognizer *)sender
{
    NSLog(@"click follow button");
    NSLog(@"%@", sender);
    [self.delegate clickFollowButton];
}

- (void)clickSwitch:(UISwitch *)sender
{
    NSLog(@"%@", sender);
    [self.delegate changePushSwitch];
}

@end
