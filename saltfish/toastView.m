//
//  toastView.m
//  saltfish
//
//  Created by alfred on 16/2/1.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import "toastView.h"
#import "colorManager.h"

@implementation toastView

+ (void)showToastWith:(NSString *)text isErr:(BOOL)isErr duration:(double)duration superView:(UIView *)superView
{

    UILabel *toast = [[UILabel alloc] initWithFrame:CGRectMake(0, superView.frame.size.height, superView.frame.size.width, 60)];
    toast.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    toast.textAlignment = UITextAlignmentCenter;
    toast.textColor = [UIColor whiteColor];
    toast.alpha = 0.92;
    toast.text = text;
    
    /* toast背景色 */
    if (isErr) {
        toast.backgroundColor = [UIColor colorWithRed:132/255.0 green:211/255.0 blue:59/255.0 alpha:1];  // 正向的提示用绿色
    } else {
        toast.backgroundColor = [colorManager purple];  // 错误的提示用红色
    }
    
    /* toast加载到当前viewController */
    [superView addSubview:toast];
    [superView bringSubviewToFront:toast];  // 放在最上层(要在所有子视图加载后)
    
    /* toast出现时的动画 */
    [UIView animateWithDuration:0.3 animations:^{
        toast.frame = CGRectMake(0, superView.frame.size.height-60, superView.frame.size.width, 60);
    }];
    
    /* 延迟n秒后消失 */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 消失动画
        [UIView animateWithDuration:0.2 animations:^{
            toast.frame = CGRectMake(0, superView.frame.size.height, superView.frame.size.width, 60);
        }];
        // 延迟n秒后消失
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [toast removeFromSuperview];
        });
    });

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
