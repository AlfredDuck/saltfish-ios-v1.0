//
//  SFPersonalViewController.h
//  saltfish
//
//  Created by alfred on 16/7/16.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFPersonalViewControllerDelegate <NSObject>
- (void)signout;
@end

@interface SFPersonalViewController : UIViewController
// 全局变量 屏幕长宽
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;

@property (nonatomic, assign) id <SFPersonalViewControllerDelegate> delegate;
@end
