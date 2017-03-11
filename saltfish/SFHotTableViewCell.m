//
//  SFHotTableViewCell.m
//  saltfish
//
//  Created by alfred on 16/7/3.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFHotTableViewCell.h"
#import "colorManager.h"
#import "UIImageView+WebCache.h"
#import "YYWebImage.h"


@implementation SFHotTableViewCell

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
    
        _hotArticleHeight = 0;
        
        /* ================ 推荐话题 ================= */
        
        /* cell标题 */
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_screenWidth-200)/2.0, _hotArticleHeight+16, 200, 20)];
        titleLabel.text = @"· 推荐话题 ·";
        titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 15.5];
        titleLabel.textColor = [colorManager mainTextColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:titleLabel];
        
        // 根据设备宽度计算图片宽高
        int ww = ceil((_screenWidth - 20*2 - 20*2)/3.0);
        // int hh = ceil(ww/107.0*89);
        int hh = ww;
        
        _hotTopicPicArr = [[NSMutableArray alloc] init];
        _hotTopicLabelArr = [[NSMutableArray alloc] init];
        
        for (int i=0; i<3; i++) {
            
            // 52px的上边距, xxpx的焦点图
            UIView *topicView = [[UIView alloc] initWithFrame:CGRectMake(20+i*(ww+20), 52+_hotArticleHeight, ww, hh)];
            
            UIImageView *picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ww, hh)];
            picImageView.backgroundColor = [colorManager lightGrayBackground];
            // uiimageview居中裁剪
            picImageView.contentMode = UIViewContentModeScaleAspectFill;
            picImageView.clipsToBounds  = YES;
            picImageView.layer.cornerRadius = 6;
            [topicView addSubview:picImageView];
            
            // 文本（在图下面，用UItextview有奇效）
            UITextView *topicLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, hh, ww, 37)];
            topicLabel.textColor = [colorManager mainTextColor];
            topicLabel.font = [UIFont fontWithName:@"Helvetica" size: 12.5f];
            topicLabel.userInteractionEnabled = NO;
            topicLabel.textAlignment = NSTextAlignmentCenter;
            [topicView addSubview:topicLabel];
            
            // 点击手势
            picImageView.userInteractionEnabled = YES; // 设置view可以交互
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHotTopic:)];   // 设置手势
            [picImageView addGestureRecognizer:singleTap]; // 给view添加手势
            
            picImageView.tag = i + 1;
            
            [self.contentView addSubview:topicView];
            [_hotTopicPicArr addObject:picImageView];
            [_hotTopicLabelArr addObject:topicLabel];
        }

        /* 分割线 + 下一段标题 */
        _partLine = [[UIView alloc] initWithFrame:CGRectMake(0, 360-8, _screenWidth, 8)];
        _partLine.backgroundColor = [colorManager lightGrayBackground];
        [self.contentView addSubview: _partLine];
        
        /* cell 背景色 */
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        
        // not usefull
        self.frame = CGRectMake(0, 0, 300, 300);
        NSLog(@"%f", self.frame.size.height);
        
    }
    return self;
}




#pragma mark - 重写 cell 中各个元素数据

/* 重写热门话题数据 */
- (void)rewriteHotTopics:(NSArray *)newArr
{
    _hotTopicData = newArr;
    
    for (int i=0; i<3; i++) {
        UITextView *topicLabel = [_hotTopicLabelArr objectAtIndex:i];
        topicLabel.text = [[newArr objectAtIndex:i] objectForKey:@"topic"];
        
        UIImageView *picImageView = [_hotTopicPicArr objectAtIndex:i];
        // 普通加载网络图片 yy库
        picImageView.yy_imageURL = [NSURL URLWithString:[[newArr objectAtIndex:i] objectForKey:@"picURL"]];
    }
}


/* 重置cell高度 */
- (void)rewriteCellHeight
{
    UIImageView *TopicPic = [_hotTopicPicArr objectAtIndex:0];
    unsigned long hh = TopicPic.frame.size.height;
    _cellHeight = _hotArticleHeight + 52 + hh + 27 + 18 + 13;
    // 修改分割线位置
    _partLine.frame = CGRectMake(0, _cellHeight-8, _screenWidth, 8);
}






#pragma mark - IBAction

- (void)clickHotTopic:(UIGestureRecognizer *)sender
{
    NSLog(@"%lu", (unsigned long)sender.view.tag);
    NSString *topic = [[_hotTopicData objectAtIndex:sender.view.tag - 1] objectForKey:@"topic"];
    NSString *picURL = [[_hotTopicData objectAtIndex:sender.view.tag - 1] objectForKey:@"picURL"];
    [self.delegate clickHotTopic:topic pic:picURL];
}


@end
