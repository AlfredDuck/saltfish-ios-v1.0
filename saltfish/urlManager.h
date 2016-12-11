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
@end
