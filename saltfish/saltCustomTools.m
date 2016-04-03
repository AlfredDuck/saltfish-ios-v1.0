//
//  saltCustomTools.m
//  saltfish
//
//  Created by alfred on 16/4/3.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "saltCustomTools.h"
#import "AFNetworking.h"
#import "urlManager.h"

@implementation saltCustomTools
@end

#pragma mark - 分享成功后，通知server
@implementation shareSuccessNote
- (void)shareSuccessWhichIs:(NSString *)weixinOrWeibo
{
    NSLog(@"啊哈？");
    
    // 准备请求参数
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/article/share_success"];
    NSDictionary *parameters = @{@"share_to": weixinOrWeibo};
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET callback
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        if ([errcode isEqualToString:@"err"]) {
            NSLog(@"share+1,查询或写入出错");
            return;
        }
        NSLog(@"share+1,success");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

@end