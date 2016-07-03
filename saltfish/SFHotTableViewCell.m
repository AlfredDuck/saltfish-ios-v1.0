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
        
        
        /* =========== 焦点图 ============== */
        
        _basedScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, _screenWidth, 170)];
        _basedScrollView.backgroundColor = [UIColor grayColor];
        
        //这个属性很重要，它可以决定是横向还是纵向滚动，一般来说也是其中的 View 的总宽度，和总的高度
        //这里同时考虑到每个 View 间的空隙，所以宽度是 200x3＋5＋10＋10＋5＝630
        //高度上与 ScrollView 相同，只在横向扩展，所以只要在横向上滚动
        _basedScrollView.contentSize = CGSizeMake(_screenWidth*3, 170);
        //用它指定 ScrollView 中内容的当前位置，即相对于 ScrollView 的左上顶点的偏移
        _basedScrollView.contentOffset = CGPointMake(0, 0);
        //按页滚动，总是一次一个宽度，或一个高度单位的滚动
        _basedScrollView.pagingEnabled = YES;
        //隐藏滚动条
        _basedScrollView.showsVerticalScrollIndicator = FALSE;
        _basedScrollView.showsHorizontalScrollIndicator = FALSE;
        // 是否边缘反弹
        _basedScrollView.bounces = NO;
        // 不响应点击状态栏的事件（留给uitableview用）
        _basedScrollView.scrollsToTop = NO;
        
        [self.contentView addSubview:_basedScrollView];

        
        
        /* 背景、分割线 */
        _partLine = [[UIView alloc] initWithFrame:CGRectMake(0, 360-15, _screenWidth, 15)];
        _partLine.backgroundColor = [colorManager lightGrayBackground];
        [self.contentView addSubview: _partLine];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        
        // not usefull
        self.frame = CGRectMake(0, 0, 300, 300);
        NSLog(@"%f", self.frame.size.height);
        
    }
    return self;
}



#pragma mark - 重写 cell 中各个元素的数据
- (void)rewriteHotArticles:(NSArray *)newArr
{
    // 循环创建轮播的图片
    for (int i=0; i<3; i++) {
        
        UIImageView *picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_screenWidth*i, 0, _screenWidth, 170)];
        picImageView.backgroundColor = [UIColor grayColor];
        
        // uiimageview居中裁剪
        picImageView.contentMode = UIViewContentModeScaleAspectFill;
        picImageView.clipsToBounds  = YES;
        // 需要AFNetwork
        [picImageView sd_setImageWithURL:[NSURL URLWithString:[[newArr objectAtIndex:i] objectForKey:@"url"]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        
        // 遮黑
        UIView *halfBlack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 170)];
        halfBlack.backgroundColor  = [UIColor blackColor];
        halfBlack.alpha = 0.22;
        [picImageView addSubview:halfBlack];
        
        // 文本
        UILabel *picLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 0, _screenWidth-54*2, 170)];
        picLabel.text = [[newArr objectAtIndex:i] objectForKey:@"title"];
        picLabel.textColor  = [UIColor whiteColor];
        picLabel.font = [UIFont fontWithName:@"Helvetica" size: 18.0f];
        picLabel.numberOfLines = 2;
        picLabel.textAlignment = UITextAlignmentCenter;
        // 文字阴影
        picLabel.layer.shadowOpacity = 0.8;
        picLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        picLabel.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        picLabel.layer.shadowRadius = 1.0;
        [picImageView addSubview:picLabel];
        
        [_basedScrollView addSubview:picImageView];
    }

}





@end
