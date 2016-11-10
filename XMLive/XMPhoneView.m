//
//  XMPhoneView.m
//  XMLive
//
//  Created by 王泽 on 16/11/8.
//  Copyright © 2016年 王泽. All rights reserved.
//

#import "XMPhoneView.h"
#import "XMBarrageViewCell.h"

@interface XMPhoneView ()<UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic, strong) UITableView                *tableView;
@property (nonatomic, strong) NSMutableArray<XMMessageInfo *>  *dataArr;

@property (nonatomic, strong) UIView                     *topHeadView;
@property (nonatomic, strong) UIImageView                *iconView;
@property (nonatomic, strong) UILabel                    *nicklabel;

@property (nonatomic, strong) UIButton                   *barrageBtn;

@property (nonatomic, strong) UIView                     *bottomPanel;
@property (nonatomic, strong) UITextField                *mess_textField;
@property (nonatomic, strong) UIButton                   *sendMessBtn;
@property (nonatomic, strong) UIButton                   *thumbUpBtn;

@end

@implementation XMPhoneView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    [self addSubviews];
    [self defineLayouts];
    [self configDatas];
    [self handleEvents];
    [self keyboardIsVisible:NO];
}

- (void)addSubviews {
    //弹幕view
    [self addSubview:self.tableView];
    
    [self addSubview:self.topHeadView];
    [self addSubview:self.iconView];
    [self addSubview:self.nicklabel];
    
    [self addSubview:self.barrageBtn];
    [self addSubview:self.thumbUpBtn];
    
    [self addSubview:self.bottomPanel];
    [self.bottomPanel addSubview:self.mess_textField];
    [self.bottomPanel addSubview:self.sendMessBtn];
    
    [self addSubview:self.thumbUpBtn];
}

- (void)defineLayouts {
    
    @weakify(self);
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self);
        make.bottom.equalTo(self.mas_bottom).offset(-70);
        make.width.equalTo(self.mas_width).multipliedBy(0.7);
        make.height.equalTo(self.mas_height).multipliedBy(0.23);
    }];
    
    [self.topHeadView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.right.equalTo(self).offset(-20);
        make.top.equalTo(self).offset(30);
        make.width.equalTo(@(110));
        make.height.equalTo(@40);
    }];
    
    [self.iconView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.right.equalTo(self.topHeadView).offset(-5);
        make.centerY.equalTo(self.topHeadView.mas_centerY);
        make.width.height.equalTo(@(30));
    }];
    
    [self.nicklabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.topHeadView.mas_centerY);
        make.left.equalTo(self.topHeadView).offset(10);
        make.right.equalTo(self.iconView.mas_left).offset(-10);
        make.height.equalTo(@(34));
    }];
    
    [self.barrageBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self).offset(20);
        make.bottom.equalTo(self).offset(-20);
        make.height.width.equalTo(@35);
    }];
    
    [self.thumbUpBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.right.equalTo(self).offset(-20);
        make.bottom.equalTo(self).offset(-20);
        make.height.width.equalTo(@35);
    }];
    
    [self.bottomPanel mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self);
        make.bottom.equalTo(self);
        make.height.equalTo(@50);
        make.width.equalTo(self.mas_width);
    }];
    
    [self.sendMessBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.right.equalTo(self.bottomPanel).offset(-10);
        make.centerY.equalTo(self.bottomPanel);
        make.height.equalTo(self.bottomPanel).offset(-10);
        make.width.equalTo(@45);
    }];
    
    [self.mess_textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.bottomPanel).offset(10);
        make.centerY.equalTo(self.bottomPanel);
        make.height.equalTo(self.bottomPanel).offset(-10);
        make.right.equalTo(self.sendMessBtn.mas_left).offset(-10);
    }];
}

- (void)configDatas {
    
    @weakify(self);
    self.messBlock = ^(XMMessageInfo *model) {
        @strongify(self);
        [self.dataArr addObject:model];
        [self.tableView reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.dataArr.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    };
    
    [RACObserve(self, keyboardIsVisible) subscribeNext:^(id x) {
        @strongify(self);
        [self keyboardIsVisible:[x boolValue]];
    }];
    RAC(self.bottomPanel,hidden) = RACObserve(self, isBottomPanelHidden);
    
    [RACObserve(self, portraitImg) subscribeNext:^(UIImage *portraitImg) {
        @strongify(self);
        if (portraitImg != nil) {
            self.iconView.image = portraitImg;
        }
    }];
    
    RAC(self.nicklabel, text) = RACObserve(self, nick);
    
}

- (void)handleEvents {
    
    @weakify(self);
    [[self.barrageBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.mess_textField becomeFirstResponder];
        [self keyboardIsVisible:YES];
    }];
    
    [[self.sendMessBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(didSendMessBtnClicked:andMess:)]) {
            [self.delegate didSendMessBtnClicked:self.sendMessBtn andMess:self.mess_textField.text];
            self.mess_textField.text = @"";
            [self.mess_textField resignFirstResponder];
            [self keyboardIsVisible:NO];
        }
    }];
    
    [[self.thumbUpBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self praiseAnimation];
    }];
}


#pragma mark - ui events

- (void)keyboardIsVisible:(BOOL) isOn {
    
    if (isOn) {
        self.barrageBtn.hidden = YES;
        self.thumbUpBtn.hidden = YES;
        self.bottomPanel.hidden = NO;
    } else {
        self.bottomPanel.hidden = YES;
        self.barrageBtn.hidden = NO;
        self.thumbUpBtn.hidden = NO;
    }
}

- (void)praiseAnimation {
    UIImageView *imageView = [[UIImageView alloc] init];
    CGRect frame = self.frame;
    //  初始frame，即设置了动画的起点
    imageView.frame = CGRectMake(frame.size.width - 50, frame.size.height - 57, 30, 30);
    //  初始化imageView透明度为0
    imageView.alpha = 0;
    //    imageView.backgroundColor = [UIColor redColor];
    imageView.clipsToBounds = YES;
    //  用0.2秒的时间将imageView的透明度变成1.0，同时将其放大1.3倍，再缩放至1.1倍，这里参数根据需求设置
    [UIView animateWithDuration:0.2 animations:^{
        imageView.alpha = 1.0;
        imageView.frame = CGRectMake(frame.size.width - 50, frame.size.height - 57, 30, 30);
        CGAffineTransform transfrom = CGAffineTransformMakeScale(1.3, 1.3);
        imageView.transform = CGAffineTransformScale(transfrom, 1, 1);
    }];
    [self insertSubview:imageView belowSubview:self.thumbUpBtn];
    //  随机产生一个动画结束点的X值
    CGFloat finishX = frame.size.width - round(random() % 200);
    //  动画结束点的Y值
    CGFloat finishY = 350;
    //  imageView在运动过程中的缩放比例
    CGFloat scale = round(random() % 2) + 0.7;
    // 生成一个作为速度参数的随机数
    CGFloat speed = 1 / round(random() % 900) + 0.6;
    //  动画执行时间
    NSTimeInterval duration = 4 * speed;
    //  如果得到的时间是无穷大，就重新附一个值（这里要特别注意，请看下面的特别提醒）
    if (duration == INFINITY) duration = 2.412346;
    // 随机生成一个0~7的数，以便下面拼接图片名
    int imageName = round(random() % 4);
    
    //  开始动画
    [UIView beginAnimations:nil context:(__bridge void *_Nullable)(imageView)];
    //  设置动画时间
    [UIView setAnimationDuration:duration];
    
    //  拼接图片名字
    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"heart_%d",imageName]];
    //  设置imageView的结束frame
    imageView.frame = CGRectMake( finishX, finishY, 30 * scale, 30 * scale);
    
    //  设置渐渐消失的效果，这里的时间最好和动画时间一致
    [UIView animateWithDuration:duration animations:^{
        imageView.alpha = 0;
    }];
    
    //  结束动画，调用onAnimationComplete:finished:context:函数
    [UIView setAnimationDidStopSelector:@selector(onAnimationComplete:finished:context:)];
    //  设置动画代理
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

/// 动画完后销毁iamgeView
- (void)onAnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    UIImageView *imageView = (__bridge UIImageView *)(context);
    [imageView removeFromSuperview];
    imageView = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XMBarrageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XMBarrageViewCell" forIndexPath:indexPath];
    
    //三种情况~ 1.新成员进入直播间, 2.成员发消息, 3.成员给主播点赞;
    
    
    switch (self.dataArr[indexPath.row].type) {
        case 0:
        {
            cell.nick = self.dataArr[indexPath.row].nick;
            cell.cellStyle = kMagicTableViewCellStyleWelcome;
            
        }
            break;
        case 1:
        {
            cell.text = self.dataArr[indexPath.row].message;
            cell.nick = self.dataArr[indexPath.row].nick;
            cell.cellStyle = kMagicTableViewCellStyleMessage;
            
        }
            break;
        case 2:
        {
            cell.nick = self.dataArr[indexPath.row].nick;
            cell.cellStyle = kMagicTableViewCellStyleThumbUp;
            
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([self.delegate respondsToSelector:@selector(didSendMessBtnClicked:andMess:)]) {
        [self.delegate didSendMessBtnClicked:self.sendMessBtn andMess:textField.text];
        self.mess_textField.text = @"";
        [self.mess_textField resignFirstResponder];
        [self keyboardIsVisible:NO];
    }
    return YES;
}


#pragma mark - getter & setter methods


- (UIView *)topHeadView {
    
    if (!_topHeadView) {
        _topHeadView = [[UIView alloc]init];
        _topHeadView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        _topHeadView.layer.cornerRadius = 20;
        _topHeadView.layer.masksToBounds = YES;
        _topHeadView.userInteractionEnabled = NO;
        
    }
    return _topHeadView;
}

- (UIImageView *)iconView {
    
    if (!_iconView) {
        
        _iconView = [[UIImageView alloc] init];
        _iconView.backgroundColor = [UIColor whiteColor];
        _iconView.layer.cornerRadius = 15;
        _iconView.layer.masksToBounds = YES;
    }
    
    return _iconView;
}

- (UILabel *)nicklabel {
    
    if (!_nicklabel) {
        _nicklabel = [[UILabel alloc] init];
        _nicklabel.font = [UIFont systemFontOfSize:12];
        _nicklabel.textAlignment = NSTextAlignmentLeft;
        _nicklabel.textColor = [UIColor whiteColor];
        _nicklabel.numberOfLines = 2;
    }
    return _nicklabel;
}


- (UIButton *)barrageBtn {
    
    if (!_barrageBtn) {
        _barrageBtn = [[UIButton alloc]init];
        _barrageBtn.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
        [_barrageBtn setImage:[UIImage imageNamed:@"message_black"] forState:UIControlStateNormal];
        [_barrageBtn setImage:[UIImage imageNamed:@"message_light"] forState:UIControlStateHighlighted];
        _barrageBtn.layer.cornerRadius = 18;
    }
    return _barrageBtn;
}

- (UIButton *)thumbUpBtn {
    
    if (!_thumbUpBtn) {
        _thumbUpBtn = [[UIButton alloc]init];
        _thumbUpBtn.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        [_thumbUpBtn setImage:[UIImage imageNamed:@"zan_black"] forState:UIControlStateNormal];
        [_thumbUpBtn setImage:[UIImage imageNamed:@"zan_light"] forState:UIControlStateHighlighted];
        _thumbUpBtn.layer.cornerRadius = 18;
    }
    return _thumbUpBtn;
}


- (UIView *)bottomPanel {
    
    if (!_bottomPanel) {
        _bottomPanel = [[UIView alloc]init];
        _bottomPanel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];;
    }
    return _bottomPanel;
}

- (UITextField *)mess_textField {
    
    if (!_mess_textField) {
        _mess_textField = [[UITextField alloc]init];
        _mess_textField.backgroundColor = [UIColor whiteColor];
        _mess_textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _mess_textField.placeholder = @"请输入弹幕的内容";
        _mess_textField.borderStyle = UITextBorderStyleRoundedRect;
        _mess_textField.delegate = self;
    }
    return _mess_textField;
}

- (UIButton *)sendMessBtn {
    
    if (!_sendMessBtn) {
        _sendMessBtn = [[UIButton alloc]init];
        _sendMessBtn.layer.cornerRadius = 5;
        _sendMessBtn.layer.masksToBounds = YES;
        _sendMessBtn.enabled = YES;
        [_sendMessBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendMessBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendMessBtn.titleLabel sizeToFit];
        [_sendMessBtn setBackgroundColor:[UIColor orangeColor]];
    }
    return _sendMessBtn;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[XMBarrageViewCell class] forCellReuseIdentifier:@"XMBarrageViewCell"];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.rowHeight = 35;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    
    return _tableView;
}

- (NSMutableArray<XMMessageInfo *> *)dataArr {
    
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc]init];
    }
    return _dataArr;
}

@end
