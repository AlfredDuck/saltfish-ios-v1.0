//
//  urlManager.h
//  saltfish
//
//  Created by alfred on 16/1/31.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface urlManager : NSObject
+ (NSString *)urlHost;
+ (BOOL)adFeedback;  // 广告反馈开关，不在市场包里开启
+ (BOOL)printToken;  // 微博登录时打印token，方便获取新的token
@end
