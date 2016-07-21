//
//  SFCustomerFeedbackViewController.h
//  saltfish
//
//  Created by alfred on 16/7/17.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SFCustomerFeedbackViewControllerDelegate <NSObject>
@required
- (void)sendFeedbackSuccess;
@end

@interface SFCustomerFeedbackViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) NSString *pageTitle;  // 页面标题
@property (nonatomic, strong) UIButton *sendButton;  // 发送按钮

@property (nonatomic, strong) UITextView *contentTextView;  // 评论输入框
@property (nonatomic, strong) UILabel *placeholder;  // 自定义 UITextView 的 placeholder

@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;

@property (nonatomic, assign) id <SFCustomerFeedbackViewControllerDelegate> delegate;

@end
