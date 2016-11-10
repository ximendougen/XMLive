//
//  XMPhoneView.h
//  XMLive
//
//  Created by 王泽 on 16/11/8.
//  Copyright © 2016年 王泽. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMMessageInfo.h"

typedef void(^messBlock)(XMMessageInfo *);

@class XMPhoneView;
@protocol XMPhoneViewDelegate <NSObject>
@optional
- (void)didSendMessBtnClicked:(UIButton *)sendMessBtn andMess:(NSString *)mess;
- (void)didThumbUpBtnClicked:(UIButton *)thumbUpBtn;
@end

@interface XMPhoneView : UIView

// 主播nick
@property (nonatomic, copy)   NSString       *nick;
// 主播头像
@property (nonatomic, copy)   UIImage        *portraitImg;
@property (nonatomic, assign) BOOL           keyboardIsVisible;
@property (nonatomic, copy)   messBlock      messBlock;
@property (nonatomic, assign) BOOL           isBottomPanelHidden;

@property (nonatomic, weak)   id<XMPhoneViewDelegate> delegate;

@end

