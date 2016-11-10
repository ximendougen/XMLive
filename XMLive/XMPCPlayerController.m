//
//  XMPCPlayerController.m
//  XMLive
//
//  Created by 王泽 on 16/11/8.
//  Copyright © 2016年 王泽. All rights reserved.
//

#import "XMPCPlayerController.h"
#import "DanmakuView.h"
#import "XMRotatoUtil.h"
#import "XMPCSmallScreenView.h"
#import "XMPCFullScreenView.h"
#import "XMMessageInfo.h"
#import "XMIMController.h"
#import "AppDelegate.h"


@interface XMPCPlayerController ()<DanmakuDelegate,UITextFieldDelegate,XMPCSmallScreenViewDelegate,XMPCFullScreenViewDelegate> {
    
    float _value;
    DanmakuView *_danmakuView;
    NSTimer *_timer;
}

@property (nonatomic, strong) UIView                        *contentView;
@property (nonatomic, strong) IJKFFMoviePlayerController    *FFvc;
@property (nonatomic, strong) UIImageView                   *imageView;
@property (nonatomic, strong) XMIMController                *imVC;

@property (nonatomic, assign) CGFloat                       FFvc_Height_multipliedBy;
@property (nonatomic, assign) CGFloat                       FFvc_Width_multipliedBy;
@property (nonatomic, assign) UIInterfaceOrientation        lastOrientation;

@property (nonatomic, strong) XMPCSmallScreenView           *smallScreenView;
@property (nonatomic, strong) XMPCFullScreenView            *fullScreenView;
@property (nonatomic, strong) NSTimer                       *showView_timer;

@property (nonatomic, assign) BOOL                          keyboardIsVisible;

@end

@implementation XMPCPlayerController

#pragma mark - life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
}

- (void)setupUI {
    
    [self addSubviews];
    [self setupBarrageUI];
    [self configDatas];
    [self handleEvents];
    
}

- (void)setupBarrageUI {
    
    CGRect rect =  CGRectMake(0, 2, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-4);
    
    DanmakuConfiguration *configuration = [[DanmakuConfiguration alloc] init];
    configuration.duration = 6.5;
    configuration.paintHeight = 21;
    configuration.fontSize = 20;
    configuration.largeFontSize = 20;
    configuration.maxLRShowCount = 30;
    configuration.maxShowCount = 45;
    _danmakuView = [[DanmakuView alloc] initWithFrame:rect Configuration:configuration];
    _danmakuView.delegate = self;
    // 添加一个子控件view(盖在siblingSubview的上面)
    [self.contentView addSubview:_danmakuView];
    _danmakuView.isPrepared = YES;
    [self onStartClick:nil];
    
    _danmakuView.hidden = YES;
    [self onStopClick:nil];
    [self.contentView addSubview:self.fullScreenView];
    if (!self.fullScreenView.hidden) {
        [self startTimer];
    }
}

- (void)addSubviews {
    
    self.FFvc_Height_multipliedBy = self.view.bounds.size.height/3;
    self.FFvc_Width_multipliedBy = self.view.bounds.size.width/3;
    
    [self.view addSubview:self.contentView];
    //站位图
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.smallScreenView];
    if (!self.smallScreenView.hidden) {
        [self startTimer];
    }
}

- (void)configDatas {
    @weakify(self);
    [RACObserve(self, portrait) subscribeNext:^(NSString * x) {
        @strongify(self);
        if (x.length >0) {
            // 设置直播占位图片
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.portrait] placeholderImage:nil];
            [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.contentView);
            }];
            //图片显示完后 开始加载播放器
            IJKFFMoviePlayerController *FFvc = [[IJKFFMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:self.stream_addr] withOptions:nil];
            self.FFvc = FFvc;
            [self.FFvc prepareToPlay];
            
            self.FFvc.view.frame = self.contentView.bounds;
            [self.contentView insertSubview:self.FFvc.view atIndex:1];
            
            XMIMController *imVc = [[XMIMController alloc] init];
            self.imVC = imVc;
            imVc.view.frame = [UIScreen mainScreen].bounds;
            [self.view insertSubview:imVc.view atIndex:1];
            
            @weakify(self);
            imVc.messBlock = ^(XMMessageInfo *model) {
                @strongify(self);
                if (model.type == 1) {
                    long time = ([self danmakuViewGetPlayTime:nil]+1)*1000;
                    NSString *pString;
                    if ([model.nick isEqualToString:@"zhangsan"]) {
                        pString = [NSString stringWithFormat:@"%ld,0,1,FF0000,125", time];
                    } else {
                        pString = [NSString stringWithFormat:@"%ld,0,1,00EBFF,125", time];
                    }
                    NSString *mString = model.message;
                    DanmakuSource *danmakuSource = [DanmakuSource createWithP:pString M:mString];
                    [_danmakuView sendDanmakuSource:danmakuSource];
                }
            };
        }
    }];
//    RAC(self.chatVc,groupID) = RACObserve(self, groupID);
}

- (void)handleEvents {
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    
    // 键盘即将显示，就会发出UIKeyboardWillShowNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // 键盘即将隐藏，就会发出UIKeyboardWillHideNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [(AppDelegate*)[UIApplication sharedApplication].delegate setAllowRotation:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.FFvc pause];
    [self.FFvc stop];
    [self.FFvc shutdown];
    [self.FFvc.view removeFromSuperview];
    [self stopTimer];
    [self onPauseClick:nil];
    [self onStopClick:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISSPCVC" object:nil];
    
    [(AppDelegate*)[UIApplication sharedApplication].delegate setAllowRotation:NO];
}

- (void)dealloc {
    
    NSLog(@"");
}

//iOS8旋转动作的具体执行
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator: coordinator];
    // 监察者将执行： 1.旋转前的动作  2.旋转后的动作（completion）
    [coordinator animateAlongsideTransition: ^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         if ([XMRotatoUtil isOrientationLandscape]) {
             _lastOrientation = [UIApplication sharedApplication].statusBarOrientation;
             [self p_prepareFullScreen];
         }
         else {
             [self p_prepareSmallScreen];
         }
     } completion: ^(id<UIViewControllerTransitionCoordinatorContext> context) {
     }];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (self.keyboardIsVisible) {
        
        [self.view endEditing:YES];
        
    } else {
        [self stopTimer];
        if([XMRotatoUtil isOrientationLandscape]) {
            
            self.fullScreenView.hidden = !self.fullScreenView.hidden;
            if (!self.fullScreenView.hidden) {
                [self startTimer];
            }
        }
        else {
            self.smallScreenView.hidden = !self.smallScreenView.hidden;
            if (!self.smallScreenView.hidden) {
                [self startTimer];
            }
        }
    }
}

#pragma mark - 键盘即将隐藏的方法
-(void)keyboardWillHide:(NSNotification *)noti
{
    [self startTimer];
    
    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.fullScreenView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.keyboardIsVisible = NO;
    }];
}

#pragma mark - 键盘即将弹出的方法
-(void)keyboardWillShow:(NSNotification *)noti
{
    [self stopTimer];
    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        // 取出键盘的高度
        CGRect keyboardF = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardH = keyboardF.size.height;
        self.fullScreenView.transform = CGAffineTransformMakeTranslation(0, -keyboardH);
        
    } completion:^(BOOL finished) {
        self.keyboardIsVisible = YES;
    }];
}

//
//-(void)updateViewConstraints {
//
//
//    [self.FFvc.view mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.equalTo(self.view).multipliedBy(self.FFvc_Height_multipliedBy);
//    }];
//    [super updateViewConstraints];
//}

#pragma mark - Private

// 切换成全屏的准备工作
- (void)p_prepareFullScreen {
    
    self.FFvc_Height_multipliedBy = self.view.bounds.size.height;
    self.FFvc.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.FFvc_Height_multipliedBy);
    self.contentView.frame = self.view.bounds;
    self.smallScreenView.hidden = YES;
    self.fullScreenView.hidden = NO;
    self.fullScreenView.frame = self.view.bounds;
    _danmakuView.frame = self.view.bounds;
    _danmakuView.isPrepared = YES;
    [self onStartClick:nil];
    _danmakuView.hidden = NO;
}

// 切换成小屏的准备工作
- (void)p_prepareSmallScreen {
    
    self.FFvc_Height_multipliedBy = self.view.bounds.size.height/3;
    self.contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.FFvc_Height_multipliedBy);
    self.FFvc.view.frame = self.contentView.bounds;
    self.fullScreenView.hidden = YES;
    self.smallScreenView.hidden = NO;
    _danmakuView.hidden = YES;
    [self onStopClick:nil];
}

- (void)onTimeCount
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    _value+=0.1/a;
    if (_value>(double)a) {
        _value=0;
    }
}

#pragma mark - ui events

- (void)hiddenView:(id)sender {
    
    if([XMRotatoUtil isOrientationLandscape]) {
        
        self.fullScreenView.hidden = YES;
    }
    else {
        self.smallScreenView.hidden = YES;
    }
}


- (void)startTimer {
    if (self.showView_timer == nil) {
        self.showView_timer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(hiddenView:) userInfo:nil repeats:NO];
    }
}

- (void)stopTimer {
    if (self.showView_timer) {
        [self.showView_timer invalidate];
        self.showView_timer = nil;
    }
}

//开始弹幕
- (void)onStartClick:(id)sender
{
    if (_danmakuView.isPrepared) {
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimeCount) userInfo:nil repeats:YES];
        }
        [_danmakuView start];
    }
}

//暂停弹幕
- (void)onPauseClick:(id)sender
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [_danmakuView pause];
}

//隐藏弹幕
- (void)onHiddenClick:(id)sender {
    
    _danmakuView.hidden = YES;
    
}

//显示弹幕
- (void)onWatchClick:(id)sender {
    
    _danmakuView.hidden = NO;
    
}

//停止弹幕
- (void)onStopClick:(id)sender {
    
    [_danmakuView stop];
}

- (void)onBarrageBtnClick:(UIButton *)barrageBtn {
    
    if (_danmakuView.isPlaying) {
        [barrageBtn setImage:[UIImage imageNamed:@"tanmu_close"] forState:UIControlStateNormal];
        [self onStopClick:nil];
        [self onHiddenClick:nil];
    } else {
        [barrageBtn setImage:[UIImage imageNamed:@"tanmu"] forState:UIControlStateNormal];
        [self onStartClick:nil];
        [self onWatchClick:nil];
    }
}

- (void)audioUse {
    
    [self.FFvc pause];
}

- (void)audioNoUse {
    
    [self.FFvc play];
}

#pragma mark - DanmakuDelegate

- (float)danmakuViewGetPlayTime:(DanmakuView *)danmakuView
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    return _value * (double)a;
}

- (BOOL)danmakuViewIsBuffering:(DanmakuView *)danmakuView
{
    return NO;
}

- (void)danmakuViewPerpareComplete:(DanmakuView *)danmakuView
{
    [_danmakuView start];
}

#pragma mark - IFMSmallScreenViewDelegate & IFMFullScreenViewDelegate

- (void)didBackBtnClicked:(UIButton *)backBtn {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didPlayBtnClicked:(UIButton *)playBtn {
    
    if (self.FFvc.isPlaying) {
        [playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [playBtn setImage:[UIImage imageNamed:@"play_light"] forState:UIControlStateHighlighted];
        [self.FFvc pause];
    } else {
        [playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [playBtn setImage:[UIImage imageNamed:@"pause_light"] forState:UIControlStateHighlighted];
        [self.FFvc play];
    }
}

- (void)didRotatoBtnClicked:(UIButton *)rotatoBtn {
    
    [self stopTimer];
    if([XMRotatoUtil isOrientationLandscape]) {
        [XMRotatoUtil forceOrientation: UIInterfaceOrientationPortrait];
        
    }
    else {
        [XMRotatoUtil forceOrientation: UIInterfaceOrientationLandscapeRight];
    }
    [self startTimer];
    [self.view endEditing:YES];
}

- (void)didBarrageBtnClicked:(UIButton *)barrageBtn {
    [self onBarrageBtnClick:barrageBtn];
}


- (void)didSendMessBtnClicked:(UIButton *)sendMessBtn andMess:(NSString *)mess {
    
    if (mess.length > 0) {
        [self.imVC sendMessage:mess];
    }
}

#pragma mark - getter & setter methods

- (UIView *)contentView {
    
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor blackColor];
        _contentView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.FFvc_Height_multipliedBy);
        
    }
    return _contentView;
}

- (UIImageView *)imageView {
    
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
    }
    return _imageView;
}

- (UIView *)smallScreenView {
    
    if (!_smallScreenView) {
        _smallScreenView = [[XMPCSmallScreenView alloc]init];
        _smallScreenView.frame = self.contentView.bounds;
        _smallScreenView.delegate = self;
    }
    return _smallScreenView;
}

- (UIView *)fullScreenView {
    
    if (!_fullScreenView) {
        _fullScreenView = [[XMPCFullScreenView alloc]init];
        _fullScreenView.root_name_str = self.liveName;
        _fullScreenView.delegate = self;
        _fullScreenView.hidden = YES;
        _fullScreenView.root_name_str = self.liveName;
    }
    return _fullScreenView;
}


@end

