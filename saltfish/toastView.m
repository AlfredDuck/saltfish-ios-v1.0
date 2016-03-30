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

+ (void)showToastWith:(NSString *)text duration:(double)duration superView:(UIView *)superView
{

    UILabel *toast = [[UILabel alloc] initWithFrame:CGRectMake(0, superView.frame.size.height, superView.frame.size.width, 60)];
    toast.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
    toast.textAlignment = UITextAlignmentCenter;
    toast.textColor = [UIColor whiteColor];
    toast.alpha = 0.92;
    toast.text = text;
    toast.backgroundColor = [colorManager purple];
    
    [superView addSubview:toast];
    [superView bringSubviewToFront:toast];  // 放在最上层(要在所有子视图加载后)
    
    // 显示动画
    [UIView animateWithDuration:0.3 animations:^{
        toast.frame = CGRectMake(0, superView.frame.size.height-60, superView.frame.size.width, 60);
    }];
    
    // 延迟n秒后消失
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
