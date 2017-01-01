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
#import "YYWebImage.h"

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
        
        /* 话题 */
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, _screenWidth-40, 20)];
        _titleLabel.text = _title;
        _titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size: 17.0];
        _titleLabel.textColor = [colorManager mainTextColor];
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
        [self.contentView addSubview:_titleLabel];
        
        /* 简介 */
        _introductionLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 73, _screenWidth-50*2, 30)];
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
//        _pushSettingView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, _screenWidth, 44)];
//        _pushSettingView.backgroundColor  = [UIColor colorWithRed:(244/255.0) green:(246/255.0) blue:(247/255.0) alpha:1];
//        
//        UILabel *pushLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 200, 44)];
//        pushLabel.text = @"话题有更新时提醒我";
//        pushLabel.font = [UIFont fontWithName:@"Helvetica" size: 14.0];
//        pushLabel.textColor = [colorManager secondTextColor];
//        [_pushSettingView addSubview: pushLabel];
//        
//        _pushSwitch = [[UISwitch alloc]init];
//        _pushSwitch.frame=CGRectMake(_screenWidth-64, 7, 0,0);   // switch大小固定，不用设置size
//        //设置ON一边的背景颜色，默认是绿色
//        _pushSwitch.onTintColor = [UIColor colorWithRed:(47/255.0) green:(175/255.0) blue:(239/255.0) alpha:1];
//        [_pushSwitch setOn:NO animated:YES];
//        [_pushSwitch addTarget:self action:@selector(clickSwitch:) forControlEvents:UIControlEventAllTouchEvents];
//        [_pushSettingView addSubview:_pushSwitch];
//        
//        [self.contentView addSubview:_pushSettingView];
        
        /* 相关推荐 recommend */
        _recommendView = [[UIView alloc] initWithFrame:CGRectMake(0,200, _screenWidth, 15+36)];
        // 灰色线条
        UIView *oneLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 15)];
        oneLine.backgroundColor = [colorManager lightGrayBackground];
        [_recommendView addSubview: oneLine];
        // label标题
        UILabel *recommendLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 15, 200, 36)];
        recommendLabel.text = @"相关推荐";
        recommendLabel.font = [UIFont fontWithName:@"Helvetica" size: 14.0];
        recommendLabel.textColor = [colorManager secondTextColor];
        [_recommendView addSubview: recommendLabel];
        [self.contentView addSubview: _recommendView];
        // 渲染内容
        
        
        /* 背景、分割线 */
        _partLine = [[UIView alloc] initWithFrame:CGRectMake(0, 190, _screenWidth, 15)];
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
    style.lineSpacing = 3;  //行距
    style.alignment = NSTextAlignmentCenter;  //居中
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    _introductionLabel.attributedText = text;
    
    // ===================设置uilabel文本折行====================
    NSString *str = _introduction;
    CGSize maxSize = {_screenWidth-50*2, 5000};  // 设置文本区域最大宽高(两边各留px)
    CGSize labelSize = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:13]
                       constrainedToSize:maxSize
                           lineBreakMode:_introductionLabel.lineBreakMode];   // str是要显示的字符串
    CGFloat newHeight = labelSize.height*16/13.0;
    _introductionLabel.frame = CGRectMake(50, 73, _screenWidth-50*2, newHeight);  // 动态修改label高度,且需要根据行距作调整
    _introductionLabel.numberOfLines = 0;  // 不可少Label属性之一
    //_postTextLabel.lineBreakMode = UILineBreakModeCharacterWrap;  // 不可少Label属性之二
    
    // ===================调整“关注”按钮的位置=================
    _followButton.frame  = CGRectMake((_screenWidth-75)/2.0, 73+newHeight+18, 75, 35);
    _recommendView.frame = CGRectMake(0, 73+newHeight+18+35+18, _screenWidth, 15+36);
    _partLine.frame = CGRectMake(0, 73+newHeight+18+35+18+15+36, _screenWidth, 15);
    // 设置cell高度
    _cellHeight = _partLine.frame.origin.y + _partLine.frame.size.height;
    
    // ===================设置按钮状态====================
    if ([isFollowing isEqualToString:@"no"]) {
        // 代表没有关注
        [_followButton setImage:[UIImage imageNamed:@"follow.png"]];
        //_partLine.frame = CGRectMake(0, 73+newHeight+18+35+18, _screenWidth, 15);
    } else {
        // 已经关注
        [_followButton setImage:[UIImage imageNamed:@"unfollow.png"]];
        //_partLine.frame = CGRectMake(0, 73+newHeight+18+35+18+44, _screenWidth, 15);
    }
}


/** 重写相关推荐 */
- (void)rewriteRecommendWith:(NSMutableArray *)RecommendArray followStatus:(NSString *)isFollowing
{
    // 如果没有相关推荐 or 当前没有关注
    if (RecommendArray.count == 0 || [isFollowing isEqualToString:@"no"]) {
        // 隐藏“相关推荐”四个字
        _recommendView.hidden = YES;
        _cellHeight = _cellHeight - (15+36);
        _partLine.frame = CGRectMake(0, _cellHeight-15, _screenWidth, 15);
        return;
    }
    
    unsigned long basedHeight = _cellHeight - _partLine.frame.size.height;  //基础高度
    for (int i=0; i<RecommendArray.count; i++) {
        // 只取前三个数据（写死在客户端）
        if (i > 2) {
            break;
        }
        
        // 创建话题背景
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, basedHeight + i*44, _screenWidth, 44)];
        [self.contentView addSubview:backgroundView];
        backgroundView.tag = i + 1;
        // 添加点击事件
        backgroundView.userInteractionEnabled = YES; // 设置可以交互
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickRecommend:)]; // 设置手势
        [backgroundView addGestureRecognizer:singleTap]; // 添加手势
        
        // 创建话题头像
        UIImageView *picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 6, 32, 32)];
        picImageView.backgroundColor = [colorManager lightGrayBackground];
        // uiimageview居中裁剪
        picImageView.contentMode = UIViewContentModeScaleAspectFill;
        picImageView.clipsToBounds  = YES;
        picImageView.layer.cornerRadius = 16;
        // 普通加载网络图片 yy库
        picImageView.yy_imageURL = [NSURL URLWithString: RecommendArray[i][@"portrait"]];
        [backgroundView addSubview:picImageView];
        
        // 创建话题名称
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 6, _screenWidth-(58+11+16+11), 16)];
        titleLabel.text = RecommendArray[i][@"title"];
        titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 15];
        titleLabel.textColor = [colorManager mainTextColor];
        [backgroundView addSubview: titleLabel];
        
        // 创建话题简介
        UILabel* introductionLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 24, _screenWidth-(54+16+11+45+16), 16)];
        introductionLabel.text = RecommendArray[i][@"introduction"];
        introductionLabel.font = [UIFont fontWithName:@"Helvetica" size: 12.0f];
        introductionLabel.textColor = [colorManager lightTextColor];
        [backgroundView addSubview: introductionLabel];
        
        // 创建关注按钮
        UIImageView* followButton = [[UIImageView alloc] initWithFrame:CGRectMake(_screenWidth-45-16, 9.5, 45, 25)];
        [followButton setImage:[UIImage imageNamed:@"follow_small.png"]];
        followButton.tag = 110;
        // uiimageview居中裁剪
        followButton.contentMode = UIViewContentModeScaleAspectFill;
        followButton.clipsToBounds  = YES;
        // 添加点击事件
        followButton.userInteractionEnabled = YES; // 设置可以交互
        UITapGestureRecognizer *singleTapOnNoteNumber = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickRecommendFollow:)]; // 设置手势
        [followButton addGestureRecognizer:singleTapOnNoteNumber]; // 添加手势
        [backgroundView addSubview:followButton];
    }
    
    unsigned long num = RecommendArray.count > 3 ? 3 : RecommendArray.count;
    // 设置推荐view
    _recommendView.frame = CGRectMake(0, _recommendView.frame.origin.y, _screenWidth, 44 + 44*num + 12);
    // 设置partline位置
    _partLine.frame = CGRectMake(0, _partLine.frame.origin.y + 44*num + 12, _screenWidth, 15);
    // 设置cell高度
    _cellHeight = _partLine.frame.origin.y + _partLine.frame.size.height;
}





#pragma mark - IBAction

/** 点击follow */
- (void)clickFollowButton:(UIGestureRecognizer *)sender
{
    NSLog(@"click follow button");
    NSLog(@"%@", sender);
    [self.delegate clickFollowButton];
}

/** 点击相关推荐 */
- (void)clickRecommend:(UIGestureRecognizer *)sender
{
    NSLog(@"click recommend");
    unsigned long index = sender.view.tag - 1;
    [self.delegate clickRecommendTopicWith: index];
}

/** 点击相关推荐的follow */
- (void)clickRecommendFollow:(UIGestureRecognizer *)sender
{
    NSLog(@"click recommend follow");
    sender.view.superview.superview.hidden = YES;
    unsigned long index = sender.view.superview.tag - 1;
    [self.delegate clickRecommendFollowWith: index];
}

- (void)clickSwitch:(UISwitch *)sender
{
    NSLog(@"%@", sender);
    [self.delegate changePushSwitch];
}

@end
