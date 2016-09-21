//
//  SFLoginViewController.h
//  saltfish
//
//  Created by alfred on 16/8/6.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFThirdLoginViewControllerDelegate <NSObject>
@required
- (void)weiboLoginSuccess;
@end

@interface SFThirdLoginViewController : UIViewController
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
- (void)requestForWeiboAuthorize;  // 新浪微博授权请求
- (void)waitForWeiboAuthorizeResult;  // 注册观察者
@property (nonatomic,assign) id <SFThirdLoginViewControllerDelegate> delegate;
@end

