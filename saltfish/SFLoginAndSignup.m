//
//  SFLoginAndSignup.m
//  saltfish
//
//  Created by alfred on 16/7/16.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFLoginAndSignup.h"
#import "WeiboSDK.h"
#import "AFNetworking.h"
#import "urlManager.h"


@implementation SFLoginAndSignup

- (void)dealloc {
    // uiviewcontroller 释放前会调用
    [[NSNotificationCenter defaultCenter] removeObserver:self];  // 注销观察者
}

#pragma mark - 新浪微博授权请求
- (void)requestForWeiboAuthorize
{
    WBAuthorizeRequest *authorReq = [[WBAuthorizeRequest alloc] init];
    authorReq.redirectURI = @"https://api.weibo.com/oauth2/default.html";
    authorReq.scope = @"";
    authorReq.shouldShowWebViewForAuthIfCannotSSO = YES;
    [WeiboSDK sendRequest:authorReq];
}


#pragma mark - 登录授权成功后，获取用户信息
/* 注册观察者 */
- (void)waitForWeiboAuthorizeResult
{
    // 新浪微博授权成功
    [[NSNotificationCenter defaultCenter] addObserverForName:@"weiboAuthorizeSuccess" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"%@", note.name);
        NSLog(@"%@", note.object);
        
        [self requestForUserInfoWithToken:[note.object objectForKey:@"token"] uid:[note.object objectForKey:@"uid"]];
        
    }];
    
    // 新浪微博授权失败
    [[NSNotificationCenter defaultCenter] addObserverForName:@"weiboAuthorizeFalse" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"%@",note.name);
    }];
}


/* 调用微博的用户信息接口 */
- (void)requestForUserInfoWithToken:(NSString *)token uid:(NSString *)uid
{
    NSString *url = @"https://api.weibo.com/2/users/show.json";
    NSDictionary *param = @{@"access_token":token,
                            @"uid":uid
                            };
    // 请求用户信息
    [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:param queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
        NSLog(@"%@", result);
        NSString *nickname = [result objectForKey:@"name"];
        NSString *portrait = [result objectForKey:@"avatar_large"];
        NSLog(@"用户昵称：%@,%@", nickname, portrait);
        
        NSDictionary *user = @{
                               @"uid":uid,
                               @"nickname":[result objectForKey:@"name"],
                               @"portrait":[result objectForKey:@"avatar_large"]
                               };
        
        // 登录注册
        [self connectForloginOrSignup:user];
        
    }];
}


#pragma mark - 到server登录或注册
- (void)connectForloginOrSignup:(NSDictionary *)userInformation
{
    NSLog(@"登录或注册请求");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/index/weibo_login"];
    
    NSDictionary *parameters = @{
                                 @"uid":[userInformation objectForKey:@"uid"],
                                 @"nickname": [userInformation objectForKey:@"nickname"],
                                 @"portrait": [userInformation objectForKey:@"portrait"]
                                 };
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSDictionary *data = [responseObject objectForKey:@"data"];
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        NSLog(@"errcode：%@", errcode);
        NSLog(@"data:%@", data);
        
        // 新浪微博登录成功后...
        [self weiboLoginSuccess:data];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


#pragma mark - 新浪微博登录成功后...
- (void)weiboLoginSuccess:(NSDictionary *)userData
{
    // 账号信息记录到本地
    NSUserDefaults *sfUserDefault = [NSUserDefaults standardUserDefaults];
    [sfUserDefault setObject:userData forKey:@"loginInfo"];
    // 检查所有 nsuserdefault
    NSArray *allkey = [[sfUserDefault dictionaryRepresentation] allKeys];
    NSLog(@"全部keys：%@", allkey);
    
    // 调用代理方法，通知登录成功
    [self.delegate weiboLoginSuccess];
    
}



@end
