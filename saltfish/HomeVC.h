//
//  ViewController.h
//  saltfish
//
//  Created by alfred on 15/12/13.
//  Copyright (c) 2015年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "saltFishLaunch.h"
#import "detailVC.h"

@interface HomeVC : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, launchDelegate, detailVCDelegate>

// 顶部频道区域
@property (nonatomic, strong) UIView *basedChannelsView;
@property (nonatomic, strong) NSArray *channels;  // 频道列表（文本）
@property (nonatomic, strong) UILabel *channelLabel; // 频道label
@property (nonatomic, strong) NSMutableArray *channelsLabelArray; // 频道label列表
@property (nonatomic, strong) UIScrollView *channelScrollView;   // 顶部scrollview
@property (nonatomic, strong) UIView *focusView;  // 紫色焦点

// 下方内容区域
@property (nonatomic, strong) UIScrollView *contentScrollView;  // 内容scrollview
@property (nonatomic, strong) UITableView *contentListTableView;  // 内容tableview
@property (nonatomic, strong) NSMutableDictionary *contentListDataSource;  // 内容tableview数据源

// 全局变量
@property (nonatomic) unsigned long currentChannel;  // 当前频道，相当于channels的index，从0开始计

// 其他全局变量
@property (nonatomic) NSInteger screenWidth;
@property (nonatomic) NSInteger screenHeight;

// 小菊花
@property (nonatomic, strong) UIActivityIndicatorView *loadingFlower;
@property (nonatomic, strong) UILabel *loadingTextLabel;

// 重新加载按钮
@property (nonatomic, strong) UIButton *reloadButton;

@end

