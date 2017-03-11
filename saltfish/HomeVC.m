//
//  ViewController.m
//  saltfish
//
//  Created by alfred on 15/12/13.
//  Copyright (c) 2015年 Alfred. All rights reserved.
//

#import "HomeVC.h"
#import "bigPicTableViewCell.h"
#import "smallPicTableViewCell.h"
#import "picBasedTableViewCell.h"
#import "detailVC.h"
#import "colorManager.h"
#import "urlManager.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "saltFishLaunch.h"
#import "toastView.h"
#import "WeiboSDK.h"

#import "TopicVC.h"
#import "ClassificationVC.h"


@interface HomeVC ()
// 此处定义私有全局变量（不暴漏给外部使用）

/* 管理 状态栏点击事件响应者
 * 1.每次创建一个tableview时
 * 2.每次切换tableview时
 *
 */
@property (nonatomic, strong) NSMutableDictionary *scrollsToTopManager;

// 网络请求状态标志
@property (nonatomic, assign) NSString *configConnectStatus;

@end



@implementation HomeVC

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//   self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//   if (self) {
//      // Custom initialization
//      self.title = @"saltfish";
//   }
//   return self;
//}

// 修改状态栏色值
// 在你自己的UIViewController里重写此方法，返回你需要的值(UIStatusBarStyleDefault 或者 UIStatusBarStyleLightContent)；
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
    //return  UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化一些全局变量
    _currentChannel = 0;
    _scrollsToTopManager = [NSMutableDictionary dictionaryWithCapacity:100];
    //
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    NSLog(@"screen size: %ld,%ld", (long)_screenHeight, (long)_screenWidth);
    
    // 读取频道配置（阻塞式）
    [self channelConfigUpdate];
    
    // 上传 uuid
    saltFishLaunch *launch = [[saltFishLaunch alloc] init];
    [launch basedUUID];
}

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
}




#pragma mark - 更新频道配置 channel config
- (void)channelConfigUpdate
{
    saltFishLaunch *launch = [[saltFishLaunch alloc] init];
    launch.delegate = self;
    [launch basedChannelConfig];
}

/* config 代理 */
- (void)channelConfig:(NSArray *)channels
{
    NSLog(@"代理返回的channels： %@", channels);
    // 初始化channels
    _channels = channels;
    
    /*怎么说呢，iOS7以后，如果scrollview直接做navigationcontroller的第一个子视图
     系统会自动添加偏移，跟顶部导航栏有关系，把这个属性关掉就可以了（神坑啊）*/
    self.automaticallyAdjustsScrollViewInsets = NO;
        
    // 基础构建初始化
    [self basedChannels];
    [self basedScrollView];
    [self basedTableViewDataSource];
    
    // 从缓存加载first channel
    [self createFirstChannelFromDataShop];
    
    [self.view bringSubviewToFront:_basedChannelsView];  // 放在最上层(要在所有子视图加载后)
}






#pragma mark - 数据外壳（字典）

// 初始化 tablView 基础数据(字典壳子）
- (void)basedTableViewDataSource
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    _contentListDataSource = [dic mutableCopy];
    dic = nil;
    
    // 根据频道名初始化基础数据
    for (NSString *channelString in _channels) {
        [_contentListDataSource setObject:@"..." forKey:channelString];
    }
    
    // NSLog(@"初始化频道数据：%@",_contentListDataSource);
}




#pragma mark - 从缓存加载first channel
- (void)createFirstChannelFromDataShop
{
    // 读取缓存
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults arrayForKey:@"dataShop"]) {
        NSArray *data = [userDefaults arrayForKey:@"dataShop"];
        NSLog(@"读取缓存first channel");
        
        // 向 DataSource 字典灌注数据
        [_contentListDataSource setObject:data forKey:[_channels objectAtIndex: 0]];
        
        // 并 初始化 first TableView
        UITableView *tableView = [self basedContentTableView: 0];
        [[_contentScrollView viewWithTag: 1] addSubview:tableView];
        
    }
    else {
        NSLog(@"无 first channel 的缓存");
        [self connectForHomeWithChannel:(long)0];
    }
}






#pragma mark - 顶部频道区（各种频道）

- (void)basedChannels {
    // 频道背景
    _basedChannelsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 64)];
    
    // 频道背景的渐变遮黑
    UIImage *blackImage = [UIImage imageNamed:@"black_top3.png"]; // 使用ImageView通过name找到图片
    UIImageView *oneImageView = [[UIImageView alloc] initWithImage:blackImage]; // 把oneImage添加到oneImageView上
    oneImageView.frame = CGRectMake(0, 0, _screenWidth, 90); // 设置图片位置和大小
    UIImageView *twoImageView = [[UIImageView alloc] initWithImage:blackImage]; // 把oneImage添加到oneImageView上
    twoImageView.frame = CGRectMake(0, 0, _screenWidth, 85); // 设置图片位置和大小
    twoImageView.alpha = 0.6;
    [_basedChannelsView addSubview:oneImageView];
    [_basedChannelsView addSubview:twoImageView];
    
    [self.view addSubview:_basedChannelsView];
    
    
    // 频道在scrollview基础上
    _channelScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, _screenWidth, 30)];
    
    // 频道文本区域的总长度
    unsigned long allLengthOfChannels = 0;  // 初始化
    
    // 设置各个频道的frame
    _channelsLabelArray = [[NSMutableArray alloc] init];
    for (int i=0; i<[_channels count]; i++) {
        NSString *channelText = [_channels objectAtIndex:i];
        UILabel *channelLabel = [[UILabel alloc] init];
        channelLabel.textAlignment = NSTextAlignmentCenter;
        channelLabel.text = channelText;
        channelLabel.tag = i+1;
        
        if (i == 0) {
            channelLabel.textColor = [UIColor whiteColor];
            channelLabel.font = [UIFont fontWithName:@"Helvetica Bold" size: 15];
            // 文字阴影
            channelLabel.shadowColor = [UIColor blackColor];
            channelLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        } else {
            channelLabel.font = [UIFont fontWithName:@"Helvetica" size: 15];
            channelLabel.textColor = [colorManager lightTextColor];
        }
        
        // 添加到 label 数组
        [_channelsLabelArray addObject:channelLabel];
        
        // channelLabel 的 frame
        unsigned long x = 0;
        for (int j=0; j<=i-1; j++) {
            NSString *txt = [_channels objectAtIndex:j];
            x = x + (unsigned long)txt.length*14 + 6 + 12;  // text后面留n px的间隔
        }
        
        unsigned long length = channelText.length;
        unsigned long w = length*14 + 6;
        channelLabel.frame = CGRectMake(9+x, 0, w, 30);
        allLengthOfChannels = 9+x+w+9;    // 修正
        
        // 频道 label 添加点击事件
        // 一定要先将userInteractionEnabled置为YES，这样才能响应单击事件
        channelLabel.userInteractionEnabled = YES; // 设置图片可以交互
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickChannelTab:)]; // 设置手势
        [channelLabel addGestureRecognizer:singleTap];

        [_channelScrollView addSubview:channelLabel];
    }
    
    // 焦点光标（紫色小条）初始化
    _focusView = [[UIView alloc] init];
    _focusView.backgroundColor = [colorManager purple];
    UIView *v = [_channelScrollView viewWithTag:1];
    _focusView.frame = CGRectMake(9, 30-3, v.frame.size.width, 3);
    [_channelScrollView addSubview:_focusView];
    
    //这个属性很重要，它可以决定是横向还是纵向滚动，一般来说也是其中的 View 的总宽度，和总的高度
    //这里同时考虑到每个 View 间的空隙，所以宽度是 200x3＋5＋10＋10＋5＝630
    //高度上与 ScrollView 相同，只在横向扩展，所以只要在横向上滚动
    _channelScrollView.contentSize = CGSizeMake(allLengthOfChannels, 30);
    
    //用它指定 ScrollView 中内容的当前位置，即相对于 ScrollView 的左上顶点的偏移
    _channelScrollView.contentOffset = CGPointMake(0, 0);
    
    //按页滚动，总是一次一个宽度，或一个高度单位的滚动
    //scrollView.pagingEnabled = YES;
    
    //隐藏滚动条
    _channelScrollView.showsVerticalScrollIndicator = FALSE;
    _channelScrollView.showsHorizontalScrollIndicator = FALSE;
    
    // 是否边缘反弹
    _channelScrollView.bounces = YES;
    // 不响应点击状态栏的事件（留给uitableview用）
    _channelScrollView.scrollsToTop =NO;
    
    [_basedChannelsView addSubview:_channelScrollView];
}






#pragma mark - ScrollView (下方的，横向)

- (void)basedScrollView
{
    //设定 ScrollView 的 Frame，逐页滚动时，如果横向滚动，按宽度为一个单位滚动，纵向时，按高度为一个单位滚动
    _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    _contentScrollView.backgroundColor = [UIColor lightGrayColor]; // ScrollView 背景色，即 View 间的填充色
    _contentScrollView.delegate = self;
    
    // 循环创建 ScrollView 的各个子视图
    for (int i=0; i<[_channels count]; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(_screenWidth * i, 0, _screenWidth, _screenHeight)];
        view.backgroundColor = [UIColor whiteColor];
        view.tag = i+1;
        
//        // 定位用的，上线注掉
//        UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(_screenWidth/2.0 - 100, 400, 200, 100)];
//        t.font = [UIFont fontWithName:@"Helvetica Bold" size: 14];
//        t.textAlignment = NSTextAlignmentCenter;
//        t.textColor = [UIColor whiteColor];
//        t.text = [_channels objectAtIndex:i];
//        t.backgroundColor = [UIColor blackColor];
//        [view addSubview:t];
        
        [_contentScrollView addSubview:view];
    }

    //这个属性很重要，它可以决定是横向还是纵向滚动，一般来说也是其中的 View 的总宽度，和总的高度
    //这里同时考虑到每个 View 间的空隙，所以宽度是 200x3＋5＋10＋10＋5＝630
    //高度上与 ScrollView 相同，只在横向扩展，所以只要在横向上滚动
    _contentScrollView.contentSize = CGSizeMake(_screenWidth*[_channels count], _screenHeight);

    //用它指定 ScrollView 中内容的当前位置，即相对于 ScrollView 的左上顶点的偏移
    _contentScrollView.contentOffset = CGPointMake(0, 0);

    //按页滚动，总是一次一个宽度，或一个高度单位的滚动
    _contentScrollView.pagingEnabled = YES;

    //隐藏滚动条
    _contentScrollView.showsVerticalScrollIndicator = FALSE;
    _contentScrollView.showsHorizontalScrollIndicator = FALSE;

    // 是否边缘反弹
    _contentScrollView.bounces = NO;
    // 不响应点击状态栏的事件（留给uitableview用）
    _contentScrollView.scrollsToTop = NO;

    [self.view addSubview:_contentScrollView];
}





#pragma mark - ScrollView 代理方法

// scrollview 减速停止
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_contentScrollView]) {   // 因为VC中存在各种 ScrollView TableView 所以要指定到某个view
        NSLog(@"ScrollView 减速停止");
        NSLog(@"ScrollView偏移：%f", _contentScrollView.contentOffset.x);
        
        // 修改频道区焦点
        NSInteger focus = _contentScrollView.contentOffset.x / _screenWidth;
        NSLog(@"焦点在第%ld个", (long)focus);
        _currentChannel = focus;
        NSLog(@"切换到第%ld个channel", _currentChannel);
        UIView *v = [_channelScrollView viewWithTag:focus + 1];
        
        // uiview 动画（无需实例化）
        [UIView animateWithDuration:0.15 animations:^{
            // 修改处于焦点的 channelLabel 的样式
            UILabel *cl;
            for (cl in _channelsLabelArray) {
                cl.textColor = [colorManager lightTextColor];
                cl.font = [UIFont fontWithName:@"Helvetica" size: 15];
                // 文字阴影
                cl.shadowColor = nil;
                cl.shadowOffset = CGSizeMake(0.5, 0.5);
            }
            UILabel *currentLabel = [_channelsLabelArray objectAtIndex:focus];
            currentLabel.textColor = [UIColor whiteColor];
            currentLabel.font = [UIFont fontWithName:@"Helvetica Bold" size: 15];
            // 文字阴影
            currentLabel.shadowColor = [colorManager mainTextColor];
            currentLabel.shadowOffset = CGSizeMake(0.5, 0.5);
            
            // 修改紫色焦点位置 (动画)
            _focusView.frame = CGRectMake(v.frame.origin.x, 27, v.frame.size.width, 3);
            
            // 修改 顶部scrollview 的偏移 (真心觉得以后会看不懂)
            long middleOfChannelTab = v.frame.origin.x + v.frame.size.width/2.0;
            long offset = middleOfChannelTab - _screenWidth/2.0;
            
            if (_channelScrollView.contentSize.width >= _screenWidth){
                if (offset >= 0 && offset <= _channelScrollView.contentSize.width - _screenWidth) {
                    offset = offset;
                    NSLog(@"情况一");
                }
                else if (offset < 0) {
                    offset = 0;
                    NSLog(@"情况二");
                }
                else if (offset > _channelScrollView.contentSize.width - _screenWidth) {
                    offset = _channelScrollView.contentSize.width - _screenWidth;
                    NSLog(@"情况三");
                }
                _channelScrollView.contentOffset = CGPointMake(offset, 0);
            }
        }];
        
        // 响应状态栏事件
        for (NSString *key in _scrollsToTopManager) {
            NSLog(@"响应状态栏事件的channel：%@", key);
            UITableView *tv = _scrollsToTopManager[key];
            tv.scrollsToTop = NO;
        }
        
        //NSLog(@"%@", _channels);
        NSLog(@"%lu", _currentChannel);
        NSString *channelString = _channels[_currentChannel];
        if (_scrollsToTopManager[channelString]) {
            UITableView *tv = _scrollsToTopManager[channelString];
            tv.scrollsToTop = YES;
        }
        
        
        // 每次切换时，检查是否需要加载 tableView
        UIView *sub = [_contentScrollView viewWithTag:_currentChannel + 1];
        BOOL isThereTableView = NO;
        for (UIView *view in sub.subviews) {
            if ([view isKindOfClass:[UITableView class]]) {
                NSLog(@"这个频道已经存在tableview + 1，tag=%ld",(long)view.tag);
                isThereTableView = YES;
            }
        }
        if (!isThereTableView) {
            [self connectForHomeWithChannel:_currentChannel];
        }
    }
}






#pragma mark - loading 动画
- (void)showLoadingOn:(UIView *)boardView
{
    if (boardView.tag) {
        NSLog(@"tag:%ld", (long)boardView.tag);
    }
    
    // 清空 boardView 的所有子view
    for (UIView *sub in boardView.subviews){
        [sub removeFromSuperview];
    }
    
    // 小菊花
    _loadingFlower = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingFlower.frame = CGRectMake(_screenWidth/2-25, _screenHeight/2-25, 50, 50);
    [_loadingFlower startAnimating];
    //[_loadingFlower stopAnimating];
    [boardView addSubview:_loadingFlower];
    
    // 加载中...
    _loadingTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(_screenWidth/2.0 - 100, _screenHeight/2+ 18, 200, 20)];
    _loadingTextLabel.font = [UIFont fontWithName:@"Helvetica" size: 13];
    _loadingTextLabel.textAlignment = NSTextAlignmentCenter;
    _loadingTextLabel.textColor = [colorManager lightTextColor];
    _loadingTextLabel.text = @"奴婢正在加载...";
    [boardView addSubview:_loadingTextLabel];
    
    // n秒未加载成功，则
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    });
    
}

- (void)showReloadButtonOn:(UIView *)boardView
{
    // 清空 boardView 的所有子view
    for (UIView *sub in boardView.subviews){
        [sub removeFromSuperview];
    }
    
    // 重新加载按钮
    _reloadButton = [[UIButton alloc] initWithFrame:CGRectMake(_screenWidth/2.0 - 100, _screenHeight/2+ 18, 200, 20)];
    [_reloadButton setTitle:@"重新加载" forState:UIControlStateNormal];
    _reloadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [_reloadButton setTitleColor:[colorManager lightTextColor] forState:UIControlStateNormal];
    _reloadButton.backgroundColor = [UIColor whiteColor];
    _reloadButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    [_reloadButton addTarget:self action:@selector(clickReloadButtonOn:) forControlEvents:UIControlEventTouchUpInside];
    [boardView addSubview:_reloadButton];
}




#pragma mark - IBAction

// 点击频道标签
- (void)clickChannelTab:(UIGestureRecognizer *)sender
{
    UIView *v = [sender view];  // 获取手势动作的父视图
    NSLog(@"点击频道标签%ld", (long)v.tag);
    _currentChannel = (long)v.tag - 1;
    NSLog(@"切换到第%lu个channel", _currentChannel);
    NSLog(@"%f", v.frame.origin.x);
    
    // 修改频道标签
    [UIView animateWithDuration:0.15 animations:^{  // uiview 动画（无需实例化）
        // 修改处于焦点的 channelLabel 的样式
        UILabel *cl;
        for (cl in _channelsLabelArray) {
            cl.textColor = [colorManager lightTextColor];
            cl.font = [UIFont fontWithName:@"Helvetica" size: 15];
            // 文字阴影
            cl.shadowColor = nil;
            cl.shadowOffset = CGSizeMake(0.5, 0.5);
        }
        UILabel *currentLabel = [_channelsLabelArray objectAtIndex:(v.tag - 1)];
        currentLabel.textColor = [UIColor whiteColor];
        currentLabel.font = [UIFont fontWithName:@"Helvetica Bold" size: 15];
        // 文字阴影
        currentLabel.shadowColor = [colorManager mainTextColor];
        currentLabel.shadowOffset = CGSizeMake(0.5, 0.5);

        // 修改紫色焦点位置 (动画)
        _focusView.frame = CGRectMake(v.frame.origin.x, 27, v.frame.size.width, 3);
        
        // 修改 顶部scrollview 的偏移 (真心觉得以后会看不懂)
        long middleOfChannelTab = v.frame.origin.x + v.frame.size.width/2.0;
        long offset = middleOfChannelTab - _screenWidth/2.0;
        
        if (_channelScrollView.contentSize.width >= _screenWidth){
            if (offset >= 0 && offset <= _channelScrollView.contentSize.width - _screenWidth) {
                offset = offset;
                NSLog(@"情况一");
            }
            else if (offset < 0) {
                offset = 0;
                NSLog(@"情况二");
            }
            else if (offset > _channelScrollView.contentSize.width - _screenWidth) {
                offset = _channelScrollView.contentSize.width - _screenWidth;
                NSLog(@"情况三");
            }
            _channelScrollView.contentOffset = CGPointMake(offset, 0);
        }
    }];
    
    // 修改下方 ScrollView 的偏移
    [UIView animateWithDuration:0.3 animations:^{
        _contentScrollView.contentOffset = CGPointMake(_screenWidth * _currentChannel, 0);
    }];
    
    
    // 响应状态栏事件
    for (NSString *key in _scrollsToTopManager) {
        NSLog(@"嘻嘻嘻嘻嘻嘻嘻嘻嘻：%@", key);
        UITableView *tv = _scrollsToTopManager[key];
        tv.scrollsToTop = NO;
    }
    
    NSString *channelString = _channels[_currentChannel];
    if (_scrollsToTopManager[channelString]) {
        UITableView *tv = _scrollsToTopManager[channelString];
        tv.scrollsToTop = YES;
    }
    
    
    // 每次切换时，检查是否需要加载 tableView
    UIView *sub = [_contentScrollView viewWithTag:_currentChannel + 1];
    BOOL isThereTableView = NO;
    for (UIView *views in sub.subviews) {
        if ([views isKindOfClass:[UITableView class]]) {
            NSLog(@"这个频道已经存在tableview + 1");
            isThereTableView = YES;
        }
    }
    if (!isThereTableView) {
        [self connectForHomeWithChannel:_currentChannel];
    }
    
    // 使当前 TableView 响应点击状态栏的事件
    // contentTableView.scrollsToTop = YES;
}

// 点击重新加载按钮
- (void)clickReloadButtonOn:(UIView *)sender
{
    UIView *boardView = [sender superview];
    NSLog(@"boardview tag:%ld", (long)boardView.tag);
    
    // 清空 boardView 的所有子view
    for (UIView *sub in boardView.subviews){
        [sub removeFromSuperview];
    }
    
    // 发起网络请求
    [self connectForHomeWithChannel:boardView.tag - 1];
}





#pragma mark - 列表缓存
// 使用 nsuserDefaults 做简单缓存，只缓存首页的第一个列表的前20项

// 写入缓存
- (void)writeDataShopWith:(NSArray *)data
{
    // 准备要缓存的数据
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:data forKey:@"dataShop"];
    NSLog(@"写入缓存完成");
}






#pragma mark - 网络请求

/* 初始化频道列表请求 */
- (void)connectForHomeWithChannel:(long)channelIndex
{
    // 获取 scrollview 中要加载内容的当前view
    UIView *currentView = [_contentScrollView viewWithTag:channelIndex + 1];
    
    // 显示loading
    [self showLoadingOn:currentView];
    
    // 准备请求参数
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/list"];
    
    NSString *channelString = [_channels objectAtIndex:channelIndex];
    NSDictionary *parameters = @{@"channel": channelString, @"type": @"refresh"};
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // NSLog(@"JSON: %@", responseObject); // AF 已将json转为字典
        
        // GET请求返回结果
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        if ([errcode isEqualToString:@"err"]) {
            // 连接正常，但后台查询数据出错
            NSLog(@"后台查询数据出错,请重试");
            [self showReloadButtonOn:currentView];
            return;
        }
        NSArray *data = [responseObject objectForKey:@"data"];
        NSString *channel = [responseObject objectForKey:@"channel"];
        // NSLog(@"返回的数据：%@", [data objectAtIndex:0]);
        
        // 向 DataSource 字典灌注数据
        [_contentListDataSource setObject:data forKey:channel];
        
        // 并 初始化一个 TableViews
        UITableView *tableView = [self basedContentTableView:channelIndex];
        [currentView addSubview:tableView];
        
        // 若是first channel，则写入缓存
        if (channelIndex == (long)0){
            [self writeDataShopWith:data];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"连接出错 or 超时");
        [self showReloadButtonOn:currentView];
    }];
}


/* 下拉刷新请求 */
- (void)connectForRefresh:(UITableView *)tableView
{
    NSLog(@"下拉刷新开始");
    
    // prepare request parameters
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/list"];
    
    long index = tableView.tag - 1;
    NSString *channelString = [_channels objectAtIndex:index];
    NSDictionary *parameters = @{@"channel": channelString, @"type": @"refresh"};
    
    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSArray *data = [responseObject objectForKey:@"data"];
        NSString *channel = [responseObject objectForKey:@"channel"];
        NSLog(@"下拉刷新channel：%@", channel);
        
        // 更新 dataSource 字典
        [_contentListDataSource setObject:data forKey:channel];

        // 刷新当前 tableview 的数据
        [tableView reloadData];
        NSLog(@"刷新 tableview：%@", channel);
        
        // 结束刷新动作
        [tableView.mj_header endRefreshing];
        NSLog(@"下拉刷新成功，结束刷新");
        
        // 若是first channel，则写入缓存
        if (index == (long)0){
            [self writeDataShopWith:data];
        }
        
        // 重置 la fin 状态
        [tableView.mj_footer resetNoMoreData];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        // 结束刷新动作
        [tableView.mj_header endRefreshing];
        NSLog(@"下拉刷新失败，结束刷新");
    }];
}


/* 上拉加载更多请求 */
- (void)connectForLoadMore:(UITableView *)tableView
{
    // 准备请求参数
    NSString *host = [urlManager urlHost];
    NSString *urlString = [host stringByAppendingString:@"/list"];
    
    long index = tableView.tag - 1;
    NSString *channelString = [_channels objectAtIndex:index];
    
    // 获取最后一个cell的id
    NSArray *currentTableViewData = [_contentListDataSource objectForKey:channelString];
    NSString *lastid = [[currentTableViewData lastObject] objectForKey:@"_id"];
    NSString *postTime = [[currentTableViewData lastObject] objectForKey:@"postTime"];
    NSLog(@"最后一个cell的id：%@",lastid);
    
    NSDictionary *parameters = @{
                                 @"channel": channelString,
                                 @"type": @"loadmore",
                                 @"last_id":lastid,
                                 @"post_time":postTime
                                 };

    // 创建 GET 请求
    AFHTTPRequestOperationManager *connectManager = [AFHTTPRequestOperationManager manager];
    connectManager.requestSerializer.timeoutInterval = 20.0;   //设置超时时间
    [connectManager GET:urlString parameters: parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // GET请求成功
        NSString *errcode = [responseObject objectForKey:@"errcode"];
        if ([errcode isEqualToString:@"err"]) {
            NSLog(@"loadmore没有更多数据了");
            // 结束加载更多
            // [tableView.mj_footer endRefreshing];
            [tableView.mj_footer endRefreshingWithNoMoreData];

            /* 自己写的 nomoreData 的实现，/(ㄒoㄒ)/~~ */
//            double h = tableView.contentSize.height;
//            double y = tableView.contentOffset.y;
//            NSLog(@";;;;;;;;;;;;%f", h);
//            NSLog(@";;;;;;;;;;;;%f", y);
//            
//            // 禁用mjRefresh
//            tableView.mj_footer = nil;
//            
//            tableView.contentOffset = CGPointMake(0, y);
//            // tableView.contentInset = UIEdgeInsetsMake(0, 0, 45, 0); // 设置距离顶部的一段偏移，继承自scrollview
//            
//            UILabel *noMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 45)];
//            noMoreLabel.font = [UIFont fontWithName:@"Helvetica" size: 13.5];
//            noMoreLabel.textAlignment = NSTextAlignmentCenter;
//            noMoreLabel.textColor = [colorManager lightTextColor];
//            noMoreLabel.text = @"~ la fin ~";
//            tableView.tableFooterView = noMoreLabel;

            return;
        }
        
        NSArray *addData = [responseObject objectForKey:@"data"];
        NSString *channel = [responseObject objectForKey:@"channel"];
        NSLog(@"加载更多channel：%@", channel);
        
        // 更新 dataSource 字典
        NSMutableArray *data = [[_contentListDataSource objectForKey:channel] mutableCopy];
        [data addObjectsFromArray:addData];
        [_contentListDataSource setObject:data forKey:channel];
        
        // 刷新当前 tableview 的数据
        [tableView reloadData];
        NSLog(@"加载更多tableview：%@", channel);
        
        // 结束加载更多
        [tableView.mj_footer endRefreshing];
        NSLog(@"加载更多成功，结束加载");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        // 结束加载更多
        [tableView.mj_footer endRefreshing];
        NSLog(@"加载更多失败，结束加载");
    }];
}







#pragma mark - 自定义代理
- (void)refreshReadedStatus
{
    // 获取当前tableview
    NSLog(@"%lu", _currentChannel);
    NSString *channelString = _channels[_currentChannel];
    if (_scrollsToTopManager[channelString]) {
        UITableView *tv = _scrollsToTopManager[channelString];
        [tv reloadData];
    }
}







/********************************/
/***** uitableview *******/
/********************************/

#pragma mark - 创建 TableView

- (UITableView *)basedContentTableView:(long)index
{
    //
    NSString *channelStr = _channels[index];
    NSString *CellWithIdentifier = [@"tableview" stringByAppendingString:channelStr];
    // static NSString *CellWithIdentifier = @"small";
    
    UITableView *contentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    [contentTableView setDelegate:self];
    [contentTableView setDataSource:self];
    
    [contentTableView registerClass:[smallPicTableViewCell class] forCellReuseIdentifier:CellWithIdentifier];
    contentTableView.backgroundColor = [colorManager lightGrayBackground];
    contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone; // 去掉分割线
    // contentTableView.contentInset = UIEdgeInsetsMake(14, 0, 0, 0); // 设置距离顶部的一段偏移，继承自scrollview
    contentTableView.tag = index + 1;
    
    
    // 响应状态栏事件
    [_scrollsToTopManager setObject:contentTableView forKey:[_channels objectAtIndex:index]];
    for (NSString *key in _scrollsToTopManager) {
        NSLog(@"响应状态栏事件的频道：%@", key);
        UITableView *tv = _scrollsToTopManager[key];
        tv.scrollsToTop = NO;
    }
    contentTableView.scrollsToTop = YES;
    
    
    // 下拉刷新 MJRefresh
    contentTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        // dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // });
        [self connectForRefresh:contentTableView];
    }];
    
    // 上拉刷新
    contentTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self connectForLoadMore:contentTableView];
    }];
    
    // 禁用 mjRefresh
    // contentTableView.mj_footer = nil;
    
    return contentTableView;
}





#pragma mark - tableview 代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"tableView tag:%ld", (long)tableView.tag);
    NSInteger num = 0;
    for (long i=0; i<[_channels count]; i++) {
        if ((long)tableView.tag == i+1) {
            NSString *key = [_channels objectAtIndex:i];
            // NSLog(@"频道：%@", key);
            num = [[_contentListDataSource objectForKey:key] count];
        }
    }
    return num;
}

// 填充cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentity = [_channels objectAtIndex:(tableView.tag-1)];
    NSString *channelKey = [cellIdentity copy];
    NSLog(@"当前频道：%@", channelKey);
    
    NSString *CellWithIdentifierBig = [@"bigCell+" stringByAppendingString:cellIdentity];
    // NSString *CellWithIdentifierBig = @"big";
    bigPicTableViewCell *cellBig = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifierBig];
    
    NSString *CellWithIdentifierSmall = [@"smallCell+" stringByAppendingString:cellIdentity];
    // NSString *CellWithIdentifierSmall = @"small";
    smallPicTableViewCell *cellSmall = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifierSmall];
    
    NSUInteger row = [indexPath row];
    // 第一个cell
    if (row == 0) {
        if (cellBig == nil) {
            cellBig = [[bigPicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellWithIdentifierBig];
        }
        // 修改 cell 内容
        [cellBig rewriteTitle:[[[_contentListDataSource objectForKey:channelKey] objectAtIndex:row] objectForKey:@"title"]];
        [cellBig rewritePicURL:[[[_contentListDataSource objectForKey:channelKey] objectAtIndex:row] objectForKey:@"picBig"]];
        
        // 取消选中的背景色
        cellBig.selectionStyle = UITableViewCellSelectionStyleNone;
        return cellBig;
    }
    // 第二个开始的其他cell
    else {
        if (cellSmall == nil) {
            cellSmall = [[smallPicTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellWithIdentifierSmall];
        }
        // 修改cell内容
        [cellSmall rewriteTitle:[[[_contentListDataSource objectForKey:channelKey] objectAtIndex:row] objectForKey:@"title"]];
        [cellSmall rewritePicURL:[[[_contentListDataSource objectForKey:channelKey] objectAtIndex:row] objectForKey:@"picSmall"]];
        [cellSmall rewriteHotDegree:[[[_contentListDataSource objectForKey:channelKey] objectAtIndex:row] objectForKey:@"subtitle"]];
        
        // cell是否已读
        [cellSmall showAsBeenRead:[[[_contentListDataSource objectForKey:channelKey] objectAtIndex:row] objectForKey:@"_id"]];
        
        // 取消选中的背景色
        cellSmall.selectionStyle = UITableViewCellSelectionStyleNone;
        return cellSmall;
    }
}


//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSString *cellIdentity = [_channels objectAtIndex:(tableView.tag-1)];
//    NSString *channelKey = [cellIdentity copy];
//    NSLog(@"当前频道：%@", channelKey);
//    
//    static NSString *CellWithIdentifier = @"aaa";
//    picBasedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
//    
//    NSUInteger row = [indexPath row];
//    if (cell == nil) {
//        cell = [[picBasedTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellWithIdentifier];
//    }
//    // 修改 cell 内容
//    [cell rewriteTitle:[[[_contentListDataSource objectForKey:channelKey] objectAtIndex:row] objectForKey:@"title"]];
//    [cell rewritePicURL:[[[_contentListDataSource objectForKey:channelKey] objectAtIndex:row] objectForKey:@"picBig"]];
////    [cell rewriteDate:[[[_contentListDataSource objectForKey:channelKey] objectAtIndex:row] objectForKey:@"postTime"]];
//    [cell rewritePortraitURL:[[[[_contentListDataSource objectForKey:channelKey] objectAtIndex:row] objectForKey:@"author"] objectForKey:@"pic"]];
//    //
//    NSString *authorName = [[[[_contentListDataSource objectForKey:channelKey] objectAtIndex:row] objectForKey:@"author"] objectForKey:@"name"];
//    NSString *articleHotScore = @"324人气";
//    NSString *str = [authorName stringByAppendingString:@" · "];
//    str = [str stringByAppendingString:articleHotScore];
//    [cell rewriteAuthorAndHotScore:str];
//    
//    // 取消选中的背景色
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    return cell;
//}



// 改变 cell 高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   // 这里的cell高度是 2 种固定高度
   NSInteger row = [indexPath row];
   if (row == 0) {
       //bigcell
       float imgWidth = _screenWidth;
       float imgHeight = imgWidth * 244 / 320;
       return imgHeight;
   }
   else {
       //smallcell
       float imgWidth = _screenWidth/4.0;  // 80px
       float imgHeight = imgWidth*3/4;   // 60px
       return imgHeight + 24 + 4;
   }
    
//    // picBased height
//    float imgHeight = 180.0f;
//    return imgHeight + 40 + 15;
}



// tableView 点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSLog(@"cell点击事件at row: %lu", (unsigned long)row);
    
    // 临时用的...
//    if (row == 0) {
//        NSLog(@"清空缓存");
//        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//        NSDictionary *dictionary = [user dictionaryRepresentation];
//        for(NSString* key in [dictionary allKeys]){
//            [user removeObjectForKey:key];
//            [user synchronize];
//        }
//        return;
//    }
    
    // 临时用的2：进入topic页面
    if (row == 0) {
        NSLog(@"进行测试...");
        TopicVC *testPV = [[TopicVC alloc] init];
        [self.navigationController pushViewController:testPV animated:YES];
        //开启iOS7的滑动返回效果
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
        return;
    }
    
    // 临时用的3：进入classification页面
    if (row == 1) {
        NSLog(@"进行测试...");
        ClassificationVC *ClassificationPV = [[ClassificationVC alloc] init];
        [self.navigationController pushViewController:ClassificationPV animated:YES];
        //开启iOS7的滑动返回效果
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
        return;
    }
    
    NSString *channelKey = @"";
    channelKey = [_channels objectAtIndex:_currentChannel];
    NSString *articleID = [[[_contentListDataSource objectForKey:channelKey] objectAtIndex:row] objectForKey:@"_id"];
    NSLog(@"articleID: %@", articleID);

    
    // 进入article详情页
    detailVC *detailPage = [[detailVC alloc] init];
    detailPage.articleID = articleID;
    detailPage.delegate = self;
    [self.navigationController pushViewController:detailPage animated:YES];
    //开启iOS7的滑动返回效果
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }

    // 返回时是非选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
