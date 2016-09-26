//
//  colorManager.h
//  saltfish
//
//  Created by alfred on 15/12/15.
//  Copyright © 2015年 Alfred. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface colorManager : NSObject
+ (UIColor *)lightGrayLineColor;
+ (UIColor *)lightGrayBackground;
+ (UIColor *)mainTextColor;
+ (UIColor *)secondTextColor;
+ (UIColor *)lightTextColor;
+ (UIColor *)purple;
+ (UIColor *)red;
+ (UIColor *)commentTextColor;
+ (UIColor *)greenGrayBackground;  // 青灰色背景
+ (UIColor *)tabTextColorGray;  // tab文字颜色（灰）
+ (UIColor *)tabTextColorBlack;  // tab文字颜色（黑）
+ (UIColor *)blueLinkColor;  // 蓝色链接文字
+ (UIColor *)blueButtonColor;  // 蓝色按钮
@end
