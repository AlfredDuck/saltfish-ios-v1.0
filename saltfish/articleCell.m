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
        
        /* 图片(尺寸固定) */
        _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 14, 100, 95)];
        _picImageView.backgroundColor = [UIColor grayColor];
        // uiimageview居中裁剪
        _picImageView.contentMode = UIViewContentModeScaleAspectFill;
        _picImageView.clipsToBounds  = YES;
        // 需要AFNetwork
        [_picImageView sd_setImageWithURL:[NSURL URLWithString:_picURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [self.contentView addSubview:_picImageView];
        
        /* 标题 */
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100+12+14, 14, _screenWidth-(100+12+14+12), 44)];
        _titleLabel.text = _title;
        _titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size: 16.0];
        _titleLabel.textColor = [colorManager mainTextColor];
        //_titleLabel.backgroundColor = [UIColor yellowColor];
        _titleLabel.numberOfLines = 2;
        [self.contentView addSubview:_titleLabel];
        
        /* 热度 */
        _hotScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(100+12+14, 60, _screenWidth-(100+12+14+12), 30)];
        _hotScoreLabel.text = _hotScore;
        _hotScoreLabel.font = [UIFont fontWithName:@"Helvetica" size: 12.0f];
        _hotScoreLabel.textColor = [colorManager lightTextColor];
        [self.contentView addSubview:_hotScoreLabel];
        
        
        /* 话题标签-scrollview */
        _basedScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(100+12+14, 80, _screenWidth-136, 30)];
//        _basedScrollView.backgroundColor =  [UIColor yellowColor];  // ScrollView 背景色，即 View 间的填充色
        _basedScrollView.delegate = self;
        
//        // 循环创建 ScrollView 的 10 个子视图
//        for (int i=0; i<10; i++) {
//            // 创建一个 UILable
//            UILabel *topicLabel = [[UILabel alloc] init];
//            // 设置 UILable 的字号(字号会用来计算label宽度）
//            topicLabel.font = [UIFont fontWithName:@"Helvetica" size: 12.0];
//            topicLabel.textColor = [colorManager lightTextColor];
//            topicLabel.backgroundColor = [UIColor greenColor];
//            
//            // 设置 UILabel 的 frame
//            topicLabel.frame = CGRectMake(i*40, 0, 30, 30);
//            [_basedScrollView addSubview:topicLabel];
//        }
        
        //这个属性很重要，它可以决定是横向还是纵向滚动，一般来说也是其中的 View 的总宽度，和总的高度
        //这里同时考虑到每个 View 间的空隙
        //高度上与 ScrollView 相同，只在横向扩展，所以只要在横向上滚动
        _basedScrollView.contentSize = CGSizeMake(100, 30);
        
        //用它指定 ScrollView 中内容的当前位置，即相对于 ScrollView 的左上顶点的偏移
        _basedScrollView.contentOffset = CGPointMake(0, 0);
        
        //按页滚动，总是一次一个宽度，或一个高度单位的滚动
        _basedScrollView.pagingEnabled = NO;
        
        //隐藏滚动条
        _basedScrollView.showsVerticalScrollIndicator = FALSE;
        _basedScrollView.showsHorizontalScrollIndicator = FALSE;
        
        // 是否边缘反弹
        _basedScrollView.bounces = YES;
        // 不响应点击状态栏的事件（留给uitableview用）
        _basedScrollView.scrollsToTop = NO;
        
        [self.contentView addSubview:_basedScrollView];
        
        
        /* 背景、分割线 */
        UIView *partLine = [[UIView alloc] initWithFrame:CGRectMake(0, 80+30+14-0.5, _screenWidth, 0.5)];
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
    //_hotDegree = [@"人气 " stringByAppendingString:newDegree];
    _hotScoreLabel.text = _hotScore;
}

- (void)rewritePicURL:(NSString *)newPicURL
{
    _picURL = newPicURL;
    [_picImageView sd_setImageWithURL:[NSURL URLWithString:_picURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
}


- (void)rewriteTopics:(NSArray *)newTopicArr
{
    /*对每个cell单独创建scrollview的方式有些费开销，看看有没有更好办法*/
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
