//
//  colorManager.m
//  saltfish
//
//  Created by alfred on 15/12/15.
//  Copyright © 2015年 Alfred. All rights reserved.
//

#import "colorManager.h"

@implementation colorManager
+ (UIColor *)lightGrayLineColor
{
    return [UIColor colorWithRed:(205/255.0) green:(205/255.0) blue:(205/255.0) alpha:1];
}
+ (UIColor *)lightGrayBackground
{
    return [UIColor colorWithRed:(242/255.0) green:(242/255.0) blue:(242/255.0) alpha:1];
}
+ (UIColor *)mainTextColor
{
    return [UIColor colorWithRed:(93/255.0) green:(93/255.0) blue:(93/255.0) alpha:1];
}
+ (UIColor *)lightTextColor
{
    return [UIColor colorWithRed:(178/255.0) green:(178/255.0) blue:(178/255.0) alpha:1];
}
+ (UIColor *)purple
{
    return [UIColor colorWithRed:(249/255.0) green:(60/255.0) blue:(131/255.0) alpha:1];
}
+ (UIColor *)red
{
    return [UIColor colorWithRed:(251/255.0) green:(88/255.0) blue:(88/255.0) alpha:1];
}
+ (UIColor *)commentTextColor
{
    return [UIColor colorWithRed:(104/255.0) green:(104/255.0) blue:(104/255.0) alpha:1];

}
@end
