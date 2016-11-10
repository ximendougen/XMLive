//
//  XMBarrageViewCell.h
//  XMLive
//
//  Created by 王泽 on 16/11/8.
//  Copyright © 2016年 王泽. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, IFMBarrageViewCellStyle) {
    kMagicTableViewCellStyleWelcome,        // 进入直播间欢迎
    kMagicTableViewCellStyleMessage,        // 普通消息
    kMagicTableViewCellStyleThumbUp,        // 点赞
    
};

@interface XMBarrageViewCell : UITableViewCell

@property (nonatomic, assign)   IFMBarrageViewCellStyle  cellStyle;
@property (nonatomic, strong)   NSString        *text;
@property (nonatomic, strong)   NSString        *nick;
//@property (nonatomic, assign)   BOOL            thumb;
@end
