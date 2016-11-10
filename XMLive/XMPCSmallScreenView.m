//
//  XMPCSmallScreenView.m
//  XMLive
//
//  Created by 王泽 on 16/11/8.
//  Copyright © 2016年 王泽. All rights reserved.
//

#import "XMPCSmallScreenView.h"

@interface XMPCSmallScreenView ()

@property (nonatomic, strong) UIButton                   *backBtn;
@property (nonatomic, strong) UIButton                   *playBtn;
@property (nonatomic, strong) UIButton                   *rotatoBtn;

@end

@implementation XMPCSmallScreenView

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
    
    [self addSubview:self.backBtn];
    [self addSubview:self.rotatoBtn];
    [self addSubview:self.playBtn];
}

- (void)defineLayouts {
    
    @weakify(self);
    [self.backBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.top.equalTo(self).offset(20);
        make.height.width.equalTo(@35);
    }];
    
    [self.playBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.right.equalTo(self).offset(-20);
        make.bottom.equalTo(self).offset(-75);
        make.height.width.equalTo(@35);
    }];
    
    [self.rotatoBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.right.equalTo(self).offset(-20);
        make.bottom.equalTo(self).offset(-20);
        make.height.width.equalTo(@35);
    }];
}

- (void)configDatas {
    
    
    
}

- (void)handleEvents {
    
    @weakify(self);
    [[self.backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(didBackBtnClicked:)]) {
            [self.delegate didBackBtnClicked:self.backBtn];
        }
    }];
    
    [[self.playBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(didPlayBtnClicked:)]) {
            [self.delegate didPlayBtnClicked:self.playBtn];
        }
    }];
    
    [[self.rotatoBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if ([self.delegate respondsToSelector:@selector(didRotatoBtnClicked:)]) {
            [self.delegate didRotatoBtnClicked:self.rotatoBtn];
        }
    }];
    
    
}

#pragma mark - getter & setter methods

- (UIButton *)backBtn {
    
    if (!_backBtn) {
        _backBtn = [[UIButton alloc]init];
        _backBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [_backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        _backBtn.layer.cornerRadius = 18;
    }
    return _backBtn;
}

- (UIButton *)playBtn {
    
    if (!_playBtn) {
        _playBtn = [[UIButton alloc]init];
        _playBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [_playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"pause_light"] forState:UIControlStateHighlighted];
        _playBtn.layer.cornerRadius = 18;
    }
    return _playBtn;
}

- (UIButton *)rotatoBtn {
    
    if (!_rotatoBtn) {
        _rotatoBtn = [[UIButton alloc]init];
        _rotatoBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [_rotatoBtn setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
        [_rotatoBtn setImage:[UIImage imageNamed:@"fullscreen_light"] forState:UIControlStateHighlighted];
        _rotatoBtn.layer.cornerRadius = 18;
        
    }
    return _rotatoBtn;
}


@end
