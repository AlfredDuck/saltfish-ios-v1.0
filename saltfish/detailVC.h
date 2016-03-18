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
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UILabel *commentNumLabel;
//
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;
@end
