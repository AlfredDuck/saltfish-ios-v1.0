//
//  SFClassificationTableViewCell.m
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFClassificationTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "colorManager.h"


@implementation SFClassificationTableViewCell

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
        _title = @"话题分类";
        self.tag = 999999;
        
        
        /* 顶部分割线 */
        UIView *partLineUp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 15)];
        partLineUp.backgroundColor = [colorManager lightGrayBackground];
        [self.contentView addSubview:partLineUp];
        
        
        /* cell标题 */
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_screenWidth-200)/2.0, 12+15, 200, 20)];
        _titleLabel.text = _title;
        _titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 14.0];
        _titleLabel.textColor = [colorManager mainTextColor];
        _titleLabel.textAlignment = UITextAlignmentCenter;
        [self.contentView addSubview:_titleLabel];
        
        
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

- (void)rewritePics:(NSArray *)newArr
{
    if (_hasPics) {
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
    
    for (int i=0; i<[newArr count]; i++) {
        [[DoubleArr lastObject] addObject:[newArr objectAtIndex:i]];
        if ((i+1)%3 == 0 && (i+1)!=[newArr count]) {    // 每隔3个元素创建一个一维数组，如果是最后一个元素则不创建
            NSMutableArray *singleArr = [[NSMutableArray alloc] init];
            [DoubleArr addObject: singleArr];
        }
    }
    NSLog(@"二维数组：%@", DoubleArr);
    
    NSString *url = @"http://f10.topitme.com/m/201102/14/12976202049513.jpg";
    // 根据设备宽度计算图片宽高
    int ww = ceil((_screenWidth - 11*2 - 16*2)/3.0);
    int hh = ceil(ww/107.0*89);
    
    // 循环创建 imageView
    for (int i=0; i<[DoubleArr count]; i++) {  // 第一层
        for (int j=0; j<[[DoubleArr objectAtIndex:i] count]; j++) {  // 第二层
            
            // 15px的上分割线 + 48px的标题
            UIImageView *picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16+j*(ww+11), 48+15+i*(hh+11), ww, hh)];
            picImageView.backgroundColor = [UIColor grayColor];
            
            // uiimageview居中裁剪
            picImageView.contentMode = UIViewContentModeScaleAspectFill;
            picImageView.clipsToBounds  = YES;
            // 需要AFNetwork
            [picImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            
            // 遮黑
            UIView *halfBlack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ww, hh)];
            halfBlack.backgroundColor  = [UIColor blackColor];
            halfBlack.alpha = 0.22;
            [picImageView addSubview:halfBlack];
            
            // 文本
            UILabel *classificationLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ww, hh)];
            classificationLable.text = [[DoubleArr objectAtIndex:i] objectAtIndex:j];
            classificationLable.textColor  = [UIColor whiteColor];
            classificationLable.font = [UIFont fontWithName:@"Helvetica" size: 15.0f];
            classificationLable.numberOfLines = 3;
            classificationLable.textAlignment = UITextAlignmentCenter;
            // 文字阴影
            classificationLable.layer.shadowOpacity = 0.8;
            classificationLable.layer.shadowColor = [UIColor blackColor].CGColor;
            classificationLable.layer.shadowOffset = CGSizeMake(1.0, 1.0);
            classificationLable.layer.shadowRadius = 1.0;
            [picImageView addSubview:classificationLable];
            
            [self.contentView addSubview:picImageView];
            
        }
    }
    
    /* cell 高度 */
    _cellHeight = (15+48) + [DoubleArr count]*(hh+11) + (5+15);
    /* 底部分割线 */
    _partLine.frame = CGRectMake(0, _cellHeight-15, _screenWidth, 15);
    
    _hasPics = YES;  // 记录已经创建pic矩阵
}





#pragma mark - IBAction


@end
