//
//  writeCommentVC.h
//  saltfish
//
//  Created by alfred on 15/12/27.
//  Copyright © 2015年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

// 定义代理
@protocol writeCommentViewControllerDelegate <NSObject>
@required
-(void)writeCommentSuccess;
@end

@interface writeCommentVC : UIViewController <UITextViewDelegate>
@property (nonatomic, strong) NSString *pageTitle;  // 页面标题
@property (nonatomic, strong) NSString *articleID;  // 要评论的文章id
@property (nonatomic, strong) UIButton *sendButton;  // 发送按钮

@property (nonatomic, strong) UITextView *contentTextView;  // 评论输入框
@property (nonatomic, strong) UILabel *placeholder;  // 自定义 UITextView 的 placeholder

@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
// 定义代理
@property (nonatomic, assign) id <writeCommentViewControllerDelegate> delegate;
@end
