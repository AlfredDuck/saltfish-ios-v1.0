//
//  TopicVC.m
//  saltfish
//
//  Created by alfred on 16/6/19.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "TopicVC.h"
#import <AFNetworking/AFNetworking.h>
#import <Accelerate/Accelerate.h>
#import "UIImageView+WebCache.h"
#import "colorManager.h"
#import "articleCell.h"
#import "TopicCell.h"


@interface TopicVC ()
// 私有变量
@property (nonatomic) float backgroundImageHeight;
@property (nonatomic) UITableView *oneTableView;
@property (nonatomic) BOOL isFollowing;
@end

@implementation TopicVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"test";
        self.view.backgroundColor = [UIColor grayColor];
    }
    return self;
}

// 修改状态栏色值
// 在你自己的UIViewController里重写此方法，返回你需要的值(UIStatusBarStyleDefault 或者 UIStatusBarStyleLightContent)；
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
    //return  UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _backgroundImageHeight = 400.0;
    
    _isFollowing = NO;
    
    [self createUIParts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - 构建UI零件
- (void)createUIParts
{
    /* 整个顶部滑动动效分三部分：背景图(中层）、tableView（下层）、头像图片（上层）*/
    
    NSString *urlStr = @"http://fb.topitme.com/b/0f/51/1139283992402510fbl.jpg";
    
    
    /* 创建tableView */
    static NSString *CellWithIdentifier = @"commentCell";
    _oneTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, _screenWidth, _screenHeight-64)];
    _oneTableView.backgroundColor = [UIColor brownColor];
    [_oneTableView setDelegate:self];
    [_oneTableView setDataSource:self];
    
    [_oneTableView registerClass:[articleCell class] forCellReuseIdentifier:CellWithIdentifier];
    _oneTableView.backgroundColor = [UIColor whiteColor];
    _oneTableView.separatorStyle = UITableViewCellSeparatorStyleNone; // 去掉分割线
    _oneTableView.contentInset = UIEdgeInsetsMake(-20+86, 0, 0, 0); // 设置距离顶部的一段偏移，继承自scrollview
    // 响应点击状态栏的事件
    _oneTableView.scrollsToTop = YES;
    [self.view addSubview:_oneTableView];
    
    
    /* 创建背景图 */
    _backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _backgroundImageHeight)];
    _backgroundView.backgroundColor = [UIColor brownColor];
//    _backgroundView.alpha = 0.5;
    // uiimageview居中裁剪
    _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundView.clipsToBounds  = YES;
    // 需要AFNetwork（异步加载）
    [_backgroundView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSLog(@"%@", imageURL);
        UIImage *imgBlur = [self boxblurImage:image withBlurNumber:(CGFloat)0.60f];
        [_backgroundView setImage:imgBlur];
    }];
    
    [self boxblurImage:_backgroundView.image withBlurNumber:20.0];
    [self.view addSubview:_backgroundView];
    
    
    /* 创建头像图片 */
    _portraitView = [[UIImageView alloc] initWithFrame:CGRectMake(_screenWidth/2.0-42, 92, 84, 84)];
    _portraitView.backgroundColor = [UIColor brownColor];
    // uiimageview居中裁剪
    _portraitView.contentMode = UIViewContentModeScaleAspectFill;
    _portraitView.clipsToBounds  = YES;
    // 需要AFNetwork（延后处理）
    [_portraitView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    [self.view addSubview:_portraitView];
    
    
    /*=================================================================*/
    // 导航栏和返回按钮
    // back button pic
    UIImage *oneImage = [UIImage imageNamed:@"back2.png"]; // 使用ImageView通过name找到图片
    UIImageView *oneImageView = [[UIImageView alloc] initWithImage:oneImage]; // 把oneImage添加到oneImageView上
    oneImageView.frame = CGRectMake(11, 13.2, 22, 17.6); // 设置图片位置和大小
    // [oneImageView setContentMode:UIViewContentModeCenter];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [backView addSubview:oneImageView];
    // 为UIView添加点击事件
    // 一定要先将userInteractionEnabled置为YES，这样才能响应单击事件
    backView.userInteractionEnabled = YES; // 设置图片可以交互
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBackButton)]; // 设置手势
    [backView addGestureRecognizer:singleTap]; // 给图片添加手势
    [self.view addSubview:backView];
    
    // title
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_screenWidth-200)/2, 20, 200, 44)];
    _titleLabel.text = @"#佐佐木希#";
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 15.0];
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.hidden = YES;
    [self.view addSubview:_titleLabel];
}



#pragma mark - IBAction
- (void)clickBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TableView 滚动事件
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"滚动事件发生");
    NSLog(@"tableview偏移：%f",scrollView.contentOffset.y);
//    float yy = -(scrollView.contentOffset.y + _backgroundImageHeight - 64);
//    _backgroundView.frame = CGRectMake(0, yy, _screenWidth, _backgroundImageHeight);
//    
//    if (_backgroundView.frame.origin.y <= -(_backgroundImageHeight-64)) {
//        _backgroundView.frame = CGRectMake(0, -(_backgroundImageHeight-64), _screenWidth, _backgroundImageHeight);
//    }
    
    /* 背景图控制 */
    float hh = -scrollView.contentOffset.y + 64;
    NSLog(@"%f",hh);
    
    // 当背景图高度最小为64，不能更小了
    if (hh <= 64.0) {
        _backgroundView.frame = CGRectMake(0, 0, _screenWidth, 64.0);
        _titleLabel.hidden = NO;
    }
    else {
        // 背景图的高度随着tableview的cntentoffset变化
        _backgroundView.frame = CGRectMake(0, 0, _screenWidth, hh);
        _titleLabel.hidden = YES;
    }
    
    /* 头像控制 */
    float yy = -scrollView.contentOffset.y + (64-58);
    // 150是背景图height，92是头像y
    
    // 修改头像高度
    _portraitView.frame = CGRectMake((_screenWidth-84)/2.0, yy, 84, 84);
    // 修改头像透明度
    if (yy <= 74.0) {
        _portraitView.alpha = (yy-10)/(80.0-10);
    }
    else {
        _portraitView.alpha = 1;
    }
    
}





#pragma mark - TopicCell 的代理方法

- (void)clickFollowButton
{
    if (_isFollowing) {
        _isFollowing = NO;
    } else {
        _isFollowing = YES;
    }

    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    [_oneTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationFade];
    
    //    [UIView animateWithDuration:0.3 animations:^{   // uiview 动画（无需实例化）单例
    //
    //    }];
}






#pragma mark - TableView 代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

// 填充cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TopicCellWithIdentifier = @"topicCell+";
    TopicCell *oneTopicCell = [tableView dequeueReusableCellWithIdentifier:TopicCellWithIdentifier];
    
    static NSString *ArticleCellWithIdentifier = @"articleCell+";
    articleCell *oneArticleCell = [tableView dequeueReusableCellWithIdentifier:ArticleCellWithIdentifier];
    
    NSUInteger row = [indexPath row];
    if (row == 0) {
        if (oneTopicCell == nil) {
            oneTopicCell = [[TopicCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TopicCellWithIdentifier];
            // 定义代理
            oneTopicCell.delegate = self;
        }
        [oneTopicCell rewriteIntroduction:@"如楼上所说，现代武器是很厉害的；对付这种超级怪兽最方便的如楼上所说，现代武器是很厉害的；对付这种超级怪兽最方便的" followStatus:_isFollowing];
        
        // 取消选中的背景色
        oneTopicCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return oneTopicCell;
    }
    else {
        if (oneArticleCell == nil) {
            oneArticleCell = [[articleCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ArticleCellWithIdentifier];
        }
        [oneArticleCell rewriteTitle:@"根据葛尔丹博士的史书，雷妮丝可能因坠地而死吧"];
        NSArray *arr = @[@"#屌丝#",@"#白富美#",@"#野外漏出#",@"#艹范冰冰#",@"#耐辱奶乳#",@"#O(∩_∩)O哈哈~#"];
        [oneArticleCell rewriteTopics:arr];
        // 取消选中的背景色
        oneArticleCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return oneArticleCell;
    }
    
    // 直接往cell addsubView的方法会在每次划出屏幕再划回来时 再加载一次subview，因此会重复加载很多subview
}

// 改变 cell 高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    if (row == 0) {
        NSLog(@"。。。。。。。。。。。。。。");
        // ===================计算折行文本高度====================
        NSString *str = @"如楼上所说，现代武器是很厉害的；对付这种超级怪兽最方便的如楼上所说，现代武器是很厉害的；对付这种超级怪兽最方便的";
        CGSize maxSize = {_screenWidth-50*2, 5000};  // 设置文本区域最大宽高(两边各留15px)
        CGSize labelSize = [str sizeWithFont:[UIFont fontWithName:@"Helvetica" size:13]
                           constrainedToSize:maxSize
                               lineBreakMode:[[UILabel alloc] init].lineBreakMode];   // str是要显示的字符串
        CGFloat newHeight = labelSize.height*16/13.0;
        
        CGFloat height;
        if (!_isFollowing) { // unfollow
            height = 68+newHeight+18+35+18+12;
        } else {
            height = 68+newHeight+18+35+18+12+44;
        }
        
        return height;
    }
    else {
        CGFloat height = 110+14;
        return height;
    }
}


// tableView 点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    if (row == 0) {
        NSLog(@"000000000000");
    }
}





#pragma mark - 高斯模糊
- (UIImage *)boxblurImage:(UIImage *)image withBlurNumber:(CGFloat)blur
{
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 240);
    boxSize = boxSize - (boxSize % 2) + 1;
    CGImageRef img = image.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    //从CGImage中获取数据
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    //设置从CGImage获取对象的属性
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate( outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    //clean up CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    return returnImage;
}





@end
