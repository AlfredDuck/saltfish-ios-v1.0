//
//  articleCell.m
//  saltfish
//
//  Created by alfred on 16/6/25.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFArticleCell.h"
#import "UIImageView+WebCache.h"
#import "YYWebImage.h"
#import "colorManager.h"

#define LIKEICON  [UIImage imageNamed:@"like_icon.png"]
#define LIKEICONRED  [UIImage imageNamed:@"like_icon_red.png"]

@implementation SFArticleCell

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
        _topic = @"阿拉丁";
        _date = @"2017-09-08";
        _portraitURL = @"http://i10.topitme.com/l007/100079161401a5c7b0.jpg";
        
        
        /* 话题头像 */
        _portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 15, 36, 36)];
        _portraitImageView.backgroundColor = [colorManager lightGrayBackground];
        // uiimageview居中裁剪
        _portraitImageView.contentMode = UIViewContentModeScaleAspectFill;
        _portraitImageView.clipsToBounds  = YES;
        _portraitImageView.layer.cornerRadius = 18;
        // 普通加载网络图片 yy库
        _portraitImageView.yy_imageURL = [NSURL URLWithString:_portraitURL];
        [self.contentView addSubview:_portraitImageView];
        // 添加手势
        _portraitImageView.userInteractionEnabled = YES; // 设置可以交互
        UITapGestureRecognizer *singleTapPortrait = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPortrait:)]; // 设置手势
        [_portraitImageView addGestureRecognizer:singleTapPortrait]; // 添加手势

        
        /* 话题标题 */
        _topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(57, 15, 200, 20)];
        _topicLabel.text = _topic;
        _topicLabel.font = [UIFont fontWithName:@"Helvetica" size: 14.0];
        _topicLabel.textColor = [colorManager blueLinkColor];
        [self.contentView addSubview:_topicLabel];
        // 添加手势
        _topicLabel.userInteractionEnabled = YES; // 设置可以交互
        UITapGestureRecognizer *singleTapTopic = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTopic:)]; // 设置手势
        [_topicLabel addGestureRecognizer:singleTapTopic]; // 添加手势
        
        /* 日期 */
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(57, 35, 200, 16)];
        _dateLabel.text = _date;
        _dateLabel.font = [UIFont fontWithName:@"Helvetica" size: 11.0];
        _dateLabel.textColor = [colorManager lightTextColor];
        [self.contentView addSubview:_dateLabel];
        
        /* 外链标志 */
        _linkMark = [[UIImageView alloc] initWithFrame:CGRectMake(_screenWidth-63-15, 20, 63, 22)];
        _linkMark.image = [UIImage imageNamed:@"link.png"];
        [self.contentView addSubview:_linkMark];
        
        /* 标题 */
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 66, _screenWidth-30, 38)];
        _titleLabel.text = _title;
        _titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 17.0];
        _titleLabel.textColor = [colorManager mainTextColor];
        //_titleLabel.backgroundColor = [UIColor yellowColor];
        _titleLabel.numberOfLines = 2;
        [self.contentView addSubview:_titleLabel];
        
        /* 图片未在此处定义 */
        
        /* ------------- 评论、喜欢、分享 -------------- */
        _customerView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, _screenWidth, 36)];  // 用户操作区域背景
        [self.contentView addSubview: _customerView];
        
        unsigned long ww = ceil(_screenWidth/3.0);
        
        /* 分享区域 */
        _shareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ww, 36)];
        // 添加点击事件
        _shareView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTapShare = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickShareIcon:)]; // 设置手势
        [_shareView addGestureRecognizer:singleTapShare]; // 添加手势
        [_customerView addSubview: _shareView];
        
        // 分享icon
        UIImage *shareIcon = [UIImage imageNamed:@"share_icon.png"];  // 32*28
        UIImageView *shareIconView = [[UIImageView alloc] initWithImage:shareIcon]; // 把oneImage添加到oneImageView上
        shareIconView.frame = CGRectMake((ww-65)/2.0, 11, 16, 14); // 设置图片位置和大小
        [_shareView addSubview: shareIconView];
        
        // 分享title
        _shareLabel = [[UILabel alloc] initWithFrame:CGRectMake((ww-65)/2.0+16+5, 0, 45, 36)];
        _shareLabel.text = @"分享";
        _shareLabel.font = [UIFont fontWithName:@"Helvetica" size: 14.0];
        _shareLabel.textColor = [colorManager secondTextColor];
        [_shareView addSubview: _shareLabel];
        
        /* 评论区域 */
        _commentView = [[UIView alloc] initWithFrame:CGRectMake(ww, 0, ww, 36)];
        // 添加点击事件
        _commentView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTapComment = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCommentIcon:)]; // 设置手势
        [_commentView addGestureRecognizer:singleTapComment]; // 添加手势
        [_customerView addSubview: _commentView];
        
        // 评论icon
        UIImage *commentIcon = [UIImage imageNamed:@"comment_icon.png"];  // 34*30
        UIImageView *commentIconView = [[UIImageView alloc] initWithImage:commentIcon]; // 把oneImage添加到oneImageView上
        commentIconView.frame = CGRectMake((ww-65)/2.0, 10.5, 17, 15); // 设置图片位置和大小
        [_commentView addSubview: commentIconView];
        
        // 评论title
        _commentLabel = [[UILabel alloc] initWithFrame:CGRectMake((ww-65)/2.0+16+5, 0, 45, 36)];
        _commentLabel.text = @"评论";
        _commentLabel.font = [UIFont fontWithName:@"Helvetica" size: 14.0];
        _commentLabel.textColor = [colorManager secondTextColor];
        [_commentView addSubview: _commentLabel];
        
        /* 喜欢😍区域 */
        _likeView = [[UIView alloc] initWithFrame:CGRectMake(2*ww, 0, ww, 36)];
        // 添加点击事件
        _likeView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTapLike = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickLikeIcon:)]; // 设置手势
        [_likeView addGestureRecognizer:singleTapLike]; // 添加手势
        [_customerView addSubview: _likeView];
        
        // 喜欢icon
        UIImage *likeIcon = [UIImage imageNamed:@"like_icon.png"];  // 32*28
        _likeIconView = [[UIImageView alloc] initWithImage: likeIcon]; // 把oneImage添加到oneImageView上
        _likeIconView.frame = CGRectMake((ww-65)/2.0, 11, 16, 14); // 设置图片位置和大小
        [_likeView addSubview: _likeIconView];
        
        // 喜欢title
        _likeLabel = [[UILabel alloc] initWithFrame:CGRectMake((ww-65)/2.0+16+5, 0, 45, 36)];
        _likeLabel.text = @"喜欢";
        _likeLabel.font = [UIFont fontWithName:@"Helvetica" size: 14.0];
        _likeLabel.textColor = [colorManager secondTextColor];
        [_likeView addSubview: _likeLabel];
        
        /* 分割线 */
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 0.5)];  // 分割线
        line.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
        [_customerView addSubview:line];
        
        /* ------------- END -------------- */

        
        /* 背景、分割线 */
        _partLine = [[UIView alloc] initWithFrame:CGRectMake(0, 40, _screenWidth, 15)];
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

- (void) rewriteTopic:(NSString *)newTopic withIndex:(unsigned long)index
{
    _topic = newTopic;
    _topicLabel.text = _topic;
    _topicLabel.tag = index + 1;
}

- (void)rewriteDate:(NSString *)newDate
{
    _date = newDate;
    _dateLabel.text = _date;
}

- (void)rewritePortrait:(NSString *)newPortrait withIndex:(unsigned long)index
{
    _portraitURL = newPortrait;
    // 普通加载网络图片 yy库
    _portraitImageView.yy_imageURL = [NSURL URLWithString:_portraitURL];
    _portraitImageView.tag = index + 1;
}


/** 重写含链接标记 **/
- (void) rewriteLinkMark:(BOOL)isShow
{
    if (!isShow) {
        _linkMark.hidden = YES;
    } else {
        _linkMark.hidden = NO;
    }
}


/** 重写分享数 **/
- (void)rewriteShareNum:(unsigned long)newShareNum withIndex:(unsigned long)index
{
    if (newShareNum == 0) {
        _shareLabel.text = @"分享";
    } else {
        _shareLabel.text = [NSString stringWithFormat: @"%lu", newShareNum];  // 数字转字符
    }
    _shareView.tag = index + 1;
}


/** 重写评论数 **/
- (void)rewriteCommentNum:(unsigned long)newCommentNum withIndex:(unsigned long)index
{
    if (newCommentNum == 0) {
        _commentLabel.text = @"评论";
    } else {
        _commentLabel.text = [NSString stringWithFormat: @"%lu", newCommentNum];  // 数字转字符
    }
    _commentView.tag = index + 1;
}


/** 重写喜欢数 **/
- (void)rewriteLikeNum:(unsigned long)newLikeNum withIndex:(unsigned long)index
{
    if (newLikeNum == 0) {
        _likeLabel.text = @"喜欢";
    } else {
        _likeLabel.text = [NSString stringWithFormat: @"%lu", newLikeNum];  // 数字转字符
    }
    _likeView.tag = index + 1;
}


/** 重写喜欢状态 */
- (void)rewriteLikeStatus:(NSString *)newLikeStatus
{
    if ([newLikeStatus isEqualToString:@"yes"]) {
        _likeIconView.image = LIKEICONRED;
    } else {
        _likeIconView.image = LIKEICON;
    }
}


/** 重写标题 **/
- (void)rewriteTitle:(NSString *)newTitle
{
    _title = newTitle;
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:_title];
    //设置行距
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 3;//行距
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    _titleLabel.attributedText = text;
    
    // ===================设置UIlabel文本折行====================
    NSString *str = _title;
    CGSize maxSize = {_screenWidth-30, 5000};  // 设置文本区域最大宽高
    CGSize labelSize = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17.0]
                       constrainedToSize:maxSize
                           lineBreakMode:_titleLabel.lineBreakMode];   // str是要显示的字符串
    unsigned long height = labelSize.height/17*20.0;
    _titleLabel.frame = CGRectMake(15, 66, labelSize.width, height);  // 因为行距增加了，所以要用参数修正height
    _titleLabel.numberOfLines = 0;  // 不可少Label属性之一
    //_postTextLabel.lineBreakMode = UILineBreakModeCharacterWrap;  // 不可少Label属性之二
    
    _textHeight = 64 + height + 15;
    /* 底部分割线 */
//    _partLine.frame = CGRectMake(0, _cellHeight-5, _screenWidth, 5);
}


/** 重写图片 **/
- (void)rewritePicURL:(NSArray *)newPicArr withIndex:(unsigned long)index
{
    if (_hasPics) {
        [_holdView removeFromSuperview];  // 为了复用cell，删除原来生成的图片view
    }
    
    // 如果没有图片
    NSLog(@"%@", [newPicArr class]);
    NSLog(@"%@", newPicArr);
    if (0 == [newPicArr count]) {
        // 用户操作区域高度
        _customerView.frame = CGRectMake(0, _textHeight, _screenWidth, 36);
        /* cell 高度 */
        _cellHeight = _textHeight + 36 + 15;
        /* 底部分割线 */
        _partLine.frame = CGRectMake(0, _cellHeight-15, _screenWidth, 15);
        _hasPics = YES;  // 记录是否已经创建pic矩阵
        return;
    }
    
    _holdView = [[UIView alloc] initWithFrame:CGRectMake(0, _textHeight, _screenWidth, 1)];
    [self.contentView addSubview:_holdView];
    
    // 如果只有一张图片
    if (1 == [newPicArr count]) {
        // 根据设备宽度计算图片宽高
        int ww = ceil(_screenWidth - 30);
        int hh = ww/16.0*9;
        UIImageView *picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, ww, hh)];
        picImageView.backgroundColor = [colorManager lightGrayBackground];
        // uiimageview居中裁剪
        picImageView.contentMode = UIViewContentModeScaleAspectFill;
        picImageView.clipsToBounds  = YES;
        // 需要SDWebImage
        NSString *url = newPicArr[0];
        // 普通加载网络图片 yy库
        picImageView.yy_imageURL = [NSURL URLWithString:url];
        // 渐进式：边下载边显示 yy库
        //[picImageView yy_setImageWithURL:[NSURL URLWithString:url] options:YYWebImageOptionProgressive];
        
        // 添加手势
        picImageView.userInteractionEnabled = YES; // 设置可以交互
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPic:)]; // 设置手势
        [picImageView addGestureRecognizer:singleTap]; // 添加手势
        [_holdView addSubview:picImageView];
        _holdView.frame = CGRectMake(0, _textHeight, _screenWidth, hh);
        
        // tag的百位代表在tableview的第几位，各位代表在图片数组中的第几位（用百位是怕图片数量超过10）
        picImageView.tag = (index+1) * 100 + 0;
        
        // 用户操作区域高度
        _customerView.frame = CGRectMake(0, _textHeight+hh+15, _screenWidth, 36);
        /* cell 高度 */
        _cellHeight = _textHeight + hh + 15 + (15+36);
        /* 底部分割线 */
        _partLine.frame = CGRectMake(0, _cellHeight-15, _screenWidth, 15);
        _hasPics = YES;  // 记录是否已经创建pic矩阵
        return;
    }
    
    /* 图片矩阵 */
    // 将一维数组处理成二维数组
    /*
     逐一读取原始数组
     创建一个single，把single存入double
     把原始数组存入double里的single
     每隔3个元素，创建一个single
     原始数组只存到最后一个single里
     */
    
    NSMutableArray *DoubleArr = [[NSMutableArray alloc] init];  // 创建一个二维数组容器
    NSMutableArray *singleArr = [[NSMutableArray alloc] init];  // 创建一个一维数组，存入二维数组的第一个位置
    [DoubleArr addObject:singleArr];
    
    for (int i=0; i<[newPicArr count]; i++) {
        [[DoubleArr lastObject] addObject:[newPicArr objectAtIndex:i]];
        if ((i+1)%3 == 0 && (i+1)!=[newPicArr count]) {    // 每隔3个元素创建一个一维数组，如果是最后一个元素则不创建
            NSMutableArray *singleArr = [[NSMutableArray alloc] init];
            [DoubleArr addObject: singleArr];
        }
    }
    NSLog(@"二维数组：%@", DoubleArr);
    
    
    // 根据设备宽度计算图片宽高
    int ww = ceil((_screenWidth - 4*2 - 15*2)/3.0);
    int hh = ww;
    
    // 循环创建 imageView
    for (int i=0; i<[DoubleArr count]; i++) {  // 第一层
        for (int j=0; j<[[DoubleArr objectAtIndex:i] count]; j++) {  // 第二层
            
            UIImageView *picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15+j*(ww+4), i*(hh+4), ww, hh)];
            picImageView.backgroundColor = [colorManager lightGrayBackground];
            // uiimageview居中裁剪
            picImageView.contentMode = UIViewContentModeScaleAspectFill;
            picImageView.clipsToBounds  = YES;
            NSString *url = [[DoubleArr objectAtIndex:i] objectAtIndex:j];
            // 普通加载网络图片 yy库
            picImageView.yy_imageURL = [NSURL URLWithString:url];
            // 渐进式：边下载边显示 yy库
            //[picImageView yy_setImageWithURL:[NSURL URLWithString:url] options:YYWebImageOptionProgressive];
            // 添加手势
            picImageView.userInteractionEnabled = YES; // 设置可以交互
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPic:)]; // 设置手势
            [picImageView addGestureRecognizer:singleTap]; // 添加手势
            [_holdView addSubview:picImageView];
            
            // tag的百位代表在tableview的第几位，各位代表在图片数组中的第几位（用百位是怕图片数量超过10）
            picImageView.tag = (index+1) * 100 + i*3+j;
        }
    }
    
    _holdView.frame = CGRectMake(0, _textHeight, _screenWidth, [DoubleArr count]*(hh+4));
    
    // 用户操作区域高度
    _customerView.frame = CGRectMake(0, _textHeight + [DoubleArr count]*(hh+4) + 15-4, _screenWidth, 36);
    /* cell 高度 */
    _cellHeight = _textHeight + [DoubleArr count]*(hh+4) + 15-4 + (15+36);
    /* 底部分割线 */
    _partLine.frame = CGRectMake(0, _cellHeight-15, _screenWidth, 15);
    _hasPics = YES;  // 记录是否已经创建pic矩阵
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
/** 点击话题 **/
- (void)clickTopic:(UIGestureRecognizer *)sender
{
    NSLog(@"点第%ld个文章", sender.view.tag);
    [self.delegate clickTopicForIndex:sender.view.tag - 1];  // 调用代理方法
}

/** 点击话题头像 **/
- (void)clickPortrait:(UIGestureRecognizer *)sender
{
    NSLog(@"点第%ld个文章", sender.view.tag);
    [self.delegate clickTopicForIndex:sender.view.tag - 1];  // 调用代理方法
}

/** 点击图片 **/
- (void)clickPic:(UIGestureRecognizer *)sender
{
    NSLog(@"点第%ld个文章", sender.view.tag);
    [self.delegate clickPicsForIndex:sender.view.tag withView:(UIView *)sender.view];  // 调用代理方法
}

/** 点击分享icon **/
- (void)clickShareIcon:(UIGestureRecognizer *)sender
{
    NSLog(@"点第%ld个文章", sender.view.tag);
    [self.delegate clickShareIconForIndex: sender.view.tag - 1];
}
/** 点击评论icon **/
- (void)clickCommentIcon:(UIGestureRecognizer *)sender
{
    NSLog(@"点第%ld个文章", sender.view.tag);
    [self.delegate clickCommentIconForIndex: sender.view.tag - 1];
}
/** 点击喜欢icon **/
- (void)clickLikeIcon:(UIGestureRecognizer *)sender
{
    NSLog(@"点第%ld个文章", sender.view.tag);
    [self.delegate clickLikeIconForIndex: sender.view.tag - 1];
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



