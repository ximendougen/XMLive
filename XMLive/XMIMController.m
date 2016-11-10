//
//  XMIMController.m
//  XMLive
//
//  Created by 王泽 on 16/11/8.
//  Copyright © 2016年 王泽. All rights reserved.
//

#define useSig @"eJxNjd1KwzAARt*ltxOXpM06hF3UUemgAafdqLsJWZK2QZbGJHVu4rsbSofenvP9fEdV*XrPOO8H7am-GBk9RCC6G7ESUnvVKGkDvHZMt47pyTFjlKDM09iKfxUn3umoAoMJAAAuMFhOUn4ZZSVljR8XIcYYhchkP6V1qtdBoNCCAELwJ706yXEyXaRLgFB6*1NtwCTfrjeFi49i2GVbzIuXS4kccO6wt01CasdLTgyYdV0*xxXZZCpj4q18dDG6QtXPSXKqd0-VYSgaO5zPunN8759r2bYfs7xdraKfX4tVWa8_"

/**
 *
 *  SdkAppId       1400016508
 *  帐号名称         601339084
 *  accountType       8029
 *
 */

//测试腾讯IM
//SDKAppId = 1400016508
//群ID：@TGS#3JDJIQEE4

#import "XMIMController.h"
#import <ImSDK/ImSDK.h>
#import <TLSSDK/TLSHelper.h>

@interface XMIMController ()<TIMConnListener,TIMUserStatusListener,TIMMessageListener>
@property (nonatomic, strong)TIMManager         *manager;
@property (nonatomic, strong)TIMConversation    *grp_conversation;

@end

@implementation XMIMController

#pragma mark - life cycle methods

- (void)loadView {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [TIMManager sharedInstance];
    [self.manager setMessageListener:self];
    [self.manager setConnListener:self];
    [self.manager disableStorage];
    [self.manager initSdk:1400016508];
    
    
    TIMLoginParam * login_param = [[TIMLoginParam alloc ]init];
    
    
    login_param.accountType = @"8029";
    login_param.identifier = @"zhangsan";
    login_param.userSig = useSig;
    login_param.appidAt3rd = @"1400016508";
    
    login_param.sdkAppId = 1400016508;
    
    [[TIMManager sharedInstance] login: login_param succ:^(){
        NSLog(@"Login 成功");
        [[TIMGroupManager sharedInstance] JoinGroup:@"@TGS#3JDJIQEE4" msg:@"Apply Join Group" succ:^(){
            NSLog(@"Join Succ");
            
            TIMConversation * grp_conversation = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:@"@TGS#3JDJIQEE4"];
            self.grp_conversation = grp_conversation;
            
        }fail:^(int code, NSString * err) {
            NSLog(@"code=%d, err=%@", code, err);
            
            if ([err isEqualToString:@"already group member"]) {
                TIMConversation * grp_conversation = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:@"@TGS#3JDJIQEE4"];
                self.grp_conversation = grp_conversation;
                NSLog(@"已经在这个群了");
            }
        }];
    } fail:^(int code, NSString * err) {
        NSLog(@"Login 失败: %d->%@", code, err);
    }];
}

- (void)sendMessage:(NSString *)mess{

    if (mess.length > 0) {
        TIMTextElem * text_elem = [[TIMTextElem alloc] init];
        
        [text_elem setText:mess];
        
        TIMMessage * msg = [[TIMMessage alloc] init];
        [msg addElem:text_elem];
        
        [self.grp_conversation sendMessage:msg succ:^(){
            NSLog(@"SendMsg Succ");
            
            XMMessageInfo *model = [[XMMessageInfo alloc]init];
            model.message = text_elem.text;
            model.type = 1;
            model.nick = @"zhangsan";
            if (self.messBlock) {
                self.messBlock(model);
            }
            
        }fail:^(int code, NSString * err) {
            NSLog(@"SendMsg Failed:%d->%@", code, err);
        }];
    }
}


#pragma mark - TIMMessageListener

- (void)onNewMessage:(NSArray*) msgs {
    
    NSLog(@"NewMessages: %@", msgs);
    
    TIMMessage * message = (TIMMessage *)msgs[0];
    XMMessageInfo *model = [[XMMessageInfo alloc]init];
    //发送信息人昵称
    model.nick = [message sender];
    
    TIMOfflinePushInfo * custom_elem = [message getOfflinePushInfo];
    if ([custom_elem.desc isEqualToString:@"点赞"]) {
        //点赞
        model.type = 2;
    }
    
    //解析消息
    for (int i = 0; i < [message elemCount]; i++) {
        
        TIMElem * elem = [message getElem:i];
        
        TIMConversation * conversation = [message getConversation];
        if ([elem isKindOfClass:[TIMGroupTipsElem class]]) {
            TIMGroupTipsElem * tips_elem = (TIMGroupTipsElem * )elem;
            switch ([tips_elem type]) {
                case TIM_GROUP_TIPS_TYPE_INVITE:
                {
                    //加入直播室人昵称
                    model.nick = [tips_elem userList].firstObject;
                    model.type = 0;
                }
                    break;
                case TIM_GROUP_TIPS_TYPE_QUIT_GRP:
                    //退出人 昵称
                    NSLog(@"%@ quit group %@", [tips_elem userList], [conversation getReceiver]);
                    break;
                default:
                    NSLog(@"ignore type");
                    break;
            }
        } else if ([elem isKindOfClass:[TIMTextElem class]]) {
            TIMTextElem * text_elem = (TIMTextElem * )elem;
            model.message = text_elem.text;
            model.type = 1;
        }
    }
    
    if (self.messBlock) {
        self.messBlock(model);
    }
}

//- (void)点赞 {
//
//    TIMOfflinePushInfo * custom_elem = [[TIMOfflinePushInfo alloc] init];
//
//    [custom_elem setExt:@"点赞"];
//    [custom_elem setDesc:@"点赞"];
//    [custom_elem setPushFlag:TIM_OFFLINE_PUSH_NO_PUSH];
//
//    TIMMessage * msg = [[TIMMessage alloc] init];
//    [msg setOfflinePushInfo:custom_elem];
//    [self.grp_conversation sendMessage:msg succ:^(){
//        NSLog(@"SendMsg Succ");
//    }fail:^(int code, NSString * err) {
//        NSLog(@"SendMsg Failed:%d->%@", code, err);
//    }];
//
//}

#pragma mark - TIMConnListener

- (void)onConnSucc {
    NSLog(@"-IM- 网络连接成功");
}

- (void)onConnFailed:(int)code err:(NSString*)err {
      // code 错误码：具体参见错误码表
    NSLog(@"Connect Failed: code=%d, err=%@", code, err);
}

- (void)onDisconnect:(int)code err:(NSString*)err {
      // code 错误码：具体参见错误码表
    NSLog(@"Disconnect: code=%d, err=%@", code, err);
}

- (void)onConnecting {
    
    NSLog(@"-IM- 网络连接中...");
}

@end

