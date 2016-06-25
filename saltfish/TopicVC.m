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
#import "commentTableViewCell.h"

@interface TopicVC ()
// 私有变量
@property (nonatomic) float backgroundImageHeight;
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
    
    [self createUIParts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - 构建UI零件
- (void)createUIParts
{
    /* 整个顶部滑动动效分三部分：背景图(中层）、tableView（下层）、头像图片（上层）*/
    
    NSString *urlStr = @"http://i10.topitme.com/l007/1000791711fc64cd4d.jpg";
    
    
    /* 创建tableView */
    static NSString *CellWithIdentifier = @"commentCell";
    UITableView *oneTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, _screenWidth, _screenHeight-64)];
    oneTableView.backgroundColor = [UIColor brownColor];
    [oneTableView setDelegate:self];
    [oneTableView setDataSource:self];
    
    [oneTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellWithIdentifier];
    oneTableView.backgroundColor = [UIColor whiteColor];
    oneTableView.separatorStyle = UITableViewCellSeparatorStyleNone; // 去掉分割线
    oneTableView.contentInset = UIEdgeInsetsMake(-20+86, 0, 0, 0); // 设置距离顶部的一段偏移，继承自scrollview
    // 响应点击状态栏的事件
    oneTableView.scrollsToTop = YES;
    [self.view addSubview:oneTableView];
    
    
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
        UIImage *imgBlur = [self boxblurImage:image withBlurNumber:(CGFloat)0.98f];
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
    UIImage *oneImage = [UIImage imageNamed:@"back.png"]; // 使用ImageView通过name找到图片
    UIImageView *oneImageView = [[UIImageView alloc] initWithImage:oneImage]; // 把oneImage添加到oneImageView上
    oneImageView.frame = CGRectMake(10, 14.5, 10, 15); // 设置图片位置和大小
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
    _titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 14];
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



#pragma mark - TableView 代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1000;
}

// 填充cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellWithIdentifier= @"commentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellWithIdentifier];
    
    NSUInteger row = [indexPath row];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellWithIdentifier];
    }
    cell.textLabel.text = @"hhh";
    cell.backgroundColor = [UIColor whiteColor];
    // 取消选中的背景色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // 直接往cell addsubView的方法会在每次划出屏幕再划回来时 再加载一次subview，因此会重复加载很多subview
    return cell;
}

// 改变 cell 高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 42;
    return height;
    
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
