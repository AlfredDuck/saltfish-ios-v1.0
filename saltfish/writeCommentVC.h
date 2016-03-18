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
// 文章id
@property (nonatomic, strong) NSString *articleID;
//
@property (nonatomic, strong) UIButton *sendButton;
//
@property (nonatomic, strong) UITextField *nickNameTextField;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UILabel *placeholder;  // 自定义 UITextView 的 placeholder
//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
// 定义代理
@property (nonatomic, assign) id <writeCommentViewControllerDelegate> delegate;
@end
