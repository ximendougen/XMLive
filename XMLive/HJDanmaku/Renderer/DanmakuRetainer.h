//
//  DanmakuRetainer.h
//  DanmakuDemo
//
//  Created by Haijiao on 15/3/3.
//  Copyright (c) 2015年 olinone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DanmakuView.h"
@class DanmakuBaseModel;

@interface DanmakuRetainer : NSObject

@property (nonatomic, assign) CGSize canvasSize;
@property (nonatomic, weak) DanmakuConfiguration *configuration;

- (void)clearVisibleDanmaku:(DanmakuBaseModel *)danmaku;
- (float)layoutPyForDanmaku:(DanmakuBaseModel *)danmaku;
- (void)clear;

@end

@interface DanmakuFTRetainer : DanmakuRetainer

@end

@interface DanmakuFBRetainer : DanmakuFTRetainer

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com