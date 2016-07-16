//
//  SFMineViewController.h
//  saltfish
//
//  Created by alfred on 16/7/2.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFTabBarViewController.h"

@interface SFMineViewController : SFTabBarViewController <UIActionSheetDelegate>

@property (nonatomic, strong) UILabel *nickname;  // 未登录时是说明文字，登录后是昵称
// 全局变量 屏幕长宽
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;

+ (void)weiboAuthorizeResult:(BOOL)result uid:(NSString *)uid token:(NSString *)token;   // 新浪微博授权成功后调用
@end
