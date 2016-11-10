//
//  XMIMController.h
//  XMLive
//
//  Created by 王泽 on 16/11/8.
//  Copyright © 2016年 王泽. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMMessageInfo.h"
typedef void(^messBlock)(XMMessageInfo *);

@interface XMIMController : UIViewController
//接收消息的回调
@property (nonatomic, copy)messBlock            messBlock;

//发消息
- (void)sendMessage:(NSString *)mess;
@end
