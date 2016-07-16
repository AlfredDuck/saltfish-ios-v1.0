//
//  SFMineViewController.h
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFTabBarViewController.h"
#import "SFLoginAndSignup.h"

@interface SFMineViewController : SFTabBarViewController <UIActionSheetDelegate, SFLoginAndSignupDelegate>

@property (nonatomic, strong) UILabel *nickname;  // 未登录时是说明文字，登录后是昵称
@property (nonatomic, strong) UIView *loginButtonBackground;  // 登录按钮

// 全局变量 屏幕长宽
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
@end
