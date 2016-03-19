//
//  detailVC.h
//  saltfish
//
//  Created by alfred on 15/12/14.
//  Copyright © 2015年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface detailVC : UIViewController<UIWebViewDelegate>
// 文章id
@property (nonatomic, strong) NSString *articleID;
//
@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic) int loadCount;
// comment button
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UILabel *commentNumLabel;
// praise button
@property (nonatomic, strong) UIButton *praiseButton;
@property (nonatomic, strong) UILabel *praiseNumLabel;
// share button
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UILabel *shareNumLabel;

//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
@end
