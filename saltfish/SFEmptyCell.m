//
//  SFEmptyCell.m
//  saltfish
//
//  Created by alfred on 16/9/1.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFEmptyCell.h"
#import "colorManager.h"

@implementation SFEmptyCell

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
        
        /* 文字 */
        UILabel *txtLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, _screenWidth, 20)];
        txtLabel.text = @"还没有关注任何话题哦";
        txtLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        txtLabel.textColor = [colorManager secondTextColor];
        txtLabel.textAlignment = UITextAlignmentCenter;
        [self.contentView addSubview: txtLabel];
        
        /* 按钮 */
        UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(ceil(_screenWidth/2.0-43), 50, 86, 32)];
        buttonView.backgroundColor = [UIColor colorWithRed:47/255.0 green:175/255.0 blue:239/255.0 alpha:1];
        buttonView.layer.cornerRadius = 5;
        [self.contentView addSubview: buttonView];
        
        UILabel *buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 86, 32)];
        buttonLabel.text = @"随便逛逛";
        buttonLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        buttonLabel.textColor = [UIColor whiteColor];
        buttonLabel.textAlignment = UITextAlignmentCenter;
        [buttonView addSubview: buttonLabel];
        // 点击手势
        buttonView.userInteractionEnabled = YES; // 设置view可以交互
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickIt:)];   // 设置手势
        [buttonView addGestureRecognizer:singleTap]; // 给view添加手势
        
        /* cell 背景色 */
        self.contentView.backgroundColor = [colorManager lightGrayBackground];
        
        // not usefull
        self.frame = CGRectMake(0, 0, 300, 300);
        NSLog(@"%f", self.frame.size.height);
        
    }
    return self;
}


#pragma mark - IBAction
- (void)clickIt:(UIGestureRecognizer *)sender
{
    [self.delegate clickButton];
}



@end
