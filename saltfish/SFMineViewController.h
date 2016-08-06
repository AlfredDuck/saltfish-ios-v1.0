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
#import "SFPersonalViewController.h"
#import "SFCustomerFeedbackViewController.h"

@interface SFMineViewController : SFTabBarViewController <UIActionSheetDelegate, SFLoginAndSignupDelegate, SFPersonalViewControllerDelegate, SFCustomerFeedbackViewControllerDelegate>

@property (nonatomic, strong) UILabel *nickname;  // 未登录时是说明文字，登录后是昵称
@property (nonatomic, strong) UIView *loginButtonBackground;  // 登录按钮
@property (nonatomic, strong) UIView *portraitBackground;  // 头像
@property (nonatomic, strong) NSString *uid;  // 登录用户id

// 全局变量 屏幕长宽
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
@end
