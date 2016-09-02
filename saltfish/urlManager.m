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
    return @"http://127.0.0.1:8000";  // 本地测试
    //return @"http://lightnews.online:8000";  // 阿里云测试
    //return @"http://saltfish.news:8080";  // 阿里云正式
}
@end
