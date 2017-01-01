//
//  urlManager.m
//  saltfish
//
//  Created by alfred on 16/1/31.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "urlManager.h"

@implementation urlManager
+ (NSString *)urlHost
{
//    return @"http://127.0.0.1:8080";  // 本地测试
//    return @"http://lightnews.online:8000";  // 阿里云测试
    return @"http://lightnews.online:8080";  // 阿里云正式
}

+ (BOOL)adFeedback  // 广告反馈开关，不在市场包里开启
{
//    return YES;  // 开启广告反馈
    return NO;  // 关闭广告反馈
}

+ (BOOL)printToken
{
//    return YES;
    return NO;
}
@end
