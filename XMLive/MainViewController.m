//
//  MainViewController.m
//  XMLive
//
//  Created by 王泽 on 16/11/8.
//  Copyright © 2016年 王泽. All rights reserved.
//

#import "MainViewController.h"
#import "XMFFPlayerManager.h"


@interface MainViewController ()

//直播
@property(nonatomic, strong) UIButton       *btn;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"直播列表";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.btn];
    
    [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
        make.width.equalTo(@200);
        make.height.equalTo(@50);
    }];
}

//映客直播 请求回来的数据结构 示例:
/**
 *  {
 city = "\U5357\U4eac\U5e02";
 creator =
 {
 gender = 0;
 id = 8647385;
 level = 69;
 nick = "JS.  \U6c5f\U5c71\U6b27\U5df4r";
 portrait = "MTQ3NjA4Njc4MDU1OCM0MTYjanBn.jpg";
 };
 
 group = 0;
 id = 1476425824110787;
 link = 0;
 multi = 0;
 name = "\U5348\U95f4";
 "online_users" = 18370;
 optimal = 0;
 "share_addr" = "http://mlive5.inke.cn/share/live.html?uid=8647385&liveid=1476425824110787&ctime=1476425824";
 slot = 6;
 "stream_addr" = "http://pull99.a8.com/live/1476425824110787.flv";
 version = 0;
 },
 
 */

#pragma mark - ui events

- (void)didClickedCloudButtonInPanelView {
    
    NSString *urlStr = @"http://116.211.167.106/api/live/aggregation?uid=133825214&interest=1";
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    // 请求数据
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", nil];
    [mgr GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable responseObject) {
        
        NSArray *lives = responseObject[@"lives"];
        NSDictionary *dic = lives[0];
        NSDictionary *creatorInfo = dic[@"creator"];
        
        //主播名称
        dict[@"nick"] = creatorInfo[@"nick"];
        //主播头像地址
        dict[@"portrait"] = creatorInfo[@"portrait"];
        //直播流地址
        dict[@"stream_addr"] = dic[@"stream_addr"];
        //房间名称
        dict[@"liveName"] = dic[@"name"];
        //启动APP 用户登录此应用账户的时候就应该登录腾讯IM, 然后进入直播间时利用请求回来的"groupID"进入IM直播组群 (此demo IM登录集成在 XMIMController );
        //此处为腾讯IM 组群ID (模拟)
        dict[@"groupID"] = @"@TGS#3V4GNSEE4";
        
        UIAlertController *alertview=[UIAlertController alertControllerWithTitle:@"准备开始视频直播" message:nil  preferredStyle:UIAlertControllerStyleAlert];
        // 设置按钮
        UIAlertAction *defult = [UIAlertAction actionWithTitle:@"竖屏直播(phone)" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action) {
            
            [self pushAndStartPlayerWithPc:NO andDict:dict];
            
        }];
        UIAlertAction *defult2 = [UIAlertAction actionWithTitle:@"横屏直播(PC)" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action) {
            [self pushAndStartPlayerWithPc:YES andDict:dict];
        }];
        UIAlertAction *defult3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction*action) {
        }];
        
        [alertview addAction:defult];
        [alertview addAction:defult2];
        [alertview addAction:defult3];
        [self.view.window.rootViewController presentViewController:alertview animated:YES completion:nil];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
    
}

//跳转并且开始播放 是(PC端)/否(手机端)
- (void)pushAndStartPlayerWithPc:(BOOL)isPc andDict:(NSDictionary *)dict {
    
    
    //主播名称
    NSString * nick = dict[@"nick"];
    //主播头像地址
    NSString * portrait = dict[@"portrait"];
    //直播流地址
    NSString * stream_addr = dict[@"stream_addr"];
    
    NSString * liveName = dict[@"liveName"];
    
    NSString * groupID = dict[@"groupID"];
    
    //设置主播昵称,头像,设置直播地址~直播间名称
    [[XMFFPlayerManager sharedTools] setMCNick:nick headImgURLStr:portrait URLStr:stream_addr liveName:liveName groupID:groupID];
    //给予出发控制器 (isFullScreen:暂时无用)
    [[XMFFPlayerManager sharedTools] setRootViewController:self isFullScreen:YES];
    
    //判断是否为PC端 准备并开始播放;
    if (isPc) {
        [[XMFFPlayerManager sharedTools] isPCPlayer:YES];
        [[XMFFPlayerManager sharedTools] prepareToPlay];
    } else {
        [[XMFFPlayerManager sharedTools] isPCPlayer:NO];
        [[XMFFPlayerManager sharedTools] prepareToPlay];
    }
}

#pragma mark - getter & setter methods
- (UIButton *)btn {
    
    if (!_btn) {
        _btn = [[UIButton alloc]init];
        [_btn addTarget:self action:@selector(didClickedCloudButtonInPanelView) forControlEvents:UIControlEventTouchUpInside];
        [_btn setTitle:@"点击开始直播" forState:UIControlStateNormal];
        _btn.titleLabel.font = [UIFont systemFontOfSize:20];
        [_btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _btn.tag = 100;
    }
    return _btn;
}

@end

