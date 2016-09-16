//
//  SFShareManager.h
//  saltfish
//
//  Created by alfred on 16/9/15.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFShareManager : UIViewController
// share info （进入页面预先拉取，在内存中缓存）
@property (nonatomic, strong) NSDictionary *shareInfo;
@property (nonatomic, strong) UIImage *shareImageForWeibo;
@property (nonatomic, strong) UIImage *shareImageForWeixin;

/** 拉取分享用的链接、标题、描述和图片等 */
- (void)connectForShareInfoWith:(NSString *)articleID toWhere:(NSString *)where;
/** 分享到微信/朋友圈 */
- (void)shareToWeixinWithTimeLine:(BOOL)isTimeLine;
/** 分享到新浪微博 */
- (void)shareToWeibo;

@end
