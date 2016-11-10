//
//  XMPCSmallScreenView.h
//  XMLive
//
//  Created by 王泽 on 16/11/8.
//  Copyright © 2016年 王泽. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XMPCSmallScreenView;

@protocol XMPCSmallScreenViewDelegate <NSObject>
@optional
- (void)didBackBtnClicked:(UIButton *)backBtn;
- (void)didPlayBtnClicked:(UIButton *)playBtn;
- (void)didRotatoBtnClicked:(UIButton *)rotatoBtn;
@end

@interface XMPCSmallScreenView : UIView

@property (nonatomic, weak) id<XMPCSmallScreenViewDelegate> delegate;



@end
