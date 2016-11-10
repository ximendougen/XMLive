//
//  XMFFPlayerManager.m
//  XMLive
//
//  Created by 王泽 on 16/11/8.
//  Copyright © 2016年 王泽. All rights reserved.
//

#import "XMFFPlayerManager.h"
#import "XMPhonePlayerController.h"
#import "XMPCPlayerController.h"

@interface XMFFPlayerManager ()
@property(nonatomic, strong)XMPhonePlayerController        *PhonePlayVC;
@property(nonatomic, strong)XMPCPlayerController           *PCPlayerVC;
@property(nonatomic, strong)UIViewController               *rootVc;

@property(nonatomic, copy)NSString                  *nick;
@property(nonatomic, copy)NSString                  *portrait;
@property(nonatomic, copy)NSString                  *stream_addr;
@property(nonatomic, copy)NSString                  *liveName;
@property(nonatomic, copy)NSString                  *groupID;
@end


@implementation XMFFPlayerManager


static XMFFPlayerManager *instance;

+ (instancetype)sharedTools{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)setMCNick:(NSString *)nick headImgURLStr:(NSString *)portrait URLStr:(NSString *)urlStr liveName:(NSString *)liveName groupID:(NSString *)groupID{
    
    self.nick = nick;
    self.portrait = [NSString stringWithFormat:@"http://img.meelive.cn/%@",portrait];
    self.stream_addr = urlStr;
    self.liveName = liveName;
    self.groupID = groupID;
}

- (void)setRootViewController:(UIViewController *)RootVc isFullScreen:(BOOL)on {
    
    self.rootVc = RootVc;
}

- (void)isPCPlayer:(BOOL)isOn {
    
    
    if (isOn) {
        
        self.PCPlayerVC = [[XMPCPlayerController alloc]init];
        self.PCPlayerVC.nick = self.nick;
        self.PCPlayerVC.portrait = self.portrait;
        self.PCPlayerVC.stream_addr = self.stream_addr;
        self.PCPlayerVC.liveName = self.liveName;
        self.PCPlayerVC.groupID = self.groupID;
        
    } else {
        
        self.PhonePlayVC = [[XMPhonePlayerController alloc]init];
        self.PhonePlayVC.nick = self.nick;
        self.PhonePlayVC.portrait = self.portrait;
        self.PhonePlayVC.stream_addr = self.stream_addr;
        self.PhonePlayVC.liveName = self.liveName;
        self.PhonePlayVC.groupID = self.groupID;
    }
}

- (void)prepareToPlay {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPhoneVc) name:@"DISMISSPHONEVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPCVc) name:@"DISMISSPCVC" object:nil];
    
    if (self.PCPlayerVC) {
        [self.rootVc presentViewController:self.PCPlayerVC animated:YES completion:nil];
    } else if(self.PhonePlayVC) {
        [self.rootVc presentViewController:self.PhonePlayVC animated:YES completion:nil];
    }
}

- (void)dismissPhoneVc{
    
    self.PhonePlayVC = nil;
    
}

- (void)dismissPCVc{
    
    self.PCPlayerVC = nil;
    
}


- (UIViewController *)rootVc {
    
    if (!_rootVc) {
        _rootVc = [[UIViewController alloc]init];
        
    }
    return _rootVc;
}

@end
