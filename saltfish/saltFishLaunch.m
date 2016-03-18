//
//  saltFishLaunch.m
//  saltfish
//
//  Created by alfred on 16/1/31.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "saltFishLaunch.h"
#import "AFNetworking.h"
#import "urlManager.h"


@interface saltFishLaunch ()
@end


@implementation saltFishLaunch


#pragma mark - Channel Config

/* read channel config from local cache or server */
- (void)basedChannelConfig
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:@"channelConfig"]) {
        // 若本地有频道配置，则检查 server 是否更新了配置，并更新到本地
        NSDictionary *channelConfig = [userDefault objectForKey:@"channelConfig"];
        NSLog(@"频道config缓存：%@", channelConfig);
        
        // 代理返回 config 缓存
        [self.delegate channelConfig:[channelConfig objectForKey:@"channels"]];
        
        // 检查 config 是否有更新（若有更新则用于下次启动）
        [self connectForUpdateConfigWith:[channelConfig objectForKey:@"updateTime"]];
    }
    else {
        // 若本地没有频道配置，则从 server 请求频道配置，并更新到本地
        NSLog(@"没有频道config");
        [self connectForInitConfig];
        
    }
}


/* 初始化 config 请求 */
- (void)connectForInitConfig
{
    // prepare for request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/config"];
    NSDictionary *parameters = @{@"update_time": @"2009-01-01"};
    
    // create GET request
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 8.0;   // 设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET response
        NSString *update = [responseObject objectForKey:@"update"];
        if ([update isEqualToString:@"no"]) {
            NSLog(@"初始华 config 却没有更新，有错误！");
            return;
        }
        NSDictionary *config = [responseObject objectForKey:@"config"];
        
        // 储存频道配置
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:config forKey:@"channelConfig"];
                
        // 使用代理返回
        [self.delegate channelConfig:[config objectForKey:@"channels"]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // NSLog(@"Error: %@", error);
        NSLog(@"config connect err");
        // 使用代理返回
        NSArray *arr = @[@"每日精选", @"娱乐八卦", @"时尚", @"电影", @"内涵",@"二次元"];  // 记得修改哦
        [self.delegate channelConfig:arr];
    }];
}



/* 更新 config 请求 */
- (void)connectForUpdateConfigWith:(NSString *)lastUpdateTime
{
    // prepare for request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/config"];
    NSDictionary *parameters = @{@"update_time": lastUpdateTime};
    
    // create GET request
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET response
        NSString *update = [responseObject objectForKey:@"update"];
        if ([update isEqualToString:@"no"]) {
            NSLog(@"server的config没有更新");
            return;
        }
        NSDictionary *config = [responseObject objectForKey:@"config"];
        
        // 储存频道配置
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:config forKey:@"channelConfig"];
        NSLog(@"已同步server的config");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


#pragma mark - UUID
- (void)basedUUID
{
    /* 每次APP启动，都上传一次uuid，记录设备的来访时间 */
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    // 是否储存uuid
    if ([userDefault objectForKey:@"uuid"]) {
        NSString *localUUID = [userDefault objectForKey:@"uuid"];
        NSLog(@"本地已存在uuid：%@", localUUID);
        [self connectForUploadUUID: localUUID];
        return;
    }
    
    // 生成uuid
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    NSLog(@"生成UUID: %@", result);
    
    // 保存uuid
    [userDefault setObject:result forKey:@"uuid"];
    
    // 上传uuid
    [self connectForUploadUUID:result];
}

- (void)connectForUploadUUID:(NSString *)uuid
{
    // prepare for request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/ios/uuid"];
    NSDictionary *parameters = @{@"uuid": uuid};
    
    // create GET request
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET response
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        if ([errcode isEqualToString:@"err"]) {
            NSLog(@"server出错，上传uuid失败");
            return;
        } else {
            NSLog(@"上传uuid成功");
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}



@end












