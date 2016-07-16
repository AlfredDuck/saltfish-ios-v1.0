//
//  SFLoginAndSignup.h
//  saltfish
//
//  Created by alfred on 16/7/16.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SFLoginAndSignupDelegate <NSObject>
@required
- (void)weiboLoginSuccess;
@end

@interface SFLoginAndSignup : NSObject
- (void)requestForWeiboAuthorize;  // 新浪微博授权请求
- (void)waitForWeiboAuthorizeResult;  // 注册观察者

@property (nonatomic,assign) id <SFLoginAndSignupDelegate> delegate;
@end
