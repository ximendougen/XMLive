//
//  XMMessageInfo.h
//  XMLive
//
//  Created by 王泽 on 16/11/8.
//  Copyright © 2016年 王泽. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMMessageInfo : NSObject

@property(nonatomic, copy)NSString *nick;
@property(nonatomic, copy)NSString *message;
@property(nonatomic, assign)NSInteger type; // 0:加入直播间  1:发消息   2:赞;

@end
