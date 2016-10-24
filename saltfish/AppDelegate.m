//
//  AppDelegate.m
//  saltfish
//
//  Created by alfred on 15/12/13.
//  Copyright (c) 2015年 Alfred. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeVC.h"
#import "SFRootViewController.h"
#import "saltCustomTools.h"
#import "WeiboSDK.h"
#import "WXApi.h"
#import "YYWebImage.h"
#import "UIImageView+WebCache.h"

#define iOS8 [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ? 1 : 0
#define kAPPKey        @"3552509555"
#define kRedirectURI   @"http://www.sina.com"
#define WXKey          @"wxd53fa52039cea997"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [NSThread sleepForTimeInterval:1.0];  //   启动等待时间
    // [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;  // 状态栏小菊花
    
    // weibo SDK
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:kAPPKey];
    // weixin SDK 向微信注册
    [WXApi registerApp:WXKey];
    // 设置YY图片缓存的最大内存上限
    YYImageCache *YYcache = [YYWebImageManager sharedManager].cache;
    YYcache.memoryCache.costLimit = 100 * 1024 * 1024;
    YYcache.diskCache.costLimit = 500 * 1024 * 1024;
    
    // 禁用sdimage的内存缓存
    [SDImageCache sharedImageCache].shouldCacheImagesInMemory = NO;
    // sdimage 最大上限
    [SDImageCache sharedImageCache].maxCacheSize = 200 * 1024 * 1024;
    [SDImageCache sharedImageCache].maxMemoryCost = 200 * 1024 * 1024;
    
    // 设置 RootViewController
    SFRootViewController *rootVC = [[SFRootViewController alloc] init];
//    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:rootVC];
//    [navVC setNavigationBarHidden:YES];
    self.window.rootViewController = rootVC;

    return YES;
}

// ios token 参考： http://blog.csdn.net/sky_snow45/article/details/41205201


#pragma mark - weiboSDK & weixinSDK 要求
// 重写AppDelegate 的handleOpenURL和openURL方法
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    // 通过判断url的前缀，决定用哪个
    NSString *string =[url absoluteString];
    NSLog(@"回调url的前缀：%@", string);

    if ([string hasPrefix:@"wb"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }else if ([string hasPrefix:@"wx"]){
        return [WXApi handleOpenURL:url delegate:self];
    }else {
        return NO;
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // 通过判断url的前缀，决定用哪个
    NSString *string =[url absoluteString];
    NSLog(@"回调url的前缀：%@", string);
    
    if ([string hasPrefix:@"wb"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }else if ([string hasPrefix:@"wx"]){
        return [WXApi handleOpenURL:url delegate:self];
    }else {
        return NO;
    }
}



#pragma mark - 微博响应信息，如认证是否成功
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        // 分享到微信的返回值
        if(response.statusCode == 0){
            NSLog(@"新浪微博分享成功！");
            // 告知server端
            shareSuccessNote *note = [[shareSuccessNote alloc] init];
            [note shareSuccessWhichIs:@"weibo"];
        } else if (response.statusCode == -1) {
            NSLog(@"用户取消分享");
        } else if (response.statusCode == -2) {
            NSLog(@"分享失败");
        }
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class]){
        WBAuthorizeResponse *res = (WBAuthorizeResponse *)response;
        NSLog(@"新浪微博授权结果的响应！");
        NSLog(@"userID:%@", res.userID);
        NSLog(@"accessToken:%@", res.accessToken);
        NSLog(@"expirationDate:%@", res.expirationDate);
        NSLog(@"refreshToken%@", res.refreshToken);
        
        // 如果userinfo不为空，则授权成功
        if (res.userID) {
            NSLog(@"授权成功");
            // 创建一个广播：微博授权成功的广播
            NSDictionary *info = @{
                                   @"uid": res.userID,
                                   @"token": res.accessToken
                                   };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"weiboAuthorizeSuccess" object:info];  // 广播出去
        }
        else {
            NSLog(@"授权失败");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"weiboAuthorizeFalse" object:nil];  // 广播出去
        }
    }
}


#pragma mark - 微信的返回信息
- (void)onResp:(BaseResp*)resp
{
    //
    NSLog(@"从微信返回app");
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
        NSLog(@"%@", strMsg);
        // 分享成功 errcode：0
        // 取消分享 errcode: -2
        if (resp.errCode == 0) {
            // 告知server端
            shareSuccessNote *note = [[shareSuccessNote alloc] init];
            [note shareSuccessWhichIs:@"weixin"];
        }
        
    }
}





/********************************/
/********* 暂时用不到的 ***********/
/********************************/
#pragma mark - 以下是暂时用不到的
- (void)applicationWillResignActive:(UIApplication *)application {
   // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
   // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
   // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
   // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
   // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
   // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
   // Saves changes in the application's managed object context before the application terminates.
   [self saveContext];
}




#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "Alfred.com.saltfish" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"saltfish" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"saltfish.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
