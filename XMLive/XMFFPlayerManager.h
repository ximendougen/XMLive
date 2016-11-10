//
//  XMFFPlayerManager.h
//  XMLive
//
//  Created by 王泽 on 16/11/8.
//  Copyright © 2016年 王泽. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMFFPlayerManager : NSObject

+ (instancetype)sharedTools;

//设置主播昵称,头像,设置直播地址~直播间名称
- (void)setMCNick:(NSString *)nick headImgURLStr:(NSString *)portrait URLStr:(NSString *)urlStr liveName:(NSString *)liveName groupID:(NSString *)groupID;

//给予出发控制器 (isFullScreen:暂时无用)
- (void)setRootViewController:(UIViewController *)RootVc isFullScreen:(BOOL)on;

//判断是否为PC端
- (void)isPCPlayer:(BOOL)isOn;

//准备并开始播放;
- (void)prepareToPlay;

@end
