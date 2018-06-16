//
//  CSButton.m
//
//
//  Created by shitingquan on 16/7/20.
//  Copyright © 2016年 csdq. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface CSButton : UIButton
@property (strong , nonatomic,readonly) UIActivityIndicatorView *spin;
@property (nonatomic , assign) NSInteger badgeNum;
- (void)startSpin;
- (void)stopSpin;
@end
