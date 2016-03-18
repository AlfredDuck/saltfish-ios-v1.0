//
//  toastView.h
//  saltfish
//
//  Created by alfred on 16/2/1.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface toastView : UIView
+ (void)showToastWith:(NSString *)text duration:(double)duration superView:(UIView *)superView;
@end
