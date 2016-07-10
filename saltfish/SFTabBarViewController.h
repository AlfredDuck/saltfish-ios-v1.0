//
//  SFTabBarViewController.h
//  saltfish
//
//  Created by alfred on 16/7/10.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * 定义这个vc的目的是让所有第一层级的vc都继承它
 * 主要是为了解决自定义tabbar在push和pop时的隐藏问题
 * 在第一层级的每个VC上都实现tabbar，就避免了在rootVC中tabbar覆盖在二级页面上面的问题
 */

@interface SFTabBarViewController : UIViewController
@property (nonatomic, strong) UIView *tabBarBackgroundView;
// 全局变量 屏幕长宽
@property (nonatomic) NSInteger screenW;
@property (nonatomic) NSInteger screenH;
- (void)createTabBarWith:(int)index;
@end
