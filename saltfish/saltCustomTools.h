//
//  saltCustomTools.h
//  saltfish
//
//  Created by alfred on 16/4/3.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface saltCustomTools : NSObject
@end


#pragma mark - 分享成功后，通知server
@interface shareSuccessNote : NSObject
- (void)shareSuccessWhichIs:(NSString *)weixinOrWeibo;
@end
