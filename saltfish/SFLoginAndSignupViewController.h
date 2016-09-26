//
//  SFLoginAndSignupViewController.h
//  saltfish
//
//  Created by alfred on 16/9/20.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFLoginAndSignupViewController : UIViewController<UITextFieldDelegate>
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;

@property (nonatomic, strong) UITextField *mailTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UITextField *nicknameTextField;
@property (nonatomic, strong) UIView *loginButton;
@property (nonatomic, strong) UILabel *loginLabel;
@property (nonatomic, strong) UIView *signupButton;
@property (nonatomic, strong) UILabel *signupLabel;
@property (nonatomic, strong) UIView *nicknameView;

@end
