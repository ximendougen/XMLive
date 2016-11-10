# IOS集成IJK直播(拉流),腾讯IM,弹幕,赞.
###废话不多说,直接上干货

现有的直播一般分为Phone端,PC端,通俗来说就是**手机直播**和**电脑端**直播,下面就是 *XMFFPlayerManager* 运行后的显示效果(PC端直播流没找到,关于分辨率大家别介意):

###[demo下载连接](https://github.com/ximendougen/XMLive.git) 




**Phone端**(竖屏):

![Mou icon](http://a4.qpic.cn/psb?/V13bEYKN3PHP3i/tB1xTzHSND9xNof.2KBT9MRf73*ClaAXykM9bJwxCKc!/m/dHcBAAAAAAAA&bo=bgJ8BAAAAAADBzY!&rf=photolist)

**PC端**(竖屏&横屏):

![Mou icon](http://a4.qpic.cn/psb?/V13bEYKN3PHP3i/wjtjHFp6**GA.ne9Rg.zYhXG63yYiDQRC2pJM*Sgb3s!/m/dAsBAAAAAAAA&bo=bgJ8BAAAAAADBzY!&rf=photolist)
![Mou icon](http://a4.qpic.cn/psb?/V13bEYKN3PHP3i/v*mAeFlbT6YM0y4SGQqFqLVIKA1*k1ZKXcf2zlm6AYE!/m/dHcBAAAAAAAA&bo=JASAAgAAAAADB4A!&rf=photolist)

#### 1. 关于本demo的一些库
**IJK:**

![Mou icon](http://a4.qpic.cn/psb?/V13bEYKN3PHP3i/XXsBQWr5s.hZfTIWlfmvLTNPmJYRDfKonT3X.fT7Vf0!/m/dOMAAAAAAAAA&bo=5AFoAgAAAAADB60!&rf=photolist)

**腾讯IM:**

![Mou icon](http://a1.qpic.cn/psb?/V13bEYKN3PHP3i/HlRlTyJaZV33bpNK55KcmM*1wW2bzH4sZaOkIWD*dio!/m/dNwAAAAAAAAA&bo=EgJ.AQAAAAADB00!&rf=photolist)

绿色圈起来的是需要从第三方下载的库(*我这有份新鲜的大家可以拿去用*--[ijk & 腾讯IMSDK(10月合并最新库)](链接: https://pan.baidu.com/s/1gffY72j) 密码: fixp)


#### 2. *XMFFPlayerManager* 的使用
1. 测试接口(GET请求就够了);

	```
	http://116.211.167.106/api/live/aggregation?uid=133825214&interest=1
	```
	具体返回的数据结构我已经注释到代码中了	


2. app根控制器(MainViewController)
	
	导入**单例** *XMFFPlayerManager.h* 
	

`XMFFPlayerManager.h` 

	+ (instancetype)sharedTools;

	//设置主播昵称,头像,设置直播地址~直播间名称~聊天群ID(腾讯IM)
	- (void)setMCNick:(NSString *)nick headImgURLStr:(NSString *)portrait URLStr:(NSString *)urlStr liveName:(NSString *)liveName groupID:(NSString *)groupID;

	//给予出发控制器 (isFullScreen:暂时无用)
	- (void)setRootViewController:(UIViewController *)RootVc isFullScreen:(BOOL)on;

	//判断是否为PC端
	- (void)isPCPlayer:(BOOL)isOn;

	//准备并开始播放;
	- (void)prepareToPlay; 


`MainViewController.h`
	
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
    
    //设置主播昵称,头像,设置直播地址~直播间名称~聊天群ID(腾讯IM)
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
	

#### 3. 小结

注意:各位同学使用IJKPlayer播放直播流需要使用 *IJKFFMoviePlayerController.h*


```
//这样就能播放一个直播
	IJKFFMoviePlayerController *FFvc = [[IJKFFMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:直播流源地址] withOptions:nil];
	//需要强引用
    self.FFvc = FFvc;
    //准备并开始播放
    [self.FFvc prepareToPlay];
    self.FFvc.view.frame = [UIScreen mainScreen].bounds;
    [self.view insertSubview:self.FFvc.view atIndex:1];

```
	//在关闭播放器的时候 必须执行下面 三个方法
	- (void)viewWillDisappear:(BOOL)animated
	{
    	[super viewWillDisappear:animated];
    
    	[self.FFvc pause];
    	[self.FFvc stop];
    	[self.FFvc shutdown];
    	//从父控件移除 (我是为了防止内存泄露,聊胜于无)
    	[self.FFvc.view removeFromSuperview];
    }

关于腾讯IM 我只是封装了一个登录 , 加入组群 , 接收消息 , 和发送群消息的类;

`XMIMController.h`
	
	#import <UIKit/UIKit.h>
	#import "XMMessageInfo.h"
	typedef void(^messBlock)(XMMessageInfo *);

	@interface XMIMController : UIViewController
	//接收消息的回调
	@property (nonatomic, copy)messBlock            messBlock;

	//发消息
	- (void)sendMessage:(NSString *)mess;
	@end
	
腾讯IM用户登录需要准守代理协议 *TIMUserStatusListener*

`XMIMController.m`
	
	//
	TIMManager  *manager = [[TIMManager alloc]init];
	self.manager = manager;
	//腾讯IM云SDK 登录注册后会给 SDKAppId
	[self.manager initSdk:SDKAppId];
	
    TIMLoginParam * login_param = [[TIMLoginParam alloc ]init];
    
    //类型
    login_param.accountType = @"XXXX";
    
    //用户名称
    login_param.identifier = @"zhangsan";
    
    //用户签名:(这个就是本地私钥加密后得出的签名,具体请到腾讯IM查看)
    login_param.userSig = useSig;
    
    //一样SDKAppId
    login_param.appidAt3rd = SDKAppId;
    login_param.sdkAppId = SDKAppId;
    
    //登录腾讯IM
    [[TIMManager sharedInstance] login: login_param succ:^(){
        NSLog(@"Login 成功");
        
        //登陆成功后加入组群
        [[TIMGroupManager sharedInstance] JoinGroup:组群ID msg:@"Apply Join Group" succ:^(){
        //加入成功
            NSLog(@"Join Succ");
            
        }fail:^(int code, NSString * err) {
            NSLog(@"code=%d, err=%@", code, err);
            
            if ([err isEqualToString:@"already group member"]) {
                 NSLog(@"已经在这个群了");
            }
        }];
    } fail:^(int code, NSString * err) {
        NSLog(@"登录失败: %d->%@", code, err);
    }];


发送和接收消息需要准守代理协议 *TIMMessageListener*
	
	#pragma mark - TIMMessageListener
	
	//类似于远程推送 ,登陆完,准守协议后只要实现此方法 就会时刻监听别人发送的信息;
	- (void)onNewMessage:(NSArray*) msgs {
	
    //获取最新的一条信息
    TIMMessage * message = (TIMMessage *)msgs[0];
    XMMessageInfo *model = [[XMMessageInfo alloc]init];
    //发送信息人昵称
    model.nick = [message sender];
    
    //此处只做了文本信息的解析 , 还有其他一些类型的信息大家请自行去腾讯IM文档查看
    if ([elem isKindOfClass:[TIMTextElem class]]) {
            TIMTextElem * text_elem = (TIMTextElem * )elem;
             
            NSLog(@""%@", text_elem.text;);
        }
    
	}

	
	//发送文本消息 
	- (void)sendMessage:(NSString *)mess{

    if (mess.length > 0) {
        TIMTextElem * text_elem = [[TIMTextElem alloc] init];
        
        [text_elem setText:mess];
        
        TIMMessage * msg = [[TIMMessage alloc] init];
        [msg addElem:text_elem];
        
        //此处 self.grp_conversation 为 "组群会话" 
        [self.grp_conversation sendMessage:msg succ:^(){
        	//成功
            NSLog(@"SendMsg Succ");
        }fail:^(int code, NSString * err) {
        	//失败
            NSLog(@"SendMsg Failed:%d->%@", code, err);
        }];
    }
}

#### 4. 结束语

希望本篇对即将需要学习和研发直播项目的同学们有所帮助;

以后也会不定期更新一些工作中的实用技术,请大家多多关照 , github 上点个Star~
