//
//  CSButton.m
//
//
//  Created by shitingquan on 16/7/20.
//  Copyright © 2016年 csdq. All rights reserved.
//

#import "CSButton.h"
#import "CSTextLayer.h"
#define kBadgeWidth 20.0
@interface CSButton()
{
    UILabel *_badgeLb;
}
@end


@implementation CSButton
+ (instancetype)buttonWithType:(UIButtonType)buttonType{
    CSButton * btn = [super buttonWithType:buttonType];
    [btn btnInit];
    return btn;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self btnInit];
    }
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    [self btnInit];
}

- (void)btnInit{
    [self addBadgeNum];
    [self addSpin];
}

- (void)addBadgeNum{
    _badgeLb = [UILabel new];
    _badgeLb.layer.borderColor = [UIColor whiteColor].CGColor;
    _badgeLb.layer.borderWidth = 1;
    _badgeLb.backgroundColor = [UIColor redColor];
    _badgeLb.textColor = [UIColor whiteColor];
    _badgeLb.textAlignment = NSTextAlignmentCenter;
    _badgeLb.font = [UIFont boldSystemFontOfSize:9];
    _badgeLb.clipsToBounds = YES;
    _badgeLb.layer.cornerRadius = kBadgeWidth/2.0f;
    _badgeLb.frame = CGRectMake(0, 0, kBadgeWidth, kBadgeWidth);
    _badgeLb.center = CGPointMake(self.frame.size.width,0);
    _badgeLb.hidden = YES;
    [self addSubview:_badgeLb];
}

- (void)setBadgeNum:(NSInteger)badgeNum{
    _badgeNum = badgeNum;
    super.clipsToBounds = NO;
    if(_badgeNum > 99){
        _badgeLb.text = @"99+";
    }else{
        _badgeLb.text = [@(_badgeNum) stringValue];
    }
    _badgeLb.layer.hidden = _badgeNum == 0;
}

- (void)addSpin{
    _spin = [UIActivityIndicatorView new];
     [self addSubview:_spin];
}

- (void)setClipsToBounds:(BOOL)clipsToBounds{
    super.clipsToBounds = YES;
}

- (void)startSpin{
    [self.spin startAnimating];
}

- (void)stopSpin{
    [self.spin stopAnimating];
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [super touchesBegan:touches withEvent:event];
//    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:0.2 options:UIViewAnimationOptionLayoutSubviews animations:^{
//        self.transform = CGAffineTransformMakeScale(0.9, 0.9);
//    } completion:^(BOOL finished) {
//        self.transform = CGAffineTransformMakeScale(1.0, 1.0);
//    }];

//}

- (void)layoutSubviews{
    [super layoutSubviews];
    _spin.frame = CGRectMake(0,0,self.frame.size.height * 0.8, self.frame.size.height * 0.8);
    _spin.center = CGPointMake(self.bounds.size.width / 2.0f, self.frame.size.height / 2.0f);
}

@end
