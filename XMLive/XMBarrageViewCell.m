//
//  XMBarrageViewCell.m
//  XMLive
//
//  Created by 王泽 on 16/11/8.
//  Copyright © 2016年 王泽. All rights reserved.
//

#import "XMBarrageViewCell.h"

@interface XMBarrageViewCell ()

@property (nonatomic, strong)   UILabel     *welcome_Label_1;
@property (nonatomic, strong)   UILabel     *welcome_Label_2;

@property (nonatomic, strong)   UILabel     *message_Label;

@property (nonatomic, strong)   UILabel     *thumb_label;
@property (nonatomic, strong)   UIImageView *thumb_imgView;

@property (nonatomic, strong)   UILabel     *nick_Label;

@end

@implementation XMBarrageViewCell

#pragma mark - life cycle methods


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupUI];
        self.selectionStyle = NO;
    }
    
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    //    self.contentView.backgroundColor = [UIColor clearColor];
    
    [self addSubviews];
    [self defineLayouts];
    [self configDatas];
    [self handleEvents];
    
}


- (void)addSubviews {
    
    [self.contentView addSubview:self.welcome_Label_1];
    [self.contentView addSubview:self.welcome_Label_2];
    [self.contentView addSubview:self.message_Label];
    [self.contentView addSubview:self.thumb_label];
    [self.contentView addSubview:self.thumb_imgView];
    [self.contentView addSubview:self.nick_Label];
    
}

- (void)defineLayouts {
    
    @weakify(self);
    [RACObserve(self, cellStyle) subscribeNext:^(id x) {
        
        switch ([x integerValue]) {
            case kMagicTableViewCellStyleWelcome:
            {
                self.welcome_Label_1.hidden = NO;
                self.welcome_Label_2.hidden = NO;
                self.message_Label.hidden = YES;
                self.thumb_label.hidden = YES;
                self.thumb_imgView.hidden = YES;
                self.nick_Label.hidden = NO;
                
                
                [self.welcome_Label_1 mas_remakeConstraints:^(MASConstraintMaker *make) {
                    @strongify(self);
                    make.left.equalTo(self.contentView).offset(5);
                    make.centerY.equalTo(self.contentView.mas_centerY);
                }];
                
                [self.nick_Label mas_remakeConstraints:^(MASConstraintMaker *make) {
                    @strongify(self);
                    make.left.equalTo(self.welcome_Label_1.mas_right).offset(5);
                    make.centerY.equalTo(self.welcome_Label_1);
                }];
                
                [self.welcome_Label_2 mas_remakeConstraints:^(MASConstraintMaker *make) {
                    @strongify(self);
                    make.left.equalTo(self.nick_Label.mas_right).offset(5);
                    make.centerY.equalTo(self.welcome_Label_1);
                }];
                
            }
                break;
            case kMagicTableViewCellStyleMessage:
            {
                self.welcome_Label_1.hidden = YES;
                self.welcome_Label_2.hidden = YES;
                self.message_Label.hidden = NO;
                self.thumb_label.hidden = YES;
                self.thumb_imgView.hidden = YES;
                self.nick_Label.hidden = NO;
                
                @weakify(self);
                [self.nick_Label mas_remakeConstraints:^(MASConstraintMaker *make) {
                    @strongify(self);
                    make.left.equalTo(self.contentView).offset(5);
                    make.centerY.equalTo(self.contentView.mas_centerY);
                }];
                
                [self.message_Label mas_remakeConstraints:^(MASConstraintMaker *make) {
                    @strongify(self);
                    make.left.equalTo(self.nick_Label.mas_right).offset(5);
                    make.centerY.equalTo(self.nick_Label);
                }];
                
            }
                break;
            case kMagicTableViewCellStyleThumbUp:
            {
                self.welcome_Label_1.hidden = YES;
                self.welcome_Label_2.hidden = YES;
                self.message_Label.hidden = YES;
                self.thumb_label.hidden = NO;
                self.thumb_imgView.hidden = NO;
                self.nick_Label.hidden = NO;
                
                @weakify(self);
                [self.nick_Label mas_remakeConstraints:^(MASConstraintMaker *make) {
                    @strongify(self);
                    make.left.equalTo(self.contentView).offset(5);
                    make.centerY.equalTo(self.contentView.mas_centerY);
                }];
                
                [self.thumb_label mas_remakeConstraints:^(MASConstraintMaker *make) {
                    @strongify(self);
                    make.left.equalTo(self.nick_Label.mas_right).offset(5);
                    make.centerY.equalTo(self.nick_Label);
                }];
                
                [self.thumb_imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    @strongify(self);
                    make.left.equalTo(self.thumb_label.mas_right).offset(5);
                    make.top.bottom.equalTo(self.contentView);
                    make.width.equalTo(self.thumb_imgView.mas_height);
                }];
                
            }
                break;
            default:
                break;
        }
        
    }];
}



- (void)configDatas {
    
    @weakify(self);
    [RACObserve(self, text) subscribeNext:^(NSString *x) {
        @strongify(self);
        self.message_Label.text = x;
    }];
    
    [RACObserve(self, nick) subscribeNext:^(NSString *x) {
        @strongify(self);
        self.nick_Label.text = x;
    }];
    
}

- (void)handleEvents {
    
    
}

#pragma mark - getter & setter methods

- (UILabel *)welcome_Label_1 {
    
    if (!_welcome_Label_1) {
        _welcome_Label_1 = [[UILabel alloc]init];
        [_welcome_Label_1 setText:@"欢迎"];
        _welcome_Label_1.font = [UIFont systemFontOfSize:20];
    }
    return _welcome_Label_1;
}

- (UILabel *)welcome_Label_2 {
    
    if (!_welcome_Label_2) {
        _welcome_Label_2 = [[UILabel alloc]init];
        [_welcome_Label_2 setText:@"来到直播间"];
        _welcome_Label_2.font = [UIFont systemFontOfSize:20];
    }
    return _welcome_Label_2;
}

- (UILabel *)message_Label {
    
    if (!_message_Label) {
        _message_Label = [[UILabel alloc]init];
        _message_Label.textColor = [UIColor whiteColor];
        _message_Label.font = [UIFont systemFontOfSize:20];
    }
    return _message_Label;
}

- (UILabel *)thumb_label {
    
    if (!_thumb_label) {
        _thumb_label = [[UILabel alloc]init];
        [_thumb_label setText:@"给主播点"];
        _thumb_label.font = [UIFont systemFontOfSize:20];
    }
    return _thumb_label;
}

- (UIImageView *)thumb_imgView {
    
    if (!_thumb_imgView) {
        _thumb_imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"赞"]];
    }
    return _thumb_imgView;
    
}

- (UILabel *)nick_Label {
    
    if (!_nick_Label) {
        _nick_Label = [[UILabel alloc]init];
        _nick_Label.textColor = [UIColor blueColor];
        _nick_Label.font = [UIFont systemFontOfSize:21];
    }
    return _nick_Label;
}

@end
