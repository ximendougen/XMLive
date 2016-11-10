//
//  DanmakuFilter.h
//  olinone
//
//  Created by Haijiao on 15/3/5.
//
//

#import <Foundation/Foundation.h>
#import "DanmakuTime.h"

@interface DanmakuFilter : NSObject

- (NSArray *)filterDanmakus:(NSArray *)danmakus Time:(DanmakuTime *)time;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com