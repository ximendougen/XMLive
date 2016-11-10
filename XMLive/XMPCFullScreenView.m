//
//  XMPCFullScreenView.m
//  XMLive
//
//  Created by 王泽 on 16/11/8.
//  Copyright © 2016年 王泽. All rights reserved.
//

#import "XMPCFullScreenView.h"

@interface XMPCFullScreenView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView                     *topPanel;
@property (nonatomic, strong) UIButton                   *rotatoBtn;
@property (nonatomic, strong) UIView                     *spaceView;
@property (nonatomic, strong) UILabel                    *room_name;

@property (nonatomic, strong) UIView                     *bottomPanel;
@property (nonatomic, strong) UIButton                   *barrageBtn;
@property (nonatomic, strong) UITextField                *mess_textField;
@property (nonatomic, strong) UIButton                   *sendMessBtn;
@property (nonatomic, strong) UIButton                   *playBtn;

@end

@implementation XMPCFullScreenView

#pragma mark - life cycle methods

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
}

- (void)addSubviews {
    [self addSubview:self.topPanel];
    [self.topPanel addSubview:self.rotatoBtn];
    [self.topPanel addSubview:self.spaceView];
    [self.topPanel addSubview:self.room_name];
    
    [self addSubview:self.bottomPanel];
    [self.bottomPanel addSubview:self.barrageBtn];
    [self.bottomPanel addSubview:self.mess_textField];
    [self.bottomPanel addSubview:self.sendMessBtn];
    [self.bottomPanel addSubview:self.playBtn];
    
}

- (void)defineLayouts {
    
    @weakify(self);
    [self.topPanel mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.top.right.equalTo(self);
        make.height.equalTo(@50);
    }];
    
    [self.rotatoBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.topPanel);
        make.left.equalTo(self.topPanel.mas_left).offset(10);
        make.height.width.equalTo(@35);
    }];
    
    [self.spaceView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.topPanel);
        make.left.equalTo(self.rotatoBtn.mas_right).offset(12);
        make.height.equalTo(@40);
        make.width.equalTo(@1);
    }];
    
    [self.room_name mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.topPanel);
        make.left.equalTo(self.spaceView.mas_right).offset(18);
    }];
    
    [self.bottomPanel mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.bottom.right.equalTo(self);
        make.height.equalTo(@50);
    }];
    
    [self.barrageBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.bottomPanel);
        make.right.equalTo(self.bottomPanel.mas_right).offset(-20);
        make.height.width.equalTo(@35);
    }];
    
    [self.sendMessBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.bottomPanel);
        make.right.equalTo(self.barrageBtn.mas_left).offset(-20);
        make.height.equalTo(@30);
        make.width.equalTo(@60);
    }];
    
    [self.playBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.bottomPanel);
        make.left.equalTo(self.bottomPanel.mas_left).offset(20);
        make.height.width.equalTo(@35);
    }];
    
    [self.mess_textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.bottomPanel);
        make.left.equalTo(self.playBtn.mas_right).offset(20);
        make.right.equalTo(self.sendMessBtn.mas_left).offset(-20);
        make.height.equalTo(@(30));
    }];
    
}

- (void)configDatas {
    
    RAC(self.room_name ,text) = RACObserve(self, root_name_str);
}

- (void)handleEvents {
    
    @weakify(self);
    [[self.rotatoBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(didRotatoBtnClicked:)]) {
            [self.delegate didRotatoBtnClicked:self.rotatoBtn];
        }
    }];
    
    [[self.barrageBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(didBarrageBtnClicked:)]) {
            [self.delegate didBarrageBtnClicked:self.barrageBtn];
        }
    }];
    
    [[self.sendMessBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(didSendMessBtnClicked:andMess:)]) {
            [self.delegate didSendMessBtnClicked:self.sendMessBtn andMess:self.mess_textField.text];
            self.mess_textField.text = @"";
            [self.mess_textField resignFirstResponder];
        }
    }];
    
    [[self.playBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(didPlayBtnClicked:)]) {
            [self.delegate didPlayBtnClicked:self.playBtn];
        }
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([self.delegate respondsToSelector:@selector(didSendMessBtnClicked:andMess:)]) {
        [self.delegate didSendMessBtnClicked:self.sendMessBtn andMess:textField.text];
        self.mess_textField.text = @"";
        [self.mess_textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - getter & setter methods

- (UIView *)topPanel {
    
    if (!_topPanel) {
        _topPanel = [[UIView alloc]init];
        _topPanel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        
    }
    return _topPanel;
}

- (UIButton *)rotatoBtn {
    
    if (!_rotatoBtn) {
        _rotatoBtn = [[UIButton alloc]init];
        [_rotatoBtn setBackgroundColor:[UIColor clearColor]];
        [_rotatoBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        
    }
    return _rotatoBtn;
}

- (UIView *)spaceView {
    
    if (!_spaceView) {
        _spaceView = [[UIView alloc]init];
        _spaceView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    }
    return _spaceView;
}

- (UILabel *)room_name {
    
    if (!_room_name) {
        _room_name = [[UILabel alloc]init];
        _room_name.textColor = [UIColor whiteColor];
    }
    return _room_name;
}


- (UIView *)bottomPanel {
    
    if (!_bottomPanel) {
        _bottomPanel = [[UIView alloc]init];
        _bottomPanel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    }
    return _bottomPanel;
}

- (UIButton *)playBtn {
    
    if (!_playBtn) {
        _playBtn = [[UIButton alloc]init];
        [_playBtn setBackgroundColor:[UIColor clearColor]];
        [_playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"pause_light"] forState:UIControlStateHighlighted];
    }
    return _playBtn;
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
        [_sendMessBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_sendMessBtn.titleLabel sizeToFit];
        [_sendMessBtn setBackgroundColor:[UIColor orangeColor]];
    }
    return _sendMessBtn;
}

- (UIButton *)barrageBtn {
    
    if (!_barrageBtn) {
        _barrageBtn = [[UIButton alloc]init];
        [_barrageBtn setBackgroundColor:[UIColor clearColor]];
        [_barrageBtn setImage:[UIImage imageNamed:@"tanmu"] forState:UIControlStateNormal];
    }
    return _barrageBtn;
}


@end
