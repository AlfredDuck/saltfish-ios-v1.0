//
//  SFEmptyCell.h
//  saltfish
//
//  Created by alfred on 16/9/1.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFEmptyCellDelegate <NSObject>
@required
- (void)clickButton;
@end

@interface SFEmptyCell : UITableViewCell
//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
//
@property (nonatomic, assign) id <SFEmptyCellDelegate> delegate;
@end
