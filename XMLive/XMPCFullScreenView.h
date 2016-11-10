//
//  XMPCFullScreenView.h
//  XMLive
//
//  Created by 王泽 on 16/11/8.
//  Copyright © 2016年 王泽. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMPCFullScreenView;
@protocol XMPCFullScreenViewDelegate <NSObject>
@optional
- (void)didRotatoBtnClicked:(UIButton *)rotatoBtn;
- (void)didBarrageBtnClicked:(UIButton *)barrageBtn;
- (void)didSendMessBtnClicked:(UIButton *)sendMessBtn andMess:(NSString *)mess;
- (void)didPlayBtnClicked:(UIButton *)playBtn;
@end

@interface XMPCFullScreenView : UIView

@property (nonatomic, copy) NSString                      *root_name_str;

@property (nonatomic, weak) id<XMPCFullScreenViewDelegate> delegate;

@end
