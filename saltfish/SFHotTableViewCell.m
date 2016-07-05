//
//  SFHotTableViewCell.m
//  saltfish
//
//  Created by alfred on 16/7/3.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "SFHotTableViewCell.h"
#import "colorManager.h"
#import "UIImageView+WebCache.h"


@implementation SFHotTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



#pragma mark - custom cells

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _screenHeight = [UIScreen mainScreen].bounds.size.height;
        _screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        
        /* ============= 焦点图 ScrollView ============== */
        
        _basedScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 170)];
        _basedScrollView.backgroundColor = [UIColor grayColor];
        _basedScrollView.delegate = self;
        
        //这个属性很重要，它可以决定是横向还是纵向滚动，一般来说也是其中的 View 的总宽度，和总的高度
        //这里同时考虑到每个 View 间的空隙，所以宽度是 200x3＋5＋10＋10＋5＝630
        //高度上与 ScrollView 相同，只在横向扩展，所以只要在横向上滚动
        _basedScrollView.contentSize = CGSizeMake(_screenWidth*3, 170);
        //用它指定 ScrollView 中内容的当前位置，即相对于 ScrollView 的左上顶点的偏移
        _basedScrollView.contentOffset = CGPointMake(0, 0);
        //按页滚动，总是一次一个宽度，或一个高度单位的滚动
        _basedScrollView.pagingEnabled = YES;
        //隐藏滚动条
        _basedScrollView.showsVerticalScrollIndicator = FALSE;
        _basedScrollView.showsHorizontalScrollIndicator = FALSE;
        // 是否边缘反弹
        _basedScrollView.bounces = YES;
        // 不响应点击状态栏的事件（留给uitableview用）
        _basedScrollView.scrollsToTop = NO;
        
        [self.contentView addSubview:_basedScrollView];
        
        
        /* 焦点图下方的定位点 */
        

        
        
        /* 背景、分割线 */
        _partLine = [[UIView alloc] initWithFrame:CGRectMake(0, 360-15, _screenWidth, 15)];
        _partLine.backgroundColor = [colorManager lightGrayBackground];
        [self.contentView addSubview: _partLine];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        
        // not usefull
        self.frame = CGRectMake(0, 0, 300, 300);
        NSLog(@"%f", self.frame.size.height);
        
    }
    return self;
}




#pragma mark - 重写 cell 中各个元素的数据

- (void)rewriteHotArticles:(NSArray *)newArr
{
    if (_hasHotArticles) {
        return;
    }
    
    // 数据传递
    _hotArticleData = [newArr copy];
    
    // 循环创建轮播的图片
    for (int i=0; i<[_hotArticleData count]+2; i++) {
        /*
         * 需要创建的图片序列如下： #2，0，1，2，#0
         * 多增加的首尾两个图片是为了进行循环滚动
         */
        
        // i代表位置，kk代表取值
        int kk = 0;
        if (i == 0) {
            kk = (int)[_hotArticleData count]-1;
        }
        else if (i>0 && i<=[_hotArticleData count]) {
            kk = i - 1;
        }
        else if (i>[_hotArticleData count]){
            kk = 0;
        }
        NSLog(@"%d", kk);
        
        UIImageView *picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_screenWidth*i, 0, _screenWidth, 170)];
        picImageView.backgroundColor = [UIColor grayColor];
        
        // uiimageview居中裁剪
        picImageView.contentMode = UIViewContentModeScaleAspectFill;
        picImageView.clipsToBounds  = YES;
        // 需要AFNetwork
        [picImageView sd_setImageWithURL:[NSURL URLWithString:[[_hotArticleData objectAtIndex:kk] objectForKey:@"url"]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        
        // 遮黑
        UIView *halfBlack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 170)];
        halfBlack.backgroundColor  = [UIColor blackColor];
        halfBlack.alpha = 0.22;
        [picImageView addSubview:halfBlack];
        
        // 文本
        UILabel *picLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 0, _screenWidth-54*2, 170)];
        picLabel.text = [[_hotArticleData objectAtIndex:kk] objectForKey:@"title"];
        picLabel.textColor  = [UIColor whiteColor];
        picLabel.font = [UIFont fontWithName:@"Helvetica" size: 18.0f];
        picLabel.numberOfLines = 2;
        picLabel.textAlignment = UITextAlignmentCenter;
        // 文字阴影
        picLabel.layer.shadowOpacity = 0.8;
        picLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        picLabel.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        picLabel.layer.shadowRadius = 1.0;
        [picImageView addSubview:picLabel];
        
        [_basedScrollView addSubview:picImageView];
    }
    
    // 重新绘制 Scrollview 宽度
    _basedScrollView.contentSize = CGSizeMake(_screenWidth*([newArr count]+2), 170);
    // 修改 Scrollview 的初始偏移
    _basedScrollView.contentOffset = CGPointMake(_screenWidth, 0);
    
    _hasHotArticles = YES;
    
    
    // 循环创建焦点图定位点
    _direction = [[UIView alloc] init];
    for (int i=0; i<[_hotArticleData count]; i++) {
        // 假设圆点的大小是6px,间隔10px
        UIView *pointer = [[UIView alloc] initWithFrame:CGRectMake((6+10)*i, 0, 6, 6)];
        pointer.backgroundColor = [UIColor whiteColor];
        pointer.alpha = 0.4;
        pointer.tag = i+1;
        pointer.layer.cornerRadius = 3;
        [_direction addSubview:pointer];
    }
    [[_direction viewWithTag:1] setAlpha:0.8];  // 初始定位在第一个点
    
    int num = (int)[_hotArticleData count];
    unsigned long ww = num*6 + (num-1)*10;
    _direction.frame = CGRectMake((_screenWidth-ww)/2.0, 150, ww, 6);
    [self.contentView addSubview: _direction];
    
    
    
    // 定时器 循环
    _timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(scrollTimer) userInfo:nil repeats:YES];

}



#pragma mark - ScrollView 代理

// 减速时触发
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_basedScrollView]) {
        NSLog(@"ScrollView 减速停止");
        NSLog(@"ScrollView偏移：%f", _basedScrollView.contentOffset.x);
        
        // 指示器移动到下一个
        NSArray *directions = [_direction subviews];
        for (int i=0; i<[directions count]; i++) {
            [(UIView *)[directions objectAtIndex:i] setAlpha:0.4];
        }
        
        //
        if (_basedScrollView.contentOffset.x == 0.0f) {
            NSLog(@"滑到队首了");
            // 悄无声息的偏移到倒数第二个
            [_basedScrollView setContentOffset:CGPointMake(_screenWidth*[_hotArticleData count], 0) animated:NO];
            // 指示器指到最后一个
            [(UIView *)[directions objectAtIndex:[_hotArticleData count]-1] setAlpha:0.8];
        }
        else if (_basedScrollView.contentOffset.x == ([_hotArticleData count] + 1)*_screenWidth) {
            NSLog(@"滑到队尾了");
            // 悄无声息的偏移到第二个
            [_basedScrollView setContentOffset:CGPointMake(_screenWidth, 0) animated:NO];
            // 指示器指到第一个
            [(UIView *)[directions objectAtIndex:0] setAlpha:0.8];
        }
        else {
            // 指示器指到对应的
            int picNum = (int)_basedScrollView.contentOffset.x / _screenWidth;
            [(UIView *)[directions objectAtIndex:picNum - 1] setAlpha:0.8];
        }
    }
    NSLog(@"fff");
}


// 开始拖拽时触发
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"开始拖拽");
    // 暂时关闭定时器
    // [_timer setFireDate:[NSDate distantFuture]];
    //取消定时器
    [_timer invalidate];
    _timer = nil;
    
}
// 结束拖拽时触发
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView  willDecelerate:(BOOL)decelerate{
    NSLog(@"结束拖拽");
    // 再次开启定时器
    // [_timer setFireDate:[NSDate distantPast]];
    // 创建一个定时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(scrollTimer) userInfo:nil repeats:YES];
}



#pragma mark - 定时执行循环
 - (void)scrollTimer
{
    unsigned long ww = _basedScrollView.contentOffset.x;  // 获取当前的偏移
    int picNumCurrent = (int)ww/_screenWidth;  // 获取当前的图片指针
    int picNumNextShow = 0;
    NSLog(@"当前在第%d帧", picNumCurrent);
    
    // 指示器归零
    NSArray *directions = [_direction subviews];
    for (int i=0; i<[directions count]; i++) {
        [(UIView *)[directions objectAtIndex:i] setAlpha:0.4];
    }
    
    // 如果当前在队尾
    if (picNumCurrent == [_hotArticleData count]+1) {
        // 悄无声息的偏移到第二个
        [_basedScrollView setContentOffset:CGPointMake(_screenWidth, 0) animated:NO];
        ww = _screenWidth;
        picNumCurrent = 1;
        NSLog(@"修正后在第%d帧",picNumCurrent);
        NSLog(@"将移到第%d帧",picNumCurrent + 1);
        picNumNextShow = picNumCurrent + 1 - 1;
        NSLog(@"实际看到是第%d帧", picNumNextShow);
    }
    // 如果当前在倒数第二位
    if (picNumCurrent == [_hotArticleData count]) {
        NSLog(@"将移到第%d帧",picNumCurrent + 1);
        picNumNextShow = 0;
        NSLog(@"实际看到是第%d帧", picNumNextShow);
    }
    // 如果当前在队首
    else if (picNumCurrent == 0) {
        // 此时无需悄无声息的调换位置，因为只是一个顺序滚动
        NSLog(@"修正后在第%d帧",picNumCurrent);
        NSLog(@"将移到第%d帧",picNumCurrent + 1);
        picNumNextShow = picNumCurrent + 1 - 1;
        NSLog(@"实际看到是第%d帧", picNumNextShow);
    }
    // 如果当前在队伍中间
    else {
        NSLog(@"将移动到第%d帧", picNumCurrent + 1);
        picNumNextShow = picNumCurrent + 1 - 1;
        NSLog(@"实际看到是第%d帧", picNumNextShow);
    }
    
    // 重新设置指示器
    [(UIView *)[directions objectAtIndex:picNumNextShow] setAlpha:0.8];

    
    // 移动到下一张图片
    [_basedScrollView setContentOffset:CGPointMake(ww + _screenWidth, 0) animated:YES];
    
    
//    // 指示器移动到下一个
//    NSArray *directions = [_direction subviews];
//    for (int i=0; i<[directions count]; i++) {
//        [(UIView *)[directions objectAtIndex:i] setAlpha:0.4];
//    }
//    // 移动到第几张图片？
//    int picNum = (int)ww/_screenWidth + 1;
//
//    // picNum是队首
//    if (picNum == 0) {
//        [(UIView *)[directions objectAtIndex:[_hotArticleData count]-1] setAlpha:0.8];
//    }
//    // picNum在队伍中间
//    else if (picNum > 0 && picNum < [_hotArticleData count]) {
//        [(UIView *)[directions objectAtIndex:picNum-1] setAlpha:0.8];
//    }

//    // picNum是队尾
//    if (picNum == [_hotArticleData count]+1) {
//        [(UIView *)[directions objectAtIndex:1] setAlpha:0.8];
//    }
//    // picNum是队首
//    else if (picNum == 0) {
//        [(UIView *)[directions objectAtIndex:[_hotArticleData count]-1] setAlpha:0.8];
//    }
//    // picNum在队伍中间
//    else {
//        [(UIView *)[directions objectAtIndex:picNum-1] setAlpha:0.8];
//    }
}

@end
