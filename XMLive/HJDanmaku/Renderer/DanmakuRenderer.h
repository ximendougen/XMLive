//
//  DanmakuRenderer.h
//  DanmakuDemo
//
//  Created by Haijiao on 15/2/28.
//  Copyright (c) 2015年 olinone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class DanmakuTime;
@class DanmakuConfiguration;

@interface DanmakuRenderer : NSObject

@property (nonatomic, weak) DanmakuConfiguration *configuration;

- (instancetype)initWithCanvas:(UIView *)canvas Configuration:(DanmakuConfiguration *)configuration;
- (void)updateCanvasFrame;

- (void)drawDanmakus:(NSArray *)danmakus Time:(DanmakuTime *)time IsBuffering:(BOOL)isBuffering;

- (void)pauseRenderer;
- (void)stopRenderer;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com