//
//  XMPCPlayerController.h
//  XMLive
//
//  Created by 王泽 on 16/11/8.
//  Copyright © 2016年 王泽. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^dismissBlock)();

@interface XMPCPlayerController : UIViewController

// 直播流地址
@property (nonatomic, copy) NSString *stream_addr;

// 主播nick
@property (nonatomic, copy) NSString *nick;

// 主播头像
@property (nonatomic, copy) NSString *portrait;

// 房间名称
@property (nonatomic, copy) NSString *liveName;

// 聊天室ID(IM)
@property (nonatomic, copy) NSString *groupID;

//@property (nonatomic, copy) dismissBlock dismiss_block;

@end
