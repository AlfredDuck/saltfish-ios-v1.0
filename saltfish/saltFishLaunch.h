//
//  saltFishLaunch.h
//  saltfish
//
//  Created by alfred on 16/1/31.
//  Copyright © 2016年 Alfred. All rights reserved.
//

#import <Foundation/Foundation.h>

/* APP 启动时需要做的一些事情 */

@protocol launchDelegate <NSObject>
@required
- (void)channelConfig:(NSArray *)channels;
@end


@interface saltFishLaunch : NSObject
- (void)basedChannelConfig;
- (void)basedUUID;
// Define Delegate
@property (nonatomic, assign) id <launchDelegate> delegate;
@end
