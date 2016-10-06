//
//  detailVC.h
//  saltfish
//
//  Created by alfred on 15/12/14.
//  Copyright © 2015年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboSDK.h"


// 定义代理
@protocol detailVCDelegate <NSObject>
@required
-(void)refreshReadedStatus;
@end


@interface detailVC : UIViewController<UIWebViewDelegate, WBHttpRequestDelegate, UIActionSheetDelegate>
// 文章id
@property (nonatomic, strong) NSString *articleID;
@property (nonatomic, strong) NSString *uid;  // 登录账户id
@property (nonatomic, strong) NSString *userType;  // 账号类型
@property (nonatomic, strong) NSString *originalLink;
//
@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic) int loadCount;
// comment button
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIView *commentButtonView;
@property (nonatomic, strong) UILabel *commentNumLabel;
// praise button
@property (nonatomic, strong) UIButton *praiseButton;
@property (nonatomic, strong) UIImageView *praiseImageView;
@property (nonatomic, strong) UIView *praiseButtonView;
@property (nonatomic, strong) UILabel *praiseNumLabel;
// like button
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIImageView *likeImageView;
@property (nonatomic, strong) UIView *likeButtonView;
@property (nonatomic, strong) UILabel *likeNumLabel;
// share button
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIView *shareButtonView;
@property (nonatomic, strong) UILabel *shareNumLabel;
// share info （进入页面预先拉取，在内存中缓存）
@property (nonatomic, strong) NSDictionary *shareInfo;
@property (nonatomic, strong) UIImage *shareImageForWeibo;
@property (nonatomic, strong) UIImage *shareImageForWeixin;

// loading flower
@property (nonatomic, strong) UIActivityIndicatorView *loadingFlower;
// 加载进度条（假的进度）
@property (nonatomic, strong) UIView *loadingProgressView;

//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
// 定义代理
@property (nonatomic, assign) id <detailVCDelegate> delegate;

@end
