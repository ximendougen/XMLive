//
//  XMPhonePlayerController.m
//  XMLive
//
//  Created by 王泽 on 16/11/8.
//  Copyright © 2016年 王泽. All rights reserved.
//

#import "XMPhonePlayerController.h"
#import "XMIMController.h"
#import "XMMessageInfo.h"
#import "XMPhoneView.h"

@interface XMPhonePlayerController ()<UITableViewDelegate,XMPhoneViewDelegate>

@property (nonatomic, strong) IJKFFMoviePlayerController *FFvc;
@property (nonatomic, strong) NSTimer                    *loginTimer;
@property (nonatomic, strong) XMIMController             *imVC;
@property (nonatomic, strong) UIImageView                *imageView;
@property (nonatomic, strong) UIButton                   *backBtn;
@property (nonatomic, strong) XMPhoneView                *phoneView;


@property (nonatomic, assign) BOOL                       keyboardIsVisible;
@property (nonatomic, assign) CGPoint                    startPoint;
@property (nonatomic, assign) BOOL                       bMove;

@end

@implementation XMPhonePlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    
}

- (void)setupUI {
    
    [self addSubviews];
    [self defineLayouts];
    [self configDatas];
    [self handleEvents];
    
}

- (void)addSubviews {
    
    //站位图
    [self.view addSubview:self.imageView];
    
    [self.view addSubview:self.phoneView];
    //返回按钮
    [self.view addSubview:self.backBtn];
    
}

- (void)defineLayouts {
    
    @weakify(self);
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.centerY.equalTo(self.phoneView.mas_top).offset(50);
        make.height.width.equalTo(@35);
    }];
}

- (void)configDatas {
    @weakify(self);
    [RACObserve(self, portrait) subscribeNext:^(NSString * portrait) {
        @strongify(self);
        if (portrait.length >0) {
            // 设置直播占位图片
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:portrait] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                self.phoneView.portraitImg = image;
            }];
            //图片显示完后 开始加载播放器
            IJKFFMoviePlayerController *FFvc = [[IJKFFMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:self.stream_addr] withOptions:nil];
            self.FFvc = FFvc;
            [self.FFvc prepareToPlay];
            self.FFvc.view.frame = [UIScreen mainScreen].bounds;
            
            [self.view insertSubview:self.FFvc.view atIndex:1];
            
            XMIMController *imVc = [[XMIMController alloc] init];
            self.imVC = imVc;
            imVc.view.frame = [UIScreen mainScreen].bounds;
            [self.view insertSubview:imVc.view atIndex:1];
            imVc.messBlock = self.phoneView.messBlock;
        }
    }];
    RAC(self.phoneView,nick) = RACObserve(self, nick);
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
}

- (void)dealloc {
    
    NSLog(@"");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.FFvc pause];
    [self.FFvc stop];
    [self.FFvc shutdown];
    [self.FFvc.view removeFromSuperview];
    [self stopTimer];

    
    // 控制器即将销毁，就会发出UIKeyboardWillHideNotification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DISMISSPHONEVC" object:nil];
}

//滑动开始事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.keyboardIsVisible) {
        [self.view endEditing:YES];
        self.phoneView.keyboardIsVisible = !self.keyboardIsVisible;
    }
    UITouch *touch = [touches anyObject];
    CGPoint pointone = [touch locationInView:self.view];//获得初始的接触点
    self.startPoint  = pointone;
}
//滑动移动事件
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    //imgViewTop是滑动后最后接触的View
    CGPoint pointtwo = [touch locationInView:self.phoneView];  //获得滑动后最后接触屏幕的点
    if(fabs(pointtwo.x-self.startPoint.x)>100) {  //判断两点间的距离
        self.bMove = YES;
    }
}
//滑动抬起事件
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint pointtwo = [touch locationInView:self.view];  //获得滑动后最后接触屏幕的点
    if((fabs(pointtwo.x-self.startPoint.x)>50)&&(self.bMove)) {
        //判断点的位置关系 左滑动
        if(pointtwo.x-self.startPoint.x>0) {   //左滑动业务处理
            if (!self.keyboardIsVisible) {
                self.phoneView.hidden = YES;
            }
        } else {    //判断点的位置关系 右滑动
            //右滑动业务处理
            if (!self.keyboardIsVisible) {
                self.phoneView.hidden = NO;
            }
        }
    }
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//
//    if (self.keyboardIsVisible) {
//        [self.view endEditing:YES];
//        self.phoneView.keyboardIsVisible = !self.keyboardIsVisible;
//    }
//}

#pragma mark - ui events
- (void)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 键盘即将隐藏的方法
-(void)keyboardWillHide:(NSNotification *)noti
{
    
    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.phoneView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.keyboardIsVisible = NO;
    }];
}

#pragma mark - 键盘即将弹出的方法
-(void)keyboardWillShow:(NSNotification *)noti
{
    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        // 取出键盘的高度
        CGRect keyboardF = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardH = keyboardF.size.height;
        self.phoneView.transform = CGAffineTransformMakeTranslation(0, -keyboardH);
        
    } completion:^(BOOL finished) {
        self.keyboardIsVisible = YES;
    }];
}

#pragma mark - private methods

- (void)stopTimer {
    if (self.loginTimer) {
        [self.loginTimer invalidate];
        self.loginTimer = nil;
    }
}

#pragma mark - IFMPhoneViewDelegate

- (void)didSendMessBtnClicked:(UIButton *)sendMessBtn andMess:(NSString *)mess {
    
    if (mess.length > 0) {
        [self.imVC sendMessage:mess];
    }
}

#pragma mark - getter & setter methods

- (UIImageView *)imageView {
    
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _imageView;
}

- (UIButton *)backBtn {
    
    if (!_backBtn) {
        _backBtn = [[UIButton alloc]init];
        [_backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [_backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        _backBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _backBtn.layer.cornerRadius = 18;
    }
    return _backBtn;
}

- (XMPhoneView *)phoneView {
    
    if (!_phoneView) {
        _phoneView = [[XMPhoneView alloc]init];
        _phoneView.frame = self.view.bounds;
        _phoneView.delegate = self;
    }
    return _phoneView;
}

@end

